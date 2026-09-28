"""Extract the non-dialogue text of ps2.asm into work/script.json.

    python tools/extract_tables.py [--rebuild]

A segment is a stretch of ps2.asm, from a label to the next `charset` reset (or to an
explicit end label), whose text lines are one of:

    nametxt "..."          fixed-length name records (the `length` in force pads them)
    soundtracktxt "..."    the Ustvestia soundtrack titles (12 cells, zero padded)
    dc.b "..."             a fixed-width row (window art, place names, job titles)
    cursorbox "..."        a menu row after the two cursor-box tiles

A run is one name, or one window: the text rows of a WinArt block joined with {BR}
(blank rows - the dakuten rows between text rows - are kept as they are). Every run
records the ordinal of its lines within the segment (`rows`), so the generator finds
them again however the text before them changes. `width` is the fixed cell count of
each row; `charset` says whether the bytes are script codes (through VDPCharacterMaps)
or font tile numbers (window art).

JP text is added where the table exists in the JP ROM at a known address with the same
record layout (names, items, techniques, enemies, soundtracks).
Without --rebuild existing `en` and `note` fields are kept.
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import asmlist
import ps2text

ASM = os.path.join(ROOT, 'PSII_Disasm', 'ps2.asm')
OUT = os.path.join(ROOT, 'work', 'script.json')

# name, start label, end label (None: next charset reset), grouping, note, JP (addr, stride, length)
SEGMENTS = [
    ('charnames', 'CharNames', 'CharNamesEnd', 'line',
     'default party names (the player can rename them); six letters, drawn as a 32-px plate',
     (0x898A, 4, 4)),
    ('items', 'InventoryData', 'TechniqueData', 'line',
     'item names; 10 cells in the name records', (0x12B68, 16, 10)),
    ('techs', 'TechniqueData', None, 'line',
     'technique names; 5 cells in the technique records', (0x13368, 8, 5)),
    ('enemies', 'EnemyNames', None, 'line',
     'enemy names; 10 cells', (0x17596, 10, 10)),
    ('soundtracks', 'SoundtrackCharArray', None, 'line',
     'music titles in the Ustvestia house; 12 cells', (0x188D2, 12, 12)),
    ('teleport', 'TeleportPlaceNamesArray', None, 'line',
     'places on the teleport list; 5 cells', None),
    ('jobs', 'loc_11456', None, 'line',
     'job titles on the status screen; 8 cells (font tiles)', None),
    ('labels', 'loc_114DA', None, 'line',
     'small window labels (font tiles)', None),
    ('windows', 'WinArt_PlayerMenu', None, 'window',
     'menu windows and profiles drawn from font tiles: each run is one window, a row per {BR}', None),
]

# segments the generator writes somewhere else than the stock table they were read from:
# (file under PSII_Disasm, start label, end label, width)
TARGETS = {'charnames': ('ext/names.asm', 'CharNamesLong', 'CharNamesLongEnd', 6)}
# nametxt records: the name field's length (the row's own text is shorter when padded by $C4)
NAME_FIELD = {'items': 10, 'techs': 5, 'enemies': 10}

_STR = re.compile(r'^\s*(nametxt|soundtracktxt|dc\.b|cursorbox)\s+(".*?")(\s*;.*|\s*)$')
_LABEL = re.compile(r'^([A-Za-z_]\w*):')
SCRIPT_CS = 'script'
TILE_CS = 'tile'


def parse_asm_string(s):
    """An AS string literal -> list of characters (\\I is the double quote in this source)."""
    assert s[0] == '"' and s[-1] == '"', s
    body = s[1:-1]
    out = []
    i = 0
    while i < len(body):
        if body[i] == '\\' and i + 1 < len(body):
            if body[i + 1] == 'I':
                out.append('"')
                i += 2
                continue
            raise ValueError('escape in ' + s)
        out.append(body[i])
        i += 1
    return ''.join(out)


def segment_lines(src, start_label, end_label):
    start = next(i for i, l in enumerate(src) if l.startswith(start_label + ':'))
    if end_label:
        end = next(i for i in range(start, len(src)) if src[i].startswith(end_label + ':'))
    else:
        end = next(i for i in range(start, len(src)) if src[i].strip() == 'charset')
    # the charset in force: the last `charset 'A', ...` before the start
    cs = None
    first = next((i for i in range(start, end) if _STR.match(src[i])), start)
    for i in range(first, -1, -1):
        m = re.match(r"\s*charset\s+'A',\s*\"\\(\d+)", src[i])
        if m:
            cs = SCRIPT_CS if m.group(1) == '11' else TILE_CS
            break
    return start, end, cs


def main():
    rebuild = '--rebuild' in sys.argv
    src = open(ASM, encoding='latin-1').read().split('\n')
    jp_rom = open(os.path.join(ROOT, 'work', 'ps2jp_stock.bin'), 'rb').read()
    jpd = ps2text.jp_decode_table()
    old = {}
    if os.path.exists(OUT) and not rebuild:
        for seg in json.load(open(OUT, encoding='utf-8'))['segments'].values():
            for r in seg['runs']:
                old[r['id']] = r

    segments = {}
    for name, start_label, end_label, grouping, note, jp in SEGMENTS:
        start, end, cs = segment_lines(src, start_label, end_label)
        rows = []          # (ordinal among string lines, line number, kind, text, label)
        label = None
        ordinal = 0
        for i in range(start, end):
            m = _LABEL.match(src[i])
            if m:
                label = m.group(1)
            s = _STR.match(src[i])
            if s:
                rows.append((ordinal, i + 1, s.group(1), parse_asm_string(s.group(2)), label))
                ordinal += 1
        runs = []
        if grouping == 'line':
            for k, (o, line, kind, text, lab) in enumerate(rows):
                runs.append({'rows': [o], 'line': line, 'kind': kind, 'label': lab,
                             'width': len(text), 'text': text.rstrip() if kind == 'dc.b' else text})
        else:
            by_label = {}
            for o, line, kind, text, lab in rows:
                by_label.setdefault(lab, []).append((o, line, kind, text))
            for lab, rs in by_label.items():
                text_rows = [r for r in rs if r[3].strip()]
                if not text_rows:
                    continue
                runs.append({'rows': [r[0] for r in text_rows], 'line': text_rows[0][1],
                             'kind': 'window', 'label': lab,
                             'width': max(len(r[3]) for r in text_rows),
                             'widths': [len(r[3]) for r in text_rows],
                             'cursor': [r[2] == 'cursorbox' for r in text_rows],
                             'text': '{BR}'.join(r[3].rstrip() for r in text_rows)})
        seg_runs = []
        for k, r in enumerate(runs):
            rid = '%s#%03d' % (name, k)
            e = {'id': rid, 'line': r['line'], 'label': r['label'], 'rows': r['rows'],
                 'kind': r['kind'], 'width': r['width']}
            if 'widths' in r:
                e['widths'] = r['widths']
                e['cursor'] = r['cursor']
            if jp:
                base, stride, length = jp
                if name == 'charnames' or k > 0 or name in ('soundtracks',):
                    idx = k if name in ('charnames', 'soundtracks') else k
                    raw = jp_rom[base + stride * idx:base + stride * idx + length]
                    t = ''
                    for b in raw:
                        if b == 0xC4:
                            break
                        t += jpd.get(b, '{%02X}' % b)
                    e['jp'] = t.rstrip()
            e['us'] = r['text']
            prev = old.get(rid, {})
            e['en'] = prev.get('en', r['text'])
            if prev.get('note'):
                e['note'] = prev['note']
            seg_runs.append(e)
        segments[name] = {'note': note, 'start': start_label, 'end': end_label, 'charset': cs,
                          'runs': seg_runs}
        if name in NAME_FIELD:
            for r in seg_runs:
                r['width'] = NAME_FIELD[name]
        if name in TARGETS:            # read from the stock table, written to another one
            file, start2, end2, width = TARGETS[name]
            segments[name].update({'file': file, 'start': start2, 'end': end2})
            for r in seg_runs:
                r['width'] = width
        print('%-12s %-6s %3d runs  lines %d-%d' % (name, cs, len(seg_runs), start + 1, end + 1))

    doc = {'format': 'ps2 script v1',
           'notes': 'Edit only `en`. Every row is fixed-width: `width` cells (`widths` per row for '
                    'windows); a window is its text rows joined with {BR}, in order. `rows` and '
                    '`line` locate the text in ps2.asm and are informational.',
           'segments': segments}
    open(OUT, 'w', encoding='utf-8', newline='\n').write(json.dumps(doc, ensure_ascii=False, indent=1) + '\n')
    print('wrote', os.path.relpath(OUT, ROOT))


if __name__ == '__main__':
    main()

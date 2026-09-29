"""The Japanese of the tables drawn from font tiles or kept outside the name records: the
window art (menus, profiles, the stat windows), the job titles, the prompts (WHO?, NEXT,
ON?), the small battle labels and the teleport places. extract_tables.py reads the name
records' JP itself; this module supplies the rest.

    python tools/jptables.py            print the JP of every such run
    python tools/jptables.py --apply    write it into work/script.json as `jp` (only `jp`)

Where the JP keeps them (work/ps2jp_stock.bin), each found from the ROM, not guessed:
* WindowArtLayoutPtrs at $13568 ($200 below the US): the same 116 entries in the same
  order, 8 bytes each - Y, X, art pointer, width + 1, lines - 1. An art pointer into RAM
  ($FF8000 + n) is a window copied from DynamicWindowsStart, $15448 in the JP (the operand
  of the copy loop the US has at $F83C, found at $F698).
* A window row is two tile lines: the dakuten and handakuten marks, then the letters.
* Job titles at $112C0, 16 bytes each (marks, then letters), in the US order.
* Prompts at $1127C: だれが? (US WHO?), NEXT, だれに? (US ON?); then the status labels.
* The battle labels (US loc_114DA) at $113B2; the teleport places in script bytes at
  $10E18, 5 each.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import asmlist
import ps2text

JP_WINDOW_TABLE = 0x13568
JP_DYNAMIC_WINDOWS = 0x15448
JP_JOBS = 0x112C0
JP_PLACES = 0x10E18
WINDOW_ENTRIES = 116
BLANK, DAKU, HANDAKU = 0x26, 0x5B, 0x5C
# tiles that frame a window: borders, the cursor box
FRAME = {0xB9: '', 0xBE: '', 0xB4: '', 0xB5: ''}
# the prompts and labels, as (JP) they stand in the ROM
PROMPTS_JP = ['だれが?', 'NEXT', 'だれに?', 'HP', 'LV', 'NEXT']
LABELS_JP = ['HP', 'かいふく', 'ミス']


def _rom():
    return open(os.path.join(ROOT, 'work', 'ps2jp_stock.bin'), 'rb').read()


def tile_row(marks, letters):
    """One text row of tile art: a line of dakuten marks over a line of letters."""
    out = []
    for m, b in zip(marks, letters):
        if b in FRAME:
            out.append(FRAME[b])
            continue
        ch = ps2text._JP_TILES.get(b)
        if ch is None:
            out.append('{%02X}' % b)
            continue
        if m == DAKU:
            ch = ps2text._DAKU.get(ch, ch + '゛')
        elif m == HANDAKU:
            ch = ps2text._HANDAKU.get(ch, ch + '゜')
        out.append(ch)
    return ''.join(out).strip()


def art_rows(rom, addr, width, lines):
    """The text rows of a window's art: lines holding letters, each with the marks line
    above it."""
    art = [rom[addr + k * width:addr + (k + 1) * width] for k in range(lines)]
    rows = []
    for k, line in enumerate(art):
        if all(b in (BLANK, DAKU, HANDAKU) or b in FRAME for b in line):
            continue                     # a marks line, a border or a blank line
        above = art[k - 1] if k and all(b in (BLANK, DAKU, HANDAKU) for b in art[k - 1]) \
            else bytes([BLANK]) * width
        row = tile_row(above, line)
        if row:
            rows.append(row)
    return rows


def window_jp(label, rom=None, labels=None):
    """The JP rows of the window whose US art is at `label`, joined with {BR}."""
    rom = rom or _rom()
    labels = labels or asmlist.labels()
    us = asmlist.rom()
    table = labels['WindowArtLayoutPtrs'][1]
    dyn = labels['DynamicWindowsStart'][1]
    a = labels[label][1]
    want = a if a < dyn else 0xFF8000 + (a - dyn)
    for i in range(WINDOW_ENTRIES):
        if int.from_bytes(us[table + 8 * i + 2:table + 8 * i + 6], 'big') == want:
            e = rom[JP_WINDOW_TABLE + 8 * i:JP_WINDOW_TABLE + 8 * i + 8]
            p = int.from_bytes(e[2:6], 'big')
            if p >= 0xFF0000:
                p = JP_DYNAMIC_WINDOWS + (p - 0xFF8000)
            return '{BR}'.join(art_rows(rom, p, e[6] - 1, e[7] + 1))
    return None


def jobs_jp(rom=None):
    rom = rom or _rom()
    return [tile_row(rom[JP_JOBS + 16 * k:JP_JOBS + 16 * k + 8],
                     rom[JP_JOBS + 16 * k + 8:JP_JOBS + 16 * k + 16]) for k in range(8)]


def places_jp(rom=None):
    rom = rom or _rom()
    return [ps2text.decode_jp(rom[JP_PLACES + 5 * k:JP_PLACES + 5 * k + 5]).strip()
            for k in range(10)]


def segment_jp(name, runs, rom=None, labels=None):
    """The JP for each run of segment `name` (None where there is none)."""
    rom = rom or _rom()
    if name == 'windows':
        labels = labels or asmlist.labels()
        return [window_jp(r['label'], rom, labels) for r in runs]
    table = {'jobs': jobs_jp(rom), 'teleport': places_jp(rom),
             'prompts': PROMPTS_JP, 'labels': LABELS_JP}.get(name)
    if table is None:
        return [None] * len(runs)
    return [table[k] if k < len(table) else None for k in range(len(runs))]


def main():
    if hasattr(sys.stdout, 'reconfigure'):
        sys.stdout.reconfigure(encoding='utf-8')
    path = os.path.join(ROOT, 'work', 'script.json')
    raw = open(path, 'rb').read()
    crlf = b'\r\n' in raw
    doc = json.loads(raw.decode('utf-8'))
    rom, labels = _rom(), asmlist.labels()
    changed = 0
    for name in ('teleport', 'prompts', 'jobs', 'labels', 'windows'):
        runs = doc['segments'][name]['runs']
        for r, jp in zip(runs, segment_jp(name, runs, rom, labels)):
            print('%-14s %s' % (r['id'], jp))
            if jp and r.get('jp') != jp:
                r['jp'] = jp
                changed += 1
    if '--apply' in sys.argv:
        # the keys keep the extractor's order: id line label rows kind width (widths cursor) jp us en
        for seg in doc['segments'].values():
            for i, r in enumerate(seg['runs']):
                if 'jp' in r:
                    order = [k for k in r if k not in ('jp', 'us', 'en')] + ['jp', 'us', 'en']
                    seg['runs'][i] = {k: r[k] for k in order if k in r}
        out = (json.dumps(doc, ensure_ascii=False, indent=1) + '\n').encode('utf-8')
        if crlf:
            out = out.replace(b'\n', b'\r\n')
        open(path, 'wb').write(out)
        print('wrote %d jp fields into work/script.json' % changed)


if __name__ == '__main__':
    main()

"""Check every `en` string against its budget - the proofreader's rules, from the shell.

    python tools/linecheck.py [--changed] [--stock] [ids...]

Dialogue (work/dialogue.json):
  * every character must exist in the script charset; unknown {tokens} are errors;
  * a message ends in exactly one end code ({END} {C5} {C6} {C7}), unless it runs on into
    the next entry (`falls_through`), which must hold none;
  * at most 255 bytes when another id follows in the bank (the table step is a byte);
  * a whole message (a fall-through chain) expands to at most 704 bytes in text_buffer;
  * a line holds at most 24 cells (20 in the battle box), inserts counted at their widest
    ({NAME} 4, {ENEMY} 10, {TECH} 5, {ITEM} 10, {MESETA} 6);
  * between two button waits there are no more lines than the window shows (2; 4 in the
    big window; 1 in the battle box), or the first ones scroll away unread;
  * with battle_box the battle box is 24 cells (192 px) and two lines, but the messages
    the game queues into an already open box (LATE_QUEUED) keep to one line.
Tables (work/script.json): every row fits its fixed width and uses only its charset.

--changed checks only entries whose en differs from us; --stock also reports the
stock text's own problems (by default only translated entries are reported).
Exit status 1 when anything is reported.
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import ps2text
import gentext

INSERT_CELLS = {0xBB: 4, 0xBC: 4, 0xBD: 10, 0xBE: 5, 0xBF: 10, 0xC0: 6}
WINDOWS = {'dialogue': (24, 2), 'big': (24, 4), 'battle': (20, 1), 'ending': (18, 7), 'finale': (26, 7)}
# battle_box: the battle box is as wide as the dialogue window, and two lines when its
# message has a {BR} (ext/battlebox.asm) - chosen when the box opens, from the ids queued
# then. The victory rewards and level-ups are queued into the open victory box later, so
# they continue in the one-line box it opened with.
BATTLE_BOX = bool(gentext.OPTIONS.get('battle_box'))
if BATTLE_BOX:
    WINDOWS['battle'] = (24, 2)
LATE_QUEUED = {'1213', '1214', '1215', '1216', '1217'}


def chunks(data):
    """The text between button waits, as lists of lines (lists of bytes / insert codes)."""
    out = [[]]
    line = []
    for b in data:
        if b == 0xC1:
            out[-1].append(line)
            line = []
        elif b == 0xC3 or b >= 0xC4:
            out[-1].append(line)
            line = []
            out.append([])
        elif b == 0xC2:
            if line:
                out[-1].append(line)
            line = []
            out.append([])
        else:
            line.append(b)
    if line:
        out[-1].append(line)
    return [c for c in out if c and any(c)]


def cells(line):
    return sum(INSERT_CELLS.get(b, 1) for b in line)


# ---- the proportional face (vwf_dialogue) ----------------------------------------
VWF = bool(gentext.OPTIONS.get('vwf_dialogue'))
# the windows the proportional renderer draws, in pixels; the final scene keeps cells
# unless vwf_ending: its speeches are 18 cells (144 px, seven lines), its closing line 24
# cells (192 px) and the ring holds five lines
WINDOW_PX = {'dialogue': 192, 'big': 192, 'battle': 192 if BATTLE_BOX else 160}
if VWF and gentext.OPTIONS.get('vwf_ending'):
    WINDOW_PX.update({'ending': 144, 'finale': 192})
    WINDOWS['finale'] = (24, 5)
PLATE_PX = 32                # long_names: a party name is drawn in four cells
_WIDTH = None


def widths():
    global _WIDTH
    if _WIDTH is None:
        _WIDTH = open(os.path.join(ROOT, 'PSII_Disasm', 'vwf', 'diawidth.bin'), 'rb').read()
    return _WIDTH


def text_px(text):
    return sum(widths()[ps2text.US_ENCODE[ch]] for ch in text if ch in ps2text.US_ENCODE)


def insert_px(script=None):
    """The widest each insert can be: the widest translated name of its table (and a
    widest name a player can type); a meseta amount is six digits."""
    if script is None:
        script = json.load(open(os.path.join(ROOT, 'work', 'script.json'), encoding='utf-8'))
    segs = script['segments']

    def widest(seg):
        return max(text_px(r['en']) for r in segs[seg]['runs'])
    digit = max(text_px(str(d)) for d in range(10))
    # a typed name: four capitals, or with long_names six letters, the first a capital
    typed = text_px('Wwwwww') if gentext.OPTIONS.get('long_names') else 4 * text_px('W')
    name = max(widest('charnames'), typed)
    return {0xBB: name, 0xBC: name, 0xBD: widest('enemies'), 0xBE: widest('techs'),
            0xBF: widest('items'), 0xC0: 6 * digit}


_INSERT_PX = None


def line_px(line):
    global _INSERT_PX
    if _INSERT_PX is None:
        _INSERT_PX = insert_px()
    w = widths()
    return sum(_INSERT_PX[b] if b in _INSERT_PX else w[b] for b in line)


def measure(line, window):
    """(used, limit, unit) of one line in its window."""
    if VWF and window in WINDOW_PX:
        return line_px(line), WINDOW_PX[window], 'px'
    return cells(line), WINDOWS[window][0], 'cells'


def dialogue_problems(doc):
    entries = doc['entries']
    probs = {}
    chain = []
    for n, e in enumerate(entries):
        p = []
        try:
            data = ps2text.encode_us(e['en'])
        except ValueError as ex:
            probs[e['id']] = [str(ex)]
            chain = []
            continue
        ends = [i for i, b in enumerate(data) if b >= 0xC4]
        if e.get('falls_through'):
            if ends:
                p.append('runs on into the next entry: must not contain an end code')
        elif ends != [len(data) - 1]:
            p.append('must end in exactly one end code')
        last_in_bank = n + 1 == len(entries) or entries[n + 1]['bank'] != e['bank']
        size = len(data) + len(e.get('tail', '')) // 2
        if gentext.MSG_MAX and not last_in_bank and size > gentext.MSG_MAX:
            p.append('%d bytes: a message is at most %d' % (size, gentext.MSG_MAX))
        window = e.get('window_override') or e['window']
        rows = WINDOWS[window][1]
        if BATTLE_BOX and LATE_QUEUED & set(e['ids']) and 0xC1 in data:
            p.append('queued into the open victory box: one line only (no {BR})')
        for c in chunks(data):
            for line in c:
                used, limit, unit = measure(line, window)
                if used > limit:
                    p.append('a line of %d %s: the window has %d' % (used, unit, limit))
                    break
        chain.append((e, data))
        if not e.get('falls_through'):
            whole = b''.join(d for _, d in chain)
            first = chain[0][0]
            for c in chunks(whole):
                if len(c) > rows:
                    probs.setdefault(first['id'], []).append(
                        '%d lines between two waits: the window shows %d' % (len(c), rows))
                    break
            exp = gentext.expanded_size(whole)
            if exp > gentext.BUFFER_MAX:
                probs.setdefault(first['id'], []).append(
                    'expands to %d bytes in text_buffer (at most %d)' % (exp, gentext.BUFFER_MAX))
            chain = []
        if p:
            probs.setdefault(e['id'], []).extend(p)
    return probs


def window_row_problems(text, us, width, field):
    """vwf_windows: one row of a window drawn from art. Each label is drawn proportionally
    in its cells (gentext.label_runs: up to the next word, the row's end or the field the
    game writes); before a field it keeps FIELD_GAP_PX. The number placeholders come from
    the stock row (gentext.window_row): the game writes numbers right-aligned into fixed
    cells, so a translation need not carry them."""
    runs, art, p = gentext.window_row(text, us, width, field)
    for col, cells, label in runs:
        lim = 8 * cells
        if field is not None and col + cells == field:
            lim -= gentext.FIELD_GAP_PX
        if text_px(label) > lim:
            p.append('%r is %d px: its cells hold %d' % (label, text_px(label), lim))
    return p


def table_problems(doc):
    probs = {}
    for name, seg in doc['segments'].items():
        tile = seg['charset'] == 'tile'
        enc = gentext.TILE_ENCODE if tile else ps2text.US_ENCODE
        for r in seg['runs']:
            p = []
            texts = r['en'].split('{BR}') if r['kind'] == 'window' else [r['en']]
            widths = r.get('widths', [r['width']])
            if len(texts) > len(r['rows']):
                p.append('%d rows: the window has %d' % (len(texts), len(r['rows'])))
            for k, t in enumerate(texts):
                bad = [ch for ch in t if ch not in enc]
                if bad:
                    p.append('no glyph for %r' % bad[0])
                w = widths[min(k, len(widths) - 1)]
                if name == 'windows' and gentext.OPTIONS.get('vwf_windows') \
                        and r['label'] not in gentext.WT_EXCLUDE:
                    us = (r['us'].split('{BR}') + [''] * len(texts))[k]
                    field = gentext.WINDOW_FIELDS.get(r['label'], [None] * 64)[k]
                    if r['label'] == 'WinArt_PlayerMenu' and gentext.OPTIONS.get('party_menu_ps4'):
                        w = r.get('pm_width', w)        # PM_MenuArt's wider label cells
                    p.extend(window_row_problems(t, us, w, field))
                elif seg.get('static_art'):
                    if text_px(t) > 8 * w:             # one label in its cells
                        p.append('%r is %d px: its cells hold %d' % (t, text_px(t), 8 * w))
                elif name == 'prompts' and r['label'] == 'loc_1142A' \
                        and gentext.OPTIONS.get('vwf_windows'):
                    if text_px(' ' + t) > 48:
                        p.append('%r is %d px: the target prompt holds 48' %
                                 (t, text_px(' ' + t)))
                elif gentext.LONG_ITEM_NAMES and name in gentext.LONG_NAME_PX:
                    # long_item_names: any length, held to the pixels of the stock cells
                    lim = gentext.LONG_NAME_PX[name]
                    if text_px(t) > lim:
                        p.append('%r is %d px: the name has %d' % (t, text_px(t), lim))
                elif len(t) > w:
                    p.append('%r is %d cells: the field holds %d' % (t, len(t), w))
                if name == 'charnames' and gentext.OPTIONS.get('long_names') and text_px(t) > PLATE_PX:
                    p.append('%r is %d px: a name plate holds %d' % (t, text_px(t), PLATE_PX))
            if p:
                probs[r['id']] = p
    return probs


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    changed = '--changed' in sys.argv
    stock = '--stock' in sys.argv
    dia = json.load(open(os.path.join(ROOT, 'work', 'dialogue.json'), encoding='utf-8'))
    scr = json.load(open(os.path.join(ROOT, 'work', 'script.json'), encoding='utf-8'))
    en_of = {e['id']: e for e in dia['entries']}
    for seg in scr['segments'].values():
        for r in seg['runs']:
            en_of[r['id']] = r
    probs = dialogue_problems(dia)
    probs.update(table_problems(scr))
    n = 0
    for rid, ps in probs.items():
        e = en_of[rid]
        untouched = e['en'] == e['us']
        if untouched and not stock:
            continue
        if changed and untouched:
            continue
        if args and rid not in args and not any(i in args for i in e.get('ids', [])):
            continue
        for p in ps:
            print('%-14s %s' % (rid, p))
            n += 1
    total = len(dia['entries']) + sum(len(s['runs']) for s in scr['segments'].values())
    done = sum(1 for e in en_of.values() if e['en'] != e['us'])
    print('%d problems; %d of %d entries translated' % (n, done, total))
    sys.exit(1 if n else 0)


if __name__ == '__main__':
    main()

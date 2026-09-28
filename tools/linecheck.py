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
    big window; 1 in the battle box), or the first ones scroll away unread.
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
        if not last_in_bank and size > gentext.MSG_MAX:
            p.append('%d bytes: a message is at most %d' % (size, gentext.MSG_MAX))
        w, rows = WINDOWS[e.get('window_override') or e['window']]
        for c in chunks(data):
            for line in c:
                if cells(line) > w:
                    p.append('a line of %d cells: the window has %d' % (cells(line), w))
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
                if len(t) > w:
                    p.append('%r is %d cells: the field holds %d' % (t, len(t), w))
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

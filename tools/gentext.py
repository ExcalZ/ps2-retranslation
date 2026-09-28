"""Write work/dialogue.json into PSII_Disasm/text/script.asm and work/script.json into
PSII_Disasm/ps2.asm.

    python tools/gentext.py [--check] [--all] [--dialogue=PATH] [--script=PATH]

Dialogue: every entry is the block of `dc.b` lines after its label; the block is
regenerated from `en` (plus the dead `tail` bytes the stock ROM has after some end codes).
Tables: every run is one or more string lines of its segment, found by ordinal
(`rows`); each is rewritten with `en`, padded to its fixed width.

Only entries whose `en` differs from the text the source currently holds are rewritten
(--all regenerates everything), so the disassembly's own comments survive on untouched
blocks. With every `en` equal to `us` the ROM is the stock one.

--check reports what would change and every budget problem, and writes nothing.
Exit status 1 if an entry cannot be encoded or does not fit its hard limits.
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import ps2text

ASM = os.path.join(ROOT, 'PSII_Disasm', 'ps2.asm')
SCRIPT_ASM = os.path.join(ROOT, 'PSII_Disasm', 'text', 'script.asm')
DIALOGUE = os.path.join(ROOT, 'work', 'dialogue.json')
SCRIPT = os.path.join(ROOT, 'work', 'script.json')

def options():
    """The flags of PSII_Disasm/ps2.options.asm as {name: int}."""
    out = {}
    for line in open(os.path.join(ROOT, 'PSII_Disasm', 'ps2.options.asm'), encoding='latin-1'):
        m = re.match(r'^(\w+)\s*=\s*(\d+)', line)
        if m:
            out[m.group(1)] = int(m.group(2))
    return out


OPTIONS = options()
# a stock table step is one byte: a message block is at most 255 bytes (long_script_offsets
# stores a pointer per message instead)
MSG_MAX = None if OPTIONS.get('long_script_offsets') else 255
# text_buffer .. sound_ram; paged_text_buffer expands a page at a time and keeps its resume
# state in the buffer's last eight bytes
PAGED = bool(OPTIONS.get('paged_text_buffer'))
BUFFER_MAX = 0x2B8 if PAGED else 0xD000 - 0xCD40
INSERT_BYTES = {0xBB: 4, 0xBC: 4, 0xBD: 10, 0xBE: 5, 0xBF: 10, 0xC0: 6}

# ---- string emission --------------------------------------------------------
SCRIPT_SAFE = set('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 ,.;?!\'-:')
TILE_ENCODE = {' ': 0x26, ',': 0x5B, '.': 0x5C, ';': 0x5D, '"': 0x5E, '?': 0x5F, '!': 0x60,
               "'": 0x61, '-': 0x62, '/': 0x64, ':': 0x80}
for _i in range(26):
    TILE_ENCODE[chr(65 + _i)] = 0x27 + _i
    TILE_ENCODE[chr(97 + _i)] = 0x41 + _i
for _i in range(10):
    TILE_ENCODE[chr(48 + _i)] = 0x76 + _i
TILE_SAFE = set(TILE_ENCODE) - {'"'}


def dcb_operands(data, safe, decode):
    """Bytes -> dc.b operand list: printable runs as strings, the rest as $XX."""
    ops = []
    run = ''
    for b in data:
        ch = decode.get(b)
        if ch is not None and ch in safe:
            run += ch
        else:
            if run:
                ops.append('"%s"' % run)
                run = ''
            ops.append('$%02X' % b)
    if run:
        ops.append('"%s"' % run)
    return ops


def dialogue_lines(data):
    """The generated block for one message: text runs and control bytes, one per line,
    in the style of the disassembly."""
    out = []
    cur = bytearray()

    def flush():
        if cur:
            ops = dcb_operands(bytes(cur), SCRIPT_SAFE, ps2text.US_DECODE)
            for k in range(0, len(ops), 16):
                out.append('\tdc.b\t' + ', '.join(ops[k:k + 16]))
            cur.clear()
    for b in data:
        if b in ps2text.CONTROLS or b >= 0xC4:
            flush()
            out.append('\tdc.b\t$%02X' % b)
        else:
            cur.append(b)
    flush()
    return out


def expanded_size(data):
    """Bytes LoadScript writes into text_buffer for this message: all of it (stock), or its
    largest page (paged_text_buffer: a page after a wait starts with two line feeds)."""
    n = best = 0
    for b in data:
        if b in INSERT_BYTES:
            n += INSERT_BYTES[b]
        elif b == 0xC1:
            n += 2
        elif b == 0xC3:
            if PAGED:
                best = max(best, n + 1)
                n = 2
                continue
            n += 3
        else:
            n += 1
        if b >= 0xC4:
            break
    return max(best, n)


# ---- dialogue ------------------------------------------------------------------
_LABELDEF = re.compile(r'^([A-Za-z_]\w*):')
_OPERAND = re.compile(r'\s*("(?:[^"]*)"|\$[0-9A-Fa-f]+|\d+)\s*(?:,|$)')


def block_bytes(lines):
    """The bytes a block of `dc.b` lines assembles to under the script charset, or None
    when a line holds anything but strings and numbers (then it is regenerated)."""
    out = bytearray()
    for line in lines:
        code = re.sub(r'^((?:[^;"]|"[^"]*")*);.*$', r'\1', line).strip()   # a ; outside quotes
        code = code.replace('\\I', '\x01')           # the source's escape for " (a placeholder here)
        if not code:
            continue
        m = re.match(r'dc\.b\s+(.*)$', code)
        if not m:
            return None
        rest = m.group(1)
        pos = 0
        while pos < len(rest):
            o = _OPERAND.match(rest, pos)
            if not o:
                return None
            tok = o.group(1)
            if tok.startswith('"'):
                for ch in tok[1:-1].replace('\x01', '"'):
                    if ch not in ps2text.US_ENCODE:
                        return None
                    out.append(ps2text.US_ENCODE[ch])
            else:
                out.append(int(tok[1:], 16) if tok.startswith('$') else int(tok))
            pos = o.end()
    return bytes(out)


def apply_dialogue(src, doc, force, problems, log):
    labels = {}
    for i, line in enumerate(src):
        m = _LABELDEF.match(line)
        if m:
            labels[m.group(1)] = i
    label_lines = sorted(labels.values())
    changed = 0
    entries = doc['entries']
    for n, e in enumerate(entries):
        last_in_bank = n + 1 == len(entries) or entries[n + 1]['bank'] != e['bank']
        try:
            data = ps2text.encode_us(e['en'])
        except ValueError as ex:
            problems.append('%s: %s' % (e['id'], ex))
            continue
        if not data or data[-1] < 0xC4 and not e.get('falls_through'):
            problems.append('%s: must end in an end code ({END}, {C5}, {C6}, {C7})' % e['id'])
            continue
        if any(b >= 0xC4 for b in data[:-1]):
            problems.append('%s: end code before the end of the message' % e['id'])
            continue
        if e.get('falls_through') and data[-1] >= 0xC4:
            problems.append('%s: falls through into the next entry: must not end in an end code' % e['id'])
        tail = bytes.fromhex(e.get('tail', ''))
        if MSG_MAX and len(data) + len(tail) > MSG_MAX and not last_in_bank and e['en'] != e['us']:
            problems.append('%s: %d bytes, a message is at most %d' % (e['id'], len(data) + len(tail), MSG_MAX))
        i = labels[e['id']]
        nxt = next((l for l in label_lines if l > i), len(src))
        nxt = min(nxt, next(k for k in range(i, len(src)) if src[k].strip() == 'charset'))
        j = max(k for k in range(i + 1, nxt) if re.match(r'^\s*dc\.b', src[k]))
        if not force and block_bytes(src[i + 1:j + 1]) == data + tail:
            continue            # the source already holds this text (in its own layout)
        new = dialogue_lines(data)
        if tail:
            new.append('; unused bytes of the stock ROM')
            for k in range(0, len(tail), 16):
                new.append('\tdc.b\t' + ', '.join('$%02X' % b for b in tail[k:k + 16]))
        if src[i + 1:j + 1] != new:
            src[i + 1:j + 1] = new
            delta = len(new) - (j - i)
            for k, v in labels.items():
                if v > i:
                    labels[k] = v + delta
            label_lines = sorted(labels.values())
            changed += 1
    # the RAM text buffer holds a whole chain of fall-through blocks
    chain = bytearray()
    first = None
    touched = False
    for e in doc['entries']:
        try:
            data = ps2text.encode_us(e['en'])
        except ValueError:
            continue
        if first is None:
            first = e['id']
        chain += data
        touched |= e['en'] != e['us']
        if not e.get('falls_through'):
            size = expanded_size(bytes(chain))
            if size > BUFFER_MAX:
                msg = '%s: the message expands to %d bytes in text_buffer (at most %d)' % (first, size, BUFFER_MAX)
                if touched:
                    problems.append(msg)
                else:
                    log.append('stock overflow kept: ' + msg)
            chain = bytearray()
            first = None
            touched = False
    log.append('dialogue: %d blocks rewritten' % changed)


# ---- tables --------------------------------------------------------------------
_STR = re.compile(r'^(\s*)(nametxt|soundtracktxt|dc\.b|cursorbox)(\s+)(".*?")(\s*;.*|\s*)$')


def table_string(text, width, charset, kind, rid, problems):
    """en text -> the operand list for one row, padded to its width."""
    if charset == 'tile':
        enc, safe, dec = TILE_ENCODE, TILE_SAFE, {v: k for k, v in TILE_ENCODE.items()}
    else:
        enc, safe, dec = ps2text.US_ENCODE, SCRIPT_SAFE, ps2text.US_DECODE
    for ch in text:
        if ch not in enc:
            problems.append('%s: no glyph for %r' % (rid, ch))
            return None
    if len(text) > width:
        problems.append('%s: %r is %d cells, the field holds %d' % (rid, text, len(text), width))
        return None
    if kind in ('nametxt', 'soundtracktxt'):
        if any(ch not in safe for ch in text):
            problems.append('%s: %r: names can only use letters, digits and , . ; ? ! \' - :' % (rid, text))
            return None
        return '"%s"' % text
    # one string literal, so the row keeps matching _STR and the ordinals stay put;
    # \I is the source's escape for the double quote
    return '"%s"' % text.ljust(width).replace('"', '\\I')


def apply_tables(src, doc, force, problems, log):
    changed = 0
    for name, seg in doc['segments'].items():
        start = next(i for i, l in enumerate(src) if l.startswith(seg['start'] + ':'))
        if seg['end']:
            end = next(i for i in range(start, len(src)) if src[i].startswith(seg['end'] + ':'))
        else:
            end = next(i for i in range(start, len(src)) if src[i].strip() == 'charset')
        string_lines = [i for i in range(start, end) if _STR.match(src[i])]
        for r in seg['runs']:
            if not force and r['en'] == r['us']:
                continue
            texts = r['en'].split('{BR}') if r['kind'] == 'window' else [r['en']]
            if len(texts) > len(r['rows']):
                problems.append('%s: %d rows, the window has %d' % (r['id'], len(texts), len(r['rows'])))
                continue
            texts += [''] * (len(r['rows']) - len(texts))
            widths = r.get('widths', [r['width']] * len(r['rows']))
            cursors = r.get('cursor', [False] * len(r['rows']))
            for o, text, w, cur in zip(r['rows'], texts, widths, cursors):
                i = string_lines[o]
                m = _STR.match(src[i])
                kind = m.group(2)
                ops = table_string(text, w, seg['charset'], kind, r['id'], problems)
                if ops is None:
                    continue
                new = m.group(1) + kind + m.group(3) + ops + (m.group(5) or '').rstrip()
                if kind in ('nametxt', 'soundtracktxt') and not ops.startswith('"'):
                    problems.append('%s: bad name operand' % r['id'])
                    continue
                if src[i] != new:
                    src[i] = new
                    changed += 1
    log.append('tables: %d lines rewritten' % changed)


def main():
    check = '--check' in sys.argv
    force = '--all' in sys.argv
    problems = []
    log = []
    opts = dict(a[2:].split('=', 1) for a in sys.argv[1:] if '=' in a)
    jobs = [(SCRIPT_ASM, apply_dialogue, opts.get('dialogue', DIALOGUE)),
            (ASM, apply_tables, opts.get('script', SCRIPT))]
    results = []
    for path, apply, doc in jobs:
        raw = open(path, 'rb').read()
        crlf = b'\r\n' in raw
        src = raw.decode('latin-1').replace('\r\n', '\n').split('\n')
        before = list(src)
        apply(src, json.load(open(doc, encoding='utf-8')), force, problems, log)
        results.append((path, crlf, src, before))
    for p in problems:
        print('PROBLEM', p)
    print('; '.join(log))
    if problems:
        print('%d problems' % len(problems))
    for path, crlf, src, before in results:
        if not check and src != before:
            text = '\n'.join(src)
            if crlf:
                text = text.replace('\n', '\r\n')
            open(path, 'wb').write(text.encode('latin-1'))
            print('wrote', os.path.relpath(path, ROOT))
    sys.exit(1 if problems else 0)


if __name__ == '__main__':
    main()

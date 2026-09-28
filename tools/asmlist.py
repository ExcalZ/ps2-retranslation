"""Read the assembler listing (PSII_Disasm/ps2.lst).

    labels()      -> {name: (line, addr)}   the line is in the label's own file
    line_addrs()  -> {line: addr} for ps2.asm; line_addrs(SCRIPT) for text/script.asm

Lines of an included file are listed as `(1)  line/ addr :`, numbered in that file.
"""
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DISASM = os.path.join(ROOT, 'PSII_Disasm')
LISTING = os.path.join(DISASM, 'ps2.lst')
MAIN = 'ps2.asm'
SCRIPT = 'text/script.asm'
_LINE = re.compile(r'^(?:\((\d+)\))?\s*(\d+)/\s*([0-9A-F]+) :(.*)$')
_LABEL = re.compile(r'^([A-Za-z_]\w*):')


def _walk(path):
    """Yields (file, line, addr, source text) for every listed line; `file` is MAIN, SCRIPT
    or None (the other includes)."""
    cur_include = None
    with open(path or LISTING, encoding='latin-1') as f:
        for raw in f:
            m = _LINE.match(raw)
            if not m:
                continue
            level, line, addr, rest = m.group(1), int(m.group(2)), int(m.group(3), 16), m.group(4)
            text = rest[21:] if len(rest) > 21 else ''
            if level is None:
                cur_include = SCRIPT if re.search(r'\binclude\s+"text/script\.asm"', text) else None
                yield MAIN, line, addr, text
            else:
                yield (SCRIPT if cur_include == SCRIPT and level == '1' else None), line, addr, text


def labels(path=None):
    out = {}
    for file, line, addr, text in _walk(path):
        m = _LABEL.match(text)
        if m and file and m.group(1) not in out:
            out[m.group(1)] = (line, addr)
    return out


def line_addrs(which=MAIN, path=None):
    """source line -> address in `which` (first occurrence; macro expansions repeat lines)."""
    out = {}
    for file, line, addr, text in _walk(path):
        if file == which and line not in out:
            out[line] = addr
    return out


def rom(path=None):
    return open(path or os.path.join(DISASM, 'ps2original.bin'), 'rb').read()

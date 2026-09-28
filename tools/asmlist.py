"""Read the assembler listing (PSII_Disasm/ps2.lst): label -> (source line, address).

    labels() -> {name: (line, addr)}
"""
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DISASM = os.path.join(ROOT, 'PSII_Disasm')
_LABEL = re.compile(r'^\s*(\d+)/\s*([0-9A-F]+) :\s+([A-Za-z_][\w]*):')


def labels(path=None):
    path = path or os.path.join(DISASM, 'ps2.lst')
    out = {}
    with open(path, encoding='latin-1') as f:
        for line in f:
            m = _LABEL.match(line)
            if m and m.group(3) not in out:
                out[m.group(3)] = (int(m.group(1)), int(m.group(2), 16))
    return out


def rom(path=None):
    return open(path or os.path.join(DISASM, 'ps2original.bin'), 'rb').read()


_LINE = re.compile(r'^\s*(\d+)/\s*([0-9A-F]+) :')


def line_addrs(path=None):
    """source line -> address, for every line of ps2.asm the listing shows (first occurrence;
    macro expansions repeat the line number)."""
    path = path or os.path.join(DISASM, 'ps2.lst')
    out = {}
    with open(path, encoding='latin-1') as f:
        for line in f:
            m = _LINE.match(line)
            if m:
                n = int(m.group(1))
                if n not in out:
                    out[n] = int(m.group(2), 16)
    return out

"""Generate the proportional dialogue face for the PS2 text engine (ext/vwf.asm).

    python tools/diafont.py

Emits into PSII_Disasm/vwf/:
    diafont.bin    256 glyphs x 8 bytes, 1bpp rows (bit 7 = left), indexed by the script
                   byte (tools/ps2text.py: 0 space, 1-10 digits, 11-36 A-Z, 37-62 a-z,
                   $3F-$47 , . ; " ? ! ' - and the ellipsis, $77 :)
    diawidth.bin   256 bytes, advance in pixels (ink + 1 px gap; space 3)
    expand.bin     256 longwords: a 1bpp row to 4bpp (ink colour 1, paper $B)

The glyphs are the PS III/IV retranslations' mixed-case face (tools/vwfmixed.py): capitals
on rows 0-6, x-height 5, baseline row 6 - the row the stock 8x8 letters sit on. Bytes
with no glyph keep advance 8 and a blank glyph, so a stray byte still takes a cell.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import ps2text
import vwfmixed

GAP = 1
SPACE = 3
OUT = os.path.join(ROOT, 'PSII_Disasm', 'vwf')

vwfmixed._g('…', 6, '#.#.#')      # the ellipsis tile ($47): three dots on the baseline


def glyph_rows(ch):
    g = vwfmixed.G.get(ch)
    if g is None:
        return None
    top, rows = g
    out = [0] * 8
    for dy, r in enumerate(rows):
        b = 0
        for dx, p in enumerate(r):
            if p == '#':
                b |= 1 << (7 - dx)
        out[top + dy] = b
    return out, max(len(r) for r in rows)


def build():
    font = bytearray(256 * 8)
    width = bytearray([8] * 256)
    missing = []
    for b, ch in sorted(ps2text.US_DECODE.items()):
        if ch == ' ':
            width[b] = SPACE
            continue
        g = glyph_rows(ch)
        if g is None:
            missing.append(ch)
            continue
        rows, iw = g
        font[b * 8:b * 8 + 8] = bytes(rows)
        width[b] = iw + GAP
    return bytes(font), bytes(width), missing


def main():
    font, width, missing = build()
    os.makedirs(OUT, exist_ok=True)
    open(os.path.join(OUT, 'diafont.bin'), 'wb').write(font)
    open(os.path.join(OUT, 'diawidth.bin'), 'wb').write(width)
    # the engine's 1bpp -> 4bpp table: 256 longwords, ink colour 1 and paper $B per pixel
    lut = bytearray()
    for b in range(256):
        v = 0
        for bit in range(8):
            v = (v << 4) | (1 if b & (0x80 >> bit) else 0xB)
        lut += v.to_bytes(4, 'big')
    open(os.path.join(OUT, 'expand.bin'), 'wb').write(bytes(lut))
    print('wrote PSII_Disasm/vwf/diafont.bin, diawidth.bin; no glyph for: %r' % ''.join(missing))


if __name__ == '__main__':
    main()

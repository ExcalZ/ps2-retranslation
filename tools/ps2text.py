"""Text codecs for Phantasy Star II (US and JP script bytes <-> readable strings).

Every text byte indexes VDPCharacterMaps: a pair (top tile, bottom tile) drawn one above
the other, tiles counted from VRAM $A000 (the font, FontsIconsArt). The JP puts the
dakuten / handakuten in the top tile; the US uses a blank top tile for every letter.

Control bytes (LoadScript / RunScript):
    $BB {NAME}   the current character's name       $BC {NAME2}  the second character's name
    $BD {ENEMY}  enemy name                          $BE {TECH}   technique name
    $BF {ITEM}   item name                           $C0 {MESETA} the meseta amount
    $C1 {BR}     next line                           $C2 {CLR}    clear the window
    $C3 {PAGE}   wait for a button, scroll a line    $C4 {END}    end of message (and more)
    $C5.. are end codes too: the value is returned to the caller (yes/no prompts etc.)
Bytes with no printable meaning are written {XX}.
"""
import os
import re
import sys

# the tools print Japanese; the Windows console defaults to a code page without kana
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)

CONTROLS = {
    0xBB: 'NAME', 0xBC: 'NAME2', 0xBD: 'ENEMY', 0xBE: 'TECH', 0xBF: 'ITEM',
    0xC0: 'MESETA', 0xC1: 'BR', 0xC2: 'CLR', 0xC3: 'PAGE', 0xC4: 'END',
}
CONTROL_CODES = {v: k for k, v in CONTROLS.items()}

# ---- US: the charset of ps2.asm (script section) --------------------------
US_DECODE = {0: ' '}
for i, c in enumerate('0123456789'):
    US_DECODE[1 + i] = c
for i in range(26):
    US_DECODE[11 + i] = chr(ord('A') + i)
    US_DECODE[37 + i] = chr(ord('a') + i)
US_DECODE.update({0x3F: ',', 0x40: '.', 0x41: ';', 0x42: '"', 0x43: '?', 0x44: '!',
                  0x45: "'", 0x46: '-', 0x47: '…', 0x77: ':'})
US_ENCODE = {v: k for k, v in US_DECODE.items()}

# ---- JP: font tile index (from $A000) -> glyph ---------------------------
_JP_TILES = {}


def _row(start, chars):
    for i, c in enumerate(chars):
        if c != '_':
            _JP_TILES[start + i] = c


_row(0x26, ' あいうえおかきくけ')     # sp a i u e o ka ki ku ke
_row(0x30, 'こさしすせそたちつてとなにぬねの')
_row(0x40, 'はひふへほまみむめもやゆよらりる')
_row(0x50, 'れろ!?わをんっゃゅょ__、。ア')
_row(0x60, 'イウエオカキクケコサシスセソタチ')
_row(0x70, 'ツテトナニヌネノハヒフ・ホマミム')
_row(0x80, 'メモヤユヨラリルレロワヲンァィ_')
_row(0x90, 'ェォッャュョー012345678')
_row(0xA0, '9ADEHLMNOPSTVWXY')
_row(0xB0, '「」/▼')
_row(0x10, 'BC')
DAKUTEN_TILE = 0x5B
HANDAKUTEN_TILE = 0x5C
BLANK_TILE = 0x26

_DAKU = dict(zip('かきくけこさしすせそたちつてとはひふへほカキクケコサシスセソタチツテトハヒフヘホウ',
                 'がぎぐげござじずぜぞだぢづでどばびぶべぼガギグゲゴザジズゼゾダヂヅデドバビブベボヴ'))
_HANDAKU = dict(zip('はひふへほハヒフヘホ', 'ぱぴぷぺぽパピプペポ'))


def _load_jp_map():
    rom = open(os.path.join(ROOT, 'work', 'ps2jp_stock.bin'), 'rb').read()
    base = 0x129C8          # VDPCharacterMaps in the JP ROM
    dec = {}
    for code in range(0xBB):
        top, bot = rom[base + 2 * code], rom[base + 2 * code + 1]
        ch = _JP_TILES.get(bot)
        if ch is None:
            continue
        if top == DAKUTEN_TILE:
            ch = _DAKU.get(ch, ch + '゛')
        elif top == HANDAKUTEN_TILE:
            ch = _HANDAKU.get(ch, ch + '゜')
        elif top != BLANK_TILE:
            continue
        dec[code] = ch
    return dec


_jp_decode = None


def jp_decode_table():
    global _jp_decode
    if _jp_decode is None:
        _jp_decode = _load_jp_map()
    return _jp_decode


def decode(data, table):
    out = []
    for b in data:
        if b in CONTROLS:
            out.append('{%s}' % CONTROLS[b])
        elif b in table:
            out.append(table[b])
        else:
            out.append('{%02X}' % b)
    return ''.join(out)


def decode_us(data):
    return decode(data, US_DECODE)


def decode_jp(data):
    return decode(data, jp_decode_table())


_TOKEN = re.compile(r'\{([A-Z0-9]+)\}')


def encode_us(text):
    out = bytearray()
    i = 0
    while i < len(text):
        m = _TOKEN.match(text, i)
        if m:
            tok = m.group(1)
            if tok in CONTROL_CODES:
                out.append(CONTROL_CODES[tok])
            elif re.fullmatch(r'[0-9A-F]{2}', tok):
                out.append(int(tok, 16))
            else:
                raise ValueError('unknown token {%s}' % tok)
            i = m.end()
            continue
        c = text[i]
        if c not in US_ENCODE:
            raise ValueError('no glyph for %r in %r' % (c, text))
        out.append(US_ENCODE[c])
        i += 1
    return bytes(out)

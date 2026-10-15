"""Bounded check: while a status screen's portrait holds palette line 1 every
field sprite but the window cursors is hidden (PM_HideSprites: Nei's sprite
is in line 1 too, so the whole party goes, not Nei alone), and all of them are
back once it closes. Dumps the sprite table on the field, with Nei's status
screen up and after; shots in work/analysis/statussprites/.

    python work/scripts/statussprites.py [rom]
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu
from ps2emu import PS2

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
out = os.path.join(ps2emu.ANALYSIS, 'statussprites')
SPRITE_TABLE = 0xFFFFF800
LINK_COUNT = 0xFFFFF62C


def depth(em, expected):
    for _ in range(100):
        if em.word(ps2emu.WINDOW_DEPTH) == expected:
            return
        em.frames(2)
    raise RuntimeError('expected %d windows, got %d' %
                       (expected, em.word(ps2emu.WINDOW_DEPTH)))


def sprites(em):
    n = em.byte(LINK_COUNT) + 1
    table = em.read(SPRITE_TABLE, 8 * min(n, 80))
    rows = []
    for i in range(0, len(table), 8):
        y, size, tile, x = (int.from_bytes(table[i + j:i + j + 2], 'big') for j in (0, 2, 4, 6))
        rows.append((y, size, tile, x))
    return rows


def visible(rows):
    """The sprites on screen (Y 0 is the hidden place), less the cursors."""
    return sorted((x, tile & 0x7FF) for y, size, tile, x in rows
                  if y and not 0x5B6 <= tile & 0x7FF < 0x5C0)


def show(label, rows):
    print(label)
    for i, (y, size, tile, x) in enumerate(rows):
        print('  %2d  y %4d  x %4d  tile %03X  pal %d  size %02X' %
              (i, y, x, tile & 0x7FF, (tile >> 13) & 3, size >> 8))


with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    em.frames(10)
    field = sprites(em)
    show('field', field)
    em.shot(os.path.join(out, 'field.png'))
    em.press('C', hold=2, release=70)
    depth(em, 3)
    ps2emu.pick(em, 2)            # Status
    ps2emu.pick(em, 0)            # Status
    ps2emu.pick(em, 1)            # Nei
    depth(em, 10)
    em.frames(10)
    status = sprites(em)
    show('Nei status', status)
    em.shot(os.path.join(out, 'stats_nei.png'))
    ps2emu.close_windows(em)
    depth(em, 0)
    em.frames(10)
    after = sprites(em)
    show('after', after)
    em.shot(os.path.join(out, 'after.png'))
    if visible(status):
        raise RuntimeError('sprites left on the status screen: %s' % visible(status))
    party = [s for s in visible(field) if s[1] in (0x300, 0x308)]
    if len(party) != 2:
        raise RuntimeError('Rolf and Nei are not both on the field: %s' % visible(field))
    if len([s for s in visible(after) if s[1] in (0x300, 0x308)]) != 2:
        raise RuntimeError('the party did not come back: %s' % visible(after))
    print('status screen: every sprite hidden; the party back after it closes')

"""Bounded worst case for the Equip screen's VWF tiles: every item name is
made to fill its whole ten-cell field (a copy of the ROM whose item-name
pointers all lead to one 84-px string), Nei holds sixteen equippable items
(both list pages) with all five slots worn, the party is full, and items are
equipped from both pages - a hand through Right/Left, a head, a body - so
the equipment window and the lists are redrawn in place at their widest.
Fails if any run finds no tiles (WT_OVERFLOW) or the equipment window's
redraw leaves its stacked range; prints the pool's headroom at the deepest
stack. Shots in work/analysis/equipstress/.

    python work/scripts/equipstress.py [rom]
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu
import ps2text
from ps2emu import PS2

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
out = os.path.join(ps2emu.ANALYSIS, 'equipstress')
NEI = 0xFFFFC040
WT_END = 0xFFFF8D80
WT_HUD = 0xFFFF8F80
WT_HUD_BUMP = 0xFFFF8E34
WT_HUD_SCREEN = 0xFFFF8E36
WT_OVERFLOW = 0xFFFF8E30
EQUIP_ID = 0x19
POOL_LEVEL = 415                # WT_PoolLevel with field_heal_popups

# Worn: Jewel Ribbon, Ceramic Claw, Sincerity Sleeves, Prisoner Clothes,
# Knife Boots; the inventory lists them (E) among eleven more she can equip.
WORN = [0x1F, 0x60, 0x51, 0x7B, 0x42]
INVENTORY = [0x9F, 0x1A, 0xE0, 0x50, 0xD1, 0x63, 0xFB, 0x2C,
             0xC2, 0x21, 0x28, 0x5D, 0x59, 0x38, 0x44, 0x40]


def wide_rom(src):
    """The ROM with every item name 14 W's (84 px: ink in all ten cells)."""
    image = bytearray(open(src, 'rb').read())
    table = ps2emu.listing_address('LN_Items')
    end = len(image)
    while image[end - 1] == 0xFF:
        end -= 1
    text = (end + 0x100) & ~0xFF
    image[text:text + 15] = bytes([ps2text.US_ENCODE['W']] * 14 + [0xC4])
    for i in range(128):
        image[table + 4 * i:table + 4 * i + 4] = text.to_bytes(4, 'big')
    total = sum(int.from_bytes(image[i:i + 2], 'big') for i in range(0x200, len(image), 2))
    image[0x18E:0x190] = (total & 0xFFFF).to_bytes(2, 'big')
    os.makedirs(out, exist_ok=True)
    path = os.path.join(out, 'wide-items.bin')
    open(path, 'wb').write(image)
    return path


def ready(em, expected):
    for _ in range(100):
        if em.word(ps2emu.WINDOW_DEPTH) == expected and not em.word(ps2emu.WINDOW_INDEX):
            return
        em.frames(2)
    raise RuntimeError('expected depth %d, got %d' % (expected, em.word(ps2emu.WINDOW_DEPTH)))


def slot_of(em, wid):
    for s in range(em.word(ps2emu.WINDOW_DEPTH)):
        if em.word(0xFFFFDF00 + 16 * s + 14) == wid:
            return s
    raise RuntimeError('window %02X is not up' % wid)


def check(em, tag):
    em.shot(os.path.join(out, tag + '.png'))
    depth = em.word(ps2emu.WINDOW_DEPTH)
    for n in range(depth):
        e = 0xFFFFDF00 + 16 * n
        print('    slot %d  window %02X  corner %04X  tiles to %3d' %
              (n, em.word(e + 14), em.word(e), em.word(WT_END + 2 * n)))
    hud = [(em.word(WT_HUD + 6 * i), em.word(WT_HUD + 6 * i + 2), em.word(WT_HUD + 6 * i + 4))
           for i in range(16)]
    print('    unstacked: %s' % ['%04X %d-%d' % h for h in hud if h[0]])
    s = slot_of(em, EQUIP_ID)
    corner = em.word(0xFFFFDF00 + 16 * s)
    if corner in [em.word(WT_HUD + 6 * i) for i in range(16)]:
        raise RuntimeError('%s: the equipment redraw left its stacked range' % tag)
    if em.word(WT_OVERFLOW):
        raise RuntimeError('%s: %d runs found no tiles' % (tag, em.word(WT_OVERFLOW)))
    top = em.word(ps2emu.WINDOW_DEPTH) - 1
    used = em.word(WT_END + 2 * top)
    bump = em.word(WT_HUD_BUMP) if em.byte(WT_HUD_SCREEN) == em.byte(ps2emu.GAME_SCREEN)         else POOL_LEVEL
    print('%-22s depth %d  stacked tiles %3d  unstacked from %3d  free %3d of %d' %
          (tag, top + 1, used, bump, bump - used, POOL_LEVEL), flush=True)
    return bump - used


def open_equip(em):
    ps2emu.open_menu(em)
    ps2emu.pick(em, 3)                 # Equip
    ps2emu.pick(em, 1, settle=90)      # Nei
    ready(em, 7)


def equipped(em, offset, item):
    for _ in range(6):
        if em.byte(NEI + offset) & 0x7F == item and not em.word(ps2emu.WINDOW_ACTIVE) \
                and not em.word(ps2emu.WINDOW_INDEX):
            em.frames(10)
            return
        em.frames(20)
        if em.byte(NEI + offset) & 0x7F == item and not em.word(ps2emu.WINDOW_ACTIVE) \
                and not em.word(ps2emu.WINDOW_INDEX):
            em.frames(10)
            return
        em.press('C', hold=2, release=40)
    raise RuntimeError('item %02X did not reach slot %d' % (item, offset - 0x20))


with PS2(wide_rom(rom)) as em:
    ps2emu.boot_to_field(em)
    em.write(0xFFFFC600, (3).to_bytes(2, 'big'))            # Eusis, Nei, Rudger, Anne
    em.write(0xFFFFC608, bytes([0, 0, 0, 1, 0, 2, 0, 3]))
    base = em.read(0xFFFFC000, 0x40)
    for c in (2, 3):
        em.write(0xFFFFC000 + 64 * c, base)
    em.write(NEI + 0x20, bytes(WORN))
    em.write(NEI + 0x27, bytes([len(INVENTORY)] + INVENTORY))
    free = []

    open_equip(em)
    free.append(check(em, 'open'))
    ps2emu.pick(em, 6, settle=60)      # NEXT, then items 0-7: Laser Claw
    ready(em, 8)                       # Right / Left
    free.append(check(em, 'right_left'))
    ps2emu.pick(em, 1, settle=60)      # Left, over the Sincerity Sleeves
    equipped(em, 0x22, 0x63)
    free.append(check(em, 'laser_claw_left'))
    ps2emu.close_windows(em)

    open_equip(em)
    ps2emu.pick(em, 2, settle=60)      # Silver Ribbon, over the Jewel Ribbon
    equipped(em, 0x20, 0x1A)
    free.append(check(em, 'silver_ribbon'))
    ps2emu.close_windows(em)

    open_equip(em)
    ps2emu.pick(em, 0, settle=60)      # NEXT: items 8-15
    ready(em, 8)
    free.append(check(em, 'page2'))
    ps2emu.pick(em, 7, settle=60)      # Cyber Vest, over the Prisoner Clothes
    equipped(em, 0x23, 0x44)
    free.append(check(em, 'cyber_vest'))
    ps2emu.close_windows(em)

    open_equip(em)
    ps2emu.pick(em, 0, settle=60)      # NEXT
    ready(em, 8)
    ps2emu.pick(em, 5, settle=60)      # Steel Claw (page 2)
    ready(em, 9)                       # Right / Left over the second page
    free.append(check(em, 'page2_right_left'))
    ps2emu.pick(em, 0, settle=60)      # Right, over the Ceramic Claw
    equipped(em, 0x21, 0x59)
    free.append(check(em, 'steel_claw_right'))
    ps2emu.close_windows(em)
    print('worst-case item names: no overflow; least free %d tiles' % min(free), flush=True)

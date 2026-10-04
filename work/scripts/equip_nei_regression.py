"""Regression for the owner's Nei Equip savestates: a Ceramic Claw is
selected from late in the list, then equipped in the other hand. Nei's field
technique count and the field-menu window stack must survive.

    python work/scripts/equip_nei_regression.py [rom]
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu
from ps2emu import PS2

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
NEI = 0xFFFFC040
FIELD_COUNT = NEI + 0x26
INV_COUNT = NEI + 0x27
CERAMIC_CLAW = 0x60


def depth(em, expected, tries=100):
    for _ in range(tries):
        if em.word(ps2emu.WINDOW_DEPTH) == expected and not em.word(ps2emu.WINDOW_INDEX):
            return
        em.frames(2)
    raise RuntimeError('expected depth %d, got %d' % (expected, em.word(ps2emu.WINDOW_DEPTH)))


with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    # A Steel Claw in each hand and a Ceramic Claw late in her inventory.
    # This makes the Right/Left window inherit a list cursor above 1.
    em.write(NEI + 0x20, bytes.fromhex('1A 59 59 2F 40 02 02 06 18 D9 AC C0 9A 60'))
    em.write(NEI + 6, (39).to_bytes(2, 'big'))
    ps2emu.open_menu(em)
    ps2emu.pick(em, 1)                 # Techniques
    ps2emu.pick(em, 1)                 # Nei
    depth(em, 5)
    if em.byte(FIELD_COUNT) != 2:
        raise RuntimeError('Nei lost her field techniques before equipping')
    if em.byte(0xFFFFDE51) != 1:
        raise RuntimeError('Nei has an unexpected NEXT page marker')
    ps2emu.close_windows(em)

    ps2emu.open_menu(em)
    ps2emu.pick(em, 3)                 # Equip
    ps2emu.pick(em, 1, settle=90)      # Nei
    depth(em, 7)
    listed = em.read(NEI + 0x28, em.byte(INV_COUNT))
    choices = [i for i, item in enumerate(listed) if item & 0x7F == CERAMIC_CLAW]
    if not choices or choices[0] < 2:
        raise RuntimeError('Ceramic Claw is not late in Nei\'s list: %s' % listed.hex(' '))
    ps2emu.pick(em, choices[0], settle=60)
    depth(em, 8)                       # Right / Left
    if em.word(0xFFFFDF7E) != 0x39:
        raise RuntimeError('the Right/Left window did not open')
    if em.byte(FIELD_COUNT) != 2:
        raise RuntimeError('Right/Left preview overwrote Nei\'s technique count')
    ps2emu.pick(em, 1, settle=60)      # Left hand
    for _ in range(6):
        if em.byte(NEI + 0x22) == CERAMIC_CLAW and em.word(ps2emu.WINDOW_DEPTH) == 7 \
                and not em.word(ps2emu.WINDOW_INDEX):
            break
        em.press('C', hold=2, release=40)
    else:
        raise RuntimeError('Ceramic Claw was not equipped in the left hand')
    if em.byte(FIELD_COUNT) != 2:
        raise RuntimeError('equipping Ceramic Claw overwrote the technique count')
    ps2emu.close_windows(em)
    depth(em, 0)
    print('Nei field count %d; inventory count %d; overflow %d' %
          (em.byte(FIELD_COUNT), em.byte(INV_COUNT), em.word(0xFFFF8E30)), flush=True)
    if em.word(0xFFFF8E30):
        raise RuntimeError('the Equip redraw exhausted VWF tiles')

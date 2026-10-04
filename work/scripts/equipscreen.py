"""Bounded check of the field menu's Equip screen (party_menu_ps4, ext/equipscreen.asm):
Equip > Eusis with a mixed inventory. The list must hold only what he can equip (worn
items included, E-marked); the comparison (Attack, Defense, Agility now > then) is read
from RAM for every entry; the Carbon Shield is picked, compared for each hand in the
Right/Left window and put in the left hand. Then a two-handed Sword is equipped, B goes
back to the Who? list with the inventory whole again, and a Sonic Gun is given before
reopening Equip. Every step is depth- or cursor-checked, including the VWF overflow
counter; screenshots go to work/analysis/equipscreen/.

    python work/scripts/equipscreen.py [rom]
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa: E402
from ps2emu import PS2  # noqa: E402

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
out = os.path.join(ps2emu.ANALYSIS, 'equipscreen')
os.makedirs(out, exist_ok=True)
EUSIS = 0xFFFFC000
SHOWN = 0xFFFF8E6C           # EQ_SHOWN: attack now/then, defense now/then, agility now/then
CURSOR = 0xFFFFDE50
KNIFE, DAGGER, TITANIUM, BOOTS, SHIELD, SWORD, NEIMET, MONOMATE, SONIC_GUN = \
    0x56, 0x57, 0x30, 0x41, 0x47, 0x5C, 0x27, 0x11, 0x6F


def depth(em, expected, tries=100):
    for _ in range(tries):
        if em.word(ps2emu.WINDOW_DEPTH) == expected:
            return
        em.frames(2)
    raise RuntimeError('expected %d windows, got %d' % (expected, em.word(ps2emu.WINDOW_DEPTH)))


def shown(em):
    w = [int.from_bytes(em.read(SHOWN + 2 * i, 2), 'big') for i in range(6)]
    return 'ATK %d>%d DEF %d>%d AGI %d>%d' % tuple(w)


def shot(em, name):
    em.frames(4)
    em.shot(os.path.join(out, name + '.png'))
    print('%-10s depth %d cursor %s overflow %d hud %d  %s' % (
        name, em.word(ps2emu.WINDOW_DEPTH), list(em.read(CURSOR, 2)),
        em.word(0xFFFF8E30), em.word(0xFFFF8E34), shown(em)),
        flush=True)


def cursor_to(em, index, tries=20):
    for _ in range(tries):
        cur = em.read(CURSOR, 1)[0]
        if cur == index:
            return
        em.press('D' if index > cur else 'U', hold=2, release=12)
    raise RuntimeError('the cursor stays at %d, wanted %d' % (em.read(CURSOR, 1)[0], index))


with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    if em.byte(EUSIS + 0x21) != KNIFE:
        raise RuntimeError('Eusis is not holding the Knife ($%02X)' % em.byte(EUSIS + 0x21))
    worn = bytes(em.read(EUSIS + 0x28, 3))
    inv = worn + bytes([MONOMATE, DAGGER, NEIMET, TITANIUM, BOOTS, MONOMATE, SHIELD, SWORD])
    em.write(EUSIS + 0x27, bytes([len(inv)]) + inv)
    em.press('C', hold=2, release=70)
    depth(em, 3)
    ps2emu.pick(em, 3)                               # Equip
    depth(em, 4)
    ps2emu.pick(em, 0, settle=90)                    # Eusis
    depth(em, 7)                                     # comparison, equipment, list
    listed = bytes(em.read(EUSIS + 0x28, em.byte(EUSIS + 0x27)))
    print('listed', listed.hex(' '))
    if any(b & 0x7F in (MONOMATE, DAGGER, TITANIUM) for b in listed) or SHIELD not in listed:   # the game's data
        raise RuntimeError('the list is not filtered: %s' % listed.hex(' '))
    for k in range(len(listed)):                     # every entry's comparison
        cursor_to(em, k)
        shot(em, 'entry%d' % k)
    ps2emu.pick(em, listed.index(SHIELD), settle=60)
    depth(em, 8)                                     # Right / Left
    shot(em, 'right')
    cursor_to(em, 1)
    shot(em, 'left')
    em.press('C', hold=2, release=60)
    for _ in range(6):                               # the message, at most six C
        if em.byte(EUSIS + 0x22) == SHIELD and em.word(ps2emu.WINDOW_DEPTH) == 7 \
                and not em.word(ps2emu.WINDOW_INDEX):
            break
        em.press('C', hold=2, release=40)
    if em.byte(EUSIS + 0x22) != SHIELD:
        raise RuntimeError('the left hand holds $%02X' % em.byte(EUSIS + 0x22))
    depth(em, 7)
    em.frames(30)
    shot(em, 'equipped')
    ps2emu.pick(em, listed.index(SWORD), settle=60)  # a two-handed weapon
    for _ in range(6):
        if em.byte(EUSIS + 0x21) == SWORD and em.byte(EUSIS + 0x22) == SWORD \
                and em.word(ps2emu.WINDOW_DEPTH) == 7 and not em.word(ps2emu.WINDOW_INDEX):
            break
        em.press('C', hold=2, release=40)
    if em.byte(EUSIS + 0x21) != SWORD or em.byte(EUSIS + 0x22) != SWORD:
        raise RuntimeError('the two-handed Sword is not in both hands')
    depth(em, 7)
    em.frames(30)
    shot(em, 'twohand')
    if em.word(0xFFFF8E30):
        raise RuntimeError('the Equip redraw exhausted VWF tiles')
    em.press('B', hold=2, release=70)
    depth(em, 4)                                     # back to the Who? list
    em.frames(10)
    shot(em, 'back')
    whole = bytes(em.read(EUSIS + 0x27, len(inv) + 1))
    expect = bytes([len(inv)]) + bytes([worn[0] & 0x7F]) + worn[1:] + bytes([
        MONOMATE, DAGGER, NEIMET, TITANIUM, BOOTS, MONOMATE, SHIELD, SWORD | 0x80])
    if whole != expect:
        raise RuntimeError('the inventory is %s, wanted %s' % (whole.hex(' '), expect.hex(' ')))
    # Giving Eusis a Sonic Gun adds one equip choice. Reopening after the two
    # redraw paths must retain enough VWF tiles for every label.
    em.write(EUSIS + 0x28 + 3, bytes([SONIC_GUN]))  # replace the first Monomate
    ps2emu.pick(em, 0, settle=90)
    depth(em, 7)
    relisted = bytes(em.read(EUSIS + 0x28, em.byte(EUSIS + 0x27)))
    print('relisted', relisted.hex(' '))
    if [b & 0x7F for b in relisted] != [b & 0x7F for b in listed[:3]] + \
            [SONIC_GUN] + [b & 0x7F for b in listed[3:]]:
        raise RuntimeError('giving a Sonic Gun changed the equippable list')
    shot(em, 'sonicgun')
    if em.word(0xFFFF8E30):
        raise RuntimeError('reopening Equip after giving a Sonic Gun exhausted VWF tiles')
    ps2emu.close_windows(em)
    depth(em, 0)
    print('equip screen: filter, comparison, one/two hands, Sonic Gun and inventory passed')

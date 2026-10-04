"""Bounded check that the field menu returns to the list an action came from
(party_menu_ps4, PM_CloseAll): Items > Eusis > Monomate > Use > Eusis comes back to his
item list (redrawn, the Monomate gone) waiting for a pick; a second item is given to Nei
and a third dropped, each coming back the same way; the last item used brings back the
character list; Techniques > Nei > Res > Eusis comes back to her technique list. Every
step is depth-, cursor- or RAM-checked; a shot of each (work/analysis/menureturn/).

    python work/scripts/menureturn.py [rom]
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa: E402
from ps2emu import PS2  # noqa: E402

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
out = os.path.join(ps2emu.ANALYSIS, 'menureturn')
os.makedirs(out, exist_ok=True)
EUSIS, NEI = 0xFFFFC000, 0xFFFFC040
EVENT_ROUTINE = 0xFFFFDE58
MONOMATE, ANTIDOTE = 0x11, 0x14


def depth(em, expected, tries=150):
    for _ in range(tries):
        if em.word(ps2emu.WINDOW_DEPTH) == expected and not em.word(ps2emu.WINDOW_INDEX):
            return
        em.frames(2)
    raise RuntimeError('expected %d windows, got %d' % (expected, em.word(ps2emu.WINDOW_DEPTH)))


def shot(em, name):
    em.frames(6)
    em.shot(os.path.join(out, name + '.png'))
    print('%-10s depth %d cursor %s step %d items %s' % (
        name, em.word(ps2emu.WINDOW_DEPTH), list(em.read(0xFFFFDE50, 2)), em.word(EVENT_ROUTINE),
        em.read(EUSIS + 0x27, 7).hex(' ')), flush=True)


def through_messages(em, want, presses=6):
    """C through the action's messages until `want` windows are up again."""
    for _ in range(presses):
        if em.word(ps2emu.WINDOW_DEPTH) == want and not em.word(ps2emu.WINDOW_INDEX):
            em.frames(20)
            if em.word(ps2emu.WINDOW_DEPTH) == want:
                return
        em.press('C', hold=2, release=40)
    depth(em, want)


with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    em.write(EUSIS + 2, (5).to_bytes(2, 'big'))
    worn = bytes(em.read(EUSIS + 0x28, 3))
    em.write(EUSIS + 0x27, bytes([6]) + worn + bytes([MONOMATE, ANTIDOTE, MONOMATE]))
    em.write(NEI + 6, (99).to_bytes(2, 'big') * 2)
    em.press('C', hold=2, release=70)
    depth(em, 3)
    ps2emu.pick(em, 0)                          # Items
    depth(em, 4)
    ps2emu.pick(em, 0)                          # Eusis
    depth(em, 5)
    ps2emu.pick(em, 3)                          # Monomate
    ps2emu.pick(em, 0)                          # Use
    ps2emu.pick(em, 0)                          # on Eusis
    through_messages(em, 5)                     # back at his item list
    shot(em, 'used')
    if em.word(EVENT_ROUTINE) != 3 or em.byte(EUSIS + 0x27) != 5:
        raise RuntimeError('not back at the list waiting for a pick')
    ps2emu.pick(em, 3)                          # the Antidote
    ps2emu.pick(em, 1)                          # Give
    ps2emu.pick(em, 1)                          # to Nei
    through_messages(em, 5)
    shot(em, 'given')
    if em.byte(EUSIS + 0x27) != 4:
        raise RuntimeError('the Antidote was not given')
    ps2emu.pick(em, 3)                          # the other Monomate
    ps2emu.pick(em, 2)                          # Drop
    for _ in range(6):                          # "really drop it?" - Yes
        if em.byte(EUSIS + 0x27) == 3:
            break
        em.press('C', hold=2, release=40)
    through_messages(em, 5)
    shot(em, 'dropped')
    if em.byte(EUSIS + 0x27) != 3:
        raise RuntimeError('the Monomate was not dropped')
    ps2emu.close_windows(em)
    depth(em, 0)
    # the last item: back to the character list
    em.write(NEI + 0x27, bytes([1, MONOMATE]))
    em.write(NEI + 2, (3).to_bytes(2, 'big'))
    em.press('C', hold=2, release=70)
    depth(em, 3)
    ps2emu.pick(em, 0)                          # Items
    ps2emu.pick(em, 1)                          # Nei
    depth(em, 5)
    ps2emu.pick(em, 0)                          # her Monomate
    ps2emu.pick(em, 0)                          # Use
    ps2emu.pick(em, 1)                          # on Nei
    through_messages(em, 4)                     # the character list
    shot(em, 'emptied')
    if em.word(EVENT_ROUTINE) != 2:
        raise RuntimeError('not back at the character list')
    ps2emu.close_windows(em)
    depth(em, 0)
    # Techniques: Res, back to the technique list
    em.write(EUSIS + 2, (5).to_bytes(2, 'big'))
    em.press('C', hold=2, release=70)
    depth(em, 3)
    ps2emu.pick(em, 1)                          # Techniques
    ps2emu.pick(em, 1)                          # Nei
    depth(em, 5)
    ps2emu.pick(em, 0)                          # Res
    ps2emu.pick(em, 0)                          # on Eusis
    through_messages(em, 5)
    shot(em, 'technique')
    if em.word(EVENT_ROUTINE) != 3 or em.word(EUSIS + 2) == 5:
        raise RuntimeError('not back at the technique list, or no heal')
    ps2emu.close_windows(em)
    depth(em, 0)
    print('menu returns to its lists: Use, Give, Drop, the last item, a technique passed')

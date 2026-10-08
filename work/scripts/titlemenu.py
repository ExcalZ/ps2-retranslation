"""Bounded title-menu check with empty or populated SRAM.

    python work/scripts/titlemenu.py [rom] [saved.sram] [choice]

choice is 0 (default), 1 (New with saves), or 2 (Erase with saves).
Choice 1 expects a free slot: with all four full, New asks to overwrite (event 5).
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
from ps2emu import PS2, GAME_SCREEN, SCREEN_TITLE, listing_address  # noqa: E402

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
sram = sys.argv[2] if len(sys.argv) > 2 else None
choice = int(sys.argv[3]) if len(sys.argv) > 3 else 0
WIN_SAVED = 0xFFFFDE54
WIN_DEPTH = 0xFFFFDE04
EVENT = 0xFFFFDE58
CURSOR = 0xFFFFDE50
TM_MAX = 0xFFFF8E7E
WIN_INDEX = 0xFFFFDE10

if choice not in range(3) or (not sram and choice):
    raise ValueError('invalid title-menu choice')

with PS2(rom, sram=sram) as em:
    for _ in range(100):
        if em.word(GAME_SCREEN) == SCREEN_TITLE:
            break
        em.frames(10)
    else:
        raise RuntimeError('title screen did not appear')
    em.frames(60)
    em.press('S', release=60)
    for step in range(12):
        if em.word(WIN_SAVED) == 0x37 and em.word(WIN_DEPTH):
            break
        if em.word(WIN_INDEX) & 0xFF == 0x37:
            em.frames(10)  # the menu is opening; do not choose its first row
        else:
            em.press('C', hold=2, release=40)
    else:
        raise RuntimeError('title menu did not open')
    em.frames(45)
    assert em.word(WIN_SAVED) == 0x37 and em.word(WIN_DEPTH) == 1
    expected_max = 2 if sram else 0
    assert em.word(TM_MAX) == expected_max
    assert list(em.read(CURSOR, 2)) == [0, expected_max]
    if not sram:
        # The one-row art's blanks must be the window's blank tile $26: the label is
        # drawn only over blanks, and an ASCII space ($20, v1.0) shows a garbage tile.
        art = em.read(listing_address('TM_EmptyArt'), 17 * 4)
        assert 0x20 not in art and art.count(0x26) == 17 + 15, art.hex()
    if choice:
        from ps2emu import pick  # noqa: E402
        pick(em, choice, settle=40)
    else:
        em.press('C', hold=2, release=40)
    # After forty release frames the title flow is waiting at its next window.
    # New has reached the naming prompt, Continue the save-slot list, and
    # Erase its save-slot list. These states are distinct from the menu itself.
    expected_event = (11, 7, 14)[choice] if sram else 7
    assert em.word(EVENT) == expected_event, (em.word(EVENT), expected_event)
    print('ok: %s, choice %d, event %d' %
          ('saved files' if sram else 'empty SRAM', choice, expected_event))

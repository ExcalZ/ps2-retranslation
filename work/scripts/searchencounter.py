"""Check that searching on a tile boundary cannot skip that step's encounter roll.

    python work/scripts/searchencounter.py [ROM]

The A button starts a search on the same frame as a rightward step. The window
covers the tile-centre frame. Hold right while dismissing it: stock PS II does
not roll until the following tile, while the fix resolves the pending roll as
soon as the window has closed. The loop and movement are bounded.
"""
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu

MOVED = 0xFFFFCB0A
ROM = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')

with ps2emu.PS2(ROM) as em:
    ps2emu.boot_to_field(em)
    start_x = em.word(ps2emu.PLAYER_X)
    if em.word(ps2emu.WINDOW_DEPTH) or em.word(MOVED):
        raise RuntimeError('field is not idle after boot')

    roll_pc = ps2emu.listing_address('SearchEncounter_Continue')
    em.breakpoint(roll_pc)
    rolls = []

    def record(pc):
        if pc == roll_pc:
            rolls.append((em.frame, em.word(ps2emu.PLAYER_X)))

    em.pad = ps2emu.BUTTON['R'] | ps2emu.BUTTON['A']
    em.frames(2, hook=record)
    em.pad = ps2emu.BUTTON['R']
    em.frames(70, hook=record)
    if em.word(ps2emu.WINDOW_DEPTH) != 1 or em.word(ps2emu.PLAYER_X) != start_x + 16:
        raise RuntimeError('search did not cover the first tile centre')
    if not em.word(MOVED) & 2:
        raise RuntimeError('encounter roll was not held while search was open')
    if rolls:
        raise RuntimeError('encounter rolled before the search window closed')

    em.pad = ps2emu.BUTTON['R'] | ps2emu.BUTTON['A']
    em.frames(2, hook=record)
    em.pad = ps2emu.BUTTON['R']
    em.frames(30, hook=record)
    em.pad = 0
    if em.word(ps2emu.WINDOW_DEPTH) or em.word(ps2emu.WINDOW_INDEX):
        raise RuntimeError('search window did not close')
    if len(rolls) != 1 or not start_x + 16 < rolls[0][1] < start_x + 32:
        raise RuntimeError('first tile roll was missed or duplicated: %r' % (rolls,))
    if em.word(MOVED):
        raise RuntimeError('moved flag remained set after the roll')
    print('search encounter roll resolved at x=%d before the next tile centre x=%d'
          % (rolls[0][1], start_x + 32))

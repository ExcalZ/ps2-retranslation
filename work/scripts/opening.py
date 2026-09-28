"""The opening, for reading the translation: title -> NEW GAME -> name the hero -> through
the opening, the dream, the Commander and Nei to the field, a screenshot per press
(work/analysis/opening/pNNN.png) with the script id. Bounded like boot_to_field.

    python work/scripts/opening.py [rom] [name]
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import (PS2, ANALYSIS, GAME_SCREEN, SCRIPT_ID, WINDOW_ACTIVE, WINDOW_INDEX,  # noqa
                    SCREEN_TITLE, SCREEN_FIELD, DEMO_FLAG)

args = sys.argv[1:]
rom = args.pop(0) if args and args[0].endswith('.bin') else os.path.join(ROOT, 'ps2en.bin')
name = args[0] if args else 'Eusis'
out = os.path.join(ANALYSIS, 'opening')

with PS2(rom) as em:
    for _ in range(200):
        if em.word(GAME_SCREEN) == SCREEN_TITLE:
            break
        em.frames(10)
    else:
        raise SystemExit('no title screen')
    em.frames(60)
    em.press('S', release=60)
    ps2emu.type_name(em, name)
    for k in range(160):
        if em.word(GAME_SCREEN) == SCREEN_FIELD and not em.word(DEMO_FLAG) \
                and not em.word(WINDOW_ACTIVE) and not em.word(WINDOW_INDEX):
            print('field reached after %d presses' % k)
            break
        em.frames(50)
        em.shot(os.path.join(out, 'p%03d.png' % k))
        print('%03d script %04X screen %04X' % (k, em.word(SCRIPT_ID), em.word(GAME_SCREEN)), flush=True)
        em.press('C', hold=2, release=10)
    else:
        print('stopped: the field never came')

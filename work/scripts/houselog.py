"""Diagnostic: log the RAM signals at every C press from the naming window through the
Nei scene into Rolf's house menu (bounded: 110 presses), with screenshots near the end.

    python work/scripts/houselog.py [rom]
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, ANALYSIS, GAME_SCREEN, WINDOW_ACTIVE, SCRIPT_ID, WINDOW_INDEX  # noqa

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
out = os.path.join(ANALYSIS, 'house')
with PS2(rom) as em:
    while em.word(GAME_SCREEN) != ps2emu.SCREEN_TITLE:
        em.frames(10)
    em.frames(60)
    em.press('S', release=60)
    ps2emu.type_name(em, 'AAAA')
    for k in range(110):
        em.press('C', hold=2, release=24)
        w = em.word
        print('%3d scr %04X demo %d win %d idx %04X saved %04X ev %04X/%04X bld %04X script %04X' % (
            k, w(GAME_SCREEN), w(0xFFFFF750), w(WINDOW_ACTIVE), w(WINDOW_INDEX), w(0xFFFFDE54),
            w(0xFFFFDE58), w(0xFFFFDE5A), w(0xFFFFF760), w(SCRIPT_ID)), flush=True)
        if k >= 70 and k % 5 == 0:
            em.shot(os.path.join(out, 'h%03d.png' % k))

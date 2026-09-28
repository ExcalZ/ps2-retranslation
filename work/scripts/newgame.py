"""Title -> New Game -> naming -> the opening -> the field, logging the game screen, the
script id and the window flag, with a screenshot every few presses. Used to learn the
boot path for tools/ps2emu.py.

    python work/scripts/newgame.py [rom]
"""
import os
import sys
import time
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
from ps2emu import PS2, GAME_SCREEN, SCRIPT_ID, WINDOW_ACTIVE, TEXT_POINTER, LEVEL_INDEX, ANALYSIS  # noqa

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
out = os.path.join(ANALYSIS, 'ng')
LOCKED = 0xFFFFFFF0
WINDOW_INDEX = 0xFFFFDE10


def log(em, k):
    st = (em.word(GAME_SCREEN), em.word(SCRIPT_ID), em.word(WINDOW_ACTIVE), em.long(TEXT_POINTER),
          em.word(LEVEL_INDEX), em.word(LOCKED), em.word(WINDOW_INDEX), em.word(0xFFFFF760))
    print(k, em.frame, '%.0fs screen %04X script %04X win %d ptr %08X level %04X locked %d winidx %04X building %04X'
          % ((time.time() - t0,) + st), flush=True)


t0 = time.time()
with PS2(rom) as em:
    while em.word(GAME_SCREEN) != 0x400:
        em.frames(10)
    em.frames(60)
    em.press('S', release=60)
    for k in range(8):              # data check, NEW GAME, the naming prompt
        em.press('C', hold=2, release=40)
    for b in 'CCCCDDDRRC':         # AAAA, down to ADV/RUB/END, right to END
        em.press(b, hold=2, release=12)
    for k in range(200):
        if k % 5 == 0:
            log(em, k)
        if k % 20 == 0:
            em.shot(os.path.join(out, 'f%03d.png' % k))
        em.press('C', hold=2, release=24)
    log(em, 999)
    em.shot(os.path.join(out, 'end.png'))

"""The field camera (centered_camera): walk the hero each way from the start of the
field and log the player's screen position ($1E y, $20 x of the object at $E400) - it
should settle at y $108, x $128 wherever the map can scroll. Bounded.

    python work/scripts/camera.py [rom]
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, ANALYSIS  # noqa

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
out = os.path.join(ANALYSIS, 'camera')
PLAYER = 0xFFFFE400


def pos(em):
    return em.word(PLAYER + 0x20), em.word(PLAYER + 0x1E), em.word(PLAYER + 0x0A)


with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    print('start   screen x %04X y %04X  map x %04X' % pos(em))
    em.shot(os.path.join(out, 'start.png'))
    for d in 'DDLLRRRRUU':
        em.press(d, hold=40, release=10)
        print('%s       screen x %04X y %04X  map x %04X' % ((d,) + pos(em)))
    em.shot(os.path.join(out, 'end.png'))

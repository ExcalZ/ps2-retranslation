"""Bounded field-menu check: the party panel and meseta, Status > Status >
Eusis's status screen > Techniques, Nei's status screen (another portrait and
palette) and B back to the list, Order, and backing out; a shot of each
(work/analysis/partymenu/).

    python work/scripts/partymenu.py [rom]
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu
from ps2emu import PS2

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
out = os.path.join(ps2emu.ANALYSIS, 'partymenu')


def shot(em, name):
    em.shot(os.path.join(out, name + '.png'))


def depth(em, expected):
    for _ in range(100):
        if em.word(ps2emu.WINDOW_DEPTH) == expected:
            return
        em.frames(2)
    raise RuntimeError('expected %d windows, got %d' %
                       (expected, em.word(ps2emu.WINDOW_DEPTH)))


with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    em.press('C', hold=2, release=70)
    depth(em, 3)
    shot(em, 'menu')
    ps2emu.pick(em, 2)            # Status
    depth(em, 4)
    shot(em, 'status')
    ps2emu.pick(em, 0)            # Status
    depth(em, 5)
    ps2emu.pick(em, 0)            # Eusis
    depth(em, 10)                 # the status screen's five windows
    shot(em, 'stats')
    em.press('C', hold=2, release=70)
    depth(em, 12)                 # two technique windows
    shot(em, 'techniques')
    ps2emu.close_windows(em)
    depth(em, 0)
    em.press('C', hold=2, release=70)
    depth(em, 3)
    ps2emu.pick(em, 2)            # Status
    ps2emu.pick(em, 0)            # Status
    ps2emu.pick(em, 1)            # Nei: another portrait and palette
    depth(em, 10)
    shot(em, 'stats_nei')
    em.press('B', hold=2, release=70)
    depth(em, 5)                  # B closes the five, back to the list
    shot(em, 'back')
    ps2emu.close_windows(em)
    depth(em, 0)
    em.press('C', hold=2, release=70)
    depth(em, 3)
    ps2emu.pick(em, 2)            # Status
    depth(em, 4)
    ps2emu.pick(em, 1)            # Order
    depth(em, 6)
    shot(em, 'order')
    ps2emu.close_windows(em)
    depth(em, 0)
    print('menu, status, techniques, order, and backout passed')

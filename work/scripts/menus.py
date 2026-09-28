"""Field menus under vwf_windows: give the hero eight items, open the menu -> ITEM ->
the hero, screenshot every step, save a state of the item list, report the engine's
overflow counter. Bounded.

    python work/scripts/menus.py [rom]
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, ANALYSIS, WINDOW_INDEX  # noqa

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
out = os.path.join(ANALYSIS, 'menus')
ITEMS = [1, 2, 4, 10, 13, 17, 19, 22]
with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    em.write(0xFFFFC027, bytes([len(ITEMS)]) + bytes(ITEMS) + bytes(16 - len(ITEMS)))
    for k, b in enumerate('CCC'):
        em.press(b, hold=2, release=45)
        em.shot(os.path.join(out, 'm%d.png' % k))
    ps2emu.save_state(em, os.path.join(ROOT, 'work', 'states', 'vram', 'itemlist.state'))
    print('overflow', em.word(0xFFFF8E30), 'window ends', [em.word(0xFFFF8D80 + 2 * i) for i in range(6)])
    runs = em.read(0xFFFF8C00, 8 * 12)
    for i in range(12):
        r = runs[i * 8:i * 8 + 8]
        if r[0] | r[1]:
            print('run %04X cells %d kind %d data %08X' % ((r[0] << 8) | r[1], r[2], r[3], int.from_bytes(r[4:8], 'big')))
    for _ in range(2):
        em.press('B', hold=2, release=25)
    for k, b in enumerate('DDCC'):          # TECH, the hero: the technique list
        em.press(b, hold=2, release=45)
    em.shot(os.path.join(out, 'tech.png'))
    print('overflow', em.word(0xFFFF8E30), 'window ends', [em.word(0xFFFF8D80 + 2 * i) for i in range(6)])
    for _ in range(4):
        em.press('B', hold=2, release=25)
    em.shot(os.path.join(out, 'closed.png'))

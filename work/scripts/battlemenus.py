"""Battle windows under vwf_windows: force a battle, then walk the command windows and
screenshot each step - the command list, a technique list, the item list. Cursor- and
depth-driven, bounded.

    python work/scripts/battlemenus.py [rom] [steps]
steps: a comma list for ps2emu.run_steps (a number picks a list entry, w waits, a button
letter presses it, f films FILM shots).
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, ANALYSIS, GAME_SCREEN  # noqa

rom = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1].endswith('.bin') else os.path.join(ROOT, 'ps2en.bin')
steps = next((a for a in sys.argv[1:] if not a.endswith('.bin')), 'w').split(',')
tag = 'stock_' if 'original' in rom else ''
ENEMY_DATA = 0xFFFFCB00
SCREEN_BATTLE = 0x14
out = os.path.join(ANALYSIS, 'battlemenus')


def state(em):
    return 'depth %d cursor %s' % (em.word(ps2emu.WINDOW_DEPTH), list(em.read(0xFFFFDE50, 2)))


with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    em.write(0xFFFFC025, bytes([3, 3]))                       # techniques
    em.write(0xFFFFC027, bytes([3, 1, 2, 4]) + bytes(13))     # items
    em.write(ENEMY_DATA, (1).to_bytes(2, 'big'))
    em.write(GAME_SCREEN, bytes([SCREEN_BATTLE]))
    em.frames(300)                                            # the battle's HUD windows are unstacked
    em.frames(30)
    em.shot(os.path.join(out, '%s0.png' % tag))
    print('start', state(em))
    ps2emu.run_steps(em, steps, out, tag, int(os.environ.get('FILM', 24)))

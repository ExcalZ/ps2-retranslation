"""A building under vwf_windows: from the Paseo field load building `index` (the game's own
building screen), then run the steps (ps2emu.run_steps), screenshotting each. Bounded.

    python work/scripts/building.py [rom] index steps
e.g. building.py 7 w,C,C,0   the item store: its greeting, BUY, the list
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, ANALYSIS, GAME_SCREEN  # noqa

args = sys.argv[1:]
rom = args.pop(0) if args and args[0].endswith('.bin') else os.path.join(ROOT, 'ps2en.bin')
index = int(args[0], 16)
steps = args[1].split(',') if len(args) > 1 else ['w']
tag = ('stock_' if 'original' in rom else '') + 'b%02X_' % index
out = os.path.join(ANALYSIS, 'buildings')
BUILDING_INDEX = 0xFFFFF760
SCREEN_BUILDING = 0x10

with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    em.write(0xFFFFC027, bytes([3, 1, 2, 4]) + bytes(13))     # items to sell
    em.write(0xFFFFC700, bytes([4, 5, 6, 7, 8, 9]) + bytes(6))  # towns known: Paseo..Piata (teleport)
    em.write(BUILDING_INDEX, index.to_bytes(2, 'big'))
    em.write(GAME_SCREEN, bytes([SCREEN_BUILDING]))
    em.frames(200)
    em.shot(os.path.join(out, '%s0.png' % tag))
    ps2emu.run_steps(em, steps, out, tag, int(os.environ.get('FILM', 24)))

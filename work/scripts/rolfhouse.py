"""Bounded look at Eusis's house with Rudger joined: the options after "continue as
is? - No", View Strength > Rudger (his profile), then Change Members (the list).
Steps as ps2emu.run_steps (a number picks that entry, a letter presses it, w waits);
a shot of each (work/analysis/rolfhouse/).

    python work/scripts/rolfhouse.py [rom] [steps]
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa: E402
from ps2emu import PS2, GAME_SCREEN  # noqa: E402

args = sys.argv[1:]
rom = args.pop(0) if args and args[0].endswith('.bin') else os.path.join(ROOT, 'ps2en.bin')
steps = (args[0] if args else 'w,C,C,w,1,w,0,w,2,w,B,w,B,w,1,w').split(',')
out = os.path.join(ps2emu.ANALYSIS, 'rolfhouse')
BUILDING_INDEX, SCREEN_BUILDING = 0xFFFFF760, 0x10

with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    em.write(0xFFFFC604, (2).to_bytes(2, 'big'))     # party_members_joined: Rudger is in
    em.write(0xFFFFC606, (2).to_bytes(2, 'big'))     # party_member_join_next: no knock
    em.write(BUILDING_INDEX, (1).to_bytes(2, 'big'))
    em.write(GAME_SCREEN, bytes([SCREEN_BUILDING]))
    em.frames(200)
    em.shot(os.path.join(out, '0.png'))
    ps2emu.run_steps(em, steps, out, '', 4)

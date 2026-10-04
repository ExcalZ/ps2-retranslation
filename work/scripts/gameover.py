"""Check the game over text path after forcing the transition from the field.

    python work/scripts/gameover.py [rom]

Bounded: the screen types its message without input, then waits for its own timer.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, GAME_SCREEN  # noqa

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
with PS2(rom) as em:
    ps2emu.boot_to_field(em, name='EUSIS')
    bare = ps2emu.listing_address('VWF_Upload_Bare')
    seen_bare = [False]

    def on_break(pc):
        if pc == bare:
            seen_bare[0] = True
            em.unbreak(bare)

    em.breakpoint(bare)
    em.write(GAME_SCREEN, b'\x00')
    em.frames(220, hook=on_break)
    if (em.byte(GAME_SCREEN) != 0 or em.word(0xFFFFCD18) != 0x4514
            or em.word(0xFFFFCD1C) != 4 or not seen_bare[0]):
        raise RuntimeError('game over screen did not open')
    print('game over transparent font path active, cursor %04X'
          % em.word(0xFFFFCD16), flush=True)

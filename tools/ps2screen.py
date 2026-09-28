"""Render the screen of a BlastEm savestate of Phantasy Star II to a PNG (planes, window
plane and sprites, from the VRAM, CRAM, VSRAM and VDP registers in the state).

    python tools/ps2screen.py state.state [out.png]

The VDP block is found by tools/vramaudit.py (the game's font at VRAM $A000); the
drawing is tools/md/blastem_screen.py's. Used by ps2emu.shot() when BlastEm's window
cannot be captured (it paints white while stopped in the stub on some desktops).
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, 'md'))
import vramaudit
import blastem_screen


def render(state, out):
    st = vramaudit.read_state(state)
    pix, w, h = blastem_screen.render(st)
    blastem_screen.write_png(out, pix, w, h)
    return out


if __name__ == '__main__':
    src = sys.argv[1]
    print(render(src, sys.argv[2] if len(sys.argv) > 2 else os.path.splitext(src)[0] + '.png'))

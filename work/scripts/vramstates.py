"""BlastEm savestates along the new-game path, for VRAM audits (tools/vramaudit.py):
the title, the opening narration, the scenes with portraits, the Commander's big window,
and the Paseo field with a forced message. States go to work/states/vram/.

    python work/scripts/vramstates.py [rom]
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, GAME_SCREEN, WINDOW_ACTIVE, SCRIPT_ID  # noqa

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
out = os.path.join(ROOT, 'work', 'states', 'vram')
with PS2(rom) as em:
    while em.word(GAME_SCREEN) != ps2emu.SCREEN_TITLE:
        em.frames(10)
    em.frames(60)
    ps2emu.save_state(em, os.path.join(out, 'title.state'))
    em.press('S', release=60)
    for _ in range(8):
        em.press('C', hold=2, release=40)
    for b in 'CCCCDDDRRC':
        em.press(b, hold=2, release=12)
    last = None
    for k in range(110):
        em.press('C', hold=2, release=24)
        key = (em.word(GAME_SCREEN), em.word(0xFFFFF760))       # screen, building
        if em.word(WINDOW_ACTIVE) and key != last:
            name = 'p%03d_scr%04X_bld%02X_id%04X' % (k, key[0], key[1], em.word(SCRIPT_ID))
            ps2emu.save_state(em, os.path.join(out, name + '.state'))
            print(name, flush=True)
            last = key

with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    ps2emu.save_state(em, os.path.join(out, 'field.state'))
    ps2emu.show_message(em, 0x1690)
    em.frames(120)
    ps2emu.save_state(em, os.path.join(out, 'field_big.state'))
    em.press('C', hold=2, release=60)
    ps2emu.save_state(em, os.path.join(out, 'field_big2.state'))
    print('field states', flush=True)

"""Force a battle on the Paseo field and fight it out, screenshotting the battle box: the
proportional battle messages (one line of 20 cells) and the victory / experience / meseta
messages. Saves a state for the VRAM audit.

    python work/scripts/battle.py [rom] [formation]
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, ANALYSIS, GAME_SCREEN, WINDOW_ACTIVE, SCRIPT_ID  # noqa

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
formation = int(sys.argv[2], 16) if len(sys.argv) > 2 else 1
ENEMY_DATA = 0xFFFFCB00
SCREEN_BATTLE = 0x14
out = os.path.join(ANALYSIS, 'battle')
with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    em.write(ENEMY_DATA, formation.to_bytes(2, 'big'))
    em.write(GAME_SCREEN, bytes([SCREEN_BATTLE]))
    for k in range(120):
        em.frames(20)
        if k == 20:
            ps2emu.save_state(em, os.path.join(ROOT, 'work', 'states', 'vram', 'battle.state'))
        if k % 2 == 0:
            em.shot(os.path.join(out, 'b%03d.png' % k))
        print(k, 'screen %02X win %d script %04X' % (em.byte(GAME_SCREEN), em.word(WINDOW_ACTIVE), em.word(0xFFFFCC0C)), flush=True)
        if em.byte(GAME_SCREEN) != SCREEN_BATTLE and k > 30:
            break
        em.press('C', hold=2, release=4)

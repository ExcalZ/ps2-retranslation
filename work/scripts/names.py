"""Long party names: name the hero RUDGER (six letters; stored as Rudger), then check
the name where the game shows it - the Commander's greeting ({NAME} insert), the field
menu's status plates and a battle's command window - with screenshots and RAM.

    python work/scripts/names.py [rom] [name]
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
import ps2text  # noqa
from ps2emu import PS2, ANALYSIS, GAME_SCREEN, WINDOW_ACTIVE, SCRIPT_ID  # noqa

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
name = sys.argv[2] if len(sys.argv) > 2 else 'RUDGER'
out = os.path.join(ANALYSIS, 'names')
with PS2(rom) as em:
    shots = []

    def hook_greeting():
        pass
    # through the naming window by hand, to catch the Commander's greeting
    while em.word(GAME_SCREEN) != ps2emu.SCREEN_TITLE:
        em.frames(10)
    em.frames(60)
    em.press('S', release=60)
    ps2emu.type_name(em, name)
    em.shot(os.path.join(out, 'named.png'))
    names = em.read(0xFFFFC660, 4)
    ext = em.read(0xFFFFC686, 2)
    print('stored: %r + %r' % (ps2text.decode_us(names), ps2text.decode_us(ext)), flush=True)
    seen = False
    for k in range(80):
        em.press('C', hold=2, release=24)
        if em.word(SCRIPT_ID) == 0x1105 or (not seen and em.word(0xFFFFF760) == 0x0E and em.word(WINDOW_ACTIVE)):
            if not seen:
                em.frames(60)
                em.shot(os.path.join(out, 'greeting.png'))
                seen = True
        if em.word(GAME_SCREEN) == ps2emu.SCREEN_FIELD and not em.word(WINDOW_ACTIVE) and k > 60:
            break
with PS2(rom) as em:
    ps2emu.boot_to_field(em, name)
    em.press('C', hold=2, release=40)        # the player menu
    em.press('C', hold=2, release=40)        # ITEM -> whose?
    em.shot(os.path.join(out, 'menu.png'))
    em.press('B', hold=2, release=20)
    em.press('D', hold=2, release=10)        # STATE
    em.press('C', hold=2, release=40)
    em.press('C', hold=2, release=60)
    em.shot(os.path.join(out, 'state.png'))
    for _ in range(4):
        em.press('B', hold=2, release=20)
    em.write(0xFFFFCB00, (1).to_bytes(2, 'big'))
    em.write(GAME_SCREEN, bytes([0x14]))
    em.frames(200)
    em.shot(os.path.join(out, 'battle.png'))
print('done')

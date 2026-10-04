"""The ending scene: jump to the Ending screen from the field and film each speech window
(1829-182F, then the closing line 1830), saving a BlastEm state at each for VRAM audits.
Bounded: at most MAX frames; it presses no buttons (the scene times itself).

    python work/scripts/ending.py [rom] [tag]       shots/states to work/analysis/ending/<tag>*
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, ANALYSIS, GAME_SCREEN, WINDOW_ACTIVE, SCRIPT_ID  # noqa

args = [a for a in sys.argv[1:]]
rom = args.pop(0) if args and args[0].endswith('.bin') else os.path.join(ROOT, 'ps2en.bin')
tag = args[0] if args else 'en'
out = os.path.join(ANALYSIS, 'ending')
os.makedirs(out, exist_ok=True)
MAX = 6000

with PS2(rom) as em:
    ps2emu.boot_to_field(em, name='WWWWWW')
    em.write(GAME_SCREEN, bytes([0x08]))
    ids = ['182A', '182B', '182C', '182D', '182E', '182F', '1830']
    seen = []
    prev = 0
    t = 0
    # the scene runs by itself (timers, no buttons): film each window when it stops typing
    while t < MAX and len(seen) < len(ids):
        em.frames(6)
        t += 6
        act = em.word(WINDOW_ACTIVE)
        if prev and not act:
            em.frames(20)
            t += 20
            name = '%s_%s' % (tag, ids[len(seen)])
            em.shot(os.path.join(out, name + '.png'))
            ps2emu.save_state(em, os.path.join(out, name + '.state'))
            print('%5d screen %04X %s cd16 %04X' % (t, em.word(GAME_SCREEN), name, em.word(0xFFFFCD16)), flush=True)
            seen.append(name)
        prev = act
    print('seen', seen, 'frames', t)
    # the credits scroll plane A through all 64 rows: film the closing line leaving
    for k in range(40):
        em.frames(60)
        name = '%s_credits%02d' % (tag, k)
        em.shot(os.path.join(out, name + '.png'))
        print(name, 'screen %04X scroll %04X' % (em.word(GAME_SCREEN), em.word(0xFFFFF61C)), flush=True)

"""The Improvement options on the field and in a battle (fast_walking, improvement_fixes):
walk the hero and log how far the leader and the follower (Nei, the object at $E440) get
in 8 frames and where they stand when they stop; then force a battle and log the command
cursor ($DE50) and the damage-flash timer. Bounded: fixed frame counts, no loops that
press on.

    python work/scripts/improvement.py [rom]
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, ANALYSIS, BUTTON, GAME_SCREEN  # noqa

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
tag = 'stock_' if 'original' in rom else ''
out = os.path.join(ANALYSIS, 'improvement')
LEADER, FOLLOWER = 0xFFFFE400, 0xFFFFE440
ENEMY_DATA = 0xFFFFCB00
SCREEN_BATTLE = 0x14


def xy(em, obj):
    return em.word(obj + 0x0A), em.word(obj + 0x0E)


with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    em.frames(30)
    print('party', em.word(0xFFFFC600) + 1, 'leader', xy(em, LEADER), 'follower', xy(em, FOLLOWER))
    for d in 'DR':
        x0 = xy(em, LEADER)
        em.pad = BUTTON[d]
        em.frames(8)
        x1 = xy(em, LEADER)
        em.frames(24)
        em.pad = 0
        em.frames(40)
        print('%s: 8 frames moved the leader %s px; stopped: leader %s follower %s'
              % (d, (x1[0] - x0[0], x1[1] - x0[1]), xy(em, LEADER), xy(em, FOLLOWER)))
    em.shot(os.path.join(out, '%sfield.png' % tag))

    em.write(ENEMY_DATA, (1).to_bytes(2, 'big'))
    em.write(GAME_SCREEN, bytes([SCREEN_BATTLE]))
    em.frames(330)
    print('battle: command cursor $DE50 = %d, window depth %d'
          % (em.word(0xFFFFDE50), em.word(ps2emu.WINDOW_DEPTH)))
    em.shot(os.path.join(out, '%sbattle.png' % tag))

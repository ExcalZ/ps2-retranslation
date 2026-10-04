"""status_messages / battle_box: fight rounds with every enemy set to one ability of the
EnemyTechniqueTable (always used, always hitting) and film the battle box while its
messages are up. 14, the TP drain (default): Rolf casts DEBAND in the first round
("Defensive barrier up!"), and once it has the ants empty TP ("TP drained!"). 8, Dark Falz's evil
heart: the party has 999 HP against its attack on all, and its turns show 1223-122A, the
two-line box. Bounded.

    python work/scripts/battleability.py [rom] [ability]
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, ANALYSIS, GAME_SCREEN, SCRIPT_ID  # noqa

rom = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1].endswith('.bin') else os.path.join(ROOT, 'ps2en.bin')
ABILITY = int(next((a for a in sys.argv[1:] if not a.endswith('.bin')), '14'))
WATCH = {0x122B, 0x122C} if ABILITY == 14 else set(range(0x1223, 0x122B)) | {0x1208}
out = os.path.join(ANALYSIS, 'battleability', str(ABILITY))
os.makedirs(out, exist_ok=True)
ENEMY_STATS = 0xFFFFC200
COMMANDS = 0xFFFFCC10         # char_battle_command_index: 16 bytes a character
TECH_DEBAN = 0x24


def drain(em):
    for k in range(5):
        em.write(ENEMY_STATS + k * 0x40 + 0x25, bytes([ABILITY, 0xFF, 0x00]))


with PS2(rom) as em:
    ps2emu.boot_to_field(em, name='WWWWWW')
    em.write(0xFFFFCB00, (1).to_bytes(2, 'big'))
    em.write(GAME_SCREEN, bytes([0x14]))
    em.frames(330)
    if em.byte(GAME_SCREEN) != 0x14:
        raise RuntimeError('no battle')
    tps = lambda: (em.word(0xFFFFC006), em.word(0xFFFFC046))
    print('TP', tps(), flush=True)
    shots = 0
    film = 0
    deband = ABILITY == 14                          # until "Defensive barrier up!" has shown
    for n in range(300):
        if not deband:                                  # (the ants act first: they wait for DEBAND)
            drain(em)
        if ABILITY != 14:                               # the evil heart's other move hits all for 90
            for c in (0xFFFFC000, 0xFFFFC040):
                em.write(c + 2, (999).to_bytes(2, 'big') * 2)
        rolf = [0, 1, 0, TECH_DEBAN] if deband else [0, 3, 0, 0]
        em.write(COMMANDS, bytes(rolf))                 # Rolf: DEBAND, or defend (command, technique)
        em.write(COMMANDS + 16, bytes([0, 3]))          # Nei defends
        if n % 25 == 0:
            em.press('C', hold=2, release=4)            # FIGHT (and past any wait)
        em.frames(8)
        sid, bsid = em.word(SCRIPT_ID), em.word(0xFFFFCC0C)
        if sid or bsid:
            print(n, 'script %04X battle %04X TP %s' % (sid, bsid, tps()), flush=True)
        if 0x122B in (sid, bsid):
            deband = False
        if sid in WATCH or bsid in WATCH:
            film = 24                                   # and on while its text is up
        if film:
            film -= 1
            em.shot(os.path.join(out, 'box_%03d.png' % n))
            shots += 1
            if shots >= 120:
                break
        if em.byte(GAME_SCREEN) != 0x14:
            break
    print('TP', tps(), flush=True)

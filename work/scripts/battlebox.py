"""battle_box: force a battle and put one script message in the battle box in the command
phase, as the battle code does; film it every 6 frames, logging the script cursor ($CD16),
the text start ($CD18), the row and last row ($CD1A, $CD1C), the window depth and queue, and the {C6} timer ($CD22).
One message a run: when the box closes the battle goes on into its round, and a second
forced box would meet the round's own windows. The real rounds: battleability.py. Bounded.

    python work/scripts/battlebox.py [rom] [id]      (id in hex, default 122A)
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, ANALYSIS, GAME_SCREEN, WINDOW_ACTIVE, WINDOW_INDEX, SCRIPT_ID, WINDOW_DEPTH  # noqa

rom = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1].endswith('.bin') else os.path.join(ROOT, 'ps2en.bin')
sid = int(next((a for a in sys.argv[1:] if not a.endswith('.bin')), '122A'), 16)
out = os.path.join(ANALYSIS, 'battlebox')
os.makedirs(out, exist_ok=True)

with PS2(rom) as em:
    ps2emu.boot_to_field(em, name='WWWWWW')
    em.write(0xFFFFCB00, (1).to_bytes(2, 'big'))
    em.write(GAME_SCREEN, bytes([0x14]))
    em.frames(330)
    if em.byte(GAME_SCREEN) != 0x14:
        raise RuntimeError('no battle')
    for _ in range(60):
        if not em.word(WINDOW_INDEX) and not em.word(WINDOW_ACTIVE):
            break
        em.frames(10)
    else:
        raise RuntimeError('windows busy')
    em.write(WINDOW_INDEX, (0x65).to_bytes(2, 'big'))
    em.write(SCRIPT_ID, sid.to_bytes(2, 'big'))
    for n in range(50):
        em.frames(6)
        s = em.read(0xFFFFCD16, 8)
        w = [int.from_bytes(s[i:i + 2], 'big') for i in range(0, 8, 2)]
        q = em.read(WINDOW_INDEX, 8)
        print('%3d cur %04X start %04X row %d last %d depth %d active %d queue %s rows %d timer %d' % (
            n * 6, w[0], w[1], w[2], w[3], em.word(WINDOW_DEPTH), em.word(WINDOW_ACTIVE),
            q.hex(), em.word(0xFFFFCF90), em.word(0xFFFFCD22)), flush=True)
        em.shot(os.path.join(out, '%04X_%03d.png' % (sid, n * 6)))

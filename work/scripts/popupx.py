"""Bounded trace of the popup X position per slot (damage_popups) over several rounds with
many enemies: the party defends, every Popup_Store logs its slot, number and the target
object's X ($A), and any change of a slot's X while it shows is reported.

    python work/scripts/popupx.py [rom]       (FORMATION=n, ROUNDS=n)
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa: E402
from ps2emu import PS2, GAME_SCREEN  # noqa: E402

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
out = os.path.join(ps2emu.ANALYSIS, 'popupx')
os.makedirs(out, exist_ok=True)
CHARS = 0xFFFFC000
POP_SLOTS = 0xFFFF8F00
SCREEN_BATTLE = 0x14
FORMATION = int(os.environ.get('FORMATION', 20))
FRAMES = int(os.environ.get('ROUNDS', 6)) * 200

with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    for k in range(2):
        em.write(CHARS + 0x40 * k + 2, (900).to_bytes(2, 'big') * 2)   # survive
    em.write(0xFFFFCB00, FORMATION.to_bytes(2, 'big'))
    em.write(GAME_SCREEN, bytes([SCREEN_BATTLE]))
    em.frames(330)
    if em.byte(GAME_SCREEN) != SCREEN_BATTLE:
        raise RuntimeError('no battle')
    store = ps2emu.listing_address('Popup_Store')
    em.breakpoint(store)

    def hook(pc):
        r = em.regs()
        a2 = r['a'][2] & 0xFFFFFFFF
        print('  frame %d STORE slot %d num %X objX %04X' % (
            em.frame, r['d'][1] & 0xFFFF, r['d'][0] & 0xFFFF, em.word(a2 + 0xA)), flush=True)

    seen = {}
    for n in range(FRAMES):
        if n % 200 == 0:                        # every round: all defend
            for k in range(2):
                em.write(0xFFFFCC10 + 16 * k, bytes([0, 3]))
        em.pad = ps2emu.BUTTON['C'] if n % 10 == 0 else 0
        em.step_frame(hook)
        slots = em.read(POP_SLOTS, 72)
        for k in range(9):
            t = int.from_bytes(slots[8 * k:8 * k + 2], 'big') & 0x7FFF
            v = int.from_bytes(slots[8 * k + 2:8 * k + 4], 'big')
            x = int.from_bytes(slots[8 * k + 4:8 * k + 6], 'big')
            if t and seen.get(k) != (x, v):
                print('%3d slot %d t %d num %04X X %04X' % (n, k, t, v, x), flush=True)
                seen[k] = (x, v)
            if t == 40:
                em.shot(os.path.join(out, 'f%03d_s%d.png' % (n, k)))

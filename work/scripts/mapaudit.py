"""VRAM audit of every field map: from the Paseo field, load each map in turn (level_index,
a position, screen_changed_flag - the game's own reload) and save a BlastEm state of it,
then report per map which tiles hold data or are referenced, and the tiles free on every
map. Bounded: one map at a time, a fixed number of frames each.

    python work/scripts/mapaudit.py [rom] [first] [last]
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
import vramaudit  # noqa
from ps2emu import PS2, GAME_SCREEN  # noqa

out = os.path.join(ROOT, 'work', 'states', 'maps')
LEVEL, LEVEL_Y, LEVEL_X, CHANGED = 0xFFFFC640, 0xFFFFC642, 0xFFFFC644, 0xFFFFF734


def used_tiles(path):
    st = vramaudit.read_state(path)
    v, regs = st['vram'], st['regs']
    ref = set()
    for base in ((regs[2] & 0x38) << 10, (regs[4] & 7) << 13):
        for i in range(64 * 32):
            ref.add(((v[base + 2 * i] << 8) | v[base + 2 * i + 1]) & 0x7FF)
    sat = (regs[5] & 0x7F) << 9
    for i in range(80):
        e = v[sat + i * 8:sat + i * 8 + 8]
        if e[0] | e[1] | e[4] | e[5]:
            t = ((e[4] << 8) | e[5]) & 0x7FF
            sz = e[2] & 0xF
            ref.update(range(t, t + ((sz >> 2) + 1) * ((sz & 3) + 1)))
    data = set(t for t in range(0x800) if any(v[t * 32:t * 32 + 32]))
    return ref, data


if __name__ == '__main__':
    rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
    first = int(sys.argv[2], 16) if len(sys.argv) > 2 else 0
    last = int(sys.argv[3], 16) if len(sys.argv) > 3 else 0x64
    MODE = sys.argv[4] if len(sys.argv) > 4 else 'maps'
    with PS2(rom) as em:
        ps2emu.boot_to_field(em)
        for lvl in range(first, last + 1):
            if MODE == 'buildings':
                em.write(0xFFFFF760, lvl.to_bytes(2, 'big'))       # building_index
                em.write(GAME_SCREEN, bytes([0x10]))               # ScreenID_Building
                em.frames(200)
                path = os.path.join(out, 'bld%02X.state' % lvl)
            else:
                em.write(LEVEL, lvl.to_bytes(2, 'big'))
                em.write(LEVEL_Y, (0x100).to_bytes(2, 'big'))
                em.write(LEVEL_X, (0x100).to_bytes(2, 'big'))
                em.write(CHANGED, (0xFFFF).to_bytes(2, 'big'))
                em.frames(150)
                path = os.path.join(out, 'map%02X.state' % lvl)
            ps2emu.save_state(em, path)
            ref, data = used_tiles(path)
            busy = ref | data
            free = [t for t in range(0x500) if t not in busy]
            runs, st = [], None
            for t in free + [None]:
                if st is not None and (t is None or t != prev + 1):
                    if prev - st >= 7:
                        runs.append('%X-%X' % (st, prev))
                    st = None
                if t is not None and st is None:
                    st = t
                prev = t
            print(MODE[:3] + ' %02X screen %04X: free (8+) %s' % (lvl, em.word(GAME_SCREEN), ' '.join(runs)), flush=True)

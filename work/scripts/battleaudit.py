"""VRAM audit of battles: one map per battle background (the level descriptor's byte $12),
a few enemy formations each and the four boss battles; a battle is forced from the field
(enemy_data_buffer, game_screen = battle), saved as a BlastEm state after its art loads,
and left by loading the next map. Prints each battle's free runs below the font and the
runs free in every battle. Bounded.

    python work/scripts/battleaudit.py [rom]
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, GAME_SCREEN  # noqa
sys.path.insert(0, HERE)
from mapaudit import used_tiles  # noqa  (importing runs nothing: guarded below)

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
PARTY = [int(x) for x in sys.argv[2].split(',')] if len(sys.argv) > 2 else None
out = os.path.join(ROOT, 'work', 'states', 'battles')
MAPS = [0x04, 0x06, 0x0A, 0x0D, 0x0F, 0x00, 0x63, 0x41, 0x03, 0x01, 0x12, 0x10, 0x38, 0x17, 0x1B, 0x1E, 0x11]
FORMATIONS = [0x10, 0x50, 0x90]
BOSSES = [(0x04, 0x100), (0x17, 0x101), (0x63, 0x102), (0x64, 0x103)]
LEVEL, LEVEL_Y, LEVEL_X, CHANGED, ENEMY = 0xFFFFC640, 0xFFFFC642, 0xFFFFC644, 0xFFFFF734, 0xFFFFCB00


def goto_map(em, lvl):
    em.write(LEVEL, lvl.to_bytes(2, 'big'))
    em.write(LEVEL_Y, (0x100).to_bytes(2, 'big'))
    em.write(LEVEL_X, (0x100).to_bytes(2, 'big'))
    em.write(GAME_SCREEN, bytes([0x0C]))
    em.write(CHANGED, (0xFFFF).to_bytes(2, 'big'))
    em.frames(150)


def runs_of(free):
    runs, st, prev = [], None, None
    for t in sorted(free) + [None]:
        if st is not None and (t is None or t != prev + 1):
            if prev - st >= 7:
                runs.append((st, prev))
            st = None
        if t is not None and st is None:
            st = t
        prev = t
    return runs


common = None
with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    jobs = [(m, f) for m in MAPS for f in FORMATIONS] + BOSSES
    if PARTY:                     # a full party: the members' field and battle art too
        jobs = [(m, 0x50) for m in (0x04, 0x0A, 0x38, 0x17, 0x1B, 0x63)] + BOSSES
        em.write(0xFFFFC600, (4).to_bytes(2, 'big'))                         # party_members_num
        em.write(0xFFFFC608, b''.join(p.to_bytes(2, 'big') for p in PARTY))   # party_member_id
    for lvl, formation in jobs:
        goto_map(em, lvl)
        em.write(ENEMY, formation.to_bytes(2, 'big'))
        em.write(GAME_SCREEN, bytes([0x14]))
        em.frames(240)
        path = os.path.join(out, 'b%02X_%03X.state' % (lvl, formation))
        ps2emu.save_state(em, path)
        ref, data = used_tiles(path)
        free = set(t for t in range(0x800) if t not in ref and t not in data)
        common = free if common is None else common & free
        print('map %02X formation %03X screen %02X: free %s' % (
            lvl, formation, em.byte(GAME_SCREEN), ' '.join('%X-%X' % r for r in runs_of(free))), flush=True)
print('free in every battle:', ' '.join('%X-%X(%d)' % (a, b, b - a + 1) for a, b in runs_of(common)))

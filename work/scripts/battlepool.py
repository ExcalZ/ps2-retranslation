"""The battle window pool with the least free party art: Rolf, Rudo, Anna and Hugh leave
19 + 4 + 25 + 26 tiles at the ends of their art blocks (WT_PartyArtTiles), so the pool is
151 tiles. A two-group formation puts up every unstacked window (both enemy names, four
stats windows, the commands); then the item list of 16 long names and Hugh's technique
list, its four pages stacked on it, are forced up. WT_OVERFLOW (runs that found no tiles)
must stay 0. Screenshots in work/analysis/battlepool/. Bounded.

    python work/scripts/battlepool.py [rom] [formation_hex]
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, GAME_SCREEN, WINDOW_DEPTH, WINDOW_INDEX, WINDOW_ACTIVE  # noqa

rom = next((a for a in sys.argv[1:] if a.endswith('.bin')), os.path.join(ROOT, 'ps2en.bin'))
FORMATION = int(next((a for a in sys.argv[1:] if not a.endswith('.bin')), '50'), 16)
out = os.path.join(ps2emu.ANALYSIS, 'battlepool')
os.makedirs(out, exist_ok=True)
SCREEN_BATTLE = 0x14
CHARACTER_INDEX = 0xFFFFDE60
PARTY = (0, 2, 5, 4)                       # Rolf, Rudo, Anna, Hugh
ART_TILES = (109, 95, 124, 93, 102, 103, 102, 93)
LONG_ITEMS = (9, 81, 49, 16, 123, 59, 58, 52, 126, 79, 55, 35, 10, 106, 105, 101)
WT_OVERFLOW, WT_END, WT_HUD_BUMP = 0xFFFF8E30, 0xFFFF8D80, 0xFFFF8E34
POOL = sum(0x80 - ART_TILES[c] for c in PARTY) + 0x23 + 8 + 0x1F + 3


def report(em, name):
    em.shot(os.path.join(out, name + '.png'))
    depth = em.word(WINDOW_DEPTH)
    stack = em.word(WT_END + 2 * (depth - 1)) if depth else 0
    bump = em.word(WT_HUD_BUMP)
    overflow = em.word(WT_OVERFLOW)
    print('%-8s depth %d  stack to %d, unstacked from %d of %d  overflow %d' % (
        name, depth, stack, bump, POOL, overflow), flush=True)
    if overflow:
        raise SystemExit('window text found no tiles at ' + name)


def idle(em):
    for _ in range(60):
        if not em.word(WINDOW_INDEX) and not em.word(WINDOW_ACTIVE):
            return
        em.frames(10)
    raise RuntimeError('windows busy')


with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    rolf = bytearray(em.read(0xFFFFC000, 64))
    rolf[4:6] = rolf[6:8] = (200).to_bytes(2, 'big')          # TP
    for c in PARTY[1:]:
        em.write(0xFFFFC000 + c * 0x40, bytes(rolf))
    em.write(0xFFFFC000 + 4 * 0x40 + 0x25, bytes([14, 10]))   # Hugh's technique counts
    em.write(0xFFFFC027, bytes([len(LONG_ITEMS)]) + bytes(LONG_ITEMS))
    em.write(0xFFFFC600, (len(PARTY) - 1).to_bytes(2, 'big'))
    em.write(0xFFFFC608, b''.join(c.to_bytes(2, 'big') for c in PARTY))
    em.write(0xFFFFCB00, FORMATION.to_bytes(2, 'big'))
    em.write(GAME_SCREEN, bytes([SCREEN_BATTLE]))
    em.frames(330)
    if em.byte(GAME_SCREEN) != SCREEN_BATTLE:
        raise RuntimeError('no battle')
    report(em, 'hud')
    idle(em)
    em.write(CHARACTER_INDEX, (0).to_bytes(2, 'big'))
    em.write(WINDOW_INDEX, (0x67).to_bytes(2, 'big'))         # WinID_BattleItemList
    em.frames(40)
    report(em, 'items')
    for name, page in (('techs1', 0), ('techs2', 4), ('techs3', 8), ('techs4', 12)):
        idle(em)
        em.write(CHARACTER_INDEX, (4).to_bytes(2, 'big'))
        em.write(0xFFFFDEEC, page.to_bytes(2, 'big'))
        em.write(WINDOW_INDEX, (0x66).to_bytes(2, 'big'))     # WinID_BattleTechList
        em.frames(40)
        report(em, name)
print('no overflow')

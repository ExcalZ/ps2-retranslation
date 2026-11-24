"""The battle window pool with the least free party art: Rolf, Rudo, Anna and Hugh leave
19 + 4 + 25 + 26 tiles at the ends of their art blocks (WT_PartyArtTiles), so the pool is
151 tiles. A two-group formation with the widest enemy names puts up every unstacked window
(both names, four stats windows); then, with the buttons a player has, Macro with the
widest lines, a member's item list of 16 long names and full technique list, every page of
each (NEXT redraws the list in place), and Macro again. WT_OVERFLOW (runs that found no
tiles) must stay 0 and the unstacked windows must not take more. Screenshots in
work/analysis/battlepool/. Bounded.

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
FORMATION = int(next((a for a in sys.argv[1:] if not a.endswith('.bin')), '64'), 16)
out = os.path.join(ps2emu.ANALYSIS, 'battlepool')
os.makedirs(out, exist_ok=True)
SCREEN_BATTLE = 0x14
CURSOR, LAST, ROUTINE = 0xFFFFDE50, 0xFFFFDE51, 0xFFFFDE58
HUGH = 4
PARTY = (0, 2, 5, 4)                       # Rolf, Rudo, Anna, Hugh
ART_TILES = (109, 95, 124, 93, 102, 103, 102, 93)
LONG_ITEMS = (0x11, 0x12, 0x11, 0x12, 9, 81, 49, 16, 123, 59, 58, 52, 126, 79, 35, 10)
WT_OVERFLOW, WT_END, WT_HUD_BUMP = 0xFFFF8E30, 0xFFFF8D80, 0xFFFF8E34
POOL = sum(0x80 - ART_TILES[c] for c in PARTY) + 0x23 + 8 + 0x1F + 3


def word(who, cmd, arg):
    return 0x8000 | who << 12 | cmd << 10 | arg << 3


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


def to_entry(em, index):
    for _ in range(12):
        cur = em.read(CURSOR, 1)[0]
        if cur == index:
            return
        em.press('D' if index > cur else 'U', hold=2, release=16)
    raise RuntimeError('the cursor stays at %d, wanted %d' % (em.read(CURSOR, 1)[0], index))


def back_to_menu(em):
    for _ in range(8):
        if em.word(WINDOW_DEPTH) == 1 and not em.word(WINDOW_INDEX) and em.word(ROUTINE) == 2:
            return
        em.press('B', hold=2, release=60)
    raise RuntimeError('the menu never came back (depth %d)' % em.word(WINDOW_DEPTH))


def macro(em, name):
    to_entry(em, 2)
    em.press('C', hold=2, release=60)
    idle(em)
    if em.word(WINDOW_DEPTH) != 3:
        raise RuntimeError('the macro windows are not up (depth %d)' % em.word(WINDOW_DEPTH))
    for slot in range(8):
        to_entry(em, slot)
        em.frames(30)
        report(em, '%s%d' % (name, slot))
    em.press('B', hold=2, release=60)
    idle(em)


with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    rolf = bytearray(em.read(0xFFFFC000, 64))
    rolf[4:6] = rolf[6:8] = (200).to_bytes(2, 'big')          # TP
    for c in PARTY[1:]:
        em.write(0xFFFFC000 + c * 0x40, bytes(rolf))
    for c in PARTY:                                           # every member: full lists
        em.write(0xFFFFC000 + c * 0x40 + 0x25, bytes([14, 10]))
        em.write(0xFFFFC027 + c * 0x40, bytes([len(LONG_ITEMS)]) + bytes(LONG_ITEMS))
    em.write(0xFFFFC600, (len(PARTY) - 1).to_bytes(2, 'big'))
    em.write(0xFFFFC608, b''.join(c.to_bytes(2, 'big') for c in PARTY))
    for k in range(4):                                        # the names six wide letters
        em.write(0xFFFFC660 + 4 * PARTY[k], bytes([33] * 4))
        em.write(0xFFFFC686 + 2 * PARTY[k], bytes([33] * 2))
    wide = [word(c, 2, i) for c, i in zip(PARTY, (9, 81, 58, 35))]
    em.write(0xFFFFC6C0, b''.join(w.to_bytes(2, 'big') for w in [word(c, 0, 0) for c in PARTY] + wide * 7))
    em.write(0xFFFFC698, (0x4D38).to_bytes(2, 'big'))
    em.write(0xFFFFCB00, FORMATION.to_bytes(2, 'big'))
    em.write(GAME_SCREEN, bytes([SCREEN_BATTLE]))
    em.frames(330)
    if em.byte(GAME_SCREEN) != SCREEN_BATTLE:
        raise RuntimeError('no battle')
    em.write(0xFFFFC200 + 2, (900).to_bytes(2, 'big'))
    idle(em)
    report(em, 'hud')
    bump = em.word(WT_HUD_BUMP)
    macro(em, 'macro')
    for steps, kind, pages in ((2, 'items', 5), (1, 'techs', 5)):
        for n in range(4):                                    # Command, Hugh (whoever C picks is checked)
            to_entry(em, 1)
            em.press('C', hold=2, release=60)
            for _ in range(n):
                em.press('R', hold=2, release=20)
            em.press('C', hold=2, release=60)
            if em.word(0xFFFFDE60) == HUGH and em.word(WINDOW_DEPTH):
                break
            back_to_menu(em)
        else:
            raise RuntimeError('Hugh cannot be picked')
        for _ in range(steps):
            em.press('R', hold=2, release=20)
        em.press('C', hold=2, release=60)
        idle(em)
        for n in range(pages):
            report(em, '%s%d' % (kind, n + 1))
            to_entry(em, 0)                                   # NEXT
            em.press('C', hold=2, release=60)
            idle(em)
        back_to_menu(em)
    macro(em, 'macro2')
    if em.word(WT_HUD_BUMP) != bump:
        raise SystemExit('the unstacked windows took more: %d, then %d' % (bump, em.word(WT_HUD_BUMP)))
print('no overflow')

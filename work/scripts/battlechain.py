"""Battle after battle, each one won and left for the field, nothing else drawn there: the
unstacked windows' tiles (WT_HUD) must not be lost from one battle to the next. The party
(Silka, Rudger, Eusis, Anne) stays, the enemies' names grow battle by battle; the last one
is the player's report (Sabocap and Hozuito Deho, Macro slot E). Prints the pool at each
battle's menu; fails if the last battle's differs from the same battle fought first.
Shots in work/analysis/battlechain/. Bounded.

    python work/scripts/battlechain.py [rom]
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, ANALYSIS, GAME_SCREEN, WINDOW_DEPTH, WINDOW_INDEX  # noqa

rom = next((a for a in sys.argv[1:] if a.endswith('.bin')), os.path.join(ROOT, 'ps2en.bin'))
out = os.path.join(ANALYSIS, 'battlechain')
os.makedirs(out, exist_ok=True)
BATTLE, FIELD = 0x14, 0x0C
MAC_DATA, MAC_MAGIC = 0xFFFFC6C0, 0xFFFFC698
FIGHT, CURSOR = 0xFFFFCC02, 0xFFFFDE50
WT_END, WT_HUD, WT_OVERFLOW, WT_HUD_BUMP = 0xFFFF8D80, 0xFFFF8F80, 0xFFFF8E30, 0xFFFF8E34
ART_TILES = (109, 95, 124, 93, 102, 103, 102, 93)
FOUR = [7, 2, 0, 5]                           # Silka, Rudger, Eusis, Anne
# the battle list's first page short, the second the widest
ITEMS = [0x11, 0x12, 0x11, 0x12, 9, 81, 58, 35, 79, 32]


def word(who, cmd, arg=0, target=0):
    return 0x8000 | who << 12 | cmd << 10 | arg << 3 | target


E = [word(2, 2, 79), word(0, 2, 32), word(7, 2, 81), word(5, 2, 9)]
SHORT = [word(c, 0) for c in (2, 0, 7, 5)]
# one party, the names growing pane by pane (a player fighting on), then the report's battle
CHAIN = [(f, FOUR) for f in (0xA6, 0x6C, 0x50, 0x8A, 0x5B, 0xE4, 0x68, 0x62, 0x58, 0x08, 0x4E,
                            0x56, 0x64, 0xB1)]


def pool(em, tag, party):
    size = sum(0x80 - (ART_TILES[party[s]] if s < len(party) else 0) for s in range(4)) + 0x4D
    raw = em.read(WT_HUD, 96)
    hud = [tuple(int.from_bytes(raw[6 * i + j:6 * i + j + 2], 'big') for j in (0, 2, 4)) for i in range(16)]
    depth = em.word(WINDOW_DEPTH)
    print('%-12s stack to %3d, unstacked from %3d of %3d, overflow %d' % (
        tag, em.word(WT_END + 2 * (depth - 1)) if depth else 0, em.word(WT_HUD_BUMP), size,
        em.word(WT_OVERFLOW)), flush=True)
    print('    ' + ' '.join('%04X:%d-%d' % h for h in hud if h[0]), flush=True)
    return em.word(WT_HUD_BUMP)


def idle(em, depth, polls=120):
    for _ in range(polls):
        if em.word(WINDOW_DEPTH) == depth and not em.word(WINDOW_INDEX):
            em.frames(10)
            return
        em.frames(4)
    raise RuntimeError('depth %d never came (%d)' % (depth, em.word(WINDOW_DEPTH)))


def to_entry(em, index):
    for _ in range(12):
        cur = em.read(CURSOR, 1)[0]
        if cur == index:
            return
        em.press('D' if index > cur else 'U', hold=2, release=16)
    raise RuntimeError('cursor %d, wanted %d' % (em.read(CURSOR, 1)[0], index))


def start(em, formation, party, ill=()):
    em.write(0xFFFFC600, (len(party) - 1).to_bytes(2, 'big'))
    em.write(0xFFFFC608, b''.join(c.to_bytes(2, 'big') for c in party))
    for c in range(8):
        em.write(0xFFFFC000 + 64 * c + 2, (999).to_bytes(2, 'big') * 2 + (200).to_bytes(2, 'big') * 2)
    for c in ill:
        em.write(0xFFFFC000 + 64 * c, (em.word(0xFFFFC000 + 64 * c) | 0x4000).to_bytes(2, 'big'))
    em.write(0xFFFFCB00, formation.to_bytes(2, 'big'))
    em.write(GAME_SCREEN, bytes([BATTLE]))
    em.frames(330)
    idle(em, 1)


def win(em):
    """Every enemy to 1 HP, Auto-Combat, and C through the victory, back to the field."""
    to_entry(em, 0)
    em.press('C', hold=2, release=8)
    for _ in range(500):
        if em.byte(GAME_SCREEN) == FIELD:
            em.frames(120)
            return
        for n in range(8):
            if em.word(0xFFFFC200 + n * 64 + 2):
                em.write(0xFFFFC200 + n * 64 + 2, (1).to_bytes(2, 'big'))
        for c in range(8):
            em.write(0xFFFFC000 + 64 * c + 2, (999).to_bytes(2, 'big'))
        if em.word(WINDOW_DEPTH) or em.word(0xFFFFCD10):
            em.press('C', hold=2, release=10)
        else:
            em.frames(10)
    raise RuntimeError('the battle never ended (screen %02X)' % em.byte(GAME_SCREEN))


def letters(em, tag):
    """The slots' letters as the plane shows them: a blank cell ($526) found no tiles."""
    st = ps2emu.save_state(em, os.path.join(out, tag + '.state'))
    import vramaudit
    vram = vramaudit.read_state(st)['vram']
    bad = ''
    for k in range(8):                        # column 16, rows 5, 7.. (as macros.py pool)
        a = 0xE000 + (5 + 2 * k) * 128 + 16 * 2
        if int.from_bytes(vram[a:a + 2], 'big') & 0x7FF == 0x526:
            bad += 'ABCDEFGH'[k]
    print('    letters missing: %s' % (bad or 'none'), flush=True)
    return bad


def page_items(em):
    """Command, the first member, Item, NEXT, and back out with B."""
    to_entry(em, 1)
    em.press('C', hold=2, release=60)         # the member cursor
    em.press('C', hold=2, release=60)         # the first member's commands
    em.press('R', hold=2, release=16)
    em.press('R', hold=2, release=16)         # Item
    em.press('C', hold=2, release=60)
    em.shot(os.path.join(out, 'items1.png'))
    depth = em.word(WINDOW_DEPTH)
    to_entry(em, 0)                           # NEXT
    em.press('C', hold=2, release=60)
    em.shot(os.path.join(out, 'items2.png'))
    print('    items: depth %d, then %d' % (depth, em.word(WINDOW_DEPTH)), flush=True)
    for _ in range(6):
        if em.word(WINDOW_DEPTH) == 1 and not em.word(WINDOW_INDEX) and em.word(0xFFFFDE58) == 2:
            return
        em.press('B', hold=2, release=60)
    raise RuntimeError('the menu never came back (depth %d)' % em.word(WINDOW_DEPTH))


def cure(em):
    """The statuses cured, and a round fought so the stat windows are drawn again."""
    to_entry(em, 0)
    for c in range(8):
        em.write(0xFFFFC000 + 64 * c, (em.word(0xFFFFC000 + 64 * c) & 0xBFFF).to_bytes(2, 'big'))
    em.press('C', hold=2, release=8)
    for n_poll in range(600):
        for c in range(8):
            em.write(0xFFFFC000 + 64 * c + 2, (999).to_bytes(2, 'big'))
        for n in range(8):
            if em.word(0xFFFFC200 + n * 64 + 2):
                em.write(0xFFFFC200 + n * 64 + 2, (900).to_bytes(2, 'big'))
        if not em.word(FIGHT) and em.word(WINDOW_DEPTH) == 1 and not em.word(WINDOW_INDEX):
            em.frames(10)
            return
        em.press('B', hold=30, release=10) if n_poll % 4 == 0 else em.frames(10)
    em.shot(os.path.join(out, 'cure_stuck.png'))
    raise RuntimeError('the menu never came back (depth %d index %04X fight %d routine %d main %d)' % (
        em.word(WINDOW_DEPTH), em.word(WINDOW_INDEX), em.word(FIGHT), em.word(0xFFFFDE58),
        em.read(0xFFFFCC00, 1)[0]))


def macro_e(em, tag, party):
    to_entry(em, 2)
    em.press('C', hold=2, release=40)
    idle(em, 3)
    to_entry(em, 4)
    em.frames(30)
    em.shot(os.path.join(out, tag + '.png'))
    pool(em, tag + ' E', party)
    bad = letters(em, tag)
    em.press('B', hold=2, release=40)
    idle(em, 1)
    return bad


def setup(em):
    ps2emu.boot_to_field(em)
    base = bytearray(em.read(0xFFFFC000, 64))
    for c in range(8):
        em.write(0xFFFFC000 + 64 * c, bytes(base))
        em.write(0xFFFFC027 + 64 * c, bytes([len(ITEMS)] + ITEMS))
    em.write(MAC_DATA, b''.join(w.to_bytes(2, 'big')
                                for m in [SHORT] * 4 + [E] + [[0] * 4] * 3 for w in m))
    em.write(MAC_MAGIC, (0x4D38).to_bytes(2, 'big'))


with PS2(rom) as em:                                  # the last battle, fought first
    setup(em)
    start(em, *CHAIN[-1])
    alone = pool(em, 'alone', FOUR)
    macro_e(em, 'alone', FOUR)
with PS2(rom) as em:
    setup(em)
    for k, (formation, party) in enumerate(CHAIN[-1:] if 'short' in sys.argv else CHAIN):
        ill = party[:3] if formation == 0xB1 else ()
        start(em, formation, party, ill)
        bump = pool(em, '%d: %02X' % (k, formation), party)
        if formation != 0xB1:
            win(em)
    bad = macro_e(em, 'last', FOUR)
    cure(em)
    after = pool(em, 'cured', FOUR)
    page_items(em)
    paged = pool(em, 'paged', FOUR)
    bad += macro_e(em, 'last2', FOUR)
    print('unstacked from %d when fought first, %d, cured %d, after the item list %d' % (
        alone, bump, after, paged))
    if bad or len({alone, bump, after, paged}) > 1:
        raise SystemExit('tiles were lost%s' % (', letters ' + bad if bad else ''))
print('the pool is the same after %d battles' % len(CHAIN))

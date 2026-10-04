"""The battle box's unstacked windows under vwf_windows (window_index bit 2): the enemy-name
window must keep its tiles while the battle options window is redrawn as Tactics (Orders /
Retreat, BattleOptions2, drawn at the same place as FIGHT/STGY), through Orders, a
character's commands, a technique list and a round. Every step is cursor- or depth-checked
and every loop is bounded.

    python work/scripts/tacticswin.py [rom] [round]
Prints the unstacked-window table (WT_HUD: place, bottom-top indices) and the stack's ends at each
step; shots in work/analysis/tacticswin/.
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, ANALYSIS, GAME_SCREEN, WINDOW_DEPTH, WINDOW_INDEX  # noqa

rom = next((a for a in sys.argv[1:] if a.endswith('.bin')), os.path.join(ROOT, 'ps2en.bin'))
ROUND = 'round' in sys.argv[1:]
tag = 'stock_' if 'original' in rom else os.path.splitext(os.path.basename(rom))[0] + '_'
out = os.path.join(ANALYSIS, 'tacticswin')
os.makedirs(out, exist_ok=True)
SCREEN_BATTLE = 0x14
CURSOR = 0xFFFFDE50
WT_HUD = 0xFFFF8F80                # 16 x (place, top, bottom)
WT_HUD_BUMP = 0xFFFF8E34
WT_END = 0xFFFF8D80
WT_OVERFLOW = 0xFFFF8E30


def state(em, name):
    try:
        em.shot(os.path.join(out, tag + name + '.png'))
    except FileNotFoundError:
        pass  # BlastEm quicksave can fail while stopped at the GDB breakpoint.
    objects = em.read(0xFFFFE000, 16 * 64)
    cursors = [(i, objects[i * 64 + 2], objects[i * 64 + 3]) for i in range(16) if objects[i * 64:i * 64 + 2] == bytes([0, 4])]
    print("battle cursor", cursors, "event", em.word(0xFFFFDE58), "saved", em.word(0xFFFFDE54), flush=True)
    if name in ('2orders', '3commands', '4techlist', '5back0', '5back1'):
        if not cursors or any((flags & 2) == 0 for _, flags, _ in cursors):
            raise RuntimeError('battle options cursor is visible over a submenu')
    hud = em.read(WT_HUD, 96)
    w = [int.from_bytes(hud[i:i + 2], 'big') for i in range(0, 96, 2)]
    rows = ['%04X:%d-%d' % (w[i], w[i + 2], w[i + 1]) for i in range(0, 48, 3) if w[i]]
    ends = [int.from_bytes(em.read(WT_END + 2 * n, 2), 'big') for n in range(4)]
    print('%-9s depth %d index %04X cursor %s overflow %d bump %d ends %s hud %s'
          % (name, em.word(WINDOW_DEPTH), em.word(WINDOW_INDEX), list(em.read(CURSOR, 2)),
             em.word(WT_OVERFLOW), em.word(WT_HUD_BUMP), ends, ' '.join(rows)), flush=True)


def settle(em, tries=30):
    """Wait (bounded) until no window is being opened or closed."""
    for _ in range(tries):
        if not em.word(WINDOW_INDEX):
            em.frames(20)
            return
        em.frames(10)
    raise RuntimeError('windows busy (%04X)' % em.word(WINDOW_INDEX))


def pick_across(em, index, tries=8):
    """The command window's icons run left to right: R/L to entry `index`, then C."""
    for _ in range(tries):
        cur = em.read(CURSOR, 1)[0]
        if cur == index:
            em.press('C', hold=2, release=40)
            return
        em.press('R' if index > cur else 'L', hold=2, release=12)
    raise RuntimeError('the command cursor stays at %d, wanted %d' % (em.read(CURSOR, 1)[0], index))


def need_depth(em, depth):
    if em.word(WINDOW_DEPTH) != depth:
        raise RuntimeError('expected %d windows up, found %d' % (depth, em.word(WINDOW_DEPTH)))


with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    em.write(0xFFFFC025, bytes([3, 3]))                       # techniques
    em.write(0xFFFFCB00, (1).to_bytes(2, 'big'))              # enemy group 1
    em.write(GAME_SCREEN, bytes([SCREEN_BATTLE]))
    em.frames(330)
    if em.byte(GAME_SCREEN) != SCREEN_BATTLE:
        raise RuntimeError('no battle')
    settle(em)
    need_depth(em, 0)
    state(em, '0start')
    if em.read(CURSOR + 1, 1)[0] != 1:
        raise RuntimeError('the battle options list is not up')
    ps2emu.pick(em, 1)                       # STGY: the Orders / Retreat window
    settle(em)
    need_depth(em, 0)
    state(em, '1tactics')
    if ROUND:
        # B back to FIGHT / STGY, then FIGHT: a round with the default commands
        em.press('B', hold=2, release=40)
        settle(em)
        state(em, '2back')
        ps2emu.pick(em, 0)
        for n in range(12):
            em.frames(40)
            state(em, '3round%02d' % n)
        sys.exit()
    ps2emu.pick(em, 0)                       # Orders: the triangle cursor over the party
    settle(em)
    state(em, '2orders')
    em.press('C', hold=2, release=40)        # the first character: name and commands
    settle(em)
    need_depth(em, 2)
    state(em, '3commands')
    pick_across(em, 1)                       # TECH
    settle(em)
    need_depth(em, 3)
    state(em, '4techlist')
    for n in range(3):                       # B back down to the commands, then the party
        em.press('B', hold=2, release=40)
        settle(em)
        state(em, '5back%d' % n)
        if em.word(WINDOW_DEPTH) == 0:
            break
    em.press('B', hold=2, release=40)
    settle(em)
    state(em, '6options')
    phases = []
    for _ in range(20):
        em.frames(1)
        phases.append(em.byte(0xFFFFE002))
    print('restored cursor phases', phases, flush=True)
    if not any((flag & 2) == 0 for flag in phases):
        raise RuntimeError('battle options cursor never reappeared')

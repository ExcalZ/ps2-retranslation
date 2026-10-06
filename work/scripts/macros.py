"""battle_macros: the battle menu (Auto-Combat, Command, Macro, Retreat) and the macro
panel, with four macros written into RAM. Bounded: every press is followed by a check of
the window depth or the cursor, and the scenario raises instead of pressing on.

    python work/scripts/macros.py [rom] [battle|pool|use SLOT|retreat|command|field]

battle  the menu, Macro, each slot A-E filmed (A white, B white, C amber: Amy is not in
        the party and Nei is left out, D amber: Rolf lacks the TP, E-H red), B back
pool    the smallest window pool (Rolf, Rudger, Hugh, Anne) against four of the widest
        items: the tile ranges, the letters' colours read from VRAM, the window runs
use N   Macro, slot N (0-3) used: prints the commands the party was given
retreat Retreat; command: Command, Rolf, Defend, then the menu again
back    Command, Rolf, B on his commands: the member cursor again (no fight), B: the menu
full    as field, with the window runs' table first filled with leftovers of closed
        windows (a long session): the slots' letters must all be drawn
field   Start's menu > Macro: a macro set from nothing and saved, then the erase question
Shots in work/analysis/macros/.
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, ANALYSIS, GAME_SCREEN, WINDOW_DEPTH  # noqa

args = sys.argv[1:]
rom = next((a for a in args if a.endswith('.bin')), os.path.join(ROOT, 'ps2en.bin'))
args = [a for a in args if not a.endswith('.bin')] or ['battle']
mode = args[0]
out = os.path.join(ANALYSIS, 'macros')
os.makedirs(out, exist_ok=True)

ENEMY_DATA = 0xFFFFCB00
SCREEN_BATTLE = 0x14
MAC_DATA = 0xFFFFC6C0
MAC_MAGIC = 0xFFFFC698
COMMANDS = 0xFFFFCC10            # char_battle_command_index: 16 bytes a character
EVENT_ROUTINE = 0xFFFFDE58
SAVED = 0xFFFFDE54               # window_index_saved
FIGHT = 0xFFFFCC02
MAIN_ROUTINE = 0xFFFFCC00
CURSOR = 0xFFFFDE50


def word(who, cmd, arg=0, target=0):
    return 0x8000 | who << 12 | cmd << 10 | arg << 3 | target


ROLF, NEI, AMY = 0, 1, 3
MACROS = [
    [word(ROLF, 0), word(NEI, 3)],                                  # A: Attack, Defend
    [word(ROLF, 2, 0x11, NEI), word(NEI, 1, 1)],                    # B: Monomate for Nei, Foie
    [word(ROLF, 0), word(AMY, 3)],                                  # C: Amy is not here, Nei left out
    [word(ROLF, 1, 2), word(NEI, 0)],                               # D: Gifoie, Rolf at 1 TP
]


def shot(em, name):
    em.shot(os.path.join(out, name + '.png'))


def state(em):
    return 'depth %d routine %d saved $%02X cursor %d' % (
        em.word(WINDOW_DEPTH), em.word(EVENT_ROUTINE), em.word(SAVED), em.read(CURSOR, 1)[0])


def wait_depth(em, depth, frames=240):
    for _ in range(frames // 4):
        if em.word(WINDOW_DEPTH) == depth and em.word(0xFFFFDE10) == 0:
            em.frames(10)
            return
        em.frames(4)
    raise RuntimeError('the windows never reached depth %d (%s)' % (depth, state(em)))


def press(em, b, settle=24):
    em.press(b, hold=2, release=settle)


def to_entry(em, index, tries=12):
    """Move the top list's cursor to `index` with Up/Down, checking after each press."""
    for _ in range(tries):
        cur = em.read(CURSOR, 1)[0]
        if cur == index:
            return
        press(em, 'D' if index > cur else 'U', 16)
    raise RuntimeError('the cursor stays at %d, wanted %d' % (em.read(CURSOR, 1)[0], index))


def expect(em, depth, what):
    wait_depth(em, depth)
    shot(em, what)
    print('%-12s %s' % (what, state(em)), flush=True)


def field(em):
    """Start's menu > Macro: slot E (empty) set to Rolf: Monomate for Nei, Nei: Defend,
    saved; then slot A (set): C asks to erase it, B is No; B, B close."""
    ps2emu.open_menu(em)
    expect(em, 3, 'f_menu')
    to_entry(em, 4)
    press(em, 'C', 30)
    expect(em, 5, 'f_slots')
    to_entry(em, 4)
    em.frames(20)
    shot(em, 'f_slotE')
    press(em, 'C', 30)
    expect(em, 6, 'f_members')
    to_entry(em, 0)
    press(em, 'C', 30)
    expect(em, 7, 'f_commands')
    to_entry(em, 2)
    press(em, 'C', 30)
    expect(em, 8, 'f_items')
    press(em, 'C', 30)                                             # the Monomate
    expect(em, 9, 'f_target')
    to_entry(em, 1)                                                # for Nei
    press(em, 'C', 30)
    expect(em, 6, 'f_members2')
    press(em, 'C', 30)                                             # Nei
    expect(em, 7, 'f_commands2')
    to_entry(em, 3)                                                # Defend
    press(em, 'C', 30)
    for _ in range(60):                                            # the question, then Yes/No
        if em.word(WINDOW_DEPTH) == 7 and em.word(0xFFFFDE10) == 0 and em.word(SAVED):
            break
        em.frames(5)
    else:
        raise RuntimeError('no Yes/No (%s)' % state(em))
    em.frames(10)
    shot(em, 'f_setq')
    print('%-12s %s' % ('f_setq', state(em)))
    to_entry(em, 0)                                                # Yes
    press(em, 'C', 30)
    expect(em, 5, 'f_saved')
    print('slot E', em.read(MAC_DATA + 4 * 8, 8).hex())
    to_entry(em, 0)
    em.frames(20)
    press(em, 'C', 30)                                             # A: set, so the question
    for _ in range(60):
        if em.word(WINDOW_DEPTH) == 7 and em.word(0xFFFFDE10) == 0 and em.word(SAVED):
            break
        em.frames(5)
    else:
        raise RuntimeError('no Yes/No (%s)' % state(em))
    em.frames(10)
    shot(em, 'f_eraseq')
    press(em, 'B', 30)                                             # No
    expect(em, 5, 'f_kept')
    print('slot A', em.read(MAC_DATA, 8).hex())
    press(em, 'B', 30)
    expect(em, 3, 'f_menu_again')
    press(em, 'B', 30)
    expect(em, 0, 'f_closed')


if mode == 'pool':
    # the window pool at its smallest (Rolf, Rudger, Hugh, Anne: the party art the
    # largest) against the longest view: four members not in the party with the widest
    # items, then three of the party left out (seven lines)
    PARTY = [0, 2, 4, 5]
    MACROS = [[word(1, 2, 9), word(3, 2, 81), word(6, 2, 58), word(7, 2, 35)]] + MACROS[1:]

with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    if mode == 'pool':
        em.write(0xFFFFC600, (len(PARTY) - 1).to_bytes(2, 'big'))
        em.write(0xFFFFC608, b''.join(c.to_bytes(2, 'big') for c in PARTY))
    data = b''.join(b''.join(w.to_bytes(2, 'big') for w in (m + [0] * 4)[:4]) for m in MACROS)
    em.write(MAC_DATA, data + bytes(64 - len(data)))
    em.write(MAC_MAGIC, (0x4D38).to_bytes(2, 'big'))
    em.write(0xFFFFC006, (1).to_bytes(2, 'big'))                    # Rolf: 1 TP
    em.write(0xFFFFC027, bytes([2, 0x11, 0x12]))                    # Rolf: Monomate, Dimate
    if mode == 'full':
        # 48 runs over the item list's art, a window not up (as a long session leaves them)
        em.write(0xFFFF8C00, b''.join((0x805F + 26 * k).to_bytes(2, 'big') + bytes([10, 1]) +
                                      (0x12D68).to_bytes(4, 'big') for k in range(48)))
    if mode == 'full':
        ps2emu.open_menu(em)
        to_entry(em, 4)
        press(em, 'C', 30)
        expect(em, 5, 'full_slots')
        if True:                                                   # the letters' runs
            runs = em.read(0xFFFF8C00, 48 * 8)
            arts = [int.from_bytes(runs[8 * k:8 * k + 2], 'big') for k in range(48)]
            letters = [a for a in arts if a and (a - 0x87DF) % 6 == 5 and 0x87DF <= a < 0x87DF + 51]
            print('letter runs %d of 8, free entries %d' % (len(letters), arts.count(0)))
            if len(letters) != 8:
                raise SystemExit('slot letters without a run')
        sys.exit(0)
    if mode == 'field':
        field(em)
        sys.exit(0)
    formation = 1
    if mode == 'boss':                                             # boss FORMATION MAP (hex)
        formation, level = int(args[1], 16), int(args[2], 16)
        em.write(0xFFFFC640, level.to_bytes(2, 'big'))             # the boss's map first
        em.write(0xFFFFC642, (0x100).to_bytes(2, 'big'))
        em.write(0xFFFFC644, (0x100).to_bytes(2, 'big'))
        em.write(GAME_SCREEN, bytes([0x0C]))
        em.write(0xFFFFF734, (0xFFFF).to_bytes(2, 'big'))
        em.frames(150)
    em.write(ENEMY_DATA, formation.to_bytes(2, 'big'))
    em.write(GAME_SCREEN, bytes([SCREEN_BATTLE]))
    em.frames(330)
    wait_depth(em, 1)
    shot(em, 'menu')
    print('menu', state(em))
    if mode == 'retreat':
        to_entry(em, 3)
        press(em, 'C', 60)
        print('retreat', state(em), 'main routine', em.read(MAIN_ROUTINE, 1)[0])
        em.frames(120)
        shot(em, 'retreat')
        sys.exit(0)
    if mode == 'back':
        to_entry(em, 1)
        press(em, 'C', 60)                                         # Command: the member cursor
        press(em, 'C', 60)                                         # Rolf: his commands
        print('commands', state(em))
        press(em, 'B', 60)                                         # back
        em.frames(30)
        shot(em, 'back_who')
        print('after B', state(em), 'fight', em.word(FIGHT))
        if em.word(FIGHT) or em.word(EVENT_ROUTINE) != 4:
            raise SystemExit('B on the commands did not go back to the member cursor')
        press(em, 'B', 60)
        wait_depth(em, 1)
        shot(em, 'back_menu')
        print('after B again', state(em), 'fight', em.word(FIGHT))
        sys.exit(0)
    if mode == 'command':
        to_entry(em, 1)
        press(em, 'C', 60)
        print('command', state(em))
        shot(em, 'command_who')
        press(em, 'C', 60)                                         # the first member
        shot(em, 'command_cmds')
        print('commands', state(em))
        for _ in range(3):
            press(em, 'R', 16)                                     # Defend
        press(em, 'C', 60)
        wait_depth(em, 1)
        shot(em, 'command_back')
        print('back', state(em), 'menu cursor', em.read(CURSOR, 1)[0])
        print('Rolf', em.read(COMMANDS, 6).hex(), 'Nei', em.read(COMMANDS + 16, 6).hex())
        sys.exit(0)
    to_entry(em, 2)
    press(em, 'C', 40)
    wait_depth(em, 3)
    shot(em, 'slots_A')
    print('slots', state(em), 'overflow', em.word(0xFFFF8E30))
    if mode == 'boss':
        for n in range(4):                                         # the boss moves under the windows
            em.frames(30)
            shot(em, 'boss%X_slots_%d' % (formation, n))
        press(em, 'B', 40)
        wait_depth(em, 1)
        shot(em, 'boss%X_menu' % formation)
        print('boss', state(em), 'overflow', em.word(0xFFFF8E30))
        sys.exit(0)
    if mode == 'pool':
        print('WT_END', em.read(0xFFFF8D80, 8).hex(), 'HUD bump %d' % em.word(0xFFFF8E34))
        for k, letter in enumerate('BA'):
            to_entry(em, 1 - k)
            em.frames(20)
            shot(em, 'pool_' + letter)
            print(letter, state(em), 'overflow', em.word(0xFFFF8E30))
        st = ps2emu.save_state(em, os.path.join(out, 'pool.state'))
        import vramaudit
        vram = vramaudit.read_state(st)['vram']
        for k in range(8):                                         # the letters: column 16, rows 5, 7..
            a = 0xE000 + (5 + 2 * k) * 128 + 16 * 2
            cell = int.from_bytes(vram[a:a + 2], 'big')
            tile = vram[(cell & 0x7FF) * 32:(cell & 0x7FF) * 32 + 32]
            print('letter %s cell %04X colours %s' % ('ABCDEFGH'[k], cell,
                  sorted(set(n for b in tile for n in (b >> 4, b & 15)))))
        runs = em.read(0xFFFF8C00, 48 * 8)                         # WT_RUNS: art, cells, kind, data
        for k in range(48):
            e = runs[8 * k:8 * k + 8]
            if e[0] or e[1]:
                print('run %2d art $%04X cells %d kind $%02X data %s' % (
                    k, int.from_bytes(e[:2], 'big'), e[2], e[3], e[4:].hex()))
        sys.exit(0)
    if mode == 'battle':
        for k, letter in enumerate('BCDE', 1):
            to_entry(em, k)
            em.frames(20)
            shot(em, 'slots_' + letter)
            print(letter, state(em), 'overflow', em.word(0xFFFF8E30))
        press(em, 'B', 40)
        wait_depth(em, 1)
        shot(em, 'slots_back')
        print('back', state(em))
        sys.exit(0)
    if mode == 'use':
        slot = int(args[1])
        to_entry(em, slot)
        em.frames(20)
        press(em, 'C', 6)
        for _ in range(60):
            if em.word(FIGHT):
                break
            em.frames(2)
        print('used', state(em), 'fight', em.word(FIGHT))
        print('Rolf', em.read(COMMANDS, 6).hex(), 'Nei', em.read(COMMANDS + 16, 6).hex())
        for n in range(6):
            em.frames(20)
            shot(em, 'use%d_%d' % (slot, n))

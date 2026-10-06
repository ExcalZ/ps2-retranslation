"""The plates an item and a technique show in battle, against the damage pop-up.

    python work/scripts/itemplate.py [rom] [--shots]

--shots films each frame from a cast's impact to its pop-up.

One round of a forced fight: Eusis uses a Monomate on Eusis (an item that casts RES)
and Nei casts RES on herself, both hurt. Each frame of the round is traced: the plate's
builder (Win_BattleItemUsed / Win_BattleTechUsed), the $F3 cast cue, the $FD impact, the
window depth and the party pop-up timers. Prints, for each action, the frame the cast cue
opened its plate, the impact, the frame the plate closed (the depth falls) and the frame
its pop-up opened, and checks that the plate is up through the cast and gone before the
result shows. Bounded: 900 frames at most, and it stops when the round is over.
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, ANALYSIS, GAME_SCREEN, WINDOW_DEPTH  # noqa

rom = next((a for a in sys.argv[1:] if a.endswith('.bin')), os.path.join(ROOT, 'ps2en.bin'))
SHOTS = '--shots' in sys.argv
out = os.path.join(ANALYSIS, 'itemplate')
os.makedirs(out, exist_ok=True)
CHAR = 0xFFFFC000
COMMANDS = 0xFFFFCC10         # char_battle_command_index: command, argument, target
COMMAND_USED = 0xFFFFCC0E
POP = 0xFFFF8F00              # damage_popups: 9 slots of 8 bytes, the party's from 5
MONOMATE, RES = 0x11, 0x27
SCREEN_BATTLE = 0x14
stock = 'original' in rom


def addr(label, after=None):
    try:
        return ps2emu.listing_address(label, after)
    except Exception:
        return None


with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    for c, top in ((0, 200), (1, 200)):
        em.write(CHAR + 64 * c + 2, (60).to_bytes(2, 'big') + top.to_bytes(2, 'big'))
        em.write(CHAR + 64 * c + 6, (40).to_bytes(2, 'big') * 2)
    inv = bytes(em.read(CHAR + 0x28, 3))           # keep the equipment
    em.write(CHAR + 0x27, bytes([4]) + inv + bytes([MONOMATE]))
    em.write(0xFFFFCB00, (1).to_bytes(2, 'big'))
    em.write(GAME_SCREEN, bytes([SCREEN_BATTLE]))
    em.frames(330)
    if em.byte(GAME_SCREEN) != SCREEN_BATTLE:
        raise RuntimeError('no battle')
    names = {'Win_BattleItemUsed': 'item plate built', 'Win_BattleTechUsed': 'tech plate built',
             'Popup_Impact': 'impact $FD'}
    bps = {}
    for label in names:
        a = addr(label)
        if a is not None:
            bps[a] = names[label]
            em.breakpoint(a)
    cast = addr('loc_35DE')
    if cast is not None:
        em.breakpoint(cast)
    events = []

    def hook(pc):
        if pc == cast:
            if em.regs()['d'][0] & 0xFF == 0xF3:
                events.append((em.frame, 'cast $F3 (command %d)' % em.word(COMMAND_USED)))
        elif pc in bps:
            events.append((em.frame, bps[pc]))

    em.write(COMMANDS, bytes([0, 2, 0, MONOMATE, 0, 0]))       # Eusis: Monomate on Eusis
    em.write(COMMANDS + 16, bytes([0, 1, 0, RES, 0, 1]))       # Nei: RES on Nei
    em.press('C', hold=2, release=2)                           # FIGHT
    depth = em.word(WINDOW_DEPTH)
    timers = [0, 0]
    start = em.frame
    quiet = 0
    for n in range(900):
        em.write(COMMANDS, bytes([0, 2, 0, MONOMATE, 0, 0]))
        em.write(COMMANDS + 16, bytes([0, 1, 0, RES, 0, 1]))
        em.step_frame(hook)
        d = em.word(WINDOW_DEPTH)
        if d != depth:
            events.append((em.frame, 'depth %d -> %d' % (depth, d)))
            depth = d
        if not stock:
            for i in (0, 1):
                t = em.word(POP + (5 + i) * 8) & 0x7FFF
                if t and not timers[i]:
                    events.append((em.frame, 'pop-up %d opens (HP %d)' % (i, em.word(CHAR + 64 * i + 2))))
                if timers[i] and not t:
                    events.append((em.frame, 'pop-up %d closed' % i))
                timers[i] = t
        # --shots: every frame from an impact that follows a cast to its pop-up and after
        last = [w for f, w in events if f > em.frame - 14]
        if SHOTS and any('impact' in w for w in last) and any('cast' in w for f, w in events
                                                               if f > em.frame - 120):
            em.shot(os.path.join(out, '%sf%03d.png' % ('stock_' if stock else '', em.frame - start)))
        # the round is over once the command window is back (depth as before FIGHT) for a while
        quiet = quiet + 1 if em.word(COMMAND_USED) == 0xFFFF and d <= 1 else 0
        if n > 120 and quiet > 90:
            break
    for f, what in events:
        print('%4d  %s' % (f - start, what))
    print('HP', em.word(CHAR + 2), em.word(CHAR + 66))

    if not stock:
        casts = 0
        for k, (f, what) in enumerate(events):
            if not what.startswith('cast'):
                continue
            later = events[k + 1:]
            impact = next((g for g, w in later if w.startswith('impact')), None)
            close = next((g for g, w in later if w == 'depth 1 -> 0'), None)
            popup = next((g for g, w in later if 'opens' in w), None)
            if None in (impact, close, popup):
                continue                    # the round ended first
            assert impact <= close < popup, 'cast at %d: impact %d, plate closed %d, pop-up %d' % (
                f - start, impact - start, close - start, popup - start)
            casts += 1
        assert casts >= 2, 'too few casts seen'
        print('ok: %d casts, each plate closed after its impact and before its pop-up' % casts)

"""The battle's top row (battle_name_panes): the enemy name panes opened at the battle
start. With one enemy group only the left pane opens; with two, both. For each
formation: a forced battle, the name panes' draws counted at their window routines
(the battle's windows are not stacked: $DE04 stays 0), checked against the formation's
groups, and a shot once the panes are up (work/analysis/battlenames/). The two routines
are in the stock image, so the stock ROM can be run for comparison (it draws both).

    python work/scripts/battlenames.py [rom] [formation ...]   (default 9 1 8: one
    enemy, one group of three, two groups)
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa: E402
from ps2emu import PS2, GAME_SCREEN  # noqa: E402

args = sys.argv[1:]
rom = args.pop(0) if args and not args[0].isdigit() else os.path.join(ROOT, 'ps2en.bin')
formations = [int(a) for a in args] or [9, 1, 8]
out = os.path.join(ps2emu.ANALYSIS, 'battlenames')
os.makedirs(out, exist_ok=True)
SCREEN_BATTLE = 0x14
FORMATION = 0xFFFFCB00
SECOND_COUNT = 0xFFFFCB14          # enemy_data_buffer+$14: the second group's count - 1
NAME_ROUTINES = ('Win_FirstEnemyName', 'Win_SecondEnemyName')
tag = os.path.splitext(os.path.basename(rom))[0]
failed = []

for f in formations:
    with PS2(rom) as em:
        ps2emu.boot_to_field(em)
        em.write(FORMATION, f.to_bytes(2, 'big'))
        em.write(GAME_SCREEN, bytes([SCREEN_BATTLE]))
        routines = {ps2emu.listing_address(n): n for n in NAME_ROUTINES}
        for addr in routines:
            em.breakpoint(addr)
        drawn = []

        def hook(pc):
            if pc in routines and not em.regs()['d'][1] & 0xFF:   # d1.b 0: the draw
                drawn.append(routines[pc])

        for n in range(330):
            em.step_frame(hook)
        if em.byte(GAME_SCREEN) != SCREEN_BATTLE:
            raise RuntimeError('formation %d: no battle' % f)
        two = em.word(SECOND_COUNT) < 0x8000
        want = list(NAME_ROUTINES) if two else [NAME_ROUTINES[0]]
        shot = os.path.join(out, '%s_f%03d.png' % (tag, f))
        em.shot(shot)
        ok = drawn == want
        print('formation %3d: %s group(s), drawn %s -> %s  %s' % (
            f, 2 if two else 1, ' '.join(drawn) or 'none', 'ok' if ok else 'WRONG', shot),
            flush=True)
        if not ok:
            failed.append(f)

if failed:
    raise SystemExit('wrong name panes in formation(s) %s' % failed)

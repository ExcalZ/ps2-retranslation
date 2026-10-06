"""Saving and continuing under long_names / vwf_windows: in the Data Memory (building 2)
save to slot 1 under a typed file name, keep BlastEm's SRAM, then boot with it and open
CONTINUE on the title - the game select with the file. Screenshots each step. Bounded.

    python work/scripts/savegame.py [rom] [file name] [--continue]
--continue skips the save and boots with the SRAM kept by the last run; HERO=name in the
environment names the hero (six letters test the saved letters 5-6). MACROS=1 writes
two macros (battle_macros) before saving and prints them after CONTINUE.
"""
import os
import shutil
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, ANALYSIS, GAME_SCREEN, SCREEN_TITLE  # noqa

CONT = '--continue' in sys.argv
args = [a for a in sys.argv[1:] if not a.startswith('--')]
rom = args.pop(0) if args and args[0].endswith('.bin') else os.path.join(ROOT, 'ps2en.bin')
fname = args[0] if args else 'SAVE'
tag = 'stock_' if 'original' in rom else ''
out = os.path.join(ANALYSIS, 'savegame')
keep = os.path.join(ROOT, 'work', 'states', 'harness', tag + 'saved.sram')
MACROS = os.environ.get('MACROS') == '1'
MACRO_BYTES = bytes.fromhex('80009c00000000008889940800000000')     # A: Attack, Defend; B: Monomate, Foie

if not CONT:
    with PS2(rom) as em:
        ps2emu.boot_to_field(em, os.environ.get('HERO', 'AAAA'))
        if MACROS:
            em.write(0xFFFFC6C0, MACRO_BYTES)
            em.write(0xFFFFC698, (0x4D38).to_bytes(2, 'big'))
        em.write(0xFFFFF760, (2).to_bytes(2, 'big'))       # the Data Memory
        em.write(GAME_SCREEN, bytes([0x10]))
        em.frames(200)
        ps2emu.run_steps(em, 'C,w,C,w,C,w,C,w,C,w,0'.split(','), out, tag + 's')
        ps2emu.wait_for_naming(em, tries=4)
        for ch in fname.upper():
            r = next(i for i, g in enumerate(ps2emu.GRID) if ch in g)
            ps2emu._cursor_to(em, r * 17 + ps2emu.GRID[r].index(ch) * 2)
            em.press('C', hold=2, release=12)
        em.shot(os.path.join(out, tag + 'typed.png'))
        ps2emu._cursor_to(em, 0x3F)
        em.press('C', hold=2, release=40)
        ps2emu.run_steps(em, 'w,w,C,w,C,w'.split(','), out, tag + 'd')
        harness = em.rom
        em.quit_saving()
    # BlastEm writes the SRAM when it exits, beside its other saves for this ROM name
    sram = os.path.join(os.environ['LOCALAPPDATA'], 'blastem',
                        os.path.splitext(os.path.basename(harness))[0], 'save.sram')
    if not os.path.exists(sram):
        raise SystemExit('no SRAM written (%s)' % sram)
    shutil.copyfile(sram, keep)
    data = open(keep, 'rb').read()
    print('sram %d bytes, nonzero %d' % (len(data), sum(1 for b in data if b)))

with PS2(rom, sram=keep) as em:
    for _ in range(100):
        if em.word(GAME_SCREEN) == SCREEN_TITLE:
            break
        em.frames(10)
    else:
        raise SystemExit('no title screen')
    em.frames(60)
    em.press('S', release=60)
    if not MACROS:
        ps2emu.run_steps(em, 'w,w,C,w,C,w,1,w,0,w,w,w'.split(','), out, tag + 't')
    else:
        # title_save_menu: Continue is the first entry; then the file, then the field
        for _ in range(12):                                  # as titlemenu.py: C until the menu is up
            if em.word(0xFFFFDE54) == 0x37 and em.word(ps2emu.WINDOW_DEPTH):
                break
            if em.word(ps2emu.WINDOW_INDEX) & 0xFF == 0x37:
                em.frames(10)
            else:
                em.press('C', hold=2, release=40)
        else:
            raise SystemExit('the title menu never opened')
        em.frames(45)
        em.press('C', hold=2, release=60)                    # Continue a Game
        em.shot(os.path.join(out, 'm_files.png'))
        em.press('C', hold=2, release=60)                    # the first file
        for _ in range(60):
            if em.word(GAME_SCREEN) in (0x0C00, 0x1000) and not em.word(ps2emu.WINDOW_INDEX):   # the field, or the Data Memory
                break
            em.frames(10)
        else:
            raise SystemExit('the saved game never loaded (screen %04X)' % em.word(GAME_SCREEN))
        em.frames(60)
        em.shot(os.path.join(out, 'm_loaded.png'))
    if MACROS:
        got = em.read(0xFFFFC6C0, 16)
        print('macros after CONTINUE: %s magic %04X -> %s' % (got.hex(), em.word(0xFFFFC698),
              'ok' if got == MACRO_BYTES else 'LOST'))

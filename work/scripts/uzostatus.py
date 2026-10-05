"""The owner's slot 2: on Uzo Mountain the status screen's portrait palette (line 1)
recoloured the mist layer, which the map draws in plane A in line 1 too. For each map
given, the game is booted, the map loaded, and Status > Status > the first member opened,
then its techniques, then every window closed. Savestates are taken before the menu, on
the status screen and after: on the status screen no plane A map cell may be left in
line 1, and after closing plane A must equal the one before the menu, cell for cell.
Every wait is bounded.

    python work/scripts/uzostatus.py [rom] [level:y:x ...]

The default maps are Uzo ($12, the slot 2 position) and a tower ($44).
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu
import ps2screen
import vramaudit
from ps2emu import PS2

rom = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1].endswith('.bin') else os.path.join(ROOT, 'ps2en.bin')
specs = [a for a in sys.argv[1:] if not a.endswith('.bin')] or ['12:570:730', '44:100:100']
out = os.path.join(ps2emu.ANALYSIS, 'uzostatus')
os.makedirs(out, exist_ok=True)
LEVEL, LEVEL_Y, LEVEL_X, CHANGED = 0xFFFFC640, 0xFFFFC642, 0xFFFFC644, 0xFFFFF734
PM_MIST = 0xFFFF8EFE


def depth(em, expected, tries=150):
    for _ in range(tries):
        if em.word(ps2emu.WINDOW_DEPTH) == expected:
            return
        em.frames(2)
    raise RuntimeError('expected %d windows, got %d' % (expected, em.word(ps2emu.WINDOW_DEPTH)))


def plane_a(path):
    st = vramaudit.read_state(path)
    base = (st['regs'][2] & 0x38) << 10
    v = st['vram']
    return [v[base + 2 * i] << 8 | v[base + 2 * i + 1] for i in range(64 * 32)], st


def snap(em, name):
    path = os.path.join(out, name + '.state')
    ps2emu.save_state(em, path)
    ps2screen.render(path, os.path.join(out, name + '.png'))
    return plane_a(path)


failed = 0
with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    for spec in specs:
        lvl, y, x = (int(s, 16) for s in spec.split(':'))
        em.write(LEVEL, lvl.to_bytes(2, 'big'))
        em.write(LEVEL_Y, y.to_bytes(2, 'big'))
        em.write(LEVEL_X, x.to_bytes(2, 'big'))
        em.write(CHANGED, (0xFFFF).to_bytes(2, 'big'))
        em.frames(150)
        tag = 'map%02X' % lvl
        before, _ = snap(em, tag + '_before')
        mist = sum(1 for e in before if e & 0x6000 == 0x2000 and e & 0x7FF < 0x500)
        ps2emu.open_menu(em)
        ps2emu.pick(em, 2)                 # Status
        depth(em, 4)
        ps2emu.pick(em, 0)                 # Status
        depth(em, 5)
        em.press('C', hold=2, release=10)  # the first member
        depth(em, 10)
        em.frames(30)
        status, st = snap(em, tag + '_status')
        left = sum(1 for e in status if e & 0x6000 == 0x2000 and e & 0x7FF < 0x500)
        print('%s: %d map cells in line 1 before; on the status screen %d left, PM_MIST %d, line 1 %s'
              % (tag, mist, left, em.word(PM_MIST), ' '.join('%03X' % c for c in st['cram'][16:24])), flush=True)
        em.press('C', hold=2, release=10)  # its techniques
        depth(em, 12)
        em.frames(30)
        snap(em, tag + '_techs')
        ps2emu.close_windows(em)
        em.frames(30)
        after, _ = snap(em, tag + '_after')
        diff = [i for i in range(64 * 32) if before[i] != after[i]]
        print('%s: after closing PM_MIST %d, %d plane A cells differ from before%s'
              % (tag, em.word(PM_MIST), len(diff),
                 ''.join(' (%d,%d) %04X->%04X' % (i // 64, i % 64, before[i], after[i]) for i in diff[:8])), flush=True)
        if left or diff or em.word(PM_MIST):
            failed += 1
print('FAILED' if failed else 'ok')

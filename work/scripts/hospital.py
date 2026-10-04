"""Bounded check: the hospital's stats window after the field menu's status screen
(party_menu_ps4). Nei's status screen leaves her job as a text run in the buffer the
hospital's stats window shares; the window must not show it. Opens Nei's status,
closes it, enters the hospital (building 4) with Eusis hurt and takes Treat Wounds,
a shot of each step (work/analysis/hospital/).

    python work/scripts/hospital.py [rom]
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa: E402
from ps2emu import PS2, GAME_SCREEN  # noqa: E402

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
out = os.path.join(ps2emu.ANALYSIS, 'hospital')
os.makedirs(out, exist_ok=True)
BUILDING_INDEX, SCREEN_BUILDING = 0xFFFFF760, 0x10


def depth(em, expected, tries=100):
    for _ in range(tries):
        if em.word(ps2emu.WINDOW_DEPTH) == expected:
            return
        em.frames(2)
    raise RuntimeError('expected %d windows, got %d' % (expected, em.word(ps2emu.WINDOW_DEPTH)))


with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    em.press('C', hold=2, release=70)
    depth(em, 3)
    ps2emu.pick(em, 2)            # Status
    ps2emu.pick(em, 0)            # Status
    ps2emu.pick(em, 1)            # Nei
    depth(em, 10)
    em.shot(os.path.join(out, '0_status.png'))
    ps2emu.close_windows(em)
    depth(em, 0)
    em.write(0xFFFFC002, (5).to_bytes(2, 'big'))       # Eusis hurt
    em.write(BUILDING_INDEX, (4).to_bytes(2, 'big'))
    em.write(GAME_SCREEN, bytes([SCREEN_BUILDING]))
    em.frames(200)
    for k, b in enumerate('CCCC', 1):                  # greeting, Treat Wounds, yes
        em.press(b, hold=2, release=50)
        em.shot(os.path.join(out, '%d.png' % k))
        print(k, 'depth', em.word(ps2emu.WINDOW_DEPTH), 'HP', em.word(0xFFFFC002), flush=True)
    if em.word(0xFFFFC002) == 5:
        raise RuntimeError('Eusis was not treated')
    print('hospital after the status screen: shots taken')

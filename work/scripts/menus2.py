"""Field menus under vwf_windows, second round: STATE, TECH (with techniques given), STRNG,
EQP for the hero. Every step screenshotted; the registry's overflow counter reported.
Each sequence ends by backing out until no window is up. Bounded.

    python work/scripts/menus2.py [rom]
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, ANALYSIS  # noqa

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
out = os.path.join(ANALYSIS, 'menus2')
tag = 'stock_' if 'original' in rom else ''
# The translated menu: Items, Techs, Status, Equip. Stock keeps five entries.
SEQS = ([('state', [1, 0]), ('tech', [2, 0]), ('strng', [3, 0]), ('eqp', [4, 0])]
        if os.path.getsize(rom) == 786432 else
        [('status', [2, 0, 0]), ('tech', [1, 0]), ('eqp', [3, 0])])

with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    em.write(0xFFFFC025, bytes([3, 3]))          # technique counts (battle, field)
    for name, seq in SEQS:
        ps2emu.open_menu(em)
        for k, i in enumerate(seq):
            ps2emu.pick(em, i)
            em.shot(os.path.join(out, '%s%s%d.png' % (tag, name, k)))
        print('%-6s overflow %d  windows up %d' % (name, em.word(0xFFFF8E30), em.word(ps2emu.WINDOW_DEPTH)))
        ps2emu.close_windows(em)

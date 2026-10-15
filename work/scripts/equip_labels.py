"""Nei's second Steel Claw must not displace the Equip window's VWF labels.

    python work/scripts/equip_labels.py [rom]
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu
from ps2emu import PS2

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
NEI = 0xFFFFC040
CLAW = 0x59
WT_END = 0xFFFF8D80
WT_HUD = 0xFFFF8F80
WT_OVERFLOW = 0xFFFF8E30
EQUIP_SLOT = 4


def ready(em, expected):
    for _ in range(100):
        if em.word(ps2emu.WINDOW_DEPTH) == expected and not em.word(ps2emu.WINDOW_INDEX):
            return
        em.frames(2)
    raise RuntimeError('expected depth %d, got %d' % (expected, em.word(ps2emu.WINDOW_DEPTH)))


with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    # Ribbon, right Steel Claw, Carbon Vest, Espadrilles, and a second claw
    # in inventory; the Equip screen filters this to five entries.
    em.write(NEI + 0x20, bytes.fromhex('1A 59 00 2F 40'))
    em.write(NEI + 0x27, bytes.fromhex('05 9A D9 AF C0 59'))
    ps2emu.open_menu(em)
    ps2emu.pick(em, 3)                 # Equip
    ps2emu.pick(em, 1, settle=90)      # Nei
    ready(em, 7)
    equipment = 0xFFFFDF00 + EQUIP_SLOT * 16
    if em.word(equipment + 14) != 0x19:
        raise RuntimeError('the equipment window is not in slot 4')
    start = em.word(WT_END + 2 * (EQUIP_SLOT - 1))
    end = em.word(WT_END + 2 * EQUIP_SLOT)
    if end - start < 79:
        raise RuntimeError('the equipment VWF range has only %d tiles' % (end - start))
    listed = em.read(NEI + 0x28, em.byte(NEI + 0x27))
    choices = [i for i, item in enumerate(listed) if item == CLAW]
    if choices != [len(listed) - 1]:
        raise RuntimeError('unexpected Steel Claw list: %s' % listed.hex(' '))
    ps2emu.pick(em, choices[0], settle=60)
    ready(em, 8)                       # Right / Left
    ps2emu.pick(em, 1, settle=60)      # Left
    for _ in range(6):
        if em.byte(NEI + 0x22) == CLAW and em.word(ps2emu.WINDOW_DEPTH) == 7 \
                and not em.word(ps2emu.WINDOW_INDEX):
            break
        em.press('C', hold=2, release=40)
    else:
        raise RuntimeError('second Steel Claw was not equipped')
    em.frames(10)
    # A separate HUD range for the equipment window means its original
    # range was exhausted during the redraw. Item-list redraws may use HUD.
    corner = em.word(equipment)
    hud_corners = [em.word(WT_HUD + 6 * i) for i in range(16)]
    if corner in hud_corners:
        raise RuntimeError('equipment redraw escaped into the HUD tile pool')
    if em.word(WT_OVERFLOW):
        raise RuntimeError('VWF tile pool overflowed')
    em.shot(os.path.join(ps2emu.ANALYSIS, 'equip_labels', 'second_claw.png'))
    ps2emu.close_windows(em)
    print('Nei equipped a second Steel Claw; equipment VWF range %d tiles, overflow 0' %
          (end - start), flush=True)

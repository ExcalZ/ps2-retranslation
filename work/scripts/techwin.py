"""The technique windows with long names: the field TECH list and its second page, STRNG's
two lists, the battle technique list (with its NEXT page) and the plate a technique shows
while it is cast. Amia leads (her lists hold Saschnella, 38, and Nasaresta, 44). Two
sessions: the menus and the forced battle lists, then a real round in which Amia casts.
Every step is cursor-, depth- or window-checked; every loop is bounded.

    python work/scripts/techwin.py [rom] [cast|menus]     (only the round, or only the menus)
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, ANALYSIS, GAME_SCREEN, WINDOW_DEPTH, WINDOW_INDEX, WINDOW_ACTIVE, SCRIPT_ID  # noqa

rom = next((a for a in sys.argv[1:] if a.endswith('.bin')), os.path.join(ROOT, 'ps2en.bin'))
CAST_ONLY = 'cast' in sys.argv[1:]
MENUS_ONLY = 'menus' in sys.argv[1:]
tag = 'stock_' if 'original' in rom else ''
out = os.path.join(ANALYSIS, 'techwin')
os.makedirs(out, exist_ok=True)
CHARACTER_INDEX = 0xFFFFDE60
COMMANDS = 0xFFFFCC10         # char_battle_command_index: 16 bytes a character
SCREEN_BATTLE = 0x14


def shot(em, name):
    em.shot(os.path.join(out, tag + name + '.png'))
    print('%-10s depth %d cursor %s overflow %d' % (name, em.word(WINDOW_DEPTH),
                                                   list(em.read(0xFFFFDE50, 2)), em.word(0xFFFF8E30)), flush=True)


def amia(em):
    """Amia (character 3, whose lists hold both) leads, as a copy of Rolf with 200 TP."""
    em.write(0xFFFFC004, (200).to_bytes(2, 'big') * 2)      # TP (max, current)
    em.write(0xFFFFC0C0, bytes(em.read(0xFFFFC000, 64)))
    em.write(0xFFFFC0C0 + 0x25, bytes([14, 10]))            # technique counts: battle, field
    em.write(0xFFFFC608, (3).to_bytes(2, 'big'))


def battle(em):
    em.write(0xFFFFCB00, (1).to_bytes(2, 'big'))
    em.write(GAME_SCREEN, bytes([SCREEN_BATTLE]))
    em.frames(330)
    if em.byte(GAME_SCREEN) != SCREEN_BATTLE:
        raise RuntimeError('no battle')


def idle(em):
    for _ in range(60):
        if not em.word(WINDOW_INDEX) and not em.word(WINDOW_ACTIVE):
            return
        em.frames(10)
    raise RuntimeError('windows busy')


def menus(em):
    ps2emu.boot_to_field(em)
    amia(em)
    redesigned = os.path.getsize(rom) != 786432
    # the field TECH list, then its second page (NEXT is entry 0)
    ps2emu.open_menu(em)
    ps2emu.pick(em, 1 if redesigned else 2)
    ps2emu.pick(em, 0)
    shot(em, 'field1')
    ps2emu.pick(em, 0)
    shot(em, 'field2')
    ps2emu.close_windows(em)
    # Status (STRNG in stock): the stats, then C for the two technique lists
    ps2emu.open_menu(em)
    ps2emu.pick(em, 2 if redesigned else 3)
    if redesigned:
        ps2emu.pick(em, 0)       # Status, rather than Order
    ps2emu.pick(em, 0)
    shot(em, 'strng1')
    em.press('C', hold=2, release=60)
    shot(em, 'strng2')
    ps2emu.close_windows(em)
    # a battle: Amia's technique list forced up (WinID_BattleTechList $66), its four pages
    # stacked (the third holds Saschnella, the fourth Nasaresta)
    battle(em)
    shot(em, 'battle0')
    for name, page in (('battle1', 0), ('battle2', 4), ('battle3', 8), ('battle4', 12)):
        idle(em)
        em.write(CHARACTER_INDEX, (3).to_bytes(2, 'big'))
        em.write(0xFFFFDEEC, page.to_bytes(2, 'big'))
        em.write(WINDOW_INDEX, (0x66).to_bytes(2, 'big'))
        em.frames(40)
        shot(em, name)


if not CAST_ONLY:
    with PS2(rom) as em:
        menus(em)

if not MENUS_ONLY:
    with PS2(rom) as em:
        # a real round: Amia casts Saschnella; Nei defends. The plate shows
        # the technique's name while it is cast.
        ps2emu.boot_to_field(em)
        amia(em)
        battle(em)
        for n in range(60):
            em.write(COMMANDS + 3 * 16, bytes([0, 1, 0, 38]))   # by character: Amia
            em.write(COMMANDS + 16, bytes([0, 3]))
            if n == 0:
                em.press('C', hold=2, release=4)            # FIGHT
            em.frames(6)
            em.shot(os.path.join(out, '%scast_%02d.png' % (tag, n)))

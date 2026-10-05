"""Equipment shops keep shopping after a decline, carrier cancel, or short funds.

    python work/scripts/shop_reprompt.py [ps2en.bin] [--money-only]

The direct building load needs the Paseo store table and list length set explicitly.
All cursor moves and waits are bounded; window IDs are checked before each choice.
"""
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu

args = sys.argv[1:]
ROM = next((arg for arg in args if arg.endswith('.bin')), os.path.join(ROOT, 'ps2en.bin'))
MONEY_ONLY = '--money-only' in args
EVENT = 0xFFFFDE58
ITEM = 0xFFFFDE68
STORE_LENGTH = 0xFFFFF764
STORE_TABLE = 0xFFFFF766
BUILDING = 0xFFFFF760
WINDOWS = 0xFFFFDF0E
OPEN_STACK = [60, 35, 33, 0x76, 40]  # portrait, meseta, dialogue, party marks, item list
WHO = [0x77, 91]  # the comparison (shop_equip_compare), the character list


def stack(em):
    return [em.word(WINDOWS + 16 * i) for i in range(em.word(ps2emu.WINDOW_DEPTH))]


def expect(em, where, event, windows):
    actual = stack(em)
    if em.word(ps2emu.GAME_SCREEN) != 0x1000 or em.word(EVENT) != event or actual != windows:
        raise RuntimeError('%s: screen %04X, event %d, windows %s; expected event %d, %s'
                           % (where, em.word(ps2emu.GAME_SCREEN), em.word(EVENT),
                              actual, event, windows))


def pick_item(em, target):
    for _ in range(8):
        cursor = em.read(ps2emu.NAME_CURSOR, 1)[0]
        if cursor == target:
            em.press('C', hold=2, release=60)
            return
        em.press('D' if target > cursor else 'U', hold=2, release=12)
    raise RuntimeError('item cursor did not reach %d' % target)


def check_shop(building, table, item_row, item_id, name):
    with ps2emu.PS2(ROM) as em:
        ps2emu.boot_to_field(em)
        em.write(STORE_LENGTH, (5).to_bytes(2, 'big'))
        em.write(STORE_TABLE, table.to_bytes(2, 'big'))
        em.write(BUILDING, building.to_bytes(2, 'big'))
        em.write(ps2emu.GAME_SCREEN, bytes([0x10]))
        em.frames(200)
        expect(em, name + ' opening', 4, OPEN_STACK)

        pick_item(em, item_row)
        em.frames(80)
        if em.read(ITEM, 1)[0] != item_id:
            raise RuntimeError('%s: selected item is not $%02X' % (name, item_id))
        expect(em, name + ' character list', 6, OPEN_STACK + WHO)
        em.press('C', hold=2, release=60)  # Eusis, who cannot equip this item
        em.frames(120)
        expect(em, name + ' equipment warning', 8, OPEN_STACK + WHO + [31])

        em.press('B', hold=2, release=60)  # No
        em.frames(120)
        expect(em, name + ' after No', 4, OPEN_STACK)
        if em.word(0xFFFFDE90) != 1:
            raise RuntimeError('%s: No was not recorded' % name)

        pick_item(em, 0)  # the shop must still accept another item
        em.frames(80)
        expect(em, name + ' next choice', 6, OPEN_STACK + WHO)
        em.press('B', hold=2, release=60)  # cancel the carrier choice
        em.frames(120)
        expect(em, name + ' after carrier cancel', 4, OPEN_STACK)
        pick_item(em, 0)
        em.frames(80)
        expect(em, name + ' choice after carrier cancel', 6, OPEN_STACK + WHO)
        print('%s: No and carrier cancel returned to the item list' % name)


def check_no_money(building, table, name):
    with ps2emu.PS2(ROM) as em:
        ps2emu.boot_to_field(em)
        em.write(0xFFFFC620, bytes(4))
        em.write(STORE_LENGTH, (5).to_bytes(2, 'big'))
        em.write(STORE_TABLE, table.to_bytes(2, 'big'))
        em.write(BUILDING, building.to_bytes(2, 'big'))
        em.write(ps2emu.GAME_SCREEN, bytes([0x10]))
        em.frames(200)
        expect(em, name + ' opening', 4, OPEN_STACK)
        pick_item(em, 0)  # an item Eusis can equip
        em.frames(80)
        expect(em, name + ' Who?', 6, OPEN_STACK + WHO)
        em.press('C', hold=2, release=60)
        em.frames(120)
        expect(em, name + ' insufficient funds message', 6, OPEN_STACK + WHO)
        if em.word(0xFFFFDE5A) != 2:
            raise RuntimeError('%s: insufficient funds did not use the retry state' % name)
        em.press('C', hold=2, release=60)  # dismiss the warning
        em.frames(120)
        expect(em, name + ' after insufficient funds', 4, OPEN_STACK)
        print('%s: insufficient funds returned to the item list' % name)


if not MONEY_ONLY:
    check_shop(5, 2, 1, 0x57, 'weapon shop: Dagger')
    check_shop(6, 1, 2, 0x2C, 'armor shop: Carbon Vest')
check_no_money(5, 2, 'weapon shop')
check_no_money(6, 1, 'armor shop')

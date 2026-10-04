"""Check Item Shop Buy/Sell returns, carrier cancel, and insufficient funds.

    python work/scripts/itemshop_reprompt.py [ps2en.bin]

The direct building load supplies Paseo's item table and its list length. Every
input follows a checked window state, and all waits are bounded.
"""
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu
import ps2text

ROM = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
EVENT = 0xFFFFDE58
EVENT_SUB = 0xFFFFDE5A
BUILDING = 0xFFFFF760
STORE_LENGTH = 0xFFFFF764
STORE_TABLE = 0xFFFFF766
MONEY = 0xFFFFC620
WINDOWS = 0xFFFFDF0E
OPEN = [60, 35, 33, 34]  # portrait, meseta, dialogue, Buy/Sell
ITEMS = OPEN + [40]
WHO = ITEMS + [91]


def stack(em):
    return [em.word(WINDOWS + 16 * i) for i in range(em.word(ps2emu.WINDOW_DEPTH))]


def expect(em, where, event, windows):
    actual = stack(em)
    if em.word(ps2emu.GAME_SCREEN) != 0x1000 or em.word(EVENT) != event or actual != windows:
        raise RuntimeError('%s: screen %04X, event %d, windows %s; wanted %d, %s'
                           % (where, em.word(ps2emu.GAME_SCREEN), em.word(EVENT),
                              actual, event, windows))


def has_text(em, phrase):
    return ps2text.encode_us(phrase) in em.read(ps2emu.TEXT_BUFFER, 380)


def enter_carrier_choice(em):
    expect(em, 'Buy/Sell', 4, OPEN)
    em.press('C', hold=2, release=60)  # Buy
    em.frames(120)
    expect(em, 'item list', 13, ITEMS)
    em.press('C', hold=2, release=60)  # Monomate
    em.frames(120)
    expect(em, 'carrier list', 15, WHO)


def open_item_shop(em, no_money=False):
    ps2emu.boot_to_field(em)
    if no_money:
        em.write(MONEY, bytes(4))
    em.write(STORE_LENGTH, (5).to_bytes(2, 'big'))
    em.write(STORE_TABLE, (0).to_bytes(2, 'big'))
    em.write(BUILDING, (7).to_bytes(2, 'big'))
    em.write(ps2emu.GAME_SCREEN, bytes([0x10]))
    em.frames(200)
    expect(em, 'Item Shop opening', 4, OPEN)


def expect_exit_reply(em, where):
    expect(em, where, 18, OPEN[:3])
    if not (has_text(em, 'In that case, is there anything else')
            and has_text(em, 'I can help you with?')):
        raise RuntimeError('%s: the submenu exit reply was not loaded' % where)
    em.frames(120)
    expect(em, where + ' return', 4, OPEN)


def check_navigation():
    with ps2emu.PS2(ROM) as em:
        open_item_shop(em)
        enter_carrier_choice(em)

        em.press('B', hold=2, release=60)  # cancel purchase at Who?
        expect(em, 'carrier cancellation reply', 19, OPEN[:3])
        if not (has_text(em, "Oh, so you've reconsidered.")
                and has_text(em, 'Perhaps something else, then?')):
            raise RuntimeError('the carrier cancellation reply was not loaded')
        em.frames(120)
        expect(em, 'carrier cancellation return', 13, ITEMS)

        em.press('B', hold=2, release=60)  # close Buy
        expect_exit_reply(em, 'Buy exit')

        em.press('D', hold=2, release=12)  # Sell
        if em.read(ps2emu.NAME_CURSOR, 1)[0] != 1:
            raise RuntimeError('Sell was not selected')
        em.press('C', hold=2, release=60)
        em.frames(120)
        expect(em, 'Sell character list', 6, OPEN + [91])
        em.press('C', hold=2, release=60)
        em.frames(120)
        expect(em, 'Sell item list', 7, OPEN + [91, 3])
        em.press('B', hold=2, release=60)  # item list -> character list
        em.frames(120)
        expect(em, 'Sell character choice again', 6, OPEN + [91])
        em.press('B', hold=2, release=60)  # close Sell
        expect_exit_reply(em, 'Sell exit')

        em.press('C', hold=2, release=60)  # Buy still works
        em.frames(120)
        expect(em, 'Buy after Sell exit', 13, ITEMS)
        print('Item Shop: carrier cancel -> Buy; Buy and Sell exits -> Buy/Sell')


def check_insufficient_funds():
    with ps2emu.PS2(ROM) as em:
        open_item_shop(em, no_money=True)
        enter_carrier_choice(em)
        em.press('C', hold=2, release=60)
        expect(em, 'insufficient funds message', 15, WHO)
        if em.word(EVENT_SUB) != 2 or not has_text(em, "You don't have enough money."):
            raise RuntimeError('the existing insufficient-funds message was not loaded')
        em.press('C', hold=2, release=60)  # dismiss its {END} message
        em.frames(120)
        expect(em, 'insufficient funds return', 4, OPEN)
        print('Item Shop: insufficient funds -> Buy/Sell')


check_navigation()
check_insufficient_funds()

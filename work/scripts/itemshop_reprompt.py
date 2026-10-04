"""Check both Item Shop returns: cancel Who? and an unaffordable purchase.

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


def check(cancel):
    label = 'declined carrier' if cancel else 'insufficient funds'
    with ps2emu.PS2(ROM) as em:
        ps2emu.boot_to_field(em)
        if not cancel:
            em.write(MONEY, bytes(4))
        em.write(STORE_LENGTH, (5).to_bytes(2, 'big'))
        em.write(STORE_TABLE, (0).to_bytes(2, 'big'))
        em.write(BUILDING, (7).to_bytes(2, 'big'))
        em.write(ps2emu.GAME_SCREEN, bytes([0x10]))
        em.frames(200)
        enter_carrier_choice(em)

        em.press('B' if cancel else 'C', hold=2, release=60)
        if cancel:
            expect(em, label + ' reply', 18, OPEN[:3])
            if not (has_text(em, "Oh, so you've reconsidered.")
                    and has_text(em, 'Perhaps something else, then?')):
                raise RuntimeError('the new carrier-decline reply was not loaded')
            em.frames(120)
        else:
            expect(em, label + ' message', 15, WHO)
            if em.word(EVENT_SUB) != 2 or not has_text(em, "You don't have enough money."):
                raise RuntimeError('the existing insufficient-funds message was not loaded')
            em.press('C', hold=2, release=60)  # dismiss its {END} message
            em.frames(120)

        expect(em, label + ' return', 4, OPEN)
        em.press('C', hold=2, release=60)
        em.frames(120)
        expect(em, label + ' next Buy', 13, ITEMS)
        print('Item Shop %s: returned to Buy/Sell; Buy works again' % label)


check(True)
check(False)

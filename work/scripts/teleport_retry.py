"""Check that No at the Teleport Station price prompt returns to destinations.

    python work/scripts/teleport_retry.py [ps2en.bin]

Every button press follows a checked building state; waits are bounded.
"""
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu
import ps2text

ROM = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
EVENT = 0xFFFFDE58
SUB = 0xFFFFDE5A
BUILDING = 0xFFFFF760
WINDOWS = 0xFFFFDF0E
YES_NO = 0xFFFFDE90
BASE = [60, 35, 33]  # portrait, meseta, dialogue
PLACES = BASE + [115]
CONFIRM = PLACES + [31]
REPLY = ps2text.encode_us('A different destination, then, perhaps?')


def stack(em):
    return [em.word(WINDOWS + 16 * i) for i in range(em.word(ps2emu.WINDOW_DEPTH))]


def expect(em, where, event, windows):
    actual = stack(em)
    if em.word(ps2emu.GAME_SCREEN) != 0x1000 or em.word(EVENT) != event or actual != windows:
        raise RuntimeError('%s: screen %04X, event %d, windows %s; wanted %d, %s'
                           % (where, em.word(ps2emu.GAME_SCREEN), em.word(EVENT),
                              actual, event, windows))


with ps2emu.PS2(ROM) as em:
    ps2emu.boot_to_field(em)
    em.write(0xFFFFC700, bytes([4, 5, 6, 7, 8, 9]) + bytes(6))
    em.write(BUILDING, (15).to_bytes(2, 'big'))
    em.write(ps2emu.GAME_SCREEN, bytes([0x10]))
    em.frames(200)
    expect(em, 'opening question', 3, BASE)

    em.press('C', hold=2, release=60)  # dismiss the opening question
    em.frames(180)
    expect(em, 'destination list', 4, PLACES)
    em.press('C', hold=2, release=60)  # select a destination
    em.frames(180)
    expect(em, 'payment confirmation', 6, CONFIRM)

    em.press('D', hold=2, release=12)  # No
    expect(em, 'No selected', 6, CONFIRM)
    em.press('C', hold=2, release=10)
    expect(em, 'decline reply', 8, BASE)
    if em.word(SUB) or em.word(ps2emu.SCRIPT_ID) != 0xC09:
        raise RuntimeError('the new Teleport Station reply was not queued')
    em.frames(180)
    expect(em, 'destination list reopened', 4, PLACES)
    if REPLY not in em.read(ps2emu.TEXT_BUFFER, 380):
        raise RuntimeError('the new Teleport Station reply was not loaded')

    em.press('C', hold=2, release=60)  # the reopened list still accepts input
    em.frames(180)
    expect(em, 'second payment confirmation', 6, CONFIRM)
    print('Teleport Station: No reply -> destination list -> confirmation again')

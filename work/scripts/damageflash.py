"""Check the saved Damage Flash setting at a real party hit in a bounded battle.

    python work/scripts/damageflash.py [rom]
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa: E402
from ps2emu import GAME_SCREEN, PS2  # noqa: E402

rom = next((a for a in sys.argv[1:] if a.endswith('.bin')), os.path.join(ROOT, 'ps2en.bin'))
OPT_FLASH = 0xFFFFC69A
PALETTE = 0xFFFFFB00
SCREEN_BATTLE = 0x14
FLASH_DONE = ps2emu.listing_address('loc_1BE2')


def check(off, expected):
    with PS2(rom) as em:
        ps2emu.boot_to_field(em)
        em.write(OPT_FLASH, bytes([off]))
        em.write(0xFFFFCB00, (1).to_bytes(2, 'big'))
        em.write(GAME_SCREEN, bytes([SCREEN_BATTLE]))
        em.frames(330)
        if em.byte(GAME_SCREEN) != SCREEN_BATTLE:
            raise RuntimeError('the forced battle did not open')
        em.breakpoint(FLASH_DONE)
        seen = []

        def hook(pc):
            if pc == FLASH_DONE:
                seen.append((em.regs()['d'][0], em.word(PALETTE)))

        for _ in range(100):
            if seen or em.byte(GAME_SCREEN) != SCREEN_BATTLE:
                break
            em.press('C', hold=2, release=4, hook=hook)
        if not seen:
            raise RuntimeError('no party damage flash in 100 bounded inputs')
        if seen[0] != expected:
            raise RuntimeError('Damage Flash %s: %s, wanted %s' %
                               ('Off' if off else 'On', seen[0], expected))
        print('Damage Flash %s: colour %06X, palette %04X' %
              ('Off' if off else 'On', *seen[0]))


check(0, (0xE000E, 0x000E))
check(1, (0x200, 0x0200))

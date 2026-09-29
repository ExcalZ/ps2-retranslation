"""Bounded visual check of per-target battle damage numbers.

    python work/scripts/damagepopups.py [formation_hex] [--enemy-area|--megid] [--shots]

Starts an ordinary battle and advances the default Fight command. Saves the
first enemy and party damage frames when --shots is given, and logs active
per-target amounts. --enemy-area makes enemies use their all-party attack.
--megid gives Nei enough TP and queues Megid, which costs party HP.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa: E402
import ps2screen  # noqa: E402

FORMATIONS = [arg for arg in sys.argv[1:] if not arg.startswith('--')]
FORMATION = int(FORMATIONS[0], 16) if FORMATIONS else 1
POP = 0xFFFF8F00
POP_LIFE = 45
SCREEN_BATTLE = 0x14
OUT = os.path.join(ps2emu.ANALYSIS, 'damagepopups')
SAVES_OK = '--shots' in sys.argv


def slots(em):
    data = em.read(POP, 9 * 8)
    return [(i, int.from_bytes(data[i * 8 + 2:i * 8 + 4], 'big'))
            for i in range(9) if int.from_bytes(data[i * 8:i * 8 + 2], 'big') & 0x7FFF]


def shot(em, name):
    global SAVES_OK
    if not SAVES_OK:
        return
    state = os.path.join(OUT, name + '.state')
    try:
        ps2emu.save_state(em, state)
    except FileNotFoundError:
        SAVES_OK = False
        print('BlastEm did not write a quicksave; no image for', name, flush=True)
    else:
        ps2screen.render(state, os.path.join(OUT, name + '.png'))


def assert_sprites(em, active):
    # Wait for the six opening frames, even when screenshots are disabled.
    # At full width, every target has a framed box and a digit sprite.
    for _ in range(10):
        timers = [em.word(POP + slot * 8) & 0x7FFF for slot, _ in active]
        if all(6 < timer <= POP_LIFE - 7 for timer in timers):
            break
        em.frames(1)
    else:
        raise AssertionError('pop-up did not reach its full-width frames')
    count = em.byte(0xFFFFF62C)
    sat = em.read(0xFFFFF800, count * 8)
    entries = [(sat[n * 8 + 2], int.from_bytes(sat[n * 8 + 4:n * 8 + 6], 'big'),
                int.from_bytes(sat[n * 8:n * 8 + 2], 'big'))
               for n in range(count)]
    assert all(sat[n * 8 + 3] == n + 1 for n in range(count)), 'sprite links broke'
    assert entries[0][1] in {0x8000 | (0x33C + slot * 4) for slot, _ in active}, (
        'damage window did not lead the sprite list')
    for slot, _ in active:
        tile = 0x8000 | (0x33C + slot * 4)
        assert any(size == 0xC and art == tile for size, art, _ in entries), (
            'missing digits for slot %d' % slot)
    assert sum(size == 0xD and art == 0x836C for size, art, _ in entries) >= len(active), (
        'missing full-width boxes')
    for slot, _ in active:
        if slot >= 5:
            assert (0xD, 0x836C, 0x113) in entries, 'party window is not 5 px above bar'


def assert_closing(em, slot):
    # Keep the test bounded and inspect the sprite table as the box shrinks.
    for _ in range(POP_LIFE):
        timer = em.word(POP + slot * 8) & 0x7FFF
        if timer <= 5:
            break
        em.frames(1)
    else:
        raise AssertionError('pop-up did not reach its closing frames')
    count = em.byte(0xFFFFF62C)
    sat = em.read(0xFFFFF800, count * 8)
    entries = [(sat[n * 8 + 2], int.from_bytes(sat[n * 8 + 4:n * 8 + 6], 'big'))
               for n in range(count)]
    assert (0x9, 0x8366) in entries, 'closing box did not contract'
    assert (0xC, 0x8000 | (0x33C + slot * 4)) not in entries, 'digits stayed up during close'


with ps2emu.PS2(os.path.join(ROOT, 'ps2en.bin')) as em:
    ps2emu.boot_to_field(em)
    em.write(0xFFFFCB00, FORMATION.to_bytes(2, 'big'))
    em.write(ps2emu.GAME_SCREEN, bytes([SCREEN_BATTLE]))
    em.frames(25)
    if '--enemy-area' not in sys.argv and '--megid' not in sys.argv:
        for char_id in em.read(0xFFFFC608, 4)[1::2]:
            em.write(0xFFFFC000 + char_id * 0x40 + 0x21, bytes([0x70, 0x70]))
    if '--megid' in sys.argv:
        em.write(0xFFFFC046, (999).to_bytes(2, 'big'))
        em.write(0xFFFFCC20, bytes([0, 1, 0, 0x34]))
    if '--enemy-area' in sys.argv:
        for enemy in range(5):
            em.write(0xFFFFC200 + enemy * 0x40 + 0x25, bytes([0xE1, 0xFF]))
    seen = set()
    for k in range(400):
        if em.byte(ps2emu.GAME_SCREEN) != SCREEN_BATTLE:
            break
        active = slots(em)
        if '--megid' in sys.argv and any(i == 6 and amount > 0 for i, amount in active):
            seen.add('Megid cost')
        types = {'enemy' if i < 5 else 'party' for i, _ in active}
        for kind in types - seen:
            shot(em, kind)
            print(kind, 'frame', k, active, flush=True)
            seen.add(kind)
        if sum(i < 5 for i, _ in active) >= 2 and 'enemy area' not in seen:
            assert_sprites(em, active)
            total = em.word(0xFFFFCB20) + em.word(0xFFFFCB22)
            assert total >= sum(amount for i, amount in active if i < 5), (
                'stock damage total did not include the area hits')
            shot(em, 'enemy_area')
            if SAVES_OK:
                em.frames(10)
                shot(em, 'enemy_total')
            assert_closing(em, next(i for i, _ in active if i < 5))
            print('enemy area', 'frame', k, active, flush=True)
            seen.add('enemy area')
        if sum(i >= 5 for i, _ in active) >= 2 and 'party area' not in seen:
            assert_sprites(em, active)
            shot(em, 'party_area')
            assert_closing(em, next(i for i, _ in active if i >= 5))
            print('party area', 'frame', k, active, flush=True)
            seen.add('party area')
        if {'enemy area', 'party area'} <= seen:
            break
        em.press('C', hold=2, release=4)
    else:
        print('bounded battle loop ended at 400 inputs', flush=True)
    print('seen:', sorted(seen), flush=True)
    required = {'party area'} if '--enemy-area' in sys.argv else {'enemy area'}
    if '--megid' in sys.argv:
        required.add('Megid cost')
    assert required <= seen, 'missing damage case: %s' % sorted(required - seen)

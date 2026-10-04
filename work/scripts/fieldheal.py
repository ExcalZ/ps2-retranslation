"""Bounded field-healing check (field_heal_popups): the amber number each healed
party member gets beside the HP row of the party panel (party_menu_ps4).

Eusis and Nei, from a new game. Each case sets HP/TP/inventory/technique counts
in RAM, clears the four field popup slots, walks the menus with checked picks,
and passes the script messages with at most a few C presses, stopping as soon
as a slot is queued. It then checks the slot values (the capped recovery, no
slot for a member who gained nothing), that the slot is being drawn (its
render bit cleared and its life counting down) and the HP in RAM, and films
the popup.

    python work/scripts/fieldheal.py [rom] [exact]

`exact` also renders each popup from a savestate (<case>_exact.png, the 320x224
screen pixel for pixel) for measuring positions.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa: E402
from ps2emu import PS2, ANALYSIS, WINDOW_DEPTH  # noqa: E402

rom = next((a for a in sys.argv[1:] if a.endswith('.bin')), os.path.join(ROOT, 'ps2en.bin'))
EXACT = 'exact' in sys.argv[1:]
out = os.path.join(ANALYSIS, 'fieldheal')
os.makedirs(out, exist_ok=True)

CHAR = 0xFFFFC000            # 64 bytes a character: +2 HP, +4 max HP, +6/+8 TP,
FH_SLOTS = 0xFFFF8F28        # +$26 field techniques, +$27/+$28 inventory
TECHNIQUE_INDEX = 0xFFFFDE66
ITEM_INDEX = 0xFFFFDE68
MONOMATE, STAR_MIST, MOON_DEW = 0x11, 0x15, 0x16
RES, SAR, SAK, NASAK, REVER = 0x27, 0x2A, 0x2D, 0x2E, 0x30
ITEMS, TECHS = 0, 1          # the field menu (party_menu_ps4)


def hp(em, c, cur=None, top=None):
    if top is not None:
        em.write(CHAR + 64 * c + 4, top.to_bytes(2, 'big'))
    if cur is not None:
        em.write(CHAR + 64 * c + 2, cur.to_bytes(2, 'big'))
    return em.word(CHAR + 64 * c + 2)


def setup(em):
    rolf, nei = CHAR, CHAR + 64
    hp(em, 0, 30, 30)
    hp(em, 1, 20, 20)
    em.write(nei + 6, (99).to_bytes(2, 'big') * 2)
    em.write(rolf + 6, (99).to_bytes(2, 'big') * 2)
    em.write(nei + 0x26, bytes([6]))     # Res Anti Sak Nasak Gires Sar
    em.write(rolf + 0x26, bytes([6]))    # Ryuka Hinas Res Gires Anti Rever
    inv = bytes(em.read(rolf + 0x28, 3))  # keep the equipment
    em.write(rolf + 0x27, bytes([6]) + inv + bytes([MONOMATE, STAR_MIST, STAR_MIST]))
    inv = bytes(em.read(nei + 0x28, 4))
    em.write(nei + 0x27, bytes([5]) + inv + bytes([MOON_DEW]))


def slots(em):
    raw = em.read(FH_SLOTS, 32)
    return [tuple(int.from_bytes(raw[8 * k + 2 * i:8 * k + 2 * i + 2], 'big') for i in range(4))
            for k in range(4)]


def run(em, name, picks, want, hps, index=None):
    """picks: list entries from the field menu on; want: {slot: amount};
    hps: {character: HP afterwards}; index: (RAM address, expected id)."""
    em.write(FH_SLOTS, bytes(32))
    ps2emu.open_menu(em)
    for p in picks:
        ps2emu.pick(em, p)
    if index and em.byte(index[0]) != index[1]:
        raise RuntimeError('%s: chose $%02X, wanted $%02X' % (name, em.byte(index[0]), index[1]))
    for n in range(6):                       # the script messages, at most six C
        for _ in range(60):
            if any(s[0] for s in slots(em)):
                break
            em.frames(1)
        else:
            if n == 5:
                raise RuntimeError('%s: no popup queued (depth %d)' % (name, em.word(WINDOW_DEPTH)))
            em.press('C', hold=2, release=10)
            continue
        break
    em.frames(12)                            # the frame has opened
    em.shot(os.path.join(out, name + '.png'))
    if EXACT:
        import ps2screen
        state = os.path.join(out, name + '.state')
        ps2emu.save_state(em, state)
        ps2screen.render(state, os.path.join(out, name + '_exact.png'))
    s1 = slots(em)
    em.frames(6)
    s2 = slots(em)
    got = {k: s1[k][1] & 0x7FFF for k in range(4) if s1[k][0]}
    if got != want:
        raise RuntimeError('%s: slots %s, wanted %s' % (name, got, want))
    for k in got:
        if s1[k][0] & 0x8000 or s2[k][0] >= s1[k][0] or not s1[k][1] & 0x8000:
            raise RuntimeError('%s: slot %d is not drawn/ageing (%s -> %s)' % (name, k, s1[k], s2[k]))
    if em.word(0xFFFF8E30):
        raise RuntimeError('%s: %d text runs found no tiles' % (name, em.word(0xFFFF8E30)))
    for c, v in hps.items():
        if hp(em, c) != v:
            raise RuntimeError('%s: character %d HP %d, wanted %d' % (name, c, hp(em, c), v))
    print('%-9s slots %s  at %s' % (name, got, {k: '%X,%X' % s1[k][2:] for k in got}), flush=True)
    ps2emu.close_windows(em)


with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    if em.word(0xFFFFC600) != 1 or em.read(0xFFFFC608, 4) != b'\0\0\0\1':
        raise RuntimeError('expected Eusis and Nei')
    setup(em)

    # Monomate (+20) capped at max: 22/30 -> 30, shows 8
    hp(em, 0, 22)
    run(em, 'monomate', [ITEMS, 0, 3, 0, 0], {0: 8}, {0: 30}, (ITEM_INDEX, MONOMATE))
    # Star Mist (the Monomate is gone: index 3) with Nei full: only Eusis's slot
    hp(em, 0, 5)
    run(em, 'starmist', [ITEMS, 0, 3, 0], {0: 25}, {0: 30, 1: 20}, (ITEM_INDEX, STAR_MIST))
    # Star Mist, both hurt
    hp(em, 0, 18); hp(em, 1, 7)
    run(em, 'starmist2', [ITEMS, 0, 3, 0], {0: 12, 1: 13}, {0: 30, 1: 20}, (ITEM_INDEX, STAR_MIST))
    # Res (+20) from Nei on Eusis
    hp(em, 0, 5)
    run(em, 'res', [TECHS, 1, 0, 0], {0: 20}, {0: 25}, (TECHNIQUE_INDEX, RES))
    # Sar (+20 each), Nei capped
    hp(em, 0, 10); hp(em, 1, 12)
    run(em, 'sar', [TECHS, 1, 5], {0: 20, 1: 8}, {0: 30, 1: 20}, (TECHNIQUE_INDEX, SAR))
    # Moon Dew from Nei revives Eusis at full
    hp(em, 0, 0)
    run(em, 'moondew', [ITEMS, 1, 4, 0, 0], {0: 30}, {0: 30}, (ITEM_INDEX, MOON_DEW))
    # Sak: Nei falls, Eusis to full
    hp(em, 0, 4); hp(em, 1, 20)
    run(em, 'sak', [TECHS, 1, 2, 0], {0: 26}, {0: 30, 1: 0}, (TECHNIQUE_INDEX, SAK))
    # Rever from Eusis brings Nei back at full
    run(em, 'rever', [TECHS, 0, 5, 1], {1: 20}, {1: 20}, (TECHNIQUE_INDEX, REVER))
    # Nasak: Nei falls, Eusis to full, no slot for Nei
    hp(em, 0, 9); hp(em, 1, 20)
    run(em, 'nasak', [TECHS, 1, 3], {0: 21}, {0: 30, 1: 0}, (TECHNIQUE_INDEX, NASAK))
    # four members (Rudger and Anne as copies of Eusis), Star Mist on all: the
    # tallest panel and a popup on each HP row; Nei full, so three popups
    for c in (2, 3):
        em.write(CHAR + 64 * c, bytes(em.read(CHAR, 0x27)))
    em.write(0xFFFFC600, (3).to_bytes(2, 'big'))
    em.write(0xFFFFC608, bytes([0, 0, 0, 1, 0, 2, 0, 3]))
    inv = bytes(em.read(CHAR + 0x28, 3))
    em.write(CHAR + 0x27, bytes([4]) + inv + bytes([STAR_MIST]))
    hp(em, 0, 1); hp(em, 1, 20); hp(em, 2, 15); hp(em, 3, 29)
    run(em, 'starmist4', [ITEMS, 0, 3, 0], {0: 29, 2: 15, 3: 1}, {0: 30, 1: 20, 2: 30, 3: 30},
        (ITEM_INDEX, STAR_MIST))
    print('field healing popups passed')

"""Bounded trace of damage popups for a two-weapon attack (damage_popups): Eusis with a
Knife in each hand attacks the first enemy group, Nei defends. Logs every popup store,
impact cue and commit by frame, the first enemy's HP and slot 0 (timer, value) each
frame, and films the round (work/analysis/dualwield/).

    python work/scripts/dualwield.py [rom]       (FORMATION=n: default 9, a lone Whirly)
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa: E402
from ps2emu import PS2, GAME_SCREEN  # noqa: E402

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
out = os.path.join(ps2emu.ANALYSIS, 'dualwield')
os.makedirs(out, exist_ok=True)
EUSIS = 0xFFFFC000
COMMANDS = 0xFFFFCC10
POP_SLOTS = 0xFFFF8F00
ENEMY_HP = 0xFFFFC202
SCREEN_BATTLE = 0x14
KNIFE = 0x56

with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    em.write(EUSIS + 0x22, bytes([KNIFE]))                       # the left hand too
    inv = bytes(em.read(EUSIS + 0x28, 3))
    em.write(EUSIS + 0x27, bytes([4]) + inv + bytes([KNIFE | 0x80]))
    em.write(EUSIS + 0x0E, (60).to_bytes(2, 'big'))              # sure to act (agility)
    em.write(EUSIS + 0x16, (250).to_bytes(2, 'big') * 2)         # luck, dexterity: both strikes land
    em.write(EUSIS + 2, (400).to_bytes(2, 'big') * 2)            # and survives
    em.write(0xFFFFCB00, int(os.environ.get('FORMATION', 9)).to_bytes(2, 'big'))
    em.write(GAME_SCREEN, bytes([SCREEN_BATTLE]))
    em.frames(330)
    if em.byte(GAME_SCREEN) != SCREEN_BATTLE:
        raise RuntimeError('no battle')
    labels = {ps2emu.listing_address(n): n for n in
              ('Popup_Store', 'Popup_Impact', 'Popup_PendingCommit')}
    for a in labels:
        em.breakpoint(a)

    def hook(pc):
        r = em.regs()
        print('  frame %d %s d0 %X d1 %X' % (em.frame, labels.get(pc, hex(pc)), r['d'][0] & 0xFFFF,
                                           r['d'][1] & 0xFFFF), flush=True)

    for n in range(480):
        if n == 0:                                   # once: the second word counts the hands
            em.write(COMMANDS, bytes([0, 0, 0, 0]))              # Eusis: attack group 0
            em.write(COMMANDS + 16, bytes([0, 3]))               # Nei: defend
        if n == 0:
            em.pad = ps2emu.BUTTON['C']
        elif n == 2:
            em.pad = 0
        em.step_frame(hook)
        slots = em.read(POP_SLOTS, 24)
        print('%3d HP %s slots %s' % (n, [em.word(ENEMY_HP + 0x40 * k) for k in range(3)],
                                     ' '.join('%04X:%d' % (int.from_bytes(slots[8 * k:8 * k + 2], 'big'),
                                                           int.from_bytes(slots[8 * k + 2:8 * k + 4], 'big'))
                                              for k in range(3))), flush=True)
        if n % 6 == 0:
            em.shot(os.path.join(out, 'f%03d.png' % n))

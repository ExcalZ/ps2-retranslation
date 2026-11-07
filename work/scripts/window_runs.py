"""Reproduce a full window text table in Equip and in manual battle targeting.

    python work/scripts/window_runs.py [rom]
"""
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu
import vramaudit

RUNS = 0xFFFF8C00
STACK = 0xFFFFDF00
ROM = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
OUT = os.path.join(ps2emu.ANALYSIS, 'window_runs', os.path.splitext(os.path.basename(ROM))[0])


def wait_depth(em, depth):
    for _ in range(100):
        if em.word(ps2emu.WINDOW_DEPTH) == depth and not em.word(ps2emu.WINDOW_INDEX):
            return
        em.frames(2)
    raise RuntimeError('expected %d windows, got %d' % (depth, em.word(ps2emu.WINDOW_DEPTH)))


def saturate(em):
    table = em.read(RUNS, 48 * 8)
    # Stale runs in the field technique art, away from both active stacks.
    stale = iter(range(0x82BE, 0x837E, 4))
    em.write(RUNS, b''.join(
        run if run[:2] != b'\0\0' else struct.pack('>HBBI', next(stale), 1, 1, 0x12D68)
        for run in (table[k:k + 8] for k in range(0, len(table), 8))
    ))


def drawn(em, slot, win_id, rows, col, cells, name):
    entry = STACK + 16 * slot
    assert em.word(entry + 14) == win_id, 'wrong window on the stack'
    pos = em.word(entry)
    path = os.path.join(OUT, name + '.state')
    ps2emu.save_state(em, path)
    vram = vramaudit.read_state(path)['vram']
    plane = 0xE000 if pos & 0x2000 else 0xC000
    matches = []
    for row in rows:
        row_offset = ((pos & 0xF80) + row * 0x80) & 0xFFF
        col_offset = (pos + col * 2) & 0x7F
        start = plane + row_offset + col_offset
        tiles = (word & 0x7FF for word, in struct.iter_unpack('>H', vram[start:start + cells * 2]))
        matches.append(sum(tile != 0x526 and b'\x11' in vram[tile * 32:tile * 32 + 32]
                           for tile in tiles))
    print('%s ink tiles %s; overflow %d' % (name, matches, em.word(ps2emu.WT_OVERFLOW)), flush=True)
    return all(matches)


with ps2emu.PS2(ROM) as em:
    ps2emu.boot_to_field(em)
    ps2emu.open_menu(em)
    ps2emu.pick(em, 3)                     # Equip
    wait_depth(em, 4)
    saturate(em)
    ps2emu.pick(em, 0, settle=90)          # Eusis
    wait_depth(em, 7)
    arrows = drawn(em, 5, 0x18, (1, 3, 5), 10, 1, 'equip')

    ps2emu.close_windows(em)
    wait_depth(em, 0)
    em.write(0xFFFFCB00, b'\x00\x56')      # Scaly and Fanbite, an AMeDAS formation
    em.write(ps2emu.GAME_SCREEN, b'\x14')
    em.frames(330)
    wait_depth(em, 1)
    ps2emu.pick(em, 1, settle=60)          # Command
    wait_depth(em, 0)
    assert em.word(0xFFFFDE58) == 4, 'no member cursor'
    em.press('C', hold=2, release=60)      # Eusis
    wait_depth(em, 2)
    saturate(em)
    ps2emu.pick(em, 0, settle=60)          # Attack
    wait_depth(em, 3)
    targets = drawn(em, 2, 0x64, (2, 4), 3, 10, 'targets')

if not arrows or not targets:
    raise SystemExit('missing Equip arrows or battle target names')

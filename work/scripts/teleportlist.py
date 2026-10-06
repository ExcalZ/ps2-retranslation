"""The Teleport Service's destination list on Motavia (six places), then on Dezolis (Skure
and the three Dezolis towns), in one session: the Dezolis list must not show the rows
the Motavia list drew last (vwf_windows runs left in WT_RUNS). Bounded.

    python work/scripts/teleportlist.py [rom]
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, ANALYSIS, GAME_SCREEN, SCREEN_FIELD, WINDOW_DEPTH  # noqa

args = sys.argv[1:]
rom = args.pop(0) if args and args[0].endswith('.bin') else os.path.join(ROOT, 'ps2en.bin')
tag = 'stock_' if 'original' in rom else ''
out = os.path.join(ANALYSIS, 'teleport')
os.makedirs(out, exist_ok=True)
BUILDING_INDEX = 0xFFFFF760
SCREEN_BUILDING = 0x10
ON_DEZOLIS = 0xFFFFF764
LIST_COUNT = 0xFFFFDED6          # the list's entries - 1 ($FFFF while it is drawn)
WT_RUNS, WT_RUNS_N = 0xFFFF8C00, 48
ART, ART_SIZE = 0x8ACA, 0x15 * 4  # the list's art in window_art_buffer


def list_runs(em):
    raw = em.read(WT_RUNS, WT_RUNS_N * 8)
    return sorted(int.from_bytes(raw[i:i + 2], 'big') - ART for i in range(0, len(raw), 8)
                  if ART <= int.from_bytes(raw[i:i + 2], 'big') < ART + ART_SIZE)


def open_list(em, name):
    em.write(BUILDING_INDEX, (0xF).to_bytes(2, 'big'))
    em.write(GAME_SCREEN, bytes([SCREEN_BUILDING]))
    em.frames(200)
    em.write(LIST_COUNT, b'\x77\x77')
    for _ in range(8):                       # the greeting's pages, then the list
        if em.word(LIST_COUNT) not in (0x7777, 0xFFFF):
            break
        em.press('C', hold=2, release=40)
    else:
        raise RuntimeError('%s: the destination list did not open' % name)
    em.frames(30)
    em.shot(os.path.join(out, '%s%s.png' % (tag, name)))
    print('%s: %d entries, runs in the list art at %s' % (name, em.word(LIST_COUNT) + 1, list_runs(em)),
          flush=True)


def leave(em):
    for _ in range(12):                      # B through the goodbye, back to the field
        if em.word(GAME_SCREEN) == SCREEN_FIELD and em.word(WINDOW_DEPTH) == 0:
            return
        em.press('B', hold=2, release=40)
        em.frames(30)
    raise RuntimeError('did not get back to the field')


with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    em.write(ON_DEZOLIS, b'\x00\x00')
    em.write(0xFFFFC704, bytes([4, 5, 6, 7, 8, 9]))     # Paseo .. Piata
    open_list(em, 'motavia')
    leave(em)
    em.write(ON_DEZOLIS, b'\x00\x01')
    em.write(0xFFFFC70A, bytes([10, 11, 12]))           # Aukba, Zosa, Ryuon
    open_list(em, 'dezolis')

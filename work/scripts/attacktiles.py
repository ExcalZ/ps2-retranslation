"""Which tiles do the party's battle sprites use? A savestate's characters and party are
copied into a booted game, a formation is forced (default the state's), and every member
fights. Each frame the sprite buffer ($FFF800) is read; any sprite whose tiles fall in the
battle window pool (WT_PoolBattle in ext/wintext.asm) is reported, and the highest tile
each party art block ($200, $280, $300, $380) reaches is printed at the end. The first
time a sprite shows the last tiles of a member's art, a savestate is taken and every
member's art in VRAM is compared with the ROM's (work/analysis/attacktiles/).
The pool's peak use (stacked windows plus unstacked ones) and WT_OVERFLOW are reported.
Bounded: at most 600 inputs, and it stops when the battle ends.

    python work/scripts/attacktiles.py STATE [formation_hex] [rom] [--party=0,2,5,4]

--party replaces the state's party list (character ids) with another.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2art
import ps2emu
import ps2screen
import vramaudit
from ps2emu import PS2

SCREEN_BATTLE = 0x14
ARGS = [a for a in sys.argv[1:] if not a.startswith('--')]
OPTS = dict(a[2:].split('=', 1) for a in sys.argv[1:] if a.startswith('--'))
state = ARGS[0]
formation = int(ARGS[1], 16) if len(ARGS) > 1 else None
rom = ARGS[2] if len(ARGS) > 2 else os.path.join(ROOT, 'ps2en.bin')


def state_ram(path):
    d = open(path, 'rb').read()
    assert d[:6] == b'BLSTSZ', 'not a BlastEm state'
    p = 8
    while p + 6 <= len(d):
        t = int.from_bytes(d[p:p + 2], 'big')
        n = int.from_bytes(d[p + 2:p + 6], 'big')
        if t == 10:                       # SECTION_MAIN_RAM
            return d[p + 7:p + 6 + n]
        p += 6 + n
    raise RuntimeError('no work RAM section')


ART_TILES = (109, 95, 124, 93, 102, 103, 102, 93)   # WT_PartyArtTiles
ART_FILES = ('rolf', 'nei', 'rudo', 'amy_shir', 'hugh_kain', 'anna', 'hugh_kain', 'amy_shir')
OUT = os.path.join(ps2emu.ANALYSIS, 'attacktiles')


def battle_pool(party):
    """WT_PoolBattle as WT_Range reads it for this party: each slot's block end, then
    the fixed ranges."""
    src = open(os.path.join(ROOT, 'PSII_Disasm', 'ext', 'wintext.asm'), newline='').read()
    body = src.split('WT_PoolBattle:', 1)[1].split('WT_PoolTitle', 1)[0]
    body = '\n'.join(line for line in body.split('\n') if 'WT_PARTY_TAIL' not in line)
    pool = []
    for slot in range(4):
        base = 0x200 + slot * 0x80
        pool.append((base + (ART_TILES[party[slot]] if slot < len(party) else 0), base + 0x80))
    nums = [int(x, 16) for x in re.findall(r'\$([0-9A-F]+)', body)]
    return pool + [(nums[i], nums[i + 1]) for i in range(0, len(nums) - 1, 2)]


ram = state_ram(state)
PARTY = [int.from_bytes(ram[0xC608 + 2 * i:0xC60A + 2 * i], 'big')
         for i in range(int.from_bytes(ram[0xC600:0xC602], 'big') + 1)]
if 'party' in OPTS:
    PARTY = [int(c) for c in OPTS['party'].split(',')]
POOL = battle_pool(PARTY)
if formation is None:
    formation = int.from_bytes(ram[0xCB00:0xCB02], 'big')
print('party', PARTY, 'pool', ' '.join('$%03X-$%03X' % (a, b - 1) for a, b in POOL), 'formation %04X' % formation)

reach = {}
hits = {}
peak = 0
pool_size = sum(b - a for a, b in POOL)
filmed = set()
damaged = []


def check_art(em, block, frame):
    """Save a state while a sprite shows the last tiles of `block`'s art: every party
    block in VRAM must hold its character's art, unchanged, and the screen is rendered."""
    path = os.path.join(OUT, 'frame%d.state' % frame)
    ps2emu.save_state(em, path)
    ps2screen.render(path, os.path.splitext(path)[0] + '.png')
    vram = vramaudit.read_state(path)['vram']
    for slot, char in enumerate(PARTY):
        art, _ = ps2art.decompress(open(os.path.join(
            ROOT, 'PSII_Disasm', 'art', 'battle_%s_art.bin' % ART_FILES[char]), 'rb').read(), 0)
        assert len(art) == ART_TILES[char] * 32, 'ART_TILES is wrong for character %d' % char
        base = (0x200 + slot * 0x80) * 32
        if vram[base:base + len(art)] != art:
            bad = [base // 32 + t for t in range(len(art) // 32)
                   if vram[base + t * 32:base + t * 32 + 32] != art[t * 32:t * 32 + 32]]
            damaged.append((frame, slot, bad))
            print('frame %d: slot %d art changed in tiles %s' % (
                frame, slot, ' '.join('$%03X' % t for t in bad)), flush=True)
    print('frame %d: block $%03X at its art end, art checked (%s)' % (frame, block, path), flush=True)


with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    em.write(0xFFFFC000, ram[0xC000:0xC200])          # the characters
    em.write(0xFFFFC600, (len(PARTY) - 1).to_bytes(2, 'big'))        # party count and list
    em.write(0xFFFFC608, b''.join(c.to_bytes(2, 'big') for c in PARTY))
    em.write(0xFFFFCB00, formation.to_bytes(2, 'big'))
    em.write(ps2emu.GAME_SCREEN, bytes([SCREEN_BATTLE]))
    em.frames(25)
    for k in range(600):
        if em.byte(ps2emu.GAME_SCREEN) != SCREEN_BATTLE:
            print('battle over after', k, 'inputs')
            break
        for _ in range(3):
            count = em.byte(0xFFFFF62C)
            sat = em.read(0xFFFFF800, max(count, 1) * 8)
            for n in range(count):
                e = sat[n * 8:n * 8 + 8]
                size = e[2] & 0xF
                tile = int.from_bytes(e[4:6], 'big') & 0x7FF
                last = tile + ((size >> 2) + 1) * ((size & 3) + 1) - 1
                block = tile & ~0x7F
                if 0x200 <= block < 0x400:
                    reach[block] = max(reach.get(block, 0), last)
                    slot = (block - 0x200) // 0x80
                    if (block not in filmed and slot < len(PARTY)
                            and last >= block + ART_TILES[PARTY[slot]] - 8):
                        filmed.add(block)
                        check_art(em, block, em.frame)
                for a, b in POOL:
                    if tile < b and last >= a:
                        key = (tile, size)
                        if key not in hits:
                            hits[key] = em.frame
                            print('frame %d: sprite tiles $%03X-$%03X (size %X) in pool $%03X-$%03X'
                                  % (em.frame, tile, last, size, a, b - 1), flush=True)
            em.frames(1)
        depth = em.word(ps2emu.WINDOW_DEPTH)
        stack = em.word(0xFFFF8D80 + 2 * (depth - 1)) if 0 < depth <= 16 else 0
        if em.byte(0xFFFF8E36) == SCREEN_BATTLE:                  # WT_HUD_SCREEN
            peak = max(peak, stack + pool_size - em.word(0xFFFF8E34))   # WT_HUD_BUMP
        em.press('C', hold=2, release=2)
    else:
        print('bounded loop ended at 600 inputs')
    overflow = em.word(0xFFFF8E30)                 # WT_OVERFLOW
for block in sorted(reach):
    print('art block $%03X reaches $%03X' % (block, reach[block]))
print('%d pool overlaps' % len(hits))
print('window text overflow', overflow, '; peak pool use %d of %d' % (peak, pool_size))
print('%d art checks, %d with changed tiles' % (len(filmed), len(damaged)))
if hits or overflow or damaged:
    sys.exit(1)

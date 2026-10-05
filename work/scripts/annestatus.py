"""The owner's slot 1 crash: the party and characters of a BlastEm savestate are
copied into a booted game, Anne is put in the party, and Status > Status > Anne
is opened (any member's status crashed: PM_PointsRow's word store at an odd
address in the info window), then C for her techniques. Breakpoints sit on the 68000 error vectors
(bus/address error, illegal instruction, ...): a crash stops there and the
registers and the stack are printed. Every wait is bounded.

    python work/scripts/annestatus.py STATE [rom] [position]

STATE is a BlastEm 0.6.2 .state (its work RAM is read from section 10);
position is Anne's place in the party list (default 3, the last of four).
"""
import os
import socket
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu
from ps2emu import PS2

state = sys.argv[1]
rom = sys.argv[2] if len(sys.argv) > 2 else os.path.join(ROOT, 'ps2en.bin')
pos = int(sys.argv[3]) if len(sys.argv) > 3 else 3
out = os.path.join(ps2emu.ANALYSIS, 'annestatus')
os.makedirs(out, exist_ok=True)
ANNE = 3                                 # Anne (US Amy); 5 is Amia


def state_ram(path):
    d = open(path, 'rb').read()
    assert d[:6] == b'BLSTSZ', 'not a BlastEm state'
    p = 8
    while p + 6 <= len(d):
        t = int.from_bytes(d[p:p + 2], 'big')
        n = int.from_bytes(d[p + 2:p + 6], 'big')
        if t == 10:                       # SECTION_MAIN_RAM: a size byte, then 64K
            return d[p + 7:p + 6 + n]
        p += 6 + n
    raise RuntimeError('no work RAM section')


class Crash(Exception):
    pass


ram = state_ram(state)
romdata = open(rom, 'rb').read()
vectors = {int.from_bytes(romdata[4 * v:4 * v + 4], 'big'): v for v in range(2, 12)}


def hook(pc):
    if pc in vectors:
        raise Crash('vector %d handler at %06X' % (vectors[pc], pc))


def depth(em, expected, tries=150):
    for _ in range(tries):
        if em.word(ps2emu.WINDOW_DEPTH) == expected:
            return
        em.frames(2, hook)
    raise RuntimeError('expected %d windows, got %d' % (expected, em.word(ps2emu.WINDOW_DEPTH)))


def report(em, why):
    r = em.regs()
    print('CRASH:', why)
    print('pc %06X sr %04X' % (r['pc'], r['sr']))
    print('d', ' '.join('%08X' % x for x in r['d']))
    print('a', ' '.join('%08X' % x for x in r['a']))
    sp = r['a'][7]
    print('stack', em.read(sp, 32).hex(' '))
    print('depth %d window %04X' % (em.word(ps2emu.WINDOW_DEPTH), em.word(0xFFFFDF7E)))


with PS2(rom) as em:
    for a in vectors:
        em.breakpoint(a)
    ps2emu.boot_to_field(em)
    # the characters, the party block and the names, from the state
    for lo, hi in ((0xC000, 0xC200), (0xC600, 0xC640), (0xC660, 0xC700)):
        em.write(0xFF0000 + lo, ram[lo:hi])
    party = [int.from_bytes(ram[0xC608 + 2 * i:0xC60A + 2 * i], 'big')
             for i in range(ram[0xC601] + 1)]
    print('state party', party, 'joined', ram[0xC605])
    if ANNE not in party:
        party[pos] = ANNE
    for i, c in enumerate(party):
        em.write(0xFFC608 + 2 * i, c.to_bytes(2, 'big'))
    print('party', party)
    print('Anne', em.read(0xFFC000 + ANNE * 0x40, 0x40).hex(' '))
    try:
        em.frames(10, hook)
        ps2emu.open_menu(em)
        em.shot(os.path.join(out, 'menu.png'))
        ps2emu.pick(em, 2)                 # Status
        depth(em, 4)
        ps2emu.pick(em, 0)                 # Status
        depth(em, 5)
        em.shot(os.path.join(out, 'list.png'))
        idx = party.index(ANNE)
        for _ in range(20):                # the cursor to Anne, checked
            cur = em.byte(ps2emu.NAME_CURSOR)
            if cur == idx:
                break
            em.press('D' if idx > cur else 'U', hold=2, release=12, hook=hook)
        else:
            raise RuntimeError('cursor stuck at %d' % em.byte(ps2emu.NAME_CURSOR))
        em.press('C', hold=2, release=10, hook=hook)
        for k in range(12):                # film the status screen opening
            em.frames(10, hook)
            em.shot(os.path.join(out, 'stats_%02d.png' % k))
            print('frame %d depth %d' % (k, em.word(ps2emu.WINDOW_DEPTH)), flush=True)
        depth(em, 10)
        em.press('C', hold=2, release=10, hook=hook)
        for k in range(8):
            em.frames(10, hook)
            em.shot(os.path.join(out, 'techs_%02d.png' % k))
        depth(em, 12)
        print('Anne status and techniques shown, no crash')
    except Crash as e:
        report(em, e)
        em.shot(os.path.join(out, 'crash.png'))
    except socket.timeout:
        em.sock.sendall(b'\x03')          # GDB break
        em._recv_packet()
        report(em, 'hang (no frame in 60 s)')

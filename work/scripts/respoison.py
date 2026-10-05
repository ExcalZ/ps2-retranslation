"""RES on a poisoned member, on the field: Nei casts RES on a poisoned Eusis. The
technique does not heal him; the script shows 010B, which runs on into 010C as the JP
does ("{NAME} held a hand over {NAME2}'s wounds." / "But a body ravaged by poison cannot
be healed."; the US release ended 010B and dropped the second line). Each page is filmed
once its text has stopped typing (the pages are read from the shots). Checks: Eusis's HP unchanged and
still poisoned, Nei's TP spent, the window closed, no VWF overflow. Bounded.

    python work/scripts/respoison.py [rom]
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa: E402
from ps2emu import PS2, ANALYSIS, WINDOW_DEPTH, TEXT_POINTER  # noqa: E402

rom = next((a for a in sys.argv[1:] if a.endswith('.bin')), os.path.join(ROOT, 'ps2en.bin'))
redesigned = os.path.getsize(rom) != 786432
tag = '' if redesigned else 'stock_'
out = os.path.join(ANALYSIS, 'respoison')
os.makedirs(out, exist_ok=True)

CHAR = 0xFFFFC000            # 64 bytes a character: +0 status (bit 15 poison), +2 HP, +6 TP, +8 max TP
TECHNIQUE_INDEX = 0xFFFFDE66
RES = 0x27


def settle(em, limit=240):
    """Wait until the text pointer stops moving (the page has typed out)."""
    last, still = None, 0
    for _ in range(limit):
        em.frames(2)
        ptr = em.long(TEXT_POINTER)
        still = still + 1 if ptr == last else 0
        last = ptr
        if still >= 10:
            return
    raise RuntimeError('the text did not settle')


with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    if em.word(0xFFFFC600) != 1 or em.read(0xFFFFC608, 4) != b'\0\0\0\1':
        raise RuntimeError('expected Eusis and Nei')
    rolf, nei = CHAR, CHAR + 64
    em.write(rolf + 2, (12).to_bytes(2, 'big'))          # hurt: RES would heal him
    em.write(nei + 6, (99).to_bytes(2, 'big') * 2)
    em.write(nei + 0x26, bytes([6]))                     # Res Anti Sak Nasak Gires Sar
    em.write(rolf, bytes([em.byte(rolf) | 0x80]))        # poisoned
    status, hp0, tp0 = em.word(rolf), em.word(rolf + 2), em.word(nei + 6)

    ps2emu.open_menu(em)
    ps2emu.pick(em, 1 if redesigned else 2)              # Techs
    ps2emu.pick(em, 1)                                   # Nei
    ps2emu.pick(em, 0)                                   # Res
    if em.byte(TECHNIQUE_INDEX) != RES:
        raise RuntimeError('chose technique $%02X' % em.byte(TECHNIQUE_INDEX))
    depth = em.word(WINDOW_DEPTH)
    ps2emu.pick(em, 0, settle=0)                         # on Eusis
    for _ in range(90):                                  # the message window opens
        if em.word(WINDOW_DEPTH) > depth:
            break
        em.frames(2)
    else:
        raise RuntimeError('no message window (depth %d)' % em.word(WINDOW_DEPTH))
    msg_depth = em.word(WINDOW_DEPTH)
    pages = 0
    for n in range(6):                                   # at most six pages
        settle(em)
        pages += 1
        em.shot(os.path.join(out, '%spage%d.png' % (tag, pages)))
        print('page %d: depth %d' % (pages, em.word(WINDOW_DEPTH)), flush=True)
        em.press('C', hold=2, release=20)
        em.frames(30)
        if em.word(WINDOW_DEPTH) < msg_depth:
            break
    else:
        raise RuntimeError('the message did not close after six pages')
    ps2emu.close_windows(em)

    problems = []
    if em.word(rolf + 2) != hp0:
        problems.append('Eusis HP %d, was %d' % (em.word(rolf + 2), hp0))
    if em.word(rolf) != status:
        problems.append('Eusis status %04X, was %04X' % (em.word(rolf), status))
    if em.word(nei + 6) >= tp0:
        problems.append('Nei TP %d, was %d: not spent' % (em.word(nei + 6), tp0))
    if redesigned and em.word(0xFFFF8E30):
        problems.append('%d text runs found no tiles' % em.word(0xFFFF8E30))
    print('pages %d; Eusis HP %d (status %04X); Nei TP %d -> %d' % (
        pages, em.word(rolf + 2), em.word(rolf), tp0, em.word(nei + 6)))
    if problems:
        raise SystemExit('; '.join(problems))
    print('RES on a poisoned member passed')

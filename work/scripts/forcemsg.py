"""Show any script message on the field and page through it, recording how far each
expanded page reaches in text_buffer ($CD40; the sound RAM starts at $D000).

    python work/scripts/forcemsg.py [--rom ROM] [--tag TAG] ID [ID...]

Screenshots go to work/analysis/msg_<tag>_<id>_<page>.png. Prints, per message, the
pages seen and the highest buffer address the expansion wrote (the byte after the
page's $C3 or end code).
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
from ps2emu import PS2, ANALYSIS, TEXT_BUFFER, TEXT_POINTER, WINDOW_ACTIVE, WINDOW_INDEX  # noqa

args = sys.argv[1:]
rom = os.path.join(ROOT, 'ps2en.bin')
tag = 'en'
if '--rom' in args:
    i = args.index('--rom'); rom = args[i + 1]; del args[i:i + 2]
if '--tag' in args:
    i = args.index('--tag'); tag = args[i + 1]; del args[i:i + 2]
ids = [int(a, 16) for a in args]


def buffer_end(em):
    """Address after the first stop byte ($C3..$C7) from the start of the buffer."""
    data = em.read(TEXT_BUFFER, 0x400)
    for i, b in enumerate(data):
        if 0xC3 <= b <= 0xC7:
            return TEXT_BUFFER + i + 1
    return None


with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    for sid in ids:
        ps2emu.show_message(em, sid)
        em.frames(30)
        page = 0
        high = 0
        while True:
            em.frames(90)                    # let the page type out
            end = buffer_end(em)
            high = max(high, end or 0, em.long(TEXT_POINTER))
            em.shot(os.path.join(ANALYSIS, 'msg_%s_%04X_%02d.png' % (tag, sid, page)))
            page += 1
            em.press('C', hold=2, release=10)
            if em.word(WINDOW_ACTIVE) == 0 or page > 60:
                break
        em.frames(30)
        for _ in range(3):
            if em.word(WINDOW_INDEX) == 0:
                break
            em.press('B', hold=2, release=20)
        print('%04X: %d pages, buffer reached $%04X (sound RAM at $D000)' % (sid, page, high & 0xFFFF), flush=True)

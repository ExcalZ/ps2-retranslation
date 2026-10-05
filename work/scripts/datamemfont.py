"""The Data Memory's naming grid after the field's windows have drawn over the font
(WT_PoolLevel reuses its letters $527-$562): on the field the next window's tiles are
pointed at the font's letters (WT_END), a field list is opened and closed, then the Data
Memory is entered and the save goes as far as the file-name grid. Savestates on the field
and at the grid; the font tiles in each are compared with the ROM's. Bounded.

    python work/scripts/datamemfont.py [rom]
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa
import ps2art  # noqa
import vramaudit  # noqa
from ps2emu import PS2, ANALYSIS, GAME_SCREEN  # noqa

args = sys.argv[1:]
rom = args.pop(0) if args and args[0].endswith('.bin') else os.path.join(ROOT, 'ps2en.bin')
tag = 'stock_' if 'original' in rom else ''
out = os.path.join(ANALYSIS, 'datamemfont')
WT_END = 0xFFFF8D80
FONT_LETTERS = 322          # WT_PoolLevel: $25E-$2FF, $780-$7FF, $6E0-$6FF, then $527


def font_check(state, label):
    vram = vramaudit.read_state(state)['vram']
    font, _ = ps2art.decompress(open(vramaudit.ROM, 'rb').read(), 0x29EB8)
    bad = [0x500 + t for t in range(0x27, 0x63)
           if vram[0xA000 + t * 32:0xA000 + t * 32 + 32] != font[t * 32:t * 32 + 32]]
    print('%s: %d of the letter tiles $527-$562 differ from the ROM font%s' % (
        label, len(bad), (' ($%X-$%X)' % (bad[0], bad[-1])) if bad else ''), flush=True)
    return bad


with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    ps2emu.open_menu(em)
    depth = em.word(ps2emu.WINDOW_DEPTH)
    em.write(WT_END + 2 * (depth - 1), FONT_LETTERS.to_bytes(2, 'big'))
    ps2emu.run_steps(em, ['0', 'w'], out, tag + 'f')
    ps2emu.save_state(em, os.path.join(out, tag + 'field.state'))
    dirty = font_check(os.path.join(out, tag + 'field.state'), 'field, the list open')
    ps2emu.close_windows(em)
    em.write(0xFFFFF760, (2).to_bytes(2, 'big'))       # the Data Memory
    em.write(GAME_SCREEN, bytes([0x10]))
    em.frames(200)
    ps2emu.run_steps(em, 'C,w,C,w,C,w,C,w,C,w,0'.split(','), out, tag + 's')
    ps2emu.wait_for_naming(em, tries=4)
    em.frames(30)
    em.shot(os.path.join(out, tag + 'grid.png'))
    ps2emu.save_state(em, os.path.join(out, tag + 'grid.state'))
    left = font_check(os.path.join(out, tag + 'grid.state'), 'Data Memory, the naming grid')
if not dirty:
    raise SystemExit('the field never drew over the font: the test proves nothing')
if left:
    raise SystemExit('FAIL: the naming grid draws from overwritten font tiles')
print('ok')

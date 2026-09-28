"""Render tools/proofread.html from proofread_template.html with the game's font, its
character map and the JP character map embedded, so the page works from file:// with no fetch.

    python tools/proofsync.py
"""
import base64
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import ps2art
import gentext
import json

rom = open(os.path.join(ROOT, 'PSII_Disasm', 'ps2original.bin'), 'rb').read()
font, _ = ps2art.decompress(rom, 0x29EB8)            # FontsIconsArt: tiles from VRAM $A000
charmap = rom[0x12BC8:0x12BC8 + 2 * 0xBB]           # VDPCharacterMaps: (top, bottom) per text byte
embed = 'const FONT_B64="%s";\nconst CHARMAP_B64="%s";' % tuple(
    base64.b64encode(x).decode() for x in (font, charmap))
embed += '\nconst OPTIONS=%s;' % json.dumps(gentext.options())   # the budgets follow the build
# the proportional face and the widest each insert can be (linecheck.insert_px)
vwf = os.path.join(ROOT, 'PSII_Disasm', 'vwf')
embed += '\nconst DIAFONT_B64="%s";\nconst DIAWIDTH_B64="%s";' % tuple(
    base64.b64encode(open(os.path.join(vwf, f), 'rb').read()).decode() for f in ('diafont.bin', 'diawidth.bin'))
import linecheck
embed += '\nconst INSERT_PX=%s;' % json.dumps(linecheck.insert_px())
embed += '\nconst LONG_NAME_PX=%s;' % json.dumps(gentext.LONG_NAME_PX)   # long_item_names
tpl =open(os.path.join(HERE, 'proofread_template.html'), encoding='utf-8').read()
out = tpl.replace('/*EMBED*/', embed)
open(os.path.join(HERE, 'proofread.html'), 'w', encoding='utf-8', newline='\n').write(out)
print('wrote tools/proofread.html (%d bytes)' % len(out))

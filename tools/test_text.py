"""Every original string survives the codecs, and the JSON files describe the ROMs.

    python tools/test_text.py

* each dialogue entry's `us` encodes back to its `hex`, which is the stock ROM at `addr`;
* each JP text decodes without an unknown byte ({XX}) and every JP block the JSON names
  is really at its `jp_addr` in the JP ROM;
* every JP block of every bank appears exactly once (paired, continued or unmatched);
* table rows: `us` fits `width`, and uses only its charset.
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import ps2text
import gentext
import extract_dialogue


def main():
    rom = open(os.path.join(ROOT, 'PSII_Disasm', 'ps2original.bin'), 'rb').read()
    jp = open(os.path.join(ROOT, 'work', 'ps2jp_stock.bin'), 'rb').read()
    dia = json.load(open(os.path.join(ROOT, 'work', 'dialogue.json'), encoding='utf-8'))
    scr = json.load(open(os.path.join(ROOT, 'work', 'script.json'), encoding='utf-8'))
    fails = []
    n_us = n_jp = 0
    jp_seen = {}
    for e in dia['entries']:
        data = bytes.fromhex(e['hex'])
        if ps2text.encode_us(e['us']) != data:
            fails.append('%s: us does not encode to hex' % e['id'])
        a = int(e['addr'], 16)
        if rom[a:a + len(data)] != data:
            fails.append('%s: hex is not the ROM at $%s' % (e['id'], e['addr']))
        n_us += 1
        for k in e.get('jp_ids', []):
            jp_seen[k] = jp_seen.get(k, 0) + 1
        if e.get('jp'):
            n_jp += 1
            if re.search(r'\{(?!C[5-7]\})[0-9A-F]{2}\}', e['jp']):
                fails.append('%s: undecodable JP byte in %r' % (e['id'], e['jp'][:40]))
            a = int(e['jp_addr'], 16)
            first = e['jp_ids'][0]
            bank = int(first[:2], 16)
            blocks = extract_dialogue.jp_blocks(jp, int.from_bytes(jp[0x189DA + 4 * bank:0x189DA + 4 * bank + 4], 'big'))
            if not any(b[0] == a for b in blocks):
                fails.append('%s: no JP block starts at $%s' % (e['id'], e['jp_addr']))
    for u in dia['jp_unmatched']:
        jp_seen[u['jp_id']] = jp_seen.get(u['jp_id'], 0) + 1
    total_blocks = 0
    for bank in range(26):
        base = int.from_bytes(jp[0x189DA + 4 * bank:0x189DA + 4 * bank + 4], 'big')
        for addr, data, nums in extract_dialogue.jp_blocks(jp, base):
            total_blocks += 1
            key = '%02X%02X' % (bank, nums[0])
            if jp_seen.get(key) != 1:
                fails.append('JP block %s is used %d times' % (key, jp_seen.get(key, 0)))
    n_rows = 0
    for name, seg in scr['segments'].items():
        enc = gentext.TILE_ENCODE if seg['charset'] == 'tile' else ps2text.US_ENCODE
        for r in seg['runs']:
            texts = r['us'].split('{BR}') if r['kind'] == 'window' else [r['us']]
            widths = r.get('widths', [r['width']])
            for t, w in zip(texts, widths):
                n_rows += 1
                if len(t) > w or any(ch not in enc for ch in t):
                    fails.append('%s: stock row %r does not fit its own budget' % (r['id'], t))
    for f in fails:
        print('FAIL', f)
    print('%d US blocks, %d with JP text, %d JP blocks accounted for, %d table rows: %s'
          % (n_us, n_jp, total_blocks, n_rows, 'FAILED' if fails else 'ok'))
    sys.exit(1 if fails else 0)


if __name__ == '__main__':
    main()

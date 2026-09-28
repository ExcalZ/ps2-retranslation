"""The stock-reproduction check: with every `en` set to its `us`, the source assembles to
the US ROM byte for byte.

    python tools/checkstock.py

Writes the JSON with en = us to temporary files, regenerates every block of ps2.asm from
them (gentext --all), assembles, compares with PSII_Disasm/ps2original.bin, and puts the
translated ps2.asm back (and assembles it again, so ps2.lst matches the source).
"""
import json
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
ASM = os.path.join(ROOT, 'PSII_Disasm', 'ps2.asm')
STOCK = os.path.join(ROOT, 'PSII_Disasm', 'ps2original.bin')


def main():
    tmp = tempfile.mkdtemp()
    saved = os.path.join(tmp, 'ps2.asm')
    shutil.copyfile(ASM, saved)
    try:
        paths = {}
        for name in ('dialogue', 'script'):
            doc = json.load(open(os.path.join(ROOT, 'work', name + '.json'), encoding='utf-8'))
            runs = doc['entries'] if name == 'dialogue' else [r for s in doc['segments'].values() for r in s['runs']]
            for r in runs:
                r['en'] = r['us']
            paths[name] = os.path.join(tmp, name + '.json')
            json.dump(doc, open(paths[name], 'w', encoding='utf-8'), ensure_ascii=False)
        rc = subprocess.call([sys.executable, os.path.join(HERE, 'gentext.py'), '--all',
                              '--dialogue=' + paths['dialogue'], '--script=' + paths['script']])
        if rc:
            raise SystemExit('gentext failed')
        out = os.path.join(tmp, 'stock.bin')
        rc = subprocess.call([sys.executable, os.path.join(HERE, 'sourcebuild.py'), out, '--no-gen'])
        if rc:
            raise SystemExit('assembly failed')
        same = open(out, 'rb').read() == open(STOCK, 'rb').read()
    finally:
        shutil.copyfile(saved, ASM)
        subprocess.call([sys.executable, os.path.join(HERE, 'sourcebuild.py'),
                         os.path.join(tmp, 'restored.bin'), '--no-gen'], stdout=subprocess.DEVNULL)
        shutil.rmtree(tmp, ignore_errors=True)
    print('stock reproduction:', 'byte-identical to ps2original.bin' if same else 'DIFFERS')
    sys.exit(0 if same else 1)


if __name__ == '__main__':
    main()

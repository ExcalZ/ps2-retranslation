"""The stock-reproduction check: with every option in ps2.options.asm at 0 and every `en`
set to its `us`, the source assembles to the US ROM (Rev A) byte for byte.

    python tools/checkstock.py

Writes the JSON with en = us to temporary files, sets the options to 0, regenerates every
block from them (gentext --all), assembles, compares with PSII_Disasm/ps2original.bin, and
puts the sources back (and assembles them again, so ps2.lst matches the source).
"""
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DISASM = os.path.join(ROOT, 'PSII_Disasm')
# every file gentext writes (ext/names.asm takes the party names even with the options at 0),
# put back afterwards
SOURCES = ['ps2.asm', os.path.join('text', 'script.asm'), 'ps2.options.asm',
           os.path.join('ext', 'names.asm'), os.path.join('ext', 'lnames.asm'),
           os.path.join('ext', 'wtstatic.asm')]
STOCK = os.path.join(DISASM, 'ps2original.bin')


def main():
    tmp = tempfile.mkdtemp()
    for f in SOURCES:
        shutil.copyfile(os.path.join(DISASM, f), os.path.join(tmp, os.path.basename(f)))
    try:
        opts = os.path.join(DISASM, 'ps2.options.asm')
        text = open(opts, encoding='latin-1').read()
        open(opts, 'w', encoding='latin-1', newline='\n').write(
            re.sub(r'(?m)^(\w+)\s*=\s*1\b', r'\1 = 0', text))
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
        for f in SOURCES:
            shutil.copyfile(os.path.join(tmp, os.path.basename(f)), os.path.join(DISASM, f))
        subprocess.call([sys.executable, os.path.join(HERE, 'sourcebuild.py'),
                         os.path.join(tmp, 'restored.bin'), '--no-gen'], stdout=subprocess.DEVNULL)
        shutil.rmtree(tmp, ignore_errors=True)
    print('stock reproduction:', 'byte-identical to ps2original.bin' if same else 'DIFFERS')
    sys.exit(0 if same else 1)


if __name__ == '__main__':
    main()

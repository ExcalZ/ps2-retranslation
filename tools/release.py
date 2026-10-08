"""Package the retranslation for distribution: BPS patches + patcher + readme + zip.

    python tools/release.py 1.0 [--rom ps2en.bin] [--allow-stale]

Produces, under release/:

    PS2_Retranslation_v1.0/PS2_Retranslation_v1.0.bps        (from Rev A)
    PS2_Retranslation_v1.0/PS2_Retranslation_v1.0_REV01.bps  (from the first release)
    PS2_Retranslation_v1.0/Patcher.html
    PS2_Retranslation_v1.0/readme.txt
    PS2_Retranslation_v1.0.zip

Two US/European releases exist and differ in 16 bytes (docs/pipeline.md section 2): Rev A
(GM 00005501-02, CRC32 904FA047), which the disassembly reproduces with every option at
0, and the first release (-01, 0D07D0EF). The canonical patch is made against Rev A. A
16-byte BPS from the first release to Rev A is embedded in Patcher.html, which applies it
first when it recognises that dump, so the page takes either; for conventional patchers a
second full patch from the first release is shipped beside the canonical one.

Patches are made with Flips when it is found (flips/flips.exe here or in the sibling
../ps4-translate, both untracked) - its encoder finds more matches - and with
tools/md/bps.py otherwise. Either way tools/md/bps.py re-applies every patch, and the
ROM must come back byte for byte.

The readme is rendered from release/readme_template.txt: every number a player can check
(sizes, CRC32/MD5/SHA-1 of the sources and of the result, the internal checksum, the
date) is a @TOKEN@ filled in from the files, so the text cannot disagree with the patch
beside it. Edit the template, not the rendered readme.

Refuses to package if:
  - the ROM being shipped differs from PSII_Disasm/ps2built.bin (a stale copy), unless
    --allow-stale is given
  - a source ROM's CRC32 is wrong
  - the ROM's internal checksum does not match its header
  - re-applying a patch does not reproduce its target
"""
import datetime
import hashlib
import os
import re
import subprocess
import sys
import tempfile
import zipfile
import zlib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, 'tools', 'md'))
import bin2smd  # noqa: E402
import bps  # noqa: E402
import webpatch  # noqa: E402

NAME = 'PS2_Retranslation'
REVA = os.path.join(ROOT, 'PSII_Disasm', 'ps2original.bin')
REVA_CRC = 0x904FA047
REV01 = os.path.join(ROOT, 'work', 'ps2us_stock.bin')
REV01_CRC = 0x0D07D0EF
BUILT = os.path.join(ROOT, 'PSII_Disasm', 'ps2built.bin')
TEMPLATE = os.path.join(ROOT, 'release', 'readme_template.txt')
PATCHER = os.path.join(ROOT, 'tools', 'md', 'patcher_template.html')
FLIPS = next((p for p in (os.path.join(ROOT, 'flips', 'flips.exe'),
                          os.path.join(os.path.dirname(ROOT), 'ps4-translate', 'flips', 'flips.exe'))
              if os.path.exists(p)), None)
OUTDIR = os.path.join(ROOT, 'release')


def hashes(data):
    return {'SIZE': '{:,}'.format(len(data)), 'CRC32': '%08X' % zlib.crc32(data),
            'MD5': hashlib.md5(data).hexdigest(), 'SHA1': hashlib.sha1(data).hexdigest()}


def md_checksum(rom):
    return sum(int.from_bytes(rom[i:i + 2], 'big') for i in range(0x200, len(rom), 2)) & 0xFFFF


def make_patch(source, target, label, flips=True):
    if FLIPS and flips:
        with tempfile.TemporaryDirectory() as tmp:
            s, t, p = (os.path.join(tmp, n) for n in ('s.bin', 't.bin', 'p.bps'))
            open(s, 'wb').write(source)
            open(t, 'wb').write(target)
            subprocess.run([FLIPS, '--create', '--bps', s, t, p], check=True,
                           stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
            patch = open(p, 'rb').read()
    else:
        patch = bps.create(source, target, label.encode())
    if bps.apply(patch, source) != target:
        sys.exit('%s: the patch does not reproduce its target' % label)
    return patch


def render(template, tokens):
    text = open(template, encoding='utf-8').read()
    for k, v in tokens.items():
        text = text.replace('@%s@' % k, v)
    left = re.findall(r'@[A-Z][A-Z0-9_]*@', text)
    if left:
        sys.exit('%s: unfilled token(s): %s' % (os.path.basename(template), ', '.join(sorted(set(left)))))
    return text


def load(path, crc, what):
    data = open(path, 'rb').read()
    if zlib.crc32(data) != crc:
        sys.exit('%s: CRC32 %08X, expected %08X - not %s' % (path, zlib.crc32(data), crc, what))
    return data


def main(argv):
    if not argv or argv[0].startswith('-'):
        sys.exit(__doc__)
    version = argv[0]
    rom_path = argv[argv.index('--rom') + 1] if '--rom' in argv else os.path.join(ROOT, 'ps2en.bin')

    reva = load(REVA, REVA_CRC, 'Rev A')
    rev01 = load(REV01, REV01_CRC, 'the first US release')
    rom = open(rom_path, 'rb').read()
    if os.path.exists(BUILT) and open(BUILT, 'rb').read() != rom and '--allow-stale' not in argv:
        sys.exit('%s differs from %s - rebuild first, or pass --allow-stale' % (rom_path, BUILT))
    stored = int.from_bytes(rom[0x18E:0x190], 'big')
    if md_checksum(rom) != stored:
        sys.exit('internal checksum %04X does not match stored %04X' % (md_checksum(rom), stored))

    stem = '%s_v%s' % (NAME, version)
    folder = os.path.join(OUTDIR, stem)
    os.makedirs(folder, exist_ok=True)
    label = '%s v%s' % (NAME.replace('_', ' '), version)
    patch = make_patch(reva, rom, label)
    patch01 = make_patch(rev01, rom, label + ' (first release)')
    to_reva = make_patch(rev01, reva, 'first release to Rev A', flips=False)
    names = {'PATCH': stem + '.bps', 'PATCH01': stem + '_REV01.bps'}
    open(os.path.join(folder, names['PATCH']), 'wb').write(patch)
    open(os.path.join(folder, names['PATCH01']), 'wb').write(patch01)

    tokens = dict(names, VERSION=version, DATE=datetime.date.today().strftime('%d.%m.%Y'),
                  MDCHK='%04X' % stored, ROMEND='0x%08X' % int.from_bytes(rom[0x1A4:0x1A8], 'big'))
    for prefix, data in (('SRC_', reva), ('R01_', rev01), ('OUT_', rom), ('SMD_', bin2smd.bin_to_smd(rom))):
        for k, v in hashes(data).items():
            tokens[prefix + k] = v
    text = render(TEMPLATE, tokens)
    readme = os.path.join(folder, 'readme.txt')
    # BOM + CRLF: Notepad-friendly, like the Phantasy Star IV readme.
    open(readme, 'wb').write(('﻿' + text.replace('\r\n', '\n').replace('\n', '\r\n')).encode('utf-8'))

    patcher = os.path.join(folder, 'Patcher.html')
    webpatch.render_patcher(patch, patcher, PATCHER, {
        'TITLE': 'Phantasy Star II',
        'SUBTITLE': 'English Retranslation v%s' % version,
        'GAME': 'Phantasy Star II (USA, Europe)',
        'PATCH': names['PATCH'],
        'OUT_NAME': 'Phantasy Star II - English Retranslation v%s' % version,   # + .bin / .smd
        'README_NOTE': ' See readme.txt.',
        'HINT': ' See readme.txt, section 2.',
    }, alternates=[('the first release, GM 00005501-01', to_reva)])

    zip_path = os.path.join(OUTDIR, stem + '.zip')
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as z:
        for n in (names['PATCH'], names['PATCH01'], 'Patcher.html', 'readme.txt'):
            z.write(os.path.join(folder, n), n)

    print('source  Rev A %s  CRC32 %s; first release CRC32 %s' % (tokens['SRC_SIZE'], tokens['SRC_CRC32'], tokens['R01_CRC32']))
    print('target  %s  CRC32 %s  MD checksum %s' % (tokens['OUT_SIZE'], tokens['OUT_CRC32'], tokens['MDCHK']))
    print('patches %d / %d bytes (%s), %d-byte REV01 -> Rev A in the patcher; all verified by re-applying'
          % (len(patch), len(patch01), 'Flips' if FLIPS else 'tools/md/bps.py', len(to_reva)))
    print('wrote   %s' % folder)
    print('wrote   %s' % zip_path)


if __name__ == '__main__':
    main(sys.argv[1:])

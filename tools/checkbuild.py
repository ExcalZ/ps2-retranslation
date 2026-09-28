"""Build invariants for the translation build.

    python tools/checkbuild.py            # check the current listing against the stock labels
    python tools/checkbuild.py --record   # (on a stock build) write work/stock_labels.json

* Nothing in the stock image moves: every label of ps2.asm outside the relocated script
  must be at the address it has in the stock ROM (work/stock_labels.json, recorded from a
  build with every option at 0). A hook that is not the size of the code it replaces
  shifts everything after it - the sound driver's bank, every savestate - and shows here.
* The stock image differs from the US ROM only inside the hooks: the changed byte ranges
  below $BF6D8 are listed for review.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import asmlist

STOCK = os.path.join(ROOT, 'work', 'stock_labels.json')
STOCK_END = 0xBF6D8          # the stock image ends here (padding follows)


def main():
    labels = asmlist.labels()
    main_labels = {n: a for n, (l, a) in labels.items() if a < STOCK_END}
    if '--record' in sys.argv:
        json.dump(main_labels, open(STOCK, 'w'), indent=0, sort_keys=True)
        print('recorded %d labels' % len(main_labels))
        return
    stock = json.load(open(STOCK))
    script = asmlist.labels()
    moved = []
    for name, addr in stock.items():
        if name not in labels:
            continue                 # a label of the relocated script or an option's branch
        a = labels[name][1]
        if a != addr and a < STOCK_END and not (0x18C4A <= addr < 0x23482):
            moved.append((name, addr, a))
    for name, a, b in sorted(moved, key=lambda m: m[1])[:20]:
        print('MOVED %-28s $%06X -> $%06X' % (name, a, b))
    rom = open(os.path.join(ROOT, 'PSII_Disasm', 'ps2built.bin'), 'rb').read()
    ref = open(os.path.join(ROOT, 'PSII_Disasm', 'ps2original.bin'), 'rb').read()
    runs, st, prev = [], None, None
    for i in range(0x200, STOCK_END):
        if rom[i] != ref[i]:
            if st is None or i > prev + 32:
                if st is not None:
                    runs.append((st, prev))
                st = i
            prev = i
    if st is not None:
        runs.append((st, prev))
    print('stock image: %d changed ranges below $%X (the hooks and the script region)'
          % (len(runs), STOCK_END))
    print('nothing moved' if not moved else '%d labels moved' % len(moved))
    sys.exit(1 if moved else 0)


if __name__ == '__main__':
    main()

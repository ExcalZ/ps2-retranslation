"""Print a dialogue bank for translating: each entry's id, script ids, window and flags,
then its JP, US and current EN text.

    python tools/bankdump.py BANK [--todo]      (--todo: only entries whose en is still us)
    python tools/bankdump.py --list             the banks, their entries and how many are done
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)


def main():
    if hasattr(sys.stdout, 'reconfigure'):
        sys.stdout.reconfigure(encoding='utf-8')
    doc = json.load(open(os.path.join(ROOT, 'work', 'dialogue.json'), encoding='utf-8'))
    entries = doc['entries']
    if '--list' in sys.argv:
        banks = {}
        for e in entries:
            b = banks.setdefault(e['bank'], [0, 0])
            b[0] += 1
            b[1] += e['en'] != e['us']
        for name, (n, done) in banks.items():
            print('%-18s %4d entries, %4d translated' % (name, n, done))
        return
    bank = sys.argv[1]
    todo = '--todo' in sys.argv
    for e in entries:
        if e['bank'] != bank or (todo and e['en'] != e['us']):
            continue
        flags = [k for k in ('falls_through', 'jp_cont', 'window_override', 'us_only', 'jp_only')
                 if e.get(k)]
        extra = ' '.join('%s=%s' % (k, e[k]) for k in flags)
        print('== %s  ids %s  window %s  %s' % (e['id'], ','.join(e['ids']), e.get('window'), extra))
        print('JP ' + (e.get('jp') or ''))
        print('US ' + (e.get('us') or ''))
        if e['en'] != e['us']:
            print('EN ' + e['en'])
        print()


if __name__ == '__main__':
    main()

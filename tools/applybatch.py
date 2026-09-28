"""Merge a batch of translations into work/dialogue.json or work/script.json.

    python tools/applybatch.py batch.json [--script] [--force]

batch.json is an object of id -> en text. Dialogue ids are the entry labels (loc_XXXXX) or
any of the script ids the entry answers to ("1601"); table ids are "items#012" etc.
Every merged entry is checked with linecheck's rules; entries with problems are still
merged (so they can be fixed in the proofreader) but reported, and the exit status is 1.
The JSON files keep their own line endings.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import linecheck


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    script = '--script' in sys.argv
    path = os.path.join(ROOT, 'work', 'script.json' if script else 'dialogue.json')
    raw = open(path, 'rb').read()
    crlf = b'\r\n' in raw
    doc = json.loads(raw.decode('utf-8'))
    batch = json.load(open(args[0], encoding='utf-8'))
    if script:
        by_id = {r['id']: r for seg in doc['segments'].values() for r in seg['runs']}
    else:
        by_id = {}
        for e in doc['entries']:
            by_id[e['id']] = e
            for i in e['ids']:
                by_id[i] = e
    missing = [k for k in batch if k not in by_id]
    if missing:
        raise SystemExit('unknown ids: ' + ', '.join(missing))
    touched = set()
    for k, text in batch.items():
        by_id[k]['en'] = text
        touched.add(by_id[k]['id'])
    out = json.dumps(doc, ensure_ascii=False, indent=1) + '\n'
    if crlf:
        out = out.replace('\n', '\r\n')
    open(path, 'wb').write(out.encode('utf-8'))
    probs = linecheck.table_problems(doc) if script else linecheck.dialogue_problems(doc)
    bad = 0
    for rid in sorted(touched):
        for p in probs.get(rid, []):
            print('%-14s %s' % (rid, p))
            bad += 1
    print('merged %d entries into %s; %d problems' % (len(touched), os.path.relpath(path, ROOT), bad))
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()

"""Extract the game script (GameScriptPtrs, 26 banks) into work/dialogue.json.

    python tools/extract_dialogue.py [--rebuild]

US side: ps2.asm is read for the structure - each bank's offset table (`dc.b A-B ; $nn`)
gives script id -> text label - and the bytes come from the stock ROM between the label's
address and the next label's (addresses from ps2.lst). Ids that share a label (zero-length
table steps) share one entry.

JP side: the JP ROM has the same 26 banks (GameScriptPtrs at $189DA); its messages are
aligned to the US ones bank by bank with a monotone dynamic programme. The US often split
one long JP message over several ids (a message is at most 255 bytes, and the RAM text
buffer 704): such a group gets the JP text on its first entry and `jp_cont` on the others.
Costs: the length of the US group against the JP length times the average ratio, the
insert codes ({NAME}, {ITEM}, ...), a leading {CLR} and the end code of the group's last
message.

Without --rebuild the existing `en` and `note` fields are kept.
"""
import json
import math
import os
import re
import sys
from collections import Counter

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import asmlist
import ps2text

ASM = os.path.join(ROOT, 'PSII_Disasm', 'text', 'script.asm')
OUT = os.path.join(ROOT, 'work', 'dialogue.json')
PAIRING = os.path.join(ROOT, 'work', 'pairing.json')
JP_GSP = 0x189DA
# the final scene's lines are drawn by loc_7932 beside the portraits: 18 cells, 7 lines
ENDING_IDS = ('182A', '182F')      # 1830, the closing line, starts at column 12: 26 cells
GROUP = 3.0          # cost of each extra message in a group, on either side
BANKS = ['ItemAction', 'TechAction', 'EquipAction', 'DataMemory', 'CloneLabs', 'Hospital',
         'WeaponStore', 'ArmorStore', 'ItemStore', 'RolfHouse', 'UstvestiaHouse',
         'InventorHouse', 'TeleportStation', 'CentralTower', 'Room', 'Roof', 'Library',
         'Governor', 'Battle', 'Introduction', 'Opening', 'GameStart', 'People',
         'LevelActions', 'LevelEvents', 'Miscellaneous']

_TABLE = re.compile(r'^\s*(?:dc\.b\s+(\w+)-\w+|scriptofs\s+(\w+),\s*\w+)')
_LABELDEF = re.compile(r'^([A-Za-z_]\w*):')


def us_structure():
    """[(bank index, [label per id])], plus the ordered list of text labels in the region."""
    src = open(ASM, encoding='latin-1').read().split('\n')
    start = next(i for i, l in enumerate(src) if l.startswith('Script_ItemAction:'))
    end = next(i for i in range(start, len(src)) if src[i].strip() == 'charset')
    banks = []
    text_labels = []
    cur = None
    for i in range(start, end):
        line = src[i]
        m = _LABELDEF.match(line)
        if m:
            name = m.group(1)
            if name.startswith('Script_'):
                cur = (BANKS.index(name[7:]), [])
                banks.append(cur)
            else:
                text_labels.append((name, i + 1))
            continue
        t = _TABLE.match(line)
        if t and cur is not None:
            cur[1].append(t.group(1) or t.group(2))
    return banks, text_labels, (start + 1, end + 1)


def jp_blocks(rom, base):
    """The bank's messages as non-overlapping blocks: [(addr, bytes, [id numbers])], one per
    distinct start address in address order, each running to the next start (or through
    its end code for the last). A block without an end code falls through into the next:
    that is how both versions show text longer than one table step allows."""
    n = rom[base]
    starts = {}
    p = base
    for k in range(n):
        p += rom[base + k]
        starts.setdefault(p, []).append(k + 1)
    order = sorted(starts)
    out = []
    for i, a in enumerate(order):
        if i + 1 < len(order):
            b = order[i + 1]
        else:
            b = a
            while rom[b] < 0xC4:
                b += 1
            b += 1
        out.append((a, rom[a:b], starts[a]))
    return out


def cut_tail(data):
    """(message bytes through the first end code, the dead bytes after it)."""
    for i, b in enumerate(data):
        if b >= 0xC4:
            return data[:i + 1], data[i + 1:]
    return data, b''


def plain_len(text):
    return len(re.sub(r'\{[^}]*\}', '', text).replace(' ', ''))


def sig(text):
    c = Counter(re.findall(r'\{(NAME2?|ENEMY|TECH|ITEM|MESETA)\}', text))
    return c


def end_code(text):
    m = re.search(r'\{([^}]*)\}$', text)
    return m.group(1) if m else ''


def align(us, jp, ratio):
    """us, jp: lists of decoded texts. Many-to-many monotone alignment: a group is k US
    messages against l JP messages (k <= 8, l <= 3), or a message of one side alone.
    Returns groups: list of (us indices, jp indices)."""
    n, m = len(us), len(jp)
    INF = float('inf')
    best = [[INF] * (m + 1) for _ in range(n + 1)]
    back = [[None] * (m + 1) for _ in range(n + 1)]
    best[0][0] = 0.0
    SKIP = 6.0
    ulen = [max(plain_len(t), 1) for t in us]
    jlen = [max(plain_len(t), 1) * ratio for t in jp]
    usig = [sig(t) for t in us]
    jsig = [sig(t) for t in jp]
    for i in range(n + 1):
        for j in range(m + 1):
            c0 = best[i][j]
            if c0 == INF:
                continue
            if i < n and c0 + SKIP < best[i + 1][j]:
                best[i + 1][j] = c0 + SKIP
                back[i + 1][j] = (i, j)
            if j < m and c0 + SKIP < best[i][j + 1]:
                best[i][j + 1] = c0 + SKIP
                back[i][j + 1] = (i, j)
            for l in range(1, 4):
                if j + l > m:
                    break
                jl = sum(jlen[j:j + l])
                js = sum((jsig[x] for x in range(j, j + l)), Counter())
                ul = 0
                us_ = Counter()
                for k in range(1, 9):
                    if i + k > n:
                        break
                    ul += ulen[i + k - 1]
                    us_ += usig[i + k - 1]
                    cost = abs(math.log(ul / jl)) * 3
                    cost += 1.5 * sum(abs(us_[t] - js[t]) for t in set(us_) | set(js))
                    if us[i].startswith('{CLR}') != jp[j].startswith('{CLR}'):
                        cost += 1.5
                    if end_code(us[i + k - 1]) != end_code(jp[j + l - 1]):
                        cost += 2.0
                    cost += GROUP * (k - 1) + GROUP * (l - 1)
                    if c0 + cost < best[i + k][j + l]:
                        best[i + k][j + l] = c0 + cost
                        back[i + k][j + l] = (i, j)
    groups = []
    i, j = n, m
    while (i, j) != (0, 0):
        pi, pj = back[i][j]
        groups.append((list(range(pi, i)), list(range(pj, j))))
        i, j = pi, pj
    groups.reverse()
    return groups


def lines_per_wait(text):
    """The most lines shown between two button waits."""
    best = 0
    for chunk in re.split(r'\{(?:PAGE|END|CLR)\}', text):
        best = max(best, chunk.count('{BR}') + 1)
    return best


def main():
    rebuild = '--rebuild' in sys.argv
    lab = asmlist.labels()
    rom = asmlist.rom()
    jp_rom = open(os.path.join(ROOT, 'work', 'ps2jp_stock.bin'), 'rb').read()
    banks, text_labels, region = us_structure()
    assert [b for b, _ in banks] == list(range(26)), 'bank order'
    built = os.path.join(ROOT, 'PSII_Disasm', 'ps2built.bin')
    if not os.path.exists(built) or open(built, 'rb').read() != rom:
        raise SystemExit('extraction reads the stock text through the listing: run it on a stock '
                         'build (every en = us: python tools/sourcebuild.py --no-gen after '
                         'restoring ps2.asm), not on a translated one')
    stale = [n for n, line in text_labels if lab[n][0] != line]
    if stale:
        raise SystemExit('PSII_Disasm/ps2.lst does not match ps2.asm (%s...): assemble first '
                         '(python tools/sourcebuild.py --no-gen)' % stale[0])

    # label -> bytes: from the label to the end of its dc.b lines (the address of the line
    # after the last one, from the listing), ids per label
    src = open(ASM, encoding='latin-1').read().split('\n')
    addrs = asmlist.line_addrs(asmlist.SCRIPT)
    blocks = {}
    for k, (name, line) in enumerate(text_labels):
        nxt = text_labels[k + 1][1] if k + 1 < len(text_labels) else region[1]
        for other in range(line, nxt):          # a Script_ label or a charset ends it too
            if src[other].startswith('Script_') or src[other].strip() == 'charset':
                nxt = other + 1
                break
        last = max(i for i in range(line, nxt - 1) if re.match(r'^\s*dc\.b', src[i]))
        a = lab[name][1]
        b = addrs[last + 2]
        blocks[name] = (a, rom[a:b], line)
    ids = {}
    for bank, table in banks:
        for n, name in enumerate(table, 1):
            ids.setdefault(name, []).append('%02X%02X' % (bank, n))

    # JP messages per bank
    jp_ptrs = [int.from_bytes(jp_rom[JP_GSP + 4 * k:JP_GSP + 4 * k + 4], 'big') for k in range(26)]
    jp_banks = [jp_blocks(jp_rom, p) for p in jp_ptrs]

    # the length ratio, from the banks whose message counts agree
    tu = tj = 0
    for bank, table in banks:
        if len(table) == len(jp_banks[bank]):
            for name, (addr, msg, _) in zip(table, jp_banks[bank]):
                tu += plain_len(ps2text.decode_us(cut_tail(blocks[name][1])[0]))
                tj += plain_len(ps2text.decode_jp(cut_tail(msg)[0]))
    ratio = tu / tj

    old = {}
    if os.path.exists(OUT) and not rebuild:
        for e in json.load(open(OUT, encoding='utf-8'))['entries']:
            old[e['id']] = e

    pairing = {}
    if os.path.exists(PAIRING):
        pairing = json.load(open(PAIRING, encoding='utf-8'))

    entries = []
    unmatched_jp = []
    seen = set()
    stats = Counter()
    for bank, table in banks:
        # unique labels of the bank in id order (aliases collapse), both sides
        uniq = []
        for name in table:
            if name not in uniq:
                uniq.append(name)
        us_txt = [ps2text.decode_us(cut_tail(blocks[n][1])[0]) for n in uniq]
        jp_uniq = jp_banks[bank]
        jp_txt = [ps2text.decode_jp(cut_tail(u[1])[0]) for u in jp_uniq]
        jp_key = ['%02X%02X' % (bank, u[2][0]) for u in jp_uniq]

        # anchors (US label -> JP id) split the bank; the DP aligns each stretch between
        # them. `us_only` / `jp_only` take messages out of the alignment altogether.
        us_only = set(pairing.get('us_only', []))
        jp_only = set(pairing.get('jp_only', []))
        fixed = [g for g in pairing.get('groups', []) if g[0][0] in uniq]
        fixed_us = {n for g in fixed for n in g[0]}
        fixed_jp = {j for g in fixed for j in g[1]}
        anchors = pairing.get('anchors', {})
        ui_live = [i for i, n in enumerate(uniq) if n not in us_only and n not in fixed_us]
        jp_live = [j for j, k in enumerate(jp_key) if k not in jp_only and k not in fixed_jp]
        cuts = [(0, 0)]
        for pos, ui in enumerate(ui_live):
            if uniq[ui] in anchors:
                cuts.append((pos, jp_live.index(jp_key.index(anchors[uniq[ui]]))))
        cuts.append((len(ui_live), len(jp_live)))
        groups = [([i], []) for i, n in enumerate(uniq) if n in us_only]
        groups += [([], [j]) for j, k in enumerate(jp_key) if k in jp_only]
        groups += [([uniq.index(n) for n in us_], [jp_key.index(k) for k in jp_]) for us_, jp_ in fixed]
        for (i0, j0), (i1, j1) in zip(cuts, cuts[1:]):
            assert i1 >= i0 and j1 >= j0, 'anchors out of order in ' + BANKS[bank]
            sub = align([us_txt[i] for i in ui_live[i0:i1]], [jp_txt[j] for j in jp_live[j0:j1]], ratio)
            for us_idx, jp_idx in sub:
                groups.append(([ui_live[i0 + x] for x in us_idx], [jp_live[j0 + x] for x in jp_idx]))

        pair = {}
        for us_idx, jp_idx in groups:
            if not us_idx:
                for j in jp_idx:
                    unmatched_jp.append({'bank': BANKS[bank], 'jp_id': jp_key[j],
                                         'jp_addr': '%05X' % jp_uniq[j][0], 'jp': jp_txt[j]})
                    stats['jp_only'] += 1
                continue
            for k, ui in enumerate(us_idx):
                if not jp_idx:
                    pair[uniq[ui]] = None
                    stats['us_only'] += 1
                elif k == 0:
                    pair[uniq[ui]] = (jp_idx, len(us_idx))
                    stats['%d:%d' % (len(us_idx), len(jp_idx))] += 1
                else:
                    pair[uniq[ui]] = ('cont', uniq[us_idx[0]])
        for name in uniq:
            if name in seen:
                continue
            seen.add(name)
            addr, data, line = blocks[name]
            msg, tail = cut_tail(data)
            us = ps2text.decode_us(msg)
            assert ps2text.encode_us(us) == msg, name
            e = {'id': name, 'ids': ids[name], 'bank': BANKS[bank], 'addr': '%05X' % addr}
            p = pair.get(name)
            jp_text = ''
            if p is None:
                e['jp_ids'] = []
            elif p[0] == 'cont':
                e['jp_cont'] = p[1]
            else:
                jp_idx, glen = p
                e['jp_ids'] = [jp_key[j] for j in jp_idx]
                e['jp_addr'] = '%05X' % jp_uniq[jp_idx[0]][0]
                jp_text = ''.join(jp_txt[j] for j in jp_idx)
                e['jp'] = jp_text
                if glen > 1:
                    e['us_parts'] = glen
            lines = max(lines_per_wait(us), lines_per_wait(jp_text))
            if any(ENDING_IDS[0] <= i <= ENDING_IDS[1] for i in ids[name]):
                e['window'] = 'ending'
            elif '1830' in ids[name]:
                e['window'] = 'finale'
            elif BANKS[bank] == 'Battle' and lines == 1:
                e['window'] = 'battle'
            elif lines > 2:
                e['window'] = 'big'
            else:
                e['window'] = 'dialogue'
            e['us'] = us
            prev = old.get(name, {})
            e['en'] = prev.get('en', us)
            for keep in ('note', 'window_override'):
                if prev.get(keep):
                    e[keep] = prev[keep]
            if msg[-1] < 0xC4:
                e['falls_through'] = True
            e['hex'] = msg.hex()
            if tail:
                e['tail'] = tail.hex()
            entries.append(e)

    # a fall-through chain is one message in one window: the largest any part asks for
    order = ['battle', 'dialogue', 'big', 'ending', 'finale']
    chain = []
    for e in entries:
        chain.append(e)
        if not e.get('falls_through'):
            w = max((x['window'] for x in chain), key=order.index)
            for x in chain:
                x['window'] = w
            chain = []

    doc = {
        'format': 'ps2 dialogue v1',
        'notes': 'Edit only `en`. {BR} next line, {PAGE} wait for a button and scroll one line, '
                 '{CLR} clear the window; {NAME} {NAME2} {ENEMY} {TECH} {ITEM} {MESETA} are inserts; '
                 'every message ends in {END} (wait, close), {C5} (close at once: a prompt follows), '
                 '{C6} (button or timeout, close all windows) or {C7} (timeout). '
                 'A message continues in the same window when the code queues the next id, so an entry '
                 'with `jp_cont` carries on the Japanese message of the entry it names.',
        'ratio': round(ratio, 3),
        'entries': entries,
        'jp_unmatched': unmatched_jp,
    }
    text = json.dumps(doc, ensure_ascii=False, indent=1) + '\n'
    open(OUT, 'w', encoding='utf-8', newline='\n').write(text)
    print('wrote %s: %d entries (%d ids); ratio %.3f; %s' % (
        os.path.relpath(OUT, ROOT), len(entries), sum(len(e['ids']) for e in entries), ratio, dict(stats)))


if __name__ == '__main__':
    main()

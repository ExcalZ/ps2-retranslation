"""Bounded check of the shops' party marks and comparison (shop_equip_compare,
ext/shopequip.asm), in the Paseo weapon and armor shops with four members in
different gear:

* every item of each list: the party window's marks (read from SH_SHOWN) against a
  model of the rule - 0 cannot equip, 1 right (main stat as it is), 2 up, 3 down;
  Attack in the weapon shop, Defense in the armor shop, a one-handed item in the hand
  holding the shop's kind of thing (or nothing) that holds the least of it;
* the Who? list: the comparison (EQ_SHOWN) for each member;
* the stack after "anything else?" Yes and after No to gear one cannot equip
  (shop_no_reprompt): the party window stays, once; the comparison closes.

Every cursor move, wait and press is bounded and checked against RAM; screenshots go
to work/analysis/shopequip/.

    python work/scripts/shopequip.py [rom]
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa: E402

rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
out = os.path.join(ps2emu.ANALYSIS, 'shopequip')
os.makedirs(out, exist_ok=True)

CHAR = 0xFFFFC000
EVENT = 0xFFFFDE58
CURSOR = 0xFFFFDE50
STORE_LENGTH = 0xFFFFF764
STORE_TABLE = 0xFFFFF766
BUILDING = 0xFFFFF760
STACK = 0xFFFFDF0E
SHOWN = 0xFFFF8FF6           # SH_SHOWN: a mark per member
EQ_SHOWN = 0xFFFF8E6C        # attack now/then, defense now/then, agility now/then
PARTY, CMP, ITEMS, WHO, YESNO = 0x76, 0x77, 40, 91, 31
OPEN = [60, 35, 33]          # portrait, meseta, dialogue
MARKS = '->^v'               # none, right, up, down

image = open(rom, 'rb').read()
INV = ps2emu.listing_address('InventoryData')
TABLES = ps2emu.listing_address('StoreEquipItemArray')


def item(i):
    """(type, who-bits, attack, defense) of item i, from the ROM."""
    r = image[INV + 16 * (i & 0x7F):INV + 16 * (i & 0x7F) + 16]
    return r[12] & 7, r[13], r[14], r[15]


def sums(slots):
    return sum(item(s)[2] for s in slots if s), sum(item(s)[3] for s in slots if s)


def equip(slots, i, hand):
    """EQ_Simulate's slots with item i on: hand 1 right, 2 left (index in slots)."""
    s = list(slots)
    kind = item(i)[0]
    if kind == 3:
        s[1] = s[2] = i
    elif kind == 2:
        held = s[hand]
        if held and item(held)[0] == 3:
            s[1] = s[2] = 0
        s[hand] = i
    else:
        s[{1: 0, 4: 3, 5: 4}[kind]] = i
    return s


def hand_for(slots, i, armor):
    stat = 3 if armor else 2
    order = (2, 1) if armor else (1, 2)
    for strict in (True, False):
        best = None
        for h in order:
            held = slots[h]
            if held and strict and (item(held)[2] != 0) == armor:
                continue
            v = item(held)[stat] if held else 0
            if best is None or v < best[0]:
                best = (v, h)
        if best:
            return best[1]
    raise AssertionError


def model(char, slots, i, armor):
    kind, who, _, _ = item(i)
    if not 1 <= kind <= 5 or not who >> char & 1:
        return 0, None
    hand = hand_for(slots, i, armor) if kind == 2 else 1
    now, then = sums(slots), sums(equip(slots, i, hand))
    k = 1 if armor else 0
    return (1 if then[k] == now[k] else 2 if then[k] > now[k] else 3), (now, then)


def stack(em):
    return [em.word(STACK + 16 * i) for i in range(em.word(ps2emu.WINDOW_DEPTH))]


def wait_stack(em, want, where, tries=150):
    for _ in range(tries):
        if stack(em) == want and not em.word(ps2emu.WINDOW_INDEX):
            return
        em.frames(2)
    raise RuntimeError('%s: windows %s, wanted %s' % (where, stack(em), want))


def cursor_to(em, index, tries=12):
    for _ in range(tries):
        cur = em.read(CURSOR, 1)[0]
        if cur == index:
            em.frames(4)
            return
        em.press('D' if index > cur else 'U', hold=2, release=10)
    raise RuntimeError('the cursor stays at %d, wanted %d' % (em.read(CURSOR, 1)[0], index))


def shot(em, name):
    em.frames(2)
    em.shot(os.path.join(out, name + '.png'))


# the party: Eusis, Nei, Rudger, Anne (copies of Eusis' record), in their own gear
GEAR = {0: [0, 0x56, 0, 0, 0],          # Knife
        1: [0, 0x59, 0, 0, 0],          # Steel Claw
        2: [0x17, 0x6F, 0x47, 0x2C, 0],  # Headgear, Sonic Gun, Carbon Shield, Carbon Vest
        3: [0, 0, 0, 0, 0]}             # nothing


def setup(em):
    ps2emu.boot_to_field(em)
    base = bytearray(em.read(CHAR, 0x40))
    a0, d0 = sums(base[0x20:0x25])
    for c, slots in GEAR.items():
        rec = bytearray(base)
        a, d = sums(slots)
        rec[0x1C:0x1E] = (int.from_bytes(rec[0x1A:0x1C], 'big') + a).to_bytes(2, 'big')
        rec[0x1E:0x20] = (int.from_bytes(base[0x1E:0x20], 'big') - d0 + d).to_bytes(2, 'big')
        rec[0x20:0x25] = bytes(slots)
        rec[0x27] = 0                   # empty inventories: room for a purchase
        em.write(CHAR + 64 * c, bytes(rec))
    em.write(0xFFFFC600, (3).to_bytes(2, 'big'))
    em.write(0xFFFFC608, bytes([0, 0, 0, 1, 0, 2, 0, 3]))
    em.write(0xFFFFC620, (99999).to_bytes(4, 'big'))


def check_list(em, table, armor, tag):
    ids = image[TABLES + 6 * table:TABLES + 6 * table + 6]
    for row, i in enumerate(ids):
        cursor_to(em, row)
        em.frames(6)
        got = list(em.read(SHOWN, 4))
        want = [model(c, GEAR[c], i, armor)[0] for c in range(4)]
        shot(em, '%s_item%d' % (tag, row))
        print('%s item %d ($%02X): marks %s, model %s' % (
            tag, row, i, ''.join(MARKS[m] for m in got), ''.join(MARKS[m] for m in want)), flush=True)
        if got != want:
            raise RuntimeError('%s item %d: marks %s, wanted %s' % (tag, row, got, want))
    return ids


def check_who(em, i, armor, tag):
    for c in range(4):
        cursor_to(em, c)
        em.frames(6)
        got = [int.from_bytes(em.read(EQ_SHOWN + 2 * k, 2), 'big') for k in range(6)]
        mark, nt = model(c, GEAR[c], i, armor)
        rec = em.read(CHAR + 64 * c, 0x20)
        now = [int.from_bytes(rec[o:o + 2], 'big') for o in (0x1C, 0x1E, 0x14)]
        if nt is None:
            want = [now[0], 0xFFFF, now[1], 0xFFFF, now[2], 0xFFFF]
        else:
            (an, dn), (at, dt) = nt
            want = [now[0], now[0] - an + at, now[1], now[1] - dn + dt, now[2], now[2]]
        shot(em, '%s_who%d' % (tag, c))
        print('%s who %d: %s, model %s' % (tag, c, got, want), flush=True)
        if got[:4] != want[:4] or got[4] != want[4] or (nt is None) != (got[5] == 0xFFFF):
            raise RuntimeError('%s who %d: comparison %s, wanted %s' % (tag, c, got, want))


def open_shop(em, building, table):
    em.write(STORE_LENGTH, (5).to_bytes(2, 'big'))
    em.write(STORE_TABLE, table.to_bytes(2, 'big'))
    em.write(BUILDING, building.to_bytes(2, 'big'))
    em.write(ps2emu.GAME_SCREEN, bytes([0x10]))
    em.frames(200)
    wait_stack(em, OPEN + [PARTY, ITEMS], 'opening')
    if em.word(0xFFFF8E30):
        raise RuntimeError('the shop ran out of VWF tiles')


def choose(em, row, want, where):
    cursor_to(em, row)
    em.press('C', hold=2, release=60)
    wait_stack(em, want, where)         # the message runs on by itself


with ps2emu.PS2(rom) as em:
    setup(em)
    # the weapon shop
    open_shop(em, 5, 2)
    ids = check_list(em, 2, False, 'weapon')
    choose(em, 0, OPEN + [PARTY, ITEMS, CMP, WHO], 'weapon: Who? for the Knife')
    check_who(em, ids[0], False, 'weapon')
    # Anne buys the Knife; "anything else?" Yes: back to the list, the comparison closed
    cursor_to(em, 3)
    em.press('C', hold=2, release=60)
    wait_stack(em, OPEN + [PARTY, ITEMS, CMP, WHO, YESNO], 'weapon: anything else?', 300)
    em.press('C', hold=2, release=60)   # Yes
    wait_stack(em, OPEN + [PARTY, ITEMS], 'weapon: after Yes')
    if em.read(CHAR + 3 * 64 + 0x27, 2) != bytes([1, ids[0]]):
        raise RuntimeError('Anne did not get the Knife')
    shot(em, 'weapon_again')
    # the Dagger for Eusis, who cannot equip it: No returns to the list (one party window)
    choose(em, 1, OPEN + [PARTY, ITEMS, CMP, WHO], 'weapon: Who? for the Dagger')
    check_who(em, ids[1], False, 'dagger')
    cursor_to(em, 0)
    em.press('C', hold=2, release=60)
    wait_stack(em, OPEN + [PARTY, ITEMS, CMP, WHO, YESNO], 'weapon: cannot equip, buy?', 300)
    shot(em, 'weapon_warning')
    em.press('B', hold=2, release=60)   # No
    wait_stack(em, OPEN + [PARTY, ITEMS], 'weapon: after No', 300)
    check_list(em, 2, False, 'weapon_after_no')
    print('weapon shop passed', flush=True)

with ps2emu.PS2(rom) as em:
    setup(em)
    open_shop(em, 6, 1)
    ids = check_list(em, 1, True, 'armor')
    choose(em, 4, OPEN + [PARTY, ITEMS, CMP, WHO], 'armor: Who? for the Carbon Shield')
    check_who(em, ids[4], True, 'armor')
    if em.word(0xFFFF8E30):
        raise RuntimeError('the shop ran out of VWF tiles')
    print('armor shop passed', flush=True)

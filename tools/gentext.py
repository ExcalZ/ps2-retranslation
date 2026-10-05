"""Write work/dialogue.json into PSII_Disasm/text/script.asm and work/script.json into
PSII_Disasm/ps2.asm.

    python tools/gentext.py [--check] [--all] [--dialogue=PATH] [--script=PATH]

Dialogue: every entry is the block of `dc.b` lines after its label; the block is
regenerated from `en` (plus the dead `tail` bytes the stock ROM has after some end codes).
Tables: every run is one or more string lines of its segment, found by ordinal
(`rows`); each is rewritten with `en`, padded to its fixed width.

Only entries whose `en` differs from the text the source currently holds are rewritten
(--all regenerates everything), so the disassembly's own comments survive on untouched
blocks. With every `en` equal to `us` the ROM is the stock one.

--check reports what would change and every budget problem, and writes nothing.
Exit status 1 if an entry cannot be encoded or does not fit its hard limits.
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import ps2text

ASM = os.path.join(ROOT, 'PSII_Disasm', 'ps2.asm')
SCRIPT_ASM = os.path.join(ROOT, 'PSII_Disasm', 'text', 'script.asm')
DIALOGUE = os.path.join(ROOT, 'work', 'dialogue.json')
SCRIPT = os.path.join(ROOT, 'work', 'script.json')

def options():
    """The flags of PSII_Disasm/ps2.options.asm as {name: int}."""
    out = {}
    for line in open(os.path.join(ROOT, 'PSII_Disasm', 'ps2.options.asm'), encoding='latin-1'):
        m = re.match(r'^(\w+)\s*=\s*(\d+)', line)
        if m:
            out[m.group(1)] = int(m.group(2))
    return out


OPTIONS = options()
# a stock table step is one byte: a message block is at most 255 bytes (long_script_offsets
# stores a pointer per message instead)
MSG_MAX = None if OPTIONS.get('long_script_offsets') else 255
# text_buffer .. sound_ram; paged_text_buffer expands a page at a time and keeps its resume
# state in the buffer's last eight bytes, and vwf_dialogue its canvas at +$180
PAGED = bool(OPTIONS.get('paged_text_buffer'))
BUFFER_MAX = 0x180 if PAGED else 0xD000 - 0xCD40
INSERT_BYTES = {0xBB: 4, 0xBC: 4, 0xBD: 10, 0xBE: 5, 0xBF: 10, 0xC0: 6}

# long_item_names: the item, technique and enemy names are drawn from tables of their own
# (ext/lnames.asm, pointers by record number); the records keep the stock names. A name is
# held to the pixels of the cells the stock one had in the windows.
LONG_ITEM_NAMES = bool(OPTIONS.get('long_item_names'))
# segment: (table, the records' label, record size, the pixels the stock cells give it)
LONG_TABLES = {
    'items': ('LN_Items', 'InventoryData', 16, 80),
    'techs': ('LN_Techs', 'TechniqueData', 8, 48 if OPTIONS.get('wide_techs') else 40),   # wide_techs: six cells
    'enemies': ('LN_Enemies', 'EnemyNames', 10, 80),
    'teleport': ('LN_Places', 'TeleportPlaceNamesArray', 5, 40),      # the teleport list
    'soundtracks': ('LN_Tracks', 'SoundtrackCharArray', 12, 96),      # Ustvestia's list
    'jobs': ('LN_Jobs', 'loc_11456', 8, 64),                          # WT_JobRun: LV/EXP window
}
LONG_SEGS = {seg: t[0] for seg, t in LONG_TABLES.items()}
LONG_NAME_PX = {seg: t[3] for seg, t in LONG_TABLES.items()}
LONG_NAMES_ASM = os.path.join(ROOT, 'PSII_Disasm', 'ext', 'lnames.asm')
LONG_INSERT = {'enemies': 0xBD, 'techs': 0xBE, 'items': 0xBF}
if OPTIONS.get('long_names'):
    INSERT_BYTES[0xBB] = INSERT_BYTES[0xBC] = 6


def long_insert_bytes(doc):
    """long_item_names: an {ENEMY}, {TECH} or {ITEM} insert is as long as its table's
    longest name."""
    for seg, b in LONG_INSERT.items():
        INSERT_BYTES[b] = max(len(r['en']) for r in doc['segments'][seg]['runs'])

# ---- string emission --------------------------------------------------------
SCRIPT_SAFE = set('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 ,.;?!\'-:')
# what a name may hold where it is written as bytes (ext/lnames.asm, the window runs): the
# string-literal set plus the letters the source's charset lacks (Ä ä, $48-$49)
NAME_SAFE = SCRIPT_SAFE | set('Ää')
TILE_ENCODE = {' ': 0x26, ',': 0x5B, '.': 0x5C, ';': 0x5D, '"': 0x5E, '?': 0x5F, '!': 0x60,
               "'": 0x61, '-': 0x62, '/': 0x64, ':': 0x80}
for _i in range(26):
    TILE_ENCODE[chr(65 + _i)] = 0x27 + _i
    TILE_ENCODE[chr(97 + _i)] = 0x41 + _i
for _i in range(10):
    TILE_ENCODE[chr(48 + _i)] = 0x76 + _i
TILE_SAFE = set(TILE_ENCODE) - {'"'}


def dcb_operands(data, safe, decode):
    """Bytes -> dc.b operand list: printable runs as strings, the rest as $XX."""
    ops = []
    run = ''
    for b in data:
        ch = decode.get(b)
        if ch is not None and ch in safe:
            run += ch
        else:
            if run:
                ops.append('"%s"' % run)
                run = ''
            ops.append('$%02X' % b)
    if run:
        ops.append('"%s"' % run)
    return ops


def dialogue_lines(data):
    """The generated block for one message: text runs and control bytes, one per line,
    in the style of the disassembly."""
    out = []
    cur = bytearray()

    def flush():
        if cur:
            ops = dcb_operands(bytes(cur), SCRIPT_SAFE, ps2text.US_DECODE)
            for k in range(0, len(ops), 16):
                out.append('\tdc.b\t' + ', '.join(ops[k:k + 16]))
            cur.clear()
    for b in data:
        if b in ps2text.CONTROLS or b >= 0xC4:
            flush()
            out.append('\tdc.b\t$%02X' % b)
        else:
            cur.append(b)
    flush()
    return out


def expanded_size(data):
    """Bytes LoadScript writes into text_buffer for this message: all of it (stock), or its
    largest page (paged_text_buffer: a page after a wait starts with two line feeds)."""
    n = best = 0
    for b in data:
        if b in INSERT_BYTES:
            n += INSERT_BYTES[b]
        elif b == 0xC1:
            n += 2
        elif b == 0xC3:
            if PAGED:
                best = max(best, n + 1)
                n = 2
                continue
            n += 3
        else:
            n += 1
        if b >= 0xC4:
            break
    return max(best, n)


# ---- dialogue ------------------------------------------------------------------
_LABELDEF = re.compile(r'^([A-Za-z_]\w*):')
_OPERAND = re.compile(r'\s*("(?:[^"]*)"|\$[0-9A-Fa-f]+|\d+)\s*(?:,|$)')


def block_bytes(lines):
    """The bytes a block of `dc.b` lines assembles to under the script charset, or None
    when a line holds anything but strings and numbers (then it is regenerated)."""
    out = bytearray()
    for line in lines:
        code = re.sub(r'^((?:[^;"]|"[^"]*")*);.*$', r'\1', line).strip()   # a ; outside quotes
        code = code.replace('\\I', '\x01')           # the source's escape for " (a placeholder here)
        if not code:
            continue
        m = re.match(r'dc\.b\s+(.*)$', code)
        if not m:
            return None
        rest = m.group(1)
        pos = 0
        while pos < len(rest):
            o = _OPERAND.match(rest, pos)
            if not o:
                return None
            tok = o.group(1)
            if tok.startswith('"'):
                for ch in tok[1:-1].replace('\x01', '"'):
                    if ch not in ps2text.US_ENCODE:
                        return None
                    out.append(ps2text.US_ENCODE[ch])
            else:
                out.append(int(tok[1:], 16) if tok.startswith('$') else int(tok))
            pos = o.end()
    return bytes(out)


def apply_dialogue(src, doc, force, problems, log):
    labels = {}
    for i, line in enumerate(src):
        m = _LABELDEF.match(line)
        if m:
            labels[m.group(1)] = i
    label_lines = sorted(labels.values())
    changed = 0
    entries = doc['entries']
    for n, e in enumerate(entries):
        last_in_bank = n + 1 == len(entries) or entries[n + 1]['bank'] != e['bank']
        if e.get('added') and not e['en']:
            continue            # a message the stock game lacks (checkstock: en = us = ''); its block is under an option
        try:
            data = ps2text.encode_us(e['en'])
        except ValueError as ex:
            problems.append('%s: %s' % (e['id'], ex))
            continue
        # the stock text keeps its own ending (0D05 has none in either release: a bug the
        # translation fixes by ending it)
        if (not data or data[-1] < 0xC4) and not e.get('falls_through') and e['en'] != e['us']:
            problems.append('%s: must end in an end code ({END}, {C5}, {C6}, {C7})' % e['id'])
            continue
        if any(b >= 0xC4 for b in data[:-1]):
            problems.append('%s: end code before the end of the message' % e['id'])
            continue
        # (010B ends in the US release; the translation runs it on into 010C as the JP does)
        if e.get('falls_through') and data[-1] >= 0xC4 and e['en'] != e['us']:
            problems.append('%s: falls through into the next entry: must not end in an end code' % e['id'])
        tail = bytes.fromhex(e.get('tail', ''))
        if MSG_MAX and len(data) + len(tail) > MSG_MAX and not last_in_bank and e['en'] != e['us']:
            problems.append('%s: %d bytes, a message is at most %d' % (e['id'], len(data) + len(tail), MSG_MAX))
        i = labels[e['id']]
        nxt = next((l for l in label_lines if l > i), len(src))
        nxt = min(nxt, next(k for k in range(i, len(src)) if src[k].strip() == 'charset'))
        j = max(k for k in range(i + 1, nxt) if re.match(r'^\s*dc\.b', src[k]))
        if not force and block_bytes(src[i + 1:j + 1]) == data + tail:
            continue            # the source already holds this text (in its own layout)
        new = dialogue_lines(data)
        if tail:
            new.append('; unused bytes of the stock ROM')
            for k in range(0, len(tail), 16):
                new.append('\tdc.b\t' + ', '.join('$%02X' % b for b in tail[k:k + 16]))
        if src[i + 1:j + 1] != new:
            src[i + 1:j + 1] = new
            delta = len(new) - (j - i)
            for k, v in labels.items():
                if v > i:
                    labels[k] = v + delta
            label_lines = sorted(labels.values())
            changed += 1
    # the RAM text buffer holds a whole chain of fall-through blocks
    chain = bytearray()
    first = None
    touched = False
    for e in doc['entries']:
        try:
            data = ps2text.encode_us(e['en'])
        except ValueError:
            continue
        if first is None:
            first = e['id']
        chain += data
        touched |= e['en'] != e['us']
        if not e.get('falls_through'):
            size = expanded_size(bytes(chain))
            if size > BUFFER_MAX:
                msg = '%s: the message expands to %d bytes in text_buffer (at most %d)' % (first, size, BUFFER_MAX)
                if touched:
                    problems.append(msg)
                else:
                    log.append('stock overflow kept: ' + msg)
            chain = bytearray()
            first = None
            touched = False
    log.append('dialogue: %d blocks rewritten' % changed)


# ---- tables --------------------------------------------------------------------
_STR = re.compile(r'^(\s*)(nametxt|soundtracktxt|dc\.b|cursorbox)(\s+)(".*?")(\s*;.*|\s*)$')


def table_string(text, width, charset, kind, rid, problems):
    """en text -> the operand list for one row, padded to its width."""
    if charset == 'tile':
        enc, safe, dec = TILE_ENCODE, TILE_SAFE, {v: k for k, v in TILE_ENCODE.items()}
    else:
        enc, safe, dec = ps2text.US_ENCODE, SCRIPT_SAFE, ps2text.US_DECODE
    for ch in text:
        if ch not in enc:
            problems.append('%s: no glyph for %r' % (rid, ch))
            return None
    if len(text) > width:
        problems.append('%s: %r is %d cells, the field holds %d' % (rid, text, len(text), width))
        return None
    if kind in ('nametxt', 'soundtracktxt'):
        if any(ch not in safe for ch in text):
            problems.append('%s: %r: names can only use letters, digits and , . ; ? ! \' - :' % (rid, text))
            return None
        return '"%s"' % text
    # one string literal, so the row keeps matching _STR and the ordinals stay put;
    # \I is the source's escape for the double quote
    return '"%s"' % text.ljust(width).replace('"', '\\I')


# ---- vwf_windows: the windows' own text as proportional runs -------------------
WT_STATIC = os.path.join(ROOT, 'PSII_Disasm', 'ext', 'wtstatic.asm')
WT_EXCLUDE = {'WinArt_NameInput'}       # the letter grid: the cursor walks its cells
STATIC_RUNS = []                        # (art expression, offset, cells, text bytes)
WT_CHOSEN_PROMPT = None                 # the target window's one-line VWF footer
_OPND = re.compile(r'\s*("(?:[^"]*)"|\$[0-9A-Fa-f]+|\d+)\s*(?:,|$)')


def art_line_bytes(line):
    """The bytes one line of window art emits (border, cursorbox, dc.b), 0 for the rest."""
    code = re.sub(r'^((?:[^;"]|"[^"]*")*);.*$', r'\1', line).strip()
    m = re.match(r'border\s+(\d+)', code)
    if m:
        return int(m.group(1))
    m = re.match(r'cursorbox\s+"(.*)"', code)
    if m:
        return 2 + len(m.group(1).replace('\\I', '"'))
    m = re.match(r'dc\.b\s+(.*)$', code)
    if not m:
        return 0
    n, rest, pos = 0, m.group(1), 0
    while pos < len(rest):
        o = _OPND.match(rest, pos)
        if not o:
            break
        tok = o.group(1)
        n += len(tok[1:-1].replace('\\I', '"')) if tok.startswith('"') else 1
        pos = o.end()
    return n


# The windows whose rows the game writes into (all six are the RAM windows; the others are
# drawn from ROM as they are): per text row, the first cell it writes. Numbers are written
# right-aligned into a field of fixed digits ending at the row's placeholder digit
# (loc_1135A 3, loc_11364 2, Exp_ConvertToDecimal 7, Meseta_ConvertToDecimal 8), the
# equipment names from cell 5 (Win_StrngEquip). A label ends before its row's field.
WINDOW_FIELDS = {
    'WinArt_Meseta': [3],                      # MST, 8 digits
    'WinArt_StrngStats': [8] * 7,              # STRNGTH .. DEFENSE, 3 digits
    'WinArt_StrngEquip': [5] * 5,              # HEAD .. LEGS, the item name
    'WinArt_StrngLVEXP': [2, 3],               # LV 2 digits, EXP 7
    'WinArt_EquipStats': [8] * 3,              # AGILITY .. DEFENSE, 3 digits
    'WinArt_BattleCharStats': [3, 3],          # HP, TP: 3 digits
}
FIELD_GAP_PX = 2             # between a label and the field after it


def label_runs(text, width, field=None):
    """A window row's label runs: (column, cells, text). In a row the game writes into
    (`field` set), words of digits are the placeholders it writes numbers over and stay in
    the art; elsewhere they are text. A run of other words (one space apart) is a label. Its cells reach the next word, the row's end, or the
    row's field (`field`, the first cell the game writes), whichever comes first; the
    label is drawn proportionally in them, so it may have more letters than cells."""
    limit = width if field is None else field
    words = [(m.start(), m.group()) for m in re.finditer(r'\S+', text)]
    runs = []
    i = 0
    while i < len(words):
        start, w = words[i]
        if w.isdigit() and field is not None:
            i += 1
            continue
        j = i
        while j + 1 < len(words) and not (words[j + 1][1].isdigit() and field is not None) \
                and words[j + 1][0] == words[j][0] + len(words[j][1]) + 1:
            j += 1
        end = words[j][0] + len(words[j][1])
        nxt = words[j + 1][0] if j + 1 < len(words) else width
        runs.append((start, min(nxt, limit) - start, text[start:end]))
        i = j + 1
    return runs


def window_row(en, us, width, field=None):
    """vwf_windows: one row of a window drawn from art -> (label runs, the art row, problems).
    The labels come from `en`; in a row the game writes into (`field`), its digits are
    ignored and the placeholder digits come from the stock row `us` at its columns - the game writes numbers right-aligned into
    fixed cells, so they never move and a translation need not carry them."""
    problems = []
    digits, words = [], en
    if field is not None:
        digits = [(m.start(), m.group()) for m in re.finditer(r'\S+', us) if m.group().isdigit()]
        words = re.sub(r'(?<!\S)\d+(?!\S)', lambda m: ' ' * len(m.group()), en)
    row = words.ljust(width)
    runs = []
    for col, cells, label in label_runs(row, width, field):
        if cells <= 0:
            problems.append('%r starts in the cells the game writes (from cell %d)' % (label, field))
            continue
        runs.append((col, cells, label))
        row = row[:col] + ' ' * len(label) + row[col + len(label):]
    row = list(row)
    for col, d in digits:                   # the placeholders go back where the stock has them
        row[col:col + len(d)] = d
    art = ''.join(row).rstrip()
    if len(art) > width:
        problems.append('the row is %d cells: the window holds %d' % (len(art), width))
    return runs, art, problems


def write_static_runs(problems):
    out = ['; Generated by tools/gentext.py from work/script.json (the windows segment):',
           '; the text of the windows drawn from fixed art, as proportional runs for',
           '; ext/wintext.asm - art, offset in it, cells, text. Do not edit.',
           'WT_StaticRuns:']
    strings = []
    for k, (art, off, cells, data) in enumerate(STATIC_RUNS):
        out += ['\tdc.l\t%s' % art, '\tdc.w\t$%X, %d' % (off, cells), '\tdc.l\tWTS_%03d' % k]
        ops = ['$%02X' % b for b in data + b'\xC4']
        strings.append('WTS_%03d:' % k)
        strings += ['\tdc.b\t' + ', '.join(ops[n:n + 16]) for n in range(0, len(ops), 16)]
    out += ['\tdc.l\t0'] + strings
    if WT_CHOSEN_PROMPT is not None:
        ops = ['$%02X' % b for b in WT_CHOSEN_PROMPT + b'\xC4']
        out += ['WT_ChosenPrompt:', '\tdc.b\t' + ', '.join(ops)]
    out += ['\teven', '']
    text = '\n'.join(out)
    if not os.path.exists(WT_STATIC) or open(WT_STATIC, encoding='latin-1').read() != text:
        open(WT_STATIC, 'w', encoding='latin-1', newline='\n').write(text)


def write_long_names(doc, problems):
    """long_item_names: ext/lnames.asm - the ranges LN_Lookup knows (the records, after
    the last, the long names, the record size), per table a pointer for each record, then
    the names, each ended by $C4."""
    out = ['; Generated by tools/gentext.py from work/script.json (%s):' % ', '.join(LONG_TABLES),
           '; the full-length names, a pointer per record (ext/longnames.asm). Do not edit.',
           'LN_Ranges:']
    for seg, (table, records, size, px) in LONG_TABLES.items():
        n = len(doc['segments'][seg]['runs'])
        out += ['\tdc.l\t%s, %s+%d, %s' % (records, records, n * size, table), '\tdc.w\t%d, 0' % size]
    out.append('\tdc.l\t0')
    strings = []
    for seg, table in LONG_SEGS.items():
        runs = doc['segments'][seg]['runs']
        labels = []
        for k, r in enumerate(runs):
            if r['rows'] != [k]:
                problems.append('%s: row %s is not record %d' % (r['id'], r['rows'], k))
            text = r['en']
            bad = [ch for ch in text if ch not in NAME_SAFE]
            if bad:
                problems.append('%s: %r: names can only use letters, digits and , . ; ? ! \' - :'
                                % (r['id'], text))
                text = ''
            lab = 'LNS_%s_%03d' % (seg, k)
            labels.append(lab)
            ops = ['$%02X' % b for b in ps2text.encode_us(text) + b'\xC4']
            strings.append(lab + ':')
            strings += ['\tdc.b\t' + ', '.join(ops[n:n + 16]) for n in range(0, len(ops), 16)]
        out.append('%s_N = %d' % (table, len(runs)))
        out.append('%s:' % table)
        out += ['\tdc.l\t' + ', '.join(labels[n:n + 8]) for n in range(0, len(labels), 8)]
    text = '\n'.join(out + strings + ['\teven', ''])
    if not os.path.exists(LONG_NAMES_ASM) or open(LONG_NAMES_ASM, encoding='latin-1').read() != text:
        open(LONG_NAMES_ASM, 'w', encoding='latin-1', newline='\n').write(text)


def apply_tables(src, doc, force, problems, log, file='ps2.asm'):
    """The segments that live in `file` (a segment's `file`, relative to PSII_Disasm;
    ps2.asm by default)."""
    global WT_CHOSEN_PROMPT
    changed = 0
    vwf = OPTIONS.get('vwf_windows') and file == 'ps2.asm'
    dyn_start = next((i for i, l in enumerate(src) if l.startswith('DynamicWindowsStart:')), None)
    for name, seg in doc['segments'].items():
        if seg.get('file', 'ps2.asm') != file:
            continue
        if seg.get('static_art'):
            # a window of the engine's own (field_options): its art is fixed in ext/ and
            # its labels are only runs, each at `col` of art row `rows[0]` in `width` cells
            st = seg['static_art']
            if OPTIONS.get('vwf_windows') and OPTIONS.get(st['option']):
                for r in seg['runs']:
                    try:
                        data = ps2text.encode_us(r['en'])
                    except ValueError as ex:
                        problems.append('%s: %s' % (r['id'], ex))
                        continue
                    STATIC_RUNS.append((st['label'], r['rows'][0] * st['width'] + r['col'],
                                        r['width'], data))
            continue
        start = next(i for i, l in enumerate(src) if l.startswith(seg['start'] + ':'))
        if seg['end']:
            end = next(i for i in range(start, len(src)) if src[i].startswith(seg['end'] + ':'))
        else:
            end = next(i for i in range(start, len(src)) if src[i].strip() == 'charset')
        string_lines = [i for i in range(start, end) if _STR.match(src[i])]
        for r in seg['runs']:
            en = r['us'] if LONG_ITEM_NAMES and name in LONG_SEGS else r['en']   # en: ext/lnames.asm
            if vwf and name == 'prompts' and r['label'] == 'loc_1142A':
                # loc_F83A copies four bytes into each of two rows. Leave that art
                # blank and draw the full target prompt on one row at window draw.
                try:
                    WT_CHOSEN_PROMPT = ps2text.encode_us(' ' + en)
                except ValueError as ex:
                    problems.append('%s: %s' % (r['id'], ex))
                    WT_CHOSEN_PROMPT = b''
                en = ' ' * r['width']
            texts = en.split('{BR}') if r['kind'] == 'window' else [en]
            if len(texts) > len(r['rows']):
                problems.append('%s: %d rows, the window has %d' % (r['id'], len(texts), len(r['rows'])))
                continue
            texts += [''] * (len(r['rows']) - len(texts))
            widths = r.get('widths', [r['width']] * len(r['rows']))
            cursors = r.get('cursor', [False] * len(r['rows']))
            fields = WINDOW_FIELDS.get(r['label'], [None] * len(r['rows']))
            us_rows = (r['us'].split('{BR}') if r['kind'] == 'window' else [r['us']]) + [''] * len(r['rows'])
            if vwf and r['label'] == 'WinArt_GameSelect' and OPTIONS.get('title_save_menu'):
                # The JSON stays in the stock order. The title menu reorders the
                # three labels and uses a separate one-row art when SRAM is empty.
                empty_runs, _, errs = window_row(texts[0], us_rows[0], widths[0])
                problems.extend('%s: %s' % (r['id'], x) for x in errs)
                for col, cells, label in empty_runs:
                    try:
                        data = ps2text.encode_us(label)
                    except ValueError as ex:
                        problems.append('%s: %s' % (r['id'], ex))
                        continue
                    STATIC_RUNS.append(('TM_EmptyArt', 0x24 + col, cells, data))
                texts = [texts[1], texts[0], texts[2]]
            for k, (o, text, w, cur, field) in enumerate(zip(r['rows'], texts, widths, cursors, fields)):
                i = string_lines[o]
                m = _STR.match(src[i])
                kind = m.group(2)
                if vwf and name == 'windows' and r['label'] not in WT_EXCLUDE:
                    # the label runs go to WT_StaticRuns; the art keeps blanks there
                    lab = next(k for k in range(i, -1, -1) if src[k].startswith(r['label'] + ':'))
                    off = sum(art_line_bytes(src[k]) for k in range(lab + 1, i))
                    if kind == 'cursorbox':
                        off += 2
                    art = r['label']
                    wv = w
                    if r['label'] == 'WinArt_PlayerMenu' and OPTIONS.get('party_menu_ps4'):
                        # PM_MenuArt: the stock rows (cursor box + 5 cells) widened to
                        # cursor box + pm_width cells; the same row, the same column
                        art = 'PM_MenuArt'
                        wv = r.get('pm_width', w)
                        off = off // 7 * (wv + 2) + off % 7
                    if dyn_start is not None and lab > dyn_start:
                        art = '(window_art_buffer&$FFFFFF)+%s-DynamicWindowsStart' % r['label']
                    runs, text, probs = window_row(text, us_rows[k], wv, field)
                    problems.extend('%s: %s' % (r['id'], x) for x in probs)
                    for col, cells, label in runs:
                        try:
                            data = ps2text.encode_us(label)
                        except ValueError as ex:
                            problems.append('%s: %s' % (r['id'], ex))
                            continue
                        STATIC_RUNS.append((art, off + col, cells, data))
                ops = table_string(text, w, seg['charset'], kind, r['id'], problems)
                if ops is None:
                    continue
                new = m.group(1) + kind + m.group(3) + ops + (m.group(5) or '').rstrip()
                if kind in ('nametxt', 'soundtracktxt') and not ops.startswith('"'):
                    problems.append('%s: bad name operand' % r['id'])
                    continue
                held = _STR.match(src[i]).group(4)[1:-1].replace('\\I', '"')
                if not force and (held == text or held == text.ljust(w)):
                    continue            # the source already holds this text (in its own layout)
                if src[i] != new:
                    src[i] = new
                    changed += 1
    log.append('tables (%s): %d lines rewritten' % (file, changed))


def main():
    check = '--check' in sys.argv
    force = '--all' in sys.argv
    problems = []
    log = []
    opts = dict(a[2:].split('=', 1) for a in sys.argv[1:] if '=' in a)
    tables = json.load(open(opts.get('script', SCRIPT), encoding='utf-8'))
    if LONG_ITEM_NAMES:
        long_insert_bytes(tables)
    table_files = sorted(set(seg.get('file', 'ps2.asm') for seg in tables['segments'].values()))
    jobs = [(SCRIPT_ASM, apply_dialogue, opts.get('dialogue', DIALOGUE))]
    for f in table_files:
        jobs.append((os.path.join(ROOT, 'PSII_Disasm', f),
                     lambda src, doc, force, problems, log, f=f: apply_tables(src, doc, force, problems, log, f),
                     opts.get('script', SCRIPT)))
    results = []
    for path, apply, doc in jobs:
        raw = open(path, 'rb').read()
        crlf = b'\r\n' in raw
        src = raw.decode('latin-1').replace('\r\n', '\n').split('\n')
        before = list(src)
        apply(src, json.load(open(doc, encoding='utf-8')), force, problems, log)
        results.append((path, crlf, src, before))
    if OPTIONS.get('vwf_windows') and not check:
        write_static_runs(problems)
        log.append('%d window runs' % len(STATIC_RUNS))
    if LONG_ITEM_NAMES and not check:
        write_long_names(tables, problems)
        log.append('long names')
    for p in problems:
        print('PROBLEM', p)
    print('; '.join(log))
    if problems:
        print('%d problems' % len(problems))
    for path, crlf, src, before in results:
        if not check and src != before:
            text = '\n'.join(src)
            if crlf:
                text = text.replace('\n', '\r\n')
            open(path, 'wb').write(text.encode('latin-1'))
            print('wrote', os.path.relpath(path, ROOT))
    sys.exit(1 if problems else 0)


if __name__ == '__main__':
    main()

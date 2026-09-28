# The build pipeline

The working reference for anyone changing text or engine code here. The current state and
checklist are in [`../work/STATUS.md`](../work/STATUS.md).

## 1. Shape of the build

There is no ROM patching. The game is assembled from source (`PSII_Disasm/ps2.asm`) by
Macro Assembler AS, and the translation reaches the source through one generator,
`tools/gentext.py`, which rewrites the text blocks of the assembly in place from the two
JSON files. With every `en` equal to its `us` the ROM is byte-identical to the US release.

```
work/dialogue.json --gentext.py--> the script blocks of ps2.asm (600 blocks, 26 banks)
work/script.json   --gentext.py--> 9 table segments of ps2.asm (400 runs)
tools/proofread_template.html + the stock font --proofsync.py--> tools/proofread.html
```

`tools/sourcebuild.py [out.bin] [--no-gen]` runs `gentext.py`, then the assembler
(`asw.exe`, `ps2p2bin.exe` from `PSII_Disasm/AS/win32/`, the same steps as `build.bat`
without its `pause`), fixes the header checksum and copies the ROM (default `ps2en.bin`).

## 2. The ROMs

| file | what | size | CRC32 | SHA-256 |
|---|---|---|---|---|
| `PSII_Disasm/ps2original.bin` | US/EU **Rev A** (`GM 00005501-02`, 1990.JAN): what the disassembly reproduces | 786,432 | `904FA047` | `A0BD97F5...2B696B` |
| `work/ps2us_stock.bin` | US/EU original release (`-01`, 1989.JUN), the user's `PhantasyStar2.smd` de-interleaved | 786,432 | `0D07D0EF` | `C3776ECA...12E21F` |
| `work/ps2jp_stock.bin` | Japan (`-00`, 1988.DEC), the user's `PS2J.BIN` trimmed to 768 KB | 786,432 | `BEC8EB5A` | `E422C8B9...FB6982` |

The two US revisions differ in 16 bytes: the header date and revision, and one list of
names where two entries are swapped (`$17A14`). The 1 MB `PS2J.BIN` is an overdump: its
last 256 KB repeat `$80000-$BFFFF`.

## 3. The text engine (what the JSON has to respect)

* **Encoding.** One byte per character: 0 space, 1-10 digits, 11-36 `A-Z`, 37-62 `a-z`,
  `$3F-$47` `, . ; " ? ! ' -` and the ellipsis tile, `$77` `:`. Each byte indexes
  `VDPCharacterMaps` ($12BC8): a pair of font tiles, drawn one above the other (the JP puts
  dakuten in the upper tile; the US leaves it blank). The JP map is at $129C8 and decodes
  every byte of the JP script (`tools/ps2text.py`).
* **Controls.** `$BB`-`$C0` insert a character name (4), a second name (4), an enemy (10),
  a technique (5), an item (10), a meseta amount (6 cells); `$C1` next line; `$C2` clear;
  `$C3` wait and scroll; `$C4`-`$C7` end the message (`$C4` waits and closes, `$C5` closes
  at once, `$C6`/`$C7` time out).
* **Banks.** `GameScriptPtrs` points at 26 banks (item actions, shops, houses, the Library,
  the Commander, battle, the opening, people, events, ...). A script id is `bank << 8 | n`;
  a bank starts with a table of **byte** offsets from one message to the next, so a message
  is at most 255 bytes unless it is the last of its bank. A message with no end code runs
  on into the next one (both versions show their long texts this way); the code can also
  queue up to eight ids in `script_id`, and a queued message continues in the same window.
* **Buffer.** `LoadScript` expands a message into `text_buffer` ($CD40), 704 bytes before
  the sound RAM; `$C1` takes two bytes, `$C3` three, inserts their full width. The stock
  Lutz scene (`loc_2019E`, 1056 bytes) overruns it - the known music freeze in the Esper
  mansion. The generator refuses a translated message that overruns.
* **Windows.** The script window is 24 cells, two text lines; `WinID_ScriptMessageBig`
  (the Library, the Commander, many story scenes) four; the battle box 20 cells, one line;
  the final scene draws beside the portraits (`loc_7932`: 18 cells, 7 lines; the closing
  line 26). `extract_dialogue.py` infers each entry's window from the most lines the US or
  JP text shows between two waits; `window_override` in the JSON corrects it.

## 4. Extraction (done once; re-runnable on a stock build only)

* `tools/extract_dialogue.py` reads the bank tables of `ps2.asm` (id -> label), takes each
  block's bytes from the stock ROM (label address to the end of its `dc.b` lines, from the
  listing), and aligns the JP script bank by bank: the JP has the same 26 banks
  (`GameScriptPtrs` at $189DA), split into non-overlapping blocks (one per distinct start
  address). A monotone dynamic programme groups k US blocks with l JP blocks, scoring
  length (the JP-to-English character ratio), the insert codes, a leading `{CLR}` and the
  end code. `work/pairing.json` corrects it: `anchors` (a US label starts a group with a JP
  id), `groups` (explicit pairs taken out of the alignment - the US moved four late
  scenes to the end of the LevelEvents bank), `us_only` / `jp_only`.
  Result: 553 one-to-one, 22 US-split pairs, 4 others; every JP block is used once
  (`test_text.py`).
* `tools/extract_tables.py` reads the name records (`nametxt`), the soundtrack titles, the
  teleport list, job titles and the window art (`WinArt_*`, drawn straight from font
  tiles: `A` = $27) into `script.json`; JP names come from the JP ROM's records.

Both keep existing `en` and `note` fields unless run with `--rebuild`. They must run on a
stock build (the extractor checks `ps2built.bin` against `ps2original.bin`): they read the
text through the listing.

## 5. Generation

`gentext.py` rewrites a dialogue block (every `dc.b` line from the label to the last one
before the next label) or a table row only when its `en` differs from `us` (`--all`:
everything), so lory90's comments survive on untouched blocks. Output lines keep to AS's
20-operand limit; table rows stay single string literals (`\I` is the source's escape
for `"`) so they keep their ordinal. Dead bytes the stock ROM has after some end codes are
kept as `tail`. The generator is idempotent.

## 6. Verification

```
python tools/checkstock.py     # en = us everywhere reproduces the Rev A ROM byte for byte
python tools/test_text.py      # codecs round-trip; the JSON matches both ROMs; every JP block used once
python tools/linecheck.py      # every translated en against its budget (--stock: the stock text too)
```

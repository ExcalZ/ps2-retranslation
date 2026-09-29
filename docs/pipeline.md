# The build pipeline

The working reference for anyone changing text or engine code here. The current state and
checklist are in [`../work/STATUS.md`](../work/STATUS.md).

## 1. Shape of the build

There is no ROM patching. The game is assembled from source (`PSII_Disasm/ps2.asm`) by
Macro Assembler AS, and the translation reaches the source through one generator,
`tools/gentext.py`, which rewrites the text of the assembly in place from the two JSON
files. The engine changes are build options (section 7): with every option at 0 and every
`en` equal to its `us`, the ROM is byte-identical to the US release (`checkstock.py`).

```
work/dialogue.json --gentext.py--> PSII_Disasm/text/script.asm (600 blocks, 26 banks)
work/script.json   --gentext.py--> the table segments of ps2.asm, ext/names.asm (party
                                   names), ext/lnames.asm (long_item_names), and
                                   ext/wtstatic.asm (the window labels, vwf_windows)
tools/diafont.py   ------------->  PSII_Disasm/vwf/ (the proportional face; not tracked)
tools/proofread_template.html + the fonts --proofsync.py--> tools/proofread.html
```

`tools/sourcebuild.py [out.bin] [--no-gen]` runs `gentext.py` and `diafont.py`, then the
assembler (`asw.exe`, `ps2p2bin.exe` from `PSII_Disasm/AS/win32/`, the same steps as
`build.bat` without its `pause`), fixes the header checksum and copies the ROM (default
`ps2en.bin`).

## 2. The ROMs

| file | what | size | CRC32 | SHA-256 |
|---|---|---|---|---|
| `PSII_Disasm/ps2original.bin` | US/EU **Rev A** (`GM 00005501-02`, 1990.JAN): what the disassembly reproduces | 786,432 | `904FA047` | `A0BD97F5...2B696B` |
| `work/ps2us_stock.bin` | US/EU original release (`-01`, 1989.JUN), the user's `PhantasyStar2.smd` de-interleaved | 786,432 | `0D07D0EF` | `C3776ECA...12E21F` |
| `work/ps2jp_stock.bin` | Japan (`-00`, 1988.DEC), the user's `PS2J.BIN` trimmed to 768 KB | 786,432 | `BEC8EB5A` | `E422C8B9...FB6982` |

The two US revisions differ in 16 bytes: the header date and revision, and one list of
names where two entries are swapped (`$17A14`). The 1 MB `PS2J.BIN` is an overdump: its
last 256 KB repeat `$80000-$BFFFF`.

## 3. The stock text engine

What the game does with every option at 0; section 7 lists what the options change, and
section 8 the budgets the translation has with them.

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
python tools/checkstock.py     # options at 0, en = us: the Rev A ROM byte for byte
python tools/checkbuild.py     # after a build: no label of the stock image has moved
python tools/test_text.py      # codecs round-trip; the JSON matches both ROMs; every JP block used once
python tools/linecheck.py      # every translated en against its budget (--stock: the stock text too)
```

`checkbuild.py` compares every label with `work/stock_labels.json` (recorded from a stock
build): a hook that is not the size of the code it replaces would shift everything after
it, the sound driver's bank and every savestate included.

In the emulator, `tools/ps2emu.py` drives BlastEm through its GDB stub (the joypad is
written at the `JoypadRead` breakpoint, so the window never needs the keyboard) at 400%
speed. Scenarios in `work/scripts/` boot a new game to the field and walk menus, battles,
shops, buildings, saving and continuing, taking screenshots; run the same one on
`PSII_Disasm/ps2original.bin` to compare with the stock game. Every loop in them is
bounded and checks RAM (window depth `$DE04`, list cursor `$DE50`) before it presses on.

## 7. The engine options (`PSII_Disasm/ps2.options.asm`)

Each is 1 in the translation build. A hook in `ps2.asm` sits under `if option ... else
<stock code> endif` and is exactly the size of the stock code; new code goes in
`PSII_Disasm/ext/`, assembled after the stock image.

| option | what it does | code |
|---|---|---|
| `relocate_script` | the script is assembled after the stock data; its region is filled to the same size | `text/script.asm` |
| `long_script_offsets` | a longword pointer per message: no 255-byte limit | `LoadScript` |
| `paged_text_buffer` | a message is expanded one page (up to a `{PAGE}`) at a time: any length fits; the Lutz overrun is gone | `ext/script.asm` |
| `vwf_dialogue` | proportional text in the script windows (dialogue, big window, battle box), drawn into a ring of VRAM tiles | `ext/vwf.asm` |
| `long_names` | party names of up to six letters (letters 5-6 beside the stock four, saved with them) | `ext/names.asm` |
| `vwf_windows` | proportional text in every window: labels, lists, names; runs drawn into free VRAM once a window is up | `ext/wintext.asm` |
| `long_item_names` | full-length item, technique and enemy names from tables of their own; the records keep the stock names | `ext/longnames.asm` |
| `centered_camera` | the field camera keeps the player centred (EvilJagaGenius's four scroll thresholds at `loc_3956`) | `ps2.asm` |
| `damage_popups` | short-lived per-target damage numbers over enemies and party members, including area attacks | `ext/damagepopups.asm` |
| `damage_popup_font` | with pop-ups on, `0` uses the stock HP/TP numerals; `1` uses thicker numerals with a tighter visible gap (default) | `ext/damagepopups.asm` |

`vwf_windows` in short: the loops that copy names into window art write blanks and
register a *run* (art address, cells, text); party names reach the art as marker bytes;
the window's own labels are `WT_StaticRuns` (generated); letters the code copies into art
(WHO?, jobs, NEXT) are found by a scan. When a window has been drawn, its runs are drawn in
the proportional face into pool tiles (free VRAM per kind of screen, from the audits in
`work/scripts/mapaudit.py` and `battleaudit.py`) and its cells are pointed at them.
Numbers stay in the stock digit tiles, right-aligned where the game writes them.

`damage_popups` records each nonzero calculated hit at the HP subtraction, then draws
a framed window over each target for 45 frames. The window expands from 8 to 32 pixels,
holds the damage number, then contracts over its final six frames. Five enemy slots and
four party slots use RAM $FFFF8F00-$FFFF8F49 and battle-only VRAM tiles $33C-$373.
Enemy windows rise over their targets; party windows overlap the character art and
stay five pixels above the lower status bar. They draw in front of the characters.
The stock total beside the enemy name remains active. Megid's HP cost also appears
over each party member. Values above 9999 display as 9999. The battle sprite and damage hooks
keep the stock code at its original addresses.

## 8. Budgets with the options on

`linecheck.py` and the proofreader apply these (the proofreader embeds the same numbers):

* **Dialogue**: pixels, not cells - 192 px a line in the script and big windows, 160 in
  the battle box, with each insert at its widest (the longest name of its table; six
  letters for a typed name; six digits for meseta). A page may expand to 384 bytes.
* **Party names**: six letters, and at most 32 px (the four cells of a name plate).
* **Items and enemies**: 80 px; **techniques**: 40 px (the stock cells in the windows).
* **Window labels**: a label is drawn in the cells up to the next word or the row's end;
  in the six windows the game writes numbers or names into (MST, the stats, LV/EXP, the
  equipment rows, the equip stats, battle HP/TP: `gentext.WINDOW_FIELDS`) it ends before
  that field with 2 px to spare. In those rows the number placeholders come from the stock
  row, so a translation gives only the label ("Strength", not "Strength   0"), and the
  numbers stay right-aligned in their fields.

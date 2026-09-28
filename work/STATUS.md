# PS2 Retranslation - Status

Updated: 2026-09-23

## State

Foundation in place; **the translation has not started**. The disassembly assembles the US
ROM (Rev A) bit-exact; the whole script and every name/menu table are in JSON with the
Japanese aligned beside the US text; the generator writes the JSON back into the source,
byte-exact and idempotent; the proofreader draws every line in the game's font with its
budget; the checks run from the shell.

Stock US ROM (Rev A): 786,432 bytes, SHA-256
`A0BD97F5AAA67301923CCC367511606BD3471EA9542919165311D4A23A2B696B`, CRC32 `904FA047`,
internal checksum `3792`. `tools/checkstock.py` reproduces it from any state of the JSON.

## Done (2026-09-23)

* **Project** set up beside ps3-translate/ps4-translate: lory90's disassembly from PSCave
  (`PSII_Disasm/`), the generic `tools/md/` of the PS IV project, MIT license, notices.
* **ROM identification.** The user's `PhantasyStar2.smd` is the original US release
  (REV01, `0D07D0EF`); the disassembly builds Rev A (REV02, `904FA047`); they differ in
  16 bytes. `PS2J.BIN` is the JP ROM overdumped to 1 MB (trimmed copy in `work/`).
* **Art codec** (`tools/ps2art.py`): the game's per-tile fill-mask compression
  (`DecompressArt`) - needed for the font; also a compressor, for new glyphs later.
* **Codecs** (`tools/ps2text.py`): US script charset, JP kana (read off the JP font sheet;
  dakuten from the upper tile), control codes.
* **Dialogue extraction**: 600 blocks / 611 ids, 578 with JP text; the rest continue a JP
  text the US split (`jp_cont`). 44 blocks run on into the next (`falls_through`).
* **Table extraction**: party names, 128 items, 64 technique slots, 127 enemies, 22
  soundtrack titles, 10 teleport places, 8 jobs, 3 labels, 30 menu windows and profiles.
* **Generator**, **proofreader**, **linecheck**, **applybatch**, **test_text**,
  **checkstock**.

## Done (2026-09-27): the script limits

Three options in `PSII_Disasm/ps2.options.asm` (all 1 in the translation build; all 0
reproduces the stock ROM, `tools/checkstock.py`):

* `relocate_script`: the script (`PSII_Disasm/text/script.asm`, split out of ps2.asm) is
  assembled after the stock data, past $BF6D8; its stock region is filled to its old size
  (`ScriptRegionSize`, $A838), so **nothing else in the ROM moves** - the sound driver at
  $B8000 keeps its bank, and the only other changed bytes are the hooks below. The ROM
  grows to 1 MB (`padROM`).
* `long_script_offsets`: each bank holds a longword pointer per id (`scriptofs` macro); a
  message may be any length. LoadScript's summing loop becomes an indexed load (same size).
* `paged_text_buffer` (`ext/script.asm`): LoadScript stops after each `{PAGE}` and resumes
  from the script when the button releases the wait, so text_buffer holds one page, not a
  whole message. Three same-size hooks (LoadScript's $C3 and end-code exits, loc_FB56).
  Fixes the stock Lutz overrun.

Verified in BlastEm (`tools/ps2emu.py`, `work/scripts/forcemsg.py`, which boots a new game
to the Paseo field and forces any message into the big window): the Commander's 31-page
chain and the Lutz scene (1690, 23 pages) page correctly; the Lutz expansion peaks at
$CD73 where the stock build writes to $D15F, 351 bytes into the sound RAM; a 407-byte test
message in 1001 shows all 15 pages and 1002 after it still resolves.

## Done (2026-09-27): proportional text (`vwf_dialogue`)

`ext/vwf.asm`, hooked at `DrawScriptToVDP`: each letter of the face (`tools/diafont.py`,
the PS III/IV mixed-case face, the stock baseline) is OR-ed into a 192-px canvas and only
the cells it touched are copied to VRAM, so the one-letter-a-frame typing keeps its pace.
A line takes the next of four 24-tile slots in the pool at **VRAM $D000-$DFFF (tiles
$680-$6FF)** - the unused half of plane A's area, blank and unreferenced on every screen
audited (`work/scripts/vramstates.py`, `work/scripts/battle.py`, `tools/vramaudit.py`:
title, opening, portrait scenes, big window, field, battle). The stock scroll copies the
cells, so lines survive it. Budgets: **192 px** in the dialogue and big windows, **160 px**
in the battle box (`linecheck.py`, the proofreader); the final scene (7 lines, 64x64
planes) keeps the stock cells. Verified in BlastEm: the Commander's scene through its
scrolls, the Rolf's-house scene, a forced battle's victory messages. A 24-cell stock line
holds about 43 letters of the new face.

## Done (2026-09-27): party names of six letters (`long_names`)

`ext/names.asm` and eleven same-size hooks. Letters 5-6 live at `$C686 + 2n`, inside the
saved party block ($C600-$C69D; unreferenced, zero in every RAM image), so saves carry
them. The naming window takes six letters (four when naming a save file in the Data
Memory), writes letters after the first in lower case (the grid has only capitals), and
keeps letters 5-6 at `$C630`. `{NAME}`/`{NAME2}` copy six. The windows draw every name as
a proportional **32-px plate** in its four cells: font tiles `$81-$96` and `$A1-$AA` (kana
and JP capitals the US game never shows - no script byte maps to them, no audited screen
references them), redrawn after every font load (three VRAM and two RAM loads hooked).
Default names are the `charnames` segment, written to `CharNamesLong` (six letters, 32 px
checked by linecheck and the proofreader). JP names measured: Eusis 22 px, Nei 13,
Rudger 29, Anne 20, Huey 20, Amia 18, Kains 22, Shilka 25.

Verified in BlastEm (`work/scripts/names.py`): the hero named RUDGER is stored `Rudg`+`er`;
the Commander says "Good morning, Rudger."; the menu's WHO? list, the status window and
the battle command window show the Rudger plate. **Not yet exercised:** naming a save file
(four letters), saving and continuing (the letters and plates should survive by
construction), renaming a recruit at Rolf's house.

Harness: `ps2emu.boot_to_field` now ends on the real field - screen $0C00 with no scene
(`demo_flag` $F750 clear) and no window, the hero moving (`$E40A`) - and every loop that
presses buttons is bounded and raises instead of pressing on (the naming grid is driven
by reading its cursor, `$DE50`). The earlier "field" states were the scripted walk to
Rolf's house (screen $1000, demo_flag 1); their VRAM audits still describe the Paseo map.

## Done (2026-09-28): centred field camera (`centered_camera`)

EvilJagaGenius's camera hack: the four scroll thresholds in `loc_3956` (Y $C8/$118, X
$D8/$168) become Y $108 and X $128, so the map scrolls with each step and the player stays
in the middle of the screen. Four immediates, nothing moves. Seen in BlastEm
(`work/scripts/camera.py`: the player's screen position holds at $128,$108 while the map
position changes).

## In progress (2026-09-28): proportional text in every window (`vwf_windows`)

`ext/wintext.asm`. Done and seen in BlastEm: the field menu (labels, WHO? list, item
list), the battle box (enemy names, party names), the party names everywhere (marker
runs; the font-tile plates are gone - they overwrote NEXT/HP/TP). Pools from VRAM audits
of all 101 maps, 19 buildings and every battle background with full parties
(`work/scripts/mapaudit.py`, `battleaudit.py`). `tools/checkbuild.py` proves nothing in
the stock image moved. Window art text comes from generated static runs
(`ext/wtstatic.asm`); letters the code copies into art (WHO?, ON?, NEXT, jobs, Heal,
miss) are found by a scan and redrawn.

Also seen against the stock ROM (2026-09-28; same steps on both, `work/scripts/menus2.py`,
`battlemenus.py`, `building.py`, `savegame.py`): STATE, STRNG, EQP, the technique list;
battle commands, technique and item lists, the technique-used and item-used windows; the
shop lists, prices, WHO?, YES/NO; the Clone Labs and hospital; the teleport list; Rolf's
house options, roster and a profile (text, LV/EXP, stats); Data Memory save slots, the save-file naming, saving, and CONTINUE on the title
(the game select, a six-letter hero name restored). Fixed on the way: label runs covered
the blanks after a label, where the game writes numbers and equipment names; the $47
glyph (one dot - the script writes an ellipsis as three) drew three dots each.

The harness runs BlastEm at 400% (its speed key, posted to the window), reads the window
depth ($DE04) and list cursor ($DE50 byte), and `PS2.quit_saving()` lets BlastEm exit
so it writes SRAM.

Every window listed has been seen.

## Done (2026-09-28): full-length item, technique and enemy names (`long_item_names`)

`ext/longnames.asm`: the names come from tables of their own (`ext/lnames.asm`, written by
gentext from the `en` of the items, techs and enemies segments, a pointer per record); the
records keep the stock names. `WT_Render` looks a record's name up (LN_Lookup) and draws the
long one in the run's pixels; `Script_ProcessItemEnemyNames` / `Script_ProcessTechNames`
jump to LN_Insert, so {ITEM}, {TECH}, {ENEMY} copy the whole name. Budgets: items and
enemies 80 px, techniques 40 px (the stock cells) - linecheck and the proofreader check
pixels for these segments, and the inserts' widths follow the longest name. Seen in
BlastEm with test names (battle lists, the enemy window, the item-used window, the shop
list and its {ITEM} line; a 50-px technique is cut at 40 as the check says). The
script.json `width` of these rows is now the field's (10/5/10), not the US name's length.

**Left:** window budgets for the window-art segments in the proofreader (as linecheck);
docs (pipeline, engine notes). Then the translation pass.

## Findings that shape the translation

* A message block is at most **255 bytes** unless it is the last of its bank; a whole
  message (a chain of fall-through blocks) at most **704 bytes** once expanded. The US
  translation already fills these: it split 22 JP texts over two to eight ids. The new
  English will be longer still in places - either split the same way (the US ids and their
  code stay as they are) or lift the limits (below).
* The windows are narrow: **24 cells** by two lines. English at 8 px per letter is the
  single biggest constraint on this script.
* The JP names do not fit the engine: party names are 4 letters (Eusis, Rudger, Kains,
  Shilka are 5-6), technique names 5 (Gifoie, Nafoie are 6).
* The stock Lutz scene overruns the text buffer (the music-freeze bug); a retranslation can
  fix it by splitting the message or by moving the buffer.

## Next - proposed order

1. ~~Engine: the script limits~~ - done.
2. ~~Engine: a proportional (VWF) dialogue font~~ - done.
3. ~~Engine: longer party names~~ - done. **3b: item, technique and enemy names** - the JP
   names are far longer than their fields (Gisaresta, Laconia Harnish, Ceramic Fibrilla):
   display-name tables for the inserts and a proportional renderer for the menus, the
   shops and the battle lists, as PS III's vwf_menu / vwf_shop / vwf_battle.
4. **Translation pass** from the JP, with the glossary's names.
5. BlastEm harness for PS II (the PS III `ps3emu.py` is the model), release packaging
   (BPS against Rev A; decide how to serve REV01 owners - a second BPS, or the offline
   patcher normalising the 16 bytes).

## Verification checklist

```
python tools/sourcebuild.py ps2en.bin     # 0 errors, 0 warnings
python tools/checkstock.py                # stock reproduction
python tools/test_text.py
python tools/linecheck.py
```

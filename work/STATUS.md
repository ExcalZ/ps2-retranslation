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
3. **Engine: longer names** - party names (RAM, save data, naming screen, inserts, windows)
   and technique names (a display-name table beside `TechniqueData`, as PS III did).
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

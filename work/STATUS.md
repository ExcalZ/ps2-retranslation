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

1. **Engine: the script limits.** Word offsets for the bank tables (or a pointer table),
   and a larger text buffer out of the sound RAM's way. Small, contained, and it removes the
   255/704 limits and the Lutz bug.
2. **Engine: a proportional (VWF) dialogue font**, as in PS III/IV. At 24 fixed cells a line
   holds about 24 letters; proportional text would hold 30-35, which changes how every
   message is written and paged - so it should come before the translation, not after.
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

# Phantasy Star II: English Retranslation - source and tools

[![Latest release](https://img.shields.io/github/v/release/ExcalZ/ps2-retranslation?label=Download%20the%20patch)](https://github.com/ExcalZ/ps2-retranslation/releases/latest)

**Players:** get the patch from the [Releases page](https://github.com/ExcalZ/ps2-retranslation/releases/latest) - the zip has an offline patcher (`Patcher.html`, which takes either US/European release, plain or `.smd`), the BPS patches and the readme. Nothing else on this page is needed to play.

A new English translation of *Phantasy Star II* (*Kaerazaru Toki no Owari ni*, Mega Drive /
Genesis), made from the Japanese script, built as a **source patch on top of the game's
disassembly** rather than by editing the ROM - the same shape as the
[Phantasy Star IV retranslation](https://github.com/ExcalZ/ps4-retranslation) and the
Phantasy Star III one. Along the way the text engine was rebuilt: proportional text in the
dialogue and in every menu, no length limit on a message, and full-length names; the menus,
shops and battle commands follow Phantasy Star IV's.

This repository holds everything needed to rebuild the patch from source:

* the script, as editable JSON with the Japanese, the 1989 US text and the new English side
  by side (`work/dialogue.json`, `work/script.json`);
* the engine changes, each an option over lory90's disassembly (`PSII_Disasm/`);
* the toolchain that extracts the text, aligns the Japanese script with the US one, writes
  the JSON back into the assembly, checks every budget, assembles the ROM, tests it under
  an emulator and packages the release (`tools/`);
* a proofreading editor that draws every line in the game's own font (`tools/proofread.html`).

**Just want to play?** Download the [release zip](https://github.com/ExcalZ/ps2-retranslation/releases/latest)
(patches + offline patcher + readme); nothing in this repository is needed.
No ROM is included here or there.

To build, you need the stock US ROM (Rev A) at `PSII_Disasm/ps2original.bin`; aligning the
Japanese script needs the JP ROM as `work/ps2jp_stock.bin` (768 KB; a 1 MB overdump is
trimmed - see `docs/pipeline.md`).

## Repository map

```
README.md                this file
docs/pipeline.md         how a build works, what each stage reads and writes, every option
docs/improvement.md      FlamePurge's Improvement v4.5 as read back into the source
work/STATUS.md           current state, what is done, what is next - read first
work/glossary.md         naming decisions: the Japanese names throughout
work/dialogue.json       the game script: 607 text blocks (618 script ids), JP / US / EN
work/script.json         names, items, techniques, enemies, menus, profiles: 14 tables, 428 runs
work/pairing.json        manual corrections to the JP / US alignment
work/scripts/            bounded BlastEm scenarios (menus, battles, shops, saving, ...)
PSII_Disasm/             lory90's disassembly (the translation is written into ps2.asm)
PSII_Disasm/ext/         the new engine code
tools/                   the toolchain (Python 3.10+, standard library only)
tools/release.py         packages a release: BPS patches, Patcher.html, readme, zip
tools/md/                generic Mega Drive utilities (BPS, SMD, 68000 interpreter, BlastEm
                         driver, offline web patcher)
release/                 readme_template.txt (the rendered releases are not tracked)
```

## Building

```bash
python tools/sourcebuild.py ps2en.bin
```

writes the JSON into the source (`gentext.py`), generates the proportional font
(`diafont.py`), assembles with Macro Assembler AS (`PSII_Disasm/AS/win32/asw.exe`,
Windows), fixes the header checksum and copies the ROM.

The engine changes are options in `PSII_Disasm/ps2.options.asm`: longer messages, a paged
text buffer, proportional text in every window, six-letter party names, full-length item,
technique and enemy names, Phantasy Star IV's menus, shops, battle commands and macros,
damage pop-ups, an Options window, a centred field camera and FlamePurge's *Improvement*
v4.5 (see `docs/pipeline.md`, section 7). With every option at 0 and every `en` equal to
its `us`, the ROM is byte-identical to the US release (Rev A); `python tools/checkstock.py`
proves it.

## Packaging a release

```bash
python tools/release.py 1.0
```

after a build and the checks (`work/STATUS.md`). It needs Rev A at
`PSII_Disasm/ps2original.bin` and the first US release (CRC32 `0D07D0EF`) as a plain binary
at `work/ps2us_stock.bin`, and writes `release/PS2_Retranslation_v1.0/` and its zip. Add the
version to the changelog in `release/readme_template.txt` first.

## Editing the translation

Edit only the `en` fields; `hex`, `jp`, `us` and the addresses describe the originals.

* **Dialogue** (`work/dialogue.json`): `{BR}` next line, `{PAGE}` wait for a button and scroll
  one line, `{CLR}` clear the window; `{NAME}` `{NAME2}` `{ENEMY}` `{TECH}` `{ITEM}` `{MESETA}`
  are inserts; a message ends in `{END}` (wait, close), `{C5}` (close at once: a prompt
  follows), `{C6}` or `{C7}` (timed). Text is proportional: a line holds 192 px (two
  lines, four in the big window; the battle box two lines when its message has a `{BR}`).
  An entry marked
  `falls_through` runs on into the next one: the game reads them as one message.
* **Tables** (`work/script.json`): a window's rows are joined with `{BR}`. Names and
  labels are measured in pixels: party names 32, items and enemies 80, techniques 48; a
  window label up to the next word or the row's end - or, in the stat windows, up to the
  field where the game writes its right-aligned number (give only the label there).
  `docs/pipeline.md` section 8 has every budget.
* `tools/proofread.html` shows every line in the game's font with live budgets. Serve the
  repository with `python -m http.server 8766` and open
  `http://localhost:8766/tools/proofread.html?file=work/dialogue.json`, or open the file
  and load a JSON.
* `tools/applybatch.py batch.json [--script]` merges a JSON of id -> `en` and checks each;
  `tools/linecheck.py` checks everything from the shell.

## Credits and legal

Translation, hacking and testing by **Excalibur_Z**, with Claude (Anthropic) for translation
and technical work. Built on lory90's Phantasy Star II disassembly. FlamePurge's
*Phantasy Star II Improvement* v4.5 (with lory1990's bug fixes, veo's fast battles and
Fauntleroy's Van Leader) is included at FlamePurge's invitation. The centred field
camera is EvilJagaGenius's. Tooling and documentation
are MIT licensed (`LICENSE`); third-party components are listed in `NOTICE.md`. Phantasy Star
II is copyright SEGA; this repository contains no ROM image and no right to one.

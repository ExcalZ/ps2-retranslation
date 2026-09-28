# Phantasy Star II: English Retranslation - source and tools

A new English translation of *Phantasy Star II* (*Kaerazaru Toki no Owari ni*, Mega Drive /
Genesis), made from the Japanese script, built as a **source patch on top of the game's
disassembly** rather than by editing the ROM - the same shape as the
[Phantasy Star IV retranslation](https://github.com/ExcalZ/ps4-retranslation) and the
Phantasy Star III one.

No release yet: the foundation is in place and the translation has not started. Read
`work/STATUS.md` first.

This repository holds:

* the script, as editable JSON with the Japanese, the 1989 US text and the new English side
  by side (`work/dialogue.json`, `work/script.json`);
* the toolchain that extracts the text, aligns the Japanese script with the US one, writes
  the JSON back into the assembly, checks every budget and assembles the ROM (`tools/`);
* a proofreading editor that draws every line in the game's own font (`tools/proofread.html`).

No ROM is included. The build needs the stock US ROM (Rev A) at
`PSII_Disasm/ps2original.bin`; aligning the Japanese script needs the JP ROM as
`work/ps2jp_stock.bin` (768 KB; a 1 MB overdump is trimmed - see `docs/pipeline.md`).

## Repository map

```
README.md                this file
docs/pipeline.md         how a build works, what each stage reads and writes
work/STATUS.md           current state, what is done, what is next - read first
work/glossary.md         naming decisions: the Japanese names throughout
work/dialogue.json       the game script: 600 text blocks (611 script ids), JP / US / EN
work/script.json         names, items, techniques, enemies, menus, profiles: 9 tables, 400 runs
work/pairing.json        manual corrections to the JP / US alignment
PSII_Disasm/             lory90's disassembly (the translation is written into ps2.asm)
tools/                   the toolchain (Python 3.10+, standard library only)
tools/md/                generic Mega Drive utilities (BPS, SMD, 68000 interpreter, BlastEm driver)
```

## Building

```bash
python tools/sourcebuild.py ps2en.bin
```

writes the JSON into `ps2.asm` (`gentext.py`), assembles with Macro Assembler AS
(`PSII_Disasm/AS/win32/asw.exe`, Windows), fixes the header checksum and copies the ROM.
With every `en` equal to its `us` the ROM is byte-identical to the US release (Rev A).

## Editing the translation

Edit only the `en` fields; `hex`, `jp`, `us` and the addresses describe the originals.

* **Dialogue** (`work/dialogue.json`): `{BR}` next line, `{PAGE}` wait for a button and scroll
  one line, `{CLR}` clear the window; `{NAME}` `{NAME2}` `{ENEMY}` `{TECH}` `{ITEM}` `{MESETA}`
  are inserts; a message ends in `{END}` (wait, close), `{C5}` (close at once: a prompt
  follows), `{C6}` or `{C7}` (timed). The window is 24 cells by two lines (four in the big
  window, one line of 20 in battle). An entry marked `falls_through` runs on into the next
  one: the game reads them as one message.
* **Tables** (`work/script.json`): fixed-width rows; a window's rows are joined with `{BR}`.
* `tools/proofread.html` shows every line in the game's font with live budgets. Serve the
  repository with `python -m http.server 8766` and open
  `http://localhost:8766/tools/proofread.html?file=work/dialogue.json`, or open the file
  and load a JSON.
* `tools/applybatch.py batch.json [--script]` merges a JSON of id -> `en` and checks each;
  `tools/linecheck.py` checks everything from the shell.

## Credits and legal

Translation, hacking and testing by **Excalibur_Z**, with Claude (Anthropic) for translation
and technical work. Built on lory90's Phantasy Star II disassembly. Tooling and documentation
are MIT licensed (`LICENSE`); third-party components are listed in `NOTICE.md`. Phantasy Star
II is copyright SEGA; this repository contains no ROM image and no right to one.

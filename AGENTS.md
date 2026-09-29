# Handoff: Phantasy Star II retranslation

For an agent picking this up (written 2026-09-28 at the end of a Claude Code session).
Read this, then `work/STATUS.md` (the running log), `docs/pipeline.md` (how the build works,
the engine options, every budget) and `work/glossary.md` (every naming decision).

## What this is

A new English translation of *Phantasy Star II* from the Japanese script, built as a
**source patch on lory90's disassembly** (`PSII_Disasm/ps2.asm`, Macro Assembler AS), not a
ROM hack. The owner is Excalibur_Z; the sibling projects `../ps3-translate` and
`../ps4-translate` are the same shape and set the conventions (American English,
Japanese names, the PS IV technique-name rules).

**State:** the engine work is finished and the **first full translation is done** - every
table in `work/script.json` and all 26 dialogue banks in `work/dialogue.json`. What is left
is proofreading, a few naming decisions that belong to the owner, and release packaging.

## Rebuild rule

Every ROM build must include the current JSON:

```bash
python tools/sourcebuild.py ps2en.bin
```

(runs `gentext.py`, which writes the JSON into the source, and `diafont.py`, which
generates the font; never pass `--no-gen` for a real build). Then always:

```bash
python tools/checkbuild.py      # must print "nothing moved"
python tools/linecheck.py       # must print "0 problems"
python tools/gentext.py --check # must rewrite nothing after a build
```

and before any commit that touches the engine, the generator or the tables:

```bash
python tools/checkstock.py      # options at 0, en = us: must be byte-identical to Rev A
python tools/test_text.py       # codecs, JSON vs both ROMs
```

`PSII_Disasm/ps2.log` existing after a build means the assembler failed: never test on a
ROM from a failed build (chain commands with `&&` and `test ! -f PSII_Disasm/ps2.log`).

## Hard rules (each was learned the hard way)

1. **Nothing in the stock image moves.** A hook in `ps2.asm` sits under
   `if option ... else <stock code> endif` and must be exactly the size of the code it
   replaces; new code goes in `PSII_Disasm/ext/`. `checkbuild.py` proves it. A 2-byte
   mismatch once shifted 244 regions.
2. **Every option at 0 must reproduce the US ROM (Rev A) byte for byte** - `checkstock.py`.
3. **Line endings are per file** (some CRLF, some LF). Python text-mode read/write on
   Windows silently flips them, and Git Bash `sed -i` strips CRLF. Edit bytes or open with
   `newline=''`; check with `open(f,'rb').read().count(b'\r\n')`. A whole-file line count in
   `git diff --stat` means you changed the endings. Stage with
   `git -c core.autocrlf=false add ...`.
4. **Bash heredocs eat backslashes** in patch text (`\S`, `\d`, `\n`). Use a file editor or a
   script file for anything with escapes.
5. **Emulator scenarios must be bounded.** The owner watches BlastEm; runaway button loops
   (once: spamming RUB in the naming window) have had to be killed by hand. Every loop has a
   limit, checks RAM before pressing on (window depth `$DE04`, list cursor byte `$DE50`,
   `GAME_SCREEN`, `DEMO_FLAG`), and raises instead of guessing. Never type blindly into the
   naming screen: use `ps2emu.type_name` / `_cursor_to`.
6. **Extraction (`extract_dialogue.py`, `extract_tables.py`) only runs on a stock build** and
   would drop hand-made layout in `script.json` (below). You should not need to run it.
7. **Never commit game data** (ROMs, savestates, `work/analysis/`); `.gitignore` covers it.
   There is no git remote; commit locally on `main`, small commits, descriptive messages.

## How to work on the text

* `work/dialogue.json` - edit only `en`. Controls: `{BR}` next line, `{PAGE}` wait then scroll
  on, `{CLR}` clear, `{END}` `{C5}` `{C6}` `{C7}` end codes, inserts `{NAME}` `{NAME2}`
  `{ENEMY}` `{TECH}` `{ITEM}` `{MESETA}`. An entry with `falls_through` must NOT end in an
  end code (it runs on into the next entry); `jp_cont` entries carry part of a JP message the
  US split over several ids - keep the split, spread the text at page breaks.
* `work/script.json` - names, menus, profiles. `windows` rows are joined with `{BR}`.
* Budgets are **pixels** (proportional font): dialogue 192 px a line (2 lines; 4 in the
  `big` window), battle box 160 px (1 line); the `ending` windows are still cells (18 a
  line, 7 lines; the closing line 26). Names: party 32 px, items/enemies 80, techniques 40,
  teleport places 40, soundtrack titles 96, jobs 64. Window labels: see
  `docs/pipeline.md` section 8 - in the stat windows a label ends before the game's number
  field and **numbers stay right-aligned**; give only the label, the placeholder digits come
  from the stock row.
* The ellipsis: `…` is ONE dot glyph; write `………` (three) for an ellipsis.
* `Ä`/`ä` exist (bytes $48/$49) for the *Ärmel* shields.
* Tools: `python tools/bankdump.py --list` (progress), `python tools/bankdump.py BANK
  [--todo]` (JP / US / EN per entry), `python tools/applybatch.py batch.json [--script]`
  (merge an id -> en JSON and check every entry), `tools/proofread.html` (the proofreader;
  regenerate with `python tools/proofsync.py`), `python tools/linecheck.py`,
  `python tools/jptables.py [--apply]` (the JP of the tile-drawn tables - windows, jobs,
  prompts, labels, teleport places - read from the JP ROM; `--apply` writes only `jp`).
* Changing an item name can widen the `{ITEM}` insert (every insert is budgeted at its
  table's widest name) and push dialogue lines over 192 px: run `linecheck.py` after any
  name change.

### Style (see `work/glossary.md` "Style" and the per-section notes)

American English. Japanese names throughout (Eusis, Rudger, Anne, Huey, Amia, Kains,
Shilka; Motavia, Palma, Dezolis, Algol). PS I names **as the PS IV translation ships them**
(Alisa - not Alis -, LaSheek, Gaira, Dark Falz, Myau, Lutz, Tyron): when a shared series
name comes up, grep `../ps4-translate` `en` text, not its glossary table. Eusis narrates in
the first person; narration is past tense; 「」 becomes "..."; the Dezolians speak a light
rural dialect ("us folks", "I reckon"), not the 1989 caricature; the Commander (そうとく)
is warm and senior; Avantino (the musician, US "Ustvestia") theatrical; the Gaira robot in
capitals.

## Emulator harness

BlastEm 0.6.2, found via `$BLASTEM`, `./blastem-win32-0.6.2/`, or
`../ps4-translate/blastem-win32-0.6.2/` (`tools/ps2emu.py`). It is driven through its GDB
stub (the joypad is written at a breakpoint, so the window never needs focus) and runs at
400% (the speed key is posted to the window). Screenshots go to `work/analysis/`; when the
window capture is blank a savestate render is used instead. `tools/montage.py` tiles shots.

Scenarios in `work/scripts/` (all bounded):
`opening.py` (new game through the dream, the Commander and Nei), `forcemsg.py ID...`
(show any script message on the field and page through it), `menus2.py` (status,
techniques, strength, equipment), `battlemenus.py STEPS` (a forced battle; steps: a number
picks a list entry, a button letter presses it, `w` waits, `f` films), `building.py INDEX
STEPS` (load a building: 1 Rolf's house, 2 Data Memory, 3 Clone Lab, 4 hospital, 5-7
shops, $F teleport), `savegame.py [--continue]` (save, then CONTINUE from the title; SRAM
is written by `PS2.quit_saving()`), `camera.py`. Run any of them on
`PSII_Disasm/ps2original.bin` (the stock ROM) to compare.

## Engine, in one paragraph

Options in `PSII_Disasm/ps2.options.asm`, all 1: `relocate_script`, `long_script_offsets`,
`paged_text_buffer` (a message expands one page at a time: no length limit, the Lutz
music freeze is gone), `vwf_dialogue` (proportional script windows), `long_names` (six-letter
party names), `vwf_windows` (proportional text in every window: `ext/wintext.asm`),
`long_item_names` (full-length items, techniques, enemies, teleport places, soundtrack
titles and jobs from generated tables, `ext/longnames.asm` + `ext/lnames.asm`),
`centered_camera` (EvilJagaGenius's hack, credited in `NOTICE.md`), `damage_popups`; and
FlamePurge's *Improvement* v4.5 without its script: `improvement_fixes` (lory1990's bug
fixes), `fast_walking`, `fast_battles`, `improvement_rebalance`, `radar_names`, with its
addenda `double_rewards` and `no_red_flash` at 0 (`ext/improvement.asm`, every change in
`docs/improvement.md`). Details in `docs/pipeline.md` section 7. Generated files you should not edit by hand:
`text/script.asm` (dialogue), `ext/wtstatic.asm`, `ext/lnames.asm`, the table rows in
`ps2.asm`, `ext/names.asm`'s name table, `PSII_Disasm/vwf/*` (untracked).

Hand-made layout in `script.json` that a re-extraction would lose: the `prompts` segment
(WHO?/NEXT/ON? strings), the extra profile rows for Eusis (row 78) and Shilka (146, 148),
the name-field widths (items 10, techs 5, enemies 10). `dialogue.json` entry `loc_1B6EC`
(0D05) had its `falls_through` removed on purpose (a stock bug: it ran into table bytes).

## What to do next, in order

1. **Proofreading pass of the dialogue.** Go bank by bank with `bankdump.py`, comparing EN
   with JP: meaning, tone per speaker (above), consistency of names and terms with
   `glossary.md`, typos, and awkward line breaks. Keep changes as batches through
   `applybatch.py`, rebuild, `linecheck`, commit per bank. Known things to look at:
   * gendered pronouns for `{NAME}` (the player can rename anyone; the JP avoids pronouns
     for inserted names - prefer rephrasing over "his/her");
   * entries whose English is identical to the 1989 text (10, listed by
     `bankdump.py BANK --todo`) are intentional, but check them.
2. **See what has not been seen in the emulator** (linecheck passes, but nobody has
   looked):
   * the ending windows 1829-182F and the closing line 1830 (cell windows, not
     proportional - check the 18-cell lines fit the portraits' layout);
   * Avantino's soundtrack list (long soundtrack titles);
   * an item with Ä in a window and in dialogue (e.g. give the party a Carbon Ärmel);
   * renaming a recruit in Rolf's house (the six-letter naming path);
   * a long enemy name in the battle box messages (`{ENEMY}` at 80 px in 160).
   Use or extend the scenarios above; keep every loop bounded.
3. **Release packaging** (as `../ps4-translate`): a BPS patch against the Rev A ROM
   (CRC32 `904FA047`) with `tools/md/bps.py`, into `release/PS2_Retranslation_vX/` (ignored
   by git), with a readme; note that the owner's REV01 dump (`0D07D0EF`) differs in 16
   bytes from Rev A (see `docs/pipeline.md` section 2) - decide with the owner whether to
   ship a second patch.

## Decisions that belong to the owner - do not settle them yourself

List them as questions (they are also in `work/glossary.md` under "Open"):
* サシュネラ shown as **Sashnela** and ナサレスタ as **Nasarest** (the full forms pass the 40 px
  of the technique lists);
* ティム **Tiem** or Tim; アメダス **Amedas** (the US Climatrol);
* transliterations with no official form: Shizas, Shoots, Fanbia, Eijia, Contel, Sakra;
  the soundtrack title "Phantasy Sprait";
* place spellings first met in the dialogue: シュレーン **Shuren** (US Shure), ロロン Roron;
* from the Improvement (`docs/improvement.md`): its lowercase naming grid (not taken:
  `long_names` lowercases automatically), the addenda (`double_rewards`, `no_red_flash`,
  at 0), and Amia's profile saying "knives" where the JP has whips.

Provisional forms are already in the JSON; changing one is a batch plus a rebuild.

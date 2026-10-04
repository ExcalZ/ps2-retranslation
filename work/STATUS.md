# PS2 Retranslation - Status

Updated: 2026-10-03

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

## Done (2026-09-28): window label budgets

A label in a window is drawn proportionally in its cells: up to the next word, the row's
end, or - in the six RAM windows the game writes into - the first cell it writes
(`gentext.WINDOW_FIELDS`: MST 3, the stats 8, LV 2, EXP 3, the equipment rows 5, battle
HP/TP 3), keeping 2 px before that field. **Numbers stay right-aligned**: the game writes
them into fixed cells ending at the stock placeholder digit, so in those rows the
placeholders are taken from the `us` row and a translation gives only the label
("Strength", not "Strength   0"). Labels may have more letters than cells (run kind LABEL:
as many as fit the pixels). gentext.window_row builds a row; linecheck and the proofreader
check it the same way. Seen in BlastEm with translated labels (Items/Status/Strength,
Mentality, Dexterity, R.hand, Mst, Lv/Exp, View strength): every number right-aligned.

Docs: `docs/pipeline.md` sections 7 (the options) and 8 (the budgets), README.

## In progress (2026-09-28): the translation pass

**Tables done** (`work/script.json`, 375 entries): party names, items, techniques, enemies,
soundtrack titles, teleport places, jobs, prompts, every menu window and the eight
profiles, from the JP (the menus, profiles, jobs and places were read from the JP ROM's
window art: `WindowArtLayoutPtrs` is at $13568 there, $200 below the US; the jobs at
$112B8, the places in script bytes at $10E1D). Decisions and the open questions are in
`work/glossary.md`. Seen in BlastEm: field menus, stats, equipment, battle lists, shop,
teleport, profile, title.

Engine additions on the way: teleport places, soundtrack titles and jobs are long-name
tables too (`LONG_TABLES` in gentext; the job through `WT_JobRun`); the WHO?/NEXT/ON?
strings are a new `prompts` segment; Ä ä are script bytes $48-$49 (the Ärmel shields). The
two short profiles use five rows (the art has them; `script.json` rows 78, 146, 148 -
added by hand, a re-extraction would drop them).

**Dialogue done** (2026-09-28): all 26 banks translated from the JP (`tools/bankdump.py
BANK` prints a bank for translating; the ten entries still equal to `us` are the same in
English). Where the US split one JP message over several ids (`jp_cont`, the old 255-byte
blocks), the ids are kept and the JP text is spread over them at page breaks. Voices: Eusis
narrates in the first person; the Dezolians a light rural dialect (ズラ, オラたち "us
folks"); the Clone Lab's doctor old-fashioned; Avantino theatrical; the Gaira robot in
capitals; the ending's last words in the 18-cell ending window. PS I names as the PS IV
translation ships them (Alisa, LaSheek, Gaira). Stock bug fixed on the way: 0D05 ran on
into the Room bank's table bytes. Seen in BlastEm: the new-game path through the dream,
the Commander and Nei (`work/scripts/opening.py`), the chained Library, Commander and Lutz
messages (`forcemsg.py`).

**Next:** a proofreading pass (play-through and the proofreader), the open naming
questions in `work/glossary.md`; then release packaging (a BPS patch against Rev A; REV01
users need Rev A or a second patch).

Proofreading pass complete (2026-09-28): all 26 dialogue banks, `ItemAction` through
`Miscellaneous`, checked against JP; 39 wording fixes in all. Next: the unseen emulator
scenarios listed in `AGENTS.md`.

## Done (2026-09-28): battle damage pop-ups

`damage_popups` displays each nonzero hit over its target for 45 frames, for both
enemies and party members. Area attacks occupy separate slots per target. The stock
damage total and HP calculation remain intact; the option-off build remains byte-exact.
`ext/damagepopups.asm` now frames each number in a 16-pixel-high blue window with a
white border. It opens from 8 to 32 pixels, holds the number, and closes over its last
six frames. Digit and box tiles occupy $33C-$373, free in all audited battle backgrounds.
`work/scripts/damagepopups.py`
forced a Shotgun attack (two enemy slots, 9 and 10) and an enemy all-party attack
(two party slots, 27 and 26), plus Megid (three enemy slots and Nei's HP cost);
each active slot's full-width digit and box sprites and closing frames were verified. BlastEm
savestates rendered the enemy and party area-hit frames in
`work/analysis/damagepopups/` (ignored by git); the numbers appear above
their targets.

The party windows now sit over the character art, five pixels above the lower
status bar, and lead the sprite list so character sprites cannot cover them.
The stock total beside the enemy name remains active (the Shotgun's two hits,
9 and 10, accumulated to 19). `damage_popup_font` selects exact stock HP/TP
numerals (`0`, the owner's preferred default) or thicker numerals with a tighter visible gap (`1`).
Both font variants were captured in the bounded party area-hit scenario.
Enemy damage windows now stay at a fixed position five pixels below the top
enemy-name windows; the opening and closing frames keep the same Y coordinate.

## Done (2026-09-29): Phantasy Star II Improvement v4.5

FlamePurge asked for his *Improvement* (`PSII_Improvement_v45.zip`, an IPS against Rev A,
not tracked) to be taken in. Everything but its script and names is in, in six options:
`improvement_fixes` (lory1990's bug fixes), `fast_walking`, `fast_battles`,
`improvement_rebalance` (equipment, shops, chests, techniques, level tables, default
commands, Van Leader, no stealing on Dezolis), `radar_names`, and the two addenda
`double_rewards` and `no_red_flash` (at 0, as the Improvement ships them). The IPS was
rebuilt from lory1990's disassembly with code inserted, so it was read back by aligning
the two ROMs and disassembling what was left; `docs/improvement.md` lists every change,
its place and its hook, and what was left out (the script, the names and labels, the
window layout that goes with them, the lowercase naming grid, the Lutz and final-boss
message splits). 18 same-size hooks call `ext/improvement.asm`; the data is `if/else`
around the stock lines. Nothing moved, every option at 0 still builds Rev A, and every
changed table (items, techniques, the eight learn lists and level tables, starting gear,
shops, chests, default commands, formations, weapon records, Menobe, Mechoman) equals the
Improvement's ROM byte for byte. New item names: Cyber Vest, Silver Claw, Wave Shot.

Checked in BlastEm (`work/scripts/improvement.py`): the leader walks 14 px in its first 8
frames (stock 7) and the follower stops one tile behind. The rest is listed in
`docs/improvement.md` as not yet watched.

**Open for the owner:** the Improvement's naming grid (18 columns, lower case, "-" and ".")
against `long_names`' automatic lower case; whether the addenda should be on; the radar
keeps DEZOLIS where the Improvement has DEZORIS.

## Done (2026-09-29): the battle box, and two new status messages

`battle_box`: the battle box is as wide as the dialogue window (24 cells, 192 px), and a
message with a `{BR}` opens it two lines tall (rows 15-20, the script window's art), so
the status messages no longer wait for a button between pages. The stock box has
`$CD1C` = 0, where every line feed clears it; the two-line box sets 2, and the stock scroll
(hard-wired to 24 cells) and the VWF renderer (24 cells whenever `$CD1C` is not 0) serve it
unchanged. The size is chosen when the box opens, from the ids queued in `script_id`
(`BattleBox_Record`, in place of `ProcessWindows`' record `lea`); the victory rewards and
level-ups (1213-1217) are queued into the open victory box later, so `linecheck.py` keeps
them to one line. 1208, 1224, 1226-1229 and 122A now break with `{BR}`; 1223 fits on
one line.

Rows 15-16 belong to the battle floor while the fight runs: `loc_5BB0` (the battle's
vertical blank) DMAs them from RAM $FF6780 every frame, which painted over the two-line
box's top border and blank row (its text, rows 17 and 19, survived). `BattleBox_Floor`
takes that DMA's place: while a two-line box is in the window stack (or being opened or
closed), it copies the two rows around it (columns 0-6 and 33-63), so the floor keeps
moving beside the box; otherwise the stock DMA. Seen in BlastEm (`battleability.py 8`).

A battle message ending in `{C6}` stays up a second a row of its box once typed: 60
frames in the one-line box (stock), 120 in the two-line one (`BattleBox_Time`, set with
the box's size; `Win_BattleMessage` loads it into the `{C6}` timer `$CD22` in place of the
stock `$3C`). Timed in BlastEm: 122A typed by frame 82, closed at 204.

`status_messages`: 122B "Defensive barrier up!" (DEBAND and the Snow Crown, which halve
the damage the party takes and said nothing) and 122C "TP drained!" (Sea Scissors and
Droll Monkey empty a member's TP, silently in the stock game; the HP drain's "Heal" is the
enemy window's readout, and enemies have no TP to show). Two `scriptofs` rows and blocks
after 122A under the option; `dialogue.json` marks the entries `added` (no stock text:
`test_text.py` skips them, `gentext.py` skips them when their `en` is empty, as in
`checkstock.py`).

Seen in BlastEm: the one-line wide box (1204, 1223 with a six-letter name, the victory
messages), the two-line box forced (122A, 1208; `battlebox.py`) and in real rounds (the
evil heart's 1228 and 1229, `battleability.py 8`), DEBAND's and the TP drain's messages in
real rounds (`battleability.py 14`). Forcing a second message while the battle's round
runs (the round starts when a forced box closes) stacks it with the round's own windows
and leaves a stale box behind: an artifact of forcing, not of the game's flow.

## Done (2026-10-01): the final scene in the proportional face (`vwf_ending`)

The speeches beside the portraits (1829-182F, 18 cells) and the closing line (1830) were
the last text in cells. `loc_7932` (which sets `$CD1C` = $C) now jumps to `Ending_Window`
(same 6 bytes, `ext/vwf.asm`), which records the line width (18 cells; 24 for the closing
line, recognised by its start cursor $4418) in `VWF_EndCells` ($CF94, past the battle box's
words); `VWF_Draw` no longer hands $CD1C > 6 to the stock cells. Pool: the speeches use
the usual one, VRAM $D000-$DFFF - plane A's lower half, which the speeches never display
(vscroll 0; zero in all seven states, `tools/vramaudit.py`) - as seven 18-tile slots. The
closing line is up as the credits start, and the credits scroll plane A through all 64
rows and write names over its lower half, so it takes five 24-tile slots at tile $400
(VRAM $8000, unreferenced by every ending state and by the credits). That scene's font has
paper 0, not $B: lines are cleared to 0 and `VWF_Upload_Bare` expands only the ink.
Budgets (`linecheck.py`, the proofreader): 144 px a line and 7 lines; the closing line 192 px,
5 lines. The six speeches are reflowed to the new width (2-4 lines) and the closing line
is centred with spaces; text unchanged. `work/scripts/ending.py` jumps to the Ending screen
from the field (it times itself, no buttons) and films each window and the credits:
verified in BlastEm, the credits start without disturbing the closing line.
`checkstock` byte-identical, `checkbuild` "nothing moved".

## Done (2026-10-02): six-cell technique names (`wide_techs`) and TP in the battle list (`battle_tech_tp`)

The owner's call: サシュネラ is **Saschnella** (46 px) and ナサレスタ **Nasaresta** (44 px),
so the technique budget is 48 px (`gentext.LONG_TABLES`; the proofreader and `linecheck`
follow it). Four windows draw technique names, all through the five-cell loop `loc_FF2E`
(and its copy `loc_10342`): the field list and its NEXT page, the battle list, the plate
shown while a technique is cast, and STRNG's two lists. Their art has fixed sizes in the
dynamic window RAM, but the field list's art is followed by an identical copy nothing
refers to (`loc_1598C`): 252 bytes, `TW_ART`. Each builder now copies a wider template
from `ext/techwin.asm` there (the plate at +112), forgets the runs other layouts left in
it (a stale run would be drawn into this layout's cells), and the loop writes six cells.
Field list 8 cells, battle list 8 (11 with TP), plate 6, STRNG 13 each (the pair moved four
cells left, $10 and $30, keeping the stock gap and right margin). The windows grow to the
right, so no cursor moves.

`battle_tech_tp`: after the name, a blank and the cost (record byte 6) in two stock digit
tiles, right-aligned by `loc_11364` as the HP/TP windows do; empty rows stay blank. The
costs go up to 55 (Megid), two digits. The field list keeps no TP (PS IV shows it there
too; one more option if wanted).

Seen in BlastEm (`work/scripts/techwin.py`, Amia leading, as her lists hold both): the field
list and its second page (Gisaresta, Nasaresta), STRNG's lists (Saschnella, Nasaresta),
the four battle pages (Saschnella 6, Gisaresta 29, Nasaresta 53) and the plate while she
casts Saschnella. `checkstock` byte-identical, `checkbuild` "nothing moved", `linecheck`
0 problems with the wider `{TECH}` insert. Noticed on the way, not from this change:
opening Tactics in battle redrew the first enemy name with tiles of the Orders/Retreat
window ("Biting Ant" became "at:ing Ant"). Fixed in `ext/wintext.asm` (an unstacked window
that outgrows its tile range is drawn again in fresh tiles; `WT_HUD` moved to $8F80, ranges
with a bottom; `work/scripts/tacticswin.py`) and seen together with this change: the name
stays through Tactics, the technique lists and a round.

The STRNG technique lists now draw FIELD on the left and COMBAT on the right,
centred over each bottom border. They are selected by window ID because both
lists share the same dynamic art. In the Amia menu the two labels take 3 and 4
VWF tiles: the open stack ends at 210 of 358 field tiles, with no overflow.

## Done (2026-10-02): battle result timing and amber healing popups

The damage popup hooks still run the stock calculations during action setup, so the
multi-target and kill decisions see their normal results. They retain each target's old
and calculated HP, and the battle loop shows the old HP until three frames after the
animation's `$FD` impact cue. That frame applies HP, opens the number window and queues
the top battle text and refreshed stats. An enemy's instant-death attack uses the same
delay. A Technique's name plate opens at the `$F3`
casting-effect cue; the `$FD` handler no longer opens it a second time. Healing from
RES/SAR, SAK/NASAK, REVER, drains and enemy healing shows the actual capped HP restored
in amber (palette 0 colour 3, `$0AAE`), omitting zero recovery.

`sourcebuild`, `checkbuild` (nothing moved), `linecheck` (0 problems), `gentext --check`,
`test_text`, and `checkstock` (byte-identical Rev A with all options off) pass. A bounded
BlastEm trace of a physical hit held enemy HP at 9 while 0 was pending, then applied 0
and opened its popup on the third frame after impact. A RES trace held Rolf's HP at 498
while 518 was pending, opened the technique plate during casting, then applied 518 and
opened an amber 20 popup on the third frame after impact. The amber digits were checked
in a savestate render (`work/analysis/heal_popup.png`).

Mixed enemy groups can load enemy art into battle palette 3. Waspy and Mosquito
healing digits once inherited that group's dark colour 3. The digit sprite now
uses the fixed battle HUD palette 0 colour 3, shared with field healing. A bounded
BlastEm check saw the heal sprite use palette 0 in both a Mosquito/Fire Ant group
(palette 3 colour 3 was `$0248`) and a Waspy/Buzzer group (`$066A`).

## Done (2026-10-02): battle name tile collision and target prompt

The owner's BlastEm victory state showed "Fencer" as "Fence": its final tile $6DF
was cleared when the victory message took the dialogue ring's fourth line
($6C8-$6DF). The battle window pool mistakenly included $6B0-$6DF. It now uses
$6E0-$6FF and extends its other free range to $374-$3FF, after damage popups'
$33C-$373. Both the battle audits and the saved victory state leave that range
free. A bounded Fencer formation ($47) ran through battle exit with no VWF
overflow; the two pools no longer share tiles.

A second saved state showed `To whom?` as `To w` / `hom?`. `loc_F83A` copies the
eight-byte prompt in two groups of four into separate rows. `gentext.py` now
keeps its art blank with `vwf_windows`, emits the full prompt as text, and
`wintext.asm` draws it on one bottom row of the target window. `linecheck.py`
checks its 48-px VWF budget. The target window opens in the bounded harness
with blank source art and no tile overflow.

## Done (2026-10-02): PS IV field menu with the party panel; field healing popups

The field menu is now PS IV's: Items, Techs, Status, Equip at the left (the old
Strength is Status; the old Status entry is gone), meseta below, and at the right
a party panel: per member the name and LV, HP, TP, its height by party size. The
panel is MenuCharStats given another record and RAM art ($FF8B4E, 170 bytes at
most) whenever it is asked for while the field menu is on the window stack, so the
heals and cures that redraw that window in place now redraw the panel. The
"Who?" lists stay for choosing a character. Cursors of windows the panel is
redrawn over are moved off the screen. The hospital and events still get the stock
stats window.

Healing from the field menu (Monomate/Dimate/Trimate, Star Mist, Moon Dew,
RES/GIRES/REVER, SAR/GISAR/NASAR, SAK, NASAK) shows the HP actually restored in
amber just left of the member's HP row in the panel; none for a member who gained
nothing (Codex's implementation, `ext/fieldheal.asm`, reviewed and corrected).

Fixed in review: the SAK hook was 18 bytes for 20 with `improvement_fixes` at 0
(checked by a build with that option off: nothing moved); every slot after the
first read its position from the wrong table entry (X and Y swapped); the
popup coordinates had been guessed from a capture of the Codex window, not the
game; the menu's window record had the wrong size bytes ($07,$0A for a 7 x 10 art:
every row skewed) and its blank cells were assembled as $20 (hatched tiles).

`work/scripts/fieldheal.py` (new, bounded; `exact` adds savestate renders):
Monomate capped, Star Mist with one member full, Star Mist on two, RES, SAR, Moon
Dew reviving, SAK, REVER, NASAK, and Star Mist on a four-member party; each checks
the amounts, the HP, that the slot is drawn and ageing, and no tile overflow.
`partymenu.py` now films each stage. `menus2.py`, `techwin.py menus` and the
hospital (building 4) pass and were looked at. Note: the hospital quoted 0 meseta
for Eusis at level 1, 5/19 HP - not looked into.

## Done (2026-10-02): PS IV status screen; covered cursors hidden

Status > Status > a character now opens PS IV's status screen: the character's
portrait at the top left, beside it the name, job, LV, HP and TP, the stats at the
right over the party panel (its lower members show below, as PS IV's roster), the
equipment below the portrait, EXP and NEXT (what the next level needs, from the
EXP table; blank at level 50) at the bottom right, meseta (moved to rows 25-27)
below the equipment. Five windows opened on stock window IDs with a variant bit
($0800 in window_index); the dispatch and record hooks give the portrait, info and
EXP windows art of their own (in the RAM of stock windows never up with the status
screen, each copied from ROM when its own window opens: MenuCharStats, the Rolf's
house regroup lists, CharOrderDestination; runs left there are forgotten) and
move the stock stats and equipment windows. B closes the five; C still opens the
techniques.

The portrait: the stock portrait window's art with its tile numbers moved to the
dialogue ring ($680-$6DF, 96 tiles, idle while no message is up; every party
portrait is 84-96 tiles), decompressed there with the display on (each tile
written with interrupts held off), its palette in line 1 (the map's saved and put
back once the window is off the stack and not being drawn; on the field line 1 is
only some NPC sprites, which show in its colours meanwhile). $F72C is $A600 while
it is drawn and reset by the next window's record. Wintext skips it.

Cursors: every field frame (PM_FieldFrame, from the field-heal frame hook) a
window's cursor that a window above it covers - or the panel redrawn over the
stack by a heal - is moved above the screen, and back when uncovered. This fixes
the Status/Order cursor showing over the character list, and replaces the heal
redraw's own hiding.

Bugs met on the way, fixed: the decompressor and the EXP digits clobbered d2
(two address errors); `PM_PORT_TILE*$20&$3FFF` assembled as $D0000000 (a CRAM
write; parenthesised); AS scopes `.local` labels by `+`/`-` labels too (renamed).
`partymenu.py` opens Eusis's and Nei's status screens, the techniques, backs out
and films each; `fieldheal.py`, `menus2.py`, `techwin.py menus` (Anne's portrait)
pass with no tile overflow.

## Done (2026-10-02): PS IV Equip screen; NPCs hidden under the portrait palette

The status screen's portrait borrows palette line 1, which on the field only map
NPC sprites use: those sprites are now taken out of the frame's sprite table while
it is loaded (`PM_HideNPCs`, after BuildSprites and at once when the portrait
loads), instead of showing in the portrait's colours. The party, cursors and heal
numbers use line 0.

Equip > a character is now PS IV's Equip screen (`ext/equipscreen.asm`), no portrait
(the item messages use the dialogue ring the portrait would occupy):
* the comparison at the top left: Attack, Defense, Agility now ▶ with the highlighted
  item (worn: without it; a one-handed weapon: in the right hand), and, in the
  Right/Left window, with it in the hand under the cursor. The preview runs the
  game's own loc_ADBE/loc_AD4C on the character and puts everything back, so it
  matches what equipping gives (a two-handed weapon counts in both hands, as the
  game counts it). Its numbers are written into its cells when they change, as the
  stock stats animation writes its own (that animation is off on this screen).
* the item list beside it, filtered to what the character can equip (InventoryData
  +$D), worn items E-marked so picking one still removes it; as tall as its entries,
  "Equip" on its bottom border. The filtering swaps the character's inventory for
  the filtered list while the screen is up and writes the E marks back when it
  closes, so every stock use of the list index stays right.
* the equipment window below the comparison, the name on its bottom border.
* `▶` is text byte $4A in the proportional face (`tools/ps2text.py`,
  `tools/diafont.py`).

Fixed with it: two stock references to fixed window-stack slots that the field
menu's extra windows had moved - the stats animation's `$DF40` (it drew numbers
into whatever window was in slot 4) and the second page's E fix `$DF62` (now the
top window's save when that is page 2, else nothing). A portrait closes with the
windows above it (`PM_CloseCount`), which replaces the status screen's own close
count; on the Equip screen B never closes past the Who? list (three windows where
the stock counts four).

`work/scripts/equipscreen.py`: the list holds exactly Eusis's equippables (with the
rebalance: the Neimet yes, the Dagger and Titanium Armor no), the comparison for
every entry and both hands matches the item data, the Carbon Shield goes in the
left hand, B returns to the Who? list with the inventory whole and the new E mark.
`partymenu.py`, `fieldheal.py`, `menus2.py`, `techwin.py menus` pass, no tile
overflow; checkbuild, linecheck, gentext --check, test_text, checkstock pass.

Follow-up (2026-10-02): saved Equip screens after a two-handed weapon and after
adding a Sonic Gun had VWF overflow counts 22 and 30. The stock equip flow redraws
the equipment and item windows in place with `window_index` bit 2; their original
windows stay on the stack. Wintext had treated those redraws as new HUD windows,
eventually allocating its remaining tiles away from the stacked windows and
dropping the later equipment labels and the list's VWF. `WT_StackRedraw` now
recognises the same plane position, art and window ID on the stack and reuses its
tile range; if the redraw needs more tiles, it retries with the HUD allocator.
`equipscreen.py` now checks the one-handed Shield, two-handed Sword, and a Sonic
Gun added before reopening the menu, with zero VWF overflow. The status-menu and
field-healing scenarios still pass.

The field window pool now includes 93 stock font tiles: the upper/lowercase
alphabet, punctuation and unused Japanese glyphs (first 123; the slash, arrow and
icons `$563-$580` are drawn as they are, and text written over `$564` lost the
party panel's HP/TP slash - taken out 2026-10-03). They are selected only on `ScreenID_Level`;
the naming grid in buildings and the battle HUD still need their original tiles.
Window VWF draws new glyph data before selecting each tile, so no VRAM clearing
pass is needed. `equipscreen.py` exercises the expanded pool (HUD floor 354 after
the equip redraws) with zero overflow; `partymenu.py` and `checkstock.py` pass.

## Done (2026-10-02): portrait outlines

The portraits' outlines are colour 0, transparent: in Rolf's house the black
backdrop shows through, on the field the map did. While the status screen's
portrait is up, the map's plane B cells under its interior are saved (into
text_buffer, idle with no message up) and set to tile 0, so the backdrop (black,
palette 0 colour 0, on the field) shows through as in the house; they go back when
B closes the portrait (PM_CloseCount), in PM_Close, or by the field frame's check.
The portrait now draws at once, so the blanking follows in a frame. This needs
planes A and B scrolled together (the field's full-screen scroll; checked in a
state: H and V scroll equal). Pixel-exact: no portrait colour was changed (most
portraits use all 16 indices, so recolouring would have cost a merged shade).

## Done (2026-10-02): playtest fixes - hospital, Techs, popups, battle top row, profiles, statuses

* The hospital's stats window showed "Unemployed": the status screen's info window and the
  Equip comparison register text runs in its art buffer; the stock MenuCharStats now
  forgets the runs left there before it builds (`PM_StockWindow`).
* Techs opened a second party window: the stock entry queued the bottom stats window,
  which the field menu turns into the panel. It now queues the character list alone, and
  B closes one window. The menu reads "Techniques": `PM_MenuArt` has seven label cells
  (`pm_width` on the entry in work/script.json, read by gentext and linecheck).
* Two weapons on one target: the second strike's calculation cleared the first strike's
  pop-up. A hit's number now waits in `POP_PENDVAL` ($FFFF8FE0) for its impact; a number
  still showing stays until then (`work/scripts/dualwield.py`, FORMATION=9: a lone Whirly).
* `battle_name_panes` (new option): no stock damage panes (the pop-ups show the numbers;
  three queue sites: battle start, `Popup_QueueWindows`, the round start's literal
  `$66C066D`), the enemy names centred (wintext renders a name once to measure it, again
  from the centring pen: `WT_PEN0`), the second group's pane at the right corner.
* Rudger's profile was cut at 128 px: wintext's canvas holds 16 cells. Longer runs are
  drawn in 16-cell pieces, the text rendered again for each with the pen 128 px further
  left; letters across a piece's edge are clipped/spilled (`WT_CHUNK`); a label may have
  64 letters.
* Change Members did not show Rudger: the status screen's portrait shares the art buffer
  of Rolf's house's member list, and wintext skipped that list as "the portrait". The
  portrait checks now also test the window ID.
* Battle statuses (the tombstone, Zzz, ...) were hidden under the fixed "HP"/"TP" runs.
  A window's fixed label run is drawn only while its art cells are blank; status tiles
  the game writes there show, and the "HP"/"TP" letters it writes are the scan's runs.

All scenarios (partymenu, fieldheal, equipscreen, hospital, menus2, techwin menus) and
checkbuild, linecheck, gentext --check, test_text, checkstock pass.
Seen, not looked into: after View Strength in Rolf's house the house portrait window
shows the last profile's portrait with its lower part garbled (stock?).

## Done (2026-10-02): the field menu returns to its lists

As PS IV's: an item used, given or dropped, or a technique used, from the field menu
comes back to the list it was picked from instead of closing the menu (`PM_CloseAll`, a
hook on CloseAllWindows): the windows above the list close, the party panel and the list
are drawn again (an item may be gone; a heal's copy of the panel, closing, would put the
old HP back), and the menu waits for the next pick. No items left: the character list.
What leaves the menu anyway still closes everything: Telepipe, Escapipe, the key and
event items, Ryuka, Hinas, Musik. `work/scripts/menureturn.py` checks Use, Give, Drop,
the last item and a technique; every other scenario and check passes.

## Done (2026-10-03): save-aware title menu

The title menu now checks all four save slots when it opens. With none occupied it
shows only Start a New Game. With any occupied it shows Continue a Game first and
selected by default, then Start a New Game and Erase Data. The original three-row
art and event routing remain behind `title_save_menu = 0`; a one-row variant is
used for empty SRAM. `work/scripts/titlemenu.py` checks the empty menu and all
three routes with an existing saved file.

## Done (2026-10-03): Options on Start (`field_options`)

As PS IV's: Start on the field (where C would open the menu) opens Options, Battle Speed
and Message Speed, each 1 (fast) to 5 (slow), the value's digit in yellow; up/down pick,
left/right change, B, C or Start close. Elsewhere Start still pauses.

* **Message Speed** 3 is the stock letter a frame; 1 two a frame, 5 one every second
  frame. The same message types in 15 / 29 / 58 frames at 1 / 3 / 5. Battle messages too.
* **Battle Speed** 2 (the default) is the stock pace: battle box hold 60 frames (120 for
  two lines), pop-ups 45, about 33 frames from a hit to the next actor's move. 1: 45, 30,
  ~25; 3-5: 80/100/120, 60/75/90, and 10/20/30 frames more before each actor. At 1 the
  party's stats windows are not drawn a second time after an action when nothing they
  show changed since the impact drew them (a checksum); the swing itself is not cut, so
  the hit-to-next gap is ~25, not 20. A fight: an actor every 44 / 52 / 84 frames at
  1 / 2 / 5; a death at 1 still shows the tombstone and 0 HP.
* Saved with the game in two spare bytes of the saved party block (`$C696-$C697`), 0 the
  default, so older saves read as Battle 2 / Message 3; checked by saving in the Data
  Memory and continuing.
* `work/scripts/options.py` checks the window, the clamps, the pause it leaves alone,
  the typing at three speeds and a fight at two. partymenu, menureturn, fieldheal,
  battlebox and titlemenu still pass; checkstock byte-identical.
* Labels "Fast", "Slow", "Battle Speed", "Message Speed" are `work/script.json`'s
  `options` segment (no JP or US: the stock game has no such window).

## Done (2026-10-03): search no longer skips encounters

The stock field loop skips an encounter roll when the A-button search opens on a
tile-centre frame. Holding a direction while closing the window moves the party off
that centre before the next roll. `search_encounter_fix` records the skipped check in
the moved flag and resolves it once the window is gone, before another search can
open. `work/scripts/searchencounter.py` reproduces the timing in BlastEm and checks
that the roll happens before the next tile centre. The stock option stays byte-exact.

## Done (2026-10-03): shop declines return to opening choices

When a character cannot equip a weapon or armor purchase, No at the confirmation now
plays that shopkeeper's new reply, closes the character and item lists, and reopens the
shop's first item selection. `shop_no_reprompt` keeps the stock event flow at 0.
`work/scripts/shop_reprompt.py` tests the Dagger and Carbon Vest paths in BlastEm,
including a second item choice after No. The stock option remains byte-exact.

In the Item Shop, B at Buy > Who? plays 0811 ("Oh, so you've reconsidered.") and
returns to the Buy item list. B from that list or the Sell character list plays
0812 ("In that case, is there anything else") and returns to Buy/Sell. B from a
Sell item list still steps back to character choice first. An unaffordable purchase
keeps 0807 ("You don't have enough money.") and returns to Buy/Sell after dismissal.
`ext/itemshop.asm` distinguishes these paths and waits for each reply before
reopening its menu; `work/scripts/itemshop_reprompt.py` checks the complete flow.

## Done (2026-10-03): the shops show who can equip an item, and how it compares

`shop_equip_compare` (`ext/shopequip.asm`): in the weapon and armor shops a party window
under the portrait (as wide as it, ending above the dialogue; a full party's covers the
portrait's lower rows), "Can equip" on its top border, marks each member while the item
list has the cursor: ▲ the item raises Attack (weapon shop) or Defense (armor shop), ▶ (the
Equip screen's arrow) no change, ▼ lowers it, nothing if they cannot equip it. At Who? the
Equip screen's comparison opens in its usual place, under the Who? list, and follows the
cursor (blank "then" numbers for one who cannot equip the item). A one-handed item is
compared in the hand holding the shop's kind of thing or nothing (of those, the one holding
the least of the stat), else either. `work/scripts/shopequip.py` checks every item of both
Paseo lists against a model with four members in different gear, the comparison for each
member, and the stack after Yes and after No (the party window once, the comparison
closed); `shop_reprompt.py` (its stack now has the two windows), `equipscreen.py` and the
item store pass; checkstock byte-identical.

## Done (2026-10-03): Equip comparison holds through the "equipped" message

Confirming an item on the Equip screen showed the bare stats (no equipment) in both
columns until the message closed: the stock flow takes the bonuses off (`loc_ADBE`,
event_routine 5) and puts them back on only after the message (`loc_AD00`), and
`EQ_Frame` kept redrawing from the character. At event_routine 5 it now leaves the
numbers, so the comparison just confirmed stays up and updates when the message
closes. Seen from the owner's savestate (Rudger, Headgear: 79 > 74 stays, then 74);
`equipscreen.py` and checkstock pass.

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

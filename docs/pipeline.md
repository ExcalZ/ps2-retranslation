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
  (the Library, the Commander, many story scenes) four; the battle box 20 cells, one line
  (the window code sets `$CD1C`, the last text row: 2, 6, 0 in the battle box, where every
  line feed clears the box, so a battle message pages with a button wait);
  the final scene draws beside the portraits (`loc_7932`: 18 cells, 7 lines; the closing
  line 26; with `vwf_ending` 144 px and 192 px, the closing line five lines at most). `extract_dialogue.py` infers each entry's window from the most lines the US or
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
| `shop_no_reprompt` | declining equipment the selected character cannot use gives a shop-specific reply, closes the character and item lists, and reopens the shop's first item selection | `Building_WeaponStore`, `Building_ArmorStore`; `work/dialogue.json` 0604/0704 |
| `paged_text_buffer` | a message is expanded one page (up to a `{PAGE}`) at a time: any length fits; the Lutz overrun is gone | `ext/script.asm` |
| `vwf_dialogue` | proportional text in the script windows (dialogue, big window, battle box), drawn into a ring of VRAM tiles | `ext/vwf.asm` |
| `vwf_ending` | the final scene's speeches (18 cells = 144 px, 7 lines) and closing line (192 px) proportional too; paper 0 as that scene's font; a hook in `loc_7932` records the width | `ext/vwf.asm`, `Ending_Window` |
| `long_names` | party names of up to six letters (letters 5-6 beside the stock four, saved with them) | `ext/names.asm` |
| `vwf_windows` | proportional text in every window: labels, lists, names; runs drawn into free VRAM once a window is up | `ext/wintext.asm` |
| `long_item_names` | full-length item, technique and enemy names from tables of their own; the records keep the stock names | `ext/longnames.asm` |
| `wide_techs` | technique names in six cells (48 px): the field list (8 cells), the battle list and the plate shown while a technique is cast one cell wider, STRNG's two lists two (13; the pair moved four cells left). The four builders copy their art from templates into the field list's RAM and the unreferenced copy after it (`loc_1598C`; 252 bytes), forgetting the runs other layouts left there. The STRNG lists draw FIELD and COMBAT over their bottom borders as VWF runs | `ext/techwin.asm`, hooks in `loc_FEF2`, `loc_FF2E`, `loc_102F0`, `loc_10342`, `loc_10CBE`, `Win_BattleTechUsed`, the window table |
| `battle_tech_tp` | the battle technique list shows each technique's TP cost (byte 6 of its record) after its name and a blank, two digits right-aligned in the stock digit tiles (`loc_11364`); an empty row shows none. The list is 11 cells wide | `ext/techwin.asm` |
| `centered_camera` | the field camera keeps the player centred (EvilJagaGenius's four scroll thresholds at `loc_3956`) | `ps2.asm` |
| `battle_box` | the battle box as wide as the dialogue window (24 cells, 192 px, columns 7-32); a message with a line feed in the ids queued when it opens gets the script window's 24 x 4 art two rows higher (rows 15-20) and `$CD1C` = 2, so it shows two lines and scrolls; while it is up, the fight's per-frame copy of the floor to rows 15-16 skips its columns; a `{C6}` message stays up a second a row of the box (60 or 120 frames) | `ext/battlebox.asm`, hooks in `ProcessWindows`, `Win_BattleMessage`, `loc_96AE`, `loc_5BB0` |
| `status_messages` | two battle messages the stock game lacks, added to the battle bank as 122B (DEBAND and the Snow Crown) and 122C (an enemy's TP drain) | `ext/battlebox.asm`, `TechAction_Deban`, `loc_3014` |
| `damage_popups` | per-target damage and amber healing numbers; HP changes and top battle messages are delayed three frames after impact, while Technique names open at casting | `ext/damagepopups.asm` |
| `damage_popup_font` | with pop-ups on, `0` uses the stock HP/TP numerals (default); `1` uses thicker numerals with a tighter visible gap | `ext/damagepopups.asm` |
| `field_heal_popups` | (needs `damage_popups`) healing from the field menu - Monomate/Dimate/Trimate, Star Mist, Moon Dew, RES/GIRES/REVER, SAR/GISAR/NASAR, SAK, NASAK - shows the HP actually restored in amber beside the member's HP (the party panel with `party_menu_ps4`, else the stats window), none for a member who gained nothing. Four sprite slots (the battle's party slots), VRAM `$23A-$25D` (the field VWF pool starts at `$25E`), cleared at every map load; checked by `work/scripts/fieldheal.py` | `ext/fieldheal.asm`, hooks in `loc_7D08`, `LevelScreenLoop`, `loc_A016`, `loc_A130`, `loc_A1C8`, `loc_A71C`, `loc_A78A` (SAR), `TechEffect_Sak`, `loc_A8C8` (NASAK) |
| `battle_name_panes` | (needs `damage_popups`, `battle_box`, `vwf_windows`) the battle's top row without the stock damage panes: the enemy names centred in their panes, the second group's pane at the right corner | `ext/battlebox.asm` (`BN_SecondName`), `ext/wintext.asm` (`WT_RenderCentred`), `ext/damagepopups.asm`, the queues at `loc_8730` and `loc_F186` |
| `party_menu_ps4` | (needs `field_heal_popups`) the field menu as PS IV's: four entries (Items, Techs, Status, Equip) at the top left, meseta at the bottom left, the party at the right (one block a member: name and LV, HP, TP; its height follows the party). The panel is MenuCharStats with another record and art while the field menu is on the window stack, so the field's heals and cures redraw it in place; the stats window elsewhere (hospital, events) is stock. Status opens Status/Order, then a character's status screen as PS IV's: portrait (tiles in the dialogue ring `$680-$6DF`, palette line 1 while it is up), name/job/LV/HP/TP, stats over the panel, equipment, EXP/NEXT; C its techniques (NPC sprites in palette line 1 are hidden meanwhile). Equip opens PS IV's Equip screen (`ext/equipscreen.asm`): the Attack/Defense/Agility comparison now ▶ with the highlighted item or hand, the item list filtered to what the character can equip (the inventory swapped while the screen is up), the equipment with the name on its border. Every field frame, cursors covered by a window above them are hidden. An item or technique used (an item given, dropped) returns to its list instead of closing the menu (`PM_CloseAll`). Checked by `work/scripts/partymenu.py` | `ext/partymenu.asm`, `ext/equipscreen.asm`, `ProcessPlayerMenu`, `Win_PlayerMenu`, `PrepareWindows`, the record hook in `ProcessWindows`, `WT_DrawWindow`, `CloseCurrentWindow`, `LoadCursorInWindows`, `loc_AAE6`, `loc_96EC`, `loc_ACC2` |
| `title_save_menu` | (needs `battle_box`, `vwf_windows`) checks the four save-slot name bytes whenever the title menu opens. Empty SRAM shows only Start a New Game; otherwise Continue a Game is first and selected by default, followed by Start a New Game and Erase Data. The one-row art and reordered labels are drawn through the existing window renderer. Checked by `work/scripts/titlemenu.py` | `ext/titlemenu.asm`, the `ProcessWindows` record hook, `Win_GameSelect`, `IntroScr_EventSelectGame`, `tools/gentext.py` |
| `field_options` | (needs `party_menu_ps4`, `battle_box`, `vwf_windows`) Start on the field, where C would open the menu, opens Options, as PS IV's (elsewhere Start pauses as stock): Battle Speed and Message Speed, 1 (fast) to 5 (slow); up/down pick, left/right change, B/C/Start close; the value's digit in yellow (palette 0 colour $C; five recoloured font digits in the dialogue ring, `$680-$684`). **Message Speed**: 3 is the stock letter a frame, 1 two, 5 one every second frame (an accumulator in the `RunScript` loop; a button still finishes the page). **Battle Speed**: 2 (the default) is stock. Battle box `{C6}` hold 45/60/80/100/120 frames at 1-5 (the two-line box twice that), pop-up life 30/45/60/75/90, and before each actor moves the fight waits 0/0/10/20/30 frames more. Stock, a hit to the next actor's move is about 33 frames: the target's flash and the attacker's swing (~24), then the four party stats windows drawn a second time (8 frames; the impact drew them already) and one more. At 1 that second drawing is skipped when a checksum of what they show (each slot's character record and command, `BS_Checksum`) is the one taken when the impact queued them (`Popup_QueueWindows`): about 25 frames. Actor to actor in a test fight: 44 frames at 1, 52 at 2 (as stock), 84 at 5. The settings are two bytes of the saved party block nothing used (`$C696-$C697`), stored so 0 is the default: saved with the game, older saves read as 2 and 3. The window is ID `$75`, past the stock table; its labels are `work/script.json`'s `options` segment (`static_art`: runs only, the art is fixed). Checked by `work/scripts/options.py` | `ext/options.asm`, `CheckGamePause`, `CheckRunScript_Part2`, `loc_F0C0`, `loc_F188`, `loc_F19E`, `PM_Dispatch`, `BattleBox_Record`, `Popup_InitAndBuild`, `Popup_QueueWindows` |
| `shop_equip_compare` | (needs `party_menu_ps4`) the weapon and armor shops as PS IV's: while the item list has the cursor, a party window under the portrait (columns 1-12, ending on row 19; a full party's reaches up over the portrait's lower rows), "Can equip" on its top border, marks each member ▲ / ▶ / ▼ by what the highlighted item does to Attack (weapon shop) or Defense (armor shop), nothing if they cannot equip it; the marks are three tiles at VRAM `$23A-$23C` (free in buildings: field_heal_popups' range is the field's) written into the window's cells as the cursor moves. At Who? the Equip screen's comparison (Attack, Defense, Agility now ▶ then; no "then" for one who cannot equip it) opens under the Who? list in the Equip screen's place and follows its cursor. A one-handed item is compared in a hand holding the shop's kind of thing (an item with an attack value is a weapon) or nothing - the one holding the least of the stat -, else either; two-handed weapons take both hands (`EQ_Simulate`). New window IDs `$76`, `$77`. Checked by `work/scripts/shopequip.py` | `ext/shopequip.asm`, `BuildingScreenLoop`, `loc_BACE`/`loc_BC64`, `loc_BAE6`/`loc_BC7C`, `loc_BBD8`/`loc_BD6E`, `shop_no_reprompt`'s `loc_BBA8`/`loc_BD3E` |
| `improvement_fixes` | lory1990's bug fixes as FlamePurge's *Improvement* v4.5 applies them (hit rate, damage, SHINB, bosses, NPC facing, the Jet Scooter, ...) | `ext/improvement.asm`, [`improvement.md`](improvement.md) |
| `search_encounter_fix` | A step reaching tile centre while a search or field window is open keeps its encounter check pending; player and Jet Scooter movement preserve it, and the check runs once when the window closes, before another A-button search. This closes the search-and-walk encounter skip. Checked by `work/scripts/searchencounter.py`. | `ext/searchencounter.asm`, hooks in player and Jet Scooter movement, `ProcessAButtonPress`, `ProcessRandomBattle` |
| `fast_walking` | 2 px a frame, the followers and the scroll to match, the Gaira alarm halved (lory1990) | `ps2.asm`, `Fix_FollowerMain` |
| `fast_battles` | a hurt ally or enemy flashes once (veo) | `loc_3308` |
| `improvement_rebalance` | FlamePurge's equipment, shops, chests, techniques, default commands, Van Leader; Shilka does not steal on Dezolis | data in `ps2.asm`, `ext/improvement.asm` |
| `radar_names` | the Gaira radar reads MOTAVIA and PALMA (DEZOLIS as stock) | `art/radar_portrait_names.bin` |
| `double_rewards`, `no_red_flash` | the Improvement's optional addenda; 0 in the build, as the Improvement ships them | `ext/improvement.asm`, `ps2.asm` |

`vwf_windows` in short: the loops that copy names into window art write blanks and
register a *run* (art address, cells, text); party names reach the art as marker bytes;
the window's own labels are `WT_StaticRuns` (generated); letters the code copies into art
(WHO?, jobs, NEXT) are found by a scan. When a window has been drawn, its runs are drawn in
the proportional face into pool tiles (free VRAM per kind of screen, from the audits in
`work/scripts/mapaudit.py` and `battleaudit.py`) and its cells are pointed at them.
Numbers stay in the stock digit tiles, right-aligned where the game writes them.
On the outdoor field (`ScreenID_Level`), the window pool also reuses 93 font tiles:
`$527-$562` (Roman letters and punctuation, which the VWF redraws), `$589-$596`, and
`$5A1-$5B3`. The VWF uploads each glyph before pointing a window cell at that tile;
the source font tiles need no separate clearing pass. Buildings retain their original
pool because the name-entry grid draws Roman letter tiles directly. Battle retains
its original pool because its HUD uses some of the apparent JP leftovers. The tiles
windows draw as they are stay reserved: the HP/TP slash, the arrow and the icons
`$563-$580` (the slash at `$564` was overwritten by text in the party panel), name
markers `$581-$588`, digits `$597-$5A0`, and border/cursor art `$5B4-$5BF`.
In battle, the window pool starts again at $6E0 after the dialogue ring's four
24-tile lines ($680-$6DF); $374-$3FF provides the extra room after the damage
popups' $33C-$373. The target-selection window draws `To whom?` as one VWF run
on its bottom row: the stock four-plus-four prompt copy would split the phrase.

`damage_popups` calculates each hit during action setup, but holds the old HP until three
frames after the animation's `$FD` impact cue, including an enemy's instant-death attack.
The HP change and number window then appear as the top battle message is queued.
Technique names open at the `$F3` casting-effect
cue instead of impact. The framed number window lasts 45 frames, expanding from 8 to
32 pixels, holding, then contracting over its final six frames. Five enemy slots and
four party slots use RAM $FFFF8F00-$FFFF8F7F (including pending HP), with the shared
event state at $FFFF8E40-$FFFF8E45, and battle-only VRAM tiles $33C-$373.
Enemy windows stay five pixels below the upper enemy-name windows. Party windows
overlap the character art and stay five pixels above the lower status bar. They
draw in front of the characters. Healing Techniques, revival, and drain effects show the
actual HP restored in amber (battle palette 0, colour 3); damage remains white. A heal
at full HP has no number.
The stock total beside the enemy name remains active. Megid's HP cost also appears
over each party member. Values above 9999 display as 9999. The battle sprite and damage hooks
keep the stock code at its original addresses.

## 8. Budgets with the options on

`linecheck.py` and the proofreader apply these (the proofreader embeds the same numbers):

* **Final scene** (`vwf_ending`): the speeches 1829-182F 144 px a line, up to 7 lines (the
  portrait takes the rest of the screen); the closing line 1830 192 px, up to 5 lines (it
  is not centred by the game: pad with spaces, 3 px each).
* **Dialogue**: pixels, not cells - 192 px a line in the script and big windows, 160 in
  the battle box (192 and two lines with `battle_box`; the ids the game queues into an
  open victory box, 1213-1217, keep to one line), with each insert at its widest (the longest name of its table; six
  letters for a typed name; six digits for meseta). A page may expand to 384 bytes.
* **Party names**: six letters, and at most 32 px (the four cells of a name plate).
* **Items and enemies**: 80 px; **techniques**: 48 px with `wide_techs` (40 without: the stock
  cells in the windows).
* **Window labels**: a label is drawn in the cells up to the next word or the row's end;
  in the six windows the game writes numbers or names into (MST, the stats, LV/EXP, the
  equipment rows, the equip stats, battle HP/TP: `gentext.WINDOW_FIELDS`) it ends before
  that field with 2 px to spare. In those rows the number placeholders come from the stock
  row, so a translation gives only the label ("Strength", not "Strength   0"), and the
  numbers stay right-aligned in their fields.

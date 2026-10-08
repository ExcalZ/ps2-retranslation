; ---------------------------------------------------------------------------
; Build options for the Phantasy Star II retranslation.
; 0 = assemble the stock US behaviour, 1 = the modification. With every option
; at 0 the assembled ROM is byte-identical to the US release (Rev A).
; ---------------------------------------------------------------------------

; Assemble the game script (text/script.asm) after the stock data at the end of
; the ROM instead of in place; its stock region is filled to the same size, so no
; other code or data moves (the sound driver at $B8000 keeps its bank).
relocate_script = 1

; The script banks' offset tables hold a longword pointer per message instead of
; a byte step, so a message may be longer than 255 bytes (needs relocate_script,
; which keeps the tables word-aligned).
long_script_offsets = 1

; In weapon and armor shops, declining unusable gear, canceling Who?, or lacking
; funds returns to item selection. In the Item Shop, canceling a carrier returns
; to Buy, leaving Buy or Sell returns to Buy/Sell, and an unaffordable purchase
; returns to Buy/Sell. Needs relocated script with long offsets for the added
; item-shop replies.
shop_no_reprompt = 1

; Declining the Teleport Station's payment confirmation gives a new reply and
; returns to the destination list. Needs relocated script with long offsets.
teleport_decline_retry = 1

; LoadScript expands a message into text_buffer ($CD40, 704 bytes before the
; sound RAM) one page at a time: it stops at each {PAGE} and resumes from the
; script when the button is pressed. A message of any length fits, and the
; stock Lutz scene no longer overruns the sound RAM (the Esper mansion freeze).
paged_text_buffer = 1

; Proportional (variable-width) text in the script windows: the dialogue, the
; big window and the battle box (ext/vwf.asm). Needs paged_text_buffer (its RAM
; is the tail of text_buffer).
vwf_dialogue = 1

; The final scene's lines in the proportional face too: the speech beside the
; portraits (18 cells, 144 px, up to seven lines) and the closing line (24 cells,
; 192 px). Needs vwf_dialogue.
vwf_ending = 1

; Party names of up to six letters (ext/names.asm): letters 5-6 are kept beside
; the stock four and saved with them, the naming window takes six (four for a
; save file), the {NAME} inserts copy six, and the windows draw each name (with
; vwf_windows) proportionally in its four cells. Needs vwf_windows.
long_names = 1

; Proportional text in the windows: menus, lists, the battle and shop windows
; (ext/wintext.asm). The names drawn into a window's art become runs drawn in the
; proportional face into pool tiles once the window is up. Needs vwf_dialogue.
vwf_windows = 1

; The field camera keeps the player centred (EvilJagaGenius's hack): the four
; scroll thresholds in loc_3956 meet at the centre, so the map scrolls with
; every step instead of once the player nears an edge of a stock dead zone
; (Y $C8-$118, X $D8-$168). The same four immediates, nothing else changes.
centered_camera = 1

; Full-length item, technique and enemy names (ext/longnames.asm): drawn from
; tables of their own (ext/lnames.asm, from work/script.json) in the windows,
; within the pixels of the stock cells (items and enemies 80, techniques 40; 48
; with wide_techs), and copied whole by the {ITEM}, {TECH} and {ENEMY} inserts.
; The records keep the stock names. Needs vwf_windows.
long_item_names = 1

; Technique names in six cells (48 px) instead of five, so the full names fit
; (Saschnella, Nasaresta): the field TECH list, the battle list and the plate a
; technique shows while it is cast one cell wider, STRNG's two lists two
; (ext/techwin.asm). Needs long_item_names.
wide_techs = 1

; The battle technique list shows each technique's TP cost right of its name, as
; Phantasy Star IV does (three cells wider). Needs wide_techs.
battle_tech_tp = 1

; The battle message box as wide as the dialogue window (24 cells, 192 px), and
; two lines tall, scrolling as the dialogue does, when its message has a line
; break ({BR}); a one-line message keeps the one-line box (ext/battlebox.asm).
; Needs vwf_dialogue and long_script_offsets.
battle_box = 1

; Two battle messages the stock game lacks: "Defensive barrier up!" for DEBAND
; (and the Snow Crown), and "TP drained!" when an enemy empties a party member's
; TP (Sea Scissors, Droll Monkey). Needs relocate_script.
status_messages = 1

; Show a short-lived damage number over each enemy or party member hit in battle.
; Each target has its own sprite, including targets of area attacks. The stock
; enemy-name damage total remains visible.
damage_popups = 1

; Damage window numeral style: 0 = the exact HP/TP digit shapes from the stock
; battle font, 1 = thicker strokes and one-pixel gaps, like PS IV's damage
; numerals. Only used when damage_popups is 1; either value builds the stock
; ROM when damage_popups is 0.
damage_popup_font = 0

; Field recovery uses the same short-lived numeral treatment: the actual HP
; restored appears in amber immediately left of that member's HP in the
; summary. Needs damage_popups for the shared numeral/frame routines.
field_heal_popups = 1

; battle_name_panes: the battle's top row without the stock damage panes (the
; pop-ups show every number): the enemy names centred in their panes, the
; second pane at the right corner, and only when there is a second enemy group.
; Needs damage_popups, battle_box (the record hook) and vwf_windows (the centring).
battle_name_panes = 1

; Four-entry field menu, visible roster and Status > Status/Order > character > Techniques.
party_menu_ps4 = 1

; The title offers only New Game with no saved files. Otherwise Continue is
; first and initially selected, followed by New Game and Erase Game.
title_save_menu = 1

; Start on the field opens Options, as Phantasy Star IV's: Battle Speed and
; Message Speed, each 1 (fast) to 5 (slow), and Damage Flash On/Off, saved
; with the game. Battle 2 (the default) is the stock pace, 5 twice its pauses
; and pop-ups, 1 shorter ones; Message 3 is the stock letter a frame, 1 twice
; as fast, 5 half. Damage Flash defaults to On for older saves. Needs
; party_menu_ps4, battle_box, vwf_windows.
field_options = 1

; The battle's commands as Phantasy Star IV's (ext/macros.asm): one window at
; the top left - Auto-Combat (the stock Fight), Command (Orders), Macro,
; Retreat - in place of Fight/Tactics and Orders/Retreat, the party's four
; windows side by side, centred in the bottom row. Macro picks one of eight command sets
; (A-H), set from a fifth field-menu entry and saved with the game (in the
; last 64 bytes of the save's copyright copy: a save is checked against the
; first 32). Needs party_menu_ps4, field_options, battle_box, vwf_windows,
; long_item_names and relocate_script.
battle_macros = 1

; The weapon and armor shops show who can equip the highlighted item, as
; Phantasy Star IV's: a party window under the portrait marks each member up,
; right (no change) or down by the item's effect on Attack (weapons) or
; Defense (armor), nothing if they cannot equip it; at Who? the Equip screen's
; comparison follows the cursor (ext/shopequip.asm). Needs party_menu_ps4.
shop_equip_compare = 1

; ---------------------------------------------------------------------------
; FlamePurge's "Phantasy Star II Improvement" v4.5 (2024-10-21), everything but
; its script and name changes, reproduced from its IPS against Rev A.
; docs/improvement.md lists every change and where it is.
; ---------------------------------------------------------------------------

; lory1990's bug fixes as the Improvement applies them (ext/improvement.asm):
; hit rate and physical damage formulas, SHINB, TOADER, the double-attack
; toggle after paralysis, no running from bosses, NPC facing, the lineup
; animation, the title and prologue, the step counter on map loads, the Jet
; Scooter, the Central Tower storage, the Kueri inventor, the Paseo old man,
; Rolf alone in Rearrange, the SAR/SAK/NASAK/ANTI field sounds, B+C over NEXT,
; the first battle cursor, Menobe's collision, the Mechoman frame, the post-game
; prologue, and "DIRECTOR" in the credits.
improvement_fixes = 1

; Preserve an encounter check reached while a search or field window is open.
; Resolve it when control returns, even if movement has left that tile centre.
search_encounter_fix = 1

; Fast walking (lory1990): the party steps 2 pixels a frame (8 frames a tile),
; the followers keep pace, and the Gaira alarm timer is halved to match.
fast_walking = 1

; Fast battles (veo): a damaged ally or enemy flashes once, not three times.
fast_battles = 1

; FlamePurge's rebalance: Wave Shot, Silver Claw and Cyber Vest replace the Bow
; Gun, Whip and Heilsam Boots; equipment rights, shops, chests, Nei's and Rudger's
; starting gear, the Fire Staff (GIFOI), FANBI, the technique lists and levels,
; Attack as every default command, Van Leader in the dams, and Shilka does not
; steal on Dezolis. The item names are work/script.json's.
improvement_rebalance = 1

; The Gaira radar reads MOTAVIA and PALMA (the Improvement's art; lory1990),
; keeping the stock DEZOLIS.
radar_names = 1

; The Improvement's optional addenda (off in the Improvement too):
; double EXP and meseta from every enemy,
double_rewards = 0
; and no red screen flash when the party takes damage (veo). With field_options
; enabled, the saved Damage Flash setting controls this instead.
no_red_flash = 0

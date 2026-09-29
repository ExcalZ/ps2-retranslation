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

; LoadScript expands a message into text_buffer ($CD40, 704 bytes before the
; sound RAM) one page at a time: it stops at each {PAGE} and resumes from the
; script when the button is pressed. A message of any length fits, and the
; stock Lutz scene no longer overruns the sound RAM (the Esper mansion freeze).
paged_text_buffer = 1

; Proportional (variable-width) text in the script windows: the dialogue, the
; big window and the battle box (ext/vwf.asm). Needs paged_text_buffer (its RAM
; is the tail of text_buffer).
vwf_dialogue = 1

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
; within the pixels of the stock cells (items and enemies 80, techniques 40),
; and copied whole by the {ITEM}, {TECH} and {ENEMY} inserts. The records keep
; the stock names. Needs vwf_windows.
long_item_names = 1

; Show a short-lived damage number over each enemy or party member hit in battle.
; Each target has its own sprite, including targets of area attacks. The stock
; enemy-name damage total remains visible.
damage_popups = 1

; Damage window numeral style: 0 = the exact HP/TP digit shapes from the stock
; battle font, 1 = thicker strokes and one-pixel gaps, like PS IV's damage
; numerals. Only used when damage_popups is 1; either value builds the stock
; ROM when damage_popups is 0.
damage_popup_font = 0

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
; save file), the {NAME} inserts copy six, and the windows draw each name as a
; proportional plate in four cells. Needs vwf_dialogue (the face).
long_names = 1

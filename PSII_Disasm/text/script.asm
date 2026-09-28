; =============================================================================
; The game script: GameScriptPtrs points at the 26 banks below.
; tools/gentext.py writes work/dialogue.json into this file.
; Included in place (the stock layout) or, with relocate_script, after the stock
; data at the end of the ROM (ps2.asm), so that nothing else in the ROM moves.
; =============================================================================

	charset	'A', "\11\12\13\14\15\16\17\18\19\20\21\22\23\24\25\26\27\28\29\30\31\32\33\34\35\36"
	charset	'a', "\37\38\39\40\41\42\43\44\45\46\47\48\49\50\51\52\53\54\55\56\57\58\59\60\61\62"
	charset	'0', "\1\2\3\4\5\6\7\8\9\10"
	charset	' ', 0
	charset	',', $3F
	charset	'.', $40
	charset	';', $41
	charset	'"', $42
	charset	'?', $43
	charset	'!', $44
	charset	39, $45	; apostrophe
	charset	'-', $46
	charset	':', $77

; A bank starts with one entry per script id: the byte step from one message to
; the next (stock), or with long_script_offsets a longword pointer to it.
scriptofs macro target, previous
	if long_script_offsets
	dc.l	target
	else
	dc.b	target-previous
	endif
	endm

	if long_script_offsets
	even
	endif
Script_ItemAction:
	scriptofs	loc_18C72, Script_ItemAction	; 1
	scriptofs	loc_18C7F, loc_18C72			; 2
	scriptofs	loc_18C96, loc_18C7F			; 3
	scriptofs	loc_18CB0, loc_18C96			; 4
	scriptofs	loc_18CC1, loc_18CB0			; 5
	scriptofs	loc_18CD3, loc_18CC1			; 6
	scriptofs	loc_18CDE, loc_18CD3			; 7
	scriptofs	loc_18D0A, loc_18CDE			; 8
	scriptofs	loc_18D1A, loc_18D0A			; 9
	scriptofs	loc_18D3F, loc_18D1A			; $A
	scriptofs	loc_18D51, loc_18D3F			; $B
	scriptofs	loc_18D77, loc_18D51			; $C
	scriptofs	loc_18D95, loc_18D77			; $D
	scriptofs	loc_18DBC, loc_18D95			; $E
	scriptofs	loc_18DC7, loc_18DBC			; $F
	scriptofs	loc_18DE3, loc_18DC7			; $10
	scriptofs	loc_18E02, loc_18DE3			; $11
	scriptofs	loc_18E31, loc_18E02			; $12
	scriptofs	loc_18E4C, loc_18E31			; $13
	scriptofs	loc_18E74, loc_18E4C			; $14
	scriptofs	loc_18E9A, loc_18E74			; $15
	scriptofs	loc_18EBD, loc_18E9A			; $16
	scriptofs	loc_18EEA, loc_18EBD			; $17
	scriptofs	loc_18EFF, loc_18EEA			; $18
	scriptofs	loc_18F10, loc_18EFF			; $19
	scriptofs	loc_18F6B, loc_18F10			; $1A
	scriptofs	loc_18F9B, loc_18F6B			; $1B
	scriptofs	loc_18FCB, loc_18F9B			; $1C
	scriptofs	loc_18FFA, loc_18FCB			; $1D
	scriptofs	loc_1902A, loc_18FFA			; $1E
	scriptofs	loc_19056, loc_1902A			; $1F
	scriptofs	loc_19085, loc_19056			; $20
	scriptofs	loc_19138, loc_19085			; $21
	scriptofs	loc_1916E, loc_19138			; $22
	scriptofs	loc_191BA, loc_1916E			; $23
	scriptofs	loc_191D5, loc_191BA			; $24
	scriptofs	loc_191F5, loc_191D5			; $25
	scriptofs	loc_1921C, loc_191F5			; $26
	scriptofs	loc_1921C, loc_1921C			; $27
	scriptofs	loc_19235, loc_1921C			; $28
	
loc_18C72:
	dc.b	$BB
	dc.b	" used the "
	dc.b	$BF
	dc.b	"."
	dc.b	$C4
	
loc_18C7F:
	dc.b	$BC
	dc.b	"'s wounds healed."
	dc.b	$C4

loc_18C96:
	dc.b	"The poison left "
	dc.b	$BC
	dc.b	"'s body."
	dc.b	$C4

loc_18CB0:
	dc.b	"But nothing happened."
	dc.b	$C4

loc_18CC1:
	dc.b	$BC
	dc.b	" came back to life."
	dc.b	$C4

loc_18CD3:
	dc.b	$BB
	dc.b	" is dead", $47, $47, $47
	dc.b	$C4

loc_18CDE:
	dc.b	"A prism with a strange, truly strange"
	dc.b	$C1
	dc.b	"radiance", $47, $47, $47
	dc.b	$C4

loc_18D0A:
	dc.b	$BB
	dc.b	" handed the "
	dc.b	$BF
	dc.b	$C1
	dc.b	"to "
	dc.b	$BC
	dc.b	"."
	dc.b	$C4

loc_18D1A:
	dc.b	$BC
	dc.b	" took the "
	dc.b	$BF
	dc.b	$C1
	dc.b	"out of "
	dc.b	$BB
	dc.b	"'s bag."
	dc.b	$C4
	
loc_18D3F:
	dc.b	$BC
	dc.b	" can't carry anything more."
	dc.b	$C4

loc_18D51:
	dc.b	"The "
	dc.b	$BF
	dc.b	" is far too good"
	dc.b	$C1
	dc.b	"to throw away!"
	dc.b	$C4

loc_18D77:
	dc.b	"Throw away the "
	dc.b	$BF
	dc.b	"?"
	dc.b	$C5

loc_18D95:
	dc.b	$BB
	dc.b	" thought better of it."
	dc.b	$C4

loc_18DBC:
	dc.b	$BB
	dc.b	" threw the "
	dc.b	$BF
	dc.b	$C1
	dc.b	"away."
	dc.b	$C4

loc_18DC7:
	dc.b	"It won't come off, however hard you try."
	dc.b	$C1
	dc.b	"What a humiliation, to be stuck in this!"
	dc.b	$C4

loc_18DE3:
	dc.b	"A fragrant scent filled the air."
	dc.b	$C4

loc_18E02:
	dc.b	"A leaf from a Maruera tree."
	dc.b	$C1
	dc.b	"It feels soft and springy to the touch."
	dc.b	$C4

loc_18E31:
	dc.b	"Suddenly everyone felt lighter."
	dc.b	$C5
	
loc_18E4C:
	dc.b	"Its notes muffled the footsteps"
	dc.b	$C1
	dc.b	"of "
	dc.b	$BB
	dc.b	" and the others."
	dc.b	$C5

loc_18E74:
	dc.b	$BB
	dc.b	" took out the "
	dc.b	$BF
	dc.b	","
	dc.b	$C1
	dc.b	"but it looked dangerous, so put it away."
	dc.b	$C4

loc_18E9A:
	dc.b	"A key for small keyholes, the kind"
	dc.b	$C1
	dc.b	"found on containers."
	dc.b	$C4

loc_18EBD:
	dc.b	"A round metal rod, about 20 cm long,"
	dc.b	$C1
	dc.b	"with markings here and there."
	dc.b	$C4

loc_18EEA:
	dc.b	"The container opened."
	dc.b	$C4

loc_18EFF:
	dc.b	$BB
	dc.b	" inserted the "
	dc.b	$BF
	dc.b	"."
	dc.b	$C4

loc_18F10:
	dc.b	$BB
	dc.b	" and the others ate the"
	dc.b	$C1
	dc.b	$BF
	dc.b	". Air filled their mouths"
	dc.b	$C3
	dc.b	"with every chew. With this, they could"
	dc.b	$C1
	dc.b	"dive to the bottom of the deep sea."
	dc.b	$C4

loc_18F6B:
	dc.b	"To try out the "
	dc.b	$BF
	dc.b	", that place"
	dc.b	$C1
	dc.b	"would be best, of course."
	dc.b	$C4

loc_18F9B:
	dc.b	"The dam's lock came free, and the roar"
	dc.b	$C1
	dc.b	"of rushing water rose up."
	dc.b	$C4

loc_18FCB:
	dc.b	"A beautiful card that shines"
	dc.b	$C1
	dc.b	"like a green emerald."
	dc.b	$C4

loc_18FFA:
	dc.b	"A clear card, the pale blue"
	dc.b	$C1
	dc.b	"of an aquamarine."
	dc.b	$C4

loc_1902A:
	dc.b	"An amber card, the color of the"
	dc.b	$C1
	dc.b	"Motavian earth of long ago."
	dc.b	$C4

loc_19056:
	dc.b	"A card as red as the sun setting"
	dc.b	$C1
	dc.b	"over the Motavian land."
	dc.b	$C4

loc_19085:
	dc.b	$42, "Darum. Your daughter, little Tiem,"
	dc.b	$C1
	dc.b	"is a real good girl."
	dc.b	$C3
	dc.b	"We're keeping her safe in the Tower"
	dc.b	$C1
	dc.b	"of Nido. If you don't want her"
	dc.b	$C3
	dc.b	"killed, bring 50,000 meseta"
	dc.b	$C1
	dc.b	"within a month! Understand?", $42
	dc.b	$C3
	dc.b	"So it read. For his daughter's sake,"
	dc.b	$C1
	dc.b	"Darum had been killing and stealing", $47, $47, $47
	dc.b	$C4

loc_19138:
	dc.b	"A device that records the events"
	dc.b	$C1
	dc.b	"in the Biosystem."
	dc.b	$C4

loc_1916E:
	dc.b	"If this reaches Paseo, we'll learn"
	dc.b	$C1
	dc.b	"what caused the biohazard."
	dc.b	$C4
	
loc_191BA:
	dc.b	$BB
	dc.b	" isn't carrying anything."
	dc.b	$C4

loc_191D5:
	dc.b	$BB
	dc.b	" checked that the "
	dc.b	$BF
	dc.b	$C1
	dc.b	"was there, and put it back."
	dc.b	$C4

loc_191F5:
	dc.b	$42, "How can I make Father"
	dc.b	$C1
	dc.b	"turn over a new leaf", $47, $47, $47, $42
	dc.b	$C4

loc_1921C:
	dc.b	"You can't use that here!"
	dc.b	$C4

loc_19235:
	dc.b	"Contacting the Data Memory!"
	dc.b	$C4
; ---------------------------------------------------------------------------------

	even
	
	if long_script_offsets
	even
	endif
Script_TechAction:
	scriptofs	loc_19268, Script_TechAction	; 1
	scriptofs	loc_19280, loc_19268			; 2
	scriptofs	loc_1928B, loc_19280			; 3
	scriptofs	loc_1929A, loc_1928B			; 4
	scriptofs	loc_192C7, loc_1929A			; 5
	scriptofs	loc_192EF, loc_192C7			; 6
	scriptofs	loc_19319, loc_192EF			; 7
	scriptofs	loc_19341, loc_19319			; 8
	scriptofs	loc_19363, loc_19341			; 9
	scriptofs	loc_1937A, loc_19363			; $A
	scriptofs	loc_1939C, loc_1937A			; $B
	scriptofs	loc_193B2, loc_1939C			; $C

loc_19268:
	dc.b	$BB
	dc.b	" can't use techniques."
	dc.b	$C4

loc_19280:
	dc.b	$BC
	dc.b	" is dead", $47, $47, $47
	dc.b	$C4

loc_1928B:
	dc.b	"Not enough TP!"
	dc.b	$C4

loc_1929A:
	dc.b	$BB
	dc.b	" held a hand over "
	dc.b	$BC
	dc.b	"'s"
	dc.b	$C1
	dc.b	"wounds. "
	dc.b	$BC
	dc.b	"'s wounds healed."
	dc.b	$C4

loc_192C7:
	dc.b	$BB
	dc.b	" held a hand over "
	dc.b	$BC
	dc.b	"."
	dc.b	$C1
	dc.b	"The poison left "
	dc.b	$BC
	dc.b	"'s body."
	dc.b	$C4

loc_192EF:
	dc.b	$BB
	dc.b	" shared a part of"
	dc.b	$C1
	dc.b	"life with everyone", $47, $47, $47
	dc.b	$C4

loc_19319:
	dc.b	$BB
	dc.b	" held "
	dc.b	$BC
	dc.b	" close, and"
	dc.b	$C1
	dc.b	"shared a part of life with "
	dc.b	$BC
	dc.b	$47, $47, $47
	dc.b	$C4
	
loc_19341:
	dc.b	$BB
	dc.b	" spread both arms wide."
	dc.b	$C1
	dc.b	"Everyone's wounds healed."
	dc.b	$C4

loc_19363:
	dc.b	$BB
	dc.b	" used "
	dc.b	$BE
	dc.b	"!"
	dc.b	$C4

loc_1937A:
	dc.b	$BB
	dc.b	" touched "
	dc.b	$BC
	dc.b	"'s cheek."
	dc.b	$C1
	dc.b	$BC
	dc.b	" came back to life!"
	dc.b	$C4
	
loc_1939C:
	dc.b	$BB
	dc.b	" held a hand over "
	dc.b	$BC
	dc.b	"'s"
	dc.b	$C1
	dc.b	"wounds."
	dc.b	$C4
	
loc_193B2:
	dc.b	"But a body poisoned like this"
	dc.b	$C1
	dc.b	"won't heal."
	dc.b	$C4
; ---------------------------------------------------------------------------------

	even
		
	if long_script_offsets
	even
	endif
Script_EquipAction:
	scriptofs	loc_193F1, Script_EquipAction	; 1
	scriptofs	loc_19401, loc_193F1				; 2
	scriptofs	loc_1940C, loc_19401				; 3
	scriptofs	loc_19426, loc_1940C				; 4
	scriptofs	loc_19433, loc_19426				; 5
	
loc_193F1:
	dc.b	$BB
	dc.b	" can't equip the"
	dc.b	$C1
	dc.b	$BF
	dc.b	"."
	dc.b	$C4

loc_19401:
	dc.b	$BB
	dc.b	" equipped the"
	dc.b	$C1
	dc.b	$BF
	dc.b	"."
	dc.b	$C4
	
loc_1940C:
	dc.b	$BB
	dc.b	" refused to wear the"
	dc.b	$C1
	dc.b	$BF
	dc.b	"."
	dc.b	$C4

loc_19426:
	dc.b	$BB
	dc.b	" took off the "
	dc.b	$BF
	dc.b	"."
	dc.b	$C4

loc_19433:
	dc.b	"The "
	dc.b	$BF
	dc.b	" can't be equipped."
	dc.b	$C4
; ---------------------------------------------------------------------------------

	even
	
	if long_script_offsets
	even
	endif
Script_DataMemory:
	scriptofs	loc_19453, Script_DataMemory	; 1
	scriptofs	loc_1946B, loc_19453			; 2
	scriptofs	loc_1948E, loc_1946B			; 3
	scriptofs	loc_194CD, loc_1948E			; 4
	scriptofs	loc_194EF, loc_194CD			; 5
	scriptofs	loc_19516, loc_194EF			; 6
	scriptofs	loc_1955A, loc_19516			; 7
	scriptofs	loc_19575, loc_1955A			; 8
	scriptofs	loc_19599, loc_19575			; 9
	scriptofs	loc_195D8, loc_19599			; $A
	scriptofs	loc_195EC, loc_195D8			; $B
	scriptofs	loc_195FE, loc_195EC			; $C
	scriptofs	loc_19614, loc_195FE			; $D
	
loc_19453:
	dc.b	"Welcome to the Data Memory."
	dc.b	$C4

loc_1946B:
	dc.b	$BB
	dc.b	" needs "
	dc.b	$C0
	dc.b	" more points"
	dc.b	$C1
	dc.b	"of experience to reach the next level."
	dc.b	$C4

loc_1948E:
	dc.b	"Shall I store your memories and"
	dc.b	$C1
	dc.b	"experiences in the memory?"
	dc.b	$C5

loc_194CD:
	dc.b	"I see", $47, $47, $47, "  Then please take care."
	dc.b	$C4

loc_194EF:
	dc.b	"Under which number shall I save them?"
	dc.b	$C5

loc_19516:
	dc.b	"Something is already saved there."
	dc.b	$C1
	dc.b	"Is it all right to erase the old data?"
	dc.b	$C5

loc_1955A:
	dc.b	"Then please give the file a name."
	dc.b	$C5

loc_19575:
	dc.b	"The saving is complete."
	dc.b	$C4

loc_19599:
	dc.b	"Are you setting out again"
	dc.b	$C1
	dc.b	"on your journey of battle?"
	dc.b	$C5

loc_195D8:
	dc.b	"I see. Then let us meet again"
	dc.b	$C1
	dc.b	"some day. Goodbye."
	dc.b	$C4

loc_195EC:
	dc.b	"We meet again, ", $BB, "."
	dc.b	$C4

loc_195FE:
	dc.b	"Take care out there."
	dc.b	$C4
	
loc_19614:
	dc.b	$BB
	dc.b	" can't go up any"
	dc.b	$C1
	dc.b	"more levels."
	dc.b	$C4
; ---------------------------------------------------------------------------------

	even
	
	if long_script_offsets
	even
	endif
Script_CloneLabs:
	scriptofs	loc_19655, Script_CloneLabs	; 1
	scriptofs	loc_1969C, loc_19655			; 2
	scriptofs	loc_196BF, loc_1969C			; 3
	scriptofs	loc_196E5, loc_196BF			; 4
	scriptofs	loc_196FD, loc_196E5			; 5
	scriptofs	loc_1972B, loc_196FD			; 6
	scriptofs	loc_19742, loc_1972B			; 7
	scriptofs	loc_19767, loc_19742			; 8
	scriptofs	loc_19825, loc_19767			; 9
	scriptofs	loc_198AD, loc_19825			; $A
	scriptofs	loc_198EC, loc_198AD			; $B
	
loc_19655:
	dc.b	"Welcome to the Clone Lab."
	dc.b	$C1
	dc.b	"Whom do you wish restored?"
	dc.b	$C5

loc_1969C:
	dc.b	"Now, now, this is no time for jokes!"
	dc.b	$C4

loc_196BF:
	dc.b	"It will cost "
	dc.b	$C0
	dc.b	" meseta."
	dc.b	$C1
	dc.b	"Is that agreeable?"
	dc.b	$C5

loc_196E5:
	dc.b	"Then take care, young one!"
	dc.b	$C4

loc_196FD:
	dc.b	"Is there anyone else I should restore?"
	dc.b	$C5

loc_1972B:
	dc.b	$BB
	dc.b	" lives again!"
	dc.b	$C5

loc_19742:
	dc.b	"Whom shall I restore, then?"
	dc.b	$C5

loc_19767:
	dc.b	"Welcome to the Clone Lab."
	dc.b	$C1
	dc.b	"Whom do you wish restored?"
	dc.b	$C3
	dc.b	"This girl, Nei? You want her restored?"
	dc.b	$C1
	dc.b	"Hmm, what could have left her cells"
	dc.b	$C3
	dc.b	"in such a ruin? I'm sorry, but all"
	dc.b	$C1
	dc.b	"that isn't human in her is broken"
	dc.b	$C3
	dc.b	"beyond repair", $47, $47, $47, " Bringing this child"
	dc.b	$C1
	dc.b	"back to life is utterly"
	dc.b	$C3
	dc.b	"impossible", $47, $47, $47
	dc.b	$C1

loc_19825:
	dc.b	"Now it would be best to let her sleep"
	dc.b	$C3
	dc.b	"in peace in the soil of mother Paseo", $47, $47, $47
	dc.b	$C1
	dc.b	"Death comes to everyone in time."
	dc.b	$C3
	dc.b	"But didn't she live her short life"
	dc.b	$C1
	dc.b	"with all she had? Then surely that"
	dc.b	$C3
	dc.b	"is enough. Don't lose heart, now."
	dc.b	$C4

loc_198AD:
	dc.b	"Have you never heard it said that"
	dc.b	$C1
	dc.b	"money talks, even in hell?"
	dc.b	$C4
	
loc_198EC:
	dc.b	"Oh, but there's a young one there who"
	dc.b	$C1
	dc.b	"has run out of strength too. That one"
	dc.b	$C3
	dc.b	"I can bring back to life."
	dc.b	$C4
; ---------------------------------------------------------------------------------

	even
	
	if long_script_offsets
	even
	endif
Script_Hospital:
	scriptofs	loc_19950, Script_Hospital	; 1
	scriptofs	loc_19960, loc_19950			; 2
	scriptofs	loc_19982, loc_19960			; 3
	scriptofs	loc_199A9, loc_19982			; 4
	scriptofs	loc_199CC, loc_199A9			; 5
	scriptofs	loc_199F7, loc_199CC			; 6
	scriptofs	loc_19A0C, loc_199F7			; 7
	scriptofs	loc_19A28, loc_19A0C			; 8
	scriptofs	loc_19A3E, loc_19A28			; 9
	scriptofs	loc_19A65, loc_19A3E			; $A

loc_19950:
	dc.b	"How may I help you?"
	dc.b	$C5

loc_19960:
	dc.b	$BB
	dc.b	" doesn't seem"
	dc.b	$C1
	dc.b	"to be poisoned", $47, $47, $47
	dc.b	$C4

loc_19982:
	dc.b	"The treatment will cost "
	dc.b	$C0
	dc.b	$C1
	dc.b	"meseta. Is that all right?"
	dc.b	$C5

loc_199A9:
	dc.b	"If you can't pay for the treatment,"
	dc.b	$C1
	dc.b	"I'm afraid", $47, $47, $47
	dc.b	$C4

loc_199CC:
	dc.b	"I see. Take care of yourself", $47, $47, $47
	dc.b	$C4

loc_199F7:
	dc.b	"Take care of yourself. Be careful."
	dc.b	$C4

loc_19A0C:
	dc.b	"Who needs treatment?"
	dc.b	$C5
	
loc_19A28:
	dc.b	"I'm afraid "
	dc.b	$BB
	dc.b	" has passed away", $47, $47, $47
	dc.b	$C4

loc_19A3E:
	dc.b	"No one seems to be hurt, though."
	dc.b	$C4

loc_19A65:
	dc.b	"Shall I treat anyone else?"
	dc.b	$C5
; ---------------------------------------------------------------------------------

	even
	
	if long_script_offsets
	even
	endif
Script_WeaponStore:
	scriptofs	loc_19A91, Script_WeaponStore	; 1
	scriptofs	loc_19AAF, loc_19A91				; 2
	scriptofs	loc_19ADB, loc_19AAF				; 3
	scriptofs	loc_19B0B, loc_19ADB				; 4
	scriptofs	loc_19B30, loc_19B0B				; 5
	scriptofs	loc_19B60, loc_19B30				; 6
	scriptofs	loc_19B81, loc_19B60				; 7
	scriptofs	loc_19BB2, loc_19B81				; 8
	scriptofs	loc_19BBE, loc_19BB2				; 9

loc_19A91:
	dc.b	"Hey, welcome. What'll it be?"
	dc.b	$C5

loc_19AAF:
	dc.b	"The "
	dc.b	$BF
	dc.b	", huh?"
	dc.b	$C1
	dc.b	"Who's carrying it?"
	dc.b	$C5

loc_19ADB:
	dc.b	"You, using this? That's a laugh!"
	dc.b	$C1
	dc.b	"You still want it?"
	dc.b	$C5

loc_19B0B:
	dc.b	"So who's carrying it?"
	dc.b	$C5

loc_19B30:
	dc.b	"You're short on money!"
	dc.b	$C4

loc_19B60:
	dc.b	"Use it well! And don't break it!"
	dc.b	$C4

loc_19B81:
	dc.b	"Use it well! Here, take it!"
	dc.b	$C1
	dc.b	"Anything else you want?"
	dc.b	$C5

loc_19BB2:
	dc.b	"See ya!"
	dc.b	$C4

loc_19BBE:
	dc.b	"Greedy, aren't you? You can't carry"
	dc.b	$C3
	dc.b	"any more. Toss something or sell it"
	dc.b	$C1
	dc.b	"off, then come back!"
	dc.b	$C4
; ---------------------------------------------------------------------------------

	even
	
	if long_script_offsets
	even
	endif
Script_ArmorStore:
	scriptofs	loc_19BF7, Script_ArmorStore	; 1
	scriptofs	loc_19C22, loc_19BF7			; 2
	scriptofs	loc_19C4D, loc_19C22			; 3
	scriptofs	loc_19C7B, loc_19C4D			; 4
	scriptofs	loc_19CA1, loc_19C7B			; 5
	scriptofs	loc_19CD0, loc_19CA1			; 6
	scriptofs	loc_19CF5, loc_19CD0			; 7
	scriptofs	loc_19D19, loc_19CF5			; 8
	scriptofs	loc_19D35, loc_19D19			; 9
	
loc_19BF7:
	dc.b	"Hey there! Need something from"
	dc.b	$C1
	dc.b	"my shop?"
	dc.b	$C5

loc_19C22:
	dc.b	"The "
	dc.b	$BF
	dc.b	", huh?"
	dc.b	$C1
	dc.b	"Who's carrying it?"
	dc.b	$C5

loc_19C4D:
	dc.b	"You can't use this one!"
	dc.b	$C1
	dc.b	"Still want it?"
	dc.b	$C5

loc_19C7B:
	dc.b	"So who's carrying it?"
	dc.b	$C5

loc_19CA1:
	dc.b	"Whoa, whoa. No loans, no credit."
	dc.b	$C4

loc_19CD0:
	dc.b	"Here you go! Hope it serves you well!"
	dc.b	$C1
	dc.b	"Use it right!"
	dc.b	$C4

loc_19CF5:
	dc.b	"Here, take it!"
	dc.b	$C1
	dc.b	"Anything else you want?"
	dc.b	$C5

loc_19D19:
	dc.b	"Take care, now!"
	dc.b	$C4

loc_19D35:
	dc.b	"You can't carry any more!"
	dc.b	$C1
	dc.b	"Clear out your bags and come back!"
	dc.b	$C4
; ---------------------------------------------------------------------------------

	even
	
	if long_script_offsets
	even
	endif
Script_ItemStore:
	scriptofs	loc_19D76, Script_ItemStore	; 1
	scriptofs	loc_19D98, loc_19D76			; 2
	scriptofs	loc_19DC1, loc_19D98			; 3
	scriptofs	loc_19DE3, loc_19DC1			; 4
	scriptofs	loc_19DFE, loc_19DE3			; 5
	scriptofs	loc_19E50, loc_19DFE			; 6
	scriptofs	loc_19E66, loc_19E50			; 7
	scriptofs	loc_19E83, loc_19E66			; 8
	scriptofs	loc_19EA4, loc_19E83			; 9
	scriptofs	loc_19ED9, loc_19EA4			; $A
	scriptofs	loc_19F01, loc_19ED9			; $B
	scriptofs	loc_19F3B, loc_19F01			; $C
	scriptofs	loc_19F5E, loc_19F3B			; $D
	scriptofs	loc_19F78, loc_19F5E			; $E
	scriptofs	loc_19F92, loc_19F78			; $F
	scriptofs	loc_19FDF, loc_19F92			; $10

loc_19D76:
	dc.b	"Welcome. How may I help you?"
	dc.b	$C5

loc_19D98:
	dc.b	"Whose belongings would you"
	dc.b	$C1
	dc.b	"like to sell?"
	dc.b	$C5

loc_19DC1:
	dc.b	"I can take it for "
	dc.b	$C0
	dc.b	" meseta."
	dc.b	$C1
	dc.b	"Is that all right?"
	dc.b	$C5
	
loc_19DE3:
	dc.b	"Which would you like to sell?"
	dc.b	$C5
	
loc_19DFE:
	dc.b	"I've never seen goods like these,"
	dc.b	$C1
	dc.b	"so I can't put a price on them."
	dc.b	$C3
	dc.b	"Please choose something else."
	dc.b	$C5
	
loc_19E50:
	dc.b	"Which would you like?"
	dc.b	$C5

loc_19E66:
	dc.b	"You don't have enough money."
	dc.b	$C4

loc_19E83:
	dc.b	"Who will carry it?"
	dc.b	$C5

loc_19EA4:
	dc.b	"You can't seem to carry any more."
	dc.b	$C1
	dc.b	"Who else will carry it?"
	dc.b	$C5

loc_19ED9:
	dc.b	"Thank you very much."
	dc.b	$C1
	dc.b	"Is there anything else you need?"
	dc.b	$C5

loc_19F01:
	dc.b	"I see. That's a shame."
	dc.b	$C1
	dc.b	"Can I help you with anything else?"
	dc.b	$C5

loc_19F3B:
	dc.b	"Thank you very much."
	dc.b	$C1
	dc.b	"Is there anything else?"
	dc.b	$C5

loc_19F5E:
	dc.b	"Goodbye. Please come again."
	dc.b	$C4
	
loc_19F78:
	dc.b	"Wh-what? You can't spring that on"
	dc.b	$C1
	dc.b	"me all of a sudden! I need time to", $47, $47, $47
	dc.b	$C4
	
loc_19F92:
	dc.b	$BB
	dc.b	" doesn't seem to be carrying"
	dc.b	$C1
	dc.b	"anything. Whose belongings will"
	dc.b	$C3
	dc.b	"you sell?"
	dc.b	$C5

loc_19FDF:
	dc.b	"Danyaraha? Bebekucharaba!"
	dc.b	$C4
; ---------------------------------------------------------------------------------

	even
	
	if long_script_offsets
	even
	endif
Script_RolfHouse:
	scriptofs	loc_1A025, Script_RolfHouse	; 1
	scriptofs	loc_1A066, loc_1A025			; 2
	scriptofs	loc_1A08A, loc_1A066			; 3
	scriptofs	loc_1A182, loc_1A08A			; 4
	scriptofs	loc_1A236, loc_1A182			; 5
	scriptofs	loc_1A270, loc_1A236			; 6
	scriptofs	loc_1A2A8, loc_1A270			; 7
	scriptofs	loc_1A31D, loc_1A2A8			; 8
	scriptofs	loc_1A38B, loc_1A31D			; 9 
	scriptofs	loc_1A3C2, loc_1A38B			; $A
	scriptofs	loc_1A401, loc_1A3C2			; $B
	scriptofs	loc_1A421, loc_1A401			; $C
	scriptofs	loc_1A43E, loc_1A421			; $D
	scriptofs	loc_1A43E, loc_1A43E			; $E
	scriptofs	loc_1A473, loc_1A43E			; $F
	scriptofs	loc_1A4CB, loc_1A473			; $10
	scriptofs	loc_1A4EE, loc_1A4CB			; $11
	scriptofs	loc_1A516, loc_1A4EE			; $12
	scriptofs	loc_1A560, loc_1A516			; $13
	scriptofs	loc_1A59C, loc_1A560			; $14
	scriptofs	loc_1A59C, loc_1A59C			; $15
	scriptofs	loc_1A59C, loc_1A59C			; $16
	scriptofs	loc_1A5C4, loc_1A59C			; $17
	scriptofs	loc_1A5EC, loc_1A5C4			; $18
	scriptofs	loc_1A614, loc_1A5EC			; $19
	scriptofs	loc_1A650, loc_1A614			; $1A
	scriptofs	loc_1A664, loc_1A650			; $1B
	scriptofs	loc_1A672, loc_1A664			; $1C
	scriptofs	loc_1A72B, loc_1A672			; $1D
	scriptofs	loc_1A7BB, loc_1A72B			; $1E
	scriptofs	loc_1A8B6, loc_1A7BB			; $1F
	scriptofs	loc_1A939, loc_1A8B6			; $20
	scriptofs	loc_1A9E1, loc_1A939			; $21
	scriptofs	loc_1AA75, loc_1A9E1			; $22
	scriptofs	loc_1AB55, loc_1AA75			; $23
	scriptofs	loc_1ABE4, loc_1AB55			; $24
	scriptofs	loc_1AC76, loc_1ABE4			; $25
	scriptofs	loc_1AD47, loc_1AC76			; $26
	scriptofs	loc_1ADE5, loc_1AD47			; $27
	scriptofs	loc_1ADFE, loc_1ADE5			; $28
	scriptofs	loc_1AE6F, loc_1ADFE			; $29
	scriptofs	loc_1AEAA, loc_1AE6F			; $2A
	scriptofs	loc_1AEF2, loc_1AEAA			; $2B
	scriptofs	loc_1AF19, loc_1AEF2			; $2C
	scriptofs	loc_1AF45, loc_1AF19			; $2D
	scriptofs	loc_1AF74, loc_1AF45			; $2E
	scriptofs	loc_1AFA5, loc_1AF74			; $2F

loc_1A025:
	dc.b	"After going home and"
	dc.b	$C1
	dc.b	"preparing for the trip,"
	dc.b	$C3
	dc.b	"Nei seemed worried."
	dc.b	$C4

loc_1A066:
	dc.b	$C2
	dc.b	"Nei, I have to leave"
	dc.b	$C1
	dc.b	"for awhile", $47, $47, $47
	dc.b	$C4

loc_1A08A:
	dc.b	$C2
	dc.b	"Nei stared at me for a"
	dc.b	$C1
	dc.b	"moment. I remembered"
	dc.b	$C1
	dc.b	"when we first met, she"
	dc.b	$C1
	dc.b	"looked at me in just the"
	dc.b	$C3
	dc.b	"same way. That was seven"
	dc.b	$C1
	dc.b	"months ago. Because she"
	dc.b	$C1
	dc.b	"was the product of a"
	dc.b	$C1
	dc.b	"mixture of human cells"
	dc.b	$C3
	dc.b	"and those of a Bio-"		
	dc.b	$C1
	dc.b	"monster, she was an"
	dc.b	$C1
	dc.b	"outcast from society."
	dc.b	$C4

loc_1A182:
	dc.b	$C2
	dc.b	"You were still small"
	dc.b	$C1
	dc.b	"when we first met, but"
	dc.b	$C1
	dc.b	"now you can take care of"
	dc.b	$C1
	dc.b	"yourself. I'm going on"
	dc.b	$C3
	dc.b	"a dangerous journey: too"	
	dc.b	$C1
	dc.b	"dangerous for you. I"
	dc.b	$C1
	dc.b	"worry about you like you"
	dc.b	$C1
	dc.b	"were my sister."
	dc.b	$C4

loc_1A236:
	dc.b	$C2
	dc.b	"Still, Nei stood in the"
	dc.b	$C1
	dc.b	"doorway to keep me from"
	dc.b	$C1
	dc.b	"leaving."
	dc.b	$C4

loc_1A270:
	dc.b	$C2
	dc.b	"Please, ", $BB, "! Take me"
	dc.b	$C1
	dc.b	"with you! I'll do"
	dc.b	$C1
	dc.b	"anything for you!"
	dc.b	$C4

loc_1A2A8:
	dc.b	"I took my sack and"
	dc.b	$C1
	dc.b	"started to go, but Nei"
	dc.b	$C1
	dc.b	"still blocked the way. I"
	dc.b	$C1
	dc.b	"had no choice. I decided"
	dc.b	$C3
	dc.b	"to let her come with me."
	dc.b	$C4

loc_1A31D:
	dc.b	"Ahh, home at last. But"
	dc.b	$C1
	dc.b	"there's no time to"
	dc.b	$C1
	dc.b	"relax! Before you go out"
	dc.b	$C1
	dc.b	"again, you'd better"
	dc.b	$C3
	dc.b	"check your companions."
	dc.b	$C4

loc_1A38B:
	dc.b	"There doesn't seem to be"
	dc.b	$C1
	dc.b	"any problems! Be on your"
	dc.b	$C1
	dc.b	"way!"
	dc.b	$C4

loc_1A3C2:
	dc.b	"This will be a difficult"
	dc.b	$C1
	dc.b	"journey! Pick your"
	dc.b	$C3
	dc.b	"companions wisely!"
	dc.b	$C5

loc_1A401:
	dc.b	"Let's check the current"
	dc.b	$C1
	dc.b	"roster."
	dc.b	$C5

loc_1A421:
	dc.b	"There's a knock at the"
	dc.b	$C1
	dc.b	"door!"
	dc.b	$C4

loc_1A43E:
	dc.b	"Let's check the"
	dc.b	$C1
	dc.b	"roster at the point"
	dc.b	$C1
	dc.b	"where ", $BB, " came in."
	dc.b	$C5

loc_1A473:
	dc.b	"Let's see how many"
	dc.b	$C1
	dc.b	"members there are, and"
	dc.b	$C1
	dc.b	"if we want to regroup."
	dc.b	$C1
	dc.b	"Well, let's get going."
	dc.b	$C5

loc_1A4CB:
	dc.b	"Who should we take into"
	dc.b	$C1
	dc.b	"the party?"
	dc.b	$C5

loc_1A4EE:
	dc.b	$BB, " is a member. Do you"
	dc.b	$C1
	dc.b	"want anyone else?"
	dc.b	$C5

loc_1A516:
	dc.b	$BB, " is a member, and"
	dc.b	$C1
	dc.b	"that makes four."
	dc.b	$C1
	dc.b	"Let's start the journey!"
	dc.b	$C4
	
; ---------------------------------------------
; some leftover script data - just remove it
	dc.b	"nd"
	dc.b	$C1
	dc.b	" Let's"
	dc.b	$C1				
	dc.b	"y!"
	dc.b	$C4
; ---------------------------------------------

loc_1A560:
	dc.b	"Your name fits you"
	dc.b	$C1
	dc.b	"well! I'm glad to have"
	dc.b	$C3
	dc.b	"you in our group!"
	dc.b	$C5

loc_1A59C:
	dc.b	$C2
	dc.b	"I see. What name would"
	dc.b	$C1
	dc.b	"be good for me?"
	dc.b	$C5
	
loc_1A5C4:
	dc.b	$C2
	dc.b	"I see; what name would"
	dc.b	$C1
	dc.b	"be good for me?"
	dc.b	$C5
	
loc_1A5EC:
	dc.b	$C2
	dc.b	"I see; what name would"
	dc.b	$C1
	dc.b	"be good for me?"
	dc.b	$C5
	
loc_1A614:
	dc.b	$C2
	dc.b	"I'm Shir of the wind,"
	dc.b	$C1
	dc.b	"because the wind is all"
	dc.b	$C1
	dc.b	"that I have."
	dc.b	$C4

loc_1A650:
	dc.b	$C2
	dc.b	"I will call you ", $BB, "!"
	dc.b	$C4
	
loc_1A664:
	dc.b	$C2
	dc.b	"Excuse me", $47, $47, $47
	dc.b	$C4

loc_1A672:
	dc.b	$C2
	dc.b	"I'm sorry to intrude,"
	dc.b	$C1
	dc.b	"but I have heard that"
	dc.b	$C1
	dc.b	$BB, " and Nei are trying"
	dc.b	$C1
	dc.b	"to solve the mystery of"
	dc.b	$C3
	dc.b	"the Biomonsters. I am a"
	dc.b	$C1
	dc.b	"professional Biomonster"
	dc.b	$C1
	dc.b	"hunter. I have little"
	dc.b	$C1
	dc.b	"talent, except that I am"
	dc.b	$C3

loc_1A72B:
	dc.b	"good with a gun."
	dc.b	$C1
	dc.b	"I also want to go with"
	dc.b	$C1
	dc.b	"you. My name is Rudo,"
	dc.b	$C1
	dc.b	"which is short for"
	dc.b	$C3
	dc.b	"Rudolf Steiner. Maybe"
	dc.b	$C1
	dc.b	"you think you know a"
	dc.b	$C1
	dc.b	"better name for me?"
	dc.b	$C5

loc_1A7BB:
	dc.b	$C2
	dc.b	"How do you do? I am Dr."
	dc.b	$C1
	dc.b	"Amy Sage. I heard that"
	dc.b	$C1
	dc.b	"you are seeking to"
	dc.b	$C1
	dc.b	"solve the mystery of the"
	dc.b	$C3
	dc.b	"Biomonsters. I will be"
	dc.b	$C1
	dc.b	"glad to assist you,"
	dc.b	$C1
	dc.b	"though I am not much of"
	dc.b	$C1
	dc.b	"a fighter."
	dc.b	$C3
	dc.b	"But, I can heal wounds."
	dc.b	$C1
	dc.b	"Give me a new name, if"
	dc.b	$C1
	dc.b	"you wish, as a sign of"
	dc.b	$C1
	dc.b	"closeness."
	dc.b	$C5

loc_1A8B6:
	dc.b	$C2
	dc.b	"How do you do, ", $BB, ". I"
	dc.b	$C1
	dc.b	"am Hugh Thompson, a"
	dc.b	$C1
	dc.b	"Biologist. I came when"
	dc.b	$C1
	dc.b	"I heard about your"
	dc.b	$C3
	dc.b	"quest. I value all"
	dc.b	$C1
	dc.b	"life, including"
	dc.b	$C1
	dc.b	"Biomonsters."
	dc.b	$C1
	
loc_1A939:
	dc.b	"I am willing to fight"
	dc.b	$C3
	dc.b	"to defend weaker life"
	dc.b	$C1
	dc.b	"forms, though. Perhaps"
	dc.b	$C1
	dc.b	"my knowledge will be of"
	dc.b	$C1
	dc.b	"help to you. I will feel"
	dc.b	$C3
	dc.b	"like we are good friends"
	dc.b	$C1
	dc.b	"if you give me a"
	dc.b	$C1
	dc.b	"nickname."
	dc.b	$C5

loc_1A9E1:
	dc.b	$C2
	dc.b	"I have long wanted to"
	dc.b	$C1
	dc.b	"meet you. I am Anna"
	dc.b	$C1
	dc.b	"Zirski. I am known as"
	dc.b	$C1
	dc.b	"a guardian. Although"
	dc.b	$C3
	dc.b	"most hunters are good,"
	dc.b	$C1
	dc.b	"some have gone bad; I"
	dc.b	$C1
	dc.b	"track them down."
	dc.b	$C1
	
loc_1AA75:
	dc.b	"My job is to hunt evil"
	dc.b	$C3
	dc.b	"hunters,but I can hunt"
	dc.b	$C1
	dc.b	"anything! I dislike"
	dc.b	$C1
	dc.b	"guns, but give me a"
	dc.b	$C1
	dc.b	"weapon with a blade, and"
	dc.b	$C3
	dc.b	"I am deadly! I can help"
	dc.b	$C1
	dc.b	"you. Yes, give me a new"
	dc.b	$C1
	dc.b	"name and I can forget"
	dc.b	$C3
	dc.b	"the past and concentrate"
	dc.b	$C1
	dc.b	"on the present", $47, $47, $47
	dc.b	$C5

loc_1AB55:
	dc.b	$C2
	dc.b	"Howja do? I'se glad ta"
	dc.b	$C1
	dc.b	"see ya. Yup, I done"
	dc.b	$C1
	dc.b	"heard you goin' out"
	dc.b	$C1
	dc.b	"after them bad'uns; I"
	dc.b	$C3
	dc.b	"kin help ya. I ain't"
	dc.b	$C1
	dc.b	"much fer them slimy"
	dc.b	$C1
	dc.b	"critters,but", $47, $47, $47
	dc.b	$C1

loc_1ABE4:
	dc.b	"if any machines or"
	dc.b	$C3
	dc.b	"robots git in yer way, I"
	dc.b	$C1
	dc.b	"kin bust'em up real"
	dc.b	$C1
	dc.b	"good! My birthin' name"
	dc.b	$C1
	dc.b	"be Josh Kain."
	dc.b	$C3
	dc.b	"Watsamatta? Don'cha"
	dc.b	$C1
	dc.b	"think tha's a good"
	dc.b	$C1
	dc.b	"name?"
	dc.b	$C5

loc_1AC76:
	dc.b	$C2
	dc.b	"Hello, ", $BB, ". You are"
	dc.b	$C1
	dc.b	"just as handsome as they"
	dc.b	$C1
	dc.b	"say. I am Shir Gold."	
	dc.b	$C1
	dc.b	"I am a thief. I care"
	dc.b	$C3
	dc.b	"little for peace and"
	dc.b	$C1
	dc.b	"justice. I steal for"
	dc.b	$C1
	dc.b	"fun; and frankly, I"
	dc.b	$C1
	dc.b	"think your little outing"
	dc.b	$C3
	dc.b	"will be packed with"
	dc.b	$C1
	dc.b	"thrills for me."
	dc.b	$C1
	
loc_1AD47:
	dc.b	"I think I'd like to go"
	dc.b	$C1
	dc.b	"with you. Remember, I'm"
	dc.b	$C3	
	dc.b	"Shir of the wind!"
	dc.b	$C1
	dc.b	"Nothing can catch me! Do"
	dc.b	$C1
	dc.b	"you want me to come with"
	dc.b	$C1
	dc.b	"you? What, you want to"
	dc.b	$C3
	dc.b	"give me a new name?"
	dc.b	$C5

loc_1ADE5:
	dc.b	"Hey,Shir is coming"
	dc.b	$C1
	dc.b	"back!"
	dc.b	$C4

loc_1ADFE:
	dc.b	$C2
	dc.b	"Sorry to make you"
	dc.b	$C1
	dc.b	"worry, but I felt the"
	dc.b	$C1
	dc.b	"breezes calling, so I"
	dc.b	$C1
	dc.b	"went for a little walk!"
	dc.b	$C3
	dc.b	"Well, ", $BB, ", let's get"
	dc.b	$C1
	dc.b	"going!"
	dc.b	$C4

loc_1AE6F:
	dc.b	"I guess there aren't"
	dc.b	$C1
	dc.b	"enough members to"
	dc.b	$C1
	dc.b	"regroup, are there?"
	dc.b	$C5

loc_1AEAA:
	dc.b	"I am going to journey on"
	dc.b	$C1
	dc.b	"my own. It would be nice"
	dc.b	$C1
	dc.b	"to have some company!"
	dc.b	$C5

loc_1AEF2:
	dc.b	"Right now I am"
	dc.b	$C1
	dc.b	"journeying just with"
	dc.b	$C1	
	dc.b	$BB, "."
	dc.b	$C5

loc_1AF19:
	dc.b	$BB, " and ", $BB, " are coming"
	dc.b	$C1
	dc.b	"with me on this journey."
	dc.b	$C5

loc_1AF45:
	dc.b	$BB, ", ", $BB, " and ", $BB, " are"
	dc.b	$C1
	dc.b	"coming with me on this"
	dc.b	$C1
	dc.b	"journey."
	dc.b	$C5

loc_1AF74:
	dc.b	"Shall we continue our"
	dc.b	$C1
	dc.b	"quest without any"
	dc.b	$C1
	dc.b	"changes?"
	dc.b	$C5

loc_1AFA5:
	dc.b	"We've added ", $BB, ". This"
	dc.b	$C1
	dc.b	"is much more reassuring."
	dc.b	$C1
	dc.b	"Well, let's get going!"
	dc.b	$C4
; ---------------------------------------------------------------------------------

	even
	
	if long_script_offsets
	even
	endif
Script_UstvestiaHouse:
	scriptofs	loc_1AFF7, Script_UstvestiaHouse		; 1
	scriptofs	loc_1B030, loc_1AFF7					; 2
	scriptofs	loc_1B044, loc_1B030					; 3
	scriptofs	loc_1B077, loc_1B044					; 4
	scriptofs	loc_1B0B3, loc_1B077					; 5
	scriptofs	loc_1B0D2, loc_1B0B3					; 6
	scriptofs	loc_1B0F4, loc_1B0D2					; 7 
	scriptofs	loc_1B10B, loc_1B0F4					; 8
	scriptofs	loc_1B143, loc_1B10B					; 9
	scriptofs	loc_1B171, loc_1B143 				; $A
	scriptofs	loc_1B19D, loc_1B171					; $B
	scriptofs	loc_1B1B9, loc_1B19D					; $C
	scriptofs	loc_1B1E8, loc_1B1B9					; $D
	
loc_1AFF7:
	dc.b	"I am Ustvestia, a"
	dc.b	$C1
	dc.b	"musician. Do you want"
	dc.b	$C3
	dc.b	"to hear me play?"
	dc.b	$C5
	
loc_1B030:
	dc.b	"Great! Pick a song."
	dc.b	$C5
	
loc_1B044:
	dc.b	"Oh, I get it, you want"
	dc.b	$C1
	dc.b	"to learn to play the"
	dc.b	$C3
	dc.b	"piano!"
	dc.b	$C5
	
; it always sounded to me that it's Rolf who says the line, but it's actually Ustvestia. To be honest I realized this
; when playing the Japanese version. It's translated poorly in my opinion. He says that you should leave since he's very busy
loc_1B077:
	dc.b	"Well, actually, I'm kind"
	dc.b	$C1
	dc.b	"of busy right now, I've"
	dc.b	$C3
	dc.b	"got to go!"
	dc.b	$C4
	
loc_1B0B3:
	dc.b	"Am I a great musician or"
	dc.b	$C1
	dc.b	"what?"
	dc.b	$C5
	
loc_1B0D2:
	dc.b	"Why, you--go on, get"
	dc.b	$C1
	dc.b	"out of here."
	dc.b	$C4
	
loc_1B0F4:
	dc.b	"Who is going to learn?"
	dc.b	$C5
	
loc_1B10B:
	dc.b	"Hey, he looks smart."		; For those who don't know, Ustvestia is gay, so "smart" was used to cover this up
	dc.b	$C1
	dc.b	"I'll give lessons for"
	dc.b	$C3	
	dc.b	"2000 meseta."
	dc.b	$C5
	
loc_1B143:
	dc.b	"All right. I'll give"
	dc.b	$C1
	dc.b	"lessons for 5000 meseta."
	dc.b	$C5
	
loc_1B171:
	dc.b	"You don't have enough"
	dc.b	$C1
	dc.b	"money. I'm not cheap."
	dc.b	$C4
	
loc_1B19D:
	dc.b	"Ok, I'll start the"
	dc.b	$C1
	dc.b	"lessons."
	dc.b	$C4
	
loc_1B1B9:
	dc.b	"Now you are also a"
	dc.b	$C1
	dc.b	"musical artist!"
	dc.b	$C3
	dc.b	"Come again!"
	dc.b	$C4
	
loc_1B1E8:
	dc.b	$BB, " has learned the"
	dc.b	$C1
	dc.b	"MUSIK technique."
	dc.b	$C4
; ---------------------------------------------------------------------------------	

	even
	
	if long_script_offsets
	even
	endif
Script_InventorHouse:
	scriptofs	loc_1B214, Script_InventorHouse	; 1
	scriptofs	loc_1B244, loc_1B214				; 2
	scriptofs	loc_1B269, loc_1B244				; 3 
	scriptofs	loc_1B2A4, loc_1B269				; 4
	scriptofs	loc_1B360, loc_1B2A4				; 5
	scriptofs	loc_1B391, loc_1B360				; 6
	scriptofs	loc_1B3FA, loc_1B391				; 7
	scriptofs	loc_1B41F, loc_1B3FA				; 8
	
loc_1B214:
	dc.b	"Hi! I'm working on"
	dc.b	$C1
	dc.b	"inventing a new kind of"
	dc.b	$C3	
	dc.b	"gum!"
	dc.b	$C4
	
loc_1B244:
	dc.b	"Do you know what MARUERA"
	dc.b	$C1
	dc.b	"LEAVES are?"
	dc.b	$C5
	
loc_1B269:
	dc.b	"I need some of those"
	dc.b	$C1
	dc.b	"leaves. If you find"
	dc.b	$C3
	dc.b	"any, let me know!"
	dc.b	$C4
	
loc_1B2A4:
	dc.b	"There is a MARUERA TREE"
	dc.b	$C1
	dc.b	"on an island in the sea."
	dc.b	$C3
	dc.b	"The leaves of that tree"
	dc.b	$C1
	dc.b	"produce a large amount"
	dc.b	$C3
	dc.b	"of oxygen; I want to"
	dc.b	$C1
	dc.b	"use the leaves to make"
	dc.b	$C3
	dc.b	"a special gum that lets"
	dc.b	$C1
	dc.b	"you breathe underwater!"
	dc.b	$C4
	
loc_1B360:
	dc.b	"That's it; a MARUERA"
	dc.b	$C1
	dc.b	"LEAF! Please give it to"
	dc.b	$C3
	dc.b	"me!"
	dc.b	$C5
	
loc_1B391:
	dc.b	"Thanks! If you'll wait,"
	dc.b	$C1
	dc.b	"I'll make the gum", $47, $47, $47
	dc.b	$C3
	dc.b	"Done! There's plenty, so"
	dc.b	$C1
	dc.b	"take some! There you go!"
	dc.b	$C3
	dc.b	"Farewell!"
	dc.b	$C4
	
loc_1B3FA:
	dc.b	"That's too bad. Well"
	dc.b	$C1
	dc.b	"then, good-bye!"
	dc.b	$C4

; referenced but immediately overwritten in the code, thus it's never seen
loc_1B41F:
	dc.b	"Now, let me see,"
	dc.b	$C1
	dc.b	"what can I work on?"
	dc.b	$C4
; ---------------------------------------------------------------------------------

	even

	if long_script_offsets
	even
	endif
Script_TeleportStation:
	scriptofs	loc_1B44C, Script_TeleportStation	; 1
	scriptofs	loc_1B46D, loc_1B44C					; 2
	scriptofs	loc_1B498, loc_1B46D					; 3
	scriptofs	loc_1B517, loc_1B498					; 4
	scriptofs	loc_1B535, loc_1B517					; 5
	scriptofs	loc_1B55A, loc_1B535					; 6
	scriptofs	loc_1B576, loc_1B55A					; 7
	scriptofs	loc_1B59B, loc_1B576					; 8
	
loc_1B44C:
	dc.b	"Welcome to the Teleport Service."
	dc.b	$C4

loc_1B46D:
	dc.b	"Which town would you like"
	dc.b	$C1
	dc.b	"to teleport to?"
	dc.b	$C5
; unused bytes of the stock ROM
	dc.b	$00, $3B, $25, $32, $38, $00, $38, $33, $C1
; ------------------------

loc_1B498:
	dc.b	"For just "
	dc.b	$C0
	dc.b	" meseta, we'll zip you"
	dc.b	$C1
	dc.b	"to any town you remember."
	dc.b	$C3
	dc.b	"Once you know a town's name, please"
	dc.b	$C1
	dc.b	"do drop by."
	dc.b	$C4

loc_1B517:
	dc.b	"Then please come again."
	dc.b	$C1
	dc.b	"We'll be waiting."
	dc.b	$C4

loc_1B535:
	dc.b	"It will cost "
	dc.b	$C0
	dc.b	" meseta."
	dc.b	$C1
	dc.b	"Is that all right?"
	dc.b	$C5

loc_1B55A:
	dc.b	"We're sorry we couldn't help."
	dc.b	$C4

loc_1B576:
	dc.b	"You don't seem to have enough money."
	dc.b	$C4

loc_1B59B:
	dc.b	"Teleport machine, switch on!"
	dc.b	$C1
	dc.b	"Take care on your way!"
	dc.b	$C4
; ---------------------------------------------------------------------------------

	even

	if long_script_offsets
	even
	endif
Script_CentralTower:
	scriptofs	loc_1B5B7, Script_CentralTower	; 1
	scriptofs	loc_1B5F6, loc_1B5B7				; 2
	scriptofs	loc_1B60B, loc_1B5F6				; 3
	scriptofs	loc_1B6CD, loc_1B60B				; 4
	scriptofs	loc_1B6EC, loc_1B6CD				; 5
	
loc_1B5B7:
	dc.b	"This is Central Tower in"
	dc.b	$C1
	dc.b	"Paseo, the capital of"
	dc.b	$C1
	dc.b	"Mota. Where to?"
	dc.b	$C5
	
loc_1B5F6:
	dc.b	"Something's wrong", $47, $47, $47
	dc.b	$C7
	
loc_1B60B:
	dc.b	"Omigosh! The lake is"
	dc.b	$C1
	dc.b	"overflowing! There must"
	dc.b	$C1
	dc.b	"have been an accident at"
	dc.b	$C1
	dc.b	"Climatrol! All of the"
	dc.b	$C3
	dc.b	"rain supply has flowed"
	dc.b	$C1
	dc.b	"into the lake! Mota"
	dc.b	$C1
	dc.b	"is going to flood! Run"
	dc.b	$C1
	dc.b	"for your lives! It's a"
	dc.b	$C3
	dc.b	"catastrophe!"
	dc.b	$C4

loc_1B6CD:
	dc.b	"This must get to the"
	dc.b	$C1
	dc.b	"governor!"
	dc.b	$C4
	
loc_1B6EC:
	dc.b	"Something is rotten in"
	dc.b	$C1
	dc.b	"the state of Mota!"
	dc.b	$C1
	dc.b	"Neifirst is dead and the"
	dc.b	$C1
	dc.b	"Biohazards have been"
	dc.b	$C3
	dc.b	"destroyed", $47, $47, $47, "but why was"
	dc.b	$C1
	dc.b	"a creature like Neifirst"
	dc.b	$C1
	dc.b	"created in the first"
	dc.b	$C1
	dc.b	"place? Who is behind"
	dc.b	$C3
	dc.b	"all of this?"
	dc.b	$C3
; ---------------------------------------------------------------------------------

	even

	if long_script_offsets
	even
	endif
Script_Room:
	scriptofs	loc_1B7BA, Script_Room	; 1
	scriptofs	loc_1B7F1, loc_1B7BA		; 2
	scriptofs	loc_1B820, loc_1B7F1		; 3
	scriptofs	loc_1B82D, loc_1B820		; 4
	scriptofs	loc_1B861, loc_1B82D		; 5
	scriptofs	loc_1B890, loc_1B861		; 6
	scriptofs	loc_1B8BA, loc_1B890		; 7
	scriptofs	loc_1B8D2, loc_1B8BA		; 8
	scriptofs	loc_1B901, loc_1B8D2		; 9
	scriptofs	loc_1B93B, loc_1B901		; $A
	scriptofs	loc_1B97C, loc_1B93B		; $B
	scriptofs	loc_1B9BC, loc_1B97C		; $C
	scriptofs	loc_1B9DF, loc_1B9BC		; $D
	scriptofs	loc_1B9F9, loc_1B9DF		; $E
	
loc_1B7BA:
	dc.b	"How're you doing? Is"
	dc.b	$C1
	dc.b	"there something I can do"
	dc.b	$C3
	dc.b	"for you?"
	dc.b	$C5
	
loc_1B7F1:
	dc.b	"Whose belongings do you"
	dc.b	$C1
	dc.b	"want to leave with me?"
	dc.b	$C5
	
loc_1B820:
	dc.b	"Which items?"
	dc.b	$C5
	
loc_1B82D:
	dc.b	"Ok, I'll keep them"
	dc.b	$C1
	dc.b	"safe for you until you"
	dc.b	$C3
	dc.b	"get back."
	dc.b	$C4
	
loc_1B861:
	dc.b	"Sorry, all my lockers"
	dc.b	$C1
	dc.b	"are filled up right now!"
	dc.b	$C4
	
loc_1B890:
	dc.b	"Don't you think you had"
	dc.b	$C1
	dc.b	"better keep that?"
	dc.b	$C4
	
loc_1B8BA:
	dc.b	"Is there anything else?"
	dc.b	$C5
	
loc_1B8D2:
	dc.b	"Well, then, take care!"
	dc.b	$C1
	dc.b	"Drop by again! So long!"
	dc.b	$C4
	
loc_1B901:
	dc.b	"These are the things I"
	dc.b	$C1
	dc.b	"have here. Which ones do"
	dc.b	$C3
	dc.b	"you want?"
	dc.b	$C5
	
loc_1B93B:
	dc.b	"That's funny; I'm pretty"
	dc.b	$C1
	dc.b	"sure you haven't left"
	dc.b	$C3
	dc.b	"anything with me."
	dc.b	$C4

loc_1B97C:
	dc.b	"Ok, you're going to take"
	dc.b	$C1
	dc.b	"this. See? It's just"
	dc.b	$C3
	dc.b	"like you left it."
	dc.b	$C4
	
loc_1B9BC:
	dc.b	"Huh? Where? I can't see"
	dc.b	$C1
	dc.b	"any items!"
	dc.b	$C4
	
loc_1B9DF:
	dc.b	"Who's going to take"
	dc.b	$C1
	dc.b	"this?"
	dc.b	$C5
	
loc_1B9F9:
	dc.b	"You have too much"
	dc.b	$C1
	dc.b	"already. Can someone"
	dc.b	$C3
	dc.b	"else take it?"
	dc.b	$C5
; ---------------------------------------------------------------------------------

	even

	if long_script_offsets
	even
	endif
Script_Roof:
	scriptofs	loc_1BA31, Script_Roof	; 1
	scriptofs	loc_1BA9E, loc_1BA31		; 2
	scriptofs	loc_1BAB4, loc_1BA9E		; 3
	
loc_1BA31:
	dc.b	"This is Mota's only"
	dc.b	$C1
	dc.b	"remaining spaceship."
	dc.b	$C3
	dc.b	"It's entirely automatic,"
	dc.b	$C1
	dc.b	"so anyone can fly it."
	dc.b	$C3
	dc.b	"Shall we go to Dezo?"
	dc.b	$C5
	
loc_1BA9E:
	dc.b	"Now leaving for Dezo."
	dc.b	$C4
	
loc_1BAB4:
	dc.b	"The party leaves Central"
	dc.b	$C1
	dc.b	"Tower without boarding"
	dc.b	$C3
	dc.b	"the spaceship."
	dc.b	$C4
; ---------------------------------------------------------------------------------

	even

	if long_script_offsets
	even
	endif
Script_Library:
	scriptofs	loc_1BB0D, Script_Library	; 1
	scriptofs	loc_1BB25, loc_1BB0D			; 2
	scriptofs	loc_1BB41, loc_1BB25			; 3
	scriptofs	loc_1BB70, loc_1BB41			; 4
	scriptofs	loc_1BC48, loc_1BB70			; 5
	scriptofs	loc_1BCA1, loc_1BC48			; 6
	scriptofs	loc_1BD50, loc_1BCA1			; 7
	scriptofs	loc_1BE34, loc_1BD50			; 8
	scriptofs	loc_1BEB1, loc_1BE34			; 9
	scriptofs	loc_1BF2C, loc_1BEB1			; $A
	scriptofs	loc_1BFDB, loc_1BF2C			; $B
	scriptofs	loc_1C09B, loc_1BFDB			; $C
	scriptofs	loc_1C163, loc_1C09B			; $D
	scriptofs	loc_1C1CF, loc_1C163			; $E
	scriptofs	loc_1C25B, loc_1C1CF			; $F
	scriptofs	loc_1C323, loc_1C25B			; $10
	scriptofs	loc_1C3D4, loc_1C323			; $11
	scriptofs	loc_1C48D, loc_1C3D4			; $12
	scriptofs	loc_1C528, loc_1C48D			; $13
	scriptofs	loc_1C5D9, loc_1C528			; $14
	scriptofs	loc_1C69B, loc_1C5D9			; $15
	scriptofs	loc_1C6DF, loc_1C69B			; $16
	scriptofs	loc_1C737, loc_1C6DF			; $17
	scriptofs	loc_1C7DE, loc_1C737			; $18
	scriptofs	loc_1C835, loc_1C7DE			; $19
	
loc_1BB0D:
	dc.b	"Welcome to the library."
	dc.b	$C4

loc_1BB25:
	dc.b	"I see. Well, see you"
	dc.b	$C1
	dc.b	"later."
	dc.b	$C4
	
loc_1BB41:
	dc.b	"Is there anything else"
	dc.b	$C1
	dc.b	"you would like to know?"
	dc.b	$C5
	
loc_1BB70:
	dc.b	"Mota used to be a"
	dc.b	$C1
	dc.b	"desert, but since"
	dc.b	$C1
	dc.b	"Mother Brain was "
	dc.b	$C1
	dc.b	"brought in, Mota has "
	dc.b	$C3
	dc.b	"become a green planet."
	dc.b	$C1
	dc.b	"Development was made"
	dc.b	$C1
	dc.b	"based on meticulous"
	dc.b	$C1
	dc.b	"plans. Mother Brain"
	dc.b	$C3
	dc.b	"created things like"
	dc.b	$C1
	dc.b	"the Biosystems lab,"
	dc.b	$C1	
	dc.b	"Climatrol, etc."
	dc.b	$C4

loc_1BC48:
	dc.b	"The Biosystems lab is"
	dc.b	$C1
	dc.b	"where creatures suitable"
	dc.b	$C1
	dc.b	"to live on Mota are"
	dc.b	$C1
	dc.b	"created through breed"
	dc.b	$C3

loc_1BCA1:
	dc.b	"improvements. All DNA"
	dc.b	$C1	
	dc.b	"data of Algo are stored"
	dc.b	$C1	
	dc.b	"there. The reason why"
	dc.b	$C1
	dc.b	"Mota was turned into"
	dc.b	$C3
	dc.b	"the largest agricultural"
	dc.b	$C1
	dc.b	"planet in Algo is owed"
	dc.b	$C1
	dc.b	"to the work of this Bio-"
	dc.b	$C1
	dc.b	"systems lab."
	dc.b	$C3
	
loc_1BD50:
	dc.b	"However, two years ago,"
	dc.b	$C1
	dc.b	"one accident which"
	dc.b	$C1
	dc.b	"happened in the Bio-"
	dc.b	$C1
	dc.b	"systems lab brought"
	dc.b	$C3
	dc.b	"about a creature that is"
	dc.b	$C1
	dc.b	"dangerous to humans."
	dc.b	$C1
	dc.b	"Biosystems lab was shut"
	dc.b	$C1
	dc.b	"down immediately, but"
	dc.b	$C3
	dc.b	"no report on the cause"
	dc.b	$C1
	dc.b	"or remedy has been made"
	dc.b	$C1
	dc.b	"yet."
	dc.b	$C4

loc_1BE34:
	dc.b	"Climatrol is a system"
	dc.b	$C1
	dc.b	"to adjust the weather"
	dc.b	$C1
	dc.b	"of Mota. It controls"
	dc.b	$C1
	dc.b	"the temperature and"
	dc.b	$C3
	dc.b	"maintains the proper"
	dc.b	$C1
	dc.b	"amount of rainfall"
	dc.b	$C1
	
loc_1BEB1:
	dc.b	"and so on. Mota was"
	dc.b	$C1
	dc.b	"originally a very dry"
	dc.b	$C3
	dc.b	"planet with no natural"
	dc.b	$C1
	dc.b	"rainfall. So the"
	dc.b	$C1
	dc.b	"existence of Climatrol"
	dc.b	$C1
	dc.b	"is essential now."
	dc.b	$C4
	
loc_1BF2C:
	dc.b	"There are rivers run-"
	dc.b	$C1
	dc.b	"ning in all four direc-"
	dc.b	$C1
	dc.b	"tions: east, west,"
	dc.b	$C1
	dc.b	"south and north from a"
	dc.b	$C3
	dc.b	"lake. There are dams"
	dc.b	$C1
	dc.b	"built between each river"
	dc.b	$C1
	dc.b	"and the lake. They"
	dc.b	$C1
	dc.b	"control the amount of"
	dc.b	$C3

loc_1BFDB:
	dc.b	"water flowing into the"
	dc.b	$C1
	dc.b	"rivers. The names of the"
	dc.b	$C1
	dc.b	"dams are Green dam,"
	dc.b	$C1
	dc.b	"Yellow dam, Red dam, and"
	dc.b	$C3
	dc.b	"Blue dam. In order to"
	dc.b	$C1
	dc.b	"enter each dam, a card"
	dc.b	$C1	
	dc.b	"whose color matches"
	dc.b	$C1
	dc.b	"the color of the dam is"
	dc.b	$C3
	dc.b	"required."
	dc.b	$C1
	
loc_1C09B:
	dc.b	"These cards are supposed"
	dc.b	$C1
	dc.b	"to be in a control"
	dc.b	$C1
	dc.b	"tower, but its location"
	dc.b	$C3
	dc.b	"is a secret. Also, the"
	dc.b	$C1
	dc.b	"smallest dam is the"
	dc.b	$C1
	dc.b	"Red dam, and the"
	dc.b	$C1
	dc.b	"structures get more"
	dc.b	$C3
	dc.b	"complicated in the order"
	dc.b	$C1
	dc.b	"of Yellow, Blue and"
	dc.b	$C1
	dc.b	"Green."
	dc.b	$C4

loc_1C163:
	dc.b	"Mother Brain is a huge"
	dc.b	$C1
	dc.b	"computer with enough"
	dc.b	$C1
	dc.b	"power to control every-"
	dc.b	$C1
	dc.b	"thing in the world of"
	dc.b	$C3	
	dc.b	"Algo. Our life is"
	dc.b	$C1
	
loc_1C1CF:
	dc.b	"monitored and is"
	dc.b	$C1
	dc.b	"supported by Mother"
	dc.b	$C1
	dc.b	"Brain. Mother Brain was"
	dc.b	$C3
	dc.b	"brought into Palm in the"
	dc.b	$C1
	dc.b	"year AW845, then the"
	dc.b	$C1
	dc.b	"network spread to Mota"
	dc.b	$C1
	dc.b	"and Dezo."
	dc.b	$C3

loc_1C25B:
	dc.b	"It is Mother Brain which"
	dc.b	$C1
	dc.b	"controls the systems"	
	dc.b	$C1
	dc.b	"such as the Biosystems"
	dc.b	$C1
	dc.b	"lab, Climatrol, dams and"
	dc.b	$C3
	dc.b	"so on. Thus Mother Brain"
	dc.b	$C1
	dc.b	"is essential to our"
	dc.b	$C1	
	dc.b	"life, but nobody knows"
	dc.b	$C1
	dc.b	"who made Mother Brain"
	dc.b	$C3
	dc.b	"or where it is."
	dc.b	$C4

loc_1C323:
	dc.b	"Analysis on recorder has"
	dc.b	$C1
	dc.b	"been completed. The"
	dc.b	$C1
	dc.b	"cause of the accident"
	dc.b	$C1
	dc.b	"in the Biosystems lab"
	dc.b	$C3
	dc.b	"was an overload of"
	dc.b	$C1
	dc.b	"energy poured into the"
	dc.b	$C1	
	dc.b	"system all at once. As a"
	dc.b	$C1
	dc.b	"result, the creature"
	dc.b	$C3

loc_1C3D4:
	dc.b	"made a rapid evolution."
	dc.b	$C1
	dc.b	"This creature does not"
	dc.b	$C1
	dc.b	"fit into the cycle of"
	dc.b	$C1
	dc.b	"nature, thus should not"
	dc.b	$C3
	dc.b	"exist. And because this"
	dc.b	$C1
	dc.b	"kind of creature was"
	dc.b	$C1
	dc.b	"created, the natural"
	dc.b	$C1
	dc.b	"cycles went out of"
	dc.b	$C3
	dc.b	"order."
	dc.b	$C4

loc_1C48D:
	dc.b	"Please look at this"
	dc.b	$C1	
	dc.b	"graph. It shows the"
	dc.b	$C1
	dc.b	"amount of energy"
	dc.b	$C1
	dc.b	"consumed in the last"
	dc.b	$C3
	dc.b	"couple of years. Let's"
	dc.b	$C1	
	dc.b	"overlap the graphs of"
	dc.b	$C1
	dc.b	"temperature and"
	dc.b	$C1
	dc.b	"rainfall on it."
	dc.b	$C4

loc_1C528:
	dc.b	"As you see, the energy"
	dc.b	$C1
	dc.b	"which was to be used by"
	dc.b	$C1
	dc.b	"Climatrol to control"
	dc.b	$C1
	dc.b	"temperature and rainfall"
	dc.b	$C3
	dc.b	"seems to have flowed"
	dc.b	$C1
	dc.b	"into the Biosystems lab."
	dc.b	$C1
	dc.b	"Biohazard could be"
	dc.b	$C1
	dc.b	"something that was"
	dc.b	$C3

loc_1C5D9:
	dc.b	"schemed up by someone."
	dc.b	$C1
	dc.b	"Please find out why the"
	dc.b	$C1
	dc.b	"energy leaked from"
	dc.b	$C3
	dc.b	"Climatrol. Also, if you"
	dc.b	$C1
	dc.b	"are going south, take"
	dc.b	$C1
	dc.b	"this with you. The"
	dc.b	$C1
	dc.b	"bridge over the west"
	dc.b	$C3
	dc.b	"river can be passed with"
	dc.b	$C1
	dc.b	"this. Good luck!"
	dc.b	$C4

loc_1C69B:
	dc.b	"If you want to find out"
	dc.b	$C1
	dc.b	"about something here,"
	dc.b	$C3
	dc.b	"please choose a file."
	dc.b	$C5

loc_1C6DF:
	dc.b	"I understand that"
	dc.b	$C1
	dc.b	$BB, " and the others"
	dc.b	$C1
	dc.b	"are going to the"
	dc.b	$C1
	dc.b	"Biosystems lab to"
	dc.b	$C3
	dc.b	"get the recorder."
	dc.b	$C4

loc_1C737:
	dc.b	"Have you figured out the"
	dc.b	$C1
	dc.b	"cause of the accident in"
	dc.b	$C1
	dc.b	"which the energy leaked"
	dc.b	$C1
	dc.b	"into Biosystems lab"
	dc.b	$C3
	dc.b	"from Climatrol?"
	dc.b	$C1
	dc.b	"I am very worried about"
	dc.b	$C1
	dc.b	"what is going on with"
	dc.b	$C1
	dc.b	"Climatrol."
	dc.b	$C4 

loc_1C7DE:
	dc.b	"Is it true that Mota"
	dc.b	$C1
	dc.b	"is going to be flooded?"
	dc.b	$C1
	dc.b	"I hope those four dams"
	dc.b	$C1
	dc.b	"will somehow open."
	dc.b	$C4

loc_1C835:
	dc.b	"Thanks to you all,"
	dc.b	$C1
	dc.b	"Mota was saved from"
	dc.b	$C1
	dc.b	"being flooded."
	dc.b	$C1
	dc.b	"How come you are wanted"
	dc.b	$C3
	dc.b	"as criminals for making"
	dc.b	$C1
	dc.b	"Mother Brain go wrong?"
	dc.b	$C1
	dc.b	"What! Someone who has a"
	dc.b	$C1
	dc.b	"key to Mother Brain is"
	dc.b	$C3
	dc.b	"in Dezo?"
	dc.b	$C3
	dc.b	"That's right", $47, $47, $47, $47, "now"
	dc.b	$C1
	dc.b	"that Palm is gone, those"
	dc.b	$C3
	dc.b	"of us who are in Mota"
	dc.b	$C1	
	dc.b	"have to sustain Algo."
	dc.b	$C1
	dc.b	$BB, ", please do your"
	dc.b	$C1
	dc.b	"best!"
	dc.b	$C4
; ---------------------------------------------------------------------------------

	even

	if long_script_offsets
	even
	endif
Script_Governor:
	scriptofs	loc_1C96D, Script_Governor	; 1
	scriptofs	loc_1CA1F, loc_1C96D			; 2
	scriptofs	loc_1CA8C, loc_1CA1F			; 3
	scriptofs	loc_1CB47, loc_1CA8C			; 4
	scriptofs	loc_1CBAA, loc_1CB47			; 5
	scriptofs	loc_1CC3B, loc_1CBAA			; 6
	scriptofs	loc_1CCC2, loc_1CC3B			; 7
	scriptofs	loc_1CD58, loc_1CCC2			; 8
	scriptofs	loc_1CDDA, loc_1CD58			; 9
	scriptofs	loc_1CE5E, loc_1CDDA			; $A
	scriptofs	loc_1CF0A, loc_1CE5E			; $B
	scriptofs	loc_1CF5F, loc_1CF0A			; $C
	scriptofs	loc_1CF75, loc_1CF5F			; $D
	scriptofs	loc_1D002, loc_1CF75			; $E
	scriptofs	loc_1D078, loc_1D002			; $F
	scriptofs	loc_1D122, loc_1D078			; $10
	scriptofs	loc_1D159, loc_1D122			; $11
	
loc_1C96D:
	dc.b	"Good morning, ", $BB, "."
	dc.b	$C1
	dc.b	"How are you? Almost two"
	dc.b	$C1
	dc.b	"years have passed since"
	dc.b	$C1
	dc.b	"you started working for"
	dc.b	$C3
	dc.b	"me, the Commander of"
	dc.b	$C1	
	dc.b	"Mota. What I am going"
	dc.b	$C1
	dc.b	"to ask you to do will"
	dc.b	$C1
	dc.b	"be the toughest job you"
	dc.b	$C3

loc_1CA1F:
	dc.b	"have ever done, but it"
	dc.b	$C1
	dc.b	"is vital to the future"
	dc.b	$C1
	dc.b	"of Mota. As you know,"
	dc.b	$C1
	dc.b	"Algo has been brought"
	dc.b	$C3
	dc.b	"up by Mother Brain."
	dc.b	$C1
	
loc_1CA8C:
	dc.b	"My work as a Commander"
	dc.b	$C3	
	dc.b	"has been to smoothly"
	dc.b	$C1
	dc.b	"promote the plans of"
	dc.b	$C1
	dc.b	"Mother Brain. I had"
	dc.b	$C1
	dc.b	"believed that Mother"
	dc.b	$C3
	dc.b	"Brain never makes"
	dc.b	$C1
	dc.b	"mistakes. But those"
	dc.b	$C1
	dc.b	"monsters all over Mota"
	dc.b	$C1
	dc.b	"are just too much!"
	dc.b	$C3

loc_1CB47:
	dc.b	"We must find out by our-"
	dc.b	$C1
	dc.b	"selves why those"
	dc.b	$C1
	dc.b	"monsters were born, and"
	dc.b	$C1
	dc.b	"how to bring them under"
	dc.b	$C3
	dc.b	"control."
	dc.b	$C4

loc_1CBAA:
	dc.b	$BB, ", your mission is"
	dc.b	$C1
	dc.b	"to go to the Biosystems"
	dc.b	$C1	
	dc.b	"lab and get the"
	dc.b	$C3
	dc.b	"recorder. If we look"
	dc.b	$C1
	dc.b	"into the data, we can"
	dc.b	$C1
	dc.b	"figure out how the"
	dc.b	$C1
	dc.b	"Biosystems lab ended up"
	dc.b	$C3

loc_1CC3B:
	dc.b	"making those monsters. "
	dc.b	$C1
	dc.b	$BB, ", I hope from the"
	dc.b	$C1
	dc.b	"bottom of my heart that"
	dc.b	$C1
	dc.b	"you come back safely"
	dc.b	$C3
	dc.b	"with the recorder. We'll"
	dc.b	$C1
	dc.b	"see each other again!"
	dc.b	$C4

loc_1CCC2:
	dc.b	"Splendid work, ", $BB, "!"
	dc.b	$C1
	dc.b	"I will immediately"
	dc.b	$C1
	dc.b	"compare the recorder"
	dc.b	$C1
	dc.b	"with the library data."
	dc.b	$C3
	dc.b	"I have always believed"
	dc.b	$C1
	dc.b	"that Mother Brain is"
	dc.b	$C1
	dc.b	"absolutely right all the"
	dc.b	$C1
	
loc_1CD58:
	dc.b	"time, and that our life"
	dc.b	$C3
	dc.b	"is protected by Mother"
	dc.b	$C1
	dc.b	"Brain. But under the"
	dc.b	$C1
	dc.b	"reign of Mother Brain,"
	dc.b	$C1
	dc.b	"we have turned into"
	dc.b	$C3
	dc.b	"weak and lethargic"
	dc.b	$C1
	
loc_1CDDA:
	dc.b	"beings. Under the"
	dc.b	$C1
	dc.b	"circumstances, we cannot"
	dc.b	$C1
	dc.b	"help realizing that"
	dc.b	$C3
	dc.b	"fact. The data must be"
	dc.b	$C1
	dc.b	"ready. You'd better get"
	dc.b	$C1
	dc.b	"going to the library!"
	dc.b	$C4

loc_1CE5E:
	dc.b	$BB, ", once again there's"
	dc.b	$C1
	dc.b	"a serious problem."
	dc.b	$C1
	dc.b	"Just when we were"
	dc.b	$C1
	dc.b	"feeling relieved that"
	dc.b	$C3
	dc.b	"those monsters had been"
	dc.b	$C1
	dc.b	"taken care of, this"
	dc.b	$C1
	dc.b	"happened! We could avoid"
	dc.b	$C1
	dc.b	"the worst case if the"
	dc.b	$C3

loc_1CF0A:
	dc.b	"dams could be opened", $47, $47, $47
	dc.b	$C1
	dc.b	"but there's no control."
	dc.b	$C1
	dc.b	"Someone must go there"
	dc.b	$C3
	dc.b	"and open them."
	dc.b	$C4

loc_1CF5F:
	dc.b	$C2
	dc.b	"Please let me do it!"
	dc.b	$C4

loc_1CF75:
	dc.b	$C2
	dc.b	"Well", $47, $47, $47, ",but", $47, $47, $47, ",I'm sorry"
	dc.b	$C1
	dc.b	"to say this, but the"
	dc.b	$C1
	dc.b	"government of Palm has"
	dc.b	$C1
	dc.b	"announced your names as"
	dc.b	$C3
	dc.b	"the ones who made Mother"
	dc.b	$C1
	dc.b	"Brain go crazy. Right"
	dc.b	$C1

loc_1D002:
	dc.b	"now, the security system"
	dc.b	$C1
	dc.b	"is desperately trying to"
	dc.b	$C3
	dc.b	"catch you guys. It is"
	dc.b	$C1	
	dc.b	"too dangerous to do"
	dc.b	$C1
	dc.b	"anything that stands"
	dc.b	$C1
	dc.b	"out."
	dc.b	$C4

loc_1D078:
	dc.b	$C2
	dc.b	"But, even if we stay"
	dc.b	$C1
	dc.b	"inside and hold our"
	dc.b	$C1
	dc.b	"breath, they will find"
	dc.b	$C1
	dc.b	"us sooner or later."
	dc.b	$C3
	dc.b	"I'd rather go and open"
	dc.b	$C1
	dc.b	"those dams. I want to"
	dc.b	$C1
	dc.b	"find out who is trying"
	dc.b	$C1
	dc.b	"to destroy Mota."
	dc.b	$C4

loc_1D122:
	dc.b	$C2
	dc.b	"I see. I won't say"
	dc.b	$C1
	dc.b	"any more. Take care of"
	dc.b	$C1
	dc.b	"yourselves."
	dc.b	$C4

loc_1D159:
	dc.b	"Welcome back. I was"
	dc.b	$C1
	dc.b	"worried sick about you."
	dc.b	$C1
	dc.b	"What? You are going to"
	dc.b	$C1
	dc.b	"Dezo without a rest?"
	dc.b	$C3
	dc.b	$47, $47, $47, "I see. You must have"
	dc.b	$C1
	dc.b	"thought it out. Use the"
	dc.b	$C1
	dc.b	"spaceship on the roof-"
	dc.b	$C1
	dc.b	"top. But, remember that"
	dc.b	$C3	
	dc.b	"you are still suspects."
	dc.b	$C1
	dc.b	"The Palm incident has"
	dc.b	$C1
	dc.b	"made them desperate."
	dc.b	$C1
	dc.b	"Make sure you take care"
	dc.b	$C3
	dc.b	"of yourselves."
	dc.b	$C4
; ---------------------------------------------------------------------------------

	even

	if long_script_offsets
	even
	endif
Script_Battle:
	scriptofs	loc_1D2A5, Script_Battle	; 1
	scriptofs	loc_1D2B3, loc_1D2A5		; 2
	scriptofs	loc_1D2CB, loc_1D2B3		; 3
	scriptofs	loc_1D2E0, loc_1D2CB		; 4
	scriptofs	loc_1D2ED, loc_1D2E0		; 5
	scriptofs	loc_1D2FC, loc_1D2ED		; 6
	scriptofs	loc_1D307, loc_1D2FC		; 7
	scriptofs	loc_1D326, loc_1D307		; 8	
	scriptofs	loc_1D341, loc_1D326 	; 9
	scriptofs	loc_1D35D, loc_1D341		; $A
	scriptofs	loc_1D369, loc_1D35D		; $B
	scriptofs	loc_1D37C, loc_1D369		; $C
	scriptofs	loc_1D38C, loc_1D37C		; $D
	scriptofs	loc_1D3A7, loc_1D38C		; $E
	scriptofs	loc_1D3BA, loc_1D3A7		; $F
	scriptofs	loc_1D3CD, loc_1D3BA		; $10
	scriptofs	loc_1D3E0, loc_1D3CD		; $11
	scriptofs	loc_1D3FC, loc_1D3E0		; $12
	scriptofs	loc_1D411, loc_1D3FC		; $13
	scriptofs	loc_1D423, loc_1D411		; $14
	scriptofs	loc_1D434, loc_1D423		; $15
	scriptofs	loc_1D444, loc_1D434		; $16
	scriptofs	loc_1D454, loc_1D444		; $17
	scriptofs	loc_1D46D, loc_1D454		; $18
	scriptofs	loc_1D4AA, loc_1D46D		; $19
	scriptofs	loc_1D4C3, loc_1D4AA		; $1A
	scriptofs	loc_1D4C3, loc_1D4C3		; $1B
	scriptofs	loc_1D4C3, loc_1D4C3		; $1C
	scriptofs	loc_1D4D7, loc_1D4C3		; $1D
	scriptofs	loc_1D4E6, loc_1D4D7		; $1E
	scriptofs	loc_1D501, loc_1D4E6		; $1F
	scriptofs	loc_1D514, loc_1D501		; $20
	scriptofs	loc_1D52E, loc_1D514		; $21
	scriptofs	loc_1D53E, loc_1D52E		; $22
	scriptofs	loc_1D558, loc_1D53E		; $23
	scriptofs	loc_1D568, loc_1D558		; $24
	scriptofs	loc_1D59E, loc_1D568		; $25
	scriptofs	loc_1D5B2, loc_1D59E		; $26
	scriptofs	loc_1D5E1, loc_1D5B2		; $27
	scriptofs	loc_1D60C, loc_1D5E1		; $28
	scriptofs	loc_1D63C, loc_1D60C		; $29
	scriptofs	loc_1D65C, loc_1D63C		; $2A
	
loc_1D2A5:
	dc.b	$BB, " fell asleep!"
	dc.b	$C6
	
loc_1D2B3:
	dc.b	$BB, " and friends"
	dc.b	$C3
	dc.b	"run away!"
	dc.b	$C6
	
loc_1D2CB:
	dc.b	"But they're"
	dc.b	$C3
	dc.b	"trapped!"
	dc.b	$C6
	
loc_1D2E0:
	dc.b	"Didn't work!"
	dc.b	$C6
	
loc_1D2ED:
	dc.b	$BB, " can't fight!"
	dc.b	$C4
	
loc_1D2FC:
	dc.b	$BB, " is dead!"
	dc.b	$C6
	
loc_1D307:
	dc.b	$BB, " doesn't know"
	dc.b	$C3
	dc.b	"any techniques!"
	dc.b	$C4
	
loc_1D326:
	dc.b	$BB, " and party are"
	dc.b	$C3
	dc.b	"destroyed!"
	dc.b	$C6
	
loc_1D341:
	dc.b	"Fighting ability"
	dc.b	$C3
	dc.b	"increases!"
	dc.b	$C6

loc_1D35D:
	dc.b	$BD, " is quiet."
	dc.b	$C6
	
loc_1D369:
	dc.b	$BD, " has gone"
	dc.b	$C3
	dc.b	"insane!"
	dc.b	$C6
	
loc_1D37C:
	dc.b	$BD, " is"
	dc.b	$C3
	dc.b	"paralyzed!"
	dc.b	$C6
	
loc_1D38C:
	dc.b	"Defense ability"
	dc.b	$C3
	dc.b	"increases!"
	dc.b	$C6
	
loc_1D3A7:
	dc.b	"Agility increases!"
	dc.b	$C6
	
loc_1D3BA:
	dc.b	$BB, " gives up a"
	dc.b	$C3
	dc.b	"life!"
	dc.b	$C6
	
loc_1D3CD:
	dc.b	"Something's wrong!"
	dc.b	$C6
	
loc_1D3E0:
	dc.b	$BB, " and party are"
	dc.b	$C3
	dc.b	"victorious!"
	dc.b	$C4
	
loc_1D3FC:
	dc.b	$C0, " experience"
	dc.b	$C3
	dc.b	"points!"
	dc.b	$C4
	
loc_1D411:
	dc.b	"Receive ", $C0
	dc.b	$C3
	dc.b	"meseta!"
	dc.b	$C4
	
loc_1D423:
	dc.b	$BB, " gains a level."
	dc.b	$C4
	
loc_1D434:
	dc.b	"New HP maximum!"
	dc.b	$C4
	
loc_1D444:
	dc.b	"New TP maximum!"
	dc.b	$C4
	
loc_1D454:
	dc.b	"Learned a new"
	dc.b	$C3
	dc.b	"technique!"
	dc.b	$C4
	
loc_1D46D:
	dc.b	$BB, " and the others"
	dc.b	$C1
	dc.b	"failed to restore peace"
	dc.b	$C1
	dc.b	"to the planet Algo."
	dc.b	$C5
	
loc_1D4AA:
	dc.b	"Trapped by plasma"
	dc.b	$C3
	dc.b	"rings!"
	dc.b	$C4
	
loc_1D4C3:
	dc.b	"Too tired to"
	dc.b	$C3
	dc.b	"fight!"
	dc.b	$C6

loc_1D4D7:
	dc.b	$BB, " is poisoned!"
	dc.b	$C6
	
loc_1D4E6:
	dc.b	"Defense ability"
	dc.b	$C3
	dc.b	"decreased!"
	dc.b	$C6
	
loc_1D501:
	dc.b	"Agility decreased!"
	dc.b	$C6
	
loc_1D514:
	dc.b	"Attack ability"
	dc.b	$C3
	dc.b	"decreased!"
	dc.b	$C6
	
loc_1D52E:
	dc.b	$BB, " is paralyzed!"
	dc.b	$C6
	
loc_1D53E:
	dc.b	$BB, " is no longer"
	dc.b	$C3
	dc.b	"paralyzed!"
	dc.b	$C6
	
loc_1D558:
	dc.b	$BB, " becomes evil!"
	dc.b	$C6
	
loc_1D568:
	dc.b	$BB, " turns traitor"
	dc.b	$C3
	dc.b	"and tries to run,"
	dc.b	$C3
	dc.b	"but can't get"
	dc.b	$C3
	dc.b	"away!"
	dc.b	$C6
	
loc_1D59E:
	dc.b	"Crushed by"
	dc.b	$C3
	dc.b	"despair!"
	dc.b	$C6
	
loc_1D5B2:
	dc.b	$BB, " turns greedy"
	dc.b	$C3
	dc.b	"and searches the"
	dc.b	$C3
	dc.b	"others' items!"
	dc.b	$C6
	
loc_1D5E1:
	dc.b	$BB, " turns"
	dc.b	$C3
	dc.b	"doubtful!"
	dc.b	$C3
	dc.b	$BB, " fights less"
	dc.b	$C3
	dc.b	"furiously!"
	dc.b	$C6
	
loc_1D60C:
	dc.b	$BB, " loses"
	dc.b	$C3
	dc.b	"confidence!"
	dc.b	$C3
	dc.b	$BB, " can't use"
	dc.b	$C3
	dc.b	"any techniques!"
	dc.b	$C6
	
loc_1D63C:
	dc.b	$BB, " gets lazy!"
	dc.b	$C3
	dc.b	"Agility decreases!"
	dc.b	$C6

loc_1D65C:
	dc.b	"The Neisword emits"
	dc.b	$C3
	dc.b	"a bright light!"
	dc.b	$C3
	dc.b	"The evil is"
	dc.b	$C3
	dc.b	"dispelled!"
	dc.b	$C6
; ---------------------------------------------------------------------------------

	even

	if long_script_offsets
	even
	endif
Script_Introduction:
	scriptofs	loc_1D6A6, Script_Introduction	; 1
	scriptofs	loc_1D6F5, loc_1D6A6				; 2
	scriptofs	loc_1D719, loc_1D6F5				; 3
	scriptofs	loc_1D762, loc_1D719				; 4
	scriptofs	loc_1D784, loc_1D762				; 5
	scriptofs	loc_1D7AC, loc_1D784				; 6
	scriptofs	loc_1D7D4, loc_1D7AC				; 7
	scriptofs	loc_1D7FF, loc_1D7D4				; 8
	scriptofs	loc_1D81A, loc_1D7FF				; 9
	scriptofs	loc_1D837, loc_1D81A				; $A
	scriptofs	loc_1D873, loc_1D837				; $B
	scriptofs	loc_1D891, loc_1D873				; $C
	scriptofs	loc_1D8A7, loc_1D891				; $D
	scriptofs	loc_1D8E7, loc_1D8A7				; $E
	scriptofs	loc_1D90A, loc_1D8E7				; $F
	scriptofs	loc_1D950, loc_1D90A				; 10
	
loc_1D6A6:
	dc.b	"There is no room to save"
	dc.b	$C1
	dc.b	"any more data; do you"
	dc.b	$C3
	dc.b	"still want to start a"
	dc.b	$C1
	dc.b	"new game?"
	dc.b	$C5
	
loc_1D6F5:
	dc.b	"What is the name of your"
	dc.b	$C1
	dc.b	"character?"
	dc.b	$C5
	
loc_1D719:
	dc.b	"Some of the existing"
	dc.b	$C1
	dc.b	"data needs to be erased"
	dc.b	$C3
	dc.b	"before starting a new"
	dc.b	$C1
	dc.b	"game."
	dc.b	$C4

loc_1D762:
	dc.b	"Well, then, let's begin"
	dc.b	$C1
	dc.b	"the game!"
	dc.b	$C4

loc_1D784:
	dc.b	"Which number game do you"
	dc.b	$C1
	dc.b	"want to start?"
	dc.b	$C5

loc_1D7AC:
	dc.b	"Which number game do you"
	dc.b	$C1
	dc.b	"want to erase?"
	dc.b	$C5

loc_1D7D4:
	dc.b	"Do you really want to"
	dc.b	$C1	
	dc.b	"erase game number ", $C0, "?"
	dc.b	$C5

loc_1D7FF:
	dc.b	"Now erasing game number"
	dc.b	$C1
	dc.b	$C0, "."
	dc.b	$C4

loc_1D81A:
	dc.b	"Ok, I won't erase that"
	dc.b	$C1
	dc.b	"game."
	dc.b	$C4

loc_1D837:
	dc.b	"There is no data for"
	dc.b	$C1
	dc.b	"that number. Enter a"
	dc.b	$C3
	dc.b	"different number."
	dc.b	$C5

loc_1D873:
	dc.b	"Let me check the backup"
	dc.b	$C1
	dc.b	"data."
	dc.b	$C7
	
loc_1D891:
	dc.b	"The data for ", $C0, " is ok."
	dc.b	$C5

loc_1D8A7:
	dc.b	"There is a problem with"
	dc.b	$C1
	dc.b	"the data. Let me see if"
	dc.b	$C3
	dc.b	"I can fix it", $47, $47, $47
	dc.b	$C7
	
loc_1D8E7:
	dc.b	"Ok, I was able to fix"
	dc.b	$C1
	dc.b	"the problem."
	dc.b	$C4

loc_1D90A:
	dc.b	"I'm sorry, I can't seem"
	dc.b	$C1
	dc.b	"to fix things right."
	dc.b	$C3
	dc.b	"Game ", $C0, " cannot be"
	dc.b	$C1
	dc.b	"played."
	dc.b	$C4

loc_1D950:
	dc.b	"Data check complete."
	dc.b	$C7
; ---------------------------------------------------------------------------------

	even

	if long_script_offsets
	even
	endif
Script_Opening:
	scriptofs	loc_1D96C, Script_Opening	; 1
	scriptofs	loc_1D9A0, loc_1D96C			; 2
	scriptofs	loc_1D9F4, loc_1D9A0			; 3
	scriptofs	loc_1DA54, loc_1D9F4			; 4
	scriptofs	loc_1DAAA, loc_1DA54			; 5
	scriptofs	loc_1DAFE, loc_1DAAA			; 6
	
loc_1D96C:
	dc.b	"This is the second"
	dc.b	$C1
	dc.b	"planet of the Algo"
	dc.b	$C1
	dc.b	"system, Mota."
	dc.b	$C7
	
loc_1D9A0:
	dc.b	"Over 1000 years have"
	dc.b	$C1
	dc.b	"passed since the evil"
	dc.b	$C1
	dc.b	"Lassic was defeated by"
	dc.b	$C1
	dc.b	"Alis and friends."
	dc.b	$C7
	
loc_1D9F4:
	dc.b	"Since that time, Algo"
	dc.b	$C1
	dc.b	"has prospered under the"
	dc.b	$C1
	dc.b	"care of a giant computer"
	dc.b	$C1
	dc.b	"called the Mother Brain."
	dc.b	$C7
	
loc_1DA54:
	dc.b	"The Mother Brain created"
	dc.b	$C1
	dc.b	"domed farms on the dry"
	dc.b	$C1
	dc.b	"world Mota, so that"
	dc.b	$C1
	dc.b	"crops would grow."
	dc.b	$C7
	
loc_1DAAA:
	dc.b	"But the people of the"
	dc.b	$C1
	dc.b	"Algo system perhaps"
	dc.b	$C1
	dc.b	"became soft in the long"
	dc.b	$C1
	dc.b	"years of peace", $47, $47, $47
	dc.b	$C7
	
loc_1DAFE:
	dc.b	"And now evil threatens"
	dc.b	$C1
	dc.b	"the system again! Who"
	dc.b	$C1
	dc.b	"will be able to unlock"
	dc.b	$C1
	dc.b	"Algo's fateful secret?"
	dc.b	$C7
; ---------------------------------------------------------------------------------

	even

	if long_script_offsets
	even
	endif
Script_GameStart:
	scriptofs	loc_1DB5E, Script_GameStart	; 1
	scriptofs	loc_1DB86, loc_1DB5E			; 2
	scriptofs	loc_1DC18, loc_1DB86			; 3
	scriptofs	loc_1DC47, loc_1DC18			; 4
	
loc_1DB5E:
	dc.b	"I am haunted by"
	dc.b	$C1
	dc.b	"nightmares every night."
	dc.b	$C5
	
loc_1DB86:
	dc.b	"A young girl is battling"
	dc.b	$C1
	dc.b	"a giant demon. I am"
	dc.b	$C1
	dc.b	"close by, but can't move"
	dc.b	$C1
	dc.b	"or speak! All I can do"
	dc.b	$C3	
	dc.b	"is watch while the demon"
	dc.b	$C1
	dc.b	"keeps striking at the"
	dc.b	$C1
	dc.b	"girl."
	dc.b	$C4
	
loc_1DC18:
	dc.b	"Just as she is fighting"
	dc.b	$C1	
	dc.b	"for her life, I awake!"
	dc.b	$C4 
	
loc_1DC47:
	dc.b	"I awake in my room,"
	dc.b	$C1	
	dc.b	"dimly lit by the early"
	dc.b	$C1	
	dc.b	"dawn. I am filled with"
	dc.b	$C1
	dc.b	"an incredible sadness"
	dc.b	$C3
	dc.b	"and fear. I am ", $BB, ", an"
	dc.b	$C1
	dc.b	"agent here in Paseo, the"
	dc.b	$C1	
	dc.b	"capital of Mota."
	dc.b	$C1
	dc.b	"I shake my head as if to"
	dc.b	$C3
	dc.b	"scatter the remnants of"
	dc.b	$C1
	dc.b	"the dream. I have no"
	dc.b	$C1
	dc.b	"time to worry like a"
	dc.b	$C1
	dc.b	"child about nightmares"
	dc.b	$C3
	dc.b	"in this modern age,"
	dc.b	$C1
	dc.b	"especially with the"
	dc.b	$C1
	dc.b	"Mother Brain planning"
	dc.b	$C1
	dc.b	"and controlling all"
	dc.b	$C3
	dc.b	"aspects of the"
	dc.b	$C1
	dc.b	"environment. I open my"
	dc.b	$C1
	dc.b	"window and take a deep"
	dc.b	$C1
	dc.b	"breath of fresh air."
	dc.b	$C3
	dc.b	"It seems to wash away"
	dc.b	$C1
	dc.b	"the bad feelings left by"
	dc.b	$C1
	dc.b	"my dream."
	dc.b	$C4
; ---------------------------------------------------------------------------------	
	
	even
	
	if long_script_offsets
	even
	endif
Script_People:
	scriptofs	loc_1DED0, Script_People	; 1
	scriptofs	loc_1DF05, loc_1DED0		; 2
	scriptofs	loc_1DF7E, loc_1DF05		; 3
	scriptofs	loc_1DFF6, loc_1DF7E		; 4
	scriptofs	loc_1E061, loc_1DFF6		; 5
	scriptofs	loc_1E0AE, loc_1E061		; 6
	scriptofs	loc_1E11A, loc_1E0AE		; 7
	scriptofs	loc_1E163, loc_1E11A		; 8
	scriptofs	loc_1E1AB, loc_1E163		; 9
	scriptofs	loc_1E1F5, loc_1E1AB		; $A
	scriptofs	loc_1E22E, loc_1E1F5		; $B
	scriptofs	loc_1E25D, loc_1E22E		; $C
	scriptofs	loc_1E299, loc_1E25D		; $D
	scriptofs	loc_1E2E3, loc_1E299		; $E
	scriptofs	loc_1E303, loc_1E2E3		; $F
	scriptofs	loc_1E32C, loc_1E303		; $10
	scriptofs	loc_1E387, loc_1E32C		; $11
	scriptofs	loc_1E3CE, loc_1E387		; $12
	scriptofs	loc_1E43C, loc_1E3CE		; $13
	scriptofs	loc_1E46D, loc_1E43C		; $14
	scriptofs	loc_1E4B7, loc_1E46D		; $15
	scriptofs	loc_1E4F1, loc_1E4B7		; $16
	scriptofs	loc_1E55E, loc_1E4F1		; $17
	scriptofs	loc_1E58A, loc_1E55E		; $18
	scriptofs	loc_1E5DE, loc_1E58A		; $19
	scriptofs	loc_1E62B, loc_1E5DE		; $1A
	scriptofs	loc_1E66E, loc_1E62B		; $1B
	scriptofs	loc_1E6C8, loc_1E66E		; $1C
	scriptofs	loc_1E728, loc_1E6C8		; $1D
	scriptofs	loc_1E783, loc_1E728		; $1E
	scriptofs	loc_1E7BA, loc_1E783		; $1F
	scriptofs	loc_1E817, loc_1E7BA		; $20
	scriptofs	loc_1E862, loc_1E817		; $21
	scriptofs	loc_1E89E, loc_1E862		; $22
	scriptofs	loc_1E8C9, loc_1E89E		; $23
	scriptofs	loc_1E927, loc_1E8C9		; $24
	scriptofs	loc_1E96C, loc_1E927		; $25
	scriptofs	loc_1E9B8, loc_1E96C		; $26
	scriptofs	loc_1EA0F, loc_1E9B8		; $27
	scriptofs	loc_1EA60, loc_1EA0F		; $28
	scriptofs	loc_1EA6F, loc_1EA60		; $29
	scriptofs	loc_1EA98, loc_1EA6F		; $2A
	scriptofs	loc_1EAE0, loc_1EA98		; $2B
	scriptofs	loc_1EB0B, loc_1EAE0		; $2C
	scriptofs	loc_1EB25, loc_1EB0B		; $2D
	scriptofs	loc_1EB4E, loc_1EB25		; $2E
	scriptofs	loc_1EB89, loc_1EB4E		; $2F
	scriptofs	loc_1EBF7, loc_1EB89		; $30
	scriptofs	loc_1EC1C, loc_1EBF7		; $31
	scriptofs	loc_1EC48, loc_1EC1C		; $32
	scriptofs	loc_1EC93, loc_1EC48		; $33
	scriptofs	loc_1ECD5, loc_1EC93		; $34
	scriptofs	loc_1ED29, loc_1ECD5		; $35
	scriptofs	loc_1ED36, loc_1ED29		; $36
	scriptofs	loc_1ED3C, loc_1ED36		; $37
	scriptofs	loc_1ED80, loc_1ED3C		; $38
	scriptofs	loc_1EDB6, loc_1ED80		; $39
	scriptofs	loc_1EDF6, loc_1EDB6		; $3A
	scriptofs	loc_1EE08, loc_1EDF6		; $3B
	scriptofs	loc_1EE5C, loc_1EE08		; $3C
	scriptofs	loc_1EEB0, loc_1EE5C		; $3D
	scriptofs	loc_1EF24, loc_1EEB0		; $3E
	scriptofs	loc_1EF60, loc_1EF24		; $3F
	scriptofs	loc_1EFB1, loc_1EF60		; $40
	scriptofs	loc_1EFD9, loc_1EFB1		; $41
	scriptofs	loc_1EFE9, loc_1EFD9		; $42
	scriptofs	loc_1F02A, loc_1EFE9		; $43
	scriptofs	loc_1F07C, loc_1F02A		; $44
	scriptofs	loc_1F0E6, loc_1F07C		; $45
	scriptofs	loc_1F136, loc_1F0E6		; $46
	scriptofs	loc_1F179, loc_1F136		; $47
	scriptofs	loc_1F1DF, loc_1F179		; $48
	scriptofs	loc_1F227, loc_1F1DF		; $49
	scriptofs	loc_1F273, loc_1F227		; $4A
	scriptofs	loc_1F2AF, loc_1F273		; $4B
	scriptofs	loc_1F2FF, loc_1F2AF		; $4C
	scriptofs	loc_1F337, loc_1F2FF		; $4D
	scriptofs	loc_1F385, loc_1F337		; $4E
	scriptofs	loc_1F3BE, loc_1F385		; $4F
	scriptofs	loc_1F406, loc_1F3BE		; $50
	scriptofs	loc_1F43B, loc_1F406		; $51
	scriptofs	loc_1F452, loc_1F43B		; $52
	scriptofs	loc_1F45F, loc_1F452		; $53
	scriptofs	loc_1F489, loc_1F45F		; $54
	scriptofs	loc_1F49C, loc_1F489		; $55
	scriptofs	loc_1F4CC, loc_1F49C		; $56
	scriptofs	loc_1F507, loc_1F4CC		; $57
	scriptofs	loc_1F53C, loc_1F507		; $58
	scriptofs	loc_1F548, loc_1F53C		; $59
	scriptofs	loc_1F55D, loc_1F548		; $5A
	scriptofs	loc_1F571, loc_1F55D		; $5B
	scriptofs	loc_1F58B, loc_1F571		; $5C
	scriptofs	loc_1F5BC, loc_1F58B		; $5D
	scriptofs	loc_1F5F6, loc_1F5BC		; $5E
	scriptofs	loc_1F628, loc_1F5F6		; $5F
	scriptofs	loc_1F690, loc_1F628		; $60
	scriptofs	loc_1F6E7, loc_1F690		; $61
	scriptofs	loc_1F732, loc_1F6E7		; $62
	scriptofs	loc_1F762, loc_1F732		; $63
	scriptofs	loc_1F7C8, loc_1F762		; $64
	scriptofs	loc_1F813, loc_1F7C8		; $65
	scriptofs	loc_1F82E, loc_1F813		; $66
	scriptofs	loc_1F87A, loc_1F82E		; $67
	scriptofs	loc_1F8BC, loc_1F87A		; $68
	scriptofs	loc_1F8E9, loc_1F8BC		; $69
	scriptofs	loc_1F92F, loc_1F8E9		; $6A
	scriptofs	loc_1F969, loc_1F92F		; $6B
	scriptofs	loc_1F99A, loc_1F969		; $6C
	scriptofs	loc_1F9AD, loc_1F99A		; $6D
	scriptofs	loc_1F9C8, loc_1F9AD		; $6E
	scriptofs	loc_1F9F6, loc_1F9C8		; $6F
	scriptofs	loc_1FA35, loc_1F9F6		; $70
	scriptofs	loc_1FA60, loc_1FA35		; $71
	scriptofs	loc_1FA9C, loc_1FA60		; $72
	scriptofs	loc_1FACD, loc_1FA9C		; $73
	scriptofs	loc_1FB1E, loc_1FACD		; $74
	scriptofs	loc_1FB3E, loc_1FB1E		; $75
	scriptofs	loc_1FB87, loc_1FB3E		; $76
	scriptofs	loc_1FBD6, loc_1FB87		; $77
	scriptofs	loc_1FBF7, loc_1FBD6		; $78
	scriptofs	loc_1FC0F, loc_1FBF7		; $79
	scriptofs	loc_1FC2D, loc_1FC0F		; $7A
	scriptofs	loc_1FC72, loc_1FC2D		; $7B
	scriptofs	loc_1FCCC, loc_1FC72		; $7C
	scriptofs	loc_1FCFF, loc_1FCCC		; $7D
	scriptofs	loc_1FD17, loc_1FCFF		; $7E
	scriptofs	loc_1FD3B, loc_1FD17		; $7F
	scriptofs	loc_1FD5D, loc_1FD3B		; $80
	scriptofs	loc_1FD91, loc_1FD5D		; $81
	scriptofs	loc_1FDC3, loc_1FD91		; $82
	scriptofs	loc_1FE21, loc_1FDC3		; $83
	scriptofs	loc_1FE53, loc_1FE21		; $84
	scriptofs	loc_1FE90, loc_1FE53		; $85
	scriptofs	loc_1FEE9, loc_1FE90		; $86
	scriptofs	loc_1FFA0, loc_1FEE9		; $87
	scriptofs	loc_1FFC9, loc_1FFA0		; $88
	scriptofs	loc_1FFEF, loc_1FFC9		; $89
	scriptofs	loc_2002F, loc_1FFEF		; $8A
	scriptofs	loc_2007B, loc_2002F		; $8B
	scriptofs	loc_200B5, loc_2007B		; $8C
	scriptofs	loc_200EE, loc_200B5		; $8D
	scriptofs	loc_20125, loc_200EE		; $8E
	scriptofs	loc_2014D, loc_20125		; $8F
	scriptofs	loc_2019E, loc_2014D		; $90
	scriptofs	loc_2026C, loc_2019E		; $91
	scriptofs	loc_20333, loc_2026C		; $92
	scriptofs	loc_203E0, loc_20333		; $93
	scriptofs	loc_2049E, loc_203E0		; $94
	scriptofs	loc_2057B, loc_2049E		; $95
	scriptofs	loc_20643, loc_2057B		; $96
	scriptofs	loc_20684, loc_20643		; $97
	scriptofs	loc_206B2, loc_20684		; $98
	scriptofs	loc_206EC, loc_206B2		; $99
	scriptofs	loc_20768, loc_206EC		; $9A
	scriptofs	loc_207B1, loc_20768		; $9B
	scriptofs	loc_207EE, loc_207B1		; $9C
	scriptofs	loc_20843, loc_207EE		; $9D
	scriptofs	loc_2089A, loc_20843		; $9E
	scriptofs	loc_208BB, loc_2089A		; $9F
	scriptofs	loc_20907, loc_208BB		; $A0
	scriptofs	loc_20942, loc_20907		; $A1
	scriptofs	loc_209AA, loc_20942		; $A2
	
; no idea why this guy says a line talking about Central Tower. In the Japanese version he says: "This is Paseo, the largest city on Motavia"
; He doesn't say it using a fully structured Japanese sentence, meaning he leaves out particles and whatnot...
loc_1DED0:
	dc.b	"This is Central Tower"
	dc.b	$C1
	dc.b	"in Paseo, the capital"
	dc.b	$C1							; should be $C3
	dc.b	"of Mota."
	dc.b	$C4
	
loc_1DF05:
	dc.b	"Maybe you should go back"
	dc.b	$C1
	dc.b	"home, when you get to a"
	dc.b	$C3
	dc.b	"strange town. There"
	dc.b	$C1
	dc.b	"might be someone strange"
	dc.b	$C3
	dc.b	"who comes looking for"
	dc.b	$C1
	dc.b	"you."
	dc.b	$C4

loc_1DF7E:
	dc.b	"Well, well, you are"
	dc.b	$C1
	dc.b	"armed and look so brave."
	dc.b	$C3
	dc.b	"But, if you don't keep"
	dc.b	$C1
	dc.b	"your weapons in good"
	dc.b	$C3
	dc.b	"shape, they are worth"
	dc.b	$C1
	dc.b	"nothing."
	dc.b	$C4

loc_1DFF6:
	dc.b	"If there's something you"
	dc.b	$C1
	dc.b	"would like to know about"
	dc.b	$C3
	dc.b	"Mota, you should go"
	dc.b	$C1
	dc.b	"to the library at the"
	dc.b	$C3
	dc.b	"Central Tower."
	dc.b	$C4
	
loc_1E061:
	dc.b	"I used to work at the"
	dc.b	$C1
	dc.b	"Biosystems Lab which is"
	dc.b	$C3
	dc.b	"on the other side of the"
	dc.b	$C1
	dc.b	"lake."
	dc.b	$C4

loc_1E0AE:
	dc.b	"Do not get close to the"
	dc.b	$C1
	dc.b	"bridge on the north"
	dc.b	$C3
	dc.b	"river. Many people have"
	dc.b	$C1
	dc.b	"been killed there by"
	dc.b	$C3
	dc.b	"a man named Darum."
	dc.b	$C4
	
loc_1E11A:
	dc.b	"If you have money, you"
	dc.b	$C1
	dc.b	"can always get your body"
	dc.b	$C3
	dc.b	"cloned at the clone"
	dc.b	$C1
	dc.b	"lab."
	dc.b	$C4

loc_1E163:
	dc.b	"From now on, women"
	dc.b	$C1
	dc.b	"should be armed and"
	dc.b	$C3
	dc.b	"should fight! I believe"
	dc.b	$C1
	dc.b	"in that!"
	dc.b	$C4

loc_1E1AB:
	dc.b	"Hunters are the coolest"
	dc.b	$C1
	dc.b	"guys. They really are"
	dc.b	$C3
	dc.b	"strong and so depend-"
	dc.b	$C1
	dc.b	"able!"
	dc.b	$C4

loc_1E1F5:
	dc.b	"This town is peaceful."
	dc.b	$C1
	dc.b	"I'm glad I moved here"
	dc.b	$C3
	dc.b	"from Arima."
	dc.b	$C4

loc_1E22E:
	dc.b	"Thanks to the Biosystems"
	dc.b	$C1
	dc.b	"Lab, Mota flourished."
	dc.b	$C4

loc_1E25D:
	dc.b	"It hasn't rained at"
	dc.b	$C1
	dc.b	"all for awhile. The"
	dc.b	$C3
	dc.b	"lake even dried up."
	dc.b	$C4

loc_1E299:
	dc.b	"My dad is just goofing"
	dc.b	$C1	
	dc.b	"off everyday."
	dc.b	$C3
	dc.b	"He says he can live"
	dc.b	$C1
	dc.b	"without working."
	dc.b	$C4

loc_1E2E3:
	dc.b	"Why should I work for"
	dc.b	$C1
	dc.b	"a living?"
	dc.b	$C4

loc_1E303:
	dc.b	"When I grow up, I'm"
	dc.b	$C1
	dc.b	"going to be a Thief."
	dc.b	$C4

loc_1E32C:
	dc.b	"They say that if you go"
	dc.b	$C1
	dc.b	"to the north bridge, a"
	dc.b	$C3
	dc.b	"guy named Darum will"
	dc.b	$C1
	dc.b	"rob you of your money."
	dc.b	$C4

loc_1E387:
	dc.b	"Why in the world did"
	dc.b	$C1
	dc.b	"you come to Arima?"
	dc.b	$C3
	dc.b	"This is such a horrible"
	dc.b	$C1
	dc.b	"place!"
	dc.b	$C4

loc_1E3CE:
	dc.b	"If only those scoundrels"
	dc.b	$C1	
	dc.b	"hadn't come to this"
	dc.b	$C3	
	dc.b	"town, Darum and his"
	dc.b	$C1
	dc.b	"daughter Teim could have"
	dc.b	$C3
	dc.b	"lived a happy life."
	dc.b	$C4

loc_1E43C:
	dc.b	"What's most frightening"
	dc.b	$C1
	dc.b	"is humans, not monsters."
	dc.b	$C4

loc_1E46D:
	dc.b	"This town has been wiped"
	dc.b	$C1
	dc.b	"out by the scoundrels,"
	dc.b	$C3
	dc.b	"and there's nothing"
	dc.b	$C1
	dc.b	"left."
	dc.b	$C4

loc_1E4B7:
	dc.b	"Those scoundrels blew up"
	dc.b	$C1
	dc.b	"everyone's houses"
	dc.b	$C3
	dc.b	"with dynamite!"
	dc.b	$C4

loc_1E4F1:
	dc.b	"The scoundrels must"
	dc.b	$C1
	dc.b	"have two more dynamite"		; how does he know that? :D
	dc.b	$C3
	dc.b	"sticks. Unless we take"
	dc.b	$C1
	dc.b	"them away, another town"
	dc.b	$C3
	dc.b	"will be destroyed."
	dc.b	$C4

loc_1E55E:
	dc.b	"Those scoundrels always"
	dc.b	$C1
	dc.b	"come from the east."
	dc.b	$C4

loc_1E58A:
	dc.b	"The scoundrels stole all"
	dc.b	$C1
	dc.b	"the food, killed all the"
	dc.b	$C3
	dc.b	"men, and kidnapped all"
	dc.b	$C1
	dc.b	"the women."
	dc.b	$C4

loc_1E5DE:
	dc.b	"Those who are left here"
	dc.b	$C1
	dc.b	"are just the powerless,"
	dc.b	$C3
	dc.b	"who are only waiting to"
	dc.b	$C1
	dc.b	"die."
	dc.b	$C4

loc_1E62B:
	dc.b	"I know! The hideout of"
	dc.b	$C1
	dc.b	"those scoundrels is at"
	dc.b	$C3
	dc.b	"a building in Shure."
	dc.b	$C4

loc_1E66E:
	dc.b	"I hear that those bad"
	dc.b	$C1	
	dc.b	"guys are very cautious,"
	dc.b	$C3
	dc.b	"and keep their stuff in"
	dc.b	$C1
	dc.b	"a locked container."
	dc.b	$C4

loc_1E6C8:
	dc.b	"Darum is not a bad guy!"
	dc.b	$C1
	dc.b	"The reason he became"
	dc.b	$C3	
	dc.b	"violent is that his"
	dc.b	$C1	
	dc.b	"daughter, Teim, was"
	dc.b	$C3
	dc.b	"kidnapped!"
	dc.b	$C4

loc_1E728:
	dc.b	"This town is called"
	dc.b	$C1
	dc.b	"Opta. The Biosystems"
	dc.b	$C3
	dc.b	"Lab is located in the"
	dc.b	$C1
	dc.b	"southern part of this"
	dc.b	$C3
	dc.b	"town."
	dc.b	$C4

loc_1E783:
	dc.b	"The Biosystems Lab"
	dc.b	$C1
	dc.b	"created the monsters?"
	dc.b	$C3
	dc.b	"That's a lie."
	dc.b	$C4

loc_1E7BA:
	dc.b	"The Biosystems Lab had"
	dc.b	$C1
	dc.b	"been creating plants"
	dc.b	$C3
	dc.b	"which grow well even in"
	dc.b	$C1
	dc.b	"a land with little rain."
	dc.b	$C4

loc_1E817:
	dc.b	"The Biosystems Lab is"
	dc.b	$C1
	dc.b	"controlled by Mother"
	dc.b	$C3
	dc.b	"Brain. It cannot make"
	dc.b	$C1
	dc.b	"mistakes!"
	dc.b	$C4

loc_1E862:
	dc.b	"STAR MIST cures your"
	dc.b	$C1
	dc.b	"scars, and MOON DEW"
	dc.b	$C3
	dc.b	"revives your soul."
	dc.b	$C4

loc_1E89E:
	dc.b	"Oh, glorious"
	dc.b	$C1
	dc.b	"Mother Brain!"
	dc.b	$C3
	dc.b	"Please save us!"
	dc.b	$C4

loc_1E8C9:
	dc.b	"Even if those monsters"
	dc.b	$C1
	dc.b	"are gone, Mota has"		; continuity error here... The monsters are still around since this dialogue pops up before you finish Climatrol, so that "are" is supposed to be "were"
	dc.b	$C3
	dc.b	"already been devastated."
	dc.b	$C1
	dc.b	"There's nothing we can"
	dc.b	$C3	
	dc.b	"do."
	dc.b	$C4

loc_1E927:
	dc.b	"Say, have you heard of"
	dc.b	$C1
	dc.b	"STAR MIST and MOON DEW?"
	dc.b	$C3
	dc.b	"They smell very good."
	dc.b	$C4

loc_1E96C:
	dc.b	"I want to be a musician."
	dc.b	$C1
	dc.b	"I heard that there's a"
	dc.b	$C3
	dc.b	"piano teacher in this"
	dc.b	$C1	
	dc.b	"town."
	dc.b	$C4

loc_1E9B8:
	dc.b	"The hole in the middle"
	dc.b	$C1
	dc.b	"of the Biosystems Lab"
	dc.b	$C3
	dc.b	"building leads to that"
	dc.b	$C1
	dc.b	"horrible basement."
	dc.b	$C4

loc_1EA0F:
	dc.b	"In the basement of the"
	dc.b	$C1
	dc.b	"Biosystems Lab, I hear"
	dc.b	$C3
	dc.b	"there is something most"
	dc.b	$C1
	dc.b	"important."
	dc.b	$C4

loc_1EA60:
	dc.b	"I feel hungry."
	dc.b	$C4

loc_1EA6F:
	dc.b	"I wonder when peace will"
	dc.b	$C1
	dc.b	"return to Mota?"
	dc.b	$C4

loc_1EA98:
	dc.b	"People of Algo are"
	dc.b	$C1	
	dc.b	"hungry all the time"
	dc.b	$C3
	dc.b	"because they can't"
	dc.b	$C1
	dc.b	"eat anything."
	dc.b	$C4

loc_1EAE0:
	dc.b	"We eat anything when we"
	dc.b	$C1
	dc.b	"get really hungry."
	dc.b	$C4

loc_1EB0B:
	dc.b	"Hey, what's"
	dc.b	$C1
	dc.b	"Mother Brain?"
	dc.b	$C4

loc_1EB25:
	dc.b	"This is Zema, a resort"
	dc.b	$C1
	dc.b	"town by the lake."
	dc.b	$C4

loc_1EB4E:
	dc.b	"I remember seeing"
	dc.b	$C1
	dc.b	"Mota people playing on"
	dc.b	$C3
	dc.b	"a mobile machine."
	dc.b	$C4

loc_1EB89:
	dc.b	"Have you been to the"
	dc.b	$C1
	dc.b	"southern peninsula?"
	dc.b	$C3
	dc.b	"That area smells ter-"
	dc.b	$C1
	dc.b	"rible because of the"
	dc.b	$C3
	dc.b	"garbage smell from"
	dc.b	$C1
	dc.b	"Roron."
	dc.b	$C4

loc_1EBF7:
	dc.b	"Mota people make"
	dc.b	$C1
	dc.b	"anything from junk."
	dc.b	$C4

loc_1EC1C:
	dc.b	"Mota people love the"
	dc.b	$C1
	dc.b	"garbage dump in Roron."
	dc.b	$C4

loc_1EC48:
	dc.b	"Around the middle of the"
	dc.b	$C1
	dc.b	"lake, there's a tower"
	dc.b	$C3
	dc.b	"where nobody has ever"
	dc.b	$C1
	dc.b	"been."
	dc.b	$C4

loc_1EC93:
	dc.b	"We used to play in the"
	dc.b	$C1
	dc.b	"ocean on a jet scooter"
	dc.b	$C3
	dc.b	"when we were young."
	dc.b	$C4

loc_1ECD5:
	dc.b	"People stopped using"
	dc.b	$C1
	dc.b	"any mobile machines"
	dc.b	$C3
	dc.b	"after the teleport"
	dc.b	$C1
	dc.b	"service was introduced."
	dc.b	$C4

loc_1ED29:
	dc.b	"What the", $47, $47, $47, "?"
	dc.b	$C4

loc_1ED36:
	dc.b	"What?"
	dc.b	$C4

loc_1ED3C:
	dc.b	"The ancestors of the"
	dc.b	$C1
	dc.b	"people in this town"
	dc.b	$C3	
	dc.b	"used to work in the"
	dc.b	$C1
	dc.b	"ocean."
	dc.b	$C4

loc_1ED80:
	dc.b	"In this town, there are"
	dc.b	$C1
	dc.b	"many stories about the"
	dc.b	$C3
	dc.b	"ocean."
	dc.b	$C4

loc_1EDB6:
	dc.b	"They say the ocean and"
	dc.b	$C1
	dc.b	"the lake are connected"
	dc.b	$C3
	dc.b	"under the ground."
	dc.b	$C4

loc_1EDF6:
	dc.b	"Welcome to Kueri."
	dc.b	$C4

loc_1EE08:
	dc.b	"They say people in the"
	dc.b	$C1
	dc.b	"old days used to eat"
	dc.b	$C3
	dc.b	"something before going"
	dc.b	$C1
	dc.b	"under the ocean."
	dc.b	$C4

loc_1EE5C:
	dc.b	"My boy friend lives on"
	dc.b	$C1
	dc.b	"the outskirts of the"
	dc.b	$C3
	dc.b	"town, so that nobody"
	dc.b	$C1
	dc.b	"disturbs his work."
	dc.b	$C4

loc_1EEB0:
	dc.b	"In the places where the"
	dc.b	$C1
	dc.b	"color of the water is"
	dc.b	$C3
	dc.b	"different in the ocean,"
	dc.b	$C1
	dc.b	"they say it's because of"
	dc.b	$C3
	dc.b	"water from the lake."
	dc.b	$C4

loc_1EF24:
	dc.b	"I remember there was a"
	dc.b	$C1
	dc.b	"rocky island named Uzo"
	dc.b	$C3	
	dc.b	"in the ocean."
	dc.b	$C4
	
loc_1EF60:
	dc.b	"It was 50 years ago when"
	dc.b	$C1
	dc.b	"Mother Brain prohibited"
	dc.b	$C3
	dc.b	"people from going to"
	dc.b	$C1
	dc.b	"the ocean."
	dc.b	$C4

loc_1EFB1:
	dc.b	"Hey, have you met our"
	dc.b	$C1
	dc.b	"friends in Roron?"
	dc.b	$C4

loc_1EFD9:
	dc.b	"Oh, no! Humans!"
	dc.b	$C4

loc_1EFE9:
	dc.b	"Did you know that it is"
	dc.b	$C1
	dc.b	"impossible to travel to"
	dc.b	$C3
	dc.b	"outer space now?"
	dc.b	$C4

loc_1F02A:
	dc.b	"After the accident of"
	dc.b	$C1
	dc.b	"10 years ago, the use"
	dc.b	$C3
	dc.b	"of any spaceship has"
	dc.b	$C1
	dc.b	"been prohibited."
	dc.b	$C4

loc_1F07C:
	dc.b	"There used to be space-"
	dc.b	$C1
	dc.b	"ships taking off for"
	dc.b	$C3
	dc.b	"Palm and Dezo one"
	dc.b	$C1
	dc.b	"after another, when"
	dc.b	$C3
	dc.b	"there was a spaceport."
	dc.b	$C4

loc_1F0E6:
	dc.b	"I wanted to be a pilot,"
	dc.b	$C1
	dc.b	"but I guess I can't be"
	dc.b	$C3
	dc.b	"one since there is no"
	dc.b	$C1
	dc.b	"spaceship."
	dc.b	$C4

loc_1F136:
	dc.b	"This town is called"
	dc.b	$C1	
	dc.b	"Piata. There used to"
	dc.b	$C3
	dc.b	"be a spaceport near"
	dc.b	$C1
	dc.b	"here."
	dc.b	$C4

loc_1F179:
	dc.b	"When people refer to the"
	dc.b	$C1	
	dc.b	"accident of 10 years"
	dc.b	$C3	
	dc.b	"ago, they mean the col-"
	dc.b	$C1
	dc.b	"lision of spaceships"
	dc.b	$C3
	dc.b	"over Dezo."
	dc.b	$C4

loc_1F1DF:
	dc.b	"They say a number of"
	dc.b	$C1
	dc.b	"people got killed in the"
	dc.b	$C3
	dc.b	"accident of 10 years"
	dc.b	$C1
	dc.b	"ago."
	dc.b	$C4

loc_1F227:
	dc.b	"Everyone used to believe"
	dc.b	$C1	
	dc.b	"that travelling in space"
	dc.b	$C3
	dc.b	"was not dangerous at"
	dc.b	$C1
	dc.b	"all."
	dc.b	$C4

loc_1F273:
	dc.b	"The last spaceship was"
	dc.b	$C1
	dc.b	"headed toward the out-"
	dc.b	$C3
	dc.b	"side of Algo."
	dc.b	$C4
	
loc_1F2AF:
	dc.b	"People used to dream of"
	dc.b	$C1
	dc.b	"travelling outside Algo."
	dc.b	$C3
	dc.b	"But now it just can't"
	dc.b	$C1
	dc.b	"be done."
	dc.b	$C4

loc_1F2FF:
	dc.b	"I hear nobody survived"
	dc.b	$C1
	dc.b	"in the accident of 10"
	dc.b	$C3
	dc.b	"years ago."
	dc.b	$C4

loc_1F337:
	dc.b	$BB, ",", $47, $47, $47, "I may have seen"
	dc.b	$C1
	dc.b	"such a name on the"
	dc.b	$C3
	dc.b	"boarding list of that"
	dc.b	$C1
	dc.b	"last spaceship."
	dc.b	$C4

loc_1F385:
	dc.b	"Hey, what's outside"
	dc.b	$C1
	dc.b	"of Algo? How come"
	dc.b	$C3
	dc.b	"we can't go there?"
	dc.b	$C4

loc_1F3BE:
	dc.b	"Mother Brain is watching"
	dc.b	$C1
	dc.b	"over us, right? Then,"
	dc.b	$C3
	dc.b	"why do accidents happen?"
	dc.b	$C4

loc_1F406:
	dc.b	"I heard that there are"
	dc.b	$C1
	dc.b	"all kinds of arms in the"
	dc.b	$C3
	dc.b	"dam."
	dc.b	$C4

loc_1F43B:
	dc.b	"Ga? dote-mew? banaput?"
	dc.b	$C4

loc_1F452:
	dc.b	"Mew! Meeyaw!"
	dc.b	$C4

loc_1F45F:
	dc.b	"We are Dezo people. The"
	dc.b	$C1
	dc.b	"best men in Algo."
	dc.b	$C4

loc_1F489:
	dc.b	"We don't ever lie!"
	dc.b	$C4

loc_1F49C:
	dc.b	"There isn't anyboby"		; TYPO ALERT!!!
	dc.b	$C1
	dc.b	"else but us on this"
	dc.b	$C3
	dc.b	"planet."
	dc.b	$C4

loc_1F4CC:
	dc.b	"Staying too long on this"
	dc.b	$C1
	dc.b	"planet makes everyone's"
	dc.b	$C3	
	dc.b	"body rot."
	dc.b	$C4

loc_1F507:
	dc.b	"The truth is, the clone"
	dc.b	$C1	
	dc.b	"lab Grandma is really"
	dc.b	$C3
	dc.b	"a man."
	dc.b	$C4

loc_1F53C:
	dc.b	"You weirdo!"
	dc.b	$C4

loc_1F548:
	dc.b	"I hate you! Go away!"
	dc.b	$C4

loc_1F55D:
	dc.b	"I'm gonna bite you!"
	dc.b	$C4

loc_1F571:
	dc.b	"This town is called"
	dc.b	$C1
	dc.b	"Zosa."
	dc.b	$C4
	
loc_1F58B:
	dc.b	"It's best to live lazily"
	dc.b	$C1
	dc.b	"with hunting like this."
	dc.b	$C4

loc_1F5BC:
	dc.b	"We are living in the"
	dc.b	$C1
	dc.b	"town that the Palm"
	dc.b	$C3
	dc.b	"people abandoned."
	dc.b	$C4

loc_1F5F6:
	dc.b	"Hey, you don't look"
	dc.b	$C1
	dc.b	"familiar. Where are you"
	dc.b	$C3
	dc.b	"from?"
	dc.b	$C4

loc_1F628:
	dc.b	"The reason the accident"
	dc.b	$C1
	dc.b	"happened on the day of"
	dc.b	$C3
	dc.b	"a solar eclipse was"
	dc.b	$C1
	dc.b	"because the Palm people"
	dc.b	$C3
	dc.b	"didn't pray."
	dc.b	$C4

loc_1F690:
	dc.b	"The Palm people were"
	dc.b	$C1
	dc.b	"punished because they"
	dc.b	$C3
	dc.b	"didn't take good care"
	dc.b	$C1
	dc.b	"of the eclipse-torch."
	dc.b	$C4

loc_1F6E7:
	dc.b	"The Palm people were"
	dc.b	$C1
	dc.b	"afraid of poison gas,"
	dc.b	$C3
	dc.b	"but it can't do anything"
	dc.b	$C1
	dc.b	"to us."
	dc.b	$C4

loc_1F732:
	dc.b	"We've got such tough"
	dc.b	$C1
	dc.b	"bodies!"
	dc.b	$C3
	dc.b	"It's unbelievable!"
	dc.b	$C4
	
loc_1F762:
	dc.b	"It's such a surprise to"
	dc.b	$C1
	dc.b	"see a human other than"
	dc.b	$C3
	dc.b	"the clone lab Grandma!"
	dc.b	$C1	
	dc.b	"Everybody left three"
	dc.b	$C3
	dc.b	"years ago."
	dc.b	$C4
	
loc_1F7C8:
	dc.b	"When I went to the other"
	dc.b	$C1
	dc.b	"side of the crevice, I"
	dc.b	$C3
	dc.b	"saw a beautiful man"
	dc.b	$C1
	dc.b	"there."
	dc.b	$C4
	
loc_1F813:
	dc.b	"This town is called"
	dc.b	$C1
	dc.b	"Aukba."
	dc.b	$C4
	
loc_1F82E:
	dc.b	"Long dern time ago, I"
	dc.b	$C1
	dc.b	"heard that someone run"
	dc.b	$C3
	dc.b	"away from Palm to this"
	dc.b	$C1
	dc.b	"planet."
	dc.b	$C4
	
loc_1F87A:
	dc.b	"They say people who are"
	dc.b	$C1
	dc.b	"hiding on this planet"
	dc.b	$C3
	dc.b	"have strange power."
	dc.b	$C4
	
loc_1F8BC:
	dc.b	"Hey, you,", $47, $47, $47, "you came"
	dc.b	$C1
	dc.b	"over from that crevice?"
	dc.b	$C4
	
loc_1F8E9:
	dc.b	"Dezo is all ours. We"
	dc.b	$C1
	dc.b	"feel so dern better"
	dc.b	$C3
	dc.b	"that those Palm people"
	dc.b	$C1
	dc.b	"left."
	dc.b	$C4
	
loc_1F92F:
	dc.b	"I wonder why that guy,"
	dc.b	$C1	
	dc.b	"hiding on this planet,"
	dc.b	$C3	
	dc.b	"never ages?"
	dc.b	$C4
	
loc_1F969:
	dc.b	"We ain't gonna leave"
	dc.b	$C1
	dc.b	"this planet no matter"
	dc.b	$C3
	dc.b	"what!"
	dc.b	$C4
	
loc_1F99A:
	dc.b	"We hate computers!"
	dc.b	$C4

loc_1F9AD:
	dc.b	"This town is called"
	dc.b	$C1
	dc.b	"Ryuon."
	dc.b	$C4

loc_1F9C8:
	dc.b	"The Palm people came to"
	dc.b	$C1
	dc.b	"Dezo to mine Laconia."
	dc.b	$C4

loc_1F9F6:
	dc.b	"The Grandma of the clone"
	dc.b	$C1
	dc.b	"lab stayed here because"
	dc.b	$C3
	dc.b	"she likes us."
	dc.b	$C4

loc_1FA35:
	dc.b	"I heard the poison gas"
	dc.b	$C1	
	dc.b	"came from the mine."
	dc.b	$C4

loc_1FA60:
	dc.b	"I saw two spaceships"
	dc.b	$C1
	dc.b	"crashing into each other"
	dc.b	$C3
	dc.b	"10 years ago."
	dc.b	$C4

loc_1FA9C:
	dc.b	"Do people in Mota"
	dc.b	$C1
	dc.b	"still believe in Mother"
	dc.b	$C3
	dc.b	"Brain?"
	dc.b	$C4

loc_1FACD:
	dc.b	"If people keep depending"
	dc.b	$C1
	dc.b	"on Mother Brain, they"
	dc.b	$C3
	dc.b	"are going to just come"
	dc.b	$C1
	dc.b	"to an end."
	dc.b	$C4

loc_1FB1E:
	dc.b	"We don't trust no Mother"
	dc.b	$C1
	dc.b	"Brain."
	dc.b	$C4

loc_1FB3E:
	dc.b	"Can such a building"
	dc.b	$C1
	dc.b	"exist? It's there, but"
	dc.b	$C3
	dc.b	"you can't see it or"
	dc.b	$C1
	dc.b	"touch it?"
	dc.b	$C4

loc_1FB87:
	dc.b	"I don't like no Palm"
	dc.b	$C1
	dc.b	"people. I'd say it's"
	dc.b	$C3
	dc.b	"bad to make a big hole"
	dc.b	$C1
	dc.b	"on my planet."
	dc.b	$C4

loc_1FBD6:
	dc.b	$47, $47, $47, "ooops, I fell asleep"
	dc.b	$C1
	dc.b	"walking."
	dc.b	$C4

loc_1FBF7:
	dc.b	"It's so dern hot today."
	dc.b	$C4

loc_1FC0F:
	dc.b	"We used to be kept by"
	dc.b	$C1
	dc.b	"humans."
	dc.b	$C4

loc_1FC2D:
	dc.b	"Most people working in"
	dc.b	$C1
	dc.b	"Dezo were away from"
	dc.b	$C3	
	dc.b	"their families back"
	dc.b	$C1
	dc.b	"home."
	dc.b	$C4

loc_1FC72:
	dc.b	"Those pets left behind"
	dc.b	$C1
	dc.b	"on this planet changed"
	dc.b	$C3
	dc.b	"into different forms"
	dc.b	$C1
	dc.b	"due to the poison gas."
	dc.b	$C4

loc_1FCCC:
	dc.b	"When humans left this"
	dc.b	$C1
	dc.b	"planet, they left us"
	dc.b	$C3
	dc.b	"behind."
	dc.b	$C4

loc_1FCFF:
	dc.b	"Feed me! I'm so hungry."
	dc.b	$C4

loc_1FD17:
	dc.b	"Hmm", $47, $47, $47, " I love the smell"
	dc.b	$C1
	dc.b	"of garbage."
	dc.b	$C4

loc_1FD3B:
	dc.b	"Hmm", $47, $47, $47, " I love"
	dc.b	$C1
	dc.b	"collecting garbage."
	dc.b	$C4

loc_1FD5D:
	dc.b	"I wonder what kind of"
	dc.b	$C1
	dc.b	"garbage I'm gonna find"
	dc.b	$C3
	dc.b	"today?"
	dc.b	$C4

loc_1FD91:
	dc.b	"Hey! I found some tasty"
	dc.b	$C1
	dc.b	"cake! Won't you try"
	dc.b	$C3
	dc.b	"some?"
	dc.b	$C5

loc_1FDC3:
	dc.b	$BB, " and the others ate"
	dc.b	$C1
	dc.b	"the cake. It tasted"
	dc.b	$C3
	dc.b	"funny! Their stomachs"
	dc.b	$C1
	dc.b	"started making strange"
	dc.b	$C3
	dc.b	"sounds."
	dc.b	$C4

loc_1FE21:
	dc.b	$BB, " and the others"
	dc.b	$C1		
	dc.b	"respectfully declined"
	dc.b	$C3
	dc.b	"the offer."
	dc.b	$C4

loc_1FE53:
	dc.b	"Hey look! I made this"
	dc.b	$C1
	dc.b	"jet scooter. It's"
	dc.b	$C3
	dc.b	"something, isn't it?"
	dc.b	$C4

loc_1FE90:
	dc.b	"I think I'm gonna try"
	dc.b	$C1
	dc.b	"and ride this over the"
	dc.b	$C3
	dc.b	"ocean. If you like, you"
	dc.b	$C1
	dc.b	"can come and watch."
	dc.b	$C4

loc_1FEE9:
	dc.b	"Hmm", $47, $47, $47, ",I wonder where"
	dc.b	$C1
	dc.b	"those Mota people went."
	dc.b	$C3
	dc.b	"Ah-ha! There's a note"
	dc.b	$C1
	dc.b	"attached! \IWe love"
	dc.b	$C3	
	dc.b	"going through garbage"
	dc.b	$C1
	dc.b	"itself. So, we don't"
	dc.b	$C3
	dc.b	"need this. Anyone can"
	dc.b	$C1
	dc.b	"have it.\I Hey, how"
	dc.b	$C3
	dc.b	"lucky I am!"
	dc.b	$C4

loc_1FFA0:
	dc.b	"You must be ", $BB, "."
	dc.b	$C1
	dc.b	"We've been expecting"
	dc.b	$C3
	dc.b	"you."
	dc.b	$C4
	
loc_1FFC9:
	dc.b	"You are not ", $BB, ","
	dc.b	$C1
	dc.b	"are you? Please leave."
	dc.b	$C4

loc_1FFEF:
	dc.b	"The glorious man who"
	dc.b	$C1
	dc.b	"used to fight to save"
	dc.b	$C3
	dc.b	"Algo is buried here."
	dc.b	$C4

loc_2002F:
	dc.b	"This man was put into"
	dc.b	$C1
	dc.b	"cold-sleep in order to"
	dc.b	$C3
	dc.b	"watch over the future"
	dc.b	$C1
	dc.b	"of Algo."
	dc.b	$C4

loc_2007B:
	dc.b	"When Mother Brain came,"
	dc.b	$C1
	dc.b	"this man decided to hide"
	dc.b	$C3
	dc.b	"in Dezo."
	dc.b	$C4

loc_200B5:
	dc.b	"We have been working for"
	dc.b	$C1	
	dc.b	"him since many"
	dc.b	$C3
	dc.b	"generations ago."
	dc.b	$C4

loc_200EE:
	dc.b	"This man told us that"
	dc.b	$C1
	dc.b	"he would awaken when"
	dc.b	$C3
	dc.b	"you arrive."
	dc.b	$C4

loc_20125:
	dc.b	"This man wakes up once"
	dc.b	$C1
	dc.b	"every ten years."
	dc.b	$C4

loc_2014D:
	dc.b	"Before the dark power"
	dc.b	$C1
	dc.b	"reigns over Algo, we"
	dc.b	$C3
	dc.b	"must get the legendary"
	dc.b	$C1
	dc.b	"arms together."
	dc.b	$C4

loc_2019E:
	dc.b	"Good job! You are"
	dc.b	$C1
	dc.b	"truly a descendant of"
	dc.b	$C3
	dc.b	"Alis. I acknowledge that"
	dc.b	$C1
	dc.b	"you are qualified to"
	dc.b	$C3
	dc.b	"succeed the power of"
	dc.b	$C1
	dc.b	"light and the memory of"
	dc.b	$C3
	dc.b	"darkness."
	dc.b	$C1
	dc.b	"One thousand years ago,"
	dc.b	$C3
	dc.b	"after the battles of"
	dc.b	$C1
	dc.b	"Alis, Algo obtained"
	dc.b	$C3

loc_2026C:
	dc.b	"peace for a short while."
	dc.b	$C1
	dc.b	"People were satisfied"
	dc.b	$C3
	dc.b	"with what was given to"
	dc.b	$C1
	dc.b	"them by those they"
	dc.b	$C3
	dc.b	"loved, and did not ask"
	dc.b	$C1
	dc.b	"for more. And it was"
	dc.b	$C3
	dc.b	"their pleasure to give"
	dc.b	$C1
	dc.b	"to their loved ones more"
	dc.b	$C3
	dc.b	"than they wanted."
	dc.b	$C1
	
loc_20333:
	dc.b	"However, when Mother"
	dc.b	$C3
	dc.b	"Brain arrived, Algo"
	dc.b	$C1
	dc.b	"changed. We got confused"
	dc.b	$C3
	dc.b	"because Mother Brain"
	dc.b	$C1
	dc.b	"created so many things,"
	dc.b	$C3
	dc.b	"we didn't really know"
	dc.b	$C1
	dc.b	"what we needed."
	dc.b	$C3
	dc.b	"People started to fight"
	dc.b	$C1
	
loc_203E0:
	dc.b	"for what Mother Brain"
	dc.b	$C3
	dc.b	"created. They no longer"
	dc.b	$C1
	dc.b	"thought that kindly"
	dc.b	$C3
	dc.b	"about Alis. People even"
	dc.b	$C1
	dc.b	"thought that they could"
	dc.b	$C3
	dc.b	"not live without"
	dc.b	$C1
	dc.b	"Mother Brain."
	dc.b	$C3
	dc.b	"I think that a devil's"
	dc.b	$C1
	dc.b	"trap is behind Mother"
	dc.b	$C3

loc_2049E:
	dc.b	"Brain. This caused the"
	dc.b	$C1
	dc.b	"people's mind to weaken."
	dc.b	$C3
	dc.b	"The trap also leads Algo"
	dc.b	$C1
	dc.b	"to destruction."
	dc.b	$C3
	dc.b	"I don't know who made"
	dc.b	$C1
	dc.b	"the trap, or why. There"
	dc.b	$C3
	dc.b	"is a Neisword in the"
	dc.b	$C1	
	dc.b	"box. When you pick it"
	dc.b	$C3
	dc.b	"up, it will rescue you"
	dc.b	$C1
	dc.b	"from the evil side."
	dc.b	$C4

loc_2057B:
	dc.b	"I will leave the future"
	dc.b	$C1
	dc.b	"of Algo up to you. I"
	dc.b	$C3
	dc.b	"pray for your safety."
	dc.b	$C1
	dc.b	"Use the Neisword if you"
	dc.b	$C3
	dc.b	"run out of power. It"
	dc.b	$C1
	dc.b	"will bring you back here"
	dc.b	$C3
	dc.b	"right away! Now go to"
	dc.b	$C1
	dc.b	"those who watch us"
	dc.b	$C3
	dc.b	"from outside of Algo."
	dc.b	$C4
	
loc_20643:
	dc.b	"Good grief! We now have"
	dc.b	$C1
	dc.b	"to worry about the lake"
	dc.b	$C3
	dc.b	"getting flooded."
	dc.b	$C4

loc_20684:
	dc.b	"Welcome. Our master has"
	dc.b	$C1
	dc.b	"been waiting for you."
	dc.b	$C4

loc_206B2:
	dc.b	"I personally wish to"
	dc.b	$C1
	dc.b	"have my master sleep"
	dc.b	$C3
	dc.b	"quietly, but", $47, $47, $47
	dc.b	$C4

loc_206EC:
	dc.b	"They say that those bad"
	dc.b	$C1
	dc.b	"guys who are rebelling"
	dc.b	$C3
	dc.b	"against Mother Brain"
	dc.b	$C1
	dc.b	"are being chased by the"
	dc.b	$C3
	dc.b	"robots the government"
	dc.b	$C1
	dc.b	"sent out."
	dc.b	$C4

loc_20768:
	dc.b	"Now that those Bio-"
	dc.b	$C1
	dc.b	"hazards are gone, we"
	dc.b	$C3
	dc.b	"can live without working"
	dc.b	$C1
	dc.b	"again."
	dc.b	$C4

loc_207B1:
	dc.b	"You guys look like the"
	dc.b	$C1
	dc.b	"guys in the pictures of"
	dc.b	$C3
	dc.b	"the wanted", $47, $47, $47
	dc.b	$C4

loc_207EE:
	dc.b	"No matter what may"
	dc.b	$C1
	dc.b	"happen, we will believe"
	dc.b	$C3
	dc.b	"in you and those who"
	dc.b	$C1
	dc.b	"are fighting for us."
	dc.b	$C4

loc_20843:
	dc.b	"Biohazards are gone, but"
	dc.b	$C1
	dc.b	"the heavy atmosphere of"
	dc.b	$C3
	dc.b	"this planet somehow"
	dc.b	$C1
	dc.b	"stays the same", $47, $47, $47
	dc.b	$C4

loc_2089A:
	dc.b	"I've seen your face"
	dc.b	$C1
	dc.b	"somewhere", $47, $47, $47
	dc.b	$C4

loc_208BB:
	dc.b	"Hey, the good-looking"
	dc.b	$C1	
	dc.b	"girl you were always"
	dc.b	$C3
	dc.b	"with, she is not with"
	dc.b	$C1
	dc.b	"you today?"
	dc.b	$C4

loc_20907:
	dc.b	"Mom told me not to talk"
	dc.b	$C1
	dc.b	"to ", $BB, " and his friends."
	dc.b	$C3
	dc.b	"Why is that?"
	dc.b	$C4

loc_20942:
	dc.b	"The future of Algo"
	dc.b	$C1
	dc.b	"depends on you."
	dc.b	$C3
	dc.b	"I'm sure it will be a"
	dc.b	$C1
	dc.b	"tough trip, but please"
	dc.b	$C3
	dc.b	"do not get discouraged!"
	dc.b	$C4

loc_209AA:
	dc.b	"Hey, have you met any"
	dc.b	$C1
	dc.b	"Dezo people? We don't"
	dc.b	$C3
	dc.b	"understand what they"
	dc.b	$C1
	dc.b	"are saying. They are"
	dc.b	$C3
	dc.b	"also liars, have warped"
	dc.b	$C1
	dc.b	"minds, and are really"
	dc.b	$C3
	dc.b	"nasty!"
	dc.b	$C4
; ---------------------------------------------------------------------------------

	even

	if long_script_offsets
	even
	endif
Script_LevelActions:
	scriptofs	loc_20A58, Script_LevelActions	; 1
	scriptofs	loc_20A77, loc_20A58				; 2
	scriptofs	loc_20A86, loc_20A77				; 3
	scriptofs	loc_20A9E, loc_20A86				; 4
	scriptofs	loc_20ABC, loc_20A9E				; 5
	scriptofs	loc_20AD2, loc_20ABC				; 6
	scriptofs	loc_20AEB, loc_20AD2				; 7
	scriptofs	loc_20B07, loc_20AEB				; 8
	scriptofs	loc_20B2F, loc_20B07				; 9
	scriptofs	loc_20B7F, loc_20B2F				; $A
	scriptofs	loc_20BD6, loc_20B7F				; $B
	scriptofs	loc_20C22, loc_20BD6				; $C
	scriptofs	loc_20C52, loc_20C22				; $D
	scriptofs	loc_20C75, loc_20C52				; $E
	scriptofs	loc_20C9A, loc_20C75				; $F
	scriptofs	loc_20CC7, loc_20C9A				; $10
	scriptofs	loc_20CED, loc_20CC7				; $11
	scriptofs	loc_20D2F, loc_20CED				; $12
	scriptofs	loc_20D76, loc_20D2F				; $13
	scriptofs	loc_20DD1, loc_20D76				; $14
	scriptofs	loc_20E1E, loc_20DD1				; $15
	scriptofs	loc_20E5E, loc_20E1E				; $16
	scriptofs	loc_20E9B, loc_20E5E				; $17
	scriptofs	loc_20EE0, loc_20E9B				; $18
	scriptofs	loc_20F1B, loc_20EE0				; $19
	scriptofs	loc_20F37, loc_20F1B				; $1A
	scriptofs	loc_20F73, loc_20F37				; $1B
	scriptofs	loc_20F97, loc_20F73				; $1C
	scriptofs	loc_20FB5, loc_20F97				; $1D
	scriptofs	loc_20FDB, loc_20FB5				; $1E
	scriptofs	loc_20FF2, loc_20FDB				; $1F
	scriptofs	loc_21045, loc_20FF2				; $20
	scriptofs	loc_210AE, loc_21045				; $21
	scriptofs	loc_210B9, loc_210AE				; $22
	
	
loc_20A58:
	dc.b	$BB, " has gotten hold of"
	dc.b	$C1
	dc.b	$C0, " meseta."
	dc.b	$C4

loc_20A77:
	dc.b	$BB, " has found"
	dc.b	$C1
	dc.b	$BF, "."
	dc.b	$C5

loc_20A86:
	dc.b	$BB, " has gotten hold of"
	dc.b	$C1
	dc.b	$BF, "."
	dc.b	$C4

loc_20A9E:
	dc.b	"But they can't hold"
	dc.b	$C1
	dc.b	"any more."
	dc.b	$C4

loc_20ABC:
	dc.b	"It's full of garbage."
	dc.b	$C4

loc_20AD2:
	dc.b	"There is nothing inside."
	dc.b	$C4

loc_20AEB:
	dc.b	"It's locked and won't"
	dc.b	$C1
	dc.b	"open."
	dc.b	$C4

loc_20B07:
	dc.b	"There seems to be"
	dc.b	$C1
	dc.b	"nothing unusual here."
	dc.b	$C4

loc_20B2F:
	dc.b	"This is the control"
	dc.b	$C1
	dc.b	"tower which links the"
	dc.b	$C3
	dc.b	"town and Mother Brain"
	dc.b	$C1
	dc.b	"in one network."
	dc.b	$C4
	
loc_20B7F:
	dc.b	"Those scoundrels seem"
	dc.b	$C1
	dc.b	"to have blown open the"
	dc.b	$C3
	dc.b	"door with dynamite and"
	dc.b	$C1
	dc.b	"stolen the things."
	dc.b	$C4

loc_20BD6:
	dc.b	"Those are bodies of the"
	dc.b	$C1
	dc.b	"scoundrels. I wonder"
	dc.b	$C3
	dc.b	"if the Biohazards killed"
	dc.b	$C1
	dc.b	"them?"
	dc.b	$C4

loc_20C22:
	dc.b	"Oh, my! There is some-"
	dc.b	$C1
	dc.b	"thing inside the pocket."
	dc.b	$C4

loc_20C52:
	dc.b	"Maybe dynamite can open"
	dc.b	$C1	
	dc.b	"this door."
	dc.b	$C4

loc_20C75:
	dc.b	"It seems like a very"
	dc.b	$C1
	dc.b	"strong shutter."
	dc.b	$C4

loc_20C9A:
	dc.b	"It looks like a Maruera-"
	dc.b	$C1
	dc.b	"tree, but it isn't."
	dc.b	$C4

loc_20CC7:
	dc.b	"This is it! This is the"
	dc.b	$C1
	dc.b	"Maruera-tree."
	dc.b	$C4

loc_20CED:
	dc.b	"Here's a key board. Oh,"
	dc.b	$C1
	dc.b	"here's some music, too."
	dc.b	$C3
	dc.b	"Shall I touch it?"
	dc.b	$C5

loc_20D2F:
	dc.b	"When you're lonely, the"
	dc.b	$C1
	dc.b	"best way to console"
	dc.b	$C3
	dc.b	"yourself is to"
	dc.b	$C1
	dc.b	"keep a pet!"
	dc.b	$C4

loc_20D76:
	dc.b	"Why don't you talk to"
	dc.b	$C1
	dc.b	"your pet, too? Please"
	dc.b	$C3
	dc.b	"come to our department-"
	dc.b	$C1
	dc.b	"store for a magic cap!"
	dc.b	$C4

loc_20DD1:
	dc.b	"Recently, there's been"
	dc.b	$C1
	dc.b	"many fake magic caps"
	dc.b	$C3
	dc.b	"going around. Please"
	dc.b	$C1
	dc.b	"be careful."
	dc.b	$C4

loc_20E1E:
	dc.b	"A gas-leak has been"
	dc.b	$C1
	dc.b	"reported in Skure"
	dc.b	$C3
	dc.b	"D block. Please"
	dc.b	$C1
	dc.b	"evacuate."
	dc.b	$C4

loc_20E5E:
	dc.b	"The cause of the gas"
	dc.b	$C1
	dc.b	"leak turned out to be a"
	dc.b	$C3
	dc.b	"simple mistake."
	dc.b	$C4

loc_20E9B:
	dc.b	"The gas that leaked out"
	dc.b	$C1	
	dc.b	"could be extremely"
	dc.b	$C3
	dc.b	"dangerous."
	dc.b	$C1
	dc.b	"Please beware!"
	dc.b	$C4

loc_20EE0:
	dc.b	"The last rescue ship"
	dc.b	$C1
	dc.b	"leaves on August 11th."
	dc.b	$C3
	dc.b	"Don't miss it!"
	dc.b	$C4

loc_20F1B:
	dc.b	"I found an old news-"
	dc.b	$C1
	dc.b	"paper!"
	dc.b	$C4

loc_20F37:
	dc.b	"What is this? I feel"
	dc.b	$C1
	dc.b	"the tremendous strength"
	dc.b	$C3
	dc.b	"of dark power!"
	dc.b	$C4

loc_20F73:
	dc.b	"There's a place to put"
	dc.b	$C1
	dc.b	"the card in."
	dc.b	$C4

loc_20F97:
	dc.b	"Let's get on the jet"
	dc.b	$C1
	dc.b	"scooter!"
	dc.b	$C4

loc_20FB5:
	dc.b	"Ok. Let's get off and"
	dc.b	$C1
	dc.b	"walk from here."
	dc.b	$C4

loc_20FDB:
	dc.b	"We can't get off here!"
	dc.b	$C4
	
loc_20FF2:
	dc.b	"There is a high rocky"
	dc.b	$C1
	dc.b	"mountain in front of"
	dc.b	$C4		; this should be $C3
	
; cut-off text
	dc.b	$BB, " and the others!"
	dc.b	$C1
	dc.b	"Is this Uzo mountain?"
	dc.b	$C4

loc_21045:
	dc.b	"The color of water"
	dc.b	$C1
	dc.b	"around here certainly"
	dc.b	$C4		; this should be $C3
	
; cut-off text
	dc.b	"seems different."
	dc.b	$C1
	dc.b	"It seems to be water"
	dc.b	$C3
	dc.b	"coming out of the"
	dc.b	$C1
	dc.b	"ground."
	dc.b	$C4
	
loc_210AE:
	dc.b	$BB, " is dead!"
	dc.b	$C4
	
loc_210B9:
	dc.b	"What? Shir is gone?"
	dc.b	$C4
; ---------------------------------------------------------------------------------

	even


	if long_script_offsets
	even
	endif
Script_LevelEvents:
	scriptofs	loc_2110D, Script_LevelEvents	; 1
	scriptofs	loc_21175, loc_2110D				; 2
	scriptofs	loc_21188, loc_21175				; 3
	scriptofs	loc_211BC, loc_21188				; 4
	scriptofs	loc_21227, loc_211BC				; 5
	scriptofs	loc_21279, loc_21227				; 6
	scriptofs	loc_212EF, loc_21279				; 7
	scriptofs	loc_2135C, loc_212EF				; 8
	scriptofs	loc_21404, loc_2135C				; 9
	scriptofs	loc_2146C, loc_21404				; $A
	scriptofs	loc_2154F, loc_2146C				; $B
	scriptofs	loc_21633, loc_2154F				; $C
	scriptofs	loc_21656, loc_21633				; $D
	scriptofs	loc_216C5, loc_21656				; $E
	scriptofs	loc_216EA, loc_216C5				; $F
	scriptofs	loc_217CB, loc_216EA				; $10
	scriptofs	loc_21817, loc_217CB				; $11
	scriptofs	loc_21817, loc_21817				; $12
	scriptofs	loc_218A0, loc_21817				; $13
	scriptofs	loc_2197C, loc_218A0				; $14
	scriptofs	loc_21A23, loc_2197C				; $15
	scriptofs	loc_21AC1, loc_21A23				; $16
	scriptofs	loc_21B89, loc_21AC1				; $17
	scriptofs	loc_21BCF, loc_21B89				; $18
	scriptofs	loc_21BEC, loc_21BCF				; $19
	scriptofs	loc_21C6A, loc_21BEC				; $1A
	scriptofs	loc_21CA1, loc_21C6A				; $1B
	scriptofs	loc_21CDE, loc_21CA1				; $1C
	scriptofs	loc_21D2D, loc_21CDE				; $1D
	scriptofs	loc_21D2D, loc_21D2D				; $1E
	scriptofs	loc_21DA4, loc_21D2D				; $1F
	scriptofs	loc_21DD8, loc_21DA4				; $20
	scriptofs	loc_21DD8, loc_21DD8				; $21
	scriptofs	loc_21EC4, loc_21DD8				; $22
	scriptofs	loc_21F67, loc_21EC4				; $23
	scriptofs	loc_21FA8, loc_21F67				; $24
	scriptofs	loc_21FA8, loc_21FA8				; $25
	scriptofs	loc_22048, loc_21FA8				; $26
	scriptofs	loc_220B8, loc_22048				; $27
	scriptofs	loc_2210A, loc_220B8				; $28
	scriptofs	loc_22151, loc_2210A				; $29
	scriptofs	loc_22151, loc_22151				; $2A
	scriptofs	loc_22195, loc_22151				; $2B
	scriptofs	loc_221F5, loc_22195				; $2C
	scriptofs	loc_2220D, loc_221F5				; $2D
	scriptofs	loc_22256, loc_2220D				; $2E
	scriptofs	loc_2228C, loc_22256				; $2F
	scriptofs	loc_222CE, loc_2228C				; $30
	scriptofs	loc_22303, loc_222CE				; $31
	scriptofs	loc_2237B, loc_22303				; $32
	scriptofs	loc_22391, loc_2237B				; $33
	scriptofs	loc_2248A, loc_22391				; $34
	scriptofs	loc_2255B, loc_2248A				; $35
	scriptofs	loc_2262F, loc_2255B				; $36
	scriptofs	loc_2269A, loc_2262F				; $37
	scriptofs	loc_226D6, loc_2269A				; $38
	scriptofs	loc_226FE, loc_226D6				; $39
	scriptofs	loc_227B5, loc_226FE				; $3A
	scriptofs	loc_2287E, loc_227B5				; $3B
	scriptofs	loc_2292B, loc_2287E				; $3C
	scriptofs	loc_229E5, loc_2292B				; $3D
	scriptofs	loc_22A8E, loc_229E5				; $3E
	scriptofs	loc_22B07, loc_22A8E				; $3F

loc_2110D:
	dc.b	"I've seen that face! He"
	dc.b	$C1
	dc.b	"tried to kill Nei seven"
	dc.b	$C1
	dc.b	"months ago! This is bad"
	dc.b	$C1
	dc.b	"news. Let's go back for"
	dc.b	$C3
	dc.b	"awhile."
	dc.b	$C4

loc_21175:
	dc.b	"What's Teim doing?"
	dc.b	$C4

loc_21188:
	dc.b	$C2
	dc.b	"I'm going to go meet my"
	dc.b	$C1
	dc.b	"father; don't go"
	dc.b	$C1
	dc.b	"anywhere."
	dc.b	$C4

loc_211BC:
	dc.b	$C2
	dc.b	"Hey girl! Give me your"
	dc.b	$C1
	dc.b	"money or I'll kill you!"
	dc.b	$C3
	dc.b	$C2
	dc.b	"I have nothing to give"
	dc.b	$C1
	dc.b	"the likes of you!"
	dc.b	$C3
	dc.b	$C2
	dc.b	"Why, you", $47, $47, $47, "!!!!"
	dc.b	$C4

loc_21227:
	dc.b	$C2
	dc.b	"Uhhhh!"
	dc.b	$C3
	dc.b	$C2
	dc.b	"Father! ", $47, $47, $47, "killing", $47, $47, $47
	dc.b	$C3
	dc.b	$C2
	dc.b	"Teim!! Oh, what have I"
	dc.b	$C1
	dc.b	"done? You won't die"
	dc.b	$C1
	dc.b	"alone!"
	dc.b	$C5

loc_21279:
	dc.b	"This is just one of the"
	dc.b	$C1
	dc.b	"many tragedies which"
	dc.b	$C1
	dc.b	"have come to pass as the"
	dc.b	$C1
	dc.b	"world falls into"
	dc.b	$C3
	dc.b	"turmoil. Someone must"
	dc.b	$C1
	dc.b	"save us!"
	dc.b	$C4

loc_212EF:
	dc.b	"I'm Teim,daughter of"
	dc.b	$C1	
	dc.b	"Darum. My father"
	dc.b	$C1	
	dc.b	"promised me he would"
	dc.b	$C1
	dc.b	"come and help me,so I'm"
	dc.b	$C3
	dc.b	"waiting here to meet"
	dc.b	$C1
	dc.b	"him."
	dc.b	$C4

loc_2135C:
	dc.b	$BB, " hands over ", $BF, ";"	
	dc.b	$C1
	dc.b	"Teim's hands are"
	dc.b	$C1
	dc.b	"shaking. \IMy father has"
	dc.b	$C1
	dc.b	"become a killer for my"
	dc.b	$C3
	dc.b	"sake? I must stop him!"
	dc.b	$C1
	dc.b	"Take me to him!\I But"
	dc.b	$C1
	dc.b	"there are many who hate"
	dc.b	$C1
	dc.b	"Darum; his daughter"
	dc.b	$C3

loc_21404:
	dc.b	"would be an easy target."
	dc.b	$C1
	dc.b	$BB, " puts a veil over"
	dc.b	$C1
	dc.b	"Teim to hide her"
	dc.b	$C1
	dc.b	"identity, and takes her"
	dc.b	$C3
	dc.b	"to see her father."
	dc.b	$C4

loc_2146C:
	dc.b	"What's this? She looks"
	dc.b	$C1
	dc.b	"just like Nei!"
	dc.b	$C1
	dc.b	"\II am Neifirst, I was"
	dc.b	$C1
	dc.b	"born 2 years ago. I am"
	dc.b	$C3	
	dc.b	"the product of a Bio-"
	dc.b	$C1
	dc.b	"systems experiment"
	dc.b	$C1
	dc.b	"combining humans with"
	dc.b	$C1
	dc.b	"animals. The people felt"
	dc.b	$C3
	dc.b	"the experiment was a"
	dc.b	$C1
	dc.b	"failure and thus tried"
	dc.b	$C1
	dc.b	"to kill me."
	dc.b	$C3

loc_2154F:
	dc.b	"\IBut I escaped,and stole"
	dc.b	$C1	
	dc.b	"DNA data from the"
	dc.b	$C1
	dc.b	"Biosystem. I have"
	dc.b	$C1
	dc.b	"created monsters to"
	dc.b	$C3
	dc.b	"wreak revenge on the"
	dc.b	$C1
	dc.b	"people who so carelessly"
	dc.b	$C1
	dc.b	"and selfishly played"
	dc.b	$C1
	dc.b	"with life. But there is"
	dc.b	$C3
	dc.b	"another Nei within me; a"
	dc.b	$C1
	dc.b	"Nei who is trying to"
	dc.b	$C1
	dc.b	"stop me.\I"
	dc.b	$C4

loc_21633:
	dc.b	$C2
	dc.b	"It can't be", $47, $47, $47, ",you don't"
	dc.b	$C1
	dc.b	"mean", $47, $47, $47, "?"
	dc.b	$C3

loc_21656:
	dc.b	$C2
	dc.b	"\IYes, that is the one"
	dc.b	$C1
	dc.b	"that you call Nei. The"
	dc.b	$C3
	dc.b	"one you think is a"
	dc.b	$C1
	dc.b	"friend is a monster who"
	dc.b	$C1
	dc.b	"despises all people!\I"
	dc.b	$C4

loc_216C5:
	dc.b	"It matters not, because"
	dc.b	$C1
	dc.b	"Nei is dead."
	dc.b	$C4

loc_216EA:
	dc.b	$C2
	dc.b	"\INo, I don't hate"
	dc.b	$C1
	dc.b	"humans!\I said Nei. \II"
	dc.b	$C1
	dc.b	"separated from Neifirst"
	dc.b	$C1
	dc.b	"because it was so"
	dc.b	$C3
	dc.b	"terrible in her! Of"
	dc.b	$C1
	dc.b	"course it is terrible to"
	dc.b	$C1
	dc.b	"be born a monster! But"
	dc.b	$C1
	dc.b	"I couldn't stand by"
	dc.b	$C3
	dc.b	"while you tried to get"
	dc.b	$C1
	dc.b	"revenge by creating"
	dc.b	$C1
	dc.b	"monsters!\I"
	dc.b	$C4

loc_217CB:
	dc.b	$C2
	dc.b	"\IFool! You say such"
	dc.b	$C1
	dc.b	"things but you are"
	dc.b	$C1
	dc.b	"powerless to stop me!"
	dc.b	$C1
	dc.b	"Just try it!\I"
	dc.b	$C5

loc_21817:
	dc.b	$BB, " hears a large"
	dc.b	$C1
	dc.b	"explosion and feels a"
	dc.b	$C3
	dc.b	"tremendous force moving"
	dc.b	$C1
	dc.b	"the satellite."
	dc.b	$C3
	dc.b	$BB, " better check the"
	dc.b	$C1
	dc.b	"control panel and fix"
	dc.b	$C1	
	dc.b	"the Gaila's orbit!"
	dc.b	$C4

loc_218A0:
	dc.b	"So this is the Mother"
	dc.b	$C1
	dc.b	"Brain controlling Algo."
	dc.b	$C1
	dc.b	$BB, " and the party are"
	dc.b	$C1
	dc.b	"overcome by the presence"
	dc.b	$C3
	dc.b	"of the Mother Brain."
	dc.b	$C1
	dc.b	"But the future of Algo"
	dc.b	$C1
	dc.b	"depends on them!"
	dc.b	$C1
	dc.b	"Will they have to fight"
	dc.b	$C3
	dc.b	"to pry Algo from the"
	dc.b	$C1
	dc.b	"grasp of Mother Brain?"
	dc.b	$C5

loc_2197C:
	dc.b	"The Mother Brain begins"
	dc.b	$C1
	dc.b	"to grin."
	dc.b	$C3
	dc.b	$C2
	dc.b	"\IYou are such fools. If"
	dc.b	$C1
	dc.b	"you damage me, the world"
	dc.b	$C1
	dc.b	"will be thrown into a"
	dc.b	$C1
	dc.b	"panic. Without me, the"
	dc.b	$C3
	dc.b	"people of Algo are"
	dc.b	$C1
	dc.b	"helpless. They have"
	dc.b	$C1
	
loc_21A23:
	dc.b	"become too soft and used"
	dc.b	$C1
	dc.b	"to comfort."
	dc.b	$C3
	dc.b	"If I were to"
	dc.b	$C1
	dc.b	"malfunction, the people"
	dc.b	$C3
	dc.b	"would die cursing their"
	dc.b	$C1
	dc.b	"fate. If that is your"
	dc.b	$C1
	dc.b	"aim, disable me! If not,"
	dc.b	$C1
	dc.b	"return now!\I"
	dc.b	$C5

loc_21AC1:
	dc.b	"The Mother Brain laughed"
	dc.b	$C1
	dc.b	"loudly and said,\I Just"
	dc.b	$C1
	dc.b	"as I thought, you cannot"
	dc.b	$C1
	dc.b	"harm me. I am like a"
	dc.b	$C3
	dc.b	"mother protecting her"
	dc.b	$C1
	dc.b	"child. And now I will"
	dc.b	$C1
	dc.b	"take my child, Algo, by"
	dc.b	$C3
	dc.b	"the hand and lead it"
	dc.b	$C1
	dc.b	"down the path of"
	dc.b	$C1
	
loc_21B89:
	dc.b	"destruction."	; this word should be in the piece of text above since this very piece of dialogue is called separately when you give another answer
	dc.b	$C1
	dc.b	"On your way, then,"
	dc.b	$C3
	dc.b	"because there is nothing"
	dc.b	$C1
	dc.b	"you can do.\I"
	dc.b	$C4

loc_21BCF:
	dc.b	"\II will show no mercy."
	dc.b	$C1
	dc.b	"Die!\I"
	dc.b	$C4

loc_21BEC:
	dc.b	"Welcome to the spaceship"
	dc.b	$C1
	dc.b	"Noah."
	dc.b	$C3
	dc.b	$C2
	dc.b	"Who are you?"
	dc.b	$C3
	dc.b	$C2
	dc.b	"I don't like your tone"
	dc.b	$C1
	dc.b	"of voice. Are you here"
	dc.b	$C1
	dc.b	"because you think we are"
	dc.b	$C1
	dc.b	"enemies?"
	dc.b	$C5

loc_21C6A:
	dc.b	"Of course we hate you"
	dc.b	$C1
	dc.b	"for destroying the"
	dc.b	$C1
	dc.b	"Mother Brain."
	dc.b	$C4

loc_21CA1:
	dc.b	"Thanks to the Mother"
	dc.b	$C1
	dc.b	"Brain which we created,"
	dc.b	$C1
	dc.b	"Algo prospered."
	dc.b	$C4

loc_21CDE:
	dc.b	$C2
	dc.b	"So you are the creators"
	dc.b	$C1
	dc.b	"of the Mother Brain."
	dc.b	$C1
	dc.b	"You are hardly what we"
	dc.b	$C1
	dc.b	"expected!"
	dc.b	$C4
	
loc_21D2D:
	dc.b	"Then they could hear"
	dc.b	$C1
	dc.b	"Lutz's voice; \IOh brave"
	dc.b	$C1
	dc.b	"warriors who rescued"
	dc.b	$C1
	dc.b	"Algol!\I And then"			; the only time they use the full name...
	dc.b	$BB, " "		; yeah, it's a space
	dc.b	$C3
	dc.b	"and the others came"
	dc.b	$C1
	dc.b	"back to life."
	dc.b	$C4

loc_21DA4:
	dc.b	"Let's get back to"						
	dc.b	$C1
	dc.b	"Mota. This is only"
	dc.b	$C1
	dc.b	"the beginning!"
	dc.b	$C4

loc_21DD8:
	dc.b	$C2
	dc.b	"Thanks to Lutz's power,"
	dc.b	$C1
	dc.b	"they were sent on their"
	dc.b	$C1
	dc.b	"way."
	dc.b	$C3
	dc.b	$C2
	dc.b	"\IVery clever! But it is"
	dc.b	$C1
	dc.b	"only a matter of time"
	dc.b	$C1
	dc.b	"before Algo is"
	dc.b	$C1
	dc.b	"destroyed.\I"
	dc.b	$C3
	dc.b	$C2
	dc.b	"\ISilence! Be quiet!\I"
	dc.b	$C3
	dc.b	$C2
	dc.b	"And in the next instant,"
	dc.b	$C1
	dc.b	$BB, " and the others were"
	dc.b	$C1
	dc.b	"attacked by several"
	dc.b	$C1
	dc.b	"hundred earthmen!"
	dc.b	$C4

loc_21EC4:
	dc.b	"Nei stood with her head"
	dc.b	$C1
	dc.b	"down and didn't move."
	dc.b	$C1
	dc.b	"Since Nei and Neifirst"
	dc.b	$C1
	dc.b	"were originally both"
	dc.b	$C3
	dc.b	"part of the same body,"
	dc.b	$C1
	dc.b	"killing Neifirst would"
	dc.b	$C1
	dc.b	"mean the end of Nei,"
	dc.b	$C1
	dc.b	"also."
	dc.b	$C4

loc_21F67:
	dc.b	"\II don't want you to"
	dc.b	$C1
	dc.b	"make any more monsters!"
	dc.b	$C1
	dc.b	"Do you understand?\I"
	dc.b	$C4

loc_21FA8:
	dc.b	"The weather control"
	dc.b	$C1
	dc.b	"system is shaking"
	dc.b	$C1
	dc.b	"terrifically. Now"
	dc.b	$C1
	dc.b	"Neifirst is dead, there"
	dc.b	$C3
	dc.b	"is no one controlling"
	dc.b	$C1
	dc.b	"it. All of the pent-up"
	dc.b	$C1
	dc.b	"energy is pouring"
	dc.b	$C1
	dc.b	"into the system!"
	dc.b	$C4

loc_22048:
	dc.b	$BB, ", there's no hope"
	dc.b	$C1
	dc.b	"for me. If Neifirst is"
	dc.b	$C1
	dc.b	"dead, I must die,too."
	dc.b	$C1
	dc.b	"And in so saying, Nei"
	dc.b	$C3
	dc.b	"silently closed her"
	dc.b	$C1
	dc.b	"eyes."
	dc.b	$C4

loc_220B8:
	dc.b	$BB, " calls Nei's name"
	dc.b	$C1
	dc.b	"once again. But his"
	dc.b	$C1
	dc.b	"plaintive cry merely"
	dc.b	$C1
	dc.b	"echoes and re-echoes."
	dc.b	$C4

loc_2210A:
	dc.b	"What has happened? ", $BB
	dc.b	$C1
	dc.b	"and the others quickly"
	dc.b	$C1
	dc.b	"decide to return to"
	dc.b	$C1
	dc.b	"Paseo."
	dc.b	$C4

loc_22151:
	dc.b	"We shall make"
	dc.b	$C1
	dc.b	"you see how it"
	dc.b	$C1
	dc.b	"feels to lose"
	dc.b	$C1
	dc.b	"something that"
	dc.b	$C1
	dc.b	"you love!"
	dc.b	$C5

loc_22195:
	dc.b	"I can see the"
	dc.b	$C1
	dc.b	"confusion and"
	dc.b	$C1
	dc.b	"pity in your"
	dc.b	$C1
	dc.b	"eyes. I will"
	dc.b	$C1
	dc.b	"never forgive"
	dc.b	$C1
	dc.b	"you for what"
	dc.b	$C1
	dc.b	"you have done."
	dc.b	$C5

loc_221F5:	
	dc.b	"How dare you"
	dc.b	$C1
	dc.b	"ruin Algo!"
	dc.b	$C5

loc_2220D:
	dc.b	"I refuse to be"
	dc.b	$C1
	dc.b	"a slave of fate!"
	dc.b	$C1
	dc.b	"I will be the"
	dc.b	$C1
	dc.b	"master of my "
	dc.b	$C1
	dc.b	"own future!"
	dc.b	$C5

loc_22256:
	dc.b	"You have shown"
	dc.b	$C1
	dc.b	"me the ugliness"
	dc.b	$C1
	dc.b	"of continued"
	dc.b	$C1
	dc.b	"existence."
	dc.b	$C5

loc_2228C:
	dc.b	"These are my "
	dc.b	$C1
	dc.b	"parting words"
	dc.b	$C1
	dc.b	"to you;"
	dc.b	$C1
	dc.b	"those who give up"
	dc.b	$C1
	dc.b	"are doomed!"
	dc.b	$C5

loc_222CE:
	dc.b	"I wonder what"
	dc.b	$C1
	dc.b	"the people will see"
	dc.b	$C1
	dc.b	"in the final days?"
	dc.b	$C5

loc_22303:
	dc.b	"\I", $BB, " wait!\I Lutz's"
	dc.b	$C1
	dc.b	"voice filled everybody's"
	dc.b	$C1
	dc.b	"heart. \IThere is still"
	dc.b	$C1
	dc.b	"somebody in the ship!"
	dc.b	$C3
	dc.b	"You can't return again!\I"
	dc.b	$C1
	dc.b	"\IWhat?\I"
	dc.b	$C4

loc_2237B:
	dc.b	"Who are these people?"
	dc.b	$C4

loc_22391:
	dc.b	$C2
	dc.b	"\IWe are not people of"
	dc.b	$C1
	dc.b	"Algo. We are from a"
	dc.b	$C1
	dc.b	"place called Earth."
	dc.b	$C1
	dc.b	"Our planet was green and"
	dc.b	$C3
	dc.b	"lovely, and we had a"
	dc.b	$C1
	dc.b	"highly advanced"
	dc.b	$C1	
	dc.b	"civilization."
	dc.b	$C3
	dc.b	"We are the last of our"
	dc.b	$C1
	dc.b	"race.\I"
	dc.b	$C3
	dc.b	$C2
	dc.b	"\IThe last", $47, $47, $47, "?\I"
	dc.b	$C3
	dc.b	$C2
	dc.b	"\IYes. Our planet has"
	dc.b	$C1
	dc.b	"been destroyed. Do you"
	dc.b	$C1
	dc.b	"want to know why?\I"
	dc.b	$C5

loc_2248A:
	dc.b	"\IWe were a weaker people"
	dc.b	$C1
	dc.b	"then. Even though we"
	dc.b	$C1
	dc.b	"knew about the evil"
	dc.b	$C1
	dc.b	"inside of us, we didn't"
	dc.b	$C3
	dc.b	"suppress it. We took"
	dc.b	$C1
	dc.b	"joy in controlling"
	dc.b	$C1
	dc.b	"nature; we didn't"
	dc.b	$C1
	dc.b	"realize we were"
	dc.b	$C3
	dc.b	"destroying ourselves\I"	; sigh... Why is the " character in the middle of the sentence?
	dc.b	$C1
	dc.b	"until it was too late."
	dc.b	$C3

loc_2255B:
	dc.b	"\IThe death rattle of our"
	dc.b	$C1
	dc.b	"planet alerted us to our"
	dc.b	$C1
	dc.b	"failure. With the time"
	dc.b	$C1
	dc.b	"remaining to us, we"
	dc.b	$C3
	dc.b	"built a spaceship to"
	dc.b	$C1
	dc.b	"wander among the stars."
	dc.b	$C1
	dc.b	"Then we found Algo."
	dc.b	$C1
	dc.b	"We found the people"
	dc.b	$C3
	dc.b	"here living in simple"
	dc.b	$C1
	dc.b	"happiness.\I"
	dc.b	$C3

loc_2262F:
	dc.b	"\IWe decided we wanted"
	dc.b	$C1
	dc.b	"this planet. And do you"
	dc.b	$C1
	dc.b	"think you can stop us,"
	dc.b	$C1
	dc.b	"we who destroyed Palm?"
	dc.b	$C3
	dc.b	"You will die!\I"
	dc.b	$C4

loc_2269A:
	dc.b	"\ISince you are going to"
	dc.b	$C1
	dc.b	"die anyway, you might"
	dc.b	$C1
	dc.b	"as well know."
	dc.b	$C5

loc_226D6:
	dc.b	"If you want to know, we"
	dc.b	$C1
	dc.b	"will tell you.\I"
	dc.b	$C4

loc_226FE:
	dc.b	"This is the satellite"
	dc.b	$C1
	dc.b	"Gaila. There is no"
	dc.b	$C1
	dc.b	"escape; you are in outer"
	dc.b	$C1
	dc.b	"space. You are guilty"
	dc.b	$C3
	dc.b	"of damaging the Mother"
	dc.b	$C1
	dc.b	"Brain. You will be kept"
	dc.b	$C1
	dc.b	"here until your death"
	dc.b	$C1
	dc.b	"sentence is carried out."
	dc.b	$C3
	dc.b	$C2
	
loc_227B5:
	dc.b	"I tried to open the dams"
	dc.b	$C1
	dc.b	"because I felt"
	dc.b	$C1
	dc.b	"responsible for making"
	dc.b	$C1
	dc.b	"too much rain fall, but"
	dc.b	$C3
	dc.b	"I was caught. I don't"
	dc.b	$C1
	dc.b	"want to die here not"
	dc.b	$C1
	dc.b	"even knowing who was"
	dc.b	$C1
	dc.b	"trying to destroy"
	dc.b	$C3
	dc.b	"Mota by using the"
	dc.b	$C1
	dc.b	"Mother Brain."
	dc.b	$C4

loc_2287E:
	dc.b	$BB, "and the rest of the"			; again no space after the character's name <_<
	dc.b	$C1
	dc.b	"company stood in"
	dc.b	$C1
	dc.b	"amazement where the"
	dc.b	$C1
	dc.b	"Mother Brain once was."
	dc.b	$C3
	dc.b	"Algo had been suddenly"
	dc.b	$C1
	dc.b	"released from the Mother"
	dc.b	$C1
	dc.b	"Brain's control. The"
	dc.b	$C1
	dc.b	"Biosystems and weather"
	dc.b	$C3

loc_2292B:
	dc.b	"control systems suddenly"
	dc.b	$C1
	dc.b	"became useless. The"
	dc.b	$C1
	dc.b	"people of Algo awaited"
	dc.b	$C1
	dc.b	"the start of their hard"
	dc.b	$C3
	dc.b	"and difficult life"
	dc.b	$C1
	dc.b	"without the Mother"
	dc.b	$C1
	dc.b	"Brain."
	dc.b	$C3
	dc.b	"But ", $BB, " and the others"
	dc.b	$C1
	dc.b	"could feel a sense of"
	dc.b	$C1
	dc.b	"hope."
	dc.b	$C4

loc_229E5:
	dc.b	"Nei, hold on!"
	dc.b	$C3
	dc.b	$C2
	dc.b	"\IThere's no hope left"
	dc.b	$C1
	dc.b	"for me. Please, ", $BB
	dc.b	$C1
	dc.b	"don't let them ever"
	dc.b	$C1
	dc.b	"repeat the mistake they"
	dc.b	$C3
	dc.b	"made when they made me."
	dc.b	$C1
	dc.b	"I hope everyone on Algo"
	dc.b	$C1
	dc.b	"can find happiness in"
	dc.b	$C1
	
loc_22A8E:
	dc.b	"their new life.\I"
	dc.b	$C3
	dc.b	$C2
	dc.b	"After saying this, Nei"
	dc.b	$C1
	dc.b	"died. ", $BB, " laid Nei's"
	dc.b	$C1
	dc.b	"lifeless body gently on"
	dc.b	$C1
	dc.b	"the ground."
	dc.b	$C3
	dc.b	"Nei! We will avenge you!"
	dc.b	$C4

loc_22B07:
	dc.b	"In place of the home we"
	dc.b	$C1
	dc.b	"have lost we will have"
	dc.b	$C1
	dc.b	"to settle for this star."
	dc.b	$C1
	dc.b	"The Mother Brain is"
	dc.b	$C3
	dc.b	"lost, but we can easily"
	dc.b	$C1
	dc.b	"create another. The"
	dc.b	$C1
	dc.b	"only ones who are"
	dc.b	$C1
	dc.b	"against us are you. If"
	dc.b	$C3
	dc.b	"you are eliminated, our"
	dc.b	$C1
	dc.b	"plans can proceed."
	dc.b	$C4
; ---------------------------------------------------------------------------------

	even

	if long_script_offsets
	even
	endif
Script_Miscellaneous:
	scriptofs	loc_22BF7, Script_Miscellaneous	; 1
	scriptofs	loc_22C4F, loc_22BF7				; 2
	scriptofs	loc_22C6D, loc_22C4F				; 3
	scriptofs	loc_22C76, loc_22C6D				; 4
	scriptofs	loc_22C7F, loc_22C76				; 5
	scriptofs	loc_22D28, loc_22C7F				; 6
	scriptofs	loc_22D99, loc_22D28				; 7
	scriptofs	loc_22DCD, loc_22D99				; 8
	scriptofs	loc_22E92, loc_22DCD				; 9
	scriptofs	loc_22F31, loc_22E92				; $A
	scriptofs	loc_22FDF, loc_22F31				; $B
	scriptofs	loc_230C0, loc_22FDF				; $C
	scriptofs	loc_2314C, loc_230C0				; $D
	scriptofs	loc_231DB, loc_2314C				; $E
	scriptofs	loc_23290, loc_231DB				; $F
	scriptofs	loc_2330A, loc_23290				; $10
	scriptofs	loc_233AA, loc_2330A				; $11
	scriptofs	loc_233E8, loc_233AA				; $12
	scriptofs	loc_2345E, loc_233E8				; $13
	
loc_22BF7:
	dc.b	"Oh no! This satellite is"
	dc.b	$C1
	dc.b	"headed straight for"
	dc.b	$C1
	dc.b	"Palm! There's no time!"
	dc.b	$C1
	dc.b	"What should I do???"
	dc.b	$C5

loc_22C4F:
	dc.b	"It was that same dream"
	dc.b	$C1
	dc.b	"again."
	dc.b	$C5

loc_22C6D:
	dc.b	$C2
	dc.b	"Help!!!"
	dc.b	$C7

loc_22C76:
	dc.b	$C2
	dc.b	$47, $47, $47, $47, $47, "?!"
	dc.b	$C7

loc_22C7F:
	dc.b	$C2
	dc.b	"Did I disturb you?"
	dc.b	$C1
	dc.b	"I'm Tyler,a space"
	dc.b	$C1
	dc.b	"pirate. I left Palm"
	dc.b	$C1
	dc.b	"long ago; life under the"
	dc.b	$C3
	dc.b	"Mother Brain was not to"
	dc.b	$C1
	dc.b	"my liking. You were"
	dc.b	$C1
	dc.b	"being held by Gaila,"
	dc.b	$C1
	dc.b	"right? It's good for"
	dc.b	$C3

loc_22D28:
	dc.b	"you that I happened to"
	dc.b	$C1
	dc.b	"be close by. Your"
	dc.b	$C1
	dc.b	"friends are also being"
	dc.b	$C1
	dc.b	"revived right now; they"
	dc.b	$C3
	dc.b	"should awake any moment."
	dc.b	$C4

loc_22D99:
	dc.b	"It was terrible", $47, $47, $47, "this"
	dc.b	$C1
	dc.b	"is all that is left of"
	dc.b	$C1
	dc.b	"Palm."
	dc.b	$C4

loc_22DCD:
	dc.b	"One planet was"
	dc.b	$C1
	dc.b	"destroyed. Who knows"
	dc.b	$C1
	dc.b	"what happened to Algo,"
	dc.b	$C1
	dc.b	"I don't know what to"
	dc.b	$C3
	dc.b	"say."
	dc.b	$C1
	dc.b	"According to the news,"
	dc.b	$C1
	dc.b	"you and your friends are"
	dc.b	$C1
	dc.b	"criminals charged with"
	dc.b	$C3
	dc.b	"destroying the Mother"
	dc.b	$C1
	dc.b	"Brain. But I don't"
	dc.b	$C3

loc_22E92:
	dc.b	"believe you could have"
	dc.b	$C1
	dc.b	"done that, could you?"
	dc.b	$C1
	dc.b	"Anyway, I'll take you"
	dc.b	$C1
	dc.b	"to Paseo. I've already"
	dc.b	$C3
	dc.b	"got your belongings"
	dc.b	$C1
	dc.b	"loaded."
	dc.b	$C1
	dc.b	"Ah, I remember now! You"
	dc.b	$C1
	dc.b	"were heading for"
	dc.b	$C3

loc_22F31:
	dc.b	"Dezo. I have heard"
	dc.b	$C1
	dc.b	"that there is someone"
	dc.b	$C1
	dc.b	"there who can do things"
	dc.b	$C1
	dc.b	"the Mother Brain can't."
	dc.b	$C3
	dc.b	"But he might be of a"
	dc.b	$C1
	dc.b	"criminal nature! You"
	dc.b	$C1
	dc.b	"never can tell! Well,"
	dc.b	$C1
	dc.b	"until we meet again!"
	dc.b	$C4

loc_22FDF:
	dc.b	"You finally made it."
	dc.b	$C1
	dc.b	"I'm Lutz, the last"
	dc.b	$C1
	dc.b	"telemental on Algo."
	dc.b	$C1
	dc.b	"You seem surprised that"
	dc.b	$C3
	dc.b	"I know your name. Don't"
	dc.b	$C1
	dc.b	"you remember? This is"
	dc.b	$C1
	dc.b	"the second time we have"
	dc.b	$C1
	dc.b	"met. I saved you from"
	dc.b	$C3
	dc.b	"death after an accident"
	dc.b	$C1
	dc.b	"on a spacetrip with your"
	dc.b	$C1

loc_230C0:
	dc.b	"parents when you were"
	dc.b	$C1
	dc.b	"10."
	dc.b	$C3
	dc.b	"What woke me was Alis'"
	dc.b	$C1
	dc.b	"scream. So you are the"
	dc.b	$C1
	dc.b	"last descendant of Alis"
	dc.b	$C1
	dc.b	"who fought to protect"
	dc.b	$C3
	dc.b	"Algo. Beautiful Alis,"
	dc.b	$C1
	
loc_2314C:
	dc.b	"the symbol of Algo, was"
	dc.b	$C1
	dc.b	"fighting the dark force"		;  It should be Dark Force
	dc.b	$C1
	dc.b	"in that dream. The dark"
	dc.b	$C3
	dc.b	"force was trying to"
	dc.b	$C1
	dc.b	"destroy Algo, but in"
	dc.b	$C1
	dc.b	"the end was itself"
	dc.b	$C1
	dc.b	"destroyed."
	dc.b	$C4

loc_231DB:
	dc.b	"But that doesn't mean"
	dc.b	$C1
	dc.b	"that there is no longer"
	dc.b	$C1
	dc.b	"anyone trying to destroy"
	dc.b	$C1
	dc.b	"Algo. You,", $BB, ", must"		; no space between comma and character's name
	dc.b	$C3
	dc.b	"arm yourself for battle."
	dc.b	$C1
	dc.b	"One valuable item is the"
	dc.b	$C1
	dc.b	"aeroprism--it will let"
	dc.b	$C1
	dc.b	"you see that which"
	dc.b	$C3

loc_23290:
	dc.b	"cannot be seen. Also"
	dc.b	$C1
	dc.b	"arm yourself with Nei's"
	dc.b	$C1
	dc.b	"weapons. Prepare"
	dc.b	$C1
	dc.b	"yourself, and then I"
	dc.b	$C3
	dc.b	"will tell you about the"
	dc.b	$C1
	dc.b	"enemy's plans."
	dc.b	$C4

loc_2330A:
	dc.b	"Ha,ha,ha,ha,ha!"
	dc.b	$C1
	dc.b	"This is Pandora's box!"
	dc.b	$C1
	dc.b	"It contains all that is"
	dc.b	$C1
	dc.b	"evil, all that you call"
	dc.b	$C3
	dc.b	"the dark force! This is"
	dc.b	$C1
	dc.b	"a present from our world"
	dc.b	$C1
	dc.b	"to all of you! Take it!"
	dc.b	$C7

loc_233AA:
	dc.b	$BB, ", are you brave"
	dc.b	$C1
	dc.b	"enough to do battle with"
	dc.b	$C1
	dc.b	"the powers of evil?"
	dc.b	$C5

loc_233E8:
	dc.b	"In that case, I'll send"
	dc.b	$C1
	dc.b	"you on your way with my"
	dc.b	$C1
	dc.b	"prayers."
	dc.b	$C1
	dc.b	"Oh, god of Algo, bless"
	dc.b	$C3
	dc.b	"this party with courage"
	dc.b	$C1
	dc.b	"and strength."
	dc.b	$C4

loc_2345E:
	dc.b	"Remove the Nei-sword"
	dc.b	$C1
	dc.b	"from this box."
	dc.b	$C4
; ---------------------------------------------------------------------------------
	
	even

	charset

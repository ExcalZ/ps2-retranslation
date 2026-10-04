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
	dc.b	"'s wounds are healed."
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
	dc.b	"A prism with a mysterious, truly"
	dc.b	$C1
	dc.b	"mysterious, radiance..."
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
	dc.b	" can't carry any more."
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
	dc.b	" reconsidered."
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
	dc.b	"How humiliating, to be stuck like this!"
	dc.b	$C4

loc_18DE3:
	dc.b	"A fragrant aroma filled the air."
	dc.b	$C4

loc_18E02:
	dc.b	"A leaf from a Maruera tree."
	dc.b	$C1
	dc.b	"It feels soft and fluffy to the touch."
	dc.b	$C4

loc_18E31:
	dc.b	"Somehow, everyone felt lighter."
	dc.b	$C5
	
loc_18E4C:
	dc.b	"Its tones muffled the footsteps"
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
	dc.b	"but put it back; it looked dangerous."
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
	dc.b	"would probably be best."
	dc.b	$C4

loc_18F9B:
	dc.b	"The dam's lock released; the sound"
	dc.b	$C1
	dc.b	"of rushing water followed."
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
	dc.b	"Motavia's former landscape."
	dc.b	$C4

loc_19056:
	dc.b	"A card as red as the sun setting"
	dc.b	$C1
	dc.b	"over the Motavian soil."
	dc.b	$C4

loc_19085:
	dc.b	$42, "Darum. Your little girl, Tiem,"
	dc.b	$C1
	dc.b	"is a real good kid, don't you think?"
	dc.b	$C3
	dc.b	"We're keeping her safe in the Tower"
	dc.b	$C1
	dc.b	"of Nido. If you don't want your daughter"
	dc.b	$C3
	dc.b	"killed, bring 50,000 meseta"
	dc.b	$C1
	dc.b	"within a month! Understand?", $42
	dc.b	$C3
	dc.b	"That's what it says. So Darum had been"
	dc.b	$C1
	dc.b	"killing and stealing for his daughter's sake..."
	dc.b	$C4

loc_19138:
	dc.b	"A device that records events"
	dc.b	$C1
	dc.b	"in the Biosystem."
	dc.b	$C4

loc_1916E:
	dc.b	"If we deliver this to Paseo, we'll learn"
	dc.b	$C1
	dc.b	"what caused the biohazards."
	dc.b	$C4
	
loc_191BA:
	dc.b	$BB
	dc.b	" isn't carrying anything."
	dc.b	$C4

loc_191D5:
	dc.b	$BB
	dc.b	" made sure the "
	dc.b	$BF
	dc.b	$C1
	dc.b	"was there, and put it back."
	dc.b	$C4

loc_191F5:
	dc.b	$42, "How can I make Father"
	dc.b	$C1
	dc.b	"change his ways, I wonder", $47, $47, $47, $42
	dc.b	$C4

loc_1921C:
	dc.b	"You can't use that here!"
	dc.b	$C4

loc_19235:
	dc.b	"Contacting Data Memory!"
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
	dc.b	" knows no field Techniques."
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
	dc.b	"Some of "
	dc.b	$BB
	dc.b	"'s life was shared"
	dc.b	$C1
	dc.b	"with everyone", $47, $47, $47
	dc.b	$C4

loc_19319:
	dc.b	$BB
	dc.b	" held "
	dc.b	$BC
	dc.b	" close."
	dc.b	$C1
	dc.b	"Some of "
	dc.b	$BB
	dc.b	"'s life flowed to "
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
	dc.b	"But a body ravaged by poison "
	dc.b	$C1
	dc.b	"cannot be healed."
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
	dc.b	" refused to equip the"
	dc.b	$C1
	dc.b	$BF
	dc.b	"."
	dc.b	$C4

loc_19426:
	dc.b	$BB
	dc.b	" removed the "
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
	dc.b	"Welcome to Data Memory."
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
	dc.b	"Shall I save your memories and"
	dc.b	$C1
	dc.b	"experiences into storage?"
	dc.b	$C5

loc_194CD:
	dc.b	"I see", $47, $47, $47, " Then, please take care."
	dc.b	$C4

loc_194EF:
	dc.b	"Which number shall I save them under?"
	dc.b	$C5

loc_19516:
	dc.b	"Something is already saved there."
	dc.b	$C1
	dc.b	"Is it all right to erase the old data?"
	dc.b	$C5

loc_1955A:
	dc.b	"Then, please give the file a name."
	dc.b	$C5

loc_19575:
	dc.b	"The saving process is complete."
	dc.b	$C4

loc_19599:
	dc.b	"Are you setting out for battle again?"
	dc.b	$C5

loc_195D8:
	dc.b	"I see. Well then, until we meet again."
	dc.b	$C1
	dc.b	"Goodbye."
	dc.b	$C4

loc_195EC:
	dc.b	"We meet again, ", $BB, "."
	dc.b	$C4

loc_195FE:
	dc.b	"Take care out there."
	dc.b	$C4
	
loc_19614:
	dc.b	$BB
	dc.b	" can't go up any more levels."
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
	dc.b	"Who needs to be regenerated?"
	dc.b	$C5

loc_1969C:
	dc.b	"Hey, now, this is no time for jokes!"
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
	dc.b	"Whom shall I revive, then?"
	dc.b	$C5

loc_19767:
	dc.b	"Welcome to the Clone Lab."
	dc.b	$C1
	dc.b	"Who needs to be regenerated?"
	dc.b	$C3
	dc.b	"This girl, Nei? You want her restored?"
	dc.b	$C1
	dc.b	"Hmm, what could have left her cells"
	dc.b	$C3
	dc.b	"all scrambled like this? I'm sorry, but all"
	dc.b	$C1
	dc.b	"her non-human parts are destroyed"
	dc.b	$C3
	dc.b	"beyond repair", $47, $47, $47, " Bringing this child"
	dc.b	$C1
	dc.b	"back to life is utterly impossible", $47, $47, $47

loc_19825:
	dc.b	"Now, it would be best to let her rest"
	dc.b	$C3
	dc.b	"in peace in the soil of mother Paseo..."
	dc.b	$C1
	dc.b	"Death comes to everyone in time."
	dc.b	$C3
	dc.b	"But didn't she live her short life"
	dc.b	$C1
	dc.b	"to the fullest? Then surely that"
	dc.b	$C3
	dc.b	"is enough. Don't lose heart, now."
	dc.b	$C4

loc_198AD:
	dc.b	"Have you never heard it said that"
	dc.b	$C1
	dc.b	"even hell's judgment depends on money?"
	dc.b	$C4
	
loc_198EC:
	dc.b	"Oh, there's another young man who's fallen."
	dc.b	$C1
	dc.b	"That one I can bring back to life."
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
	dc.b	"then, I'm afraid", $47, $47, $47
	dc.b	$C4

loc_199CC:
	dc.b	"I see. Take care of yourself", $47, $47, $47
	dc.b	$C4

loc_199F7:
	dc.b	"Take care, and stay safe."
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
	dc.b	"Who'll carry it?"
	dc.b	$C5

loc_19ADB:
	dc.b	"You, using this? What a joke!"
	dc.b	$C1
	dc.b	"Are you sure?"
	dc.b	$C5

loc_19B0B:
	dc.b	"Didn't think so."
	dc.b	$C1
	dc.b	"Then, how about something else?"
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
	dc.b	"Hey there! Need somethin' from"
	dc.b	$C1
	dc.b	"my shop?"
	dc.b	$C5

loc_19C22:
	dc.b	"The "
	dc.b	$BF
	dc.b	", huh?"
	dc.b	$C1
	dc.b	"Who's carryin' it?"
	dc.b	$C5

loc_19C4D:
	dc.b	"You can't use this thing!"
	dc.b	$C1
	dc.b	"That fine by you?"
	dc.b	$C5

loc_19C7B:
	dc.b	"Fair enough."
	dc.b	$C1
	dc.b	"Somethin' else interest you instead?"
	dc.b	$C5

loc_19CA1:
	dc.b	"Whoa, whoa. I don't do loans, and I don't do"
	dc.b	$C1
	dc.b	"credit."
	dc.b	$C4

loc_19CD0:
	dc.b	"Here ya go! Hope it suits you!"
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
	if shop_no_reprompt
	scriptofs	Script_ItemStore_NoCarrier, loc_19FDF	; $11
	scriptofs	Script_ItemStore_AnythingElse, Script_ItemStore_NoCarrier	; $12
	endif

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
	dc.b	"I've never seen that item before,"
	dc.b	$C1
	dc.b	"so I can't put a price on it."
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
	dc.b	"It seems like you can't carry any more."
	dc.b	$C1
	dc.b	"Is there someone else who will carry it?"
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
	dc.b	"Is there anything else you need?"
	dc.b	$C5

loc_19F5E:
	dc.b	"Goodbye. Please come again."
	dc.b	$C4
	
loc_19F78:
	dc.b	"Wh-what? Y-you can't spring that on"
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
	dc.b	"Danyaraha? Bebekucharaaba!"
	dc.b	$C4

	if shop_no_reprompt
Script_ItemStore_NoCarrier:
	dc.b	"Oh, so you've reconsidered."
	dc.b	$C1
	dc.b	"Perhaps something else, then?"
	dc.b	$C5

Script_ItemStore_AnythingElse:
	dc.b	"In that case, is there anything else"
	dc.b	$C1
	dc.b	"I can help you with?"
	dc.b	$C5
	endif
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
	dc.b	"Back home, as I prepared for the trip,"
	dc.b	$C1
	dc.b	"Nei appeared, looking worried."
	dc.b	$C4

loc_1A066:
	dc.b	$C2
	dc.b	$42, "Nei, we're going to be apart for a while."
	dc.b	$C1
	dc.b	"Be strong, even without me.", $42
	dc.b	$C4

loc_1A08A:
	dc.b	$C2
	dc.b	"Nei just stared at me. That's right,"
	dc.b	$C1
	dc.b	"when Nei and I first met, she looked at"
	dc.b	$C1
	dc.b	"me just like this. That must have been"
	dc.b	$C1
	dc.b	"around seven months ago, I think."
	dc.b	$C3
	dc.b	"Because she was born from fusing"
	dc.b	$C1
	dc.b	"biomonster cells with human ones,"
	dc.b	$C1
	dc.b	"Nei had been shunned and hated by people,"
	dc.b	$C1
	dc.b	"and nearly killed by them."
	dc.b	$C4

loc_1A182:
	dc.b	$C2
	dc.b	$42, "When I saved you, you were still"
	dc.b	$C1
	dc.b	"little, but you should be fine on"
	dc.b	$C1
	dc.b	"your own now, right? Besides, my"
	dc.b	$C1
	dc.b	"journey could become very dangerous."
	dc.b	$C3
	dc.b	"I don't want to put you at risk."
	dc.b	$C1
	dc.b	"You understand, don't you? It may not have"
	dc.b	$C1
	dc.b	"been for very long, but it was fun having a"
	dc.b	$C1
	dc.b	"little sister like you.", $42
	dc.b	$C4

loc_1A236:
	dc.b	$C2
	dc.b	"But even through my reassurances,"
	dc.b	$C1
	dc.b	"Nei stood in front of the door,"
	dc.b	$C1
	dc.b	"determined not to let me leave."
	dc.b	$C4

loc_1A270:
	dc.b	$C2
	dc.b	$42
	dc.b	$BB
	dc.b	", please! Take Nei with you."
	dc.b	$C1
	dc.b	"Nei will do anything for "
	dc.b	$BB
	dc.b	"!", $42
	dc.b	$C4

loc_1A2A8:
	dc.b	"I picked up my bag and stood up, but"
	dc.b	$C1
	dc.b	"Nei would not budge from the door,"
	dc.b	$C1
	dc.b	"so I had no choice but to take her"
	dc.b	$C1
	dc.b	"along."
	dc.b	$C4

loc_1A31D:
	dc.b	"Ah, home at last."
	dc.b	$C1
	dc.b	"But there's no time to rest."
	dc.b	$C1
	dc.b	"Before I set out again, I should"
	dc.b	$C1
	dc.b	"check on my companions."
	dc.b	$C4

loc_1A38B:
	dc.b	"There should be no problems with this."
	dc.b	$C1
	dc.b	"Okay, time to head out again."
	dc.b	$C4

loc_1A3C2:
	dc.b	"This is a hard journey, and lives are at"
	dc.b	$C1
	dc.b	"stake. I must choose the party carefully."
	dc.b	$C5

loc_1A401:
	dc.b	"Let's see who's here right now."
	dc.b	$C5

loc_1A421:
	dc.b	"Oh, someone's knocking at the door."
	dc.b	$C4

loc_1A43E:
	dc.b	"Now that "
	dc.b	$BB
	dc.b	" has joined,"
	dc.b	$C1
	dc.b	"let's confirm our companions."
	dc.b	$C5

loc_1A473:
	dc.b	"Then let's unassign these members for now"
	dc.b	$C1
	dc.b	"and reorganize the party."
	dc.b	$C5

loc_1A4CB:
	dc.b	"Who should join the party?"
	dc.b	$C5

loc_1A4EE:
	dc.b	$BB
	dc.b	" joined."
	dc.b	$C1
	dc.b	"Should I add more members?"
	dc.b	$C5

loc_1A516:
	dc.b	$BB
	dc.b	" joined. That makes four."
	dc.b	$C1
	dc.b	"Now, let's head out again."
	dc.b	$C4
; unused bytes of the stock ROM
	dc.b	$32, $28, $C1, $00, $16, $29, $38, $45, $37, $C1, $3D, $44, $C4
; ---------------------------------------------

loc_1A560:
	dc.b	$42, "That name suits you."
	dc.b	$C1
	dc.b	"I'm very glad to meet you.", $42
	dc.b	$C5

loc_1A59C:
	dc.b	$C2
	dc.b	$42, "Understood. And what shall it be?", $42
	dc.b	$C5
	
loc_1A5C4:
	dc.b	$C2
	dc.b	$42, "All right. And what name will"
	dc.b	$C1
	dc.b	"you give me?", $42
	dc.b	$C5
	
loc_1A5EC:
	dc.b	$C2
	dc.b	$42, "Can't be helped, I guess. Oh, well."
	dc.b	$C1
	dc.b	"Give me a cool one, will ya?", $42
	dc.b	$C5
	
loc_1A614:
	dc.b	$C2
	dc.b	$42, "I am Shilka of the wind."
	dc.b	$C1
	dc.b	"Nothing more, and nothing less.", $42
	dc.b	$C4

loc_1A650:
	dc.b	$C2
	dc.b	$42, "Then, I'll call you "
	dc.b	$BB
	dc.b	"."
	dc.b	$C1
	dc.b	"Glad to have you.", $42
	dc.b	$C4
	
loc_1A664:
	dc.b	$C2
	dc.b	$42, $47, $47, $47, " I'm terribly sorry.", $42
	dc.b	$C4

loc_1A672:
	dc.b	$C2
	dc.b	$42, "Forgive my dropping by. I hear people called"
	dc.b	$C1
	dc.b	$BB
	dc.b	" and Nei are investigating the"
	dc.b	$C1
	dc.b	"mystery of the biomonsters. I don't"
	dc.b	$C1
	dc.b	"mean to brag, but I'm a professional"
	dc.b	$C3
	dc.b	"hunter of biomonsters. I don't have much"
	dc.b	$C1
	dc.b	"in the way of sword skills, and I have no"
	dc.b	$C1
	dc.b	"special powers, either. But I can handle"
	dc.b	$C1
	dc.b	"almost any kind of gun."
	dc.b	$C3

loc_1A72B:
	dc.b	"If possible, I'd like to join you on your"
	dc.b	$C1
	dc.b	"journey. I should introduce myself."
	dc.b	$C1
	dc.b	"I'm Rudger", $47, $47, $47, " Rudger Steiner."
	dc.b	$C3
	dc.b	"But if you want to change my name,"
	dc.b	$C1
	dc.b	"maybe you can think of a better one."
	dc.b	$C1
	dc.b	"Will you give me a new name?", $42
	dc.b	$C5

loc_1A7BB:
	dc.b	$C2
	dc.b	$42, "Excuse me. You must be "
	dc.b	$BB
	dc.b	"."
	dc.b	$C1
	dc.b	"How do you do? My name is Anne Saga."
	dc.b	$C1
	dc.b	"I'm a doctor, just out of medical school."
	dc.b	$C1
	dc.b	"I heard you're investigating the mystery"
	dc.b	$C3
	dc.b	"of the biomonsters, so my apologies for"
	dc.b	$C1
	dc.b	"bothering you, but please let me join you."
	dc.b	$C1
	dc.b	"I'm not very good at fighting, but I can heal"
	dc.b	$C1
	dc.b	"those who are hurt in battle."
	dc.b	$C3
	dc.b	"As a sign of our new friendship,"
	dc.b	$C1
	dc.b	"would you give me a name?", $42
	dc.b	$C5

loc_1A8B6:
	dc.b	$C2
	dc.b	$42, "How do you do, "
	dc.b	$BB
	dc.b	"?"
	dc.b	$C1
	dc.b	"I'm Huey Lean. I'm a scholar, and"
	dc.b	$C1
	dc.b	"I study living things. I heard about"
	dc.b	$C1
	dc.b	"you, "
	dc.b	$BB
	dc.b	", and wanted to meet you,"
	dc.b	$C3
	dc.b	"so here I am. Biomonster or not,"
	dc.b	$C1
	dc.b	"a life is a life."
	dc.b	$C1
	
loc_1A939:
	dc.b	"I don't want to defeat them, but in order to"
	dc.b	$C1
	dc.b	"protect the weak, fighting is necessary."
	dc.b	$C3
	dc.b	"My skills may be of use for that."
	dc.b	$C1
	dc.b	"If you'll have me, please let me join you."
	dc.b	$C3
	dc.b	"Oh, I know! If you gave me a nickname,"
	dc.b	$C1
	dc.b	"wouldn't it feel like we've become friends?", $42
	dc.b	$C5

loc_1A9E1:
	dc.b	$C2
	dc.b	$42, "I've been wanting to meet you, "
	dc.b	$BB
	dc.b	"."
	dc.b	$C1
	dc.b	"I'm Amia Amirsky. People have taken to"
	dc.b	$C1
	dc.b	"calling me a counterhunter."
	dc.b	$C3
	dc.b	"In this world there are good hunters,"
	dc.b	$C1
	dc.b	"and there are bad ones", $47, $47, $47, " The bad"
	dc.b	$C1
	dc.b	"ones, I quietly send on to the next world", $47, $47, $47
	dc.b	$C3
	
loc_1AA75:
	dc.b	"That is my line of work", $47, $47, $47, " And of course,"
	dc.b	$C1
	dc.b	"hunters aren't my only targets", $47, $47, $47, " "
	dc.b	$C1
	dc.b	"I don't care for guns, but with a bladed"
	dc.b	$C3
	dc.b	"weapon, I am unmatched."
	dc.b	$C1
	dc.b	"You won't regret taking me along."
	dc.b	$C3
	dc.b	"Yes", $47, $47, $47, " perhaps a new name, to cast"
	dc.b	$C1
	dc.b	"off my past, would be nice", $47, $47, $47, $42
	dc.b	$C5

loc_1AB55:
	dc.b	$C2
	dc.b	$42, "Phew", $47, $47, $47, " Finally caught you!"
	dc.b	$C1
	dc.b	"You sure were out a lot! You're the"
	dc.b	$C1
	dc.b	"ones going around with a cute little"
	dc.b	$C1
	dc.b	"sister, beating up the bad guys, right?"
	dc.b	$C3
	dc.b	"So why didn't you call me? I'd rather not"
	dc.b	$C1
	dc.b	"deal with the slimy, gooey critters,"
	dc.b	$C1
	dc.b	"but if it's machines or mechs that"
	dc.b	$C1
	dc.b	"need wrecking, leave it to me!"
	dc.b	$C3

loc_1ABE4:
	dc.b	"I'm a gentleman, so the girls can"
	dc.b	$C1
	dc.b	"travel with me without a worry!"
	dc.b	$C1
	dc.b	"I'm Kains Ji An, the scrap dealer!"
	dc.b	$C3
	dc.b	"Hey! What's with that look?"
	dc.b	$C1
	dc.b	"You got a problem with my name?", $42
	dc.b	$C5

loc_1AC76:
	dc.b	$C2
	dc.b	$42, "Hello, "
	dc.b	$BB
	dc.b	". You're a cute"
	dc.b	$C1
	dc.b	"boy, just like they say. Shilka Levinia"
	dc.b	$C1
	dc.b	"is my name, you know. I'm not too"
	dc.b	$C1
	dc.b	"interested in things like justice or peace,"
	dc.b	$C3
	dc.b	"with me being a thief. I steal all sorts"
	dc.b	$C1
	dc.b	"of things just to pass the time. I hear"
	dc.b	$C1
	dc.b	$BB
	dc.b	" and the others are on"
	dc.b	$C1
	dc.b	"a journey full of thrills."
	dc.b	$C3
	
loc_1AD47:
	dc.b	"It sounds fun, so maybe I'll come along."
	dc.b	$C1
	dc.b	"But I'm Shilka of the Wind."
	dc.b	$C1
	dc.b	"Nothing will ever tie me down! If that's"
	dc.b	$C1
	dc.b	"all right with you, I'll join!"
	dc.b	$C3
	dc.b	"Oh?! What's this? You want to"
	dc.b	$C1
	dc.b	"give me a name?", $42
	dc.b	$C5

loc_1ADE5:
	dc.b	$42, "Huh? Shilka's come back", $47, $47, $47, $42
	dc.b	$C4

loc_1ADFE:
	dc.b	$C2
	dc.b	$42, "Heh heh. Sorry to make you worry."
	dc.b	$C1
	dc.b	"A breeze lured me out, and I went"
	dc.b	$C1
	dc.b	"for a carefree little stroll."
	dc.b	$C1
	dc.b	$BB
	dc.b	", come on, let's head out again.", $42
	dc.b	$C4

loc_1AE6F:
	dc.b	$47, $47, $47, " or so I thought, but there aren't"
	dc.b	$C1
	dc.b	"enough members to reorganize."
	dc.b	$C5

loc_1AEAA:
	dc.b	"Right now I'm traveling alone."
	dc.b	$C1
	dc.b	"How lonely it is!"
	dc.b	$C5

loc_1AEF2:
	dc.b	"Right now I'm traveling with "
	dc.b	$BB
	dc.b	","
	dc.b	$C1
	dc.b	"just the two of us."
	dc.b	$C5

loc_1AF19:
	dc.b	"Traveling with me right now"
	dc.b	$C1
	dc.b	"are "
	dc.b	$BB
	dc.b	" and "
	dc.b	$BB
	dc.b	"."
	dc.b	$C5

loc_1AF45:
	dc.b	"Traveling with me right now"
	dc.b	$C1
	dc.b	"are "
	dc.b	$BB
	dc.b	", "
	dc.b	$BB
	dc.b	" and "
	dc.b	$BB
	dc.b	"."
	dc.b	$C5

loc_1AF74:
	dc.b	"Shall we continue our journey as is?"
	dc.b	$C5

loc_1AFA5:
	dc.b	$BB
	dc.b	" joined. Much more reassuring"
	dc.b	$C1
	dc.b	"than just two. Well, let's head out again."
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
	dc.b	"You may address me as Avancino."
	dc.b	$C1
	dc.b	"Avancino the Musician, if you so please."
	dc.b	$C3
	dc.b	"You all have come to hear my humble sound,"
	dc.b	$C1
	dc.b	"naturally?"
	dc.b	$C5
	
loc_1B030:
	dc.b	"Oh my! How delightful!!"
	dc.b	$C1
	dc.b	"Then, please, do pick a song."
	dc.b	$C5
	
loc_1B044:
	dc.b	"Oh my. So that means", $47, $47, $47, " I've got it!"
	dc.b	$C1
	dc.b	"You've come to learn the piano, hm?"
	dc.b	$C5
	
; it always sounded to me that it's Rolf who says the line, but it's actually Ustvestia. To be honest I realized this
; when playing the Japanese version. It's translated poorly in my opinion. He says that you should leave since he's very busy
loc_1B077:
	dc.b	"Oh. Well then, as for myself, I'm terribly"
	dc.b	$C1
	dc.b	"busy, so if you'll excuse me."
	dc.b	$C4
	
loc_1B0B3:
	dc.b	"Oh my! So you'd acknowledge one such as I"
	dc.b	$C1
	dc.b	"to be a truly great musician?"
	dc.b	$C5
	
loc_1B0D2:
	dc.b	"Hmph. The very idea! I hate you."
	dc.b	$C1
	dc.b	"Begone!!"
	dc.b	$C4
	
loc_1B0F4:
	dc.b	"Which of you will take the lesson?"
	dc.b	$C5
	
loc_1B10B:
	dc.b	"Oh! Well, aren't you awfully cute."
	dc.b	$C1
	dc.b	"I'll make it 2000 meseta. How's that?"
	dc.b	$C5
	
loc_1B143:
	dc.b	"Very well. Lessons are 5000 meseta."
	dc.b	$C1
	dc.b	"Is that acceptable?"
	dc.b	$C5
	
loc_1B171:
	dc.b	"You don't have enough money, hm?"
	dc.b	$C1
	dc.b	"Don't undersell one such as I!"
	dc.b	$C4
	
loc_1B19D:
	dc.b	"In that case, allow me to teach you."
	dc.b	$C4
	
loc_1B1B9:
	dc.b	"With this, you, too, have become an artiste."
	dc.b	$C1
	dc.b	"Do come again, won't you!"
	dc.b	$C4
	
loc_1B1E8:
	dc.b	$BB
	dc.b	" learned the Musica Technique."
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
	dc.b	"Hi! I'm doing research on making"
	dc.b	$C1
	dc.b	"a mysterious chewing gum."
	dc.b	$C4
	
loc_1B244:
	dc.b	"Do you know about Maruera Leaves?"
	dc.b	$C5
	
loc_1B269:
	dc.b	"I want some. If you find any, let me know!"
	dc.b	$C4
	
loc_1B2A4:
	dc.b	"At the top of a small island in the"
	dc.b	$C1
	dc.b	"Motavian sea, there's a Maruera tree."
	dc.b	$C3
	dc.b	"Its leaves efficiently produce oxygen,"
	dc.b	$C1
	dc.b	"so if I take their extract and make"
	dc.b	$C3
	dc.b	"gum from it, it'll become possible to breathe"
	dc.b	$C1
	dc.b	"underwater!"
	dc.b	$C4
	
loc_1B360:
	dc.b	"Ah! That! Could that be a Maruera"
	dc.b	$C1
	dc.b	"Leaf?! Wow! Hey, will you give it to me?"
	dc.b	$C5
	
loc_1B391:
	dc.b	"Thanks. Aren't you a good person."
	dc.b	$C1
	dc.b	"Wait a moment. The gum's nearly ready."
	dc.b	$C3
	dc.b	"There, done. I made plenty, so you can"
	dc.b	$C1
	dc.b	"have some too. Take it. See you!"
	dc.b	$C4
	
loc_1B3FA:
	dc.b	"That's too bad. Goodbye."
	dc.b	$C4

; referenced but immediately overwritten in the code, thus it's never seen
loc_1B41F:
	dc.b	"What should I study next, I wonder?"
	dc.b	$C1
	dc.b	"If you find anything fun, tell me, okay?"
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
	if teleport_decline_retry
	scriptofs	Script_TeleportStation_Retry, loc_1B59B	; 9
	endif
	
loc_1B44C:
	dc.b	"Welcome. This is the Teleport Service."
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
	dc.b	"Once you've memorized a town's name,"
	dc.b	$C1
	dc.b	"please be sure to come by."
	dc.b	$C4

loc_1B517:
	dc.b	"Well then, please come again."
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
	dc.b	"A shame that we were unable to help you."
	dc.b	$C4

loc_1B576:
	dc.b	"You don't seem to have enough money."
	dc.b	$C4

loc_1B59B:
	dc.b	"Teleport machine, switch on!"
	dc.b	$C1
	dc.b	"Take care on your way!"
	dc.b	$C4
	if teleport_decline_retry

Script_TeleportStation_Retry:
	dc.b	"A different destination, then, perhaps?"
	dc.b	$C5
	endif
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
	dc.b	"This is the Central Tower of Paseo,"
	dc.b	$C1
	dc.b	"the capital of Motavia."
	dc.b	$C1
	dc.b	"Where shall we go?"
	dc.b	$C5
	
loc_1B5F6:
	dc.b	"Huh? Something's going on."
	dc.b	$C1
	dc.b	"What could it be?"
	dc.b	$C7
	
loc_1B60B:
	dc.b	$42, "It's a disaster!! The lake is"
	dc.b	$C1
	dc.b	"overflowing!! There's been an accident"
	dc.b	$C1
	dc.b	"at AMeDAS, and all the water that"
	dc.b	$C1
	dc.b	"should have become rain is pouring"
	dc.b	$C3
	dc.b	"into the lake instead!! Tons and tons of it!!"
	dc.b	$C1
	dc.b	"At this rate, Motavia is going to be"
	dc.b	$C1
	dc.b	"completely flooded!!"
	dc.b	$C3
	dc.b	"You should run for your lives, too!", $42
	dc.b	$C1
	dc.b	"This is a catastrophe!"
	dc.b	$C4

loc_1B6CD:
	dc.b	"Okay, I have to take this to the Governor."
	dc.b	$C4
	
loc_1B6EC:
	dc.b	"What on earth is happening to Motavia?"
	dc.b	$C1
	dc.b	"With Nei First dead, the biomonsters"
	dc.b	$C1
	dc.b	"must surely have been wiped out."
	dc.b	$C3
	dc.b	"But why was Nei First created?"
	dc.b	$C1
	dc.b	"Who was behind it, and to what end?"
	dc.b	$C4
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
	dc.b	"Hey, how have you been?"
	dc.b	$C1
	dc.b	"Anything I can do for you?"
	dc.b	$C5
	
loc_1B7F1:
	dc.b	"Whose belongings will you leave"
	dc.b	$C1
	dc.b	"with me?"
	dc.b	$C5
	
loc_1B820:
	dc.b	"Which ones will you leave?"
	dc.b	$C5
	
loc_1B82D:
	dc.b	"Got it. I'll keep them safe for you"
	dc.b	$C1
	dc.b	"until you come back."
	dc.b	$C4
	
loc_1B861:
	dc.b	"Sorry. My locker is already"
	dc.b	$C1
	dc.b	"packed full of stuff."
	dc.b	$C4
	
loc_1B890:
	dc.b	"I don't mean to presume, but maybe"
	dc.b	$C1
	dc.b	"it would be better if you held on to that?"
	dc.b	$C4
	
loc_1B8BA:
	dc.b	"Anything else I can do for you?"
	dc.b	$C5
	
loc_1B8D2:
	dc.b	"Take care, then."
	dc.b	$C1
	dc.b	"And come by to see me again!"
	dc.b	$C4
	
loc_1B901:
	dc.b	"This is everything of yours I have for now."
	dc.b	$C1
	dc.b	"Which ones will you take?"
	dc.b	$C5
	
loc_1B93B:
	dc.b	"That's odd. I'm pretty sure you"
	dc.b	$C1
	dc.b	"didn't leave anything with me."
	dc.b	$C4

loc_1B97C:
	dc.b	"Taking this one, huh?"
	dc.b	$C1
	dc.b	"There you go. It's all yours."
	dc.b	$C4
	
loc_1B9BC:
	dc.b	"Huh? What luggage?"
	dc.b	$C1
	dc.b	"I don't see any."
	dc.b	$C4
	
loc_1B9DF:
	dc.b	"Who's carrying it?"
	dc.b	$C5
	
loc_1B9F9:
	dc.b	"You can't carry any more."
	dc.b	$C1
	dc.b	"Will someone else take it?"
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
	dc.b	"This is the last spaceship left"
	dc.b	$C1
	dc.b	"on Motavia. It flies automatically,"
	dc.b	$C3
	dc.b	"so anyone can pilot it."
	dc.b	$C1
	dc.b	"Shall we go to Dezolis?"
	dc.b	$C5
	
loc_1BA9E:
	dc.b	"Departing for Dezolis."
	dc.b	$C4
	
loc_1BAB4:
	dc.b	$BB
	dc.b	" and the others left the"
	dc.b	$C1
	dc.b	"Central Tower without boarding."
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
	dc.b	"Welcome! This is the Library."
	dc.b	$C4

loc_1BB25:
	dc.b	"I see. Good day, then."
	dc.b	$C4
	
loc_1BB41:
	dc.b	"Is there anything else you'd like"
	dc.b	$C1
	dc.b	"to look up?"
	dc.b	$C5
	
loc_1BB70:
	dc.b	"Motavia was once a barren world, nothing"
	dc.b	$C1
	dc.b	"but desert. But after Mother Brain"
	dc.b	$C1
	dc.b	"was brought to Motavia, it became"
	dc.b	$C1
	dc.b	"a lush, green planet."
	dc.b	$C3
	dc.b	"That is because it built systems such"
	dc.b	$C1
	dc.b	"as the Biosystem and AMeDAS, and all"
	dc.b	$C1
	dc.b	"development followed Mother Brain's"
	dc.b	$C1
	dc.b	"meticulous plans."
	dc.b	$C4

loc_1BC48:
	dc.b	"The Biosystem creates life adapted"
	dc.b	$C1
	dc.b	"to Motavia through selective breeding."
	dc.b	$C1
	dc.b	"The DNA of every living thing in"
	dc.b	$C1
	dc.b	"Algol is stored there."
	dc.b	$C3

loc_1BCA1:
	dc.b	"It is thanks to the Biosystem that"
	dc.b	$C1
	dc.b	"Motavia could become the leading"
	dc.b	$C1
	dc.b	"agricultural planet in the Algol star system."
	dc.b	$C3
	
loc_1BD50:
	dc.b	"Two years ago, however, an accident"
	dc.b	$C1
	dc.b	"at the Biosystem gave rise to creatures"
	dc.b	$C1
	dc.b	"that posed a threat to people. This is known"
	dc.b	$C1
	dc.b	"as the ", $42, "biohazard", $42, ". The Biosystem was"
	dc.b	$C3
	dc.b	"immediately sealed off, but to this day,"
	dc.b	$C1
	dc.b	"neither the cause nor a solution has been"
	dc.b	$C1
	dc.b	"made public."
	dc.b	$C4

loc_1BE34:
	dc.b	"AMeDAS is the system that regulates"
	dc.b	$C1
	dc.b	"Motavia's weather. It keeps the"
	dc.b	$C1
	dc.b	"temperature from rising, and makes"
	dc.b	$C1
	dc.b	"the rain fall in appropriate measure."
	dc.b	$C3
	dc.b	"For Motavia, normally lacking in rainfall"
	dc.b	$C1
	dc.b	"and water,"
	dc.b	$C1
	
loc_1BEB1:
	dc.b	"AMeDAS has become something"
	dc.b	$C1
	dc.b	"completely indispensable."
	dc.b	$C4
	
loc_1BF2C:
	dc.b	"From the lake of Motavia, rivers run"
	dc.b	$C1
	dc.b	"out in four directions: east, west,"
	dc.b	$C1
	dc.b	"south and north. Between the rivers"
	dc.b	$C1
	dc.b	"and the lake stand dams, which"
	dc.b	$C3

loc_1BFDB:
	dc.b	"regulate how much water flows from"
	dc.b	$C1
	dc.b	"the lake into the rivers. The four dams"
	dc.b	$C1
	dc.b	"are the Green Dam, the Yellow Dam,"
	dc.b	$C1
	dc.b	"the Red Dam and the Blue Dam. To enter"
	dc.b	$C3
	
loc_1C09B:
	dc.b	"a dam, a keycard of corresponding color"
	dc.b	$C1
	dc.b	"is required. The cards are said to be kept in"
	dc.b	$C1
	dc.b	"the Control Tower, but in which town"
	dc.b	$C1
	dc.b	"remains a secret."
	dc.b	$C4

loc_1C163:
	dc.b	"Mother Brain is an enormous computer with"
	dc.b	$C1
	dc.b	"the power to run the entire Algol star"
	dc.b	$C1
	dc.b	"system. Our lives are supported and"
	dc.b	$C1
	dc.b	"watched over by Mother Brain."
	dc.b	$C3
	
loc_1C1CF:
	dc.b	"Mother Brain was brought to Palma in"
	dc.b	$C1
	dc.b	"AW 845, and its network subsequently"
	dc.b	$C1
	dc.b	"expanded to encompass Motavia and"
	dc.b	$C1
	dc.b	"Dezolis."
	dc.b	$C3

loc_1C25B:
	dc.b	"Mother Brain also regulates systems such"
	dc.b	$C1
	dc.b	"as the Biosystem, AMeDAS, and the dams."
	dc.b	$C1
	dc.b	"While Mother Brain is essential to our"
	dc.b	$C1
	dc.b	"survival, its location, and the identity"
	dc.b	$C3
	dc.b	"of its creators, is unknown."
	dc.b	$C4

loc_1C323:
	dc.b	"The analysis of the System Recorder is"
	dc.b	$C1
	dc.b	"complete. The accident at the Biosystem"
	dc.b	$C1
	dc.b	"happened because a surplus of energy"
	dc.b	$C1
	dc.b	"was fed into the system."
	dc.b	$C3

loc_1C3D4:
	dc.b	"As a result, living creatures underwent"
	dc.b	$C1
	dc.b	"rapid evolution. These creatures fall"
	dc.b	$C1
	dc.b	"outside the natural order; they are"
	dc.b	$C1
	dc.b	"things that should not exist."
	dc.b	$C3
	dc.b	"And because they were set loose,"
	dc.b	$C1
	dc.b	"the entire natural cycle has been thrown"
	dc.b	$C1
	dc.b	"into disarray."
	dc.b	$C4

loc_1C48D:
	dc.b	"Please look at this graph. It shows"
	dc.b	$C1
	dc.b	"the energy used at the Biosystem"
	dc.b	$C1
	dc.b	"over the last several years."
	dc.b	$C3
	dc.b	"Now let's overlay the graphs of temperature"
	dc.b	$C1
	dc.b	"and rainfall."
	dc.b	$C4

loc_1C528:
	dc.b	"In other words, it seems the energy"
	dc.b	$C1
	dc.b	"AMeDAS uses to regulate temperature"
	dc.b	$C1
	dc.b	"and rainfall flowed into the Biosystem,"
	dc.b	$C1
	dc.b	"for reasons currently unknown."
	dc.b	$C3
	dc.b	"Perhaps the biohazard was secretly"
	dc.b	$C1
	dc.b	"masterminded by someone", $47, $47, $47
	dc.b	$C3

loc_1C5D9:
	dc.b	"In any case, please find out why"
	dc.b	$C1
	dc.b	"energy flowed out of AMeDAS."
	dc.b	$C3
	dc.b	"And if you are going south, please"
	dc.b	$C1
	dc.b	"take this with you. With it, you"
	dc.b	$C1
	dc.b	"should be able to cross the bridge"
	dc.b	$C1
	dc.b	"over the western river. Good luck."
	dc.b	$C4

loc_1C69B:
	dc.b	"If you'd like to look something up"
	dc.b	$C1
	dc.b	"here, please choose a file."
	dc.b	$C5

loc_1C6DF:
	dc.b	"I hear "
	dc.b	$BB
	dc.b	" and the others are"
	dc.b	$C1
	dc.b	"going to the Biosystem to get the"
	dc.b	$C1
	dc.b	"System Recorder."
	dc.b	$C4

loc_1C737:
	dc.b	"Have you found the cause of the accident"
	dc.b	$C1
	dc.b	"that sent energy from AMeDAS into the"
	dc.b	$C1
	dc.b	"Biosystem? I can't help worrying about"
	dc.b	$C1
	dc.b	"what is happening at AMeDAS."
	dc.b	$C4

loc_1C7DE:
	dc.b	$BB
	dc.b	", is it true that Motavia"
	dc.b	$C1
	dc.b	"is going to be flooded?"
	dc.b	$C1
	dc.b	"If only the four dams could"
	dc.b	$C1
	dc.b	"somehow be opened", $47, $47, $47
	dc.b	$C4

loc_1C835:
	dc.b	$BB
	dc.b	", thanks to all of you, Motavia"
	dc.b	$C1
	dc.b	"was spared from the flood."
	dc.b	$C3
	dc.b	"Why, then, have you been branded as the"
	dc.b	$C1
	dc.b	"criminals who made Mother Brain"
	dc.b	$C1
	dc.b	"go haywire?"
	dc.b	$C3
	dc.b	"What! Someone who holds the key to"
	dc.b	$C1
	dc.b	"Mother Brain is on Dezolis?!"
	dc.b	$C3
	dc.b	"I see", $47, $47, $47, " Now that Palma is gone, we"
	dc.b	$C1
	dc.b	"on Motavia must support Algol ourselves."
	dc.b	$C1
	dc.b	"Please do your best, "
	dc.b	$BB
	dc.b	"."
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
	dc.b	"Good morning, "
	dc.b	$BB
	dc.b	". How are you?"
	dc.b	$C1
	dc.b	"It's been nearly two years since you"
	dc.b	$C1
	dc.b	"came to work under me, the Governor"
	dc.b	$C1
	dc.b	"of Motavia."
	dc.b	$C3
	dc.b	"What I'm about to ask of you will be"
	dc.b	$C1
	dc.b	"the hardest task yet. It is a grave matter"
	dc.b	$C1
	dc.b	"critical to the very future of Motavia."
	dc.b	$C3

loc_1CA1F:
	dc.b	"As you know, Algol has been nurtured"
	dc.b	$C1
	dc.b	"by Mother Brain. My work as Governor has"
	dc.b	$C1
	dc.b	"been to ensure that Mother Brain's plans"
	dc.b	$C3
	
loc_1CA8C:
	dc.b	"proceeded smoothly. I always believed"
	dc.b	$C1
	dc.b	"Mother Brain to be infallible. However, the"
	dc.b	$C1
	dc.b	"biomonsters now rampaging through Motavia"
	dc.b	$C1
	dc.b	"are simply out of control."
	dc.b	$C3

loc_1CB47:
	dc.b	"Why were the biomonsters created, and"
	dc.b	$C1
	dc.b	"how can they be stopped? We must find"
	dc.b	$C1
	dc.b	"that out for ourselves."
	dc.b	$C4

loc_1CBAA:
	dc.b	$BB
	dc.b	", your mission is to go to the"
	dc.b	$C1
	dc.b	"Biosystem and bring back the System"
	dc.b	$C1
	dc.b	"Recorder you'll find there."
	dc.b	$C3
	dc.b	"If we study its data, I'm sure we'll"
	dc.b	$C1
	dc.b	"learn why the Biosystem wound up"
	dc.b	$C1
	dc.b	"creating monsters."
	dc.b	$C3

loc_1CC3B:
	dc.b	$BB
	dc.b	", I pray with all my heart"
	dc.b	$C1
	dc.b	"that you come back safely with the"
	dc.b	$C1
	dc.b	"System Recorder. Until we meet again!"
	dc.b	$C4

loc_1CCC2:
	dc.b	"Good work, "
	dc.b	$BB
	dc.b	". I'll have this"
	dc.b	$C1
	dc.b	"System Recorder cross-checked against the"
	dc.b	$C1
	dc.b	"Library's data right away."
	dc.b	$C3
	dc.b	$BB
	dc.b	", until now, I believed that"
	dc.b	$C1
	dc.b	"whatever Mother Brain did was"
	dc.b	$C1
	dc.b	"absolutely right."
	dc.b	$C3
	
loc_1CD58:
	dc.b	"That our lives were protected by"
	dc.b	$C1
	dc.b	"Mother Brain."
	dc.b	$C1
	dc.b	"But under Mother Brain, how frail"
	dc.b	$C1
	dc.b	"and indolent we have become."
	dc.b	$C3
	
loc_1CDDA:
	dc.b	"When something like this happens,"
	dc.b	$C1
	dc.b	"one can't help but feel its significance."
	dc.b	$C1
	dc.b	"Now, the data should be ready."
	dc.b	$C1
	dc.b	"You should head over to the Library."
	dc.b	$C4

loc_1CE5E:
	dc.b	$BB
	dc.b	", something truly troubling"
	dc.b	$C1
	dc.b	"has happened. Just when we were relieved"
	dc.b	$C1
	dc.b	"that the biomonsters were gone, this"
	dc.b	$C1
	dc.b	"crisis began."
	dc.b	$C3

loc_1CF0A:
	dc.b	"If we could at least open the dams,"
	dc.b	$C1
	dc.b	"we'd avoid the worst case scenario, but the"
	dc.b	$C1
	dc.b	"controls aren't responding. Someone"
	dc.b	$C1
	dc.b	"needs to go and open them manually."
	dc.b	$C4

loc_1CF5F:
	dc.b	$C2
	dc.b	$42, "Please, let me do it!", $42
	dc.b	$C4

loc_1CF75:
	dc.b	$C2
	dc.b	"Hmm", $47, $47, $47, " But", $47, $47, $47, " It's quite unfortunate,"
	dc.b	$C1
	dc.b	"but the Palma government has"
	dc.b	$C1
	dc.b	"labeled you as the criminals who"
	dc.b	$C1
	dc.b	"drove Mother Brain haywire", $47, $47, $47
	dc.b	$C3

loc_1D002:
	dc.b	"Right now the security system is"
	dc.b	$C1
	dc.b	"searching for you frantically."
	dc.b	$C1
	dc.b	"It's dangerous to draw attention now."
	dc.b	$C4

loc_1D078:
	dc.b	$C2
	dc.b	$42, "But even if we stay home and keep a low"
	dc.b	$C1
	dc.b	"profile, we'll be caught anyway."
	dc.b	$C1
	dc.b	"Therefore, I'll go and open the dams."
	dc.b	$C3
	dc.b	"Who is trying to bring ruin to Motavia?"
	dc.b	$C1
	dc.b	"That's what I want to find out!", $42
	dc.b	$C4

loc_1D122:
	dc.b	$C2
	dc.b	"I see. Then I'll say no more."
	dc.b	$C1
	dc.b	"Take care."
	dc.b	$C4

loc_1D159:
	dc.b	"You made it back. I was worried."
	dc.b	$C1
	dc.b	"What did you say? You're going to Dezolis"
	dc.b	$C1
	dc.b	"without even taking time to rest", $47, $47, $47, " I see."
	dc.b	$C3
	dc.b	"You must have given this careful"
	dc.b	$C1
	dc.b	"consideration."
	dc.b	$C1
	dc.b	"Then, use the spaceship on the roof."
	dc.b	$C3
	dc.b	"But you're still under suspicion."
	dc.b	$C1
	dc.b	"After the Palma incident, they're more"
	dc.b	$C1
	dc.b	"agitated than ever. Be careful out there."
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
	if status_messages
	scriptofs	Msg_Battle2B, loc_1D65C		; $2B
	scriptofs	Msg_Battle2C, Msg_Battle2B	; $2C
	endif
	
loc_1D2A5:
	dc.b	$BB, " fell asleep!"
	dc.b	$C6
	
loc_1D2B3:
	dc.b	$BB
	dc.b	" and the others ran!"
	dc.b	$C6
	
loc_1D2CB:
	dc.b	"But they couldn't escape!"
	dc.b	$C6
	
loc_1D2E0:
	dc.b	"It had no effect!"
	dc.b	$C6
	
loc_1D2ED:
	dc.b	$BB, " can't fight!"
	dc.b	$C4
	
loc_1D2FC:
	dc.b	$BB
	dc.b	" died!"
	dc.b	$C6
	
loc_1D307:
	dc.b	$BB
	dc.b	" has no Techniques!"
	dc.b	$C4
	
loc_1D326:
	dc.b	$BB
	dc.b	" and the others were wiped out."
	dc.b	$C6
	
loc_1D341:
	dc.b	"Attack, Dexterity, and Agility up!"
	dc.b	$C6

loc_1D35D:
	dc.b	$BD
	dc.b	" fell silent."
	dc.b	$C6
	
loc_1D369:
	dc.b	$BD
	dc.b	" became confused!"
	dc.b	$C6
	
loc_1D37C:
	dc.b	$BD
	dc.b	" was paralyzed."
	dc.b	$C6
	
loc_1D38C:
	dc.b	"Defense up!"
	dc.b	$C6
	
loc_1D3A7:
	dc.b	"Agility up!"
	dc.b	$C6
	
loc_1D3BA:
	dc.b	$BB
	dc.b	" shared their life!"
	dc.b	$C6
	
loc_1D3CD:
	dc.b	"Huh? Something's not right!"
	dc.b	$C6
	
loc_1D3E0:
	dc.b	$BB
	dc.b	" and the others won!"
	dc.b	$C4
	
loc_1D3FC:
	dc.b	"Got "
	dc.b	$C0
	dc.b	" Experience points!"
	dc.b	$C4
	
loc_1D411:
	dc.b	"Got "
	dc.b	$C0
	dc.b	" meseta!"
	dc.b	$C4
	
loc_1D423:
	dc.b	$BB
	dc.b	"'s level increased!"
	dc.b	$C4
	
loc_1D434:
	dc.b	"Max HP increased!"
	dc.b	$C4
	
loc_1D444:
	dc.b	"Max TP increased!"
	dc.b	$C4
	
loc_1D454:
	dc.b	"Mastered a Technique!"
	dc.b	$C4
	
loc_1D46D:
	dc.b	$BB
	dc.b	" and the others fell in vain,"
	dc.b	$C1
	dc.b	"without bringing peace to Algol", $47, $47, $47
	dc.b	$C5
	
loc_1D4AA:
	dc.b	"A Plasma Ring clamped on!"
	dc.b	$C4
	
loc_1D4C3:
	dc.b	"Can't fight anymore", $47, $47, $47
	dc.b	$C6

loc_1D4D7:
	dc.b	$BB
	dc.b	" was poisoned!"
	dc.b	$C6
	
loc_1D4E6:
	dc.b	"Defense down!"
	dc.b	$C6
	
loc_1D501:
	dc.b	"Agility down!"
	dc.b	$C6
	
loc_1D514:
	dc.b	"Attack down!"
	dc.b	$C6
	
loc_1D52E:
	dc.b	$BB
	dc.b	" was paralyzed!"
	dc.b	$C6
	
loc_1D53E:
	dc.b	$BB
	dc.b	"'s paralysis wore off."
	dc.b	$C6
	
loc_1D558:
	dc.b	$BB
	dc.b	"'s heart was stained with evil!"
	dc.b	$C6
	
loc_1D568:
	dc.b	"Trying to betray the party!"
	dc.b	$C1
	dc.b	$BB
	dc.b	" ran off! But couldn't get away!"
	dc.b	$C6
	
loc_1D59E:
	dc.b	"Crushed by despair!"
	dc.b	$C6
	
loc_1D5B2:
	dc.b	$BB
	dc.b	" turned greedy!"
	dc.b	$C1
	dc.b	"Rifling through the others' bags!"
	dc.b	$C6
	
loc_1D5E1:
	dc.b	$BB
	dc.b	" grew suspicious!"
	dc.b	$C1
	dc.b	"Involuntarily eased up on attacks!"
	dc.b	$C6
	
loc_1D60C:
	dc.b	$BB
	dc.b	" lost confidence!"
	dc.b	$C1
	dc.b	"Can't use Techniques."
	dc.b	$C6
	
loc_1D63C:
	dc.b	$BB
	dc.b	" became lazy!"
	dc.b	$C1
	dc.b	"Agility down!"
	dc.b	$C6

loc_1D65C:
	dc.b	"The Nei Sword emitted a bright light!"
	dc.b	$C1
	dc.b	"The evil washed away from their hearts."
	dc.b	$C6
	if status_messages	; ext/battlebox.asm
Msg_Battle2B:
	dc.b	"Defensive barrier up!"
	dc.b	$C6
Msg_Battle2C:
	dc.b	"TP drained!"
	dc.b	$C6
	endif
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
	dc.b	"There's no room left to save any"
	dc.b	$C1
	dc.b	"more data, but"
	dc.b	$C3
	dc.b	"do you want to start a new game"
	dc.b	$C1
	dc.b	"anyway?"
	dc.b	$C5
	
loc_1D6F5:
	dc.b	"First, please give the protagonist a name."
	dc.b	$C5
	
loc_1D719:
	dc.b	"When starting a new story, you'll want"
	dc.b	$C1
	dc.b	"to write it on a blank page, right?"
	dc.b	$C3
	dc.b	"Well then, please erase one of your saved"
	dc.b	$C1
	dc.b	"games before you begin."
	dc.b	$C4

loc_1D762:
	dc.b	"And now, at last, the curtain rises"
	dc.b	$C1
	dc.b	"on Phantasy Star II."
	dc.b	$C4

loc_1D784:
	dc.b	"Which game will you start?"
	dc.b	$C5

loc_1D7AC:
	dc.b	"Which game will you erase?"
	dc.b	$C5

loc_1D7D4:
	dc.b	"Game number "
	dc.b	$C0
	dc.b	"."
	dc.b	$C1
	dc.b	"Are you sure you want to erase it?"
	dc.b	$C5

loc_1D7FF:
	dc.b	"Well then, I'll erase the data."
	dc.b	$C4

loc_1D81A:
	dc.b	"Whew, that was close! I almost"
	dc.b	$C1
	dc.b	"erased it by mistake."
	dc.b	$C4

loc_1D837:
	dc.b	"There's no data under that number."
	dc.b	$C1
	dc.b	"Please choose another number."
	dc.b	$C5

loc_1D873:
	dc.b	"Well then, I'll check the backup data!"
	dc.b	$C7
	
loc_1D891:
	dc.b	"The data for number "
	dc.b	$C0
	dc.b	" is fine."
	dc.b	$C5

loc_1D8A7:
	dc.b	"What's this?!"
	dc.b	$C1
	dc.b	"The data for number "
	dc.b	$C0
	dc.b	" is broken!"
	dc.b	$C3
	dc.b	"But don't lose heart just yet."
	dc.b	$C1
	dc.b	"I'm going to start repairing it now."
	dc.b	$C7
	
loc_1D8E7:
	dc.b	"Your good deeds must have paid off."
	dc.b	$C1
	dc.b	"The data is fixed! Hooray!"
	dc.b	$C4

loc_1D90A:
	dc.b	"Sadly, the data couldn't be fixed."
	dc.b	$C1
	dc.b	"This is a truly rare occurrence!"
	dc.b	$C3
	dc.b	"Maybe you're one of the luckiest"
	dc.b	$C1
	dc.b	"people around! Don't let it get you down!"
	dc.b	$C4

loc_1D950:
	dc.b	"The data check is complete."
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
	dc.b	"This is Motavia, the second planet"
	dc.b	$C1
	dc.b	"of the Algol star system", $47, $47, $47
	dc.b	$C7
	
loc_1D9A0:
	dc.b	"About a thousand years have passed since"
	dc.b	$C1
	dc.b	"LaSheek, who ruled Algol by the power"
	dc.b	$C1
	dc.b	"of darkness, fell to the four heroes:"
	dc.b	$C1
	dc.b	"Alisa, Tyron, Lutz and Myau", $47, $47, $47
	dc.b	$C7
	
loc_1D9F4:
	dc.b	"In that time Algol continued developing."
	dc.b	$C1
	dc.b	"Mother Brain, a gigantic computer, came"
	dc.b	$C1
	dc.b	"to manage every planet, and provided"
	dc.b	$C1
	dc.b	"a life of peace and prosperity."
	dc.b	$C7
	
loc_1DA54:
	dc.b	"Due to Mother Brain's plans, Motavia, too,"
	dc.b	$C1
	dc.b	"went from a planet of desert to one"
	dc.b	$C1
	dc.b	"of lush greenery, and the Dome Farms"
	dc.b	$C1
	dc.b	"produced abundant crops."
	dc.b	$C7
	
loc_1DAAA:
	dc.b	"Living in peace, people seemed to have"
	dc.b	$C1
	dc.b	"forgotten how to fight", $47, $47, $47, " they even forgot"
	dc.b	$C1
	dc.b	"the battles of Alisa and her companions,"
	dc.b	$C1
	dc.b	"the heroes who saved Algol", $47, $47, $47
	dc.b	$C7
	
loc_1DAFE:
	dc.b	"But darkness encroaches on Algol"
	dc.b	$C1
	dc.b	"once again! Who, then, will unravel the"
	dc.b	$C1
	dc.b	"mystery of destiny hidden within Algol?"
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
	dc.b	"Around that time, I tossed and turned"
	dc.b	$C1
	dc.b	"from the same nightmare every night."
	dc.b	$C5
	
loc_1DB86:
	dc.b	"A girl is fighting a sinister demon"
	dc.b	$C1
	dc.b	"resembling an enormous monster", $47, $47, $47
	dc.b	$C3
	dc.b	"I'm watching nearby, but I"
	dc.b	$C1
	dc.b	"can't move and can't call out."
	dc.b	$C1
	dc.b	"All I can do is watch as the"
	dc.b	$C1
	dc.b	"monster torments her", $47, $47, $47
	dc.b	$C4
	
loc_1DC18:
	dc.b	"And then, just as the girl is about to lose"
	dc.b	$C1
	dc.b	"her strength, I wake up."
	dc.b	$C4
	
loc_1DC47:
	dc.b	"In my room, dim in the light of dawn,"
	dc.b	$C1
	dc.b	"I was overcome by indescribable sorrow,"
	dc.b	$C1
	dc.b	"and I held back the tears that welled"
	dc.b	$C1
	dc.b	"up in my eyes", $47, $47, $47
	dc.b	$C3
	dc.b	"My name is "
	dc.b	$BB
	dc.b	". I work as an agent"
	dc.b	$C1
	dc.b	"in Paseo, the capital of Motavia."
	dc.b	$C1
	dc.b	"I shook my head, trying to eject"
	dc.b	$C1
	dc.b	"the dream from my mind."
	dc.b	$C3
	dc.b	"In an age where a colossal main computer"
	dc.b	$C1
	dc.b	"called Mother Brain rules the world,"
	dc.b	$C1
	dc.b	"getting sentimental over something as"
	dc.b	$C1
	dc.b	"vague as a dream is nonsensical."
	dc.b	$C3
	dc.b	"After all, everything that happens in"
	dc.b	$C1
	dc.b	"the world can be reduced to digital"
	dc.b	$C1
	dc.b	"data", $47, $47, $47
	dc.b	$C3
	dc.b	"I opened the window and breathed in"
	dc.b	$C1
	dc.b	"the morning air. Its freshness swept"
	dc.b	$C1
	dc.b	"through me, washing away the dream's"
	dc.b	$C1
	dc.b	"hold on me", $47, $47, $47
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
	dc.b	"This is Paseo, the largest city"
	dc.b	$C1
	dc.b	"on Motavia", $47, $47, $47
	dc.b	$C4
	
loc_1DF05:
	dc.b	"When you reach a new town, it's a good"
	dc.b	$C1
	dc.b	"idea to return home once."
	dc.b	$C3
	dc.b	"Someone who's heard of you might come"
	dc.b	$C1
	dc.b	"looking for you."
	dc.b	$C4

loc_1DF7E:
	dc.b	"Well, well. Quite the brave getup."
	dc.b	$C1
	dc.b	"But gear's useless if you don't use it well!"
	dc.b	$C4

loc_1DFF6:
	dc.b	"If there's something you want to know"
	dc.b	$C1
	dc.b	"about Motavia, go to the Library"
	dc.b	$C3
	dc.b	"in the Central Tower!"
	dc.b	$C4
	
loc_1E061:
	dc.b	"I used to work at the Biosystem,"
	dc.b	$C1
	dc.b	"west of the lake", $47, $47, $47
	dc.b	$C4

loc_1E0AE:
	dc.b	"Don't go near the bridge over the northern"
	dc.b	$C1
	dc.b	"river. Lots of people have been killed"
	dc.b	$C3
	dc.b	"there by a man called Darum."
	dc.b	$C4
	
loc_1E11A:
	dc.b	"As long as you have money, the Clone"
	dc.b	$C1
	dc.b	"Lab can restore your body. Convenient, huh?"
	dc.b	$C4

loc_1E163:
	dc.b	"From now on, women should take up arms"
	dc.b	$C1
	dc.b	"and fight too! I'm going to buy some as well!"
	dc.b	$C4

loc_1E1AB:
	dc.b	"When it comes to men, hunters are the"
	dc.b	$C1
	dc.b	"coolest! They're strong, and so reliable!"
	dc.b	$C4

loc_1E1F5:
	dc.b	"This town is so peaceful. I'm really"
	dc.b	$C1
	dc.b	"glad I moved here from Arimaya", $47, $47, $47
	dc.b	$C4

loc_1E22E:
	dc.b	"Motavia prospered thanks to the Biosystem."
	dc.b	$C1
	dc.b	"Yet now the monsters that same Biosystem"
	dc.b	$C3
	dc.b	"made are ravaging Motavia. Fate can be"
	dc.b	$C1
	dc.b	"cruelly ironic, eh", $47, $47, $47
	dc.b	$C4

loc_1E25D:
	dc.b	"It hasn't rained at all lately."
	dc.b	$C1
	dc.b	"The lake has dried up, too."
	dc.b	$C4

loc_1E299:
	dc.b	"My dad just lazes around every day."
	dc.b	$C1
	dc.b	"He says he can get by without working."
	dc.b	$C4

loc_1E2E3:
	dc.b	"Is working hard a dumb thing to do?"
	dc.b	$C1
	dc.b	"That's what all the grown-ups say."
	dc.b	$C4

loc_1E303:
	dc.b	"When I grow up, I'm going to be a thief!"
	dc.b	$C1
	dc.b	"It's a trendy job right now."
	dc.b	$C4

loc_1E32C:
	dc.b	"They say if you go to the north bridge,"
	dc.b	$C1
	dc.b	"some guy called Darum will rob you."
	dc.b	$C4

loc_1E387:
	dc.b	"Why on earth did you come to Arimaya?"
	dc.b	$C1
	dc.b	"This is a terrible place."
	dc.b	$C4

loc_1E3CE:
	dc.b	"If those thugs had never come to town,"
	dc.b	$C1
	dc.b	"Darum and his daughter Tiem could have"
	dc.b	$C3
	dc.b	"lived happily together", $47, $47, $47
	dc.b	$C4

loc_1E43C:
	dc.b	"People are more terrifying than monsters."
	dc.b	$C4

loc_1E46D:
	dc.b	"Thugs attacked this town, and"
	dc.b	$C1
	dc.b	"now there's nothing left", $47, $47, $47
	dc.b	$C4

loc_1E4B7:
	dc.b	"Those thugs blew up people's houses"
	dc.b	$C1
	dc.b	"with dynamite", $47, $47, $47
	dc.b	$C4

loc_1E4F1:
	dc.b	"The thugs should have two more sticks"
	dc.b	$C1
	dc.b	"of dynamite left."
	dc.b	$C3
	dc.b	"If we don't get them back, they'll"
	dc.b	$C1
	dc.b	"destroy a town again", $47, $47, $47
	dc.b	$C4

loc_1E55E:
	dc.b	"Those thugs always come from the east."
	dc.b	$C1
	dc.b	"How terrifying their silhouettes look"
	dc.b	$C3
	dc.b	"against the morning glow", $47, $47, $47
	dc.b	$C4

loc_1E58A:
	dc.b	"The thugs slaughtered the men, carried"
	dc.b	$C1
	dc.b	"off the women, and stole all our food."
	dc.b	$C4

loc_1E5DE:
	dc.b	"The only ones left here are the weak."
	dc.b	$C1
	dc.b	"We're just waiting to starve to death."
	dc.b	$C4

loc_1E62B:
	dc.b	"I know! The thugs' hideout is inside"
	dc.b	$C1
	dc.b	"the building in Shuren."
	dc.b	$C4

loc_1E66E:
	dc.b	"They say those crooks are cautious, and"
	dc.b	$C1
	dc.b	"keep their loot in locked containers."
	dc.b	$C4

loc_1E6C8:
	dc.b	"Mr. Darum isn't a bad man! He only turned"
	dc.b	$C1
	dc.b	"violent because little Tiem was kidnapped!"
	dc.b	$C4

loc_1E728:
	dc.b	"This is Optano. The Biosystem is"
	dc.b	$C1
	dc.b	"south of this town."
	dc.b	$C4

loc_1E783:
	dc.b	"The Biosystem made the monsters?"
	dc.b	$C1
	dc.b	"That's got to be a lie."
	dc.b	$C4

loc_1E7BA:
	dc.b	"The Biosystem has been making plants"
	dc.b	$C1
	dc.b	"that grow well even with little rain."
	dc.b	$C4

loc_1E817:
	dc.b	"Mother Brain controls the Biosystem."
	dc.b	$C1
	dc.b	"There's no way mistakes could happen!"
	dc.b	$C4

loc_1E862:
	dc.b	$42, "The scent of stars heals wounds;"
	dc.b	$C1
	dc.b	"the scent of the moon revives the soul.", $42
	dc.b	$C3
	dc.b	"So the nobles of old used to say"
	dc.b	$C1
	dc.b	"as they used their atomizers."
	dc.b	$C4

loc_1E89E:
	dc.b	"O, Great Mother Brain!"
	dc.b	$C1
	dc.b	"Please save us!"
	dc.b	$C4

loc_1E8C9:
	dc.b	"Even with the monsters gone, Motavia's"
	dc.b	$C1
	dc.b	"already in shambles. Nothing can be done."
	dc.b	$C4

loc_1E927:
	dc.b	"Say, do you know about atomizers?"
	dc.b	$C1
	dc.b	"They smell so lovely."
	dc.b	$C3
	dc.b	"But atomizers are a real luxury."
	dc.b	$C1
	dc.b	"You hardly ever get your hands on one."
	dc.b	$C4

loc_1E96C:
	dc.b	"I want to be a musician. I heard there's"
	dc.b	$C1
	dc.b	"a piano teacher in this town", $47, $47, $47
	dc.b	$C4

loc_1E9B8:
	dc.b	"The hole in the middle of the Biosystem"
	dc.b	$C1
	dc.b	"building leads to that terrifying basement."
	dc.b	$C4

loc_1EA0F:
	dc.b	"The basement of the Biosystem", $47, $47, $47
	dc.b	$C1
	dc.b	"Something of the utmost importance"
	dc.b	$C3
	dc.b	"seems to be down there", $47, $47, $47
	dc.b	$C4

loc_1EA60:
	dc.b	"I'm hungry", $47, $47, $47
	dc.b	$C4

loc_1EA6F:
	dc.b	"I wonder when Motavia will finally know"
	dc.b	$C1
	dc.b	"peace?"
	dc.b	$C4

loc_1EA98:
	dc.b	"The people from Palma are picky eaters,"
	dc.b	$C1
	dc.b	"so they go hungry."
	dc.b	$C4

loc_1EAE0:
	dc.b	"When we're hungry, we'll eat anything."
	dc.b	$C4

loc_1EB0B:
	dc.b	"Hey, what's Mother Brain?"
	dc.b	$C1
	dc.b	"Does it taste good?"
	dc.b	$C4

loc_1EB25:
	dc.b	"This is Zema, the resort town"
	dc.b	$C1
	dc.b	"by the lake."
	dc.b	$C4

loc_1EB4E:
	dc.b	"I've seen Motavians riding around"
	dc.b	$C1
	dc.b	"on a vehicle. It looked like fun!"
	dc.b	$C4

loc_1EB89:
	dc.b	"Have you been to the southern peninsula?"
	dc.b	$C1
	dc.b	"The smell of garbage drifts over from"
	dc.b	$C3
	dc.b	"Roron. It stinks!"
	dc.b	$C4

loc_1EBF7:
	dc.b	"Motavians can make anything out of junk."
	dc.b	$C4

loc_1EC1C:
	dc.b	"The Motavians love the Roron garbage"
	dc.b	$C1
	dc.b	"dump. They're always playing there."
	dc.b	$C4

loc_1EC48:
	dc.b	"In the middle of the lake there's a tower no"
	dc.b	$C1
	dc.b	"one has ever been to. I wonder what it is?"
	dc.b	$C4

loc_1EC93:
	dc.b	"When we were young, we used to play"
	dc.b	$C1
	dc.b	"on the sea with jet scooters, too."
	dc.b	$C4

loc_1ECD5:
	dc.b	"Once the Teleport Service came along,"
	dc.b	$C1
	dc.b	"nobody used vehicles any more."
	dc.b	$C4

loc_1ED29:
	dc.b	"What's that?"
	dc.b	$C4

loc_1ED36:
	dc.b	"Huh?!"
	dc.b	$C4

loc_1ED3C:
	dc.b	"The ancestors of the people in this"
	dc.b	$C1
	dc.b	"town worked out at sea, you know."
	dc.b	$C4

loc_1ED80:
	dc.b	"All sorts of legends and stories about the"
	dc.b	$C1
	dc.b	"sea are still told in this town."
	dc.b	$C4

loc_1EDB6:
	dc.b	"They say the sea and the lake are joined"
	dc.b	$C1
	dc.b	"underground. I wonder if that's true."
	dc.b	$C4

loc_1EDF6:
	dc.b	"Welcome to Kueris."
	dc.b	$C4

loc_1EE08:
	dc.b	"They say people long ago would eat"
	dc.b	$C1
	dc.b	"something before diving to catch fish."
	dc.b	$C4

loc_1EE5C:
	dc.b	"My boyfriend lives on the edge of town,"
	dc.b	$C1
	dc.b	"so nobody gets in the way of his research."
	dc.b	$C4

loc_1EEB0:
	dc.b	"Where the sea water's a different color,"
	dc.b	$C1
	dc.b	"they say lake water is welling up."
	dc.b	$C4

loc_1EF24:
	dc.b	"There should be a rocky island called"
	dc.b	$C1
	dc.b	"Uzo out in the Motavian sea."
	dc.b	$C4
	
loc_1EF60:
	dc.b	"It was fifty years ago that Mother Brain"
	dc.b	$C1
	dc.b	"decreed no one may go out to sea."
	dc.b	$C4

loc_1EFB1:
	dc.b	"Hey, have you met our friends"
	dc.b	$C1
	dc.b	"in Roron yet?"
	dc.b	$C4

loc_1EFD9:
	dc.b	"Aah, a human! Scary!"
	dc.b	$C4

loc_1EFE9:
	dc.b	"Did you know? Traveling through space"
	dc.b	$C1
	dc.b	"just isn't possible any more."
	dc.b	$C4

loc_1F02A:
	dc.b	"There was an accident ten years ago, and"
	dc.b	$C1
	dc.b	"all spaceship use was since prohibited."
	dc.b	$C4

loc_1F07C:
	dc.b	"Back when the spaceport was functional,"
	dc.b	$C1
	dc.b	"ships flew to Palma and Dezolis constantly."
	dc.b	$C4

loc_1F0E6:
	dc.b	"I wanted to be a pilot, but with no"
	dc.b	$C1
	dc.b	"spaceships, I guess that won't happen."
	dc.b	$C4

loc_1F136:
	dc.b	"This town is Piata. Long ago there"
	dc.b	$C1
	dc.b	"was a spaceport near here, you know."
	dc.b	$C4

loc_1F179:
	dc.b	"The accident ten years ago was when two"
	dc.b	$C1
	dc.b	"spaceships collided above Dezolis."
	dc.b	$C4

loc_1F1DF:
	dc.b	"They say a huge number of people"
	dc.b	$C1
	dc.b	"died in the accident ten years ago."
	dc.b	$C4

loc_1F227:
	dc.b	"Everyone believed that space travel"
	dc.b	$C1
	dc.b	"wasn't dangerous at all."
	dc.b	$C4

loc_1F273:
	dc.b	"The last spaceship was headed"
	dc.b	$C1
	dc.b	"beyond Algol."
	dc.b	$C4
	
loc_1F2AF:
	dc.b	"Going beyond Algol was a dream for so"
	dc.b	$C1
	dc.b	"long, but it can never come true now", $47, $47, $47
	dc.b	$C4

loc_1F2FF:
	dc.b	"I hear no one survived the accident"
	dc.b	$C1
	dc.b	"ten years ago."
	dc.b	$C4

loc_1F337:
	dc.b	$BB
	dc.b	$47, $47, $47, " Hmm, I think that name was on"
	dc.b	$C1
	dc.b	"the passenger list of the last ship", $47, $47, $47
	dc.b	$C4

loc_1F385:
	dc.b	"Hey, what's outside Algol?"
	dc.b	$C1
	dc.b	"Why can't we go there?"
	dc.b	$C4

loc_1F3BE:
	dc.b	"Mother Brain watches over us, right?"
	dc.b	$C1
	dc.b	"So why do accidents happen?"
	dc.b	$C4

loc_1F406:
	dc.b	"They say the dams contain all kinds of"
	dc.b	$C1
	dc.b	"weapons. People long ago left them"
	dc.b	$C3
	dc.b	"there as protective charms."
	dc.b	$C4

loc_1F43B:
	dc.b	"Ga? Dotenyara? Panaputonyahohoi!"
	dc.b	$C4

loc_1F452:
	dc.b	"Nyaa! Unyanyaan!"
	dc.b	$C4

loc_1F45F:
	dc.b	"Us folks are Dezolians."
	dc.b	$C1
	dc.b	"Finest men in all of Algol!"
	dc.b	$C4

loc_1F489:
	dc.b	"Us folks never tell a lie, no sir!"
	dc.b	$C4

loc_1F49C:
	dc.b	"Ain't nobody but us on this planet."
	dc.b	$C4

loc_1F4CC:
	dc.b	"Stay on this planet too long, and your"
	dc.b	$C1
	dc.b	"body goes rotten, tell ya what."
	dc.b	$C4

loc_1F507:
	dc.b	"The granny at the clone shop's really"
	dc.b	$C1
	dc.b	"a man, y'know."
	dc.b	$C4

loc_1F53C:
	dc.b	"Nyah, you big dummy!"
	dc.b	$C4

loc_1F548:
	dc.b	"I hate you! Go away!"
	dc.b	$C4

loc_1F55D:
	dc.b	"I'm gonna bite you!"
	dc.b	$C4

loc_1F571:
	dc.b	"This town's called Zosa."
	dc.b	$C4
	
loc_1F58B:
	dc.b	"Living easy and hunting like this"
	dc.b	$C1
	dc.b	"is the best life there is."
	dc.b	$C4

loc_1F5BC:
	dc.b	"Us folks live in a town the Palma"
	dc.b	$C1
	dc.b	"people abandoned. Ya got a problem?"
	dc.b	$C4

loc_1F5F6:
	dc.b	"Well now, you're a rare one."
	dc.b	$C1
	dc.b	"Where'd you come from?"
	dc.b	$C4

loc_1F628:
	dc.b	"That accident on the day of the eclipse"
	dc.b	$C1
	dc.b	"happened 'cause Palma folks didn't pray."
	dc.b	$C4

loc_1F690:
	dc.b	"They didn't treat the Eclipse Torch right,"
	dc.b	$C1
	dc.b	"so the Palma folks faced divine retribution."
	dc.b	$C4

loc_1F6E7:
	dc.b	"Palma folks were scared of the poison"
	dc.b	$C1
	dc.b	"gas, but it don't bother us none."
	dc.b	$C4

loc_1F732:
	dc.b	"Us folks are so tough, it amazes"
	dc.b	$C1
	dc.b	"even us."
	dc.b	$C4
	
loc_1F762:
	dc.b	"Another human, besides the granny at"
	dc.b	$C1
	dc.b	"the clone shop? Now that's a surprise!"
	dc.b	$C3
	dc.b	"Everybody else left three years back."
	dc.b	$C4
	
loc_1F7C8:
	dc.b	"When I went past the crevasse, I saw"
	dc.b	$C1
	dc.b	"a real handsome fellow over there."
	dc.b	$C4
	
loc_1F813:
	dc.b	"This town's called Aukbal."
	dc.b	$C4
	
loc_1F82E:
	dc.b	"Way, way back, somebody ran off from"
	dc.b	$C1
	dc.b	"Palma to this planet, I hear."
	dc.b	$C4
	
loc_1F87A:
	dc.b	"Folks say the ones hiding on this planet"
	dc.b	$C1
	dc.b	"have strange powers."
	dc.b	$C4
	
loc_1F8BC:
	dc.b	"Oh, did you come through that crevasse?"
	dc.b	$C1
	dc.b	"Aw, wrong fella. My mistake."
	dc.b	$C4
	
loc_1F8E9:
	dc.b	"The planet Dezolis belongs to us. Good"
	dc.b	$C1
	dc.b	"riddance to the Palma folks, I say."
	dc.b	$C4
	
loc_1F92F:
	dc.b	"That fellow hiding on this planet never"
	dc.b	$C1
	dc.b	"gets any older. Mighty strange."
	dc.b	$C4
	
loc_1F969:
	dc.b	"Us folks ain't ever leaving this"
	dc.b	$C1
	dc.b	"planet, no matter what!"
	dc.b	$C4
	
loc_1F99A:
	dc.b	"Us folks hate computers!"
	dc.b	$C4

loc_1F9AD:
	dc.b	"This town's called Ryuon."
	dc.b	$C4

loc_1F9C8:
	dc.b	"Palma folks came to Dezolis"
	dc.b	$C1
	dc.b	"to dig for Laconia."
	dc.b	$C4

loc_1F9F6:
	dc.b	"The granny at the clone shop stayed"
	dc.b	$C1
	dc.b	"here 'cause she likes us folks."
	dc.b	$C4

loc_1FA35:
	dc.b	"The poison gas came up when they dug"
	dc.b	$C1
	dc.b	"the holes, they say. Dezolis's farts, y'know!"
	dc.b	$C4

loc_1FA60:
	dc.b	"I saw it. Ten years back, two ships crashed."
	dc.b	$C1
	dc.b	"The sky went bright red."
	dc.b	$C4

loc_1FA9C:
	dc.b	"Do Palma and Motavia folks still"
	dc.b	$C1
	dc.b	"believe in Mother Brain?"
	dc.b	$C4

loc_1FACD:
	dc.b	"Lean on Mother Brain, and sooner or"
	dc.b	$C1
	dc.b	"later you'll get burned, I reckon."
	dc.b	$C4

loc_1FB1E:
	dc.b	"Us folks don't count on Mother Brain."
	dc.b	$C4

loc_1FB3E:
	dc.b	"It's right there, but you can't see"
	dc.b	$C1
	dc.b	"or touch it. Can such a building exist?"
	dc.b	$C4

loc_1FB87:
	dc.b	"I don't like Palma folks. Digging a great"
	dc.b	$C1
	dc.b	"big hole in my planet. Just awful!"
	dc.b	$C4

loc_1FBD6:
	dc.b	$47, $47, $47, " Whoops, fell asleep walking."
	dc.b	$C4

loc_1FBF7:
	dc.b	"Sure is hot today, tell ya what."
	dc.b	$C4

loc_1FC0F:
	dc.b	"Long ago, we were kept by humans."
	dc.b	$C4

loc_1FC2D:
	dc.b	"Lots of the people working on Dezolis"
	dc.b	$C1
	dc.b	"had left their families back home."
	dc.b	$C4

loc_1FC72:
	dc.b	"The pets left behind on this planet"
	dc.b	$C1
	dc.b	"were changed by the poison gas."
	dc.b	$C4

loc_1FCCC:
	dc.b	"When the humans left this planet,"
	dc.b	$C1
	dc.b	"they left us behind."
	dc.b	$C4

loc_1FCFF:
	dc.b	"Give me food! I'm starving."
	dc.b	$C4

loc_1FD17:
	dc.b	"Mmm, garbage smells so good."
	dc.b	$C4

loc_1FD3B:
	dc.b	"La la la. Collecting garbage is fun."
	dc.b	$C4

loc_1FD5D:
	dc.b	"What kind of garbage will I find today?"
	dc.b	$C4

loc_1FD91:
	dc.b	"Hey! I found a yummy cake!"
	dc.b	$C1
	dc.b	"Want to try some?"
	dc.b	$C5

loc_1FDC3:
	dc.b	$BB
	dc.b	" and the others ate the cake."
	dc.b	$C1
	dc.b	"It tasted weird! Their stomachs rumbled!"
	dc.b	$C4

loc_1FE21:
	dc.b	$BB
	dc.b	" and the others politely"
	dc.b	$C1
	dc.b	"declined."
	dc.b	$C4

loc_1FE53:
	dc.b	"Look, look! I built this jet scooter."
	dc.b	$C1
	dc.b	"Not bad, huh?"
	dc.b	$C4

loc_1FE90:
	dc.b	"I'm going to the sea to try it out."
	dc.b	$C1
	dc.b	"Come and watch, if you like."
	dc.b	$C4

loc_1FEE9:
	dc.b	"Huh? Where did the Motavians go?"
	dc.b	$C1
	dc.b	"Oh, there's a note posted here."
	dc.b	$C3
	dc.b	$42, "We like messing with garbage, that's all."
	dc.b	$C1
	dc.b	"So we don't need this. Someone can have it.", $42
	dc.b	$C3
	dc.b	"Yes! How lucky is that!!"
	dc.b	$C4

loc_1FFA0:
	dc.b	"You must be "
	dc.b	$BB
	dc.b	"."
	dc.b	$C1
	dc.b	"We've been expecting you."
	dc.b	$C4
	
loc_1FFC9:
	dc.b	"You're not "
	dc.b	$BB
	dc.b	", are you?"
	dc.b	$C1
	dc.b	"Please leave."
	dc.b	$C4

loc_1FFEF:
	dc.b	"Here sleeps the noble soul who once"
	dc.b	$C1
	dc.b	"fought to save Algol."
	dc.b	$C4

loc_2002F:
	dc.b	"This person was put into cold sleep to watch"
	dc.b	$C1
	dc.b	"over the future of Algol."
	dc.b	$C4

loc_2007B:
	dc.b	"When Mother Brain appeared, this one chose"
	dc.b	$C1
	dc.b	"to hide away on Dezolis."
	dc.b	$C4

loc_200B5:
	dc.b	"For generations, our family has"
	dc.b	$C1
	dc.b	"served this person."
	dc.b	$C4

loc_200EE:
	dc.b	"This one spoke of awakening to the truth"
	dc.b	$C1
	dc.b	"when you arrived."
	dc.b	$C4

loc_20125:
	dc.b	"This one awakens once every ten years."
	dc.b	$C4

loc_2014D:
	dc.b	"Before the power of darkness dominates"
	dc.b	$C1
	dc.b	"Algol, gather the legendary weapons"
	dc.b	$C1
	dc.b	"without delay."
	dc.b	$C4

loc_2019E:
	dc.b	"Well done. You have truly proven Alisa's"
	dc.b	$C1
	dc.b	"blood runs within you. I acknowledge that"
	dc.b	$C1
	dc.b	"you are fit to inherit the power of light and"
	dc.b	$C1
	dc.b	"the memory of darkness."
	dc.b	$C3

loc_2026C:
	dc.b	"A thousand years ago, after the battle"
	dc.b	$C1
	dc.b	"of Alisa and her friends, Algol enjoyed"
	dc.b	$C1
	dc.b	"a brief peace."
	dc.b	$C3
	dc.b	"People were content with what their loved"
	dc.b	$C1
	dc.b	"ones gave them, and wished for nothing"
	dc.b	$C1
	dc.b	"more; instead, they found joy in giving"
	dc.b	$C1
	dc.b	"their loved ones more than they asked for."
	dc.b	$C3
	
loc_20333:
	dc.b	"But with the arrival of Mother Brain,"
	dc.b	$C1
	dc.b	"Algol changed", $47, $47, $47
	dc.b	$C3
	dc.b	"Mother Brain made so many things that"
	dc.b	$C1
	dc.b	"we lost sight of what we truly needed."
	dc.b	$C3
	
loc_203E0:
	dc.b	"People started to fight and clutch at"
	dc.b	$C1
	dc.b	"whatever Mother Brain made, and forgot"
	dc.b	$C1
	dc.b	"about the look in gentle Alisa's eyes."
	dc.b	$C3
	dc.b	"Already, people have even begun to think"
	dc.b	$C1
	dc.b	"that they cannot live without"
	dc.b	$C1
	dc.b	"Mother Brain."
	dc.b	$C3

loc_2049E:
	dc.b	"Behind Mother Brain, which has made the"
	dc.b	$C1
	dc.b	"people's hearts so weak, I sense the"
	dc.b	$C1
	dc.b	"trap of a devil."
	dc.b	$C3
	dc.b	"A trap that will lead Algol to ruin!"
	dc.b	$C1
	dc.b	"Who set this trap, and for what purpose,"
	dc.b	$C1
	dc.b	"even I do not know."
	dc.b	$C3
	dc.b	"In that box lies the Nei Sword. Once"
	dc.b	$C1
	dc.b	"you take that weapon in hand, I shall"
	dc.b	$C1
	dc.b	"send you to where the evil ones lurk."
	dc.b	$C4

loc_2057B:
	dc.b	"I entrust the future of Algol to you."
	dc.b	$C1
	dc.b	"I pray with all my heart for your safety."
	dc.b	$C3
	dc.b	"And should you feel your strength fail you,"
	dc.b	$C1
	dc.b	"use the Nei Sword. It will summon you"
	dc.b	$C1
	dc.b	"back here instantly."
	dc.b	$C3
	dc.b	"Now, go! To the place where they who"
	dc.b	$C1
	dc.b	"monitor us so intently from the stars"
	dc.b	$C1
	dc.b	"beyond Algol await!!"
	dc.b	$C4
	
loc_20643:
	dc.b	"Good grief, now we have to worry"
	dc.b	$C1
	dc.b	"about the lake overflowing", $47, $47, $47
	dc.b	$C4

loc_20684:
	dc.b	"Welcome. The one we serve awaits you."
	dc.b	$C4

loc_206B2:
	dc.b	"For my part, I'd prefer to let the one"
	dc.b	$C1
	dc.b	"we serve sleep peacefully", $47, $47, $47
	dc.b	$C4

loc_206EC:
	dc.b	"I hear the government's robots are"
	dc.b	$C1
	dc.b	"hunting down the villains who refuse to"
	dc.b	$C3
	dc.b	"obey Mother Brain."
	dc.b	$C4

loc_20768:
	dc.b	"The biomonsters are gone, so we can"
	dc.b	$C1
	dc.b	"go back to living a lazy life."
	dc.b	$C4

loc_207B1:
	dc.b	"You look just like the people on"
	dc.b	$C1
	dc.b	"the wanted posters", $47, $47, $47
	dc.b	$C4

loc_207EE:
	dc.b	"Whatever happens, we believe in you all"
	dc.b	$C1
	dc.b	"who are fighting for our sake."
	dc.b	$C4

loc_20843:
	dc.b	"The biomonsters are gone. But the dark"
	dc.b	$C1
	dc.b	"air over this planet somehow won't lift", $47, $47, $47
	dc.b	$C4

loc_2089A:
	dc.b	"I've seen that face somewhere", $47, $47, $47
	dc.b	$C4

loc_208BB:
	dc.b	"Hey, isn't the pretty lady who was"
	dc.b	$C1
	dc.b	"always with you here today?"
	dc.b	$C4

loc_20907:
	dc.b	"Mama said not to talk to "
	dc.b	$BB
	dc.b	$C1
	dc.b	"and his friends. Why?"
	dc.b	$C4

loc_20942:
	dc.b	"The future of Algol rests on your shoulders."
	dc.b	$C1
	dc.b	"I imagine it will be a hard journey, but"
	dc.b	$C3
	dc.b	"please don't give up."
	dc.b	$C4

loc_209AA:
	dc.b	"Hey, have you ever met the Dezolians?"
	dc.b	$C1
	dc.b	"You can't understand a word they say,"
	dc.b	$C3
	dc.b	"they lie, they're contrarian. Horrible people!"
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
	dc.b	$BB
	dc.b	" got "
	dc.b	$C0
	dc.b	" meseta!"
	dc.b	$C4

loc_20A77:
	dc.b	$BB
	dc.b	" found the "
	dc.b	$BF
	dc.b	"!"
	dc.b	$C5

loc_20A86:
	dc.b	$BB
	dc.b	" got the "
	dc.b	$BF
	dc.b	"!"
	dc.b	$C4

loc_20A9E:
	dc.b	"But there's no room to carry it!"
	dc.b	$C4

loc_20ABC:
	dc.b	"It's full of garbage."
	dc.b	$C4

loc_20AD2:
	dc.b	"There's nothing inside!"
	dc.b	$C4

loc_20AEB:
	dc.b	"It's locked and won't open!"
	dc.b	$C4

loc_20B07:
	dc.b	"There seems to be nothing unusual here."
	dc.b	$C4

loc_20B2F:
	dc.b	"This is the Control Tower that links"
	dc.b	$C1
	dc.b	"the city to Mother Brain's network", $47, $47, $47
	dc.b	$C4
	
loc_20B7F:
	dc.b	"The thugs seem to have blown the door"
	dc.b	$C1
	dc.b	"open with dynamite and stolen the goods."
	dc.b	$C4

loc_20BD6:
	dc.b	"The body of one of the thugs. Did the"
	dc.b	$C1
	dc.b	"biomonsters get them", $47, $47, $47, "?"
	dc.b	$C4

loc_20C22:
	dc.b	"Huh? There's something in the pocket!"
	dc.b	$C4

loc_20C52:
	dc.b	"It looks like dynamite could break this door."
	dc.b	$C4

loc_20C75:
	dc.b	"A sturdy-looking shutter."
	dc.b	$C4

loc_20C9A:
	dc.b	"It looks like one, but this isn't"
	dc.b	$C1
	dc.b	"a Maruera tree."
	dc.b	$C4

loc_20CC7:
	dc.b	"This is it! A Maruera tree!!"
	dc.b	$C4

loc_20CED:
	dc.b	"There's a keyboard. Oh? There's sheet"
	dc.b	$C1
	dc.b	"music too. Shall we give it a try?"
	dc.b	$C5

loc_20D2F:
	dc.b	$42, "To comfort a lonely life,"
	dc.b	$C1
	dc.b	"nothing beats a pet!!", $42
	dc.b	$C4

loc_20D76:
	dc.b	$42, "Why not talk with your pet, too?"
	dc.b	$C1
	dc.b	"Magic Hats at Safe Department Store!!", $42
	dc.b	$C4

loc_20DD1:
	dc.b	$42, "Counterfeit Magic Hats have been going"
	dc.b	$C1
	dc.b	"around lately. Please be careful.", $42
	dc.b	$C4

loc_20E1E:
	dc.b	$42, "Gas leak in Skure, Block D."
	dc.b	$C1
	dc.b	"Everyone, please evacuate.", $42
	dc.b	$C4

loc_20E5E:
	dc.b	$42, "Cause of gas leak determined to be"
	dc.b	$C1
	dc.b	"simple mistake.", $42
	dc.b	$C4

loc_20E9B:
	dc.b	$42, "The leaked gas is harmful to your"
	dc.b	$C1
	dc.b	"health. Beware!!", $42
	dc.b	$C4

loc_20EE0:
	dc.b	$42, "The last rescue ship leaves August"
	dc.b	$C1
	dc.b	"11. Don't miss it!", $42
	dc.b	$C4

loc_20F1B:
	dc.b	"I found an old newspaper!"
	dc.b	$C4

loc_20F37:
	dc.b	"What?! What is this?! I sense an immensely"
	dc.b	$C1
	dc.b	"sinister force!"
	dc.b	$C4

loc_20F73:
	dc.b	"There's a slot for a card."
	dc.b	$C4

loc_20F97:
	dc.b	"All right, let's board the jet scooter!"
	dc.b	$C4

loc_20FB5:
	dc.b	"Okay, let's get off here."
	dc.b	$C4

loc_20FDB:
	dc.b	"We can't get off here!"
	dc.b	$C4
	
loc_20FF2:
	dc.b	"Before "
	dc.b	$BB
	dc.b	" and the others towered"
	dc.b	$C1
	dc.b	"a high, rocky mountain!"
	dc.b	$C3
	dc.b	"This must be the mountain of Uzo!"
	dc.b	$C4
; unused bytes of the stock ROM
	dc.b	$BB, $00, $25, $32, $28, $00, $38, $2C, $29, $00, $33, $38, $2C, $29, $36, $37
	dc.b	$44, $C1, $13, $37, $00, $38, $2C, $2D, $37, $00, $1F, $3E, $33, $00, $31, $33
	dc.b	$39, $32, $38, $25, $2D, $32, $43, $C4

loc_21045:
	dc.b	"Sure enough, the water is only a different"
	dc.b	$C1
	dc.b	"color in this spot. It seems an underground"
	dc.b	$C3
	dc.b	"spring is welling up."
	dc.b	$C4
; unused bytes of the stock ROM
	dc.b	$37, $29, $29, $31, $37, $00, $28, $2D, $2A, $2A, $29, $36, $29, $32, $38, $40
	dc.b	$C1, $13, $38, $00, $37, $29, $29, $31, $37, $00, $38, $33, $00, $26, $29, $00
	dc.b	$3B, $25, $38, $29, $36, $C3, $27, $33, $31, $2D, $32, $2B, $00, $33, $39, $38
	dc.b	$00, $33, $2A, $00, $38, $2C, $29, $C1, $2B, $36, $33, $39, $32, $28, $40, $C4
	
loc_210AE:
	dc.b	$BB
	dc.b	" died!"
	dc.b	$C4
	
loc_210B9:
	dc.b	"Huh? Shilka isn't here?"
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
	dc.b	"Ah! I recognize that face!!"
	dc.b	$C1
	dc.b	"It's the guy who tried to kill Nei"
	dc.b	$C1
	dc.b	"seven months ago! This could be trouble."
	dc.b	$C1
	dc.b	"Let's turn back for now."
	dc.b	$C4

loc_21175:
	dc.b	"Tiem seems to have some something in mind,"
	dc.b	$C1
	dc.b	"but what on earth is she planning?"
	dc.b	$C4

loc_21188:
	dc.b	$C2
	dc.b	$42, "I'm going to see my father now."
	dc.b	$C1
	dc.b	"You all stay right there.", $42
	dc.b	$C4

loc_211BC:
	dc.b	$C2
	dc.b	$42, "Hey, you, girl! Hand over your money!"
	dc.b	$C1
	dc.b	"Or I'll cut you down!!", $42
	dc.b	$C3
	dc.b	$C2
	dc.b	$42, "I have nothing to give to the likes of you!", $42
	dc.b	$C3
	dc.b	$C2
	dc.b	$42, "What? How dare you speak to me that way!", $42
	dc.b	$C4

loc_21227:
	dc.b	$C2
	dc.b	$42, "Ah!!!", $42
	dc.b	$C3
	dc.b	$C2
	dc.b	$42, "Father", $47, $47, $47, " no more killing", $47, $47, $47, $42
	dc.b	$C3
	dc.b	$C2
	dc.b	$42, "Tiem!!! Oh, what have I done!"
	dc.b	$C1
	dc.b	"Wait for me. Your father's coming"
	dc.b	$C1
	dc.b	"right now", $47, $47, $47, $42
	dc.b	$C5

loc_21279:
	dc.b	"Oh, what a tragic end for the two of them!"
	dc.b	$C1
	dc.b	"But in the end, this happened because"
	dc.b	$C1
	dc.b	"the world has fallen into turmoil. We must"
	dc.b	$C1
	dc.b	"restore a life of peace, and soon."
	dc.b	$C4

loc_212EF:
	dc.b	$42, "I'm Tiem, Darum's daughter."
	dc.b	$C1
	dc.b	"Father promised me he'd come to save"
	dc.b	$C1
	dc.b	"me, for sure! That's why I'm waiting for"
	dc.b	$C1
	dc.b	"him here.", $42
	dc.b	$C4

loc_2135C:
	dc.b	$BB
	dc.b	" handed over the "
	dc.b	$BF
	dc.b	"."
	dc.b	$C1
	dc.b	"Tiem's hands were trembling."
	dc.b	$C3
	dc.b	$42, "Father has been killing people"
	dc.b	$C1
	dc.b	"for me? I have to stop him."
	dc.b	$C1
	dc.b	"Take me to Father!", $42
	dc.b	$C3

loc_21404:
	dc.b	"But many people hated Darum. Being"
	dc.b	$C1
	dc.b	"seen would be dangerous. "
	dc.b	$BB
	dc.b	" and"
	dc.b	$C1
	dc.b	"the others hid Tiem under a veil and"
	dc.b	$C1
	dc.b	"took her along."
	dc.b	$C4

loc_2146C:
	dc.b	"She's the spitting image of Nei! What is this?!"
	dc.b	$C3
	dc.b	$42, "I am Nei First. I was born"
	dc.b	$C1
	dc.b	"two years ago."
	dc.b	$C3
	dc.b	"During an experiment crossing humans"
	dc.b	$C1
	dc.b	"and animals, a massive surge of energy"
	dc.b	$C1
	dc.b	"was sent into the Biosystem. I am the"
	dc.b	$C1
	dc.b	"product of that event."
	dc.b	$C3
	dc.b	"The humans said the experiment was a"
	dc.b	$C1
	dc.b	"failure, and they tried to kill me."
	dc.b	$C3

loc_2154F:
	dc.b	"But I escaped, drew DNA data from"
	dc.b	$C1
	dc.b	"the Biosystem, and created monsters."
	dc.b	$C3
	dc.b	"To exact revenge upon the humans who"
	dc.b	$C1
	dc.b	"meddle with nature as they please and toy"
	dc.b	$C1
	dc.b	"with life itself. But within me, there was"
	dc.b	$C1
	dc.b	"another Nei who stood in my way.", $42
	dc.b	$C4

loc_21633:
	dc.b	$C2
	dc.b	$42, "Wh-what? Could that be", $47, $47, $47, "!!", $42
	dc.b	$C3

loc_21656:
	dc.b	$C2
	dc.b	$42, "Yes, the girl you call Nei!"
	dc.b	$C3
	dc.b	"You travel with that Nei, thinking"
	dc.b	$C1
	dc.b	"she's your companion, but really she's"
	dc.b	$C1
	dc.b	"no different from a hideous monster."
	dc.b	$C1
	dc.b	"She must hate humans.", $42
	dc.b	$C4

loc_216C5:
	dc.b	"Is that true? Does Nei really"
	dc.b	$C1
	dc.b	"hate humans?"
	dc.b	$C1
	dc.b	"But Nei is dead now. There's no way"
	dc.b	$C1
	dc.b	"to be sure how she felt", $47, $47, $47
	dc.b	$C4

loc_216EA:
	dc.b	$C2
	dc.b	$42, "No! That's not true!", $42, " Nei cried."
	dc.b	$C1
	dc.b	$42, "I split away because it hurt so much"
	dc.b	$C1
	dc.b	"to be inside Nei First!"
	dc.b	$C3
	dc.b	"It's true that being born a monster"
	dc.b	$C1
	dc.b	"is terribly painful and sad!"
	dc.b	$C3
	dc.b	"But I can't accept you making"
	dc.b	$C1
	dc.b	"monsters to take revenge"
	dc.b	$C1
	dc.b	"on humans.", $42
	dc.b	$C4

loc_217CB:
	dc.b	$C2
	dc.b	$42, "How impudent! You say all that,"
	dc.b	$C1
	dc.b	"but you aren't capable of fighting me."
	dc.b	$C1
	dc.b	"Go on, try it if you can.", $42
	dc.b	$C5

loc_21817:
	dc.b	$BB
	dc.b	" and the others heard a dull"
	dc.b	$C1
	dc.b	"explosion and felt a jolt, as if Gaira were"
	dc.b	$C1
	dc.b	"being swept away somewhere. They had to"
	dc.b	$C1
	dc.b	"check the controls and fix Gaira's orbit!!"
	dc.b	$C4

loc_218A0:
	dc.b	"So this is Mother Brain, who rules over"
	dc.b	$C1
	dc.b	"Algol at will! "
	dc.b	$BB
	dc.b	" and the others"
	dc.b	$C1
	dc.b	"were nearly crushed by the suspicious"
	dc.b	$C1
	dc.b	"aura exuded by Mother Brain."
	dc.b	$C3
	dc.b	"But the future of Algol rests on"
	dc.b	$C1
	dc.b	$BB
	dc.b	" and the others! To sever this hold"
	dc.b	$C1
	dc.b	"on Algol, must they fight Mother Brain?!"
	dc.b	$C5

loc_2197C:
	dc.b	"Then Mother Brain's lips curled into a"
	dc.b	$C1
	dc.b	"thin smile and said:"
	dc.b	$C3
	dc.b	$C2
	dc.b	$42, "Heh heh heh. What fools. If you destroy"
	dc.b	$C1
	dc.b	"me, the entire star system will fall into"
	dc.b	$C1
	dc.b	"panic. Without me, the people of Algol are"
	dc.b	$C1
	dc.b	"incapable of doing anything at all."
	dc.b	$C3
	dc.b	"Once they have known a life of luxury,"
	dc.b	$C1
	dc.b	"they can never go back."
	dc.b	$C3
	
loc_21A23:
	dc.b	"If you destroy me, the people will tremble"
	dc.b	$C1
	dc.b	"in misery, cursing their own fates as they"
	dc.b	$C1
	dc.b	"die."
	dc.b	$C3
	dc.b	"If that's what you want, then destroy me!!"
	dc.b	$C1
	dc.b	"Well then! If you're going to turn back, now"
	dc.b	$C1
	dc.b	"is the time!", $42
	dc.b	$C5

loc_21AC1:
	dc.b	"Then Mother Brain laughed triumphantly"
	dc.b	$C1
	dc.b	"and said:"
	dc.b	$C3
	dc.b	$C2
	dc.b	$42, "Of course. You could never destroy me."
	dc.b	$C3
	dc.b	"For to you, I am like a mother, who"
	dc.b	$C1
	dc.b	"has protected, cherished and raised"
	dc.b	$C1
	dc.b	"you."
	dc.b	$C3
	dc.b	"My darling child, Algol. From now on, I shall"
	dc.b	$C1
	dc.b	"lead this child by the hand and walk"
	dc.b	$C1
	dc.b	"the road to ruin.", $42
	dc.b	$C3
	
loc_21B89:
	dc.b	$42, "Ho ho ho ho. Now, be on your way home."
	dc.b	$C1
	dc.b	"There's nothing at all that you can do.", $42
	dc.b	$C4

loc_21BCF:
	dc.b	$42, "Very well. Then I'll show no mercy"
	dc.b	$C1
	dc.b	"either. Die and be done with it!", $42
	dc.b	$C4

loc_21BEC:
	dc.b	$42, "Welcome to the spaceship Noah,"
	dc.b	$C1
	dc.b	"children.", $42
	dc.b	$C3
	dc.b	$C2
	dc.b	$42, "Who on earth are you people?!", $42
	dc.b	$C3
	dc.b	$C2
	dc.b	$42, "'You people'? How rude. You don't think"
	dc.b	$C1
	dc.b	"we're your enemies, now, do you?", $42
	dc.b	$C5

loc_21C6A:
	dc.b	$42, "I see. Well, then we agree, since you"
	dc.b	$C1
	dc.b	"destroyed Mother Brain, that makes you our"
	dc.b	$C1
	dc.b	"hated enemy.", $42
	dc.b	$C4

loc_21CA1:
	dc.b	$42, "Indeed. After all, Algol prospered as a"
	dc.b	$C1
	dc.b	"result of Mother Brain, which we"
	dc.b	$C1
	dc.b	"constructed.", $42
	dc.b	$C4

loc_21CDE:
	dc.b	$C2
	dc.b	$42, "So! It was you all who made Mother Brain!"
	dc.b	$C1
	dc.b	"Just what are you people?!", $42
	dc.b	$C4
	
loc_21D2D:
	dc.b	"Then "
	dc.b	$BB
	dc.b	" and the others heard Lutz's"
	dc.b	$C1
	dc.b	"voice: ", $42, "Let there be light for the warriors"
	dc.b	$C1
	dc.b	"who saved Algol!", $42, " And by Lutz's mysterious"
	dc.b	$C1
	dc.b	"power, they breathed new life."
	dc.b	$C4

loc_21DA4:
	dc.b	"Now, let's go back to Motavia."
	dc.b	$C1
	dc.b	"From here out, this is all just the beginning!!"
	dc.b	$C4

loc_21DD8:
	dc.b	$C2
	dc.b	"At that moment, Lutz's power brought the"
	dc.b	$C1
	dc.b	"rest of their companions to them!!"
	dc.b	$C3
	dc.b	$C2
	dc.b	$42, "Tch. What a clever trick!! But"
	dc.b	$C1
	dc.b	"the destruction of Algol is only a matter"
	dc.b	$C1
	dc.b	"of time", $47, $47, $47, $42
	dc.b	$C3
	dc.b	$C2
	dc.b	$42, "Shut up!! Be quiet!!", $42
	dc.b	$C3
	dc.b	$C2
	dc.b	"And the next instant, "
	dc.b	$BB
	dc.b	" and"
	dc.b	$C1
	dc.b	"the others charged at the Earthmen,"
	dc.b	$C1
	dc.b	"hundreds strong", $47, $47, $47
	dc.b	$C4

loc_21EC4:
	dc.b	"Nei hung her head and didn't move."
	dc.b	$C1
	dc.b	"Nei and Nei First were once of the"
	dc.b	$C1
	dc.b	"same body. If Nei First were killed,"
	dc.b	$C1
	dc.b	"Nei couldn't survive either."
	dc.b	$C4

loc_21F67:
	dc.b	$42, "I don't want you to create any more"
	dc.b	$C1
	dc.b	"monsters. Please understand!!"
	dc.b	$C1
	dc.b	"Big sister!!", $42
	dc.b	$C4

loc_21FA8:
	dc.b	"What?! What is this? AMeDAS is shaking!"
	dc.b	$C1
	dc.b	"I see! With Nei First dead, all of her latent"
	dc.b	$C1
	dc.b	"energy is suddenly pouring into the AMeDAS"
	dc.b	$C1
	dc.b	"system!!"
	dc.b	$C4

loc_22048:
	dc.b	$42
	dc.b	$BB
	dc.b	", I'm finished", $47, $47, $47, " If Nei"
	dc.b	$C1
	dc.b	"First dies, I can't go on living"
	dc.b	$C1
	dc.b	"either", $47, $47, $47, $42, " And with that, Nei"
	dc.b	$C1
	dc.b	"quietly closed her eyes", $47, $47, $47
	dc.b	$C4

loc_220B8:
	dc.b	$BB
	dc.b	" called Nei's name once more."
	dc.b	$C1
	dc.b	"But the plaintive cry only echoed emptily"
	dc.b	$C1
	dc.b	"through the surrounding area."
	dc.b	$C4

loc_2210A:
	dc.b	"What on earth has happened!!"
	dc.b	$C1
	dc.b	$BB
	dc.b	" and the others hurried"
	dc.b	$C1
	dc.b	"back to Paseo."
	dc.b	$C4

loc_22151:
	dc.b	$42, "We'll make you taste the grief"
	dc.b	$C1
	dc.b	"of losing the ones you love!", $42
	dc.b	$C5

loc_22195:
	dc.b	$42, "I can see the confusion and"
	dc.b	$C1
	dc.b	"pity in your eyes."
	dc.b	$C1
	dc.b	"But I will never forgive"
	dc.b	$C1
	dc.b	"what you have done!", $42
	dc.b	$C5

loc_221F5:	
	dc.b	$42, "Damn you!! You wrecked our..."
	dc.b	$C1
	dc.b	"our... Algol!!", $42
	dc.b	$C5

loc_2220D:
	dc.b	$42, "I will never be a slave to fate!"
	dc.b	$C1
	dc.b	"I'll carve out my future"
	dc.b	$C1
	dc.b	"with my own hands!!", $42
	dc.b	$C5

loc_22256:
	dc.b	$42, "You showed us the ugliness of"
	dc.b	$C1
	dc.b	"living. But we will never"
	dc.b	$C1
	dc.b	"forget the beauty of life!!", $42
	dc.b	$C5

loc_2228C:
	dc.b	$42, "If something must perish,"
	dc.b	$C1
	dc.b	"then let it perish!"
	dc.b	$C1
	dc.b	"Those are my only parting"
	dc.b	$C1
	dc.b	"words for you!!", $42
	dc.b	$C5

loc_222CE:
	dc.b	"                  At the end of a time"
	dc.b	$C1
	dc.b	"                 that will never return,"
	dc.b	$C1
	dc.b	"                          what will"
	dc.b	$C1
	dc.b	"                        they see", $47, $47, $47, "?"
	dc.b	$C5

loc_22303:
	dc.b	$42
	dc.b	$BB
	dc.b	"!! Wait!!", $42, " Lutz's voice, tense in a"
	dc.b	$C1
	dc.b	"way never heard before, leapt into the"
	dc.b	$C1
	dc.b	"hearts of "
	dc.b	$BB
	dc.b	" and the others."
	dc.b	$C3
	dc.b	$42, "Something is still aboard that ship!"
	dc.b	$C1
	dc.b	"You must not come back yet!!", $42
	dc.b	$C1
	dc.b	$42, "What?!", $42
	dc.b	$C4

loc_2237B:
	dc.b	"What on earth is this?!"
	dc.b	$C1
	dc.b	"Who in the world are these people?!"
	dc.b	$C4

loc_22391:
	dc.b	$C2
	dc.b	$42, "We are not people of Algol. Our home is a"
	dc.b	$C1
	dc.b	"planet called Earth. It shone a brilliant blue"
	dc.b	$C1
	dc.b	"in the galaxy, and a caused a highly"
	dc.b	$C1
	dc.b	"advanced civilization to bloom."
	dc.b	$C3
	dc.b	"We are the last descendants"
	dc.b	$C1
	dc.b	"of Earth.", $42
	dc.b	$C3
	dc.b	$C2
	dc.b	$42, "The last", $47, $47, $47, "?", $42
	dc.b	$C3
	dc.b	$C2
	dc.b	$42, "Yes, our home is gone now."
	dc.b	$C1
	dc.b	"Would you like to know why it was lost?", $42
	dc.b	$C5

loc_2248A:
	dc.b	$42, "Looking back now, we were truly"
	dc.b	$C1
	dc.b	"a weak people."
	dc.b	$C3
	dc.b	"We knew that Dark Falz, the devil that"
	dc.b	$C1
	dc.b	"dwells within the heart, lived within us,"
	dc.b	$C1
	dc.b	"and yet we could not restrain it."
	dc.b	$C3
	dc.b	"And so, hatred begat hatred. And through"
	dc.b	$C1
	dc.b	"the hubris nurtured by the power of"
	dc.b	$C1
	dc.b	"our civilization, we came to delight in"
	dc.b	$C1
	dc.b	"bending nature to our will."
	dc.b	$C3
	dc.b	"Only at the very last moment did we"
	dc.b	$C1
	dc.b	"realize we were strangling ourselves."
	dc.b	$C3

loc_2255B:
	dc.b	"Listening to the sound of the Earth"
	dc.b	$C1
	dc.b	"breaking apart, we realized for the"
	dc.b	$C1
	dc.b	"first time that we had been wrong."
	dc.b	$C3
	dc.b	"Those of us who barely survived boarded"
	dc.b	$C1
	dc.b	"this ship and wandered through space."
	dc.b	$C1
	dc.b	"And then we found it. This... ", $42, "Algol", $42, "."
	dc.b	$C3
	dc.b	"The people here lived knowing nothing"
	dc.b	$C1
	dc.b	"of calamity. We envied them for it,"
	dc.b	$C1
	dc.b	"and we resented them for it."
	dc.b	$C3

loc_2262F:
	dc.b	"We swore an oath back then. Whatever it"
	dc.b	$C1
	dc.b	"took, we would take this planet for"
	dc.b	$C1
	dc.b	"ourselves."
	dc.b	$C3
	dc.b	"Surely you're not foolish enough to defy"
	dc.b	$C1
	dc.b	"us, the ones who had the power to destroy"
	dc.b	$C1
	dc.b	"Palma? Just accept your deaths quietly!", $42
	dc.b	$C4

loc_2269A:
	dc.b	$42, "Yes, and knowing that now makes no"
	dc.b	$C1
	dc.b	"difference to you all, moments away from"
	dc.b	$C1
	dc.b	"death. Isn't that right?", $42
	dc.b	$C5

loc_226D6:
	dc.b	$42, "I see. If you want to know,"
	dc.b	$C1
	dc.b	"I suppose we'll tell you.", $42
	dc.b	$C4

loc_226FE:
	dc.b	$42, "THIS IS THE SATELLITE GAIRA."
	dc.b	$C1
	dc.b	"OUTSIDE IS SPACE. NO ESCAPE."
	dc.b	$C1
	dc.b	"DISRUPTING MOTHER BRAIN IS A GRAVE CRIME."
	dc.b	$C1
	dc.b	"AWAIT YOUR DEATH SENTENCE HERE.", $42
	dc.b	$C3
	dc.b	$C2
	
loc_227B5:
	dc.b	"Ever since AMeDAS flooded, I've felt"
	dc.b	$C1
	dc.b	"responsible and fought to open the"
	dc.b	$C1
	dc.b	"dams, but in the end, we were captured!"
	dc.b	$C3
	dc.b	"Who is using Mother Brain's system to bring"
	dc.b	$C1
	dc.b	"ruin to Motavia? To think I would die here"
	dc.b	$C1
	dc.b	"without ever finding out", $47, $47, $47
	dc.b	$C4

loc_2287E:
	dc.b	"For a while, "
	dc.b	$BB
	dc.b	" and the others"
	dc.b	$C1
	dc.b	"stood in disbelief where Mother Brain had"
	dc.b	$C1
	dc.b	"been. Algol was free at last from"
	dc.b	$C1
	dc.b	"Mother Brain's dominion."
	dc.b	$C3

loc_2292B:
	dc.b	"AMeDAS, the Biosystem, everything"
	dc.b	$C1
	dc.b	"Mother Brain controlled would be of no"
	dc.b	$C1
	dc.b	"use now. Now, without them, Algol faced"
	dc.b	$C1
	dc.b	"a harsh and difficult existence ahead."
	dc.b	$C3
	dc.b	"However, "
	dc.b	$BB
	dc.b	" and the others could"
	dc.b	$C1
	dc.b	"feel a light of hope dwelling within"
	dc.b	$C1
	dc.b	"this new Algol."
	dc.b	$C4

loc_229E5:
	dc.b	$42, "Nei! Hang on, Nei!", $42
	dc.b	$C3
	dc.b	$C2
	dc.b	$42, "It's no use", $47, $47, $47, " "
	dc.b	$BB
	dc.b	", please."
	dc.b	$C1
	dc.b	"Promise me you'll never make devils"
	dc.b	$C1
	dc.b	"like us again."
	dc.b	$C3
	
loc_22A8E:
	dc.b	"May everyone find happiness in a peaceful"
	dc.b	$C1
	dc.b	"Algol", $47, $47, $47, $42
	dc.b	$C3
	dc.b	$C2
	dc.b	"And with those words, Nei died", $47, $47, $47
	dc.b	$C1
	dc.b	$BB
	dc.b	" and the others gently laid"
	dc.b	$C1
	dc.b	"Nei's body down."
	dc.b	$C1
	dc.b	$42, "Nei! We'll avenge you, right now!", $42
	dc.b	$C4

loc_22B07:
	dc.b	$42, "We will claim this planet in lieu of"
	dc.b	$C1
	dc.b	"the home we lost. That's all there"
	dc.b	$C1
	dc.b	"is to it. Mother Brain may be gone, but"
	dc.b	$C1
	dc.b	"with our power,"
	dc.b	$C3
	dc.b	"it's a simple matter to create a new"
	dc.b	$C1
	dc.b	"ruler for Algol."
	dc.b	$C3
	dc.b	"You are the only ones trying to defy us."
	dc.b	$C1
	dc.b	"Without you, Algol will be ours to command"
	dc.b	$C1
	dc.b	"as we please."
	dc.b	$C1
	dc.b	"Now, prepare to die.", $42
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
	dc.b	"This is bad! This artificial satellite is"
	dc.b	$C1
	dc.b	"headed straight for Palma!!"
	dc.b	$C1
	dc.b	"There's no time left!!!"
	dc.b	$C1
	dc.b	"What should I do? What should I do", $47, $47, $47, "?"
	dc.b	$C5

loc_22C4F:
	dc.b	"Ah, I'm having the same dream again", $47, $47, $47
	dc.b	$C5

loc_22C6D:
	dc.b	$C2
	dc.b	$42, "Help me!!!", $42
	dc.b	$C7

loc_22C76:
	dc.b	$C2
	dc.b	$47, $47, $47, $47, $47, "?!"
	dc.b	$C7

loc_22C7F:
	dc.b	$C2
	dc.b	"You're awake, huh?"
	dc.b	$C1
	dc.b	"I'm Tyler. A space pirate. I got tired of"
	dc.b	$C1
	dc.b	"living underneath Mother Brain's absolute"
	dc.b	$C1
	dc.b	"control, so I fled Palma."
	dc.b	$C3

loc_22D28:
	dc.b	"You were locked up on Gaira, right?"
	dc.b	$C1
	dc.b	"Lucky I happened to be passing by."
	dc.b	$C1
	dc.b	"Your companions are in the regeneration"
	dc.b	$C1
	dc.b	"tanks, too. They should wake up soon."
	dc.b	$C4

loc_22D99:
	dc.b	"Still, you've been through a tough ordeal,"
	dc.b	$C1
	dc.b	"haven't you? Look. That's the end of Palma."
	dc.b	$C4

loc_22DCD:
	dc.b	"A whole planet has died."
	dc.b	$C1
	dc.b	"What on earth will become of Algol?"
	dc.b	$C1
	dc.b	"Right now I don't even know what"
	dc.b	$C1
	dc.b	"to say to you."
	dc.b	$C3

loc_22E92:
	dc.b	"The news said you were the criminals who"
	dc.b	$C1
	dc.b	"drove Mother Brain crazy, but there's no"
	dc.b	$C1
	dc.b	"way you could have done a thing like that."
	dc.b	$C1
	dc.b	"Isn't that right?"
	dc.b	$C3
	dc.b	"For now, I'll take you as far as Paseo."
	dc.b	$C1
	dc.b	"I've retrieved your belongings for you."
	dc.b	$C3

loc_22F31:
	dc.b	"Oh, right! Have you been to Dezolis?"
	dc.b	$C1
	dc.b	"Rumor has it there's someone there"
	dc.b	$C1
	dc.b	"with the very power Mother Brain fears most."
	dc.b	$C3
	dc.b	"Maybe that's your culprit!"
	dc.b	$C1
	dc.b	"Let's meet again sometime!"
	dc.b	$C4

loc_22FDF:
	dc.b	"Welcome, "
	dc.b	$BB
	dc.b	". I am Lutz, the last"
	dc.b	$C1
	dc.b	"esper of Algol. You seem to be wondering"
	dc.b	$C1
	dc.b	"how I know your name."
	dc.b	$C3
	dc.b	"You may not recall, but this is the second"
	dc.b	$C1
	dc.b	"time we have met. When you were ten, on a"
	dc.b	$C1
	dc.b	"journey into space with your parents, you"
	dc.b	$C1
	dc.b	"were involved in an accident."
	dc.b	$C3
	dc.b	"At that time I awakened, and with the"
	dc.b	$C1
	dc.b	"power of light, I summoned you and"
	dc.b	$C1
	dc.b	"brought you back to life."
	dc.b	$C1

loc_230C0:
	dc.b	"What woke me was Alisa's scream."
	dc.b	$C3
	dc.b	"Yes, you are the last descendant of"
	dc.b	$C1
	dc.b	"Alisa, who once fought to protect"
	dc.b	$C1
	dc.b	"Algol. And you have seen it too:"
	dc.b	$C3
	dc.b	"the nightmare in which Alisa, the symbol of"
	dc.b	$C1
	dc.b	"beautiful Algol, fights the power of"
	dc.b	$C1
	dc.b	"darkness known as Dark Falz."
	dc.b	$C3
	
loc_2314C:
	dc.b	"Dark Falz is the one who once sought"
	dc.b	$C1
	dc.b	"to bring Algol to ruin. However, Dark Falz"
	dc.b	$C1
	dc.b	"was defeated."
	dc.b	$C4

loc_231DB:
	dc.b	"But that doesn't mean there is no one"
	dc.b	$C1
	dc.b	"left who plots to destroy Algol."
	dc.b	$C3
	dc.b	$BB
	dc.b	", gather the weapons needed to"
	dc.b	$C1
	dc.b	"defeat these evil ones. Among them is the"
	dc.b	$C1
	dc.b	"Aeroprism, a prism to reveal that which"
	dc.b	$C1
	dc.b	"could not be seen."
	dc.b	$C3

loc_23290:
	dc.b	"Once you have gathered every weapon"
	dc.b	$C1
	dc.b	"bearing the name Nei, which means ", $42, "that"
	dc.b	$C1
	dc.b	"which is not", $42, $47, $47, $47, " I shall tell you of the"
	dc.b	$C1
	dc.b	"schemes of something malevolent."
	dc.b	$C4

loc_2330A:
	dc.b	"Ha ha ha ha ha!!"
	dc.b	$C1
	dc.b	"Welcome to the trap of evil, Pandora's Box!"
	dc.b	$C1
	dc.b	"Sealed within is the entirety of the calamity"
	dc.b	$C1
	dc.b	"you call Dark Falz!"
	dc.b	$C3
	dc.b	"This is a gift from our world to yours."
	dc.b	$C1
	dc.b	"Accept it."
	dc.b	$C7

loc_233AA:
	dc.b	$BB
	dc.b	". Have you the courage to go"
	dc.b	$C1
	dc.b	"and defeat the evil ones?"
	dc.b	$C5

loc_233E8:
	dc.b	"I see", $47, $47, $47, " Then I shall pray for you."
	dc.b	$C3
	dc.b	"O god of Algol! Grant these ones"
	dc.b	$C1
	dc.b	"courage and strength!"
	dc.b	$C4

loc_2345E:
	dc.b	"Now, take the Nei Sword"
	dc.b	$C1
	dc.b	"from that box."
	dc.b	$C4
; ---------------------------------------------------------------------------------
	
	even

	charset

; =============================================================================
; long_names: party names of up to six letters.
;
; Stock: a name is four bytes at character_names ($C660 + 4n), filled by the
; naming window through $C63C-$C63F, copied into the dialogue by the {NAME}
; inserts (Script_ProcessCharNames, four letters) and converted by SetCharNames
; into four font-tile pairs at $C038 + $40n, which every window that shows a
; party member (the status screens, the battle box, the shops) draws as four
; cells. Rudger, Kains, Shilka and Eusis do not fit.
;
; Here letters 5-6 live beside the name at NAME_EXT ($C686 + 2n): the saved
; party block runs $C600-$C69D and nothing uses $C686-$C69B (no reference in
; the code, zero in every RAM image taken), so saves carry them unchanged. The
; naming window takes six letters (four for a save file's name, in the Data
; Memory), writes letters after the first in lower case - the letter grid has
; only capitals - and keeps letters 5-6 at NAME_ENTRY_EXT ($C630, unused too).
; The inserts copy all six. The windows get a name plate instead of letter
; tiles: each name is drawn in the proportional face into four tiles of its
; own - font tiles that hold kana or JP capitals the US game never shows - so
; six letters fit the four cells (Rudger is 29 px). The font is reloaded on
; most screen changes, so every font load draws the plates again.
; =============================================================================
	if long_names

NAME_EXT	= $FFFFC686		; letters 5-6 of each party name (8 x 2)
NAME_ENTRY_EXT	= $FFFFC630		; letters 5-6 of the name in the naming window
NAMES_CANVAS	= text_buffer+$1E0	; 4 cells x 8 rows, cell-major (the plate being drawn)
NAMES_PLATE_PX	= 32

	charset	'A', "\11\12\13\14\15\16\17\18\19\20\21\22\23\24\25\26\27\28\29\30\31\32\33\34\35\36"
	charset	'a', "\37\38\39\40\41\42\43\44\45\46\47\48\49\50\51\52\53\54\55\56\57\58\59\60\61\62"
	charset	' ', 0
	outradix 10
length	:=	6
; The default names, six letters each at most (tools/gentext.py: work/script.json charnames).
CharNamesLong:
	nametxt	"ROLF"
	nametxt	"NEI"
	nametxt	"RUDO"
	nametxt	"AMY"
	nametxt	"HUGH"
	nametxt	"ANNA"
	nametxt	"KAIN"
	nametxt	"SHIR"
CharNamesLongEnd:
	outradix 16
	charset

	even
; Font tiles (counted from $500) that hold the plates: four per character.
NamePlateTiles:
	dc.b	$81, $82, $83, $84,  $85, $86, $87, $88,  $89, $8A, $8B, $8C,  $8D, $8E, $8F, $90
	dc.b	$91, $92, $93, $94,  $95, $96, $A1, $A2,  $A3, $A4, $A5, $A6,  $A7, $A8, $A9, $AA

; ---------------------------------------------------------------------------
; New game: the default names (replaces the copy of CharNames).
; ---------------------------------------------------------------------------
Names_Init:
	lea	(CharNamesLong).l, a0
	lea	(character_names).w, a1
	lea	(NAME_EXT).w, a2
	moveq	#7, d0
-
	move.b	(a0)+, (a1)+
	move.b	(a0)+, (a1)+
	move.b	(a0)+, (a1)+
	move.b	(a0)+, (a1)+
	move.b	(a0)+, (a2)+
	move.b	(a0)+, (a2)+
	dbf	d0, -
	rts

; ---------------------------------------------------------------------------
; LoadScript's {NAME} / {NAME2}: d1 = the character, a3 = character_names,
; a2 = text_buffer. Copies up to six letters (the stock: four).
; ---------------------------------------------------------------------------
Names_Insert:
	move.w	d1, d0
	lsl.w	#2, d1
	adda.w	d1, a3
	moveq	#3, d1
-
	cmpi.b	#$C4, (a3)
	beq.s	Names_Insert_Done
	move.b	(a3)+, (a2)+
	dbf	d1, -
	lea	(NAME_EXT).w, a3
	add.w	d0, d0
	adda.w	d0, a3
	moveq	#1, d1
-
	move.b	(a3)+, d0
	cmpi.b	#$C4, d0
	beq.s	Names_Insert_Done
	tst.b	d0			; a four-letter name's padding
	beq.s	Names_Insert_Done
	move.b	d0, (a2)+
	dbf	d1, -
Names_Insert_Done:
	rts

; ---------------------------------------------------------------------------
; SetCharNames: point every character's name cells at its plate and draw the
; plates (replaces the conversion to letter tiles).
; ---------------------------------------------------------------------------
Names_SetPlates:
	lea	($FFFFC038).w, a2
	lea	(NamePlateTiles).l, a0
	moveq	#7, d0
-
	move.l	#$26262626, (a2)	; the dakuten row: blank
	move.l	(a0)+, 4(a2)		; the letter row: the plate's four tiles
	lea	$40(a2), a2
	dbf	d0, -
	; fall through to Names_UploadVRAM

; Draw the eight plates into the font in VRAM.
Names_UploadVRAM:
	movem.l	d0-d7/a0-a6, -(sp)
	move	sr, -(sp)
	move	#$2700, sr
	lea	(vdp_control_port).l, a2
	lea	(vdp_data_port).l, a3
	move.w	#$8F02, (a2)
	moveq	#0, d7			; the character
Names_UpV_Char:
	bsr.w	Names_Render
	moveq	#0, d5			; the plate's cell
Names_UpV_Cell:
	move.w	d7, d0
	lsl.w	#2, d0
	add.w	d5, d0
	lea	(NamePlateTiles).l, a0
	moveq	#0, d1
	move.b	(a0,d0.w), d1
	move.w	d1, d0
	addi.w	#$500, d0
	bsr.w	VWF_VRAMWrite
	bsr.w	Names_ExpandCell	; 8 longwords of cell d5 to (a3)
	addq.w	#1, d5
	cmpi.w	#4, d5
	bne.s	Names_UpV_Cell
	addq.w	#1, d7
	cmpi.w	#8, d7
	bne.s	Names_UpV_Char
	move	(sp)+, sr
	movem.l	(sp)+, d0-d7/a0-a6
	rts

; Draw the eight plates into a font image in RAM at a5 (tile k at a5 + 32k).
Names_UploadRAM:
	movem.l	d0-d7/a0-a6, -(sp)
	movea.l	a5, a6
	moveq	#0, d7
Names_UpR_Char:
	bsr.w	Names_Render
	moveq	#0, d5
Names_UpR_Cell:
	move.w	d7, d0
	lsl.w	#2, d0
	add.w	d5, d0
	lea	(NamePlateTiles).l, a0
	moveq	#0, d1
	move.b	(a0,d0.w), d1
	lsl.w	#5, d1
	lea	(a6,d1.w), a3		; the tile in the image; Names_ExpandCell writes (a3)+
	bsr.w	Names_ExpandCellRAM
	addq.w	#1, d5
	cmpi.w	#4, d5
	bne.s	Names_UpR_Cell
	addq.w	#1, d7
	cmpi.w	#8, d7
	bne.s	Names_UpR_Char
	movem.l	(sp)+, d0-d7/a0-a6
	rts

; Draw character d7's name into NAMES_CANVAS. Letters that would cross the
; plate's 32 px are dropped (the proofreader holds the defaults to it).
Names_Render:
	lea	(NAMES_CANVAS).w, a5
	moveq	#7, d0
-
	clr.l	(a5)+
	dbf	d0, -
	moveq	#0, d4			; the pen
	lea	(character_names).w, a1
	move.w	d7, d0
	lsl.w	#2, d0
	adda.w	d0, a1
	moveq	#3, d6
-
	moveq	#0, d1
	move.b	(a1)+, d1
	cmpi.b	#$C4, d1
	beq.s	Names_Render_Done
	bsr.s	Names_Letter
	dbf	d6, -
	lea	(NAME_EXT).w, a1
	move.w	d7, d0
	add.w	d0, d0
	adda.w	d0, a1
	moveq	#1, d6
-
	moveq	#0, d1
	move.b	(a1)+, d1
	cmpi.b	#$C4, d1
	beq.s	Names_Render_Done
	tst.b	d1
	beq.s	Names_Render_Done
	bsr.s	Names_Letter
	dbf	d6, -
Names_Render_Done:
	rts

; OR letter d1 into the canvas at pen d4 and advance it.
Names_Letter:
	lea	(VWF_Width).l, a0
	moveq	#0, d2
	move.b	(a0,d1.w), d2		; advance
	move.w	d4, d3
	add.w	d2, d3
	subq.w	#1, d3			; the last pixel of ink + gap - 1
	cmpi.w	#NAMES_PLATE_PX, d3
	bhi.s	Names_Letter_Done
	lea	(VWF_Font).l, a0
	lsl.w	#3, d1
	adda.w	d1, a0
	move.w	d4, d3
	lsr.w	#3, d3			; cell
	lsl.w	#3, d3
	lea	(NAMES_CANVAS).w, a5
	adda.w	d3, a5
	move.w	d4, d3
	andi.w	#7, d3			; pixel in the cell
	moveq	#7, d0
-
	moveq	#0, d1
	move.b	(a0)+, d1
	lsl.w	#8, d1
	lsr.w	d3, d1
	cmpa.w	#(NAMES_CANVAS+24)&$FFFF, a5
	bcc.s	+			; the last cell has no neighbour to spill into
	or.b	d1, 8(a5)
+
	lsr.w	#8, d1
	or.b	d1, (a5)+
	dbf	d0, -
	add.w	d2, d4
Names_Letter_Done:
	rts

; Cell d5 of the canvas, expanded, to the VDP data port (a3).
Names_ExpandCell:
	lea	(NAMES_CANVAS).w, a5
	move.w	d5, d0
	lsl.w	#3, d0
	adda.w	d0, a5
	lea	(VWF_Expand).l, a0
	moveq	#7, d6
-
	moveq	#0, d0
	move.b	(a5)+, d0
	lsl.w	#2, d0
	move.l	(a0,d0.w), (a3)
	dbf	d6, -
	rts

; Cell d5 of the canvas, expanded, to RAM at (a3)+.
Names_ExpandCellRAM:
	lea	(NAMES_CANVAS).w, a5
	move.w	d5, d0
	lsl.w	#3, d0
	adda.w	d0, a5
	lea	(VWF_Expand).l, a0
	moveq	#7, d6
-
	moveq	#0, d0
	move.b	(a5)+, d0
	lsl.w	#2, d0
	move.l	(a0,d0.w), (a3)+
	dbf	d6, -
	rts

; ---------------------------------------------------------------------------
; The font loads: after the stock decompression, the plates again.
; ---------------------------------------------------------------------------
Names_FontVRAM:				; the VDP address is set by the caller
	lea	(FontsIconsArt).l, a0
	jsr	(DecompressArt).l
	bra.w	Names_UploadVRAM

Names_FontRAM:				; a4 = the RAM image (DecompressArt2 advances it)
	move.l	a4, -(sp)
	lea	(FontsIconsArt).l, a0
	jsr	(DecompressArt2).l
	move.l	a5, -(sp)
	movea.l	4(sp), a5		; the image's start
	bsr.w	Names_UploadRAM
	movea.l	(sp)+, a5
	addq.l	#4, sp
	rts

; ---------------------------------------------------------------------------
; The naming window (Win_NameInput).
; ---------------------------------------------------------------------------
Names_EntryInit:
	clr.l	($FFFFC63C).w
	clr.w	(NAME_ENTRY_EXT).w
	rts

; The last position the window takes: 5, or 3 for a save file's name.
Names_EntryMax:
	moveq	#5, d2
	cmpi.w	#BuildingID_DataMemory, (building_index).w
	bne.s	+
	moveq	#3, d2
+
	rts

; A letter chosen (d1; $C4 = END). a0 = $C63C + the position (the stock address).
Names_EntryLetter:
	cmpi.b	#$C4, d1
	bne.s	Names_EntryLetter_Put
	addq.l	#4, sp
	jmp	(loc_10494).l
Names_EntryLetter_Put:
	move.w	(chosen_letter_position).w, d2
	beq.s	Names_EntryLetter_Where	; the first letter stays a capital
	cmpi.b	#11, d1
	bcs.s	Names_EntryLetter_Where
	cmpi.b	#36, d1
	bhi.s	Names_EntryLetter_Where
	addi.b	#26, d1			; A-Z -> a-z
Names_EntryLetter_Where:
	cmpi.w	#4, d2
	bcs.s	Names_EntryLetter_Store
	lea	(NAME_ENTRY_EXT-4).w, a0
	adda.w	d2, a0
Names_EntryLetter_Store:
	move.b	d1, (a0)
	rts

Names_EntryAdvance:			; ADV, or a letter placed: the next position
	bsr.s	Names_EntryMax
	cmp.w	(chosen_letter_position).w, d2
	beq.s	+
	addq.w	#1, (chosen_letter_position).w
+
	rts

; END: the $C4 after the last letter entered (d1 = $C4), as the stock does for four.
Names_EntryEnd:
	bsr.s	Names_EntryMax
	move.w	d2, d3			; the last position
	move.w	d2, d0
Names_EntryEnd_Scan:
	bsr.s	Names_EntryAddr
	tst.b	(a0)
	bne.s	Names_EntryEnd_Found
	subq.w	#1, d0
	bpl.s	Names_EntryEnd_Scan	; all blank: d0 = -1, the $C4 goes first
Names_EntryEnd_Found:
	cmp.w	d3, d0
	beq.s	Names_EntryEnd_Full	; every position holds a letter
	addq.w	#1, d0
	bsr.s	Names_EntryAddr
	move.b	d1, (a0)
Names_EntryEnd_Full:
	rts

; a0 = the address of position d0 in the naming window's name.
Names_EntryAddr:
	lea	($FFFFC63C).w, a0
	cmpi.w	#4, d0
	bcs.s	+
	lea	(NAME_ENTRY_EXT-4).w, a0
+
	adda.w	d0, a0
	rts

; A party member named (loc_B384): the four letters and letters 5-6.
Names_EntryStore:
	lea	(character_names).w, a2
	move.w	(character_index).w, d0
	lsl.w	#2, d0
	adda.w	d0, a2
	move.l	($FFFFC63C).w, (a2)
	lea	(NAME_EXT).w, a2
	move.w	(character_index).w, d0
	add.w	d0, d0
	move.w	(NAME_ENTRY_EXT).w, (a2,d0.w)
	rts

	endif

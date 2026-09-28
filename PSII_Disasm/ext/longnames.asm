; =============================================================================
; long_item_names: full-length item, technique and enemy names.
;
; The stock names live in the records (InventoryData: 16 bytes, the name 10;
; TechniqueData: 8, the name 5; EnemyNames: 10) and are copied by length. Here
; a name is looked up by its record in tables of their own (ext/lnames.asm,
; generated from work/script.json), ended by $C4: the window runs draw it
; (WT_Render, vwf_windows) in the pixels the stock cells had, and the script's
; {ENEMY}, {TECH} and {ITEM} inserts copy it (Script_ProcessItemEnemyNames and
; Script_ProcessTechNames jump to LN_Insert). The records keep the stock names.
; =============================================================================
	if long_item_names
	if vwf_windows==0
	error "long_item_names needs vwf_windows"
	endif

; a0 = a name in a record -> a0 = its long name, Z clear; anything else stays,
; Z set. Every other register is kept.
LN_Lookup:
	movem.l	d0-d2/a1, -(sp)
	lea	(LN_Ranges).l, a1
LN_Lookup_Next:
	move.l	(a1)+, d1		; the first record
	beq.s	LN_Lookup_None
	move.l	(a1)+, d2		; after the last
	move.l	a0, d0
	cmp.l	d1, d0
	bcs.s	LN_Lookup_Skip
	cmp.l	d2, d0
	bcc.s	LN_Lookup_Skip
	sub.l	d1, d0
	divu.w	4(a1), d0		; the record; the remainder in the high word
	swap	d0
	tst.w	d0
	bne.s	LN_Lookup_Skip		; inside a record, not its name
	swap	d0
	lsl.w	#2, d0
	movea.l	(a1), a1
	movea.l	(a1,d0.w), a0
	movem.l	(sp)+, d0-d2/a1
	andi.b	#$FB, ccr		; Z clear: a long name
	rts
LN_Lookup_Skip:
	addq.w	#8, a1			; the table and the record size
	bra.s	LN_Lookup_Next
LN_Lookup_None:
	movem.l	(sp)+, d0-d2/a1
	ori.b	#4, ccr			; Z set: not a name
	rts

; the records, after the last, the long names, the record size
LN_Ranges:
	dc.l	InventoryData, InventoryData+LN_Items_N*16, LN_Items
	dc.w	16, 0
	dc.l	TechniqueData, TechniqueData+LN_Techs_N*8, LN_Techs
	dc.w	8, 0
	dc.l	EnemyNames, EnemyNames+LN_Enemies_N*10, LN_Enemies
	dc.w	10, 0
	dc.l	0

; An insert: a3 = the name in its record, a2 = text_buffer; copies the long
; name (a2 after it). In place of the stock copy by length.
LN_Insert:
	movem.l	d0/a0, -(sp)
	movea.l	a3, a0
	bsr.w	LN_Lookup
	moveq	#31, d0
LN_Insert_Copy:
	cmpi.b	#$C4, (a0)
	beq.s	LN_Insert_Done
	move.b	(a0)+, (a2)+
	dbf	d0, LN_Insert_Copy
LN_Insert_Done:
	movem.l	(sp)+, d0/a0
	rts

	include	"ext/lnames.asm"
	endif

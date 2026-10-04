; =============================================================================
; The field menu's Equip screen as PS IV's (party_menu_ps4): at the top left
; the comparison - Attack, Defense and Agility now and with the highlighted
; item (with the hand being chosen, once a one-handed weapon is picked) -, the
; item list beside it holding only what this character can equip (worn items
; marked E, so picking one still removes it) in a fixed eight-row window,
; "Equip" on its bottom border, and the equipment below the comparison with
; the character's name on its bottom border.
;
; The stock flow is kept: the windows are the stock ones (EquipStats is the
; comparison), opened and redrawn by their plain IDs and moved by the record
; hook while the Equip screen is up (PM_EquipMode). The filtering swaps the
; character's inventory for the equippable items (EQ_Filter) while the screen
; is up and writes the E marks back when it closes (EQ_Restore): equipping
; neither adds nor removes items, so every stock use of the list index as an
; inventory index stays right.
;
; The comparison's labels and arrow are runs drawn with the window; its six
; numbers are written into its cells every frame they change (EQ_Frame), as
; the stock stats window's animation writes its own (loc_96F4, which is off
; while the Equip screen is up), so the list keeps the input.
; =============================================================================
	if party_menu_ps4

EQ_INV_SAVE	= $FFFF8E48		; 17 bytes: the character's count and 16 items
EQ_INV_MAP	= $FFFF8E5A		; 16 bytes: the filtered list's inventory indices
EQ_INV_CHAR	= $FFFF8E6A		; word: the character whose inventory is swapped, + 1
EQ_SHOWN	= $FFFF8E6C		; 6 words: the numbers in the comparison ($FFFF: none)
EQ_PATCH	= $FFFF8E78		; word: the list art row given a border, or 0
EQ_SCRATCH	= $FFFF8E7A		; word: where the page-1 E fix writes when it has nothing to fix
EQ_LIST_REC	= $FFFF8EEA		; 8 bytes: the list's fixed-height record

EQ_ART_LIST	= window_art_buffer+WinArt_MenuItemList-DynamicWindowsStart	; 13 x 18
EQ_ART_EQUIP	= window_art_buffer+WinArt_StrngEquip-DynamicWindowsStart	; 15 x 12
EQ_CMP_ART	= PM_INFO_ART		; the info window's buffer: never up here (98 bytes)
EQ_CMP_W	= 14
EQ_LIST_W	= 13

; Equip > a character (the hook replaces loc_AAE6's queue): the filtered
; inventory, then the stock windows but the LV/EXP one, which PS IV has not.
PM_EquipQueue:
	bsr.w	EQ_Filter
	move.l	#(WinID_EqpEquipList<<$10)|WinID_EquipStats, (window_index).w
	move.w	#WinID_ItemList2, (window_index+4).w
	rts

; The character's inventory, kept in EQ_INV_SAVE, becomes the items they can
; equip (InventoryData+$D: a bit per character), in order, E marks and all;
; EQ_INV_MAP holds where each came from. Nothing equippable: left as it is.
EQ_Filter:
	movem.l	d0-d4/a0-a4, -(sp)
	move.w	(character_index).w, d2
	lea	($FFFFC027).w, a2
	move.w	d2, d0
	lsl.w	#6, d0
	adda.w	d0, a2			; the count, then the 16 items
	movea.l	a2, a1
	lea	(EQ_INV_SAVE).w, a0
	moveq	#17-1, d0
-
	move.b	(a1)+, (a0)+
	dbf	d0, -
	moveq	#0, d1
	move.b	(a2), d1
	lea	(EQ_INV_SAVE+1).w, a0
	lea	(EQ_INV_MAP).w, a3
	lea	1(a2), a1
	lea	(InventoryData+$D).l, a4
	moveq	#0, d3			; equippable so far
	moveq	#0, d4			; the inventory index
	bra.s	EQF_next
EQF_item:
	moveq	#0, d0
	move.b	(a0,d4.w), d0
	andi.w	#$7F, d0
	lsl.w	#4, d0
	btst	d2, (a4,d0.w)
	beq.s	EQF_skip
	move.b	(a0,d4.w), (a1)+
	move.b	d4, (a3)+
	addq.w	#1, d3
EQF_skip:
	addq.w	#1, d4
EQF_next:
	cmp.w	d1, d4
	bcs.s	EQF_item
	tst.w	d3
	beq.s	EQF_done		; nothing to equip: the stock list and messages
	move.b	d3, (a2)
	moveq	#16-1, d0
	sub.w	d3, d0
	bmi.s	+
-
	clr.b	(a1)+
	dbf	d0, -
+
	addq.w	#1, d2
	move.w	d2, (EQ_INV_CHAR).w
EQF_done:
	movem.l	(sp)+, d0-d4/a0-a4
	rts

; The Equip screen has closed: the E marks back into the whole inventory, and
; the inventory back.
EQ_Restore:
	movem.l	d0-d2/a0-a3, -(sp)
	bsr.w	EQ_Unpatch
	move.w	(EQ_INV_CHAR).w, d2
	beq.s	EQR_done
	subq.w	#1, d2
	lea	($FFFFC027).w, a2
	lsl.w	#6, d2
	adda.w	d2, a2
	moveq	#0, d1
	move.b	(a2), d1		; the filtered count
	lea	1(a2), a1
	lea	(EQ_INV_MAP).w, a3
	lea	(EQ_INV_SAVE+1).w, a0
	bra.s	EQR_next
EQR_item:
	moveq	#0, d2
	move.b	(a3)+, d2
	andi.b	#$7F, (a0,d2.w)
	move.b	(a1)+, d0
	andi.b	#$80, d0
	or.b	d0, (a0,d2.w)
EQR_next:
	dbf	d1, EQR_item
	lea	(EQ_INV_SAVE).w, a0
	moveq	#17-1, d0
-
	move.b	(a0)+, (a2)+
	dbf	d0, -
	clr.w	(EQ_INV_CHAR).w
EQR_done:
	movem.l	(sp)+, d0-d2/a0-a3
	rts

; PM_Record, with the Equip screen up (d0 = the window ID): Z clear and a1 =
; the layout base if it is one of its windows.
EQ_Record:
	cmpi.w	#WinID_ItemList2, d0
	beq.s	EQC_list
	cmpi.w	#WinID_ItemList3, d0
	beq.s	EQC_list
	lea	(EQ_Layouts).l, a0
EQC_scan:
	move.w	(a0)+, d1
	beq.s	EQC_no
	cmp.w	d0, d1
	beq.s	EQC_found
	addq.w	#8, a0
	bra.s	EQC_scan
EQC_found:
	move.w	d0, d1
	lsl.w	#3, d1
	movea.l	a0, a1
	suba.w	d1, a1
	andi.b	#$FB, ccr
	rts
EQC_no:
	ori.b	#4, ccr
	rts
EQC_list:				; the list: full height even if equipping adds an item
	lea	(EQ_LIST_REC).w, a0
	move.w	#$4000|(1<<7)|(18*2), (a0)	; columns 18-32 from row 1 (stock 23, 1)
	cmpi.w	#WinID_ItemList3, d0
	bne.s	+
	move.w	#$4000|(2<<7)|(19*2), (a0)	; its second page one cell down and right, as stock
+
	move.l	#EQ_ART_LIST&$FFFFFF, 2(a0)
	move.b	#EQ_LIST_W+1, 6(a0)
	move.b	#17, 7(a0)		; eight rows: redraws may add an inventory item
	move.w	d0, d1
	lsl.w	#3, d1
	movea.l	a0, a1
	suba.w	d1, a1
	andi.b	#$FB, ccr
	rts

; PM_Dispatch, with the Equip screen up (d0 = the window ID, d1 = its routine).
EQ_Dispatch:
	cmpi.w	#WinID_EquipStats, d0
	beq.w	EQ_BuildCompare
	tst.w	d1
	bne.w	PM_Stock		; routines 1 and 2: the stock cursor and input
	cmpi.w	#WinID_EqpEquipList, d0
	beq.s	EQD_equip
	cmpi.w	#WinID_ItemList2, d0
	beq.s	EQD_list
	cmpi.w	#WinID_ItemList3, d0
	bne.w	PM_Stock
EQD_list:
	move.w	d0, -(sp)
	bsr.w	PM_Stock		; the stock art, then its bottom border
	move.w	(sp)+, d0
	bra.w	EQ_ListBorder
EQD_equip:
	bsr.w	PM_Stock
	; fall through: the name on the bottom border

; The equipment window's bottom border carries the character's name (four
; marker bytes in the middle: wintext draws the name over the line).
EQ_NameOnBorder:
	move.l	a0, -(sp)
	move.w	(character_index).w, d0
	addi.b	#$81, d0
	lea	(EQ_ART_EQUIP+11*15+5).w, a0
	move.b	d0, (a0)+
	move.b	d0, (a0)+
	move.b	d0, (a0)+
	move.b	d0, (a0)+
	movea.l	(sp)+, a0
	rts

; The status screen's equipment window shares the art: its border again.
EQ_BorderBack:
	move.l	a0, -(sp)
	lea	(EQ_ART_EQUIP+11*15+5).w, a0
	move.b	#$BE, (a0)+
	move.b	#$BE, (a0)+
	move.b	#$BE, (a0)+
	move.b	#$BE, (a0)+
	movea.l	(sp)+, a0
	rts

; d0 = ItemList2 or ItemList3: the fixed bottom border with "Equip"
; (letter tiles: wintext redraws the word). The Items menu's list shares
; this art; EQ_Unpatch puts the row back once it is drawn.
EQ_ListBorder:
	movem.l	d0-d1/a0-a1, -(sp)
	bsr.w	EQ_Unpatch
	lea	(EQ_ART_LIST+17*EQ_LIST_W).w, a0
	move.w	a0, (EQ_PATCH).w
	moveq	#EQ_LIST_W-1, d0
-
	move.b	#$BE, (a0)+
	dbf	d0, -
	suba.w	#EQ_LIST_W-4, a0
	move.b	#$2B, (a0)+		; E
	move.b	#$51, (a0)+		; q
	move.b	#$55, (a0)+		; u
	move.b	#$49, (a0)+		; i
	move.b	#$50, (a0)+		; p
	movem.l	(sp)+, d0-d1/a0-a1
	rts

; The patched list row back as the template has it.
EQ_Unpatch:
	movem.l	d0/a0-a1, -(sp)
	move.w	(EQ_PATCH).w, d0
	beq.s	EQU_done
	movea.w	d0, a0
	subi.w	#(EQ_ART_LIST&$FFFF), d0
	lea	(WinArt_MenuItemList).l, a1	; the ROM template the RAM art is loaded from
	adda.w	d0, a1
	moveq	#EQ_LIST_W-1, d0
-
	move.b	(a1)+, (a0)+
	dbf	d0, -
	clr.w	(EQ_PATCH).w
EQU_done:
	movem.l	(sp)+, d0/a0-a1
	rts

; The comparison's art: three rows of a label, three cells for the number
; now, the arrow, three for the number then; the numbers are EQ_Frame's.
EQ_BuildCompare:
	move.w	#0, (window_index_saved).w
	movem.l	d0-d7/a0-a3, -(sp)
	move.w	#$FFFF, (EQ_SHOWN).w
	lea	(EQ_CMP_ART).w, a1
	move.w	#EQ_CMP_W*7, d0
	bsr.w	PM_ForgetRuns
	moveq	#EQ_CMP_W, d0
	move.w	#$B9, d1
	bsr.w	PM_Fill
	lea	(EQ_Labels).l, a2
	moveq	#3-1, d7
EQB_row:
	move.b	#$26, (a1)+
	movea.l	(a2)+, a0		; the label: a run of five cells
	moveq	#5, d4
	moveq	#WT_RUN_KIND_LABEL, d5	; as many letters as fit (TEXT: one a cell)
	jsr	(WT_Register).l
	moveq	#5+3, d0
	moveq	#$26, d1
	bsr.w	PM_Fill
	lea	(EQ_Arrow).l, a0	; the arrow: a run of one
	moveq	#1, d4
	jsr	(WT_Register).l
	moveq	#1+3+1, d0
	bsr.w	PM_Fill
	tst.w	d7
	beq.s	+
	moveq	#EQ_CMP_W, d0		; a blank row between
	bsr.w	PM_Fill
+
	dbf	d7, EQB_row
	moveq	#EQ_CMP_W, d0
	move.w	#$BE, d1
	bsr.w	PM_Fill
	movem.l	(sp)+, d0-d7/a0-a3
	rts

EQ_Labels:
	dc.l	EQ_Attack, EQ_Defense, EQ_Agility
EQ_Attack:	dc.b	$0B, $38, $38, $25, $27, $2F, $C4		; Attack
EQ_Defense:	dc.b	$0E, $29, $2A, $29, $32, $37, $29, $C4	; Defense
EQ_Agility:	dc.b	$0B, $2B, $2D, $30, $2D, $38, $3D, $C4	; Agility
EQ_Arrow:	dc.b	$4A, $C4				; the arrow (tools/diafont.py)
	even

; Every field frame (PM_FieldFrame).
EQ_Frame:
	movem.l	d0-d7/a0-a4, -(sp)
	bsr.w	PM_EquipMode
	beq.s	EQM_off
	cmpi.w	#3, (event_routine).w	; 1-2: the menu and the Who? list
	bcc.s	EQM_on
EQM_off:
	bsr.w	EQ_Restore		; (nothing to do when nothing is swapped)
	bra.w	EQM_done
EQM_on:
	; the list's border row, once the list is drawn
	tst.w	(EQ_PATCH).w
	beq.s	+
	tst.w	(window_index).w
	bne.s	+
	move.l	#EQ_ART_LIST&$FFFFFF, d0
	bsr.w	EQ_FindArt
	bmi.s	+
	bsr.w	EQ_Unpatch
+
	move.l	#EQ_CMP_ART&$FFFFFF, d0
	bsr.w	EQ_FindArt
	bpl.s	+
	move.w	#$FFFF, (EQ_SHOWN).w	; not up (yet)
	bra.w	EQM_done
+
	movea.l	a0, a4			; its stack entry
	cmpi.w	#5, (event_routine).w	; equipped: the bonuses are off (loc_ADBE) until
	beq.w	EQM_done		; the message closes (loc_AD00): the numbers stay
	; which item, and how
	move.w	(character_index).w, d3
	lea	(character_data_buffer).w, a1
	move.w	d3, d0
	lsl.w	#6, d0
	adda.w	d0, a1
	move.w	(current_active_objects_num).w, d0
	andi.w	#$F, d0
	subq.w	#1, d0
	lsl.w	#4, d0
	lea	($FFFFDF00+$E).w, a0
	move.w	(a0,d0.w), d0		; the top window
	moveq	#0, d2
	move.b	($FFFFDE50).w, d2	; its cursor
	moveq	#2, d1			; a one-handed weapon: the right hand
	cmpi.w	#WinID_RightLeft, d0
	bne.s	+
	cmpi.w	#1, d2			; the new cursor may still hold the item's list index
	bhi.s	EQM_none		; until Right/Left has initialized it
	moveq	#0, d0
	move.b	(item_index).w, d0
	add.w	d2, d1			; 0 right, 1 left
	bra.s	EQM_sim
+
	cmpi.w	#WinID_ItemList3, d0
	bne.s	+
	subq.w	#1, d2			; NEXT, then items 8-15
	bmi.s	EQM_none
	addq.w	#8, d2
	bra.s	EQM_item
+
	cmpi.w	#WinID_ItemList2, d0
	bne.s	EQM_none
	cmpi.b	#8, ($FFFFDE51).w	; a NEXT before the eight
	bne.s	EQM_item
	subq.w	#1, d2
	bmi.s	EQM_none
EQM_item:
	moveq	#0, d0
	move.b	$28(a1,d2.w), d0
	bpl.s	EQM_sim
	andi.w	#$7F, d0		; worn: the comparison without it
	moveq	#-1, d1
	bra.s	EQM_sim
EQM_none:
	moveq	#0, d0
EQM_sim:
	bsr.w	EQ_Simulate		; d4-d6: attack, defense, agility then
	bsr.s	EQ_ShowSix
EQM_done:
	movem.l	(sp)+, d0-d7/a0-a4
	rts

; a1 = the character's record, d4-d6 = attack, defense, agility then ($FFFF:
; none, three blank cells), a4 = the comparison's stack entry: the six numbers,
; when they change (EQ_SHOWN). The shop's comparison uses it too (shopequip).
EQ_ShowSix:
	movem.l	d0-d1/d7/a0/a3, -(sp)
	lea	(EQ_SHOWN).w, a0
	move.w	$1C(a1), d0
	cmp.w	(a0), d0
	bne.s	EQ6_draw
	cmp.w	2(a0), d4
	bne.s	EQ6_draw
	move.w	$1E(a1), d0
	cmp.w	4(a0), d0
	bne.s	EQ6_draw
	cmp.w	6(a0), d5
	bne.s	EQ6_draw
	move.w	$14(a1), d0
	cmp.w	8(a0), d0
	bne.s	EQ6_draw
	cmp.w	10(a0), d6
	beq.s	EQ6_done
EQ6_draw:
	move.w	$1C(a1), (a0)+
	move.w	d4, (a0)+
	move.w	$1E(a1), (a0)+
	move.w	d5, (a0)+
	move.w	$14(a1), (a0)+
	move.w	d6, (a0)+
	lea	(EQ_SHOWN).w, a3
	moveq	#0, d7			; the row (inner rows 0, 2, 4)
-
	move.w	(a3)+, d0		; now: inner columns 6-8
	moveq	#6, d1
	bsr.w	EQ_PutNumber
	move.w	(a3)+, d0		; then: 10-12
	moveq	#10, d1
	bsr.w	EQ_PutNumber
	addq.w	#2, d7
	cmpi.w	#6, d7
	bcs.s	-
EQ6_done:
	movem.l	(sp)+, d0-d1/d7/a0/a3
	rts

; d0 = an art address (24-bit): a0 = the stack entry holding it, N clear; N set
; if none.
EQ_FindArt:
	move.l	d1, -(sp)
	lea	($FFFFDF00).w, a0
	move.w	(current_active_objects_num).w, d1
	andi.w	#$F, d1
	bra.s	EQA_next
EQA_scan:
	cmp.l	6(a0), d0
	beq.s	EQA_found
	lea	$10(a0), a0
EQA_next:
	dbf	d1, EQA_scan
	move.l	(sp)+, d1
	ori.b	#8, ccr
	rts
EQA_found:
	move.l	(sp)+, d1
	andi.b	#$F7, ccr
	rts

; The character at a1 (d3) with item d0 (0: none) equipped - d1 = 2/3 the
; hand a one-handed weapon goes in, -1: d0 taken off: d4 attack, d5 defense,
; d6 agility as the game's own sums would make them (loc_ADBE takes the
; equipment's bonuses off, loc_AD4C puts them on). The character is left as
; it was.
EQ_Simulate:
	movem.l	d0-d3/d7/a0-a3, -(sp)
	move.w	$1C(a1), d4
	move.w	$1E(a1), d5
	move.w	$14(a1), d6
	tst.w	d0
	beq.w	EQS_done		; nothing highlighted: as now
	move.l	$1C(a1), -(sp)		; attack, defense
	move.w	$14(a1), -(sp)		; agility
	move.l	$20(a1), -(sp)		; head, hands, body
	move.w	$24(a1), -(sp)		; legs (and the next byte)
	movem.w	d0-d1, -(sp)
	jsr	(loc_ADBE).l		; the bonuses off
	movem.w	(sp)+, d0-d1
	lea	(character_data_buffer+$20).w, a2
	move.w	d3, d2
	lsl.w	#6, d2
	adda.w	d2, a2			; the five slots
	tst.w	d1
	bpl.s	EQS_on
	moveq	#5-1, d2		; off: every slot holding it
-
	move.b	(a2,d2.w), d7
	andi.b	#$7F, d7
	cmp.b	d0, d7
	bne.s	+
	clr.b	(a2,d2.w)
+
	dbf	d2, -
	bra.s	EQS_sum
EQS_on:
	bsr.w	EQ_ItemType		; d2 = the type: 1 head, 2 one hand, 3 both, 4 body, 5 legs
	cmpi.w	#3, d2
	bne.s	+
	move.b	d0, 1(a2)		; both hands
	move.b	d0, 2(a2)
	bra.s	EQS_sum
+
	cmpi.w	#2, d2
	bne.s	+
	move.w	d1, d2			; the hand: 2 right, 3 left
	subq.w	#1, d2
	move.w	d0, -(sp)
	moveq	#0, d0
	move.b	(a2,d2.w), d0		; a two-handed weapon there leaves both hands
	andi.w	#$7F, d0
	beq.s	EQS_hand
	move.w	d2, -(sp)
	bsr.s	EQ_ItemType
	cmpi.w	#3, d2
	movem.w	(sp)+, d2		; (flags kept)
	bne.s	EQS_hand
	clr.b	1(a2)
	clr.b	2(a2)
EQS_hand:
	move.w	(sp)+, d0
	move.b	d0, (a2,d2.w)
	bra.s	EQS_sum
+
	cmpi.w	#1, d2
	bcs.s	EQS_sum
	cmpi.w	#5, d2
	bhi.s	EQS_sum
	move.b	d0, -1(a2,d2.w)		; head, body, legs
EQS_sum:
	jsr	(loc_AD4C).l		; the bonuses on (d3)
	lea	(character_data_buffer).w, a1
	move.w	d3, d2
	lsl.w	#6, d2
	adda.w	d2, a1
	move.w	$1C(a1), d4
	move.w	$1E(a1), d5
	move.w	$14(a1), d6
	move.w	(sp)+, $24(a1)
	move.l	(sp)+, $20(a1)
	move.w	(sp)+, $14(a1)
	move.l	(sp)+, $1C(a1)
EQS_done:
	movem.l	(sp)+, d0-d3/d7/a0-a3
	rts

; d0 = an item: d2 = its equipment type (InventoryData+$C, low three bits).
EQ_ItemType:
	move.l	a0, -(sp)
	moveq	#0, d2
	move.w	d0, d2
	andi.w	#$7F, d2
	lsl.w	#4, d2
	lea	(InventoryData+$C).l, a0
	move.b	(a0,d2.w), d2
	andi.w	#7, d2
	movea.l	(sp)+, a0
	rts

; d0 = a number (0-999; $FFFF: none, three blanks), d7 = the comparison's
; inner row, d1 = its inner column, a4 = its stack entry: three digit cells,
; right-aligned, written with interrupts held off (the vertical blank also
; talks to the VDP).
EQ_PutNumber:
	movem.l	d0-d6/a0-a3, -(sp)
	suba.l	a1, a1			; a number
	cmpi.w	#$FFFF, d0
	bne.s	+
	movea.w	#1, a1			; none
	moveq	#0, d0
+
	cmpi.w	#999, d0
	bls.s	+
	move.w	#999, d0
+
	move.w	(a4), d2		; the window's corner (as ProcessWindows placed it)
	move.w	d7, d3
	addq.w	#1, d3			; past the top border
	lsl.w	#7, d3
	add.w	d3, d2
	andi.w	#$EFFF, d2		; rows wrap on the 32-row plane
	move.w	d1, d3			; past the left border
-
	bsr.s	EQ_NextCell
	dbf	d3, -
	lea	(vdp_control_port).l, a2
	lea	(vdp_data_port).l, a3
	lea	(EQ_Divisors).l, a0
	moveq	#0, d4			; a digit drawn
	moveq	#3-1, d5
EQP_digit:
	moveq	#0, d6
	move.w	d0, d6
	divu.w	(a0)+, d6
	move.w	d6, d1			; the digit
	swap	d6
	move.w	d6, d0			; the rest
	move.w	#$8526, d6		; blank
	cmpa.w	#0, a1
	bne.s	EQP_put			; no number: every cell
	tst.w	d1
	bne.s	+
	tst.w	d4
	bne.s	+
	tst.w	d5
	bne.s	EQP_put
+
	moveq	#1, d4
	move.w	#$8597, d6
	add.w	d1, d6
EQP_put:
	move	sr, -(sp)
	move	#$2700, sr
	move.w	d2, (a2)
	move.w	#3, (a2)
	move.w	d6, (a3)
	move	(sp)+, sr
	bsr.s	EQ_NextCell
	dbf	d5, EQP_digit
	movem.l	(sp)+, d0-d6/a0-a3
	rts

; d2 = a plane cell's address word: the next cell of the row (wrapping in it).
EQ_NextCell:
	move.l	d6, -(sp)
	move.b	d2, d6
	andi.b	#$80, d6
	addq.b	#2, d2
	andi.b	#$7F, d2
	or.b	d6, d2
	move.l	(sp)+, d6
	rts

EQ_Divisors:
	dc.w	100, 10, 1

; loc_96EC (the stock stats window's animation, in the vertical blank): off
; while the Equip screen is up - the comparison draws its own numbers.
EQ_StatAnim:
	tst.w	($FFFFDEA8).w
	beq.s	+
	bsr.w	PM_EquipMode
	bne.s	++
	addq.l	#4, sp
	jmp	(loc_96F4).l
+
	rts
+
	clr.w	($FFFFDEA8).w
	rts

; loc_ACC2: the E mark of the item a weapon replaced is cleared in what the
; second page saved of the first (its cells under the second page). The stock
; code took slot 6's save; it is the top window's when that is the second
; page, and nothing otherwise. d0 = the item's list index (< 8).
EQ_Page1Marks:
	mulu.w	#$3C, d0
	move.w	d1, -(sp)
	move.w	(current_active_objects_num).w, d1
	andi.w	#$F, d1
	subq.w	#1, d1
	lsl.w	#4, d1
	lea	($FFFFDF00).w, a0
	adda.w	d1, a0
	cmpi.w	#WinID_ItemList3, $E(a0)
	bne.s	+
	movea.l	2(a0), a0		; its save
	move.w	(sp)+, d1
	rts
+
	lea	(EQ_SCRATCH-$1F).w, a0	; + d0 + $1F: the scratch word
	suba.w	d0, a0
	move.w	(sp)+, d1
	rts

; The Equip screen's other windows (the list's record is built: EQ_Record).
EQ_Layouts:
	dc.w	WinID_EquipStats	; the comparison: columns 1-16, rows 1-7
	dc.w	$4000|(1<<7)|(1*2)
	dc.l	EQ_CMP_ART&$FFFFFF
	dc.b	EQ_CMP_W+1, 6
	dc.w	WinID_EqpEquipList	; the equipment: columns 1-17, rows 9-20
	dc.w	$4000|(9<<7)|(1*2)
	dc.l	EQ_ART_EQUIP&$FFFFFF
	dc.b	$10, $0B
	dc.w	0
	endif

; =============================================================================
; shop_equip_compare: the weapon and armor shops show who can equip the
; highlighted item, as Phantasy Star IV's shops do, and how it compares.
;
; While the item list has the cursor, a party window under the shopkeeper's
; portrait (columns 1-12, as wide as the portrait, ending on row 19 above the
; dialogue: a full party's reaches up over the portrait's lower rows) shows
; each member, two rows apart as in the stock lists, with a mark before the
; name: up, the item would raise the main stat
; (Attack in the weapon shop, Defense in the armor shop); right (the Equip
; screen's comparison arrow), it would leave it as it is; down, it would lower
; it; no mark, the member cannot equip it. "Can equip" is on its top border.
; The marks are three tiles of their own (SH_TILE: wintext's building pool
; starts past field_heal_popups' $23A-$25D, which only the field uses), written
; into the window's cells when the list's cursor moves.
;
; Once the item is chosen, the Who? list comes up over the Equip screen's
; comparison (ext/equipscreen.asm), in the same place as on the Equip screen:
; Attack, Defense and Agility now and with the item, for the member under the
; Who? cursor (no "then" numbers for one who cannot equip it).
;
; A one-handed item is compared in a hand that holds the same kind of thing
; (a weapon in the weapon shop, anything else in the armor shop) or nothing,
; the one holding the least of the main stat - the one the item improves most;
; if neither hand does, in either. A two-handed weapon takes both hands, as on
; the Equip screen (EQ_Simulate).
;
; Both windows are new IDs past the stock table: PM_Dispatch gives them their
; routine 0 (they leave window_index_saved 0, so the list queued after each
; takes the input), BattleBox_Record their records. The party window opens
; under the item list and stays while the shop is open; the comparison opens
; under the Who? list and closes with it (the two stock closings of the Who?
; list count one window more while it is up).
; =============================================================================
	if shop_equip_compare
	if party_menu_ps4==0
	error "shop_equip_compare needs party_menu_ps4 (the comparison, the window dispatch)"
	endif

SH_ID_PARTY	= $76			; past the stock windows ($74) and WinID_Options
SH_ID_CMP	= $77
SH_SHOWN	= $FFFF8FF6		; 4 bytes: the mark shown in each member's row ($FF: none yet)
SH_PARTY_ART	= PM_PORT_ART		; 124 bytes (Rolf's house's member list: never up in a shop)
SH_PARTY_W	= 10			; cells inside the borders: as wide as the portrait
SH_COL		= 1			; the left border column (the portrait's)
SH_BOTTOM	= 19			; the bottom border row (the dialogue's top is row 20)
SH_MARK_COL	= 2			; the mark's inner column; the name at 4-7
SH_WEAPONS	= (PtrBuilding_WeaponStore-BuildingIndex)/4
SH_ARMOR	= (PtrBuilding_ArmorStore-BuildingIndex)/4
SH_TILE		= $23A			; right, up, down
SH_TILE_VDP	= $40000000|(((SH_TILE*$20)&$3FFF)<<16)|((SH_TILE*$20)>>14)

; ---------------------------------------------------------------------------
; BuildingScreenLoop (the hook replaces its two calls): the marks and the
; comparison follow the cursors, in the two shops.
; ---------------------------------------------------------------------------
SH_Frame:
	jsr	(RunObjects).l
	jsr	(BuildSprites).l
	cmpi.w	#SH_WEAPONS, (building_index).w
	beq.s	+
	cmpi.w	#SH_ARMOR, (building_index).w
	bne.s	SHF_end
+
	movem.l	d0-d7/a0-a6, -(sp)
	bsr.w	SH_Marks
	bsr.w	SH_Compare
	movem.l	(sp)+, d0-d7/a0-a6
SHF_end:
	rts

; ---------------------------------------------------------------------------
; The store's event routines (each hook replaces one move to window_index).
; ---------------------------------------------------------------------------
; loc_BACE / loc_BC64: the item list, the party window under it - unless that
; is up already (the list reopened after No).
SH_OpenList:
	move.w	#WinID_StoreInventory, (window_index).w
	movem.l	d0-d2/a0, -(sp)
	move.w	#SH_ID_PARTY, d0
	bsr.w	SH_Find
	bpl.s	+
	move.l	#(SH_ID_PARTY<<16)|WinID_StoreInventory, (window_index).w
+
	movem.l	(sp)+, d0-d2/a0
	rts

; loc_BAE6 / loc_BC7C: the Who? list, the comparison under it.
SH_OpenWho:
	move.w	#WinID_StoreCharList, (window_index).w
	movem.l	d0-d2/a0, -(sp)
	move.w	#SH_ID_CMP, d0
	bsr.w	SH_Find
	bpl.s	+
	move.l	#(SH_ID_CMP<<16)|WinID_StoreCharList, (window_index).w
+
	movem.l	(sp)+, d0-d2/a0
	rts

; loc_BBD8 / loc_BD6E ($8001: the Who? list, after "anything else?" - Yes),
; and shop_no_reprompt's loc_BBA8 / loc_BD3E ($8002: the Who? and item lists):
; the comparison under the Who? list closes with it.
SH_Close1:
	move.w	#$8001, (window_index).w
	bra.s	SH_CloseCmp
SH_Close2:
	move.w	#$8002, (window_index).w
SH_CloseCmp:
	movem.l	d0-d2/a0, -(sp)
	move.w	#SH_ID_CMP, d0
	bsr.w	SH_Find
	bmi.s	+
	addq.w	#1, (window_index).w
+
	movem.l	(sp)+, d0-d2/a0
	rts

; ---------------------------------------------------------------------------
; The windows. BattleBox_Record: d0 = the window ID, a1 = the records' base.
; ---------------------------------------------------------------------------
SH_Record:
	cmpi.w	#SH_ID_CMP, d0
	bne.s	+
	lea	(SH_CmpLayout-SH_ID_CMP*8).l, a1
	rts
+
	cmpi.w	#SH_ID_PARTY, d0
	bne.s	+
	move.w	d1, -(sp)
	move.w	(party_members_num).w, d1	; as tall as the party
	andi.w	#3, d1
	lsl.w	#3, d1
	lea	(SH_PartyLayouts-SH_ID_PARTY*8).l, a1
	adda.w	d1, a1
	move.w	(sp)+, d1
+
	rts

; PM_Dispatch: d0 = SH_ID_PARTY or SH_ID_CMP, d1 = the window's routine (only
; routine 0 runs: both leave window_index_saved 0).
SH_Window:
	tst.w	d1
	bne.s	+
	cmpi.w	#SH_ID_CMP, d0
	beq.w	EQ_BuildCompare		; the Equip screen's art (it resets EQ_SHOWN)
	bra.s	SH_BuildParty
+
	rts

; The party window's art: two rows a member, a blank one and one with a blank
; cell for the mark (SH_Marks writes it) and the name (four marker bytes:
; wintext draws the six letters), and "Can equip" on the top border (letter
; tiles: wintext redraws the words; a registered run would outlive the window
; in WT_RUNS, over the art's other users). The mark tiles are loaded with it.
SH_BuildParty:
	move.w	#0, (window_index_saved).w
	movem.l	d0-d3/a0-a1, -(sp)
	move.l	#$FFFFFFFF, (SH_SHOWN).w
	bsr.w	SH_LoadMarks
	lea	(SH_PARTY_ART).w, a1
	moveq	#SH_PARTY_W*10, d0
	bsr.w	PM_ForgetRuns
	move.b	#$B9, (a1)+
	lea	(SH_Label).l, a0
	moveq	#SH_LabelEnd-SH_Label-1, d0
-
	move.b	(a0)+, (a1)+
	dbf	d0, -
	moveq	#SH_PARTY_W-1-(SH_LabelEnd-SH_Label), d0
	move.w	#$B9, d1
	bsr.w	PM_Fill
	lea	(party_member_id).w, a0
	move.w	(party_members_num).w, d3
	andi.w	#3, d3
-
	moveq	#SH_PARTY_W+SH_MARK_COL+2, d0	; a blank row; the margin, the mark, a gap
	moveq	#$26, d1
	bsr.w	PM_Fill
	move.w	(a0)+, d1
	andi.w	#7, d1
	addi.b	#$81, d1
	moveq	#4, d0
	bsr.w	PM_Fill
	moveq	#SH_PARTY_W-SH_MARK_COL-6, d0
	moveq	#$26, d1
	bsr.w	PM_Fill
	dbf	d3, -
	moveq	#SH_PARTY_W, d0
	move.w	#$BE, d1
	bsr.w	PM_Fill
	movem.l	(sp)+, d0-d3/a0-a1
	rts

SH_Label:	dc.b	$29, $41, $4E, $26, $45, $51, $55, $49, $50	; Can equip
SH_LabelEnd:
	even

SH_CmpLayout:				; the Equip screen's place: columns 1-16, rows 1-7
	dc.w	$4000|(1<<7)|(1*2)
	dc.l	EQ_CMP_ART&$FFFFFF
	dc.b	EQ_CMP_W+1, 6

SH_PartyLayout macro rows
	dc.w	$4000|((SH_BOTTOM+1-rows)<<7)|(SH_COL*2)
	dc.l	SH_PARTY_ART&$FFFFFF
	dc.b	SH_PARTY_W+1, rows-1
	endm
SH_PartyLayouts:			; one to four members: rows 16-19 to 10-19
	SH_PartyLayout 4
	SH_PartyLayout 6
	SH_PartyLayout 8
	SH_PartyLayout 10

; The three mark tiles at SH_TILE: the comparison's arrow (tools/diafont.py)
; moved to the cell's middle, then up and down; ink 1 on the windows' $B.
SH_LoadMarks:
	movem.l	d0-d4/a0-a3, -(sp)
	lea	(vdp_control_port).l, a2
	lea	(vdp_data_port).l, a3
	move	sr, -(sp)
	move	#$2700, sr
	move.w	#$8F02, (a2)
	move.l	#SH_TILE_VDP, (a2)
	lea	(VWF_Font+$4A*8).l, a0
	moveq	#2, d3
	bsr.s	SH_MarkTile
	lea	(SH_Glyphs).l, a0
	moveq	#0, d3
	bsr.s	SH_MarkTile
	bsr.s	SH_MarkTile
	move	(sp)+, sr
	movem.l	(sp)+, d0-d4/a0-a3
	rts

; a0 = eight 1bpp rows, d3 = the pixels to move them right: one tile.
SH_MarkTile:
	moveq	#8-1, d4
SHMT_row:
	moveq	#0, d0
	move.b	(a0)+, d0
	lsr.b	d3, d0
	moveq	#0, d1
	moveq	#8-1, d2
SHMT_pixel:
	lsl.l	#4, d1
	add.b	d0, d0
	bcc.s	+
	addq.b	#1, d1			; ink
	bra.s	++
+
	addi.b	#$B, d1			; paper
+
	dbf	d2, SHMT_pixel
	move.l	d1, (a3)
	dbf	d4, SHMT_row
	rts

SH_Glyphs:				; centred on the arrow's middle (row 3, column 3)
	dc.b	$00, $00, $10, $38, $7C, $00, $00, $00	; up
	dc.b	$00, $00, $7C, $38, $10, $00, $00, $00	; down

; ---------------------------------------------------------------------------
; Every frame in the two shops.
; ---------------------------------------------------------------------------
; The party window's marks, for the item under the list's cursor (while the
; list is down they stay as they are).
SH_Marks:
	move.w	#SH_ID_PARTY, d0
	bsr.w	SH_Find
	bmi.s	SHM_end
	movea.l	a0, a4			; its stack entry
	bsr.w	SH_ListItem
	beq.s	SHM_end
	lea	(party_member_id).w, a2
	lea	(SH_SHOWN).w, a3
	move.w	(party_members_num).w, d7
	andi.w	#3, d7
	moveq	#0, d6			; the member's row
SHM_member:
	move.w	(a2)+, d3
	andi.w	#7, d3
	bsr.s	SH_Mark
	cmp.b	(a3,d6.w), d2
	beq.s	+
	move.b	d2, (a3,d6.w)
	bsr.w	SH_PutMark
+
	addq.w	#1, d6
	dbf	d7, SHM_member
SHM_end:
	rts

; d0 = an item, d3 = a character: d2 = the mark, 0 none (cannot equip it),
; 1 right (the main stat as it is), 2 up, 3 down.
SH_Mark:
	movem.l	d0-d1/d3-d6/a1, -(sp)
	moveq	#0, d2
	bsr.w	SH_CanEquip
	beq.s	SHK_end
	bsr.w	SH_Record3
	bsr.w	SH_Evaluate		; d4 attack, d5 defense then
	move.w	$1C(a1), d1		; attack now
	cmpi.w	#SH_ARMOR, (building_index).w
	bne.s	+
	move.w	$1E(a1), d1		; defense
	move.w	d5, d4
+
	cmp.w	d1, d4
	beq.s	SHK_same
	bhi.s	SHK_up
	moveq	#3, d2
	bra.s	SHK_end
SHK_up:
	moveq	#2, d2
	bra.s	SHK_end
SHK_same:
	moveq	#1, d2
SHK_end:
	movem.l	(sp)+, d0-d1/d3-d6/a1
	rts

; d6 = a member's row, d2 = its mark, a4 = the party window's stack entry:
; the mark's cell, with interrupts held off (the vertical blank also talks to
; the VDP).
SH_PutMark:
	movem.l	d0-d3/a2-a3, -(sp)
	move.w	d2, d3
	move.w	(a4), d2		; the window's corner
	move.w	d6, d1
	add.w	d1, d1
	addq.w	#2, d1			; past the top border and the member's blank row
	lsl.w	#7, d1
	add.w	d1, d2
	andi.w	#$EFFF, d2		; rows wrap on the 32-row plane
	moveq	#SH_MARK_COL, d1	; past the left border
-
	bsr.w	EQ_NextCell
	dbf	d1, -
	move.w	#$8526, d0		; none: the blank
	tst.w	d3
	beq.s	+
	move.w	#$8000|(SH_TILE-1), d0
	add.w	d3, d0
+
	lea	(vdp_control_port).l, a2
	lea	(vdp_data_port).l, a3
	move	sr, -(sp)
	move	#$2700, sr
	move.w	d2, (a2)
	move.w	#3, (a2)
	move.w	d0, (a3)
	move	(sp)+, sr
	movem.l	(sp)+, d0-d3/a2-a3
	rts

; The comparison, for the member under the Who? cursor (the first until the
; list is up) and the item chosen.
SH_Compare:
	move.w	#SH_ID_CMP, d0
	bsr.w	SH_Find
	bmi.s	SHC_end
	movea.l	a0, a4			; its stack entry
	bsr.w	SH_ListItem
	beq.s	SHC_end
	move.w	d0, d7
	move.w	#WinID_StoreCharList, d0
	bsr.w	SH_Find
	bpl.s	+
	moveq	#0, d1
	bra.s	++
+
	bsr.w	SH_Cursor
	cmp.w	(party_members_num).w, d1
	bls.s	+
	moveq	#0, d1
+
	lea	(party_member_id).w, a0
	add.w	d1, d1
	move.w	(a0,d1.w), d3
	andi.w	#7, d3
	move.w	d7, d0
	bsr.w	SH_Record3
	moveq	#-1, d4			; cannot equip it: no numbers then
	moveq	#-1, d5
	moveq	#-1, d6
	bsr.w	SH_CanEquip
	beq.s	+
	bsr.w	SH_Evaluate
+
	bsr.w	EQ_ShowSix
SHC_end:
	rts

; ---------------------------------------------------------------------------
; d0 = a window ID: a0 = the topmost stack entry with it, d1 = its slot, N
; clear; N set if none is up. d2 is used.
SH_Find:
	move.w	(current_active_objects_num).w, d1
	andi.w	#$F, d1
-
	subq.w	#1, d1
	bmi.s	+			; none (N set)
	move.w	d1, d2
	lsl.w	#4, d2
	lea	($FFFFDF00).w, a0
	adda.w	d2, a0
	cmp.w	$E(a0), d0
	bne.s	-
	tst.w	d1			; N clear
+
	rts

; d1 = a window's slot: d1 = the entry its cursor is on (0 before the cursor
; is placed).
SH_Cursor:
	move.l	a0, -(sp)
	lea	(object_ram).w, a0
	lsl.w	#6, d1
	adda.w	d1, a0
	moveq	#0, d1
	cmpi.w	#ObjID_RedRectangleCursor, (a0)
	bne.s	+
	move.b	$32(a0), d1
+
	movea.l	(sp)+, a0
	rts

; d0 = the item under the item list's cursor; 0 (and Z set) when the list is
; not up.
SH_ListItem:
	movem.l	d1-d2/a0, -(sp)
	move.w	#WinID_StoreInventory, d0
	bsr.s	SH_Find
	bmi.s	SHL_none
	bsr.s	SH_Cursor
	cmpi.w	#5, d1			; six entries
	bhi.s	SHL_none
	lea	(StoreEquipItemArray).l, a0
	move.w	($FFFFF766).w, d0	; the store's list (Win_StoreInventory)
	mulu.w	#6, d0
	adda.w	d0, a0
	moveq	#0, d0
	move.b	(a0,d1.w), d0
	andi.w	#$7F, d0
	bra.s	SHL_end
SHL_none:
	moveq	#0, d0
SHL_end:
	movem.l	(sp)+, d1-d2/a0
	tst.w	d0
	rts

; d3 = a character: a1 = its record.
SH_Record3:
	move.w	d3, -(sp)
	lea	(character_data_buffer).w, a1
	lsl.w	#6, d3
	adda.w	d3, a1
	move.w	(sp)+, d3
	rts

; d0 = an item, d3 = a character: Z clear if the item is equipment (a body
; part, InventoryData+$C) the character can wear (+$D, a bit each).
SH_CanEquip:
	movem.l	d0/a0, -(sp)
	lsl.w	#4, d0
	lea	(InventoryData).l, a0
	adda.w	d0, a0
	move.b	$C(a0), d0
	andi.b	#7, d0
	beq.s	+
	cmpi.b	#5, d0
	bhi.s	+
	btst	d3, $D(a0)
	bra.s	++
+
	ori.b	#4, ccr			; Z set: not equipment
+
	movem.l	(sp)+, d0/a0
	rts

; d0 = an item the character d3 (record a1) can equip: d4-d6 = attack,
; defense and agility with it on, a one-handed item in the hand compared.
SH_Evaluate:
	movem.l	d1-d2, -(sp)
	moveq	#2, d1			; (for what is not one-handed)
	bsr.w	EQ_ItemType		; d2
	cmpi.w	#2, d2
	bne.s	+
	bsr.s	SH_Hand
+
	bsr.w	EQ_Simulate
	movem.l	(sp)+, d1-d2
	rts

; d0 = a one-handed item, a1 = the character's record: d1 = the hand to
; compare it in, 2 right or 3 left. First the hands that hold nothing or the
; shop's kind of thing (an item with an attack value is a weapon), then any;
; of those, the one holding the least of the shop's stat (InventoryData+$E
; attack, +$F defense) - the weapon shop tries the right hand first, the
; armor shop the left.
SH_Hand:
	movem.l	d0/d2-d7/a0, -(sp)
	lea	(InventoryData+$E).l, a0
	moveq	#0, d5			; the stat: attack
	moveq	#2, d6			; the hand tried first
	cmpi.w	#SH_ARMOR, (building_index).w
	bne.s	+
	moveq	#1, d5			; defense
	moveq	#3, d6
+
	moveq	#1, d7			; first only the hands that qualify
SHH_pass:
	moveq	#-1, d1			; the hand found
	moveq	#-1, d4			; what it holds of the stat ($FFFF: none found)
	move.w	d6, d2
	bsr.s	SHH_try
	eori.w	#1, d2			; the other hand
	bsr.s	SHH_try
	tst.w	d1
	bpl.s	SHH_end
	subq.w	#1, d7
	bpl.s	SHH_pass		; then any
	moveq	#2, d1			; (not reached)
SHH_end:
	movem.l	(sp)+, d0/d2-d7/a0
	rts

; d2 = a hand: the hand found if it qualifies (d7 = 0: any does) and holds
; less of the stat than the one found so far (d4).
SHH_try:
	moveq	#0, d3			; nothing held: none of it
	moveq	#0, d0
	move.b	$1F(a1,d2.w), d0	; the hand's slot ($21 right, $22 left)
	andi.w	#$7F, d0
	beq.s	SHT_compare
	lsl.w	#4, d0
	tst.w	d7
	beq.s	SHT_stat
	tst.b	(a0,d0.w)		; its attack: a weapon
	bne.s	SHT_weapon
	tst.w	d5
	beq.s	SHT_skip		; something else, in the weapon shop
	bra.s	SHT_stat
SHT_weapon:
	tst.w	d5
	bne.s	SHT_skip		; a weapon, in the armor shop
SHT_stat:
	add.w	d5, d0
	move.b	(a0,d0.w), d3
SHT_compare:
	cmp.w	d4, d3
	bcc.s	SHT_skip		; not less (the first tried wins a tie)
	move.w	d3, d4
	move.w	d2, d1
SHT_skip:
	rts

	endif

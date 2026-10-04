; =============================================================================
; wide_techs: technique names in six cells (48 px) instead of five, so the full
; names fit (Saschnella, Nasaresta); battle_tech_tp: the battle list shows each
; technique's TP cost beside its name, as Phantasy Star IV does.
;
; Four windows draw technique names, all through one loop (loc_FF2E, and its copy
; loc_10342) that copies five cells: the field TECH list and its second page
; (LevelTechList / 2), the battle list (BattleTechList), the plate a technique shows
; while it is cast (BattleTechUsed) and STRNG's two lists (FullTechList / 2). Their
; art lives in the dynamic window RAM at fixed sizes, so a wider art cannot stay
; where it was. The field list's art is followed in that RAM by an identical copy
; nothing refers to (loc_1598C): 252 bytes together, TW_ART. Each of the four
; builders now copies its art, one cell wider (STRNG's two columns: two), from a
; template here into TW_ART, forgets the runs (ext/wintext.asm) that other layouts
; left in that RAM, and fills it as the stock code does. The four windows are never
; up at once (the battle list and the plate have places of their own anyway).
;
; The battle list with battle_tech_tp: 2 cells of cursor, 6 of name, a blank, 2
; digits of TP in the stock digit tiles (loc_11364, as the HP/TP windows); an empty
; row shows none.
; =============================================================================
	if wide_techs
	if long_item_names==0
	error "wide_techs needs long_item_names"
	endif

; The widened battle Tech list reaches the old options cursor at X $118. Hide
; that sprite once Orders advances to character selection, commands or a list.
; The original six-byte window test is replaced by a six-byte jump; for the
; options windows, continue through the original cursor logic unchanged.
TW_BattleOptionsCursor:
	cmpi.w	#4, (event_routine).w
	bcc.s	TW_BattleOptionsCursor_Hide
	tst.w	(window_index).w
	beq.s	+
	jmp	(loc_1862).l
+
	jmp	(ObjRRCB_WindowReady).l
TW_BattleOptionsCursor_Hide:
	move.b	#$32, 2(a0)
	rts

	if (loc_1598C-WinArt_LevelTechList)<>7*18
	error "wide_techs: the field list's art is not followed by its unused copy"
	endif

TW_ART		equ window_art_buffer+WinArt_LevelTechList-DynamicWindowsStart
TW_ART_SIZE	equ WinArt_StrngHPTP-WinArt_LevelTechList	; with the copy at loc_1598C
TW_EXTRA	equ $FFFF8EA0		; word: cells after a name before the next row (the TP), 0 or 3

TW_FIELD_W	equ 8			; cursor 2 + name 6
	if battle_tech_tp
TW_BATTLE_W	equ 11			; cursor 2 + name 6 + blank + TP 2
	else
TW_BATTLE_W	equ 8
	endif
TW_USED		equ TW_ART+112		; the plate: 6 x 4, past the battle list
TW_USED_W	equ 6
TW_FULL_W	equ 13			; name 6 + blank + name 6

	if (TW_FULL_W+7<>20)||(TW_USED-TW_ART+TW_USED_W<>118)
	error "wide_techs: the offsets written out in ps2.asm (loc_1031A, Win_BattleTechUsed) changed"
	endif
	if (TW_FIELD_W*18>TW_ART_SIZE)||(TW_FULL_W*18>TW_ART_SIZE)||(TW_BATTLE_W*10>112)||(112+TW_USED_W*4>TW_ART_SIZE)
	error "wide_techs: an art does not fit TW_ART"
	endif

; ---------------------------------------------------------------------------
; loc_FF2E, loc_10342: a technique's name - a3 = its record, a1 = the art, d3 =
; the row (0 above the letters, 1 the letters) - in six cells, then, in the battle
; list, the TP. As WT_LoopA3, which the stock hook calls: a1 past the row's cells,
; d2 = -1.
; ---------------------------------------------------------------------------
TW_Loop:
	moveq	#5, d2			; six cells
	if battle_tech_tp
	tst.w	(TW_EXTRA).w
	bne.s	TW_LoopCost
	endif
	bra.w	WT_LoopA3
	if battle_tech_tp
TW_LoopCost:
	movem.l	d0-d4/a2, -(sp)
	moveq	#0, d0
	cmpa.l	#TechniqueData, a3
	beq.s	+			; an empty row: no cost
	move.b	5(a3), d0		; the TP it costs
+
	move.w	d0, -(sp)
	bsr.w	WT_LoopA3
	move.w	(sp)+, d0
	addq.w	#1, a1			; the blank cell
	tst.w	d3
	beq.s	+			; the row above the letters
	tst.w	d0
	beq.s	+
	jsr	(loc_11364).l		; two digits, right-aligned
	bra.s	++
+
	addq.w	#2, a1
+
	movem.l	(sp)+, d0-d4/a2
	moveq	#-1, d2
	rts
	endif

; ---------------------------------------------------------------------------
; The builders. Each replaces the stock art set-up: a3 = the header's six cells
; (the border, or NEXT's cursor box) where there is a header; returns a1 = the
; first cell the stock code fills.
; ---------------------------------------------------------------------------
TW_FieldArt:				; loc_FEF2: LevelTechList / 2
	movem.l	d0/a0, -(sp)
	clr.w	(TW_EXTRA).w
	lea	(TW_TplField).l, a0
	move.w	#TW_FIELD_W*18-1, d0
	bsr.w	TW_CopyArt
	bsr.w	TW_Header
	lea	(TW_ART+TW_FIELD_W).w, a1
	movem.l	(sp)+, d0/a0
	rts

TW_BattleArt:				; loc_10CBE: BattleTechList
	movem.l	d0/a0, -(sp)
	move.w	#TW_BATTLE_W-8, (TW_EXTRA).w
	lea	(TW_TplBattle).l, a0
	move.w	#TW_BATTLE_W*10-1, d0
	bsr.w	TW_CopyArt
	bsr.w	TW_Header
	lea	(TW_ART+TW_BATTLE_W).w, a1
	movem.l	(sp)+, d0/a0
	rts

TW_UsedArt:				; Win_BattleTechUsed, in place of its first instruction
	move.w	#0, (window_index_saved).w
	movem.l	d0/a0-a1, -(sp)
	clr.w	(TW_EXTRA).w
	bsr.w	TW_Forget
	lea	(TW_TplUsed).l, a0
	lea	(TW_USED).w, a1
	moveq	#TW_USED_W*4-1, d0
-
	move.b	(a0)+, (a1)+
	dbf	d0, -
	movem.l	(sp)+, d0/a0-a1
	rts

TW_FullArt:				; loc_102F0: FullTechList / 2 (d0 is set after)
	move.l	a0, -(sp)
	clr.w	(TW_EXTRA).w
	lea	(TW_TplFull).l, a0
	move.w	#TW_FULL_W*18-1, d0
	bsr.w	TW_CopyArt
	lea	(TW_ART+TW_FULL_W).w, a1
	movea.l	(sp)+, a0
	rts

; a0 = a template, d0 = its bytes - 1: copied to TW_ART, the runs left in TW_ART
; forgotten; a1 = TW_ART.
TW_CopyArt:
	bsr.w	TW_Forget
	lea	(TW_ART).w, a1
-
	move.b	(a0)+, (a1)+
	dbf	d0, -
	lea	(TW_ART).w, a1
	rts

; The header's six cells from a3 to a1.
TW_Header:
	moveq	#5, d0
-
	move.b	(a3)+, (a1)+
	dbf	d0, -
	rts

; Forget the runs registered in TW_ART: a run of another layout would be drawn
; into this one's cells.
TW_Forget:
	movem.l	d0-d1/a0, -(sp)
	lea	(WT_RUNS).w, a0
	moveq	#WT_RUNS_N-1, d0
-
	move.w	(a0), d1
	cmpi.w	#TW_ART&$FFFF, d1
	bcs.s	+
	cmpi.w	#(TW_ART+TW_ART_SIZE)&$FFFF, d1
	bcc.s	+
	clr.w	(a0)
+
	addq.w	#8, a0
	dbf	d0, -
	movem.l	(sp)+, d0-d1/a0
	rts

; The two STRNG lists share TW_ART, so choose their footer by window ID
; after the art has been drawn. The run replaces four bottom-border cells at
; most; WT_DrawRun allocates tiles only for cells that hold letters.
TW_FullLabel:
	cmpi.l	#(TW_ART&$FFFFFF), 6(a6)
	bne.s	TW_FullLabel_Done
	cmpi.w	#TW_FULL_W+1, $A(a6)
	bne.s	TW_FullLabel_Done
	move.w	$E(a6), d0
	cmpi.w	#WinID_FullTechList, d0	; left list: field techniques
	beq.s	TW_FullLabel_Field
	cmpi.w	#WinID_FullTechList2, d0	; right list: battle techniques
	bne.s	TW_FullLabel_Done
	lea	(TW_CombatText).l, a0
	moveq	#4, d4
	bra.s	TW_FullLabel_Draw
TW_FullLabel_Field:
	lea	(TW_FieldText).l, a0
	moveq	#3, d4
TW_FullLabel_Draw:
	move.w	#TW_FULL_W*17+5, d0	; centered on the bottom border
	moveq	#WT_RUN_KIND_LABEL, d1
	bsr.w	WT_DrawRun
TW_FullLabel_Done:
	rts

TW_FieldText:
	dc.b	$10, $13, $0F, $16, $0E, $C4	; FIELD
TW_CombatText:
	dc.b	$0D, $19, $17, $0C, $0B, $1E, $C4	; COMBAT
	even

; ---------------------------------------------------------------------------
; The templates: the stock arts, wider.
; ---------------------------------------------------------------------------
TW_TplField:				; 8 x 18: the header, eight entries
	border	TW_FIELD_W, $B9
	rept	8
	border	TW_FIELD_W, $26
	dc.b	$B4, $B5
	border	TW_FIELD_W-2, $26
	endm
	border	TW_FIELD_W, $BE

TW_TplBattle:				; 8 (11) x 10: the header, four entries
	border	TW_BATTLE_W, $B9
	rept	4
	border	TW_BATTLE_W, $26
	dc.b	$B4, $B5
	border	TW_BATTLE_W-2, $26
	endm
	border	TW_BATTLE_W, $BE

TW_TplUsed:				; 6 x 4
	border	TW_USED_W, $B9
	border	TW_USED_W*2, $26
	border	TW_USED_W, $BE

TW_TplFull:				; 13 x 18: two columns of eight
	border	TW_FULL_W, $B9
	border	TW_FULL_W*16, $26
	border	TW_FULL_W, $BE
	even

	endif

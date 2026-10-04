; =============================================================================
; Amber recovery numbers for healing from the field menu: items (Monomate,
; Dimate, Trimate, Star Mist, Moon Dew) and techniques (RES family, SAR family,
; SAK, NASAK, REVER). Each shows the HP actually restored, none for a member who
; gained nothing, beside that member's HP: in the party panel with
; party_menu_ps4, else in the stock MenuCharStats window. The field's palette
; 0, colour 3 is the normal menu amber ($0AAE on every playable audited map).
; Four slots (the battle's party slots, unused on the field) and a field-only
; VRAM reservation: a group recovery shows every living party member at once.
; work/scripts/fieldheal.py checks every path.
; =============================================================================
	if field_heal_popups
	if damage_popups==0
	error "field_heal_popups needs damage_popups"
	endif

FH_SLOTS	= POP_SLOTS+$28	; four slots after the battle's five enemy slots
FH_TILES	= $23A			; 4 slots x 4 digit tiles
FH_BOX_TILES	= FH_TILES+$10	; 20 shared frame tiles
FH_BOX_LOADED	= $FFFF8E46

; Sprite coordinates carry the +128 bias; a slot's Y is its digits' row, the
; 32x16 frame drawn 4px above it, so a slot at an 8px text row's Y frames it.
	if party_menu_ps4
; The party panel (ext/partymenu.asm): member k's HP row is 2+4k rows below the
; panel's top border. The frame stands just left of it, against the panel's
; left border, over whatever lies there: nothing in the panel is hidden.
FH_HPX0	= 128+PM_PANEL_COL*8-32
FH_HPX1	= FH_HPX0
FH_HPX2	= FH_HPX0
FH_HPX3	= FH_HPX0
FH_HPY0	= 128+(PM_PANEL_ROW+2)*8
FH_HPY1	= FH_HPY0+32
FH_HPY2	= FH_HPY0+64
FH_HPY3	= FH_HPY0+96
	else
; MenuCharStats has four 56px columns (measured in a savestate render): column
; k's "HP" label at screen x 56+56k, its number's three cells at 80+56k-103+56k,
; blank cells at 72+56k and 104+56k; names on row y 176, HP 192, TP 200. Each
; frame covers x 48+56k-79+56k, y 184-199: the blank cell after the previous
; number, the label and the blank cell before this number, between the name
; and TP rows. So the amber number stands just left of the HP and hides no
; digit.
FH_HPX0	= 128+48
FH_HPX1	= 128+48+56
FH_HPX2	= 128+48+56*2
FH_HPX3	= 128+48+56*3
FH_HPY0	= 128+188
FH_HPY1	= FH_HPY0
FH_HPY2	= FH_HPY0
FH_HPY3	= FH_HPY0
	endif

; Store d1 (the already-capped new HP) at -2(a2), where a2 initially points
; at max HP. The original instruction leaves a2 at current HP; retain that
; observable result while recording only the actual, nonzero recovery.
FH_Store:
	movem.l	d0-d3/a0-a1, -(sp)
	move.w	-2(a2), d3
	move.w	d1, -(a2)
	move.w	d1, d0
	sub.w	d3, d0
	bsr.w	FH_QueueAtCurrentHP
	movem.l	(sp)+, d0-d3/a0-a1
	rts

; The direct paths replace store + stats window + event increment as one
; ten-byte hook. It deliberately leaves a2 as the original store did.
FH_StoreAndStats:
	bsr.w	FH_Store
	; fall through
FH_ShowStats:
	move.w	#((6<<8)|WinID_MenuCharStats), (window_index).w
	addq.w	#1, (event_routine_sub).w
	rts

; d0 = actual HP restored, a2 = character_data_buffer + character*64 + 2.
FH_QueueAtCurrentHP:
	tst.w	d0
	beq.w	FH_QueueDone
	move.w	a2, d1
	subi.w	#$C002, d1		; low word of character_data_buffer + 2
	lsr.w	#6, d1			; character ID
	lea	(party_member_id).w, a0
	moveq	#0, d2
FH_FindParty:
	cmp.w	(a0)+, d1
	beq.s	FH_FoundParty
	addq.w	#1, d2
	cmp.w	(party_members_num).w, d2
	bls.s	FH_FindParty
	bra.s	FH_QueueDone		; not an active party member
FH_FoundParty:
	lea	(FH_SLOTS).l, a0
	lsl.w	#3, d2
	adda.w	d2, a0
	ori.w	#$8000, d0		; amber kind, as battle healing uses
	move.w	d0, 2(a0)
	move.w	#$8000|POP_LIFE, (a0)
	move.w	d2, d0
	lsr.w	#1, d0			; slot*8 -> slot*4, the (X, Y) pair
	lea	(FH_Positions).l, a1
	move.w	(a1,d0.w), 4(a0)
	move.w	2(a1,d0.w), 6(a0)
FH_QueueDone:
	rts

; The group paths (Star Mist, SAR/GISAR/NASAR, NASAK) replace their whole loop,
; from the loop label through the stats-window update, with one JSR to a copy
; of the loop that stores through FH_Store; the rest of the span is NOPs, so
; loc_A130/loc_A144 and the others stay at their stock addresses.
FH_StarMistLoop:
FH_StarMistLoopMember:
	lea	(character_data_buffer).w, a2
	move.w	(a1)+, d1
	lsl.w	#6, d1
	adda.w	d1, a2
	tst.w	(a2)+
	bmi.s	FH_StarMistLoopNext
	tst.w	(a2)+
	beq.s	FH_StarMistLoopNext
	move.w	(a2), d1
	bsr.w	FH_Store
FH_StarMistLoopNext:
	dbf	d0, FH_StarMistLoopMember
	bsr.w	FH_ShowStats
	rts

FH_SarLoop:
FH_SarLoopMember:
	lea	(character_data_buffer).w, a2
	move.w	(a1)+, d1
	lsl.w	#6, d1
	adda.w	d1, a2
	tst.w	(a2)+
	bmi.s	FH_SarLoopNext
	move.w	(a2)+, d1
	beq.s	FH_SarLoopNext
	move.b	(technique_index).w, d0
	cmpi.b	#TechID_Sar, d0
	bne.s	FH_SarNotSar
	addi.w	#$14, d1
	bra.s	FH_SarCap
FH_SarNotSar:
	cmpi.b	#TechID_Gisar, d0
	bne.s	FH_SarFull
	addi.w	#$3C, d1
	bra.s	FH_SarCap
FH_SarFull:
	move.w	(a2), d1
FH_SarCap:
	cmp.w	(a2), d1
	bcs.s	FH_SarStore
	move.w	(a2), d1
FH_SarStore:
	bsr.w	FH_Store
FH_SarLoopNext:
	dbf	d2, FH_SarLoopMember
	if improvement_fixes
	jsr	(Fix_FieldHealSound).l
	else
	bsr.w	FH_ShowStats
	endif
	rts

FH_NasakLoop:
FH_NasakLoopMember:
	lea	(character_data_buffer).w, a2
	move.w	(a1)+, d1
	lsl.w	#6, d1
	adda.w	d1, a2
	tst.w	(a2)+
	bmi.s	FH_NasakLoopNext
	tst.w	(a2)+
	beq.s	FH_NasakLoopNext
	move.w	(a2), d1
	bsr.w	FH_Store
FH_NasakLoopNext:
	dbf	d0, FH_NasakLoopMember
	if improvement_fixes
	jsr	(Fix_FieldHealSound).l
	else
	bsr.w	FH_ShowStats
	endif
	rts

; Moon Dew begins with a pointer to max HP instead of an already-computed
; result.  Rebuild its stock address calculation, then make it a full restore.
; d1 still contains the stock character offset on return.
FH_MoonDewStore:
	lea	(character_data_buffer+4).w, a2
	move.w	(character_index_2).w, d1
	lsl.w	#6, d1
	adda.w	d1, a2
	move.w	d1, d2
	move.w	(a2), d1
	bsr.w	FH_Store
	move.w	d2, d1
	rts

; SAK's target test and its status update form one contiguous fixed-size hook.
; It must retain the post-increment behaviour of both tests because the store
; deliberately leaves a2 at the current-HP word.
FH_SakFinish:
	tst.w	(a2)+
	bmi.s	FH_SakStats
	tst.w	(a2)+
	beq.s	FH_SakStats
	move.w	(a2), d1
	bsr.w	FH_Store
FH_SakStats:
	if improvement_fixes
	jsr	(Fix_FieldHealSound).l
	else
	bsr.w	FH_ShowStats
	endif
	rts

; Level loading replaces all field VRAM, so discard both the cached frame and
; the pending records before its first BuildSprites.  Battle init clears its
; complete record block independently.
FH_InitAndBuild:
	clr.w	(FH_BOX_LOADED).l
	if party_menu_ps4
	clr.w	(PM_PAL_SAVED).l	; the new map's palette is loaded: nothing to put back
	clr.w	(PM_OVER).l
	clr.w	(PM_PLANEB).l		; the map is drawn anew
	endif
	lea	(FH_SLOTS).l, a0
	moveq	#4*2-1, d0
FH_InitClear:
	clr.l	(a0)+
	dbf	d0, FH_InitClear
	jsr	(BuildSprites).l
	moveq	#0, d0			; the replaced caller's next instruction
	rts

; The main level loop has two adjacent short calls. Replacing their combined
; eight bytes with this wrapper keeps every stock offset fixed while allowing a
; far helper call.
FH_RunObjectsAndBuild:
	jsr	(RunObjects).l
	if party_menu_ps4
	jsr	(PM_FieldFrame).l	; the portrait's palette, covered cursors
	endif
	bsr.w	FH_BuildSprites
	rts

; Replaces the field's regular BuildSprites. It first builds the normal SAT,
; then appends only field slots and
; moves them in front of the map sprites, leaving the stock SAT intact.
FH_BuildSprites:
	jsr	(BuildSprites).l
	if party_menu_ps4
	jsr	(PM_HideNPCs).l		; while the portrait's palette is up
	endif
	movem.l	d0-d7/a0-a6, -(sp)
	tst.w	(FH_BOX_LOADED).l
	bne.s	+
	bsr.w	FH_LoadBoxArt
	move.w	#1, (FH_BOX_LOADED).l
+
	moveq	#0, d0
	move.b	(sprite_link_field_count).w, d0
	movea.w	d0, a6
	lea	(FH_SLOTS).l, a5
	moveq	#0, d7
FH_BuildLoop:
	move.w	(a5), d0
	beq.w	FH_BuildNext
	tst.b	(sprite_count).w
	beq.w	FH_BuildNext
	tst.w	d0
	bpl.s	FH_BuildReady
	bsr.w	FH_Render
	andi.w	#$7FFF, (a5)
FH_BuildReady:
	move.w	6(a5), d1
	move.w	(a5), d6
	moveq	#4, d3
	cmpi.w	#6, d6
	bhi.s	FH_Opening
	move.w	d6, d3
	addq.w	#1, d3
	lsr.w	#1, d3
	bra.s	FH_WidthReady
FH_Opening:
	moveq	#POP_LIFE, d0
	sub.w	d6, d0
	cmpi.w	#6, d0
	bcc.s	FH_WidthReady
	lsr.w	#1, d0
	addq.w	#1, d0
	move.w	d0, d3
FH_WidthReady:
	cmpi.w	#4, d3
	bne.s	FH_BoxSprite
	cmpi.w	#6, d6
	bls.s	FH_BoxSprite
	move.w	d1, d0
	move.w	d7, d4
	lsl.w	#2, d4
	addi.w	#$8000|FH_TILES, d4
	move.w	4(a5), d5
	move.w	2(a5), d2
	andi.w	#$7FFF, d2
	cmpi.w	#1000, d2
	bcc.s	FH_XReady
	subq.w	#4, d5
	cmpi.w	#100, d2
	bcc.s	FH_XReady
	subq.w	#4, d5
	cmpi.w	#10, d2
	bcc.s	FH_XReady
	subq.w	#4, d5
FH_XReady:
	moveq	#$C, d2
	bsr.w	Popup_AppendSprite
FH_BoxSprite:
	tst.b	(sprite_count).w
	beq.s	FH_AgeSprite
	move.w	d3, d2
	subq.w	#1, d2
	add.w	d2, d2
	lea	(FH_BoxTileTable).l, a0
	move.w	(a0,d2.w), d4
	ori.w	#$8000, d4
	lea	(Popup_BoxSizeTable).l, a0
	move.w	(a0,d2.w), d2
	move.w	d1, d0
	subq.w	#4, d0
	move.w	4(a5), d5
	moveq	#4, d6
	sub.w	d3, d6
	lsl.w	#2, d6
	add.w	d6, d5
	bsr.w	Popup_AppendSprite
FH_AgeSprite:
	subq.w	#1, (a5)
FH_BuildNext:
	addq.w	#8, a5
	addq.w	#1, d7
	cmpi.w	#4, d7
	bcs.w	FH_BuildLoop
	bsr.w	Popup_MoveToFront
	movem.l	(sp)+, d0-d7/a0-a6
	rts

; The field box art is byte-for-byte the battle frame, at FH_BOX_TILES.
FH_BoxTileTable:
	dc.w	FH_BOX_TILES, FH_BOX_TILES+2, FH_BOX_TILES+6, FH_BOX_TILES+$C

FH_LoadBoxArt:
	move.w	#$8F02, (vdp_control_port).l
	move.l	#$49400001, (vdp_control_port).l	; VRAM tile $24A
	moveq	#1, d1
FH_BoxWidth:
	moveq	#0, d2
FH_BoxColumn:
	move.l	#$BBBBBBBB, d3
	tst.w	d2
	bne.s	+
	move.l	#$1BBBBBBB, d3
+
	move.w	d1, d0
	subq.w	#1, d0
	cmp.w	d0, d2
	bne.s	+
	andi.l	#$FFFFFFF0, d3
	ori.l	#1, d3
+
	move.l	#$11111111, (vdp_data_port).l
	moveq	#6, d4
-
	move.l	d3, (vdp_data_port).l
	dbf	d4, -
	moveq	#6, d4
-
	move.l	d3, (vdp_data_port).l
	dbf	d4, -
	move.l	#$11111111, (vdp_data_port).l
	addq.w	#1, d2
	cmp.w	d1, d2
	bcs.s	FH_BoxColumn
	addq.w	#1, d1
	cmpi.w	#5, d1
	bcs.s	FH_BoxWidth
	rts

; As Popup_Render, but each field slot writes its own four tiles at FH_TILES.
FH_Render:
	move.w	2(a5), d4
	andi.w	#$7FFF, d4
	cmpi.w	#9999, d4
	bls.s	+
	move.w	#9999, d4
+
	move.w	d7, d0
	lsl.w	#2, d0
	addi.w	#FH_TILES, d0
	moveq	#0, d6
	move.w	d0, d6
	lsl.l	#5, d6
	lsl.l	#2, d6
	lsr.w	#2, d6
	swap	d6
	ori.l	#$40000000, d6
	move.l	d6, (vdp_control_port).l
	lea	(Popup_Divisors).l, a4
	lea	(Popup_ExpandAmber).l, a2
	moveq	#0, d3
	moveq	#0, d5
FH_RenderDigit:
	moveq	#0, d0
	move.w	d4, d0
	divu.w	(a4)+, d0
	move.w	d0, d1
	swap	d0
	move.w	d0, d4
	tst.w	d1
	bne.s	FH_DrawDigit
	tst.w	d3
	bne.s	FH_DrawDigit
	cmpi.w	#3, d5
	beq.s	FH_DrawDigit
	moveq	#7, d6
-
	move.l	#0, (vdp_data_port).l
	dbf	d6, -
	bra.s	FH_DigitNext
FH_DrawDigit:
	moveq	#1, d3
	lsl.w	#3, d1
	lea	(Popup_StockDigits).l, a0
	adda.w	d1, a0
	moveq	#7, d6
FH_DrawRow:
	moveq	#0, d0
	move.b	(a0)+, d0
	if damage_popup_font
	move.b	d0, d2
	lsr.b	#1, d2
	or.b	d2, d0
	endif
	move.w	d0, d2
	lsr.w	#4, d0
	lsl.w	#1, d0
	move.w	(a2,d0.w), d0
	swap	d0
	andi.w	#$F, d2
	lsl.w	#1, d2
	move.w	(a2,d2.w), d0
	move.l	d0, (vdp_data_port).l
	dbf	d6, FH_DrawRow
FH_DigitNext:
	addq.w	#1, d5
	cmpi.w	#4, d5
	bcs.w	FH_RenderDigit
	rts

FH_Positions:
	dc.w	FH_HPX0, FH_HPY0, FH_HPX1, FH_HPY1
	dc.w	FH_HPX2, FH_HPY2, FH_HPX3, FH_HPY3
	endif

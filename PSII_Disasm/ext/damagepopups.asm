; Per-target battle damage pop-ups. Nine slots cover five enemies and four
; party positions. The box uses $6E0-$6F3; nine digit slots use
; $6F4-$6FF, $7E9-$7FC and $5D4-$5D7. These tiles stay clear of
; party art ($200-$3FF) and weapon/technique effects ($400-$4FF).
; The numerals reproduce the stock HP/TP face or thicken it according to
; damage_popup_font. Zero stays transparent in sprite art.
	if damage_popups

POP_SLOTS	= $FFFF8F00		; 9 x 8: timer/dirty, damage, X, Y
POP_BOX_TILES	= $6E0
POP_BOX_LOADED	= $FFFF8F48
POP_PENDING	= $FFFF8F4A		; 9 x 6: old HP, calculated HP, pending box X (0 = none)
POP_EVENT_TIMER	= $FFFF8E40	; shared impact-to-result delay
POP_EVENT_COMMAND = $FFFF8E42
POP_EVENT_SCRIPT	= $FFFF8E44
POP_PENDVAL	= $FFFF8FE0		; 9 words: each slot's number, shown at the impact
POP_IMPACT_DELAY = 4		; this frame plus three complete frames
POP_LIFE	= 45
POP_ENEMY_DIGIT_Y = $B1	; box top at screen Y=45, five below top windows
POP_PARTY_DIGIT_Y = $117	; box bottom five pixels above the party bar

; Called during the battle's fade-in, before actions can deal damage.
Popup_InitAndBuild:
	movem.l	d0/a0, -(sp)
	lea	(POP_SLOTS).l, a0
	moveq	#31, d0		; slots, pending records and the intervening gap
-
	clr.l	(a0)+
	dbf	d0, -
	clr.w	(POP_EVENT_TIMER).l
	if field_options
	clr.w	(BS_WAIT).w		; no pause left over from the last fight
	clr.w	(BS_SNAP_OK).w
	endif
	movem.l	(sp)+, d0/a0
	jmp	(BuildSprites).l

; d0 = a pop-up's frames: POP_LIFE, longer at a slower Battle Speed.
Popup_Life:
	if field_options
	jmp	(OPT_PopLife).l		; 30 at Battle Speed 1 to 90 at 5
	else
	moveq	#POP_LIFE, d0
	rts
	endif

; Replace CheckEnemyAlive without moving the following stock code.
Popup_CheckEnemyAlive:
	move.l	d3, -(sp)
	move.w	2(a1), d3
	sub.w	d0, 2(a1)
	bhi.s	+
	move.w	#0, 2(a1)
	bset	#5, 3(a2)
	moveq	#0, d1
	move.w	$C(a1), d1
	add.l	d1, (enemy_data_buffer+$30).w
	move.w	$A(a1), d1
	add.l	d1, (enemy_data_buffer+$34).w
+
	bsr.w	Popup_RecordEnemy
	move.l	(sp)+, d3
	rts

; The regular enemy attack has a separate damage formula in the stock game.
Popup_EnemyNormalDamage:
	move.l	d3, -(sp)
	move.w	2(a1), d3
	sub.w	d0, 2(a1)
	bhi.s	+
	move.w	#0, 2(a1)
	bset	#5, 3(a2)
+
	bsr.w	Popup_RecordParty
	move.l	(sp)+, d3
	rts

; Exact copy of Enemy_CalculateAttackDamage's arithmetic and status rules.
Popup_EnemyCalculateDamage:
	move.l	d3, -(sp)
	move.w	2(a1), d3
	jsr	(GenerateRandomNumber).l
	andi.l	#$1F, d0
	addi.w	#$54, d0
	mulu.w	d6, d0
	divu.w	#$64, d0
	_btst	#1, 0(a1)
	bne.s	Popup_ECD_Half
	_btst	#0, 0(a1)
	beq.s	Popup_ECD_Apply
Popup_ECD_Half:
	lsr.w	#1, d0
	bne.s	Popup_ECD_Apply
	bset	#4, 3(a2)
	move.l	(sp)+, d3
	rts
Popup_ECD_Apply:
	sub.w	d0, 2(a1)
	bhi.s	+
	move.w	#0, 2(a1)
	bset	#5, 3(a2)
+
	bsr.w	Popup_RecordParty
	move.l	(sp)+, d3
	rts

; Megid damages every enemy through CheckEnemyAlive, then halves each living
; party member's HP (rounded up). Show the HP actually paid by each member.
Popup_MegidCost:
	movem.l	d0-d1/d3, -(sp)
	move.w	2(a1), d1
	move.w	d1, d3
	move.w	d0, 2(a1)
	bne.s	+
	addq.w	#1, 2(a1)
+
	sub.w	2(a1), d1
	move.w	d1, d0
	bsr.w	Popup_RecordParty
	movem.l	(sp)+, d0-d1/d3
	rts

; d0 is the calculated hit, a2 the target object. The stock total continues
; to use d0, including overkill. Zero and failed hits have no number.
Popup_RecordEnemy:
	movem.l	d1-d2/a3-a4, -(sp)
	move.w	a2, d1
	subi.w	#$E800, d1
	lsr.w	#7, d1
	bsr.w	Popup_Store
	movem.l	(sp)+, d1-d2/a3-a4
	rts

Popup_RecordParty:
	movem.l	d1-d2/a3-a4, -(sp)
	move.w	a2, d1
	subi.w	#$E400, d1
	lsr.w	#7, d1
	lea	(party_member_id).w, a3
	moveq	#0, d2
-
	cmp.w	(a3)+, d1
	beq.s	+
	addq.w	#1, d2
	cmp.w	(party_members_num).w, d2
	bls.s	-
	bra.s	Popup_RecordParty_End
+
	move.w	d2, d1
	addq.w	#5, d1
	bsr.w	Popup_Store
Popup_RecordParty_End:
	movem.l	(sp)+, d1-d2/a3-a4
	rts

; The stock calculation runs now so multi-hit and kill decisions see its result.
; The real HP is restored at the end of this frame until the impact cue.
; d3 is the HP before this calculation; a1 is the target stat record.
Popup_ApplyHeal:
	movem.l	d0-d3, -(sp)
	move.w	2(a1), d3
	add.w	d6, 2(a1)
	move.w	4(a1), d1
	cmp.w	2(a1), d1
	bcc.s	+
	move.w	d1, 2(a1)
+
	move.w	2(a1), d0
	sub.w	d3, d0
	beq.s	+
	ori.w	#$8000, d0	; the amber numeral kind
	bsr.w	Popup_RecordParty
+
	movem.l	(sp)+, d0-d3
	rts

Popup_FullHealIfWell:
	tst.w	(a1)
	bmi.s	+
	bsr.s	Popup_FullHeal
+
	rts

Popup_ReviveHP:
	bsr.s	Popup_FullHeal
	move.w	#1, $22(a2)
	rts

Popup_FullHeal:
	movem.l	d0/d3, -(sp)
	move.w	2(a1), d3
	move.w	4(a1), 2(a1)
	move.w	2(a1), d0
	sub.w	d3, d0
	beq.s	+
	ori.w	#$8000, d0
	bsr.w	Popup_RecordParty
+
	movem.l	(sp)+, d0/d3
	rts

; FANBI and an enemy drain heal the attacker while damaging their target.
; Keep d0 as the calculated damage for the stock group-total message.
Popup_DrainHealParty:
	movem.l	d0-d3/a1-a2, -(sp)
	movea.l	a3, a1
	movea.l	a0, a2
	bsr.s	Popup_DrainHeal
	movem.l	(sp)+, d0-d3/a1-a2
	rts

Popup_DrainHealEnemy:
	movem.l	d0-d3/a1-a2, -(sp)
	movea.l	a3, a1
	movea.l	a0, a2
	bsr.s	Popup_DrainHeal
	movem.l	(sp)+, d0-d3/a1-a2
	rts

Popup_DrainHeal:
	move.w	2(a1), d3
	add.w	d0, 2(a1)
	move.w	4(a1), d1
	cmp.w	2(a1), d1
	bcc.s	+
	move.w	d1, 2(a1)
+
	move.w	2(a1), d0
	sub.w	d3, d0
	beq.s	+
	ori.w	#$8000, d0
	; a2 is the actor: choose the party or enemy display slot.
	cmpa.w	#$E800, a2
	bcc.s	Popup_DrainEnemyRecord
	bsr.w	Popup_RecordParty
	bra.s	+
Popup_DrainEnemyRecord:
	bsr.w	Popup_RecordEnemy
+
	rts

Popup_EnemyHeal20:
	move.l	d3, -(sp)
	move.w	2(a1), d3
	moveq	#$14, d0
	move.w	2(a1), d1
	add.w	d0, d1
	cmp.w	4(a1), d1
	bcs.s	+
	move.w	4(a1), d1
+
	move.w	d1, 2(a1)
	sub.w	d3, d1
	beq.s	+
	move.w	d1, d0
	ori.w	#$8000, d0
	bsr.w	Popup_RecordEnemy
+
	moveq	#$14, d0
	move.l	(sp)+, d3
	rts

Popup_EnemyFullHeal:
	movem.l	d0/d3, -(sp)
	move.w	2(a1), d3
	move.w	4(a1), 2(a1)
	move.w	2(a1), d0
	sub.w	d3, d0
	beq.s	+
	ori.w	#$8000, d0
	bsr.w	Popup_RecordEnemy
+
	movem.l	(sp)+, d0/d3
	rts

; Instant death has no ordinary damage calculation, but still needs the same
; impact delay and popup as a hit that removes all remaining HP.
Popup_EnemyInstantKill:
	movem.l	d0/d3, -(sp)
	move.w	2(a1), d3
	move.w	d3, d0
	move.w	#0, 2(a1)
	bset	#5, 3(a2)
	bsr.w	Popup_RecordParty
	movem.l	(sp)+, d0/d3
	rts

Popup_Store:
	tst.w	d0
	beq.w	Popup_Store_End
	move.w	d1, d2
	mulu.w	#6, d2
	lea	(POP_PENDING).l, a4
	adda.w	d2, a4
	move.w	d1, d2
	add.w	d2, d2
	lea	(POP_PENDVAL).l, a3
	tst.w	4(a4)
	bne.s	Popup_Store_Add
	move.w	d3, (a4)	; keep HP before the first hit on this target
	move.w	d0, (a3,d2.w)	; the number, for the impact cue to show
	bra.s	Popup_Store_Pending
Popup_Store_Add:
	add.w	d0, (a3,d2.w)	; another hit of this action on the same target: total them
	bcc.s	Popup_Store_Pending
	move.w	#$FFFF, (a3,d2.w)
Popup_Store_Pending:
	move.w	2(a1), 2(a4)
	move.w	$A(a2), d2	; the target sprite's X during this hit
	subi.w	#16, d2		; centre the 32-pixel box on that sprite
	move.w	d2, 4(a4)	; keep the next hit's X while an older popup is visible
	move.w	d1, d2
	lsl.w	#3, d2
	lea	(POP_SLOTS).l, a3
	adda.w	d2, a3
	tst.w	(a3)		; a number still showing (an earlier hit on this
	bne.s	Popup_Store_End	; target - a second weapon's): it stays until then
	move.w	d0, 2(a3)
	move.w	4(a4), 4(a3)
	cmpi.w	#5, d1
	bcs.s	Popup_StoreEnemyPos
	move.w	#POP_PARTY_DIGIT_Y, 6(a3)
	rts
Popup_StoreEnemyPos:
	move.w	#POP_ENEMY_DIGIT_Y, 6(a3)
Popup_Store_End:
	rts

; $FD is the animation's impact event. The first event in an action owns the
; text and starts a single delay for all targets (including area attacks).
Popup_Impact:
	movem.l	d0-d1/a0-a1, -(sp)
	tst.w	(POP_EVENT_TIMER).l
	bne.s	Popup_ImpactEnd
	move.w	(battle_command_used).w, d0
	bmi.s	Popup_ImpactEnd
	move.w	d0, (POP_EVENT_COMMAND).l
	move.w	(battle_script_id).w, (POP_EVENT_SCRIPT).l
	move.w	#POP_IMPACT_DELAY, (POP_EVENT_TIMER).l
	move.w	#$FFFF, (battle_command_used).w
Popup_ImpactEnd:
	clr.w	(battle_script_id).w
	movem.l	(sp)+, d0-d1/a0-a1
	rts

; $F3 starts the visible casting effect. An item that invokes a technique
; retains its Item command and gets its ordinary item plate at impact.
Popup_CastEffect:
	cmpi.b	#$F3, d0
	bne.s	+
	cmpi.w	#1, (battle_command_used).w
	bne.s	+
	move.w	#WinID_BattleTechUsed, (window_index).w
+
	neg.b	d0
	move.w	d0, $40(a0)
	rts

; Called after RunObjects, before battle windows are processed. Calculations
; in this frame have finished; preserve their final HP while showing the old
; HP until the common three-frame impact delay expires.
Popup_ProcessPending:
	moveq	#0, d6		; commit this frame?
	move.w	(POP_EVENT_TIMER).l, d0
	beq.s	Popup_PendingLoopStart
	subq.w	#1, d0
	move.w	d0, (POP_EVENT_TIMER).l
	bne.s	Popup_PendingLoopStart
	moveq	#1, d6
Popup_PendingLoopStart:
	lea	(POP_PENDING).l, a5
	lea	(POP_SLOTS).l, a4
	moveq	#0, d7
Popup_PendingLoop:
	tst.w	4(a5)
	beq.s	Popup_PendingNext
	cmpi.w	#5, d7
	bcc.s	Popup_PendingParty
	move.w	d7, d0
	lsl.w	#6, d0
	lea	(enemy_stat_buffer+2).w, a1
	adda.w	d0, a1
	bra.s	Popup_PendingAddressReady
Popup_PendingParty:
	move.w	d7, d0
	subq.w	#5, d0
	add.w	d0, d0
	lea	(party_member_id).w, a1
	move.w	(a1,d0.w), d0
	lsl.w	#6, d0
	lea	(character_data_buffer+2).w, a1
	adda.w	d0, a1
Popup_PendingAddressReady:
	tst.w	d6
	bne.s	Popup_PendingCommit
	move.w	(a5), (a1)
	bra.s	Popup_PendingNext
Popup_PendingCommit:
	move.w	2(a5), (a1)
	move.w	4(a5), 4(a4)	; the new hit replaces the visible popup at its own X
	clr.w	4(a5)
	move.w	d7, d0
	add.w	d0, d0
	lea	(POP_PENDVAL).l, a1
	move.w	(a1,d0.w), 2(a4)	; this hit's number (the slot may still show the last)
	bsr.w	Popup_Life
	ori.w	#$8000, d0
	move.w	d0, (a4)
Popup_PendingNext:
	addq.w	#6, a5
	addq.w	#8, a4
	addq.w	#1, d7
	cmpi.w	#9, d7
	bcs.s	Popup_PendingLoop
	tst.w	d6
	beq.s	Popup_PendingDone
	bsr.w	Popup_QueueWindows
Popup_PendingDone:
	rts

; The stock $FD window sequence, released on the same frame as HP/popups.
Popup_QueueWindows:
	if field_options
	jsr	(BS_Snapshot).l		; what the stats windows will show (Battle Speed 1)
	endif
	lea	(window_index).w, a1
	cmpi.w	#2, (POP_EVENT_COMMAND).l
	bne.s	+
	move.w	#WinID_BattleItemUsed, (a1)+
+
	move.l	#((6<<$18)|(WinID_BattleFirstCharStats<<$10)|(6<<8)|WinID_BattleSecondCharStats), (a1)+
	move.l	#((6<<$18)|(WinID_BattleThirdCharStats<<$10)|(6<<8)|WinID_BattleFourthCharStats), (a1)+
	if battle_name_panes==0		; (the old damage panes are gone with it)
	cmpi.w	#$102, (enemy_data_buffer).w
	bcc.s	+
	move.l	#((6<<$18)|(WinID_FirstEnemyInfo<<$10)|(6<<8)|WinID_SecondEnemyInfo), (a1)+
+
	endif
	move.w	(POP_EVENT_SCRIPT).l, d0
	beq.s	+
	move.w	#WinID_BattleMessage, (a1)+
	move.w	d0, (script_id).w
+
	rts

; Run after BuildSprites. Each framed window expands, holds its number,
; then contracts. An open window needs one box and one digit sprite.
Popup_BuildSprites:
	jsr	(BuildSprites).l
	movem.l	d0-d7/a0-a6, -(sp)
	bsr.w	Popup_ProcessPending
	tst.w	(POP_BOX_LOADED).l
	bne.s	+
	bsr.w	Popup_LoadBoxArt
	move.w	#1, (POP_BOX_LOADED).l
+
	moveq	#0, d0
	move.b	(sprite_link_field_count).w, d0
	movea.w	d0, a6		; stock sprites precede our new entries
	lea	(POP_SLOTS).l, a5
	moveq	#0, d7
Popup_BuildLoop:
	move.w	(a5), d0
	beq.w	Popup_BuildNext
	tst.b	(sprite_count).w
	beq.w	Popup_BuildNext
	tst.w	d0
	bpl.s	Popup_BuildReady
	bsr.w	Popup_Render
	andi.w	#$7FFF, (a5)
Popup_BuildReady:
	move.w	6(a5), d1
	move.w	(a5), d6		; remaining frames
	moveq	#4, d3		; box width in tiles
	cmpi.w	#6, d6
	bhi.s	Popup_Opening
	move.w	d6, d3		; closing: 3, 3, 2, 2, 1, 1
	addq.w	#1, d3
	lsr.w	#1, d3
	bra.s	Popup_WidthReady
Popup_Opening:
	bsr.w	Popup_Life
	sub.w	d6, d0
	cmpi.w	#6, d0
	bcc.s	Popup_WidthReady
	lsr.w	#1, d0		; opening: 1, 1, 2, 2, 3, 3
	addq.w	#1, d0
	move.w	d0, d3
Popup_WidthReady:
	cmpi.w	#4, d3
	bne.s	Popup_BoxSprite
	cmpi.w	#6, d6
	bls.s	Popup_BoxSprite
	move.w	d1, d0
	move.w	d7, d4
	add.w	d4, d4
	lea	(Popup_DigitTiles).l, a0
	move.w	(a0,d4.w), d4
	ori.w	#$8000, d4
	; Palette 0 colour 3 stays amber even when mixed enemies use palette 3.
	move.w	4(a5), d5
	move.w	2(a5), d2
	andi.w	#$7FFF, d2	; healing stores its amber kind in bit 15
	cmpi.w	#1000, d2
	bcc.s	Popup_XReady
	subq.w	#4, d5
	cmpi.w	#100, d2
	bcc.s	Popup_XReady
	subq.w	#4, d5
	cmpi.w	#10, d2
	bcc.s	Popup_XReady
	subq.w	#4, d5
Popup_XReady:
	moveq	#$C, d2		; four tiles across, one tile high
	bsr.w	Popup_AppendSprite
Popup_BoxSprite:
	tst.b	(sprite_count).w
	beq.s	Popup_AgeSprite
	move.w	d3, d2
	subq.w	#1, d2
	add.w	d2, d2
	lea	(Popup_BoxTileTable).l, a0
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
	add.w	d6, d5		; keep all widths centered
	bsr.w	Popup_AppendSprite
Popup_AgeSprite:
	subq.w	#1, (a5)
Popup_BuildNext:
	addq.w	#8, a5
	addq.w	#1, d7
	cmpi.w	#9, d7
	bcs.w	Popup_BuildLoop
	bsr.w	Popup_MoveToFront
	movem.l	(sp)+, d0-d7/a0-a6
	rts

; Earlier SAT entries cover later sprites. Rotate the new damage entries
; ahead of the stock character sprites so the low party windows stay visible.
; All entries have sequential links, which are rebuilt after the rotation.
Popup_MoveToFront:
	moveq	#0, d5
	move.b	(sprite_link_field_count).w, d5
	move.w	a6, d1
	cmp.w	d5, d1
	bcc.s	Popup_MoveDone
	moveq	#0, d0
	bsr.w	Popup_Reverse
	move.w	a6, d0
	move.w	d5, d1
	bsr.w	Popup_Reverse
	moveq	#0, d0
	move.w	d5, d1
	bsr.w	Popup_Reverse
	lea	(sprite_table+3).w, a0
	moveq	#1, d0
Popup_Relink:
	move.b	d0, (a0)
	addq.w	#8, a0
	addq.w	#1, d0
	cmp.w	d5, d0
	bls.s	Popup_Relink
Popup_MoveDone:
	rts

; Reverse SAT entries [d0,d1) in place, two longwords per entry.
Popup_Reverse:
	cmp.w	d1, d0
	bcc.s	Popup_ReverseDone
	subq.w	#1, d1
Popup_ReverseLoop:
	cmp.w	d1, d0
	bcc.s	Popup_ReverseDone
	move.w	d0, d2
	lsl.w	#3, d2
	lea	(sprite_table).w, a0
	adda.w	d2, a0
	move.w	d1, d2
	lsl.w	#3, d2
	lea	(sprite_table).w, a1
	adda.w	d2, a1
	move.l	(a0), d4
	move.l	(a1), (a0)
	move.l	d4, (a1)
	move.l	4(a0), d4
	move.l	4(a1), 4(a0)
	move.l	d4, 4(a1)
	addq.w	#1, d0
	subq.w	#1, d1
	bra.s	Popup_ReverseLoop
Popup_ReverseDone:
	rts

; d0 Y, d2 size, d4 tile/priority, d5 X. The caller checks sprite_count.
Popup_AppendSprite:
	movea.l	($FFFFF608).w, a4
	move.w	d0, (a4)+
	move.b	d2, (a4)+
	addq.b	#1, (sprite_link_field_count).w
	move.b	(sprite_link_field_count).w, (a4)+
	move.w	d4, (a4)+
	move.w	d5, (a4)+
	move.l	a4, ($FFFFF608).w
	clr.l	(a4)
	subq.b	#1, (sprite_count).w
	rts

Popup_DigitTiles:
	dc.w	$6F4, $6F8, $6FC, $7E9, $7ED, $7F1, $7F5, $7F9, $5D4
Popup_BoxTileTable:
	dc.w	POP_BOX_TILES, POP_BOX_TILES+2, POP_BOX_TILES+6, POP_BOX_TILES+12
Popup_BoxSizeTable:
	dc.w	$1, $5, $9, $D

; Four widths of a 16-pixel-high framed window. Genesis sprite tiles run
; down each column, so write the top and bottom tile for each column.
Popup_LoadBoxArt:
	move.w	#$8F02, (vdp_control_port).l
	move.l	#$5C000003, (vdp_control_port).l
	moveq	#1, d1		; width in tiles
Popup_BoxWidth:
	moveq	#0, d2		; column
Popup_BoxColumn:
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
-	move.l	d3, (vdp_data_port).l
	dbf	d4, -
	moveq	#6, d4
-	move.l	d3, (vdp_data_port).l
	dbf	d4, -
	move.l	#$11111111, (vdp_data_port).l
	addq.w	#1, d2
	cmp.w	d1, d2
	bcs.s	Popup_BoxColumn
	addq.w	#1, d1
	cmpi.w	#5, d1
	bcs.s	Popup_BoxWidth
	rts

; Upload four transparent digit tiles into this slot's fixed VRAM address.
; 9999 is the largest four-digit presentation; ordinary battle damage is
; below that and the stock damage total keeps its full calculated value.
Popup_Render:
	move.w	2(a5), d4
	lea	(Popup_Expand).l, a2
	btst	#15, d4
	beq.s	+
	andi.w	#$7FFF, d4
	lea	(Popup_ExpandAmber).l, a2
+
	cmpi.w	#9999, d4
	bls.s	+
	move.w	#9999, d4
+
	move.w	d7, d0
	add.w	d0, d0
	lea	(Popup_DigitTiles).l, a0
	move.w	(a0,d0.w), d0
	moveq	#0, d6
	move.w	d0, d6
	lsl.l	#5, d6
	lsl.l	#2, d6
	lsr.w	#2, d6
	swap	d6
	ori.l	#$40000000, d6
	move.l	d6, (vdp_control_port).l
	lea	(Popup_Divisors).l, a4
	moveq	#0, d3		; a nonzero digit has appeared
	moveq	#0, d5		; digit index
Popup_RenderDigit:
	moveq	#0, d0
	move.w	d4, d0
	divu.w	(a4)+, d0
	move.w	d0, d1
	swap	d0
	move.w	d0, d4
	tst.w	d1
	bne.s	Popup_DrawDigit
	tst.w	d3
	bne.s	Popup_DrawDigit
	cmpi.w	#3, d5
	beq.s	Popup_DrawDigit
	moveq	#7, d6
-
	move.l	#0, (vdp_data_port).l
	dbf	d6, -
	bra.s	Popup_DigitNext
Popup_DrawDigit:
	moveq	#1, d3
	lsl.w	#3, d1
	lea	(Popup_StockDigits).l, a0
	adda.w	d1, a0
	moveq	#7, d6
Popup_DrawRow:
	moveq	#0, d0
	move.b	(a0)+, d0
	if damage_popup_font
	move.b	d0, d2
	lsr.b	#1, d2
	or.b	d2, d0		; thicker strokes, one-pixel interdigit gap
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
	dbf	d6, Popup_DrawRow
Popup_DigitNext:
	addq.w	#1, d5
	cmpi.w	#4, d5
	bcs.w	Popup_RenderDigit
	rts

Popup_Divisors:
	dc.w	1000, 100, 10, 1
; The battle HP/TP numerals are tiles $97-$A0 in FontsIconsArt (stock ROM
; $29EB8). Their white pixels are 1; their blue background becomes 0 here.
Popup_StockDigits:
	dc.b	$00,$78,$84,$84,$84,$84,$84,$78	; 0
	dc.b	$00,$10,$30,$10,$10,$10,$10,$38	; 1
	dc.b	$00,$78,$84,$04,$18,$60,$80,$FC	; 2
	dc.b	$00,$FC,$08,$30,$08,$04,$84,$78	; 3
	dc.b	$00,$18,$28,$48,$88,$FC,$08,$08	; 4
	dc.b	$00,$F8,$80,$80,$F8,$04,$84,$78	; 5
	dc.b	$00,$38,$40,$80,$F8,$84,$84,$78	; 6
	dc.b	$00,$FC,$84,$88,$10,$20,$20,$20	; 7
	dc.b	$00,$78,$84,$84,$78,$84,$84,$78	; 8
	dc.b	$00,$78,$84,$84,$7C,$04,$08,$30	; 9
; Four 1bpp pixels expanded to four transparent 4bpp pixels.
Popup_Expand:
	dc.w	$0000,$0001,$0010,$0011,$0100,$0101,$0110,$0111
	dc.w	$1000,$1001,$1010,$1011,$1100,$1101,$1110,$1111
; Battle palette 0 colour $3 is amber ($0AAE), as in field healing.
; Colour $1 in the same palette is white for damage digits.
Popup_ExpandAmber:
	dc.w	$0000,$0003,$0030,$0033,$0300,$0303,$0330,$0333
	dc.w	$3000,$3003,$3030,$3033,$3300,$3303,$3330,$3333

	endif

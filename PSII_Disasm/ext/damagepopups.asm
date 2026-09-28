; Per-target battle damage pop-ups. Nine slots cover five enemies and four
; party positions. Digit tiles use $33C-$35F and box tiles $360-$373,
; a range unused by every audited battle formation, including the bosses.
; The font comes from the dialogue face; zero stays transparent in sprite art.
	if damage_popups

POP_SLOTS	= $FFFF8F00		; 9 x 8: timer/dirty, damage, X, Y
POP_TILES	= $33C
POP_BOX_LOADED	= $FFFF8F48
POP_LIFE	= 45

; Called during the battle's fade-in, before actions can deal damage.
Popup_InitAndBuild:
	movem.l	d0/a0, -(sp)
	lea	(POP_SLOTS).l, a0
	moveq	#17, d0
-
	clr.l	(a0)+
	dbf	d0, -
	clr.w	(POP_BOX_LOADED).l
	movem.l	(sp)+, d0/a0
	jmp	(BuildSprites).l

; Replace CheckEnemyAlive without moving the following stock code.
Popup_CheckEnemyAlive:
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
	rts

; The regular enemy attack has a separate damage formula in the stock game.
Popup_EnemyNormalDamage:
	sub.w	d0, 2(a1)
	bhi.s	+
	move.w	#0, 2(a1)
	bset	#5, 3(a2)
+
	bsr.w	Popup_RecordParty
	rts

; Exact copy of Enemy_CalculateAttackDamage's arithmetic and status rules.
Popup_EnemyCalculateDamage:
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
	rts
Popup_ECD_Apply:
	sub.w	d0, 2(a1)
	bhi.s	+
	move.w	#0, 2(a1)
	bset	#5, 3(a2)
+
	bsr.w	Popup_RecordParty
	rts

; Megid damages every enemy through CheckEnemyAlive, then halves each living
; party member's HP (rounded up). Show the HP actually paid by each member.
Popup_MegidCost:
	movem.l	d0-d1, -(sp)
	move.w	2(a1), d1
	move.w	d0, 2(a1)
	bne.s	+
	addq.w	#1, 2(a1)
+
	sub.w	2(a1), d1
	move.w	d1, d0
	bsr.w	Popup_RecordParty
	movem.l	(sp)+, d0-d1
	rts

; d0 is the calculated hit, a2 the target object. The stock total continues
; to use d0, including overkill. Zero and failed hits have no number.
Popup_RecordEnemy:
	movem.l	d1-d2/a3, -(sp)
	move.w	a2, d1
	subi.w	#$E800, d1
	lsr.w	#7, d1
	bsr.s	Popup_Store
	movem.l	(sp)+, d1-d2/a3
	rts

Popup_RecordParty:
	movem.l	d1-d2/a3, -(sp)
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
	bsr.s	Popup_Store
Popup_RecordParty_End:
	movem.l	(sp)+, d1-d2/a3
	rts

Popup_Store:
	tst.w	d0
	beq.s	Popup_Store_End
	move.w	d1, d2
	lsl.w	#3, d2
	lea	(POP_SLOTS).l, a3
	adda.w	d2, a3
	move.w	#$8000|POP_LIFE, (a3)
	move.w	d0, 2(a3)
	move.w	$A(a2), d2
	subi.w	#16, d2
	move.w	d2, 4(a3)
	move.w	$E(a2), d2
	cmpi.w	#5, d1
	bcs.s	+
	subi.w	#56, d2		; party: above the character art
	bra.s	++
+
	subi.w	#48, d2		; enemy: above the creature art
+
	move.w	d2, 6(a3)
Popup_Store_End:
	rts

; Run after BuildSprites. Each framed window expands, holds its number,
; then contracts. An open window needs one box and one digit sprite.
Popup_BuildSprites:
	jsr	(BuildSprites).l
	movem.l	d0-d7/a0-a6, -(sp)
	tst.w	(POP_BOX_LOADED).l
	bne.s	+
	bsr.w	Popup_LoadBoxArt
	move.w	#1, (POP_BOX_LOADED).l
+
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
	moveq	#POP_LIFE, d0
	sub.w	(a5), d0
	lsr.w	#2, d0
	move.w	6(a5), d1
	sub.w	d0, d1		; rising number Y; box starts four above it
	move.w	(a5), d6		; remaining frames
	moveq	#4, d3		; box width in tiles
	cmpi.w	#6, d6
	bhi.s	Popup_Opening
	move.w	d6, d3		; closing: 3, 3, 2, 2, 1, 1
	addq.w	#1, d3
	lsr.w	#1, d3
	bra.s	Popup_WidthReady
Popup_Opening:
	moveq	#POP_LIFE, d0
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
	lsl.w	#2, d4
	addi.w	#$8000|POP_TILES, d4
	move.w	4(a5), d5
	move.w	2(a5), d2
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
	movem.l	(sp)+, d0-d7/a0-a6
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

Popup_BoxTileTable:
	dc.w	$360, $362, $366, $36C
Popup_BoxSizeTable:
	dc.w	$1, $5, $9, $D

; Four widths of a 16-pixel-high framed window. Genesis sprite tiles run
; down each column, so write the top and bottom tile for each column.
Popup_LoadBoxArt:
	move.w	#$8F02, (vdp_control_port).l
	move.l	#$6C000001, (vdp_control_port).l
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
	cmpi.w	#9999, d4
	bls.s	+
	move.w	#9999, d4
+
	move.w	d7, d0
	lsl.w	#2, d0
	addi.w	#POP_TILES, d0
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
	addq.w	#1, d1		; text bytes 1-10 are 0-9
	lsl.w	#3, d1
	lea	(VWF_Font).l, a0
	adda.w	d1, a0
	moveq	#7, d6
Popup_DrawRow:
	moveq	#0, d0
	move.b	(a0)+, d0
	move.w	d0, d2
	lsr.w	#4, d0
	lsl.w	#1, d0
	lea	(Popup_Expand).l, a1
	move.w	(a1,d0.w), d0
	swap	d0
	andi.w	#$F, d2
	lsl.w	#1, d2
	move.w	(a1,d2.w), d0
	move.l	d0, (vdp_data_port).l
	dbf	d6, Popup_DrawRow
Popup_DigitNext:
	addq.w	#1, d5
	cmpi.w	#4, d5
	bcs.w	Popup_RenderDigit
	rts

Popup_Divisors:
	dc.w	1000, 100, 10, 1
; Four 1bpp pixels expanded to four transparent 4bpp pixels.
Popup_Expand:
	dc.w	$0000,$0001,$0010,$0011,$0100,$0101,$0110,$0111
	dc.w	$1000,$1001,$1010,$1011,$1100,$1101,$1110,$1111

	endif

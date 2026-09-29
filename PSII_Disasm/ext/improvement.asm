; FlamePurge's "Phantasy Star II Improvement" v4.5: the code its changes need,
; called from same-size hooks in ps2.asm (docs/improvement.md lists them all).
; Each routine does what the Improvement's reassembled code does at that spot.

	if improvement_fixes

; LoadSpritesInLevel: the world map's first sprite is a Jet Scooter at the dock,
; which the post-Roron scooter (kept at its last position, loaded right after)
; shared slot 0 ($E800) with. Leave slot 0 to that one: skip the entry and the slot.
Fix_LevelSpriteSlots:
	move.w	#$40, d0
	move.w	#$1F, d1
	tst.w	(level_index).w
	bne.s	+
	lea	$40(a3), a3
	subq.w	#1, d1
	addq.w	#6, a2
+
	rts

; ObjRRCB_Init: the battle command cursor starts on the first entry.
Fix_BattleCursorInit:
	move.w	#1, $22(a0)
	move.w	#0, ($FFFFDE50).w
	rts

; TechAction_Shinb: loc_27AA tests the enemy's type through a1, which the stock
; left on the character: SHINB never worked. N set = no escape (as the stock
; beq to loc_22EA when the escape rate is 0, a boss).
Fix_ShinbEscape:
	tst.w	(enemy_data_buffer+$18).w
	bne.s	+
	ori.b	#8, ccr
	rts
+
	lea	(enemy_stat_buffer).w, a1
	jmp	(loc_27AA).l

; loc_2C28: d0's high word was left over when the divu ran.
Fix_TechSuccessRate:
	lea	(EnemyTechSuccessRate).l, a4
	moveq	#0, d0
	rts

; loc_785C, the end of the credits: clear the event flags before the Sega screen,
; so a prologue that plays after the ending shows the dams closed and the rivers dry.
Fix_ClearEventFlags:
	lea	($FFFFC700).w, a0
	moveq	#0, d0
	move.w	#$3F, d7
-
	move.l	d0, (a0)+
	dbf	d7, -
	move.w	#$9001, (vdp_control_port).l
	rts

; LevelScreen: a map load clears the moved flag, so entering a map is no step
; towards a battle.
Fix_LevelScreenInit:
	jsr	(LoadDynWindowsInRam).l
	clr.w	($FFFFCB0A).w
	rts

; SAR, SAK and NASAK out of battle (the sound RES uses), and ANTI (the hospital's).
Fix_FieldHealSound:
	move.w	#((6<<8)|WinID_MenuCharStats), (window_index).w
	addq.w	#1, (event_routine_sub).w
	move.b	#SXFID_Healed, (sound_queue).w
	rts

Fix_FieldAntiSound:
	move.w	#((6<<8)|WinID_MenuCharStats), (window_index).w
	addq.w	#1, (event_routine_sub).w
	move.b	#SXFID_PoisonCured, (sound_queue).w
	rts

; loc_C1EA, back from the Central Tower storage list: check again that the
; character still has an item to store.
Fix_StorageReturn:
	tst.w	(event_routine_sub_2).w
	beq.s	+
	lea	($FFFFC027).w, a2
	move.w	(character_index).w, d1
	lsl.w	#6, d1
	adda.w	d1, a2
	tst.b	(a2)
	beq.s	++
	move.w	#WinID_MenuItemList, (window_index).w
	addq.w	#1, (event_routine).w
	rts
+
	jmp	(loc_C1FC).l
+
	jmp	(loc_C218).l

; The Kueri inventor: once he has made the gum ($C720 = 2), he greets with $B08
; ("what can I work on?") and the visit ends there.
Fix_InventorGreeting:
	cmpi.b	#2, ($FFFFC720).w
	beq.s	+
	move.w	#$B01, (script_id).w
	rts
+
	addq.w	#1, (event_routine_sub).w
	addq.l	#4, sp			; return from loc_C8CA
	rts

Fix_InventorGum:
	jsr	(AddItemToInventory2).l
	addq.b	#1, ($FFFFC720).w
	move.b	#SXFID_ItemReceived, (sound_queue).w
	rts

; loc_D9C6, getting off the Jet Scooter: the leader starts from the scooter's
; position and direction before the step off.
Fix_ScooterDisembark:
	move.w	($FFFFE80E).w, ($FFFFE40E).w
	move.w	($FFFFE80A).w, ($FFFFE40A).w
	move.w	($FFFFE82A).w, ($FFFFE42A).w
	lea	($FFFFE800).w, a0
	lea	(JetScooter_CharOffPosOffsets).l, a1
	rts

; Run_EventIndex_TryRun: a random 0 no longer beats an escape rate of 0 (bosses).
Fix_TryRunRandom:
	jsr	(GenerateRandomNumber).l
	tst.w	(enemy_data_buffer+$18).w
	bne.s	+
	moveq	#1, d0
+
	rts

	endif	; improvement_fixes

	if improvement_fixes|fast_walking

; ObjFlwngChar_Main, whole. fast_walking: a follower trails the leader by 8
; frames of the position history, not 16 (the stock offset came from the word
; at $E402 less the object's address). improvement_fixes: a follower animates
; only on a frame it moved.
Fix_FollowerMain:
	move.l	-$3C(a0), 4(a0)		; the leader's mappings
	lea	($FFFFDD00).w, a2
	move.w	($FFFFF740).w, d0
	if fast_walking
	moveq	#0, d1
	move.w	a0, d1
	subi.w	#$E400, d1
	lsr.w	#1, d1
	sub.w	d1, d0
	else
	move.l	($FFFFE400).w, d1
	sub.l	a0, d1
	add.w	d1, d0
	endif
	andi.w	#$FF, d0
	adda.w	d0, a2
	move.w	(a2)+, d0
	move.w	(a2), d1
	moveq	#3, d2
	moveq	#0, d3			; set when the follower moves
	cmp.w	$E(a0), d1
	beq.s	Fix_Follower_X
	bhi.s	Fix_Follower_Dir
	move.w	#0, d2
	bra.s	Fix_Follower_Dir
Fix_Follower_X:
	moveq	#9, d2
	cmp.w	$A(a0), d0
	beq.s	Fix_Follower_Pos
	bhi.s	Fix_Follower_Dir
	move.w	#6, d2
Fix_Follower_Dir:
	moveq	#1, d3
	move.w	d2, $2A(a0)
Fix_Follower_Pos:
	move.w	d0, $A(a0)
	move.w	d1, $E(a0)
	tst.w	($FFFFE414).w
	bne.s	+
	tst.w	($FFFFE418).w
	beq.s	Fix_Follower_Stand
+
	tst.w	($FFFFE428).w
	beq.s	Fix_Follower_Ret
	if improvement_fixes
	tst.w	d3
	beq.s	Fix_Follower_Ret
	endif
	subq.w	#1, $26(a0)
	bpl.s	Fix_Follower_Ret
	move.w	#7, $26(a0)
	move.w	$32(a0), d0
	addq.w	#1, $32(a0)
	andi.w	#3, $32(a0)
	lea	(Level_SpriteMappingsArray).l, a1
	adda.w	d0, a1
	move.b	(a1), d0
	add.w	$2A(a0), d0
	move.w	d0, $24(a0)
Fix_Follower_Ret:
	rts
Fix_Follower_Stand:
	move.w	$2A(a0), $24(a0)
	rts

	endif	; improvement_fixes|fast_walking

	if improvement_rebalance

; ProcessStealItem: Shilka steals from the shops of Motavia only.
Fix_StealOnMotavia:
	tst.w	(planet_index).w
	bne.s	+
	lea	(party_member_id).w, a1
	move.w	(party_members_num).w, d0
	rts
+
	addq.l	#4, sp			; return from ProcessStealItem
	rts

	endif	; improvement_rebalance

	if double_rewards

; The enemy records' EXP and meseta, doubled as they are copied to RAM (the
; Doubler addendum doubles the records; the most, $36F5 EXP, still fits a word).
Fix_DoubleRewards:
	move.w	(a1)+, d1
	add.w	d1, d1
	move.w	d1, $C(a6)
	move.w	(a1)+, d1
	add.w	d1, d1
	move.w	d1, $A(a6)
	rts

	endif	; double_rewards

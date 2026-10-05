; B at an equipment shop's Who? list cancels that purchase, not the visit.
; Each Building_*Store hook replaces the stock eight-byte subroutine check.
	if shop_no_reprompt
WeaponShop_ExitDispatch:
	tst.w	(event_routine_sub).w
	beq.s	.weapon_event
	cmpi.w	#2, (event_routine_sub).w
	beq.s	.weapon_money
	cmpi.w	#1, (event_routine_sub).w
	bne.s	.weapon_exit
	cmpi.w	#6, (event_routine).w	; Who? selection
	bne.s	.weapon_exit
	tst.w	(script_id).w		; a warning or purchase failure is pending
	bne.s	.weapon_exit
	move.w	#$604, (script_id).w
	clr.w	(event_routine_sub).w
	move.w	#9, (event_routine).w	; reuse the existing No return
	jmp	(loc_BBA8).l
.weapon_money:
	cmpi.w	#6, (event_routine).w
	bne.s	.weapon_exit
	tst.w	(script_id).w
	bne.s	.weapon_wait
	clr.w	(event_routine_sub).w
	move.w	#9, (event_routine).w
	jmp	(loc_BBA8).l
.weapon_wait:
	rts
.weapon_event:
	jmp	(WeaponStoreEventDispatch).l
.weapon_exit:
	jmp	(loc_BA66).l

ArmorShop_ExitDispatch:
	tst.w	(event_routine_sub).w
	beq.s	.armor_event
	cmpi.w	#2, (event_routine_sub).w
	beq.s	.armor_money
	cmpi.w	#1, (event_routine_sub).w
	bne.s	.armor_exit
	cmpi.w	#6, (event_routine).w	; Who? selection
	bne.s	.armor_exit
	tst.w	(script_id).w
	bne.s	.armor_exit
	move.w	#$704, (script_id).w
	clr.w	(event_routine_sub).w
	move.w	#9, (event_routine).w
	jmp	(loc_BD3E).l
.armor_money:
	cmpi.w	#6, (event_routine).w
	bne.s	.armor_exit
	tst.w	(script_id).w
	bne.s	.armor_wait
	clr.w	(event_routine_sub).w
	move.w	#9, (event_routine).w
	jmp	(loc_BD3E).l
.armor_wait:
	rts
.armor_event:
	jmp	(ArmorStoreEventDispatch).l
.armor_exit:
	jmp	(loc_BBFC).l
	endif

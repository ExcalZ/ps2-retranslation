; The Item Shop's Buy > Who? cancel and insufficient-funds return.
; Building_ItemStore jumps here in place of its eight-byte subroutine check.
	if shop_no_reprompt
	if relocate_script==0
	error "shop_no_reprompt needs relocate_script"
	endif
	if long_script_offsets==0
	error "shop_no_reprompt needs long_script_offsets"
	endif

ItemShop_ExitDispatch:
	cmpi.w	#18, (event_routine).w	; waiting for the shopkeeper's reply
	beq.s	.wait_reply
	tst.w	(event_routine_sub).w
	bne.s	.sub
	jmp	(ItemStoreEventDispatch).l
.sub:
	cmpi.w	#15, (event_routine).w	; Buy > Who? selection
	beq.s	.candidate
	jmp	(loc_BD92).l
.candidate:
	cmpi.w	#1, (event_routine_sub).w	; B at the carrier list
	beq.s	.cancel
	cmpi.w	#2, (event_routine_sub).w	; insufficient funds
	beq.s	.return
	jmp	(loc_BD92).l
.cancel:
	move.w	#$811, (script_id).w
.return:
	clr.w	(event_routine_sub).w
	move.w	#$8003, (window_index).w	; close Who?, item list, Buy/Sell
	move.w	#18, (event_routine).w	; show the reply before Buy/Sell
	rts
.wait_reply:
	tst.w	(script_id).w
	bne.s	.wait
	move.w	#3, (event_routine).w	; reopen Buy/Sell
.wait:
	rts
	endif

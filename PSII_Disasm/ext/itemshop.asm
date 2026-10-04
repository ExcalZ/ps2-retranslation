; The Item Shop's Buy > Who? cancel, insufficient-funds return, and Buy/Sell exits.
; Building_ItemStore jumps here in place of its eight-byte subroutine check.
	if shop_no_reprompt
	if relocate_script==0
	error "shop_no_reprompt needs relocate_script"
	endif
	if long_script_offsets==0
	error "shop_no_reprompt needs long_script_offsets"
	endif

IS_WAIT_MAIN	= 18		; outside the stock ItemStoreEventIndex
IS_WAIT_BUY	= 19

ItemShop_ExitDispatch:
	cmpi.w	#IS_WAIT_MAIN, (event_routine).w
	beq.w	.wait_main
	cmpi.w	#IS_WAIT_BUY, (event_routine).w
	beq.w	.wait_buy
	tst.w	(event_routine_sub).w
	bne.s	.sub
	jmp	(ItemStoreEventDispatch).l
.sub:
	cmpi.w	#1, (event_routine_sub).w	; B in a menu
	bne.s	.maybe_money
	cmpi.w	#15, (event_routine).w	; Buy > Who?
	beq.s	.cancel_carrier
	cmpi.w	#13, (event_routine).w	; Buy item list
	beq.s	.close_menu
	cmpi.w	#6, (event_routine).w	; Sell character list
	beq.s	.close_menu
	jmp	(loc_BD92).l
.maybe_money:
	cmpi.w	#2, (event_routine_sub).w	; insufficient funds
	bne.s	.stock_exit
	cmpi.w	#15, (event_routine).w
	bne.s	.stock_exit
	move.w	#$8003, (window_index).w	; Who?, Buy list, Buy/Sell
	clr.w	(event_routine_sub).w
	move.w	#IS_WAIT_MAIN, (event_routine).w
	rts
.stock_exit:
	jmp	(loc_BD92).l
.cancel_carrier:
	move.w	#$811, (script_id).w
	clr.w	(event_routine_sub).w
	move.w	#$8003, (window_index).w	; expose the dialogue window
	move.w	#IS_WAIT_BUY, (event_routine).w
	rts
.close_menu:
	move.w	#$812, (script_id).w
	clr.w	(event_routine_sub).w
	move.w	#$8002, (window_index).w	; submenu and Buy/Sell
	move.w	#IS_WAIT_MAIN, (event_routine).w
	rts
.wait_main:
	tst.w	(script_id).w
	bne.s	.wait_main_done
	move.w	#3, (event_routine).w	; reopen Buy/Sell
.wait_main_done:
	rts
.wait_buy:
	tst.w	(script_id).w
	bne.s	.wait_buy_done
	move.l	#((WinID_BuySell<<16)|WinID_StoreInventory), (window_index).w
	move.w	#13, (event_routine).w	; the Buy item list takes input
.wait_buy_done:
	rts
	endif

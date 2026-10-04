; Return to the destination list after declining the Teleport Station's price.
; Building_TeleportStation jumps here in place of its eight-byte subroutine check.
	if teleport_decline_retry
	if relocate_script==0
	error "teleport_decline_retry needs relocate_script"
	endif
	if long_script_offsets==0
	error "teleport_decline_retry needs long_script_offsets"
	endif

TeleportStation_ExitDispatch:
	move.w	(event_routine_sub).w, d0
	bne.s	.sub
	cmpi.w	#8, (event_routine).w	; outside the stock event table
	beq.s	.wait_reply
	jmp	(TeleportStationEventDispatch).l
.sub:
	cmpi.w	#1, d0			; No at the payment confirmation
	bne.s	.stock_exit
	cmpi.w	#6, (event_routine).w
	bne.s	.stock_exit
	move.w	#$C09, (script_id).w
	move.w	#$8001, (window_index).w	; Yes/No is gone; close destination list
	clr.w	(event_routine_sub).w
	move.w	#8, (event_routine).w
	rts
.stock_exit:
	jmp	(loc_CA80).l
.wait_reply:
	tst.w	(script_id).w
	bne.s	.wait_done
	move.w	#WinID_TeleportPlaceNames, (window_index).w
	move.w	#4, (event_routine).w	; destination list takes input
.wait_done:
	rts
	endif

; Title menu variants. The stock menu and its event code stay in place for an
; option-0 build. A save slot is occupied when its first name byte is nonzero,
; the same check used by Continue and Erase in the stock title state machine.
	if title_save_menu
	if battle_box==0
	error "title_save_menu needs battle_box for the window-record hook"
	endif
	if vwf_windows==0
	error "title_save_menu needs vwf_windows for its reordered labels"
	endif

; Called each time the game-select window opens, including after erasing data.
TM_Open:
	clr.w	(TM_MAX).w
	lea	($200739).l, a0
	moveq	#3, d0
.slot:
	tst.b	(a0)
	bne.s	.found
	lea	$800(a0), a0
	dbf	d0, .slot
	bra.s	.open
.found:
	move.w	#2, (TM_MAX).w
.open:
	move.w	#WinID_GameSelect, (window_index).w
	addq.w	#1, (event_routine).w
	rts

; The saved-file order is Continue, New, Erase. With no files the only row is
; New. The caller has already handled B/cancel and cleared event_routine_sub_2.
TM_Select:
	move.w	($FFFFDED0).w, d0
	tst.w	(TM_MAX).w
	beq.s	.new
	tst.w	d0
	beq.s	.continue
	cmpi.w	#1, d0
	beq.s	.new
	addq.w	#3, (event_routine).w
	addq.w	#7, (event_routine).w
	rts
.continue:
	addq.w	#7, (event_routine).w
	rts
.new:
	addq.w	#1, (event_routine).w
	rts

; ProcessWindows supplies a1 = WindowArtLayoutPtrs-8, d0 = window ID.
TM_Record:
	cmpi.w	#WinID_GameSelect, d0
	bne.s	.done
	tst.w	(TM_MAX).w
	bne.s	.done
	lea	(TM_EmptyLayout-WinID_GameSelect*8).l, a1
.done:
	rts

TM_EmptyLayout:
	dc.b	$41, $8E
	dc.l	TM_EmptyArt
	dc.b	$12, $03

TM_EmptyArt:				; $26 the blank tile: the label is drawn only on blanks
	border 17, $B9			; (the window charset is not in force here: " " is $20)
	border 17, $26
	dc.b	$B4, $B5
	border 15, $26
	border 17, $BE
	even
	endif

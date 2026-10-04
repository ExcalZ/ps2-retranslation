; A search window can cover the exact frame a step reaches tile centre. The
; stock encounter test returns while the window is up, then movement carries
; the player off centre before the test runs again. CB0A's low bit remains the
; moved flag; bit 1 records a check due once the window closes. Both player
; and Jet Scooter movement preserve that pending bit.

	if search_encounter_fix
SearchEncounter_MarkMoved:
	ori.w	#1, ($FFFFCB0A).w
	rts

; The A button can open the next search window on the first free frame. Settle
; an earlier deferred encounter before that new interaction takes the frame.
SearchEncounter_BeforeA:
	tst.w	(window_index).w
	bne.s	SearchEncounter_Return
	cmpi.w	#1, ($FFFFCB0A).w
	bls.s	SearchEncounter_AReady
	tst.w	($FFFFDE70).w
	bne.s	SearchEncounter_AReady
	tst.w	(current_active_objects_num).w
	bne.s	SearchEncounter_AReady
	jsr	(ProcessRandomBattle).l
	cmpi.b	#ScreenID_Battle, (game_screen).w
	beq.s	SearchEncounter_Return
SearchEncounter_AReady:
	jmp	(SearchEncounter_AContinue).l

SearchEncounter_Precheck:
	tst.w	($FFFFCB0A).w
	beq.s	SearchEncounter_Return
	tst.w	(demo_flag).w
	bne.s	SearchEncounter_Return
	cmpi.w	#1, ($FFFFCB0A).w
	bhi.s	SearchEncounter_OnStep
	jmp	(SearchEncounter_PositionCheck).l

SearchEncounter_OnStep:
	tst.w	($FFFFDE70).w
	bne.s	SearchEncounter_Pending
	tst.w	(window_index).w
	bne.s	SearchEncounter_Pending
	tst.w	(current_active_objects_num).w
	bne.s	SearchEncounter_Pending
	move.w	#0, ($FFFFCB0A).w
	jmp	(SearchEncounter_Continue).l

SearchEncounter_Pending:
	ori.w	#2, ($FFFFCB0A).w
SearchEncounter_Return:
	rts
	endif

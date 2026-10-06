; =============================================================================
; battle_box: the battle message box as wide as the script window, and two
; lines tall when its message needs them.
;
; The stock box is 20 cells by one text line at rows 17-20 (a letter is two
; cells tall), with $CD1C = 0: every line feed clears it, so a longer battle
; message has to wait for a button between pages. Here the box is 24 cells
; (192 px, as the dialogue) at the same rows, and when a message queued for it
; holds a line feed ({BR}) it opens as the script window's 24 x 4 art two rows
; higher (rows 15-20) with $CD1C = 2, so it shows two lines and scrolls as the
; dialogue window does.
;
; ProcessWindows looks the record up as WindowArtLayoutPtrs-8 + id * 8; the
; hook returns a base that lands on BattleBox_Tall instead. The choice is made
; from the ids queued in script_id when the window opens: messages the game
; queues into an open box later (the victory rewards and level-ups) continue
; in the box it opened with (tools/linecheck.py keeps those to one line).
;
; Rows 15-16 are the battle floor's while the fight runs: the vertical blank
; copies them from RAM every frame, so around a two-line box it copies only the
; columns beside it (BattleBox_Floor).
;
; RAM: BattleBox_Rows and BattleBox_Time, two words past VWF's part of the
; text_buffer tail.
; =============================================================================
	if battle_box

; BattleBox_Rows (ps2.constants.asm: the hooks in Win_BattleMessage read them as
; short addresses) = $CF90: 0 one line, 2 two lines; BattleBox_Time = $CF92: the
; frames a message ending in {C6} stays up once typed, a second a row of the box
; (the stock 60 for the one-line box, 120 for the two-line one).

; ProcessWindows: in place of lea (WindowArtLayoutPtrs-8).l, a1; d0 = window id.
BattleBox_Record:
	lea	(WindowArtLayoutPtrs-8).l, a1
	cmpi.w	#WinID_BattleMessage, d0
	bne.s	.done
	movem.l	d0-d2/a0/a2, -(sp)
	moveq	#0, d2			; one line
	lea	(script_id).w, a2
	moveq	#8-1, d1		; the queue holds eight ids
.id:
	move.w	(a2)+, d0
	beq.s	.set			; the end of the queue
	andi.w	#$FF, d0
	beq.s	.next			; no message (LoadScript skips it too)
	move.w	-2(a2), d0
	lsr.w	#6, d0
	andi.w	#$3FC, d0
	lea	(GameScriptPtrs).l, a0
	movea.l	(a0,d0.w), a0		; the bank
	move.w	-2(a2), d0
	andi.w	#$FF, d0
	subq.w	#1, d0
	add.w	d0, d0
	add.w	d0, d0
	movea.l	(a0,d0.w), a0		; the message (long_script_offsets)
.byte:
	move.b	(a0)+, d0
	cmpi.b	#$C1, d0
	beq.s	.two			; a line feed
	cmpi.b	#$C4, d0
	bcs.s	.byte			; up to its end code (through fall-through blocks)
.next:
	dbf	d1, .id
	bra.s	.set
.two:
	moveq	#2, d2
.set:
	move.w	d2, (BattleBox_Rows).w
	move.w	d2, d1
	mulu.w	#30, d1
	addi.w	#60, d1			; a second a row: 60 frames, 120 for two
	if field_options
	jsr	(OPT_HoldScale).l	; 45/90 at Battle Speed 1 to 120/240 at 5
	endif
	move.w	d1, (BattleBox_Time).w
	movem.l	(sp)+, d0-d2/a0/a2
	tst.w	(BattleBox_Rows).w
	beq.s	.done
	lea	(BattleBox_Tall-WinID_BattleMessage*8).l, a1
.done:
	if battle_name_panes
	cmpi.w	#WinID_SecondEnemyName, d0	; the second group's name at the right corner
	bne.s	+
	lea	(BN_SecondName-WinID_SecondEnemyName*8).l, a1
+
	endif
	if party_menu_ps4
	jsr	(PM_Record).l
	endif
	if title_save_menu
	jsr	(TM_Record).l
	endif
	if field_options
	jsr	(OPT_Record).l
	endif
	if shop_equip_compare
	jsr	(SH_Record).l
	endif
	if battle_macros
	jsr	(MAC_Record).l
	endif
	rts

	if battle_name_panes
; battle_name_panes: the stock second name pane is columns 21-32 with its damage
; pane at 33-38; with no damage panes it stands at the right corner, columns
; 27-38, as the first (1-12) stands at the left.
BN_SecondName:
	dc.w	$6000|(1<<7)|(27*2)
	dc.l	(window_art_buffer&$FFFFFF)+WinArt_EnemyNames-DynamicWindowsStart
	dc.b	$0B, $03

; The battle start's queue (loc_8730): the two name panes, no damage panes (the
; pop-ups show the numbers). With one enemy group (the second group's count,
; less one, is -1; its ID is 0) the right corner's pane is not opened at all.
BN_QueueNames:
	move.l	#((4<<$18)|(WinID_FirstEnemyName<<$10)|(4<<8)|WinID_SecondEnemyName), (window_index).w
	clr.l	(window_index+4).w
	tst.w	(enemy_data_buffer+$14).w
	bpl.s	+
	clr.w	(window_index+2).w	; the first group's pane alone
+
	rts
	endif

; The battle's vertical blank (loc_5BB0), while the fight runs: the stock DMA
; of the floor's last two rows - RAM $FF6780, 2 x 64 cells, to plane A rows
; 15-16, every frame - which would paint over the two-line box's top rows.
; While such a box is up (open, opening or closing) the two rows are copied
; around it instead: columns 0-6 and 33-63, the floor still moving beside it.
; Leaves a6 at the control port, as the stock code.
BattleBox_Floor:
	lea	(vdp_control_port).l, a6
	movem.l	d0-d3/a0-a1, -(sp)
	bsr.s	BattleBox_TallUp
	bne.s	BBFloor_Around
	move.w	#$9380, (a6)		; the stock DMA
	move.w	#$9400, (a6)
	move.w	#$95C0, (a6)
	move.w	#$96B3, (a6)
	move.w	#$977F, (a6)
	move.w	#$4780, (a6)
	move.w	#$83, ($FFFFF644).w
	move.w	($FFFFF644).w, (a6)
	bra.s	BBFloor_Done
BBFloor_Around:
	move.w	#$8F02, (a6)
	lea	(vdp_data_port).l, a1
	lea	($FF6780).l, a0
	move.l	#$47800003, d1		; VRAM $C780: row 15, column 0
	moveq	#2-1, d3
BBFloor_Row:
	move.l	d1, (a6)
	moveq	#7-1, d0		; columns 0-6
-
	move.w	(a0)+, (a1)
	dbf	d0, -
	lea	26*2(a0), a0		; the box's columns 7-32
	move.l	d1, d2
	addi.l	#(33*2)<<16, d2
	move.l	d2, (a6)
	moveq	#31-1, d0		; columns 33-63
-
	move.w	(a0)+, (a1)
	dbf	d0, -
	addi.l	#$80<<16, d1		; the next row
	dbf	d3, BBFloor_Row
BBFloor_Done:
	movem.l	(sp)+, d0-d3/a0-a1
	rts

; NE when a two-line battle box is in the window stack: a slot ($DF00 + 16 per
; window: +$C the height byte, +$E the id) up, or being opened or closed ($DE40).
BattleBox_TallUp:
	lea	($FFFFDF00).w, a0
	move.w	(current_active_objects_num).w, d0
	andi.w	#$F, d0
	tst.w	($FFFFDE40).w
	beq.s	+
	addq.w	#1, d0			; the slot the window code is drawing or restoring
+
	subq.w	#1, d0
	bmi.s	BBTall_No
-
	cmpi.w	#WinID_BattleMessage, $E(a0)
	bne.s	+
	cmpi.w	#5, $C(a0)		; BattleBox_Tall's height
	beq.s	BBTall_Yes
+
	lea	$10(a0), a0
	dbf	d0, -
BBTall_No:
	moveq	#0, d0
	rts
BBTall_Yes:
	moveq	#1, d0
	rts

	even
; The two-line box: the script window's size and art, its bottom on the
; one-line box's (row 20), columns 7-32.
BattleBox_Tall:
	dc.b	$47, $8E
	dc.l	WinArt_ScriptMessage
	dc.b	$19, $05

; The one-line box: 24 cells at rows 17-20, columns 7-32.
BattleBox_WideArt:
	border 24, $B9
	border 24*2, $26
	border 24, $BE
	even

	if long_script_offsets==0
	error "battle_box needs long_script_offsets"
	endif
	if vwf_dialogue==0
	error "battle_box needs vwf_dialogue"
	endif

	endif

; =============================================================================
; status_messages: two battle messages the stock game lacks.
; =============================================================================
	if status_messages

; TechAction_Deban: in place of _bset #1, 0(a1) - the barrier that halves the
; damage a party member takes - with its message.
Status_Deband:
	bset	#1, (a1)
	move.w	#$122B, (battle_script_id).w	; "Defensive barrier up!"
	rts

; An enemy's TP drain (loc_3014): in place of move.w #0, 6(a1).
Status_TPDrain:
	move.w	#0, 6(a1)
	move.w	#$122C, (battle_script_id).w	; "TP drained!"
	rts

	if relocate_script==0
	error "status_messages needs relocate_script (two more messages in the battle bank)"
	endif

	endif

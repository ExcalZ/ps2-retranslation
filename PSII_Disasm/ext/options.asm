; =============================================================================
; field_options: Start on the field opens Options, as Phantasy Star IV's.
;
;	               Fast      Slow
;	 > Battle Speed   1 2 3 4 5
;	   Message Speed  1 2 3 4 5
;
; Up and down pick the setting, left and right change it, B, C or Start
; close the window. The current value's digit is drawn in yellow (palette 0,
; colour $C, $2EE on every map: the window font's ink is colour 1).
;
; Battle Speed, 1 (fast) to 5 (slow): 2 is the stock pace (the default).
;	speed			1	2	3	4	5
;	battle box hold		45	60	80	100	120	(BS_HoldK; the two-line box twice)
;	pop-up life		30	45	60	75	90	(BS_PopLife)
;	hit to next actor	~25	~33	+10	+20	+30	(BS_Frames)
; A hit's impact to the next actor's move is about 33 frames stock: the
; target's flash and the attacker's swing ending (~24), then the party's four
; stats windows drawn again (8) and the $8002 frame. At 1 that second drawing is
; skipped when nothing the windows show has changed since the impact drew them
; (BS_Redraw: a checksum taken in Popup_QueueWindows); the swing is not cut.
;
; Message Speed, 1 (fast) to 5 (slow): 3 is the stock letter a frame; 1 two
; letters a frame, 5 one every second frame (MS_Rate). A button still shows
; the rest of the page at once.
;
; The settings are saved with the game: two bytes of the saved party block
; that nothing else uses ($C696-$C697, after long_names' NAME_EXT), stored so
; that 0 is the default (older saves read as Battle 2, Message 3).
;
; Start opens the window only where C would open the field menu; elsewhere
; (a message up, a scene, another screen) it pauses as stock.
;
; The window is a new ID, $75 past the stock table: PM_Dispatch gives it its
; routines, BattleBox_Record its record. Its labels are WT_StaticRuns from
; work/script.json's options segment (tools/gentext.py).
; =============================================================================
	if field_options
	if party_menu_ps4==0
	error "field_options needs party_menu_ps4 for the window dispatch hook"
	endif
	if battle_box==0
	error "field_options needs battle_box for the window record and the box's hold"
	endif
	if vwf_windows==0
	error "field_options needs vwf_windows for its labels"
	endif

WinID_Options	= $75		; past the stock windows (the last is $74)

OPT_BATTLE	= $FFFFC696	; byte: (Battle Speed - 1) xor 1 (saved: 0 is 2)
OPT_MESSAGE	= $FFFFC697	; byte: (Message Speed - 1) xor 2 (saved: 0 is 3)
MS_ACC		= $FFFF8EF8	; word: quarters of a letter owed to the text
BS_WAIT		= $FFFF8EFA	; word: frames the fight waits before the next actor
BS_SNAP_OK	= $FFFF8EFC	; word: BS_SNAP was taken at this actor's impact
BS_SNAP		= $FFFF8FF2	; long: the stats windows' checksum when the impact queued them

OPT_COL		= 8		; the window's left border column (centred)
OPT_ROW		= 1		; its top border row
OPT_W		= 22		; cells inside the borders (work/script.json: options)
OPT_DIGIT	= 12		; the art column of the digit 1 (the others every second cell)
OPT_ENTRY0	= 2		; the art rows of the two settings
OPT_TILE	= $680		; five yellow digits: the dialogue ring (no message is up)
OPT_TILE_VDP	= $40000000|(((OPT_TILE*$20)&$3FFF)<<16)|((OPT_TILE*$20)>>14)
OPT_FONT_DIGIT	= $598		; the window font's 1 (the stat digits, $597 + n)
OPT_FONT_VDPR	= (((OPT_FONT_DIGIT*$20)&$3FFF)<<16)|((OPT_FONT_DIGIT*$20)>>14)	; VRAM read

; ---------------------------------------------------------------------------
; The settings, 0-4 (speed - 1); a byte out of range reads as the default.
; ---------------------------------------------------------------------------
OPT_GetBattle:
	moveq	#0, d0
	move.b	(OPT_BATTLE).w, d0
	eori.b	#1, d0
	cmpi.b	#4, d0
	bls.s	+
	moveq	#1, d0
+
	rts

OPT_GetMessage:
	moveq	#0, d0
	move.b	(OPT_MESSAGE).w, d0
	eori.b	#2, d0
	cmpi.b	#4, d0
	bls.s	+
	moveq	#2, d0
+
	rts

; The battle box's hold: d1 = the stock frames (60, 120 for two lines), scaled
; by BS_HoldK / 12.
OPT_HoldScale:
	move.l	d0, -(sp)
	bsr.s	OPT_GetBattle
	move.b	BS_HoldK(pc,d0.w), d0
	mulu.w	d0, d1
	divu.w	#12, d1
	swap	d1
	clr.w	d1			; (the remainder)
	swap	d1
	move.l	(sp)+, d0
	rts

BS_HoldK:				; twelfths of the stock hold, Battle Speed 1-5
	dc.b	9, 12, 16, 20, 24
	even

; d0 = a damage pop-up's frames (stock 45).
OPT_PopLife:
	bsr.s	OPT_GetBattle
	move.b	BS_PopLife(pc,d0.w), d0
	rts

BS_PopLife:
	dc.b	30, 45, 60, 75, 90
	even

; ---------------------------------------------------------------------------
; CheckGamePause (the hook replaces its first two instructions): Start on the
; field, where C would open the menu, opens Options instead of pausing.
; ---------------------------------------------------------------------------
OPT_Pause:
	tst.w	(paused_flag).w
	beq.s	+
	jmp	(CheckGamePause_Hold).l	; paused already
+
	cmpi.b	#ScreenID_Level, (game_screen).w
	bne.s	.stock
	btst	#ButtonStart, (joypad_pressed).w
	beq.s	.stock
	tst.w	(controls_locked).w	; the field is free, as ProcessPlayerMenu asks
	bne.s	.stock
	tst.w	($FFFFDE70).w
	bne.s	.stock
	tst.w	(window_index).w
	bne.s	.stock
	tst.w	(window_index_saved).w
	bne.s	.stock
	tst.w	(window_active_flag).w
	bne.s	.stock
	tst.w	(event_routine).w
	bne.s	.stock
	tst.w	(current_active_objects_num).w
	bne.s	.stock
	tst.w	(demo_flag).w
	bne.s	.stock
	tst.b	(event_flags).w
	bne.s	.stock
	tst.w	(screen_changed_flag).w
	bne.s	.stock
	move.b	#SXFID_Selection, (sound_queue).w
	move.w	#WinID_Options, (window_index).w
	rts
.stock:
	jmp	(CheckGamePause_Start).l

; ---------------------------------------------------------------------------
; The window. BattleBox_Record: its record (d0 = the window ID, a1 the base).
; ---------------------------------------------------------------------------
OPT_Record:
	cmpi.w	#WinID_Options, d0
	bne.s	+
	lea	(OPT_Layout-WinID_Options*8).l, a1
+
	rts

; PM_Dispatch: d1 = the window's routine (0 queued, 1 drawn, 2 every frame after).
OPT_Window:
	tst.w	d1
	beq.s	OPT_Prepare
	subq.w	#1, d1
	beq.w	OPT_Ready
	bra.w	OPT_Input

; Queued: the yellow digits 1-5, the font's with ink 1 made colour $C.
OPT_Prepare:
	clr.w	(MS_ACC).w
	movem.l	d0-d3/a0/a2-a3, -(sp)
	lea	(vdp_control_port).l, a2
	lea	(vdp_data_port).l, a3
	lea	-$A0(sp), sp		; the five tiles
	movea.l	sp, a0
	move	sr, -(sp)
	move	#$2700, sr
	move.w	#$8F02, (a2)		; a word at a time
	move.l	#OPT_FONT_VDPR, (a2)
	moveq	#5*16-1, d0
-
	move.w	(a3), (a0)+
	dbf	d0, -
	lea	-$A0(a0), a0
	move.w	#5*32-1, d0		; (past moveq's range)
-
	move.b	(a0), d1
	move.b	d1, d2
	andi.b	#$F0, d2
	cmpi.b	#$10, d2
	bne.s	+
	eori.b	#$D0, d1		; ink 1 -> $C
+
	move.b	d1, d2
	andi.b	#$0F, d2
	cmpi.b	#$01, d2
	bne.s	+
	eori.b	#$0D, d1
+
	move.b	d1, (a0)+
	dbf	d0, -
	lea	-$A0(a0), a0
	move.l	#OPT_TILE_VDP, (a2)
	moveq	#5*16-1, d0
-
	move.w	(a0)+, (a3)
	dbf	d0, -
	move	(sp)+, sr
	lea	$A0(sp), sp
	movem.l	(sp)+, d0-d3/a0/a2-a3
	rts

; Drawn: the values, then the cursor on Battle Speed.
OPT_Ready:
	moveq	#0, d4
	bsr.s	OPT_DrawRow
	moveq	#1, d4
	bsr.s	OPT_DrawRow
	moveq	#1, d0			; two entries
	move.w	#128+(OPT_COL+1)*8, d1
	move.w	#128+(OPT_ROW+OPT_ENTRY0)*8, d2
	jmp	(LoadCursorInWindows).l

; d4 = the setting (0 Battle, 1 Message): its five digits, the value's yellow.
OPT_DrawRow:
	movem.l	d0-d5/a0/a2-a3, -(sp)
	bsr.w	OPT_Get
	move.w	d0, d5			; the value, 0-4
	lea	($FFFFDF00).w, a0	; the window's entry: the top-left cell's address
	move.w	(current_active_objects_num).w, d0
	subq.w	#1, d0
	andi.w	#$F, d0
	lsl.w	#4, d0
	move.w	(a0,d0.w), d2
	add.w	d4, d4
	addq.w	#OPT_ENTRY0, d4		; the art row
	lsl.w	#7, d4
	add.w	d4, d2			; its row
	andi.w	#$EFFF, d2
	lea	(vdp_control_port).l, a2
	lea	(vdp_data_port).l, a3
	move	sr, -(sp)
	move	#$2700, sr
	moveq	#0, d3			; the digit, 0-4
-
	move.w	d3, d1			; its column: the left border, then the art's
	add.w	d1, d1
	addi.w	#OPT_DIGIT+1, d1
	add.w	d1, d1
	move.w	d2, d0
	andi.w	#$FF80, d0
	add.w	d2, d1
	andi.w	#$7F, d1		; across the plane's edge
	or.w	d1, d0
	move.w	d0, (a2)
	move.w	#3, (a2)
	move.w	#$8500|($98&$FF), d0	; the font's digit
	add.w	d3, d0
	cmp.w	d5, d3
	bne.s	+
	move.w	#$8000|OPT_TILE, d0	; the value: yellow
	add.w	d3, d0
+
	move.w	d0, (a3)
	addq.w	#1, d3
	cmpi.w	#5, d3
	bcs.s	-
	move	(sp)+, sr
	movem.l	(sp)+, d0-d5/a0/a2-a3
	rts

; d4 = the setting: d0 = its value, 0-4.
OPT_Get:
	tst.w	d4
	bne.w	OPT_GetMessage
	bra.w	OPT_GetBattle

; d4 = the setting, d0 = its new value.
OPT_Set:
	tst.w	d4
	bne.s	+
	eori.b	#1, d0
	move.b	d0, (OPT_BATTLE).w
	eori.b	#1, d0
	rts
+
	eori.b	#2, d0
	move.b	d0, (OPT_MESSAGE).w
	eori.b	#2, d0
	rts

; Every frame: left and right change the setting under the cursor; B, C or
; Start close the window.
OPT_Input:
	move.b	(joypad_pressed).w, d2
	moveq	#0, d4
	move.b	($FFFFDE50).w, d4	; the cursor's entry
	andi.w	#1, d4
	btst	#ButtonLeft, d2
	beq.s	.right
	bsr.s	OPT_Get
	subq.w	#1, d0
	bmi.s	.close_check
	bra.s	.set
.right:
	btst	#ButtonRight, d2
	beq.s	.close_check
	bsr.s	OPT_Get
	addq.w	#1, d0
	cmpi.w	#4, d0
	bhi.s	.close_check
.set:
	bsr.s	OPT_Set
	bsr.w	OPT_DrawRow
.close_check:
	andi.b	#Button_B_Mask|Button_C_Mask|ButtonStart_Mask, d2
	beq.s	.done
	move.b	#SXFID_Selection, (sound_queue).w
	bclr	#ButtonStart, (joypad_pressed).w	; not a pause next frame
	clr.w	(window_index_saved).w
	move.w	#$8001, (window_index).w
.done:
	rts

OPT_Layout:
	dc.w	$4000|(OPT_ROW<<7)|(OPT_COL*2)
	dc.l	OPT_Art
	dc.b	OPT_W+1, 5		; six rows

; The labels are WT_StaticRuns (work/script.json, options): the header (Fast,
; Slow) on row 1, the settings on rows 2 and 4. $26 is the blank tile, $98-$9C
; the digits 1-5.
OPT_Blanks macro n
	rept	n
	dc.b	$26
	endm
	endm
OPT_Setting macro
	dc.b	$B4, $B5		; the cursor's cells
	OPT_Blanks OPT_DIGIT-2
	dc.b	$98, $26, $99, $26, $9A, $26, $9B, $26, $9C
	OPT_Blanks OPT_W-OPT_DIGIT-9
	endm
OPT_Art:
	border OPT_W, $B9
	OPT_Blanks OPT_W
	OPT_Setting
	OPT_Blanks OPT_W
	OPT_Setting
	border OPT_W, $BE
OPT_ArtEnd:
	even

; ---------------------------------------------------------------------------
; Message Speed: CheckRunScript_Part2 (the hook replaces the stock loop: one
; letter a frame, all of the page once a button set $CD20). a1 = the text,
; a2/a3 the VDP ports.
; ---------------------------------------------------------------------------
MS_Run:
	tst.w	($FFFFCD20).w
	bne.s	MS_All
	move.l	d0, -(sp)
	bsr.w	OPT_GetMessage
	move.b	MS_Rate(pc,d0.w), d0
	add.w	d0, (MS_ACC).w
	move.l	(sp)+, d0
MS_Next:
	cmpi.w	#4, (MS_ACC).w
	bcs.s	MS_Done
	subq.w	#4, (MS_ACC).w
	jsr	(RunScript).l
	move.l	a1, (text_buffer_pointer).w
	tst.w	($FFFFCD20).w
	beq.s	MS_Next
MS_All:
	clr.w	(MS_ACC).w
-
	jsr	(RunScript).l
	move.l	a1, (text_buffer_pointer).w
	tst.w	($FFFFCD20).w
	bne.s	-
MS_Done:
	rts

MS_Rate:				; quarters of a letter a frame, Message Speed 1-5
	dc.b	8, 6, 4, 3, 2
	even

; ---------------------------------------------------------------------------
; Battle Speed: loc_F188 (the hook replaces its first two instructions) starts
; the next actor once the last one is done and the windows are drawn; it
; waits BS_WAIT frames first. BS_Arm (in place of the move.w #1, ($CC06)
; that marks an actor busy) sets the wait for the one after.
; ---------------------------------------------------------------------------
BS_Gap:
	tst.w	(BS_WAIT).w
	beq.s	+
	subq.w	#1, (BS_WAIT).w
	addq.l	#4, sp			; not this frame: back to loc_F188's caller
	rts
+
	lea	($FFFFCCA0).w, a0
	move.w	($FFFFCC90).w, d0
	rts

BS_Arm:
	move.w	#1, ($FFFFCC06).w
	clr.w	(BS_SNAP_OK).w		; its impact takes the checksum anew
	move.l	d0, -(sp)
	bsr.w	OPT_GetBattle
	move.b	BS_Frames(pc,d0.w), d0
	move.w	d0, (BS_WAIT).w
	move.l	(sp)+, d0
	rts

BS_Frames:				; Battle Speed 1-5
	dc.b	0, 0, 10, 20, 30
	even

; loc_F0C0 (the hook replaces the lea and the queue's first three entries):
; after each actor the stock queue closes two windows ($8002, nothing to do
; with none up) and draws the party's four stats windows again. At Battle
; Speed 1 they are not drawn again when the impact drew them and nothing they
; show has changed since. Leaves a1 past the entries queued.
BS_Redraw:
	lea	(window_index).w, a1
	bsr.w	OPT_GetBattle
	tst.w	(BS_SNAP_OK).w
	beq.s	BSR_all
	clr.w	(BS_SNAP_OK).w
	tst.w	d0
	bne.s	BSR_all
	bsr.s	BS_Checksum
	cmp.l	(BS_SNAP).l, d0
	bne.s	BSR_all
	tst.w	(current_active_objects_num).w
	beq.s	+
	move.w	#$8002, (a1)+
+
	rts
BSR_all:
	move.w	#$8002, (a1)+
	move.l	#((6<<$18)|(WinID_BattleFirstCharStats<<$10)|(6<<8)|WinID_BattleSecondCharStats), (a1)+
	move.l	#((6<<$18)|(WinID_BattleThirdCharStats<<$10)|(6<<8)|WinID_BattleFourthCharStats), (a1)+
	rts

; Popup_QueueWindows: the impact queues the stats windows; what they will show.
BS_Snapshot:
	move.l	d0, -(sp)
	bsr.s	BS_Checksum
	move.l	d0, (BS_SNAP).l
	move.w	#1, (BS_SNAP_OK).w
	move.l	(sp)+, d0
	rts

; d0 = a checksum of what the four stats windows are drawn from (loc_1095A):
; the party, each slot's character record and battle command.
BS_Checksum:
	movem.l	d1-d3/a0-a1, -(sp)
	moveq	#0, d0
	move.w	(party_members_num).w, d0
	lea	(party_member_id).w, a1
	moveq	#3, d3
BSC_member:
	move.w	(a1)+, d1
	andi.w	#7, d1
	add.w	d1, d0
	rol.l	#5, d0
	lea	(character_data_buffer).w, a0
	move.w	d1, d2
	lsl.w	#6, d2
	adda.w	d2, a0
	moveq	#$40/4-1, d2
-
	add.l	(a0)+, d0
	rol.l	#3, d0
	dbf	d2, -
	lea	(char_battle_command_index).w, a0
	lsl.w	#4, d1
	add.w	(a0,d1.w), d0
	rol.l	#1, d0
	dbf	d3, BSC_member
	movem.l	(sp)+, d1-d3/a0-a1
	rts
	endif

; =============================================================================
; battle_macros: the battle's commands as Phantasy Star IV's, and macros.
;
; The battle opens one window at the top left, under the first enemy's name:
;
;	Auto-Combat	the stock Fight: everyone repeats their command
;	Command		the stock Orders: pick a member, then their command
;	Macro		one of eight command sets, A-H
;	Retreat		the stock Retreat
;
; in place of Fight/Tactics and Orders/Retreat in the middle of the bottom row;
; the party's four windows stand side by side in that row instead, centred
; (columns 4, 12, 20 and 28), the member cursor with them. The window is on
; the stack while a choice is made and closed before the fight starts:
; Command closes it and reopens it once a member's command is set, as the
; stock reopened Fight/Tactics.
; The cursor starts on the last choice made in this battle.
;
; Macro opens the slots A-H beside it and, right of them, the commands of the
; slot under the cursor, one line a member: the name and Attack, Defend, a
; technique or an item. C on a set slot gives each member in the party their
; command from it and starts the fight, as Auto-Combat would; the members act
; in the stock order (by agility), not the macro's. B goes back to the menu.
;
; A slot's letter is red when the slot is empty, amber when it cannot be carried
; out as set: a member in it is not in the party, lacks the TP for its technique
; or no longer carries its item, the member a technique or item is for is not
; in the party, or a member in the party is not in it. The line of each such
; member is amber too (the view shows the macro's members, four at most: a
; party member it leaves out has no line). Used anyway, such a member attacks
; instead (the macro is not changed). An attack or a technique against enemies is aimed at the
; first group (the fight moves on to the second once the first is gone).
;
; On the field, the menu (Start's C menu) has a fifth entry, Macro: the same
; two windows. C on a slot: if it is set, "This macro will be erased" (Yes/No)
; first; then the members of the party are listed, and each picked is given a
; command - Attack, Technique (the battle list, with TP), Item (their own
; items), Defend; a technique or item used on a member asks for whom - and
; leaves the list, the slot's window showing the commands set so far. With
; everyone set, "This macro will be set" (Yes/No) saves it (No leaves the slot
; empty). B steps back a window; B on the member list gives up the macro.
;
; The macros are saved with the game: 8 slots x 4 words in the last 64 bytes
; of the save's copy of the copyright string ($C6C0-$C6FF), which the game
; only compares with the ROM's to tell a save is good - it compares the first
; 32 bytes now (loc_D6AA). A word: bit 15 set (used), 12-14 the member, 10-11
; the command (0 Attack, 1 Technique, 2 Item, 3 Defend), 3-9 the technique or
; item, 0-2 the member it is for. $C698 (saved, unused by the game) holds
; MAC_MAGIC once those bytes are macros: an older save, whose bytes there are
; the copyright string's, starts with none.
;
; Windows (IDs past the stock table and the other options'): the battle menu,
; the slots, the slot's commands (the view), and for the editor the member
; list, the command list and the target list. PM_Dispatch sends their routines
; here, BattleBox_Record their records (battle or field places). The view is
; under the slots on the stack (the slots take the input) and is redrawn in
; place, outside the stack, when the cursor moves: its tile range is reserved
; for its longest content when the slots open (MAC_Reserve). The editor uses
; the battle's technique and item lists (moved, their B taken here) and the
; field's Yes/No (B is No here).
;
; RAM: the view's and the slots' art in the shops' item list's buffer, the
; member list's in the save list's, the target list's in Rolf's house's
; profile list's - windows never up with these; each is put back from ROM when
; the macro windows close. The editor's state lives in the teleport list's
; buffer (that window copies its whole art from ROM when it opens).
; =============================================================================
	if battle_macros
	if party_menu_ps4==0
	error "battle_macros needs party_menu_ps4 (the window dispatch, the field menu)"
	endif
	if battle_box==0
	error "battle_macros needs battle_box (the window-record hook)"
	endif
	if vwf_windows==0
	error "battle_macros needs vwf_windows (the labels, the coloured runs)"
	endif
	if long_item_names==0
	error "battle_macros needs long_item_names (the names in the view)"
	endif
	if relocate_script==0
	error "battle_macros needs relocate_script (two messages added to the item bank)"
	endif

MAC_ID_FIRST	= $78			; past WinID_Options ($75) and shop_equip_compare ($76, $77)
BM_ID_MENU	= $78			; the battle's command window
MAC_ID_SLOTS	= $79			; A-H
MAC_ID_VIEW	= $7A			; the slot's commands
MAC_ID_MEMBERS	= $7B			; the editor: the members left to set
MAC_ID_CMDS	= $7C			; the editor: Attack, Technique, Item, Defend
MAC_ID_TARGET	= $7D			; the editor: whom a technique or item is for
MAC_ID_LAST	= $7D

MAC_DATA	= $FFFFC6C0		; 8 slots x 4 words (saved)
MAC_MAGIC_W	= $FFFFC698		; word (saved): MAC_MAGIC once MAC_DATA holds macros
MAC_MAGIC	= $4D38
MAC_MSG_ERASE	= $29			; the item bank's added messages
MAC_MSG_SET	= $2A

MAC_INK_AMBER	= 7			; window palette colours ($008E, $000E on the field and in battle)
MAC_INK_RED	= 8

; Unsaved state. MAC_EDIT and BM_LAST in RAM nothing else uses; the rest in
; the teleport list's art buffer (only valid while the macro windows are up).
MAC_EDIT	= $FFFF8BF8		; word: the field editor is up (the lists' places, B, Yes/No)
BM_LAST		= $FFFF8BFA		; word: the battle menu's last choice in this battle
BM_CHOICE	= $FFFF8BFC		; word: the battle menu's choice, -1 none
MAC_VARS	= window_art_buffer+WinArt_TeleportPlaceNames-DynamicWindowsStart
MAC_SLOT	= MAC_VARS+0		; word: the slot under the cursor
MAC_CHOICE	= MAC_VARS+2		; word: the entry a list was left on, -1 for B
MAC_BUILD	= MAC_VARS+4		; 4 words: the macro being set
MAC_COUNT	= MAC_VARS+12		; word: its entries
MAC_WHO		= MAC_VARS+14		; word: the member being set
MAC_CMD		= MAC_VARS+16		; word: their command
MAC_ARG		= MAC_VARS+18		; word: its technique or item
MAC_PICK	= MAC_VARS+20		; word: the member's entry in MAC_LEFT
MAC_LEFT	= MAC_VARS+22		; 4 words: the members not set yet
MAC_LEFTN	= MAC_VARS+30		; word: how many
MAC_BUILDING	= MAC_VARS+32		; word: the view shows MAC_BUILD, not the slot
MAC_FOCUS	= MAC_VARS+34		; word: the window the view's redraw gives the input back to
MAC_BASE	= MAC_VARS+36		; word: the stack's depth with the slots on top
MAC_ASK		= MAC_VARS+38		; word: the Yes/No asks to erase (0) or to set (1)
MAC_LINES	= MAC_VARS+40		; 4 x 6 and $FF: the view's lines: character.b, ink.b, command text.l
MAC_VARS_END	= MAC_LINES+4*6+1
	if MAC_VARS_END>window_art_buffer+WinArt_UstvestiaSoundtracks-DynamicWindowsStart
	error "battle_macros: the state does not fit the teleport list's buffer"
	endif

; The windows' sizes: W cells inside the borders, H rows with them.
MAC_VIEW_WB	= 15			; battle: name 4, a blank, the command 10
MAC_VIEW_WF	= 21			; field: on to the screen's edge, over the party panel
MAC_VIEW_WMAX	= 21
MAC_CMD_CELLS	= 10
MAC_VIEW_H	= 9			; four lines, two rows apart
MAC_SLOTS_W	= 3			; cursor 2, the letter
MAC_SLOTS_H	= 17
MAC_LIST_W	= 6			; cursor 2, the name 4
MAC_LIST_H	= 9
BM_W		= 10			; cursor 2, the label 8
BM_H		= 9
MAC_VIEW_ART	= window_art_buffer+WinArt_StoreInventory-DynamicWindowsStart
MAC_SLOTS_ART	= MAC_VIEW_ART+MAC_VIEW_WMAX*MAC_VIEW_H
MAC_SHOP_SIZE	= WinArt_ProfileCharList-WinArt_StoreInventory
MAC_MEMBERS_ART	= window_art_buffer+WinArt_SaveSlots-DynamicWindowsStart
MAC_SAVES_SIZE	= WinArt_StoreInventory-WinArt_SaveSlots
MAC_TARGET_ART	= window_art_buffer+WinArt_ProfileCharList-DynamicWindowsStart
MAC_PROFILES_SIZE = WinArt_RegroupCharList-WinArt_ProfileCharList
	if (MAC_VIEW_WMAX*MAC_VIEW_H+MAC_SLOTS_W*MAC_SLOTS_H>MAC_SHOP_SIZE)||(MAC_LIST_W*MAC_LIST_H>MAC_SAVES_SIZE)||(MAC_LIST_W*MAC_LIST_H>MAC_PROFILES_SIZE)
	error "battle_macros: a window's art does not fit its buffer"
	endif

; Places (left border column, top border row).
BM_COL		= 1			; under the first enemy's name (rows 1-4)
BM_ROW		= 5
MACB_SLOTS_COL	= 13			; battle: beside the menu
MACB_SLOTS_ROW	= 4
MACB_VIEW_COL	= 18
MACB_VIEW_ROW	= 5
MACF_SLOTS_COL	= 12			; field: beside the menu (columns 1-11)
MACF_SLOTS_ROW	= 1
MACF_VIEW_COL	= 17
MACF_VIEW_ROW	= 1
MACF_MEMBERS_COL = 17			; under the view
MACF_MEMBERS_ROW = 10
MACF_CMDS_COL	= 25
MACF_CMDS_ROW	= 10
MACF_TARGET_COL	= 32
MACF_TARGET_ROW	= 10
MACF_LIST_COL	= 17			; the technique and item lists (battle: columns 8 and 2, row 15)
MACF_LIST_ROW	= 10

MAC_Place macro col, row
	dc.w	$4000|((row)<<7)|((col)*2)
	endm
; In battle, plane A's rows 0-14 are the background, copied from RAM every
; frame (loc_5BB0): windows above row 15 are drawn on plane B, as the enemies'
; names are, their cells' priority over the background's.
MAC_PlaceB macro col, row
	dc.w	$6000|((row)<<7)|((col)*2)
	endm
MAC_CursorX	function col, 128+((col)+1)*8
MAC_CursorY	function row, 128+((row)+1)*8

; ---------------------------------------------------------------------------
; The battle's start (in place of the queue entry that drew Fight/Tactics).
; ---------------------------------------------------------------------------
BM_BattleStart:
	move.w	#0, (window_index+8).w
	clr.w	(BM_LAST).w
	clr.w	(MAC_EDIT).w
	move.w	#-1, (BM_CHOICE).w
	rts

; ---------------------------------------------------------------------------
; loc_978C, drawing a window (d0 = its VDP address, d5 = $8500): a window on
; plane B gets its frame without priority (the stock: the enemies' names), so
; that plane A's tiles - the battle's enemies - show in front of it. The macro
; windows keep it: their frames cover the enemies, as their cells do.
; ---------------------------------------------------------------------------
MAC_FrameBase:
	btst	#$D, d0
	beq.s	MACFB_done
	move.w	#$500, d5
	movem.l	d0/a0, -(sp)
	lea	($FFFFDF00+$E).w, a0	; the window being drawn: the slot past the stack
	move.w	(current_active_objects_num).w, d0
	andi.w	#$F, d0
	lsl.w	#4, d0
	cmpi.w	#MAC_ID_FIRST, (a0,d0.w)
	bcs.s	+
	move.w	#$8500, d5
+
	movem.l	(sp)+, d0/a0
MACFB_done:
	rts

; ---------------------------------------------------------------------------
; The battle's choosing routines (Battle_EventIndex_Standby; d1 = event_routine).
; 4 (a member to command) and 5 (their command) are the stock routines.
; ---------------------------------------------------------------------------
BM_Standby:
	cmpi.w	#4, d1
	bne.s	+
	jmp	(loc_EBBC).l
+
	cmpi.w	#5, d1
	bne.s	+
	jmp	(loc_EC5C).l
+
	subq.w	#1, d1
	cmpi.w	#(BM_RoutinesEnd-BM_Routines)/2, d1
	bcc.s	BM_None
	add.w	d1, d1
	move.w	BM_Routines(pc,d1.w), d1
	jmp	BM_Routines(pc,d1.w)
BM_None:
	rts
BM_Routines:
	dc.w	BM_Open-BM_Routines		; 1
	dc.w	BM_Chosen-BM_Routines		; 2
	dc.w	BM_Command-BM_Routines		; 3 (as stock: B on a member's commands comes back here)
	dc.w	BM_None-BM_Routines		; 4 (not reached)
	dc.w	BM_None-BM_Routines		; 5
	dc.w	BM_Fight-BM_Routines		; 6
	dc.w	BM_MacroChosen-BM_Routines	; 7
	dc.w	BM_Retreat-BM_Routines		; 8
BM_RoutinesEnd:

; 1: the menu.
BM_Open:
	move.w	#-1, (BM_CHOICE).w
	move.w	#BM_ID_MENU, (window_index).w
	move.w	#2, (event_routine).w
	rts

; 2: a choice made (the menu's input left window_index_saved 0), or B from
; choosing a member (the stock routine 4 steps back to 2 with the menu closed).
BM_Chosen:
	move.w	(BM_CHOICE).w, d0
	move.w	#-1, (BM_CHOICE).w
	tst.w	d0
	bmi.s	BM_Reopen
	cmpi.w	#2, d0
	beq.s	BM_Macro
	move.w	#$8001, (window_index).w	; the menu closes before the fight or the member cursor
	move.b	BM_Next(pc,d0.w), d0
	move.w	d0, (event_routine).w
	rts
BM_Reopen:
	move.w	#1, (event_routine).w
	rts
BM_Next:
	dc.b	6, 3, 0, 8			; Auto-Combat, Command, (Macro), Retreat
	even

; Macro: the view, then the slots over it.
BM_Macro:
	bsr.w	MAC_Ensure
	clr.w	(MAC_SLOT).w
	clr.w	(MAC_BUILDING).w
	clr.w	(MAC_FOCUS).w
	move.l	#(MAC_ID_VIEW<<16)|MAC_ID_SLOTS, (window_index).w
	move.w	#7, (event_routine).w
	rts

; 6: Auto-Combat (or a macro set): the menu is closed, the fight starts (the
; stock loc_EB52).
BM_Fight:
	move.w	#0, (event_routine).w
	move.b	#1, (battle_main_routine_index).w
	move.w	#1, (fight_active_flag).w
	rts

; 3: Command: the member cursor, as the stock loc_EB78's Orders. The stock
; routine 5 steps back here (subq #2) when B leaves a member's commands: the
; member cursor again.
BM_Command:
	lea	(object_ram).w, a0
	move.w	(current_active_objects_num).w, d3
	addq.w	#1, d3
	lsl.w	#6, d3
	adda.w	d3, a0
	move.w	#ObjID_CharSelectTriangleCursor, (a0)
	move.w	#0, $22(a0)
	move.w	(party_members_num).w, $32(a0)
	move.w	#$90, $A(a0)
	move.w	#$148, $E(a0)
	move.w	#4, (event_routine).w
	rts

; 7: a slot picked (or B).
BM_MacroChosen:
	tst.w	(MAC_CHOICE).w
	bmi.s	+
	move.w	(MAC_SLOT).w, d0
	bsr.w	MAC_Apply
	bsr.w	MAC_Release
	move.w	#$8003, (window_index).w	; the slots, the view and the menu
	move.w	#6, (event_routine).w
	rts
+
	bsr.w	MAC_Release
	move.w	#$8002, (window_index).w	; back to the menu
	move.w	#BM_ID_MENU, (window_index_saved).w
	move.w	#2, (window_routine).w
	move.w	#2, (event_routine).w
	rts

; 8: Retreat (the stock loc_EB78's Run).
BM_Retreat:
	move.w	#0, (event_routine).w
	move.b	#2, (battle_main_routine_index).w
	rts

; ---------------------------------------------------------------------------
; The field menu's entries (loc_9A20, in place of its first two instructions:
; d0 = the entry x 4 for the stock table). The fifth, Macro, is run here.
; ---------------------------------------------------------------------------
MAC_MenuEntry:
	move.w	($FFFFDE80).w, d0
	cmpi.w	#4, d0
	beq.s	+
	lsl.w	#2, d0
	rts
+
	addq.l	#4, sp			; not back to loc_9A20
	subq.w	#1, d1
	cmpi.w	#(MACF_RoutinesEnd-MACF_Routines)/2, d1
	bcc.s	MACF_None
	add.w	d1, d1
	move.w	MACF_Routines(pc,d1.w), d1
	jmp	MACF_Routines(pc,d1.w)
MACF_None:
	rts
MACF_Routines:
	dc.w	MACF_Open-MACF_Routines		; 1
	dc.w	MACF_Slot-MACF_Routines		; 2
	dc.w	MACF_Ask-MACF_Routines		; 3
	dc.w	MACF_Answer-MACF_Routines	; 4
	dc.w	MACF_None-MACF_Routines		; 5
	dc.w	MACF_Member-MACF_Routines	; 6
	dc.w	MACF_Command-MACF_Routines	; 7
	dc.w	MACF_Tech-MACF_Routines		; 8
	dc.w	MACF_Item-MACF_Routines		; 9
	dc.w	MACF_Target-MACF_Routines	; 10
	dc.w	MACF_Notice-MACF_Routines	; 11
MACF_RoutinesEnd:

; 1: the view, then the slots over it.
MACF_Open:
	bsr.w	MAC_Ensure
	move.w	#1, (MAC_EDIT).w
	clr.w	(MAC_SLOT).w
	clr.w	(MAC_BUILDING).w
	clr.w	(MAC_FOCUS).w
	move.l	#(MAC_ID_VIEW<<16)|MAC_ID_SLOTS, (window_index).w
	move.w	#2, (event_routine).w
	rts

; 2: a slot picked, or B: back to the menu.
MACF_Slot:
	tst.w	(MAC_CHOICE).w
	bpl.s	+
	bsr.w	MAC_Release
	clr.w	(MAC_EDIT).w
	move.w	#$8002, (window_index).w
	move.w	#WinID_PlayerMenu, (window_index_saved).w
	move.w	#2, (window_routine).w
	move.w	#1, (event_routine).w
	rts
+
	move.w	(current_active_objects_num).w, (MAC_BASE).w
	bsr.w	MAC_SlotAddr
	tst.w	(a2)
	bpl.w	MAC_StartBuild		; empty: set it
	clr.w	(MAC_ASK).w		; set: erase it first?
	move.w	#MAC_MSG_ERASE, (script_id).w
	move.w	#WinID_ScriptMessage, (window_index).w
	move.w	#3, (event_routine).w
	rts

; 3: the question has been shown: Yes/No.
MACF_Ask:
	move.w	#WinID_YesNo, (window_index).w
	move.w	#4, (event_routine).w
	rts

; 4: answered (B is No).
MACF_Answer:
	move.w	#$8002, (window_index).w	; the Yes/No and the message
	tst.w	(MAC_ASK).w
	bne.s	MACF_SetAnswer
	tst.w	(yes_no_input).w
	beq.s	+
	move.w	#MAC_ID_SLOTS, (window_index_saved).w	; No: the slots again
	move.w	#2, (window_routine).w
	move.w	#2, (event_routine).w
	rts
+
	bsr.w	MAC_SlotAddr		; Yes: erased, then set anew
	clr.l	(a2)+
	clr.l	(a2)
	bra.w	MAC_StartBuild
MACF_SetAnswer:
	tst.w	(yes_no_input).w
	bne.s	+
	bsr.w	MAC_SlotAddr		; Yes: saved
	move.l	(MAC_BUILD).w, (a2)+
	move.l	(MAC_BUILD+4).w, (a2)
+
	clr.w	(MAC_BUILDING).w
	clr.w	(MAC_FOCUS).w
	move.w	#(6<<8)|MAC_ID_VIEW, (window_index+2).w	; the slot's commands, its letter
	move.w	#(6<<8)|MAC_ID_SLOTS, (window_index+4).w
	move.w	#2, (event_routine).w
	rts

; Setting a slot: nothing set yet, every member of the party left. Leaves the
; queue after what window_index already holds: the view, the member list.
MAC_StartBuild:
	clr.l	(MAC_BUILD).w
	clr.l	(MAC_BUILD+4).w
	clr.w	(MAC_COUNT).w
	move.w	#1, (MAC_BUILDING).w
	lea	(party_member_id).w, a0
	lea	(MAC_LEFT).w, a1
	move.w	(party_members_num).w, d0
	andi.w	#3, d0
	move.w	d0, d1
	addq.w	#1, d1
	move.w	d1, (MAC_LEFTN).w
-
	move.w	(a0)+, d1
	andi.w	#7, d1
	move.w	d1, (a1)+
	dbf	d0, -
	clr.w	(MAC_FOCUS).w
	lea	(window_index).w, a0
-
	tst.w	(a0)+			; past what is queued
	bne.s	-
	move.w	#(6<<8)|MAC_ID_VIEW, -2(a0)	; the view: nothing set
	move.w	#MAC_ID_MEMBERS, (a0)
	move.w	#6, (event_routine).w
	rts

; 6: a member picked: their command. B: the macro is given up.
MACF_Member:
	move.w	(MAC_CHOICE).w, d0
	bpl.s	+
	clr.w	(MAC_BUILDING).w
	clr.w	(MAC_FOCUS).w
	move.w	#$8001, (window_index).w	; the member list
	move.w	#(6<<8)|MAC_ID_VIEW, (window_index+2).w
	move.w	#(6<<8)|MAC_ID_SLOTS, (window_index+4).w
	move.w	#2, (event_routine).w
	rts
+
	move.w	d0, (MAC_PICK).w
	add.w	d0, d0
	lea	(MAC_LEFT).w, a0
	move.w	(a0,d0.w), (MAC_WHO).w
	move.w	#MAC_ID_CMDS, (window_index).w
	move.w	#7, (event_routine).w
	rts

; 7: the command.
MACF_Command:
	move.w	(MAC_CHOICE).w, d0
	bpl.s	+
	move.w	#$8001, (window_index).w
	move.w	#MAC_ID_MEMBERS, (window_index_saved).w
	move.w	#2, (window_routine).w
	move.w	#6, (event_routine).w
	rts
+
	move.w	d0, (MAC_CMD).w
	moveq	#0, d2
	cmpi.w	#1, d0
	beq.s	MACF_TechList
	cmpi.w	#2, d0
	beq.s	MACF_ItemList
	moveq	#0, d3			; Attack, Defend: nothing more to ask
	bra.w	MAC_MemberDone
MACF_TechList:
	bsr.w	MAC_WhoRecord
	move.b	$25(a0), d1		; the battle techniques
	andi.w	#$1F, d1
	bne.s	+
	move.w	#$1207, d0		; none: "{NAME} has no Techniques!"
	bra.s	MACF_Tell
+
	move.w	(MAC_WHO).w, (character_index).w
	move.w	#0, ($FFFFDEEC).w	; the first page
	move.w	#WinID_BattleTechList, (window_index).w
	move.w	#8, (event_routine).w
	rts
MACF_ItemList:
	bsr.w	MAC_WhoRecord
	tst.b	$27(a0)			; the items carried
	bne.s	+
	move.w	#$23, d0		; none: "{NAME} isn't carrying anything."
	bra.s	MACF_Tell
+
	move.w	(MAC_WHO).w, (character_index).w
	move.w	#0, ($FFFFDEEE).w
	move.w	#WinID_BattleItemList, (window_index).w
	move.w	#9, (event_routine).w
	rts
MACF_Again:
	move.w	#MAC_ID_CMDS, (window_index_saved).w
	move.w	#2, (window_routine).w
	rts
; d0 = a message about the member being set; then the command list again (11).
MACF_Tell:
	move.w	(MAC_WHO).w, (character_index).w
	move.w	d0, (script_id).w
	move.w	#WinID_ScriptMessage, (window_index).w
	move.w	#11, (event_routine).w
	rts

; 11: the message has been read: it closes, the command list again.
MACF_Notice:
	move.w	#$8001, (window_index).w
	move.w	#7, (event_routine).w
	bra.s	MACF_Again

; 8: a technique picked (technique_index), or B.
MACF_Tech:
	tst.w	(MAC_CHOICE).w
	bpl.s	+
MACF_ListBack:
	move.w	#$8001, (window_index).w
	move.w	#7, (event_routine).w
	bra.s	MACF_Again
+
	moveq	#0, d2
	move.b	(technique_index).w, d2
	andi.w	#$3F, d2
	move.w	d2, (MAC_ARG).w
	bsr.w	MAC_TechForMember
	beq.s	MACF_NoTarget
	bra.s	MACF_AskTarget

; 9: an item picked (item_index), or B.
MACF_Item:
	tst.w	(MAC_CHOICE).w
	bmi.s	MACF_ListBack
	moveq	#0, d2
	move.b	(item_index).w, d2
	andi.w	#$7F, d2
	move.w	d2, (MAC_ARG).w
	bsr.w	MAC_ItemForMember
	beq.s	MACF_NoTarget
MACF_AskTarget:
	move.w	#MAC_ID_TARGET, (window_index).w
	move.w	#10, (event_routine).w
	rts
MACF_NoTarget:
	move.w	(MAC_CMD).w, d0
	moveq	#0, d3
	bra.s	MAC_MemberDone

; 10: whom it is for, or B: the list again.
MACF_Target:
	move.w	(MAC_CHOICE).w, d0
	bmi.s	MACF_TargetBack
	add.w	d0, d0
	lea	(party_member_id).w, a0
	move.w	(a0,d0.w), d3
	andi.w	#7, d3
	move.w	(MAC_CMD).w, d0
	move.w	(MAC_ARG).w, d2
	bra.s	MAC_MemberDone
MACF_TargetBack:
	move.w	#$8001, (window_index).w
	move.w	#2, (window_routine).w
	cmpi.w	#1, (MAC_CMD).w
	bne.s	+
	move.w	#WinID_BattleTechList, (window_index_saved).w
	move.w	#8, (event_routine).w
	rts
+
	move.w	#WinID_BattleItemList, (window_index_saved).w
	move.w	#9, (event_routine).w
	rts

; A member's command (d0), its technique or item (d2) and target (d3) are
; set: the member leaves the list; the windows above the slots close, the view
; shows the macro so far; the list again, or with everyone set, the question.
MAC_MemberDone:
	move.w	(MAC_WHO).w, d1
	lsl.w	#2, d1
	or.w	d1, d0			; the member and the command: bits 12-14, 10-11
	lsl.w	#8, d0
	lsl.w	#2, d0
	lsl.w	#3, d2
	or.w	d2, d0
	or.w	d3, d0
	ori.w	#$8000, d0
	lea	(MAC_BUILD).w, a0
	move.w	(MAC_COUNT).w, d1
	add.w	d1, d1
	move.w	d0, (a0,d1.w)
	addq.w	#1, (MAC_COUNT).w
	lea	(MAC_LEFT).w, a0	; out of the list
	move.w	(MAC_PICK).w, d0
	add.w	d0, d0
	adda.w	d0, a0
	moveq	#3, d1
	sub.w	(MAC_PICK).w, d1
	bra.s	+
-
	move.w	2(a0), (a0)+
+
	dbf	d1, -
	subq.w	#1, (MAC_LEFTN).w
	move.w	(current_active_objects_num).w, d0
	sub.w	(MAC_BASE).w, d0
	ori.w	#$8000, d0
	move.w	d0, (window_index).w	; down to the slots
	clr.w	(MAC_FOCUS).w
	move.w	#(6<<8)|MAC_ID_VIEW, (window_index+2).w
	tst.w	(MAC_LEFTN).w
	beq.s	+
	move.w	#MAC_ID_MEMBERS, (window_index+4).w
	move.w	#6, (event_routine).w
	rts
+
	move.w	#1, (MAC_ASK).w
	move.w	#MAC_MSG_SET, (script_id).w
	move.w	#WinID_ScriptMessage, (window_index+4).w
	move.w	#3, (event_routine).w
	rts

; a0 = the record of the member being set.
MAC_WhoRecord:
	lea	(character_data_buffer).w, a0
	move.w	(MAC_WHO).w, d1
	lsl.w	#6, d1
	adda.w	d1, a0
	rts

; d2 = a technique: Z clear if it is used on a member (the stock loc_ED96: the
; byte after its cost, low bits not 0, bit 7 clear).
MAC_TechForMember:
	move.l	a0, -(sp)
	lea	(TechniqueData+6).l, a0
	move.w	d2, d0
	lsl.w	#3, d0
	move.b	(a0,d0.w), d0
	bmi.s	+			; an enemy group
	andi.b	#3, d0
	movea.l	(sp)+, a0
	rts
+
	movea.l	(sp)+, a0
	ori.b	#4, ccr
	rts

; d2 = an item: Z clear if it is used on a member (the stock CommandAction_Item).
MAC_ItemForMember:
	cmpi.w	#ItemID_MoonDew, d2
	beq.s	+
	cmpi.w	#ItemID_Monomate, d2
	bcs.s	++
	cmpi.w	#ItemID_Antidote, d2
	bhi.s	++
+
	andi.b	#$FB, ccr
	rts
+
	ori.b	#4, ccr
	rts

; a2 = the slot MAC_SLOT's four words.
MAC_SlotAddr:
	lea	(MAC_DATA).w, a2
	move.w	(MAC_SLOT).w, d0
	andi.w	#7, d0
	lsl.w	#3, d0
	adda.w	d0, a2
	rts

; ---------------------------------------------------------------------------
; The save.
; ---------------------------------------------------------------------------
; A new game (in place of the copy of the copyright string to $C6A0): its first
; 32 bytes, then no macros.
MAC_NewGame:
	lea	(CopyrightString).l, a0
	lea	($FFFFC6A0).w, a1
	moveq	#32/4-1, d0
-
	move.l	(a0)+, (a1)+
	dbf	d0, -
	bra.s	MAC_Clear

; The macros are in MAC_DATA (an older save: none yet).
MAC_Ensure:
	cmpi.w	#MAC_MAGIC, (MAC_MAGIC_W).w
	beq.s	+
MAC_Clear:
	lea	(MAC_DATA).w, a0
	moveq	#64/4-1, d0
-
	clr.l	(a0)+
	dbf	d0, -
	move.w	#MAC_MAGIC, (MAC_MAGIC_W).w
+
	rts

; ---------------------------------------------------------------------------
; The checks.
; ---------------------------------------------------------------------------
; d0 = a character: Z clear if it is in the party (d1 is used).
MAC_InParty:
	movem.l	d2/a0, -(sp)
	lea	(party_member_id).w, a0
	move.w	(party_members_num).w, d2
	andi.w	#3, d2
-
	move.w	(a0)+, d1
	andi.w	#7, d1
	cmp.w	d0, d1
	beq.s	+
	dbf	d2, -
	movem.l	(sp)+, d2/a0
	ori.b	#4, ccr
	rts
+
	movem.l	(sp)+, d2/a0
	andi.b	#$FB, ccr
	rts

; d0 = a macro word: Z set if it can be carried out as set.
MAC_EntryOK:
	movem.l	d0-d4/a0-a1, -(sp)
	move.w	d0, d3
	lsr.w	#8, d0
	lsr.w	#4, d0
	andi.w	#7, d0			; the member
	bsr.s	MAC_InParty
	beq.s	MACOK_no
	lea	(character_data_buffer).w, a0
	lsl.w	#6, d0
	adda.w	d0, a0
	move.w	d3, d2
	lsr.w	#3, d2
	andi.w	#$7F, d2		; the technique or item
	move.w	d3, d4
	lsr.w	#8, d4
	lsr.w	#2, d4
	andi.w	#3, d4			; the command
	cmpi.w	#1, d4
	beq.s	MACOK_tech
	cmpi.w	#2, d4
	beq.s	MACOK_item
MACOK_yes:
	movem.l	(sp)+, d0-d4/a0-a1
	ori.b	#4, ccr
	rts
MACOK_no:
	movem.l	(sp)+, d0-d4/a0-a1
	andi.b	#$FB, ccr
	rts
MACOK_tech:
	andi.w	#$3F, d2
	move.w	d2, d0
	lsl.w	#3, d0
	lea	(TechniqueData+5).l, a1
	moveq	#0, d1
	move.b	(a1,d0.w), d1		; its TP
	cmp.w	6(a0), d1
	bhi.s	MACOK_no
	bsr.w	MAC_TechForMember
	beq.s	MACOK_yes
	bra.s	MACOK_target
MACOK_item:
	moveq	#0, d1
	move.b	$27(a0), d1		; the items carried
	beq.s	MACOK_no
	subq.w	#1, d1
	lea	$28(a0), a1
-
	move.b	(a1)+, d0
	andi.w	#$7F, d0
	cmp.w	d2, d0
	beq.s	+
	dbf	d1, -
	bra.s	MACOK_no
+
	bsr.w	MAC_ItemForMember
	beq.s	MACOK_yes
MACOK_target:
	move.w	d3, d0
	andi.w	#7, d0			; the member it is for
	bsr.w	MAC_InParty
	beq.s	MACOK_no
	bra.s	MACOK_yes

; a2 = four macro words, d0 = a character: Z clear if the macro has them.
MAC_Has:
	movem.l	d1-d2/a2, -(sp)
	moveq	#3, d2
-
	move.w	(a2)+, d1
	bpl.s	+			; past the last
	lsr.w	#8, d1
	lsr.w	#4, d1
	andi.w	#7, d1
	cmp.w	d0, d1
	beq.s	++
	dbf	d2, -
+
	movem.l	(sp)+, d1-d2/a2
	ori.b	#4, ccr
	rts
+
	movem.l	(sp)+, d1-d2/a2
	andi.b	#$FB, ccr
	rts

; a2 = a slot: d0 = 0 if it can be carried out as set, MAC_INK_AMBER if not,
; MAC_INK_RED if it is empty.
MAC_SlotInk:
	movem.l	d1-d2/a0/a2, -(sp)
	moveq	#MAC_INK_RED, d0
	tst.w	(a2)
	bpl.s	MACSI_done
	moveq	#3, d2
	movea.l	a2, a0
-
	move.w	(a0)+, d0
	bpl.s	+
	bsr.w	MAC_EntryOK
	bne.s	MACSI_amber
	dbf	d2, -
+
	lea	(party_member_id).w, a0	; every member in it
	move.w	(party_members_num).w, d2
	andi.w	#3, d2
-
	move.w	(a0)+, d0
	andi.w	#7, d0
	bsr.s	MAC_Has
	beq.s	MACSI_amber
	dbf	d2, -
	moveq	#0, d0
	bra.s	MACSI_done
MACSI_amber:
	moveq	#MAC_INK_AMBER, d0
MACSI_done:
	movem.l	(sp)+, d1-d2/a0/a2
	rts

; ---------------------------------------------------------------------------
; Using a macro (d0 = the slot): each member of the party is given their
; command from it, or Attack where the macro has none for them or cannot be
; carried out (char_battle_command_index: the command, the technique or item,
; the target - a member, or 0: the first enemy group).
; ---------------------------------------------------------------------------
MAC_Apply:
	movem.l	d0-d4/a0-a2, -(sp)
	lea	(MAC_DATA).w, a2
	andi.w	#7, d0
	lsl.w	#3, d0
	adda.w	d0, a2
	lea	(party_member_id).w, a1
	move.w	(party_members_num).w, d4
	andi.w	#3, d4
MACA_member:
	move.w	(a1)+, d1
	andi.w	#7, d1			; the member
	bsr.w	MAC_Find		; d0 = their word in the macro
	beq.s	+			; none: Attack
	bsr.w	MAC_EntryOK
	beq.s	++
+
	moveq	#0, d0
+
	lea	(char_battle_command_index).w, a0
	move.w	d1, d2
	lsl.w	#4, d2
	adda.w	d2, a0
	move.w	d0, d3
	bsr.w	MAC_Fields		; d0 command, d2 technique or item
	move.w	d0, (a0)+
	move.w	d2, (a0)+
	bsr.w	MAC_TargetOf
	move.w	d0, (a0)
	dbf	d4, MACA_member
	movem.l	(sp)+, d0-d4/a0-a2
	rts

; a2 = a slot, d1 = a character: d0 = the slot's word for them, Z clear; or 0,
; Z set.
MAC_Find:
	movem.l	d2-d3/a0, -(sp)
	movea.l	a2, a0
	moveq	#3, d2
-
	move.w	(a0)+, d0
	bpl.s	+			; past the last
	move.w	d0, d3
	lsr.w	#8, d3
	lsr.w	#4, d3
	andi.w	#7, d3
	cmp.w	d1, d3
	beq.s	++
	dbf	d2, -
+
	moveq	#0, d0
	movem.l	(sp)+, d2-d3/a0
	rts
+
	movem.l	(sp)+, d2-d3/a0
	tst.w	d0			; (bit 15: Z clear)
	rts

; d3 = a macro word (0: Attack): d0 = the command, d2 = the technique or item.
MAC_Fields:
	moveq	#0, d0
	moveq	#0, d2
	tst.w	d3
	bpl.s	+
	move.w	d3, d0
	lsr.w	#8, d0
	lsr.w	#2, d0
	andi.w	#3, d0
	move.w	d3, d2
	lsr.w	#3, d2
	andi.w	#$7F, d2
+
	rts

; d3 = a macro word: d0 = the member its technique or item is for, or 0 (the
; first enemy group, or no target).
MAC_TargetOf:
	movem.l	d1-d2, -(sp)
	bsr.s	MAC_Fields
	move.w	d0, d1
	cmpi.w	#1, d1
	bne.s	+
	bsr.w	MAC_TechForMember
	bra.s	++
+
	cmpi.w	#2, d1
	bne.s	MACT_none
	bsr.w	MAC_ItemForMember
+
	beq.s	MACT_none
	move.w	d3, d0
	andi.w	#7, d0
	bra.s	+
MACT_none:
	moveq	#0, d0
+
	movem.l	(sp)+, d1-d2
	rts

; ---------------------------------------------------------------------------
; The windows' records (BattleBox_Record: d0 = the window ID, a1 = the base
; ProcessWindows adds ID x 8 to).
; ---------------------------------------------------------------------------
MAC_Record:
	cmpi.w	#MAC_ID_FIRST, d0
	bcs.s	MACR_lists
	cmpi.w	#MAC_ID_LAST, d0
	bhi.s	MACR_done
	move.l	d1, -(sp)
	lea	(MAC_FieldLayouts-MAC_ID_FIRST*8).l, a1
	cmpi.b	#ScreenID_Battle, (game_screen).w
	bne.s	+
	lea	(MAC_BattleLayouts-MAC_ID_FIRST*8).l, a1
+
	move.l	(sp)+, d1
MACR_done:
	rts
MACR_lists:				; the editor's technique and item lists
	bsr.w	MAC_Editing
	beq.s	MACR_done
	cmpi.w	#WinID_BattleTechList, d0
	bne.s	+
	lea	(MAC_TechLayout-WinID_BattleTechList*8).l, a1
+
	cmpi.w	#WinID_BattleItemList, d0
	bne.s	MACR_done
	lea	(MAC_ItemLayout-WinID_BattleItemList*8).l, a1
	rts

; A record: place, art, width + 1 (inside the borders), height - 1.
MAC_BattleLayouts:
	MAC_PlaceB BM_COL, BM_ROW
	dc.l	BM_Art
	dc.b	BM_W+1, BM_H-1
	MAC_PlaceB MACB_SLOTS_COL, MACB_SLOTS_ROW
	dc.l	MAC_SLOTS_ART&$FFFFFF
	dc.b	MAC_SLOTS_W+1, MAC_SLOTS_H-1
	MAC_PlaceB MACB_VIEW_COL, MACB_VIEW_ROW
	dc.l	MAC_VIEW_ART&$FFFFFF
	dc.b	MAC_VIEW_WB+1, MAC_VIEW_H-1
	MAC_Place MACF_MEMBERS_COL, MACF_MEMBERS_ROW	; (the editor's: not in battle)
	dc.l	MAC_MEMBERS_ART&$FFFFFF
	dc.b	MAC_LIST_W+1, MAC_LIST_H-1
	MAC_Place MACF_CMDS_COL, MACF_CMDS_ROW
	dc.l	MAC_CmdArt
	dc.b	BM_W+1, BM_H-1
	MAC_Place MACF_TARGET_COL, MACF_TARGET_ROW
	dc.l	MAC_TARGET_ART&$FFFFFF
	dc.b	MAC_LIST_W+1, MAC_LIST_H-1
MAC_FieldLayouts:
	MAC_Place BM_COL, BM_ROW		; (the battle's: not on the field)
	dc.l	BM_Art
	dc.b	BM_W+1, BM_H-1
	MAC_Place MACF_SLOTS_COL, MACF_SLOTS_ROW
	dc.l	MAC_SLOTS_ART&$FFFFFF
	dc.b	MAC_SLOTS_W+1, MAC_SLOTS_H-1
	MAC_Place MACF_VIEW_COL, MACF_VIEW_ROW
	dc.l	MAC_VIEW_ART&$FFFFFF
	dc.b	MAC_VIEW_WF+1, MAC_VIEW_H-1
	MAC_Place MACF_MEMBERS_COL, MACF_MEMBERS_ROW
	dc.l	MAC_MEMBERS_ART&$FFFFFF
	dc.b	MAC_LIST_W+1, MAC_LIST_H-1
	MAC_Place MACF_CMDS_COL, MACF_CMDS_ROW
	dc.l	MAC_CmdArt
	dc.b	BM_W+1, BM_H-1
	MAC_Place MACF_TARGET_COL, MACF_TARGET_ROW
	dc.l	MAC_TARGET_ART&$FFFFFF
	dc.b	MAC_LIST_W+1, MAC_LIST_H-1
MAC_TechLayout:				; the battle's list, under the view
	MAC_Place MACF_LIST_COL, MACF_LIST_ROW
	if wide_techs
	dc.l	TW_ART&$FFFFFF
	dc.b	TW_BATTLE_W+1, $09
	else
	dc.l	(window_art_buffer&$FFFFFF)+WinArt_BattleTechList-DynamicWindowsStart
	dc.b	$08, $09
	endif
MAC_ItemLayout:
	MAC_Place MACF_LIST_COL, MACF_LIST_ROW
	dc.l	(window_art_buffer&$FFFFFF)+WinArt_BattleItemList-DynamicWindowsStart
	dc.b	$0E, $09

; LoadCursorInWindows (d1 = X, d2 = Y, from PM_CursorPlace): the editor's
; technique and item lists are moved from their battle places.
MAC_CursorPlace:
	bsr.w	MAC_Editing
	beq.s	+
	cmpi.w	#WinID_BattleTechList, (window_index_saved).w
	bne.s	++
	addi.w	#(MACF_LIST_COL-8)*8, d1
	subi.w	#(15-MACF_LIST_ROW)*8, d2
+
	rts
+
	cmpi.w	#WinID_BattleItemList, (window_index_saved).w
	bne.s	+
	addi.w	#(MACF_LIST_COL-2)*8, d1
	subi.w	#(15-MACF_LIST_ROW)*8, d2
+
	rts

; ---------------------------------------------------------------------------
; The windows' routines (PM_Dispatch: d0 = the window ID, d1 = the routine: 0
; queued, 1 drawn, 2 every frame after).
; ---------------------------------------------------------------------------
MAC_Window:
	cmpi.w	#MAC_ID_LAST, d0
	bhi.s	MACW_none
	subi.w	#MAC_ID_FIRST, d0
	add.w	d0, d0
	move.w	MACW_Index(pc,d0.w), d0
	jmp	MACW_Index(pc,d0.w)
MACW_none:
	rts
MACW_Index:
	dc.w	BM_Window-MACW_Index
	dc.w	MAC_SlotsWindow-MACW_Index
	dc.w	MAC_ViewWindow-MACW_Index
	dc.w	MAC_MembersWindow-MACW_Index
	dc.w	MAC_CmdsWindow-MACW_Index
	dc.w	MAC_TargetWindow-MACW_Index

; PM_Dispatch, for the stock windows while the editor is up: the technique and
; item lists take B here (the stock goes back to the battle's commands), and
; the Yes/No takes B as No (the stock closes it and the question). Z set if
; the window is not one of them (PM_Dispatch goes on).
MAC_EditWindow:
	cmpi.w	#2, d1
	bne.s	MACE_not
	bsr.s	MAC_Editing
	beq.s	MACE_not
	cmpi.w	#WinID_YesNo, d0
	beq.s	MACE_yesno
	cmpi.w	#WinID_BattleTechList, d0
	beq.s	+
	cmpi.w	#WinID_BattleItemList, d0
	bne.s	MACE_not
+
	btst	#Button_B, (joypad_pressed).w
	bne.s	MACE_back
	clr.w	(MAC_CHOICE).w		; C: the stock takes it (technique_index, item_index)
MACE_not:
	ori.b	#4, ccr
	rts
MACE_back:
	move.b	#SXFID_Selection, (sound_queue).w
	move.w	#-1, (MAC_CHOICE).w
	clr.w	(window_index_saved).w
	andi.b	#$FB, ccr
	rts
MACE_yesno:
	btst	#Button_B, (joypad_pressed).w
	beq.s	MACE_not
	move.b	#SXFID_Selection, (sound_queue).w
	move.w	#1, (yes_no_input).w
	clr.w	(window_index_saved).w
	andi.b	#$FB, ccr
	rts

; Z clear while the field editor is up: MAC_EDIT, and the slots on the stack
; (a flag left over by a reset in the editor is not trusted).
MAC_Editing:
	tst.w	(MAC_EDIT).w
	beq.s	MACED_no
	movem.l	d0/a0, -(sp)
	lea	($FFFFDF00+$E).w, a0	; each stacked window's ID
	move.w	(current_active_objects_num).w, d0
	andi.w	#$F, d0
	bra.s	+
-
	cmpi.w	#MAC_ID_SLOTS, (a0)
	beq.s	MACED_yes
	lea	$10(a0), a0
+
	dbf	d0, -
	movem.l	(sp)+, d0/a0
MACED_no:
	ori.b	#4, ccr
	rts
MACED_yes:
	movem.l	(sp)+, d0/a0
	andi.b	#$FB, ccr
	rts

; A list's input: C leaves the entry under the cursor in MAC_CHOICE, B -1; the
; window then gives up the input (window_index_saved 0) to the event routines.
MAC_ListInput:
	move.b	(joypad_pressed).w, d0
	btst	#Button_C, d0
	bne.s	+
	btst	#Button_B, d0
	beq.s	MACL_done
	move.w	#-1, d0
	bra.s	++
+
	bsr.s	MAC_CursorEntry
+
	move.w	d0, (MAC_CHOICE).w
	move.b	#SXFID_Selection, (sound_queue).w
	clr.w	(window_index_saved).w
MACL_done:
	rts

; d0 = the entry under the top window's cursor.
MAC_CursorEntry:
	move.l	a0, -(sp)
	lea	(object_ram).w, a0
	move.w	(current_active_objects_num).w, d0
	subq.w	#1, d0
	andi.w	#$F, d0
	lsl.w	#6, d0
	adda.w	d0, a0
	moveq	#0, d0
	move.b	$32(a0), d0
	movea.l	(sp)+, a0
	rts

; The battle menu: fixed art, its labels WT_StaticRuns (work/script.json).
BM_Window:
	tst.w	d1
	beq.s	MACL_done
	subq.w	#1, d1
	bne.s	+
	moveq	#3, d0
	move.w	#MAC_CursorX(BM_COL), d1
	move.w	#MAC_CursorY(BM_ROW), d2
	jsr	(LoadCursorInWindows).l
	move.b	(BM_LAST+1).w, $32(a0)	; on the last choice
	rts
+
	btst	#Button_C, (joypad_pressed).w
	beq.s	MACL_done
	move.b	#SXFID_Selection, (sound_queue).w
	bsr.s	MAC_CursorEntry
	move.w	d0, (BM_LAST).w
	move.w	d0, (BM_CHOICE).w
	clr.w	(window_index_saved).w
	rts

; The editor's command list: fixed art, labels in WT_StaticRuns.
MAC_CmdsWindow:
	tst.w	d1
	beq.s	MACL_done
	subq.w	#1, d1
	bne.w	MAC_ListInput
	moveq	#3, d0
	move.w	#MAC_CursorX(MACF_CMDS_COL), d1
	move.w	#MAC_CursorY(MACF_CMDS_ROW), d2
	jmp	(LoadCursorInWindows).l

; The member list: the members not set yet. The target list: the party.
MAC_MembersWindow:
	lea	(MAC_LEFT).w, a2
	move.w	(MAC_LEFTN).w, d2
	lea	(MAC_MEMBERS_ART).w, a1
	move.w	#MACF_MEMBERS_COL, d3
	bra.s	MAC_NamesWindow
MAC_TargetWindow:
	lea	(party_member_id).w, a2
	move.w	(party_members_num).w, d2
	andi.w	#3, d2
	addq.w	#1, d2
	lea	(MAC_TARGET_ART).w, a1
	move.w	#MACF_TARGET_COL, d3
; a2 = the members (words), d2 = how many, a1 = the art, d3 = the column.
MAC_NamesWindow:
	tst.w	d1
	beq.s	MACN_art
	subq.w	#1, d1
	bne.w	MAC_ListInput
	move.w	d2, d0
	subq.w	#1, d0
	move.w	d3, d1
	addq.w	#1, d1
	lsl.w	#3, d1
	addi.w	#128, d1
	move.w	#MAC_CursorY(MACF_MEMBERS_ROW), d2
	jmp	(LoadCursorInWindows).l
MACN_art:
	move.w	#MAC_LIST_W*MAC_LIST_H, d0
	jsr	(PM_ForgetRuns).l
	movea.l	a1, a0
	moveq	#MAC_LIST_W-1, d0
-
	move.b	#$B9, (a0)+		; the top border
	dbf	d0, -
	moveq	#0, d1			; the entry
MACN_row:
	cmp.w	d2, d1
	bcc.s	MACN_blank
	move.b	#$B4, (a0)+		; the cursor's cells
	move.b	#$B5, (a0)+
	move.w	d1, d0
	add.w	d0, d0
	move.w	(a2,d0.w), d0
	andi.w	#7, d0
	addi.w	#$81, d0		; the name's marker (ext/wintext.asm)
	moveq	#4-1, d3
-
	move.b	d0, (a0)+
	dbf	d3, -
	bra.s	MACN_gap
MACN_blank:
	moveq	#MAC_LIST_W-1, d3
-
	move.b	#$26, (a0)+
	dbf	d3, -
MACN_gap:
	addq.w	#1, d1
	cmpi.w	#4, d1
	bcc.s	+
	moveq	#MAC_LIST_W-1, d3	; the row between two entries
-
	move.b	#$26, (a0)+
	dbf	d3, -
	bra.s	MACN_row
+
	moveq	#MAC_LIST_W-1, d0
-
	move.b	#$BE, (a0)+		; the bottom border
	dbf	d0, -
	rts

; ---------------------------------------------------------------------------
; The slots: A-H, each letter a run in its colour (red: empty, amber: cannot
; be carried out as set).
; ---------------------------------------------------------------------------
MAC_SlotsWindow:
	tst.w	d1
	beq.s	MACS_art
	subq.w	#1, d1
	bne.s	MACS_input
	moveq	#7, d0
	move.w	#MAC_CursorX(MACF_SLOTS_COL), d1
	move.w	#MAC_CursorY(MACF_SLOTS_ROW), d2
	cmpi.b	#ScreenID_Battle, (game_screen).w
	bne.s	+
	move.w	#MAC_CursorX(MACB_SLOTS_COL), d1
	move.w	#MAC_CursorY(MACB_SLOTS_ROW), d2
+
	jsr	(LoadCursorInWindows).l
	move.b	(MAC_SLOT+1).w, $32(a0)	; on the slot shown
	rts
MACS_input:
	bsr.w	MAC_CursorEntry
	cmp.w	(MAC_SLOT).w, d0
	beq.s	+
	move.w	d0, (MAC_SLOT).w	; another slot: the view shows it
	move.w	#MAC_ID_SLOTS, (MAC_FOCUS).w
	move.w	#(6<<8)|MAC_ID_VIEW, (window_index).w
	rts
+
	cmpi.b	#ScreenID_Battle, (game_screen).w
	bne.w	MAC_ListInput
	btst	#Button_C, (joypad_pressed).w
	beq.w	MAC_ListInput
	bsr.w	MAC_SlotAddr		; battle: an empty slot cannot be used
	tst.w	(a2)
	bmi.w	MAC_ListInput
	rts
MACS_art:
	bsr.w	MAC_Reserve		; (the first time: the view's tiles)
	lea	(MAC_SLOTS_ART).w, a1
	move.w	#MAC_SLOTS_W*MAC_SLOTS_H, d0
	jsr	(PM_ForgetRuns).l
	moveq	#8, d0			; the eight letters
	bsr.w	MAC_RunRoom
	movea.l	a1, a0
	moveq	#MAC_SLOTS_W-1, d0
-
	move.b	#$B9, (a0)+
	dbf	d0, -
	moveq	#0, d6			; the slot
MACS_row:
	move.b	#$B4, (a0)+
	move.b	#$B5, (a0)+
	move.b	#$26, (a0)+		; the letter's cell: a run
	movem.l	d6/a0-a1, -(sp)
	lea	-1(a0), a1
	lea	(MAC_DATA).w, a2
	move.w	d6, d0
	lsl.w	#3, d0
	adda.w	d0, a2
	bsr.w	MAC_SlotInk
	lsl.w	#4, d0
	addq.w	#WT_RUN_KIND_LABEL, d0
	move.w	d0, d5
	moveq	#1, d4
	lea	(MAC_Words).l, a0
	move.w	d6, d0
	addq.w	#2, d0			; the letters after Attack and Defend
	lsl.w	#2, d0
	movea.l	(a0,d0.w), a0
	jsr	(WT_Register).l
	movem.l	(sp)+, d6/a0-a1
	addq.w	#1, d6
	cmpi.w	#8, d6
	bcc.s	+
	moveq	#MAC_SLOTS_W-1, d0
-
	move.b	#$26, (a0)+
	dbf	d0, -
	bra.s	MACS_row
+
	moveq	#MAC_SLOTS_W-1, d0
-
	move.b	#$BE, (a0)+
	dbf	d0, -
	rts

; ---------------------------------------------------------------------------
; The view: the commands of the slot under the cursor (or, in the editor, of
; the macro being set), a line a member: the name, then the command. Redrawn
; in place (6<<8): the input goes back to MAC_FOCUS.
; ---------------------------------------------------------------------------
MAC_ViewWindow:
	tst.w	d1
	bne.w	MACL_done
	bsr.w	MAC_ViewLines
	lea	(MAC_VIEW_ART).w, a1
	move.w	#MAC_VIEW_WMAX*MAC_VIEW_H, d0
	jsr	(PM_ForgetRuns).l
	moveq	#8, d0			; four lines, two runs each
	bsr.w	MAC_RunRoom
	moveq	#MAC_VIEW_WF, d3	; the art's width (its row stride)
	cmpi.b	#ScreenID_Battle, (game_screen).w
	bne.s	+
	moveq	#MAC_VIEW_WB, d3
+
	movea.l	a1, a0
	move.w	d3, d0
	subq.w	#1, d0
-
	move.b	#$B9, (a0)+
	dbf	d0, -
	move.w	d3, d0
	mulu.w	#MAC_VIEW_H-2, d0
	subq.w	#1, d0
-
	move.b	#$26, (a0)+
	dbf	d0, -
	move.w	d3, d0
	subq.w	#1, d0
-
	move.b	#$BE, (a0)+
	dbf	d0, -
	lea	(MAC_LINES).w, a2
	lea	(a1,d3.w), a3		; the first line's first cell
	moveq	#4-1, d6
MACV_line:
	moveq	#0, d0
	move.b	(a2), d0
	bmi.s	MACV_done		; no more lines
	movea.l	d0, a0			; the name
	moveq	#0, d5
	move.b	1(a2), d5
	lsl.w	#4, d5
	move.w	d5, d7			; the ink
	addq.w	#WT_RUN_KIND_NAME, d5
	moveq	#4, d4
	movea.l	a3, a1
	jsr	(WT_Register).l
	movea.l	2(a2), a0		; the command
	move.w	d7, d5
	addq.w	#WT_RUN_KIND_LABEL, d5
	moveq	#MAC_CMD_CELLS, d4
	lea	5(a3), a1
	jsr	(WT_Register).l
	addq.w	#6, a2
	adda.w	d3, a3			; two rows down
	adda.w	d3, a3
	dbf	d6, MACV_line
MACV_done:
	move.w	(MAC_FOCUS).w, d0
	beq.s	+
	move.w	d0, (window_index_saved).w	; a redraw: the input back where it was
	move.w	#2, (window_routine).w
+
	rts

; MAC_LINES for the view: the macro's members in its order (four at most), amber
; where they cannot be carried out as set (not in the editor: the macro being
; set has no colours). A character byte $FF ends the lines.
MAC_ViewLines:
	lea	(MAC_LINES).w, a1
	tst.w	(MAC_BUILDING).w
	beq.s	+
	lea	(MAC_BUILD).w, a2
	moveq	#0, d6			; the editor: no colours
	bra.s	++
+
	bsr.w	MAC_SlotAddr
	moveq	#1, d6
+
	bsr.s	MAC_LinesOf
	move.b	#$FF, (a1)
	rts

; a2 = four macro words: their lines at a1 (advanced); d6 = 0: no colours.
MAC_LinesOf:
	moveq	#3, d2
MACLO_word:
	move.w	(a2)+, d3
	bpl.s	MACLO_end
	move.w	d3, d0
	lsr.w	#8, d0
	lsr.w	#4, d0
	andi.w	#7, d0
	move.b	d0, (a1)+		; the member
	moveq	#0, d1
	tst.w	d6
	beq.s	+
	move.w	d3, d0
	bsr.w	MAC_EntryOK
	beq.s	+
	moveq	#MAC_INK_AMBER, d1
+
	move.b	d1, (a1)+
	bsr.s	MAC_CommandText
	move.l	a0, (a1)+
	dbf	d2, MACLO_word
MACLO_end:
	rts

; d3 = a macro word: a0 = its command's text (ended by $C4).
MAC_CommandText:
	move.w	d3, d0
	lsr.w	#8, d0
	lsr.w	#2, d0
	andi.w	#3, d0
	move.w	d3, d1
	lsr.w	#3, d1
	andi.w	#$7F, d1
	lsl.w	#2, d1
	lea	(MAC_Words).l, a0
	tst.w	d0
	beq.s	MACCT_word		; Attack
	cmpi.w	#3, d0
	bne.s	+
	addq.w	#4, a0			; Defend
MACCT_word:
	movea.l	(a0), a0
	rts
+
	lea	(LN_Techs).l, a0
	andi.w	#$3F<<2, d1
	cmpi.w	#1, d0
	beq.s	+
	lea	(LN_Items).l, a0
	move.w	d3, d1
	lsr.w	#3, d1
	andi.w	#$7F, d1
	lsl.w	#2, d1
+
	movea.l	(a0,d1.w), a0
	rts

; ---------------------------------------------------------------------------
; The view's tiles. When the slots are first drawn the view is the window
; under them; its range of the pool is made as long as its longest content
; (the eight slots', and in the editor a whole macro), so that redrawn in place
; it never reaches the slots' tiles. In battle, short of the unstacked windows'.
; ---------------------------------------------------------------------------
MAC_Reserve:
	movem.l	d0-d7/a0-a3, -(sp)
	move.w	(current_active_objects_num).w, d7
	andi.w	#$F, d7
	subq.w	#1, d7			; the top window's slot
	bmi.w	MACR_end
	move.w	d7, d0
	lsl.w	#4, d0
	lea	($FFFFDF00+$E).w, a0
	cmpi.w	#MAC_ID_VIEW, (a0,d0.w)
	bne.w	MACR_end		; the slots redrawn: the view's range is set
	move.w	(MAC_SLOT).w, -(sp)
	move.w	(MAC_BUILDING).w, -(sp)
	clr.w	(MAC_BUILDING).w
	moveq	#0, d5			; the most tiles
	moveq	#7, d4
-
	move.w	d4, (MAC_SLOT).w
	bsr.w	MAC_ViewLines
	bsr.s	MAC_LinesTiles
	cmp.w	d0, d5
	bcc.s	+
	move.w	d0, d5
+
	dbf	d4, -
	move.w	(sp)+, (MAC_BUILDING).w
	move.w	(sp)+, (MAC_SLOT).w
	cmpi.b	#ScreenID_Battle, (game_screen).w
	beq.s	+
	cmpi.w	#4*(4+10), d5		; the editor: four members with any command
	bcc.s	+
	move.w	#4*(4+10), d5
+
	bsr.w	MAC_ViewLines		; (the lines shown)
	lea	(WT_END).w, a0
	moveq	#0, d6			; the view's first tile
	move.w	d7, d0
	add.w	d0, d0
	tst.w	d7
	beq.s	+
	move.w	-2(a0,d0.w), d6
+
	move.w	d6, d1
	add.w	d5, d1			; its end, reserved
	movem.l	d0-d1/a0, -(sp)
	jsr	(WT_HudFloor).l		; no further than the unstacked windows less the letters
	subq.w	#8, d0
	move.w	d0, d2
	movem.l	(sp)+, d0-d1/a0
	cmp.w	d2, d1
	ble.s	+
	move.w	d2, d1
+
	cmp.w	(a0,d0.w), d1
	ble.s	MACR_end
	move.w	d1, (a0,d0.w)
MACR_end:
	movem.l	(sp)+, d0-d7/a0-a3
	rts

; d0 = the tiles MAC_LINES may take: four a name, the command's cells.
MAC_LinesTiles:
	movem.l	d1-d3/a0-a2, -(sp)
	moveq	#0, d0
	lea	(MAC_LINES).w, a2
	lea	(VWF_Width).l, a1
MACLT_line:
	tst.b	(a2)
	bmi.s	MACLT_end
	addq.w	#4, d0
	movea.l	2(a2), a0
	moveq	#0, d2			; pixels
-
	moveq	#0, d1
	move.b	(a0)+, d1
	cmpi.b	#$C4, d1
	beq.s	+
	moveq	#0, d3
	move.b	(a1,d1.w), d3
	add.w	d3, d2
	bra.s	-
+
	addi.w	#7+8, d2		; its cells, and one for a letter's spill
	lsr.w	#3, d2
	cmpi.w	#MAC_CMD_CELLS, d2
	bls.s	+
	moveq	#MAC_CMD_CELLS, d2
+
	add.w	d2, d0
	addq.w	#6, a2
	bra.s	MACLT_line
MACLT_end:
	movem.l	(sp)+, d1-d3/a0-a2
	rts

; ---------------------------------------------------------------------------
; Room in WT_RUNS for d0 runs. A run stays in the table after its window has
; closed (until another run is registered over its art), and after a long
; session the 48 entries can all be such leftovers: the slots' letters found
; no entry. With fewer than d0 entries free, the runs whose art is in no window
; on the stack are forgotten - but for the macro windows' own buffers (the
; window being prepared is not on the stack yet) and the field menu's party
; panel (redrawn over the stack).
; ---------------------------------------------------------------------------
MAC_RunRoom:
	movem.l	d0-d7/a0-a1, -(sp)
	lea	(WT_RUNS).w, a0
	moveq	#WT_RUNS_N-1, d1
	moveq	#0, d2			; free entries
-
	tst.w	(a0)
	bne.s	+
	addq.w	#1, d2
+
	addq.w	#8, a0
	dbf	d1, -
	cmp.w	d0, d2
	bcc.w	MACRR_done
	lea	(WT_RUNS).w, a0
	moveq	#WT_RUNS_N-1, d1
MACRR_run:
	move.w	(a0), d3		; the run's art address
	beq.s	MACRR_next
	move.w	d3, d0			; the macro buffers: kept
	subi.w	#MAC_VIEW_ART&$FFFF, d0
	cmpi.w	#MAC_SHOP_SIZE, d0
	bcs.s	MACRR_next
	move.w	d3, d0
	subi.w	#MAC_MEMBERS_ART&$FFFF, d0
	cmpi.w	#MAC_SAVES_SIZE, d0
	bcs.s	MACRR_next
	move.w	d3, d0
	subi.w	#MAC_TARGET_ART&$FFFF, d0
	cmpi.w	#MAC_PROFILES_SIZE, d0
	bcs.s	MACRR_next
	move.w	d3, d0
	subi.w	#PM_PANEL_ART&$FFFF, d0
	cmpi.w	#170, d0
	bcs.s	MACRR_next
	lea	($FFFFDF00).w, a1	; a stacked window's art: kept
	move.w	(current_active_objects_num).w, d4
	andi.w	#$F, d4
	bra.s	MACRR_wnext
MACRR_win:
	move.l	6(a1), d5		; its art
	cmpi.l	#$FF0000, d5
	bcs.s	MACRR_wskip		; ROM art: no runs
	move.w	d3, d0
	sub.w	d5, d0			; the run's offset in it
	bcs.s	MACRR_wskip
	move.w	$A(a1), d6
	subq.w	#1, d6
	move.w	$C(a1), d7
	addq.w	#1, d7
	mulu.w	d7, d6			; the art's size (as WT_DrawWindow)
	cmp.w	d6, d0
	bcs.s	MACRR_next		; in it
MACRR_wskip:
	lea	$10(a1), a1
MACRR_wnext:
	dbf	d4, MACRR_win
	clr.w	(a0)			; a closed window's: forgotten
MACRR_next:
	addq.w	#8, a0
	dbf	d1, MACRR_run
MACRR_done:
	movem.l	(sp)+, d0-d7/a0-a1
	rts

; ---------------------------------------------------------------------------
; The macro windows close: the runs they left are forgotten and the buffers
; they borrowed are put back as the windows that own them expect them.
; ---------------------------------------------------------------------------
MAC_Release:
	movem.l	d0/a0-a1, -(sp)
	lea	(MAC_VIEW_ART).w, a1
	move.w	#MAC_SHOP_SIZE, d0
	jsr	(PM_ForgetRuns).l
	lea	(WinArt_StoreInventory).l, a0
	bsr.s	MAC_Restore
	lea	(MAC_MEMBERS_ART).w, a1
	move.w	#MAC_SAVES_SIZE, d0
	jsr	(PM_ForgetRuns).l
	lea	(WinArt_SaveSlots).l, a0
	bsr.s	MAC_Restore
	lea	(MAC_TARGET_ART).w, a1
	move.w	#MAC_PROFILES_SIZE, d0
	jsr	(PM_ForgetRuns).l
	lea	(WinArt_ProfileCharList).l, a0
	bsr.s	MAC_Restore
	movem.l	(sp)+, d0/a0-a1
	rts
; a0 = the ROM art, a1 = its buffer, d0 = the size.
MAC_Restore:
	movem.l	d0/a0-a1, -(sp)
	subq.w	#1, d0
-
	move.b	(a0)+, (a1)+
	dbf	d0, -
	movem.l	(sp)+, d0/a0-a1
	rts

; ---------------------------------------------------------------------------
; Fixed art: the battle menu and the editor's command list (four entries two
; rows apart, the labels WT_StaticRuns from work/script.json).
; ---------------------------------------------------------------------------
BM_Entries macro
	rept	3
	dc.b	$B4, $B5
	rept	BM_W-2
	dc.b	$26
	endm
	rept	BM_W
	dc.b	$26
	endm
	endm
	dc.b	$B4, $B5
	rept	BM_W-2
	dc.b	$26
	endm
	endm
BM_Art:
	border BM_W, $B9
	BM_Entries
	border BM_W, $BE
BM_ArtEnd:
MAC_CmdArt:
	border BM_W, $B9
	BM_Entries
	border BM_W, $BE
MAC_CmdArtEnd:
	even

	endif

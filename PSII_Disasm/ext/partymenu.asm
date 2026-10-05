; The PS IV-style field menu: the four-entry menu at the top left, meseta at
; the bottom left, and the party at the right, one block a member: name and LV,
; HP, TP. The stock entry table and art stay in place; these records are
; selected only while the menu is up.
;
; The party window is the stock MenuCharStats (the four-column stats window
; the field's healing and curing redraw in place) given another record and
; art: whenever MenuCharStats is asked for while the field menu is on the
; window stack - or by PM_Open, which marks it with PM_VAR - the panel is drawn
; instead. So a heal's redraw (6<<8: at once, outside the stack) shows the new
; HP in the panel itself.
;
; Status > Status > a character opens PS IV's status screen: the portrait at
; the top left (its tiles in the dialogue ring's VRAM, idle while no message is
; up; its palette in line 1, which on the field only a few sprites use, put
; back when the window closes), beside it the name, job, LV, HP and TP, the
; stats at the right over the party panel, the equipment below the portrait,
; EXP and NEXT at the bottom right. Five windows, opened with PM_VAR on stock
; window IDs: the dispatch and record hooks give them their own art and places.
;
; Cursors of windows covered by a window opened above them (or by the panel
; redrawn over the stack) are moved off the screen, and back when uncovered:
; PM_FieldFrame, every field frame.
	if party_menu_ps4
	if battle_box==0
	error "party_menu_ps4 needs battle_box for the window-record hook"
	endif
	if vwf_windows==0
	error "party_menu_ps4 needs vwf_windows for its menu labels"
	endif
	if field_heal_popups==0
	error "party_menu_ps4 needs field_heal_popups for its field-frame hook"
	endif

PM_ROSTER_FLAG	equ $FFFF8EA2
PM_VAR_CUR	= $FFFF8EA4		; word: the window being prepared is that variant (its ID), or 0
PM_PAL_SAVED	= $FFFF8EA6		; word: palette line 1 is the portrait's; the map's is saved
PM_OVER		= $FFFF8EA8		; word: the panel was redrawn over the stack at depth n-1
PM_PAL_SAVE	= $FFFF8EAA		; 64 bytes: line 1 of the palette and of its fade target
PM_PLANEB	= $FFFF8E7C		; word: plane B corner saved while the portrait is up
PM_PLANEB_SAVE	= text_buffer		; up to 242 bytes: plane B under the portrait
PM_PLANEB_SIZE	= text_buffer+$F2	; width and height in cells, after the saved cells
PM_VAR		= $0800			; window_index: the field menu's variant of that window

PM_PANEL_ART	= $FFFF8B4E		; past the dynamic window art ($8000-$8B4D); 170 bytes at most
; The other variants' art takes the RAM of stock windows that are never up
; with the status screen and copy their whole art from ROM when they open.
PM_INFO_ART	= window_art_buffer+WinArt_MenuCharStats-DynamicWindowsStart	; 189 (needs 120)
PM_PORT_ART	= window_art_buffer+WinArt_RegroupCharList-DynamicWindowsStart	; 124, Rolf's house (needs 120)
PM_EXP_ART	= window_art_buffer+WinArt_CharOrderDestination-DynamicWindowsStart	; 60 (needs 55)

PM_PANEL_COL	= 28			; the panel's left border column; it ends at the screen's edge
PM_PANEL_ROW	= 1			; its top border row (the menu's)
PM_PANEL_W	= 10			; cells inside the borders
PM_INFO_W	= 12
PM_EXP_W	= 11

PM_ID_PORTRAIT	= WinID_StrngHPTP	; the stock IDs the variants are opened under
PM_ID_INFO	= WinID_StrngLVEXP
PM_ID_STATS	= WinID_StrngStats
PM_ID_EXP	= WinID_CharOrderDestination
PM_ID_EQUIP	= WinID_StrngEquip

PM_PORT_TILE	= $680			; the portrait's 96 tiles: the dialogue ring (ext/vwf.asm)
PM_PORT_VDP	= $40000000|(((PM_PORT_TILE*$20)&$3FFF)<<16)|((PM_PORT_TILE*$20)>>14)	; VRAM write there
PM_PORT_CELL	= $A600			; $F72C while it is drawn: priority, palette 1, tiles $6xx

PM_Open:
	move.b	#SXFID_Selection, (sound_queue).w
	move.w	#1, (PM_ROSTER_FLAG).w
	move.l	#((PM_VAR|WinID_MenuCharStats)<<$10)|WinID_MenuMeseta, (window_index).w
	move.w	#WinID_PlayerMenu, (window_index+4).w
	move.w	#1, (event_routine).w
	clr.w	(event_routine_sub).w
	rts

; Is the window being prepared or drawn (d0 = its ID) the party panel? Z clear
; if so. MenuCharStats queued by PM_Open, or asked for while the field menu
; (WinID_PlayerMenu) is on the window stack.
PM_IsPanel:
	cmpi.w	#WinID_MenuCharStats, d0
	bne.s	.no
	movem.l	d0-d1/a0, -(sp)
	move.w	(window_index).w, d0
	andi.w	#PM_VAR|$FF, d0
	cmpi.w	#PM_VAR|WinID_MenuCharStats, d0
	beq.s	.yes
	lea	($FFFFDF00+$E).w, a0	; each stacked window's ID
	move.w	(current_active_objects_num).w, d1
	andi.w	#$F, d1
	bra.s	.next
.scan:
	cmpi.w	#WinID_PlayerMenu, (a0)
	beq.s	.yes
	lea	$10(a0), a0
.next:
	dbf	d1, .scan
	movem.l	(sp)+, d0-d1/a0
.no:
	ori.b	#4, ccr			; Z set: not the panel
	rts
.yes:
	movem.l	(sp)+, d0-d1/a0
	andi.b	#$FB, ccr		; Z clear
	rts

; Is the window at the head of the queue (d0 = its ID) a status-screen variant?
; Z clear if so.
PM_IsVariant:
	move.l	d1, -(sp)
	move.w	(window_index).w, d1
	andi.w	#PM_VAR|$FF, d1
	eori.w	#PM_VAR, d1
	cmp.w	d0, d1
	beq.s	.yes
	move.l	(sp)+, d1
	ori.b	#4, ccr
	rts
.yes:
	move.l	(sp)+, d1
	andi.b	#$FB, ccr
	rts

; Called from ProcessWindows with the usual layout-table base in a1 and the
; window ID in d0.
PM_Record:
	movem.l	d1/a0, -(sp)
	cmpi.w	#PM_PORT_CELL, ($FFFFF72C).w	; drawn after the portrait: the window font again
	bne.s	+
	cmpi.w	#PM_ID_PORTRAIT, d0
	beq.s	+
	move.w	#$8500, ($FFFFF72C).w
+
	bsr.w	PM_IsPanel
	bne.s	PMR_panel
	bsr.s	PM_IsVariant
	bne.s	PMR_variant
	bsr.w	PM_EquipMode
	beq.s	+
	bsr.w	EQ_Record		; the Equip screen's windows (ext/equipscreen.asm)
	bne.s	PMR_done
+
	tst.w	(PM_ROSTER_FLAG).w
	beq.s	PMR_done
	cmpi.w	#WinID_MenuMeseta, d0
	beq.s	PMR_meseta
	cmpi.w	#WinID_PlayerMenu, d0
	bne.s	PMR_done
	lea	(PM_MenuLayout-WinID_PlayerMenu*8).l, a1
	bra.s	PMR_done
PMR_meseta:
	lea	(PM_MesetaLayout-WinID_MenuMeseta*8).l, a1
PMR_done:
	movem.l	(sp)+, d1/a0
	rts
PMR_panel:
	btst	#2, (window_index).w	; redrawn outside the stack: it covers the cursors
	beq.s	+
	move.w	(current_active_objects_num).w, d1
	andi.w	#$F, d1
	addq.w	#1, d1
	move.w	d1, (PM_OVER).w
+
	move.w	(party_members_num).w, d1
	andi.w	#3, d1
	lsl.w	#3, d1
	lea	(PM_PanelLayouts-WinID_MenuCharStats*8).l, a1
	adda.w	d1, a1
	bra.s	PMR_done
PMR_variant:
	lea	(PM_VariantLayouts).l, a0
PMR_lookup:
-
	move.w	(a0)+, d1
	beq.s	PMR_done			; (not reached: every ID is listed)
	cmp.w	d0, d1
	beq.s	+
	addq.w	#8, a0
	bra.s	-
+
	move.w	d0, d1
	lsl.w	#3, d1
	movea.l	a0, a1
	suba.w	d1, a1
	bra.s	PMR_done

; PrepareWindows' dispatch (d0 = the window ID, d1 = its routine): the panel's
; and the variants' art, or the stock routine. The stock jsr's lsl/andi are
; done here; the table entry is reached by an rts so that every register
; arrives as stock.
PM_Dispatch:
	if field_options
	cmpi.w	#WinID_Options, d0	; the Options window (ext/options.asm)
	beq.w	OPT_Window
	endif
	if shop_equip_compare
	cmpi.w	#SH_ID_PARTY, d0	; the shops' windows (ext/shopequip.asm)
	beq.w	SH_Window
	cmpi.w	#SH_ID_CMP, d0
	beq.w	SH_Window
	endif
	tst.w	d1
	bne.s	+
	clr.w	(PM_VAR_CUR).w		; routine 0: a window starts
	bsr.w	PM_IsVariant
	beq.s	+
	move.w	d0, (PM_VAR_CUR).w
+
	bsr.w	PM_IsPanel
	bne.w	PM_BuildPanel
	bsr.w	PM_EquipMode
	bne.w	EQ_Dispatch		; the Equip screen's windows (ext/equipscreen.asm)
	tst.w	(PM_VAR_CUR).w
	beq.s	PM_StockWindow
	cmp.w	(PM_VAR_CUR).w, d0
	bne.s	PM_StockWindow
	cmpi.w	#PM_ID_PORTRAIT, d0
	beq.w	PM_BuildPortrait
	cmpi.w	#PM_ID_INFO, d0
	beq.w	PM_BuildInfoStatus
	cmpi.w	#PM_ID_EXP, d0
	beq.w	PM_BuildExp
	cmpi.w	#PM_ID_EQUIP, d0
	bne.s	PM_StockWindow
	tst.w	d1
	bne.s	PM_Stock
	bsr.s	PM_Stock		; the stock art, its border whole again: the
	bra.w	EQ_BorderBack		; Equip screen writes the name on it
PM_StockWindow:
	cmpi.w	#WinID_MenuCharStats, d0	; the stock stats window (the hospital's):
	bne.s	PM_Stock		; its buffer is the info window's and the
	movem.l	d0/a1, -(sp)		; comparison's, whose runs must not show in it
	lea	(PM_INFO_ART).w, a1
	move.w	#189, d0
	bsr.w	PM_ForgetRuns
	movem.l	(sp)+, d0/a1
PM_Stock:				; the stats and the equipment: the stock art
	lsl.w	#2, d0
	andi.w	#$3FC, d0
	subq.l	#4, sp
	move.l	a0, -(sp)
	lea	(WindowsIndexTable).l, a0
	adda.w	d0, a0
	move.l	a0, 4(sp)
	movea.l	(sp)+, a0
	rts

; Is the Equip screen up (the field menu on the stack, its cursor on Equip)?
; Z clear if so. Its windows are moved while it is, whoever opens them: the
; stock code opens and redraws them by their plain IDs.
PM_EquipMode:
	cmpi.w	#3, ($FFFFDE80).w
	bne.s	PME_no
	movem.l	d0-d1/a0, -(sp)
	lea	($FFFFDF00+$E).w, a0
	move.w	(current_active_objects_num).w, d1
	andi.w	#$F, d1
	bra.s	PME_next
PME_scan:
	cmpi.w	#WinID_PlayerMenu, (a0)
	beq.s	PME_yes
	lea	$10(a0), a0
PME_next:
	dbf	d1, PME_scan
	movem.l	(sp)+, d0-d1/a0
PME_no:
	ori.b	#4, ccr
	rts
PME_yes:
	movem.l	(sp)+, d0-d1/a0
	andi.b	#$FB, ccr
	rts

; CloseCurrentWindow (d1 = $8000 + the windows to close): when the window left
; on top would be a portrait, it closes too - it belongs to the windows above
; it, and the stock counts do not know it.
PM_CloseCount:
	movem.l	d0/a0, -(sp)
	bsr.w	PM_EquipMode		; the Equip screen opens three windows where
	beq.s	PMC_portrait		; the stock counts close four: never past the
	lea	($FFFFDF00+$E).w, a0	; Who? list (the topmost on the stack)
	move.w	(current_active_objects_num).w, d0
	andi.w	#$F, d0
	subq.w	#1, d0
	bmi.s	PMC_portrait
	move.w	d0, -(sp)
	lsl.w	#4, d0
-
	cmpi.w	#WinID_StrngCharList, (a0,d0.w)
	beq.s	+
	subi.w	#$10, d0
	bpl.s	-
	addq.l	#2, sp
	bra.s	PMC_portrait
+
	lsr.w	#4, d0			; its slot
	neg.w	d0
	add.w	(sp)+, d0		; the windows above it
	beq.s	PMC_portrait		; (it is on top: B on it closes it)
	move.w	d1, -(sp)
	andi.w	#7, d1
	cmp.w	d0, d1
	movem.w	(sp)+, d1
	bls.s	PMC_portrait
	andi.w	#$FFF8, d1
	or.w	d0, d1
PMC_portrait:
	move.w	d1, d0
	andi.w	#7, d0
	neg.w	d0
	add.w	(current_active_objects_num).w, d0
	subq.w	#1, d0			; the window that would be on top
	bmi.s	PMC_done
	lsl.w	#4, d0
	lea	($FFFFDF00+6).w, a0
	cmpi.l	#PM_PORT_ART&$FFFFFF, (a0,d0.w)
	bne.s	PMC_done
	cmpi.w	#PM_ID_PORTRAIT, 8(a0,d0.w)	; (Rolf's house's member list shares the art)
	bne.s	PMC_done
	addq.w	#1, d1
PMC_done:
	tst.w	(PM_PLANEB).w		; the portrait among the windows closing:
	beq.s	PMC_planeb		; the map under it back now, before the
	move.l	#PM_PORT_ART&$FFFFFF, d0	; vertical blank takes the windows off
	bsr.w	EQ_FindArt
	bmi.s	PMC_planeb
	cmpi.w	#PM_ID_PORTRAIT, $E(a0)
	bne.s	PMC_planeb
	suba.w	#$DF00, a0
	move.w	a0, d0
	lsr.w	#4, d0			; its slot
	move.w	d1, a0
	andi.w	#7, d1
	sub.w	(current_active_objects_num).w, d0
	add.w	d1, d0			; slot - (depth - n): >= 0 if it closes
	move.w	a0, d1
	tst.w	d0
	bmi.s	PMC_planeb
	bsr.w	PM_PlaneBBack
PMC_planeb:
	movem.l	(sp)+, d0/a0
	move.w	d1, (window_index).w	; the two instructions the hook replaced
	lea	($FFFFDEFE).w, a1
	rts

; LoadCursorInWindows (d1 = X, d2 = Y): a moved window's cursor moves with it.
PM_CursorPlace:
	bsr.w	PM_EquipMode
	beq.s	PMP_done
	cmpi.w	#WinID_ItemList2, (window_index_saved).w	; column 18 (stock 23)
	beq.s	+
	cmpi.w	#WinID_ItemList3, (window_index_saved).w	; column 19 (stock 24)
	bne.s	PMP_done
+
	subi.w	#(23-18)*8, d1
PMP_done:
	lea	(object_ram).w, a0	; the two instructions the hook replaced
	move.w	(current_active_objects_num).w, d3
	rts

; While the portrait's palette is in line 1, the sprites in that line - the
; map's people, on the field - are moved above the screen in the sprite table
; this frame built, rather than shown in the portrait's colours. The party,
; the cursors and the heal numbers use line 0.
PM_HideNPCs:
	tst.w	(PM_PAL_SAVED).w
	beq.s	PMH_end
	movem.l	d0-d1/a0, -(sp)
	moveq	#0, d0
	move.b	(sprite_link_field_count).w, d0
	lea	(sprite_table).w, a0
	bra.s	PMH_next
PMH_loop:
	move.w	4(a0), d1
	andi.w	#$6000, d1
	cmpi.w	#$2000, d1
	bne.s	PMH_skip
	clr.w	(a0)
PMH_skip:
	addq.w	#8, a0
PMH_next:
	dbf	d0, PMH_loop
	movem.l	(sp)+, d0-d1/a0
PMH_end:
	rts

; CloseAllWindows (the hook replaces its first two instructions): an item
; used, given or dropped, or a technique used, from the field menu returns to
; the list it came from, as PS IV's menu does - the windows above the list
; close and the menu waits for the next pick (event_routine back to it). The
; item list is drawn again (an item may be gone; none left: the character
; list instead). What leaves the menu anyway closes everything: Telepipe,
; Escapipe, the key and event items, Ryuka, Hinas, Musik.
PM_CloseAll:
	movem.l	d0-d3/a0, -(sp)
	lea	($FFFFDF00+$E).w, a0
	move.w	(current_active_objects_num).w, d3
	andi.w	#$F, d3			; the windows up
	move.w	($FFFFDE80).w, d0	; the menu's entry
	beq.s	PMA_items
	cmpi.w	#1, d0
	bne.w	PMA_stock
	; Techniques: the technique being used is a list pick (event_routine 3)
	cmpi.w	#3, (event_routine).w
	bne.w	PMA_stock
	cmpi.b	#TechID_Ryuka, (technique_index).w
	bcc.w	PMA_stock		; Ryuka, Hinas, Musik leave the menu
	move.w	#WinID_LevelTechList2, d0	; its second page, or the first
	bsr.w	PMA_Find
	bpl.s	+
	move.w	#WinID_LevelTechList, d0
	bsr.w	PMA_Find
	bmi.w	PMA_stock
+
	moveq	#3, d2			; the step a pick of it takes
	ori.w	#6<<8, d0		; drawn again last: it takes the input back
	bra.w	PMA_return
PMA_items:
	cmpi.w	#4, (event_routine).w	; Use, Give or Drop under way
	bne.w	PMA_stock
	tst.w	($FFFFDE88).w
	bne.s	PMA_items_list		; Give, Drop
	moveq	#0, d0
	move.b	(item_index).w, d0
	cmpi.w	#ItemID_Hidapipe, d0
	bcs.s	+
	cmpi.w	#ItemID_MoonDew, d0
	bls.s	PMA_items_list		; Hidapipe, the mates, Antidote, Star Mist, Moon Dew
+
	lsl.w	#4, d0
	movea.l	a0, a1
	lea	(InventoryData+$C).l, a0
	btst	#3, (a0,d0.w)
	movea.l	a1, a0
	bne.w	PMA_stock		; an item with an action of its own
PMA_items_list:
	lea	(character_data_buffer+$27).w, a1
	move.w	(character_index).w, d0
	lsl.w	#6, d0
	tst.b	(a1,d0.w)
	beq.s	PMA_items_none
	move.w	#WinID_MenuItemList, d0
	bsr.w	PMA_Find
	bmi.w	PMA_stock
	moveq	#3, d2			; a pick of it opens Use/Give/Drop
	move.w	#(6<<8)|WinID_MenuItemList, d0	; drawn again: an item may be gone
	bra.s	PMA_return
PMA_items_none:				; nothing left: the character list
	move.w	#WinID_MenuItemChar, d0
	bsr.w	PMA_Find
	bmi.s	PMA_stock
	moveq	#2, d2
	move.w	#(6<<8)|WinID_MenuItemChar, d0
; d1 = the list's slot, d2 = the step, d0 = the list drawn again (in place, last:
; its routine takes the input back). The party panel is drawn again before it:
; closing a heal's copy of it puts back what it covered, the HP before.
PMA_return:
	sub.w	d1, d3
	subq.w	#1, d3			; the windows above the list
	ble.s	PMA_stock
	ori.w	#$8000, d3
	move.w	d3, (window_index).w	; close them
	move.w	#(6<<8)|WinID_MenuCharStats, (window_index+2).w	; the panel
	move.w	d0, (window_index+4).w	; the list
	clr.w	(window_index+6).w
	lsl.w	#4, d1
	move.w	(a0,d1.w), (window_index_saved).w	; its routine takes the input again
	move.w	d2, (event_routine).w
	moveq	#0, d0
	move.w	d0, (event_routine_sub).w
	move.w	d0, ($FFFFDE6E).w
	move.w	d0, ($FFFFDE70).w
	move.w	d0, ($FFFFDE72).w
	movem.l	(sp)+, d0-d3/a0
	addq.l	#4, sp			; past CloseAllWindows' own code
	rts
PMA_stock:
	movem.l	(sp)+, d0-d3/a0
	moveq	#0, d0			; the two instructions the hook replaced
	move.w	d0, (window_index_saved).w
	rts

; d0 = a window ID, a0 = the stack's IDs, d3 = the windows up: d1 = the slot of
; the topmost window with that ID, N set if none (or the field menu is not up).
PMA_Find:
	movem.l	d2/a1, -(sp)
	move.w	d3, d1
PMA_FindNext:
	subq.w	#1, d1
	bmi.s	PMA_FindNone
	move.w	d1, d2
	lsl.w	#4, d2
	cmp.w	(a0,d2.w), d0
	bne.s	PMA_FindNext
	moveq	#0, d2			; the field menu (WinID_PlayerMenu) below it?
PMA_FindMenu:
	cmp.w	d1, d2
	bcc.s	PMA_FindNone
	move.w	d2, -(sp)
	lsl.w	#4, d2
	cmpi.w	#WinID_PlayerMenu, (a0,d2.w)
	movem.w	(sp)+, d2
	beq.s	PMA_FindOk
	addq.w	#1, d2
	bra.s	PMA_FindMenu
PMA_FindOk:
	movem.l	(sp)+, d2/a1
	andi.b	#$F7, ccr		; N clear
	rts
PMA_FindNone:
	movem.l	(sp)+, d2/a1
	ori.b	#8, ccr			; N set
	rts

; Status > Status > a character: the five windows of the status screen. The
; equipment comes last, as the stock four's: its routine takes the input.
PM_StatsOpen:
	move.l	#((PM_VAR|$200|PM_ID_PORTRAIT)<<$10)|(PM_VAR|PM_ID_INFO), (window_index).w	; the portrait at once
	move.l	#((PM_VAR|PM_ID_STATS)<<$10)|(PM_VAR|PM_ID_EXP), (window_index+4).w
	move.w	#PM_VAR|PM_ID_EQUIP, (window_index+8).w
	addq.w	#1, (event_routine).w
	rts

; a1 = an art buffer, d0 = its size: forget the runs other windows registered
; there (the buffers are shared).
PM_ForgetRuns:
	movem.l	d0-d3/a0, -(sp)
	move.w	a1, d1
	move.w	d1, d2
	add.w	d0, d2
	lea	(WT_RUNS).w, a0
	moveq	#WT_RUNS_N-1, d0
-
	move.w	(a0), d3
	cmp.w	d1, d3
	bcs.s	+
	cmp.w	d2, d3
	bcc.s	+
	clr.w	(a0)
+
	addq.w	#8, a0
	dbf	d0, -
	movem.l	(sp)+, d0-d3/a0
	rts

; d0 = cells, d1 = the byte: a row of it at a1.
PM_Fill:
	subq.w	#1, d0
	bmi.s	+
-
	move.b	d1, (a1)+
	dbf	d0, -
+
	rts

; The panel's art: a border row, then for each member a name/LV row, an HP row
; and a TP row, a blank row between members, and a border row. The name is
; four marker bytes (wintext draws the six-letter name); LV, HP and TP are
; letter tiles, which wintext redraws in the proportional face; the numbers
; are the stock digit tiles, right-aligned.
PM_BuildPanel:
	move.w	#0, (window_index_saved).w	; as Win_MenuCharStats: Win_Null runs next
	movem.l	d0-d5/a0-a3, -(sp)
	lea	(PM_PANEL_ART).l, a1
	moveq	#PM_PANEL_W, d0
	move.w	#$B9, d1
	bsr.s	PM_Fill
	lea	(party_member_id).w, a0
	move.w	(party_members_num).w, d5
	andi.w	#3, d5
PM_PanelMember:
	move.w	(a0)+, d1
	lea	(character_data_buffer).w, a3
	move.w	d1, d0
	lsl.w	#6, d0
	adda.w	d0, a3
	addi.b	#$81, d1		; the name: four marker bytes
	moveq	#4, d0
	bsr.s	PM_Fill
	move.b	#$26, (a1)+
	move.b	#$26, (a1)+
	move.b	#$32, (a1)+		; L
	move.b	#$3C, (a1)+		; V
	move.w	$A(a3), d0
	jsr	(loc_11364).l		; two digits
	bsr.w	PM_HPTP
	tst.w	d5
	beq.s	PM_PanelEnd
	moveq	#PM_PANEL_W, d0
	moveq	#$26, d1
	bsr.s	PM_Fill
	subq.w	#1, d5
	bra.s	PM_PanelMember
PM_PanelEnd:
	moveq	#PM_PANEL_W, d0
	move.w	#$BE, d1
	bsr.s	PM_Fill
	movem.l	(sp)+, d0-d5/a0-a3
	rts

; The HP and TP rows (ten cells each) of the character at a3, at a1.
; Use the stock field stats window's 2x2 dead/poison marks in the label cells.
PM_HPTP:
	movem.l	d5/a0/a4, -(sp)
	lea	(loc_11432+8).l, a4	; HP/TP, after the dead and poison marks
	tst.w	2(a3)
	beq.s	.dead
	tst.w	(a3)
	bpl.s	.labels
	subq.w	#4, a4			; poisoned
	bra.s	.labels
.dead:
	subq.w	#8, a4
.labels:
	move.w	(a4)+, d5
	lea	2(a3), a0
	bsr.s	PM_PointsRow
	move.w	(a4)+, d5
	lea	6(a3), a0
	bsr.s	PM_PointsRow
	movem.l	(sp)+, d5/a0/a4
	rts

; d5 = two label tiles, a0 = the current value (the maximum after it): "HP"
; or "TP", a blank, three digits, "/", three digits - ten cells at a1.
PM_PointsRow:
	move.w	d5, (a1)+
	move.b	#$26, (a1)+
	move.w	(a0), d0
	jsr	(loc_1135A).l		; three digits (d0-d4, a2)
	move.b	#$64, (a1)+		; /
	move.w	2(a0), d0
	jmp	(loc_1135A).l

; The info window: the name, the job, LV, then HP and TP, PS IV's order.
; d7 = its width, a blank cell either side of the ten-cell rows.
PM_BuildInfoStatus:
	moveq	#PM_INFO_W, d7
PM_BuildInfo:
	move.w	#0, (window_index_saved).w
	movem.l	d0-d7/a0-a3, -(sp)
	lea	(PM_INFO_ART).w, a1
	move.w	d7, d0
	mulu.w	#10, d0
	bsr.w	PM_ForgetRuns
	move.w	d7, d6
	subi.w	#10, d6
	lsr.w	#1, d6			; the margin
	move.w	(character_index).w, d2
	lea	(character_data_buffer).w, a3
	move.w	d2, d0
	lsl.w	#6, d0
	adda.w	d0, a3
	move.w	d7, d0
	move.w	#$B9, d1
	bsr.w	PM_Fill
	move.w	d6, d0			; the name
	moveq	#$26, d1
	bsr.w	PM_Fill
	move.w	d2, d1
	addi.b	#$81, d1
	moveq	#4, d0
	bsr.w	PM_Fill
	move.w	d7, d0			; the rest of the row and a blank row
	add.w	d7, d0
	sub.w	d6, d0
	subq.w	#4, d0
	moveq	#$26, d1
	bsr.w	PM_Fill
	move.w	d6, d0			; the job: a run of its full-length name
	bsr.w	PM_Fill
	lea	(loc_11456).l, a0
	move.w	d2, d0
	lsl.w	#3, d0
	adda.w	d0, a0
	moveq	#8, d4
	moveq	#WT_RUN_KIND_TEXT, d5
	jsr	(WT_Register).l
	move.w	d7, d0			; its cells, the row's end and a blank row
	add.w	d7, d0
	sub.w	d6, d0
	moveq	#$26, d1
	bsr.w	PM_Fill
	move.w	d6, d0			; LV, the number at the HP's right edge
	bsr.w	PM_Fill
	move.b	#$32, (a1)+
	move.b	#$3C, (a1)+
	moveq	#6, d0
	bsr.w	PM_Fill
	move.w	$A(a3), d0
	jsr	(loc_11364).l
	move.w	d6, d0			; the margin and a blank row
	add.w	d7, d0
	moveq	#$26, d1
	bsr.w	PM_Fill
	move.w	d6, d0			; HP and TP: ten cells each
	bsr.w	PM_Fill
	move.w	#$2E36, d5		; HP
	lea	2(a3), a0
	bsr.w	PM_PointsRow
	move.w	d6, d0
	add.w	d6, d0
	moveq	#$26, d1
	bsr.w	PM_Fill
	move.w	#$3A36, d5		; TP
	lea	6(a3), a0
	bsr.w	PM_PointsRow
	move.w	d6, d0
	moveq	#$26, d1
	bsr.w	PM_Fill
	move.w	d7, d0
	move.w	#$BE, d1
	bsr.w	PM_Fill
	movem.l	(sp)+, d0-d7/a0-a3
	rts

; EXP and NEXT (what the next level needs; nothing at the top level).
PM_BuildExp:
	move.w	#0, (window_index_saved).w
	movem.l	d0-d7/a0-a3, -(sp)
	lea	(PM_EXP_ART).w, a1
	moveq	#PM_EXP_W*5, d0
	bsr.w	PM_ForgetRuns
	move.w	(character_index).w, d2
	lea	(character_data_buffer).w, a3
	move.w	d2, d0
	lsl.w	#6, d0
	adda.w	d0, a3
	moveq	#PM_EXP_W, d0
	move.w	#$B9, d1
	bsr.w	PM_Fill
	move.b	#$2B, (a1)+		; E
	move.b	#$3E, (a1)+		; X
	move.b	#$36, (a1)+		; P
	move.b	#$26, (a1)+
	move.l	$C(a3), d0
	jsr	(Exp_ConvertToDecimal).l	; seven digits
	moveq	#PM_EXP_W, d0
	moveq	#$26, d1
	bsr.w	PM_Fill
	move.b	#$34, (a1)+		; N
	move.b	#$2B, (a1)+		; E
	move.b	#$3E, (a1)+		; X
	move.b	#$3A, (a1)+		; T
	move.w	$A(a3), d3
	cmpi.w	#$32, d3		; the top level (as Character_ProcessLevelUp)
	bcc.s	PMX_top
	lea	(CharExperiencePtrs).l, a0
	move.w	(character_index).w, d0	; (the digits used d1-d4)
	lsl.w	#2, d0
	movea.l	(a0,d0.w), a0
	mulu.w	#$E, d3
	move.l	(a0,d3.w), d0
	andi.l	#$FFFFFF, d0
	sub.l	$C(a3), d0
	bcc.s	+
	moveq	#0, d0
+
	jsr	(Exp_ConvertToDecimal).l
	bra.s	PMX_end
PMX_top:
	moveq	#7, d0
	moveq	#$26, d1
	bsr.w	PM_Fill
PMX_end:
	moveq	#PM_EXP_W, d0
	move.w	#$BE, d1
	bsr.w	PM_Fill
	movem.l	(sp)+, d0-d7/a0-a3
	rts

; The portrait: its art (the stock portrait window's, the tile numbers moved to
; PM_PORT_TILE), its tiles decompressed there, its palette in line 1 (the
; map's saved first), $F72C for the drawing. Routines 1 and 2 do nothing: the
; next window resets $F72C (PM_Record).
PM_BuildPortrait:
	tst.w	d1
	beq.s	+
	rts
+
	movem.l	d0-d7/a0-a6, -(sp)
	move.w	(character_index).w, d2
	andi.w	#7, d2
	lsl.w	#2, d2
	lea	(PM_PORT_ART).w, a1
	lea	(PM_PortraitArt).l, a0
	movea.l	(a0,d2.w), a0
	moveq	#$80-$00, d3		; tile byte + this = the ring's
	tst.w	d2
	bne.s	+
	moveq	#$80-$A0, d3		; Rolf's tiles are loaded at $4A0
+
	moveq	#10-1, d0		; the top border
-
	move.b	(a0)+, (a1)+
	dbf	d0, -
	moveq	#100-1, d0
-
	move.b	(a0)+, d1
	add.b	d3, d1
	move.b	d1, (a1)+
	dbf	d0, -
	moveq	#10-1, d0		; the bottom border
-
	move.b	(a0)+, (a1)+
	dbf	d0, -
	lea	(PM_PortraitTiles).l, a0
	movea.l	(a0,d2.w), a0
	move.l	#PM_PORT_VDP, d6
	move.w	d2, -(sp)
	bsr.w	PM_Decompress		; (uses d2)
	move.w	(sp)+, d2
	tst.w	(PM_PAL_SAVED).w
	bne.s	+
	lea	($FFFFFB20).w, a0	; the map's line 1 and its fade target
	lea	(PM_PAL_SAVE).w, a1
	moveq	#8-1, d0
-
	move.l	(a0)+, (a1)+
	dbf	d0, -
	lea	($FFFFFBA0).w, a0
	moveq	#8-1, d0
-
	move.l	(a0)+, (a1)+
	dbf	d0, -
	move.w	#1, (PM_PAL_SAVED).w
+
	lea	(PM_PortraitPal).l, a0
	movea.l	(a0,d2.w), a0
	lea	($FFFFFB20).w, a1
	lea	($FFFFFBA0).w, a2
	moveq	#8-1, d0
-
	move.l	(a0), (a1)+
	move.l	(a0)+, (a2)+
	dbf	d0, -
	move.w	#PM_PORT_CELL, ($FFFFF72C).w
	bsr.w	PM_HideNPCs		; this frame's sprite table is built already
	movem.l	(sp)+, d0-d7/a0-a6
	rts

PM_PortraitArt:
	dc.l	WinArt_RolfPortrait, WinArt_NeiPortrait, WinArt_RudoPortrait, WinArt_AmyPortrait
	dc.l	WinArt_HughPortrait, WinArt_AnnaPortrait, WinArt_KainPortrait, WinArt_ShirPortrait
PM_PortraitTiles:
	dc.l	RolfPortraitArt, NeiPortraitArt, RudoPortraitArt, AmyPortraitArt
	dc.l	HughPortraitArt, AnnaPortraitArt, KainPortraitArt, ShirPortraitArt
PM_PortraitPal:
	dc.l	Pal_RolfPortrait, Pal_NeiPortrait, Pal_RudoPortrait, Pal_AmyPortrait
	dc.l	Pal_HughPortrait, Pal_AnnaPortrait, Pal_KainPortrait, Pal_ShirPortrait

; DecompressArt with the display on: a0 = the art, d6 = the VDP command of the
; first tile. The same decoding (each tile into $F7A0), but every tile is
; written with interrupts held off and its own address, so the vertical
; blank's VDP traffic can never fall between the address and the data.
PM_Decompress:
	lea	($FFFFF7A0).w, a3
	moveq	#0, d0
	moveq	#0, d2
	move.b	(a0)+, d2
	beq.w	PMD_literal
	bmi.w	PMD_end
	subq.w	#1, d2
PMD_group:
	lea	($FFFFF7A0).w, a2
	movea.l	a2, a3
	move.b	(a0)+, d3
	move.b	(a0)+, d4
	lsl.w	#8, d4
	move.b	(a0)+, d4
	lsl.l	#8, d4
	move.b	(a0)+, d4
	lsl.l	#8, d4
	move.b	(a0)+, d4
	or.l	d4, d0
	moveq	#$1F, d7
-
	lsl.l	#1, d4
	bcc.s	+
	move.b	d3, (a2)
+
	addq.w	#1, a2
	dbf	d7, -
	dbf	d2, PMD_group
	moveq	#-1, d1
	eor.l	d0, d1
	beq.s	PMD_out
PMD_literal:
	moveq	#$1F, d7
-
	lsl.l	#1, d0
	bcs.s	+
	move.b	(a0)+, (a3)
+
	addq.w	#1, a3
	dbf	d7, -
PMD_out:
	lea	($FFFFF7A0).w, a6
	lea	(vdp_data_port).l, a5
	move	sr, -(sp)
	move	#$2700, sr
	move.w	#$8F02, (vdp_control_port).l
	move.l	d6, (vdp_control_port).l
	rept	8
	move.l	(a6)+, (a5)
	endm
	move	(sp)+, sr
	addi.l	#$200000, d6		; the next tile
	bra.w	PM_Decompress
PMD_end:
	rts

; Every field frame, before the sprites are built (FH_RunObjectsAndBuild).
; The portrait's palette goes back once its window is off the stack; each
; window's cursor is hidden (Y 0, above the screen) while a window above it
; - or the panel redrawn over the stack - covers it, and shown again (its Y
; as the cursor object computes it) when uncovered.
PM_FieldFrame:
	bsr.w	EQ_Frame		; the Equip screen (ext/equipscreen.asm)
	movem.l	d0-d7/a0-a3, -(sp)
	move.w	(current_active_objects_num).w, d7
	andi.w	#$F, d7
	move.w	(PM_OVER).w, d0
	beq.s	+
	subq.w	#1, d0
	cmp.w	d7, d0
	beq.s	+
	clr.w	(PM_OVER).w		; the stack changed: the redraw is gone
+
	tst.w	(PM_PAL_SAVED).w
	beq.s	PMF_cursors
	move.w	(window_index).w, d0	; still being drawn (not on the stack yet)
	andi.w	#PM_VAR|$FF, d0
	cmpi.w	#PM_VAR|PM_ID_PORTRAIT, d0
	beq.s	PMF_cursors
	lea	($FFFFDF00+6).w, a0	; each stacked window's art
	move.w	d7, d0
	bra.s	PMF_pnext
PMF_pscan:
	cmpi.l	#PM_PORT_ART&$FFFFFF, (a0)
	bne.s	+
	cmpi.w	#PM_ID_PORTRAIT, 8(a0)
	beq.s	PMF_up			; the portrait is still up
+
	lea	$10(a0), a0
PMF_pnext:
	dbf	d0, PMF_pscan
	lea	(PM_PAL_SAVE).w, a0
	lea	($FFFFFB20).w, a1
	moveq	#8-1, d0
-
	move.l	(a0)+, (a1)+
	dbf	d0, -
	lea	($FFFFFBA0).w, a1
	moveq	#8-1, d0
-
	move.l	(a0)+, (a1)+
	dbf	d0, -
	clr.w	(PM_PAL_SAVED).w
	bsr.w	PM_PlaneBBack		; (if B or PM_Close did not already)
	bra.s	PMF_cursors
PMF_up:
	tst.w	(PM_PLANEB).w		; drawn: the map under it blank, once
	bne.s	PMF_cursors
	subq.w	#6, a0
	bsr.w	PM_PlaneBBlank
PMF_cursors:
	move.w	($FFFFF718).w, d5	; the camera's row and column on the plane
	andi.w	#$F8, d5		; (as ProcessWindows places windows)
	lsr.w	#3, d5
	move.w	($FFFFF71A).w, d6
	andi.w	#$1F8, d6
	lsr.w	#3, d6
	lea	(object_ram).w, a2
	moveq	#0, d4			; the window
PMF_cursor:
	cmp.w	d7, d4
	bcc.w	PMF_done
	cmpi.w	#ObjID_RedRectangleCursor, (a2)
	bne.w	PMF_next
	moveq	#0, d0
	move.b	$32(a2), d0
	lsl.w	#4, d0
	add.w	$2A(a2), d0		; its Y when shown
	move.w	d0, d3
	subi.w	#128, d0
	asr.w	#3, d0			; its cell
	move.w	$A(a2), d1
	subi.w	#128, d1
	asr.w	#3, d1
	lea	($FFFFDF00).w, a0	; the windows above it
	move.w	d4, d2
	addq.w	#1, d2
	move.w	d2, -(sp)
	lsl.w	#4, d2
	adda.w	d2, a0
	move.w	(sp)+, d2
PMF_above:
	cmp.w	d7, d2
	bcc.s	PMF_over
	bsr.w	PM_InWindow
	beq.s	PMF_hide
	lea	$10(a0), a0
	addq.w	#1, d2
	bra.s	PMF_above
PMF_over:
	tst.w	(PM_OVER).w
	beq.s	PMF_show
	cmpi.w	#PM_PANEL_COL, d1
	blt.s	PMF_show
	cmpi.w	#PM_PANEL_ROW, d0
	blt.s	PMF_show
	move.w	(party_members_num).w, d2
	andi.w	#3, d2
	lsl.w	#2, d2
	addq.w	#PM_PANEL_ROW+4, d2	; the panel's bottom border row
	cmp.w	d2, d0
	bgt.s	PMF_show
PMF_hide:
	clr.w	$E(a2)
	bra.s	PMF_next
PMF_show:
	tst.w	$E(a2)
	bne.s	PMF_next
	move.w	d3, $E(a2)
PMF_next:
	lea	$40(a2), a2
	addq.w	#1, d4
	bra.w	PMF_cursor
PMF_done:
	movem.l	(sp)+, d0-d7/a0-a3
	rts

; The portrait's outlines are colour 0, which the VDP draws transparent: in
; Rolf's house the black backdrop shows through them, on the field the map
; would. So while the portrait is up, the map's plane B cells under its
; interior are saved (PM_PLANEB_SAVE) and blanked (tile 0, transparent: the
; backdrop, black on the field, shows), and put back as it closes. Some maps
; scroll plane B separately: use its scroll difference from plane A to find
; the cells actually behind the portrait. A partial-tile offset needs one
; more row or column. The saved cells fit before VWF_RAM in text_buffer.
; a0 = the portrait's stack entry.
PM_PlaneBBlank:
	movem.l	d0-d6/a1-a3, -(sp)
	move.w	(a0), d0
	move.w	($FFFFF61E).w, d5	; plane B vertical scroll minus plane A
	sub.w	($FFFFF61C).w, d5
	moveq	#10, d6
	move.w	d5, d1
	andi.w	#7, d1
	beq.s	+
	addq.w	#1, d6
+
	move.b	d6, (PM_PLANEB_SIZE+1).w
	asr.w	#3, d5
	lsl.w	#7, d5			; plane B row stride
	add.w	d5, d0
	move.w	($FFFFF622).w, d5	; plane B horizontal scroll minus plane A
	sub.w	($FFFFF620).w, d5
	moveq	#10, d6
	move.w	d5, d1
	andi.w	#7, d1
	beq.s	+
	addq.w	#1, d6
+
	move.b	d6, (PM_PLANEB_SIZE).w
	asr.w	#3, d5
	add.w	d5, d5			; two bytes per cell
	add.w	d5, d0
	move.w	d0, (PM_PLANEB).w
	moveq	#0, d4			; save and blank
	bra.s	PMB_walk
PM_PlaneBBack:
	movem.l	d0-d6/a1-a3, -(sp)
	move.w	(PM_PLANEB).w, d0
	beq.w	PMB_done
	clr.w	(PM_PLANEB).w
	moveq	#1, d4			; put back
PMB_walk:
	lea	(PM_PLANEB_SAVE).w, a1
	lea	(vdp_control_port).l, a2
	lea	(vdp_data_port).l, a3
	andi.w	#$FFF, d0		; the window's corner in the plane
	moveq	#0, d3
	move.b	(PM_PLANEB_SIZE+1).w, d3
	subq.w	#1, d3
PMB_row:
	addi.w	#$80, d0
	andi.w	#$FFF, d0
	move.w	d0, d1
	moveq	#0, d2
	move.b	(PM_PLANEB_SIZE).w, d2
	subq.w	#1, d2
PMB_cell:
	move.w	d1, d5			; the next cell of the row (wrapping in it)
	andi.w	#$F80, d5
	addq.w	#2, d1
	andi.w	#$7F, d1
	or.w	d5, d1
	move.w	d1, d6
	move	sr, -(sp)
	move	#$2700, sr		; the vertical blank talks to the VDP too
	tst.w	d4
	bne.s	PMB_back
	ori.w	#$2000, d6		; read VRAM $E000 + the cell
	move.w	d6, (a2)
	move.w	#3, (a2)
	move.w	(a3), (a1)+
	ori.w	#$4000, d6		; write it: tile 0
	move.w	d6, (a2)
	move.w	#3, (a2)
	move.w	#0, (a3)
	bra.s	PMB_next
PMB_back:
	ori.w	#$6000, d6
	move.w	d6, (a2)
	move.w	#3, (a2)
	move.w	(a1)+, (a3)
PMB_next:
	move	(sp)+, sr
	dbf	d2, PMB_cell
	dbf	d3, PMB_row
PMB_done:
	movem.l	(sp)+, d0-d6/a1-a3
	rts

; Is the cell (row d0, column d1) inside the stacked window at a0? Z set if so.
; d5/d6 = the camera's row and column.
PM_InWindow:
	movem.l	d0-d3, -(sp)
	move.w	(a0), d2
	move.w	d2, d3
	lsr.w	#7, d2
	andi.w	#$1F, d2
	sub.w	d5, d2
	andi.w	#$1F, d2		; the window's top row on the screen
	andi.w	#$7F, d3
	lsr.w	#1, d3
	sub.w	d6, d3
	andi.w	#$3F, d3		; its left column
	sub.w	d2, d0
	bmi.s	.out
	cmp.w	$C(a0), d0		; rows: the height byte + 1
	bhi.s	.out
	sub.w	d3, d1
	bmi.s	.out
	cmp.w	$A(a0), d1		; columns: the width byte + 1
	bhi.s	.out
	movem.l	(sp)+, d0-d3
	ori.b	#4, ccr
	rts
.out:
	movem.l	(sp)+, d0-d3
	andi.b	#$FB, ccr
	rts

PM_PanelPlace	= $4000|(PM_PANEL_ROW<<7)|(PM_PANEL_COL*2)
PM_PanelLayouts:			; by party size; size bytes: width + 1, height - 1
	rept	4
	dc.w	PM_PanelPlace
	dc.l	PM_PANEL_ART&$FFFFFF
	dc.b	PM_PANEL_W+1, 4*(1+(*-PM_PanelLayouts)/8)
	endm

; The status screen: per variant its ID, then its record (place: $4000 + row *
; $80 + column * 2; size bytes: width + 1, height - 1). 40 x 28 cells.
PM_VariantLayouts:
	dc.w	PM_ID_PORTRAIT		; columns 1-12, rows 1-12
	dc.w	$4000|(1<<7)|(1*2)
	dc.l	PM_PORT_ART&$FFFFFF
	dc.b	11, 11
	dc.w	PM_ID_INFO		; columns 13-26, rows 1-10
	dc.w	$4000|(1<<7)|(13*2)
	dc.l	PM_INFO_ART&$FFFFFF
	dc.b	PM_INFO_W+1, 9
	dc.w	PM_ID_STATS		; columns 27-39, rows 1-15: over the panel
	dc.w	$4000|(1<<7)|(27*2)
	dc.l	(window_art_buffer&$FFFFFF)+WinArt_StrngStats-DynamicWindowsStart
	dc.b	$0C, $0E
	dc.w	PM_ID_EXP		; columns 27-39, rows 20-24
	dc.w	$4000|(20<<7)|(27*2)
	dc.l	PM_EXP_ART&$FFFFFF
	dc.b	PM_EXP_W+1, 4
	dc.w	PM_ID_EQUIP		; columns 1-17, rows 13-24
	dc.w	$4000|(13<<7)|(1*2)
	dc.l	(window_art_buffer&$FFFFFF)+WinArt_StrngEquip-DynamicWindowsStart
	dc.b	$10, $0B
	dc.w	0

PM_MenuInput:
	lea	($FFFFDE80).w, a0
	move.b	(joypad_pressed).w, d0
	btst	#Button_B, d0
	bne.s	PM_Close
	btst	#Button_C, d0
	beq.s	.normal
	clr.w	(PM_ROSTER_FLAG).w
.normal:
	jmp	(loc_11060).l

PM_Close:
	clr.w	(PM_ROSTER_FLAG).w
	bsr.w	PM_PlaneBBack		; a status screen closing with the rest
	jmp	(CloseAllWindows).l

; The stock Strength path already provides character -> stats -> techniques.
; The second stage is the stock Status/Order choice; Order keeps its routine.
PM_StatusEntry:
	cmpi.w	#1, d1
	beq.s	.choice
	cmpi.w	#2, d1
	bne.s	.after_choice
	tst.w	$FFFFDE92.w
	bne.s	.order
	jmp	(loc_AA88).l
.choice:
	jmp	(loc_A440).l
.order:
	jmp	(loc_A48A).l
.after_choice:
	cmpi.w	#3, d1
	beq.s	.stats
	cmpi.w	#4, d1
	beq.s	.techniques
	bra.s	PM_Close
.stats:
	bra.w	PM_StatsOpen
.techniques:
	jmp	(loc_AAAA).l

PM_MenuLayout:				; size bytes: width + 1, height - 1
	dc.b	$40, $82
	dc.l	PM_MenuArt
	dc.b	PM_MENU_W+1, $09
PM_MesetaLayout:			; columns 1-12, rows 25-27: the bottom left, as PS IV's
	dc.w	$4000|(25<<7)|(1*2)
	dc.l	(window_art_buffer&$FFFFFF)+WinArt_Meseta-DynamicWindowsStart
	dc.b	$0C, $02

; The stock art's rows (a cursor box and the label cells, a blank row) with
; seven label cells where the stock has five ("Techniques"): gentext places
; the labels (pm_width in work/script.json) by row and column.
PM_MENU_W	= 2+7
PM_MenuArt:				; $26 the blank tile
	border PM_MENU_W, $B9
	rept	4
	dc.b	$B4, $B5
	rept	PM_MENU_W-2
	dc.b	$26
	endm
	rept	PM_MENU_W
	dc.b	$26
	endm
	endm
	border PM_MENU_W, $BE
	even
	endif

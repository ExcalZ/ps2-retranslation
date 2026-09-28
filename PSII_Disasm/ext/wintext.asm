; =============================================================================
; vwf_windows: proportional text in the menus, lists and other windows.
;
; A window is drawn by loc_978C from its art - one byte per cell, the cell's
; tile being $500 + byte (the font) - over a few frames, and loc_9872 puts the
; saved plane back when it closes. Names reach the art through six loops that
; turn text bytes into font tiles (items, techniques, enemies, places, the save
; files); the stock renders each letter as one 8-px cell.
;
; Here those loops write blank cells and record a *run* instead: where in the
; art the name goes, how many cells it has and where its text is (WT_Register).
; When a window has been drawn in full (WT_WindowDrawn, hooked in loc_947A)
; the runs that fall in its art are drawn in the proportional face into tiles
; of a pool, and the run's cells on the plane are pointed at them (the word
; read back from VRAM keeps the window's priority and palette bits). Party
; names reach the art as four marker bytes ($81 + the character, SetCharNames),
; which the same pass finds and draws from the character's six-letter name.
;
; The pool is the VRAM no screen of that kind uses (work/scripts/mapaudit.py,
; battleaudit.py over every map, building and battle background with full
; parties): the field and the buildings $23A-$2FF, $780-$7FF and $6E0-$6FF,
; battles $26D-$27F, $2E7-$2FF, $3DD-$3FF, $7E9-$7FF and $6B0-$6FF (the
; dialogue ring keeps two slots there), the title and intro $313-$3FF. Windows
; open and close as a stack: window n takes tiles from where window n-1's end,
; so closing one - or a new screen resetting the stack - frees its tiles.
; Only cells that hold ink get a tile; the rest keep the blank one.
;
; RAM: $FFFF8C00-$FFFF8FFF, past the dynamic window art ($8000-$8B4D, the
; only user of that block; zero in every RAM image taken).
; =============================================================================
	if vwf_windows

WT_RUNS		= $FFFF8C00		; 48 runs x 8: art address.w, cells.b, kind.b, data.l
WT_RUNS_N	= 48
WT_END		= $FFFF8D80		; 16 words: the pool index after window slot n's tiles
WT_CANVAS	= $FFFF8DA0		; 17 cells x 8 rows, cell-major (the 17th takes a spill)
WT_CELLS_MAX	= 16
WT_OVERFLOW	= $FFFF8E30		; word: runs that found no tiles (the harness reads it)
WT_HUD_MODE	= $FFFF8E32		; word: the window being drawn is outside the stack
WT_HUD_BUMP	= $FFFF8E34		; word: the lowest index the unstacked windows hold
WT_HUD_SCREEN	= $FFFF8E36		; byte: the screen those windows belong to
WT_TEXTBUF	= $FFFF8E80		; 32 bytes: a word copied in letter tiles, as text
WT_HUD		= $FFFF8E40		; 16 x (plane address.w, top index.w): the unstacked windows
WT_HUD_N	= 16
WT_RUN_KIND_TEXT	= 1		; data = text bytes, one a byte, ended by $C4
WT_RUN_KIND_ODD		= 2		; data = text bytes on odd addresses (backup RAM)
WT_RUN_KIND_NAME	= 3		; data = the character (a party-name marker run)

; The pool, per kind of screen: (first tile, tile after the last) ranges, 0-ended.
WT_PoolField:
	dc.w	$23A, $300,  $780, $800,  $6E0, $700,  0
WT_PoolBattle:
	dc.w	$26D, $280,  $2E7, $300,  $3DD, $400,  $7E9, $800,  $6B0, $700,  0
WT_PoolTitle:
	dc.w	$313, $400,  0

; ---------------------------------------------------------------------------
; The name loops: a1 = the art, the source per loop, d2 = cells - 1, d3 = 0 for
; the dakuten row (blank in the US font anyway), 1 for the letter row. Each
; leaves a1 past the cells, the source past what it read and d2 = -1, as the
; stock loop does.
; ---------------------------------------------------------------------------
WT_LoopA3:				; loc_F96C (items), loc_FF2E / loc_10342 (techniques), loc_10EA0 (enemies)
	movem.l	d0/d3-d7/a0, -(sp)	; the stock loop changes only d1, d2, a4 and its pointers
	movea.l	a3, a0
	moveq	#WT_RUN_KIND_TEXT, d5
	bsr.s	WT_Loop
	adda.w	d4, a3
	movem.l	(sp)+, d0/d3-d7/a0
	moveq	#-1, d2
	rts

WT_LoopA0:				; loc_10F94 (places, soundtracks): count in d5, d2 is the caller's
	movem.l	d0/d2-d4/d6-d7/a2, -(sp)
	move.w	d5, d2
	moveq	#WT_RUN_KIND_TEXT, d5
	bsr.s	WT_Loop
	adda.w	d4, a0
	movem.l	(sp)+, d0/d2-d4/d6-d7/a2
	moveq	#-1, d5
	rts

WT_LoopA2Odd:				; loc_10522 (save-file names in backup RAM)
	movem.l	d0/d3-d7/a0, -(sp)
	movea.l	a2, a0
	moveq	#WT_RUN_KIND_ODD, d5
	bsr.s	WT_Loop
	adda.w	d4, a2
	adda.w	d4, a2
	movem.l	(sp)+, d0/d3-d7/a0
	moveq	#-1, d2
	rts

; d2 = cells - 1, d3 = the row, d5 = the kind, a0 = the text; returns d4 = cells.
WT_Loop:
	moveq	#0, d4
	move.w	d2, d4
	addq.w	#1, d4
	tst.w	d3
	beq.s	WT_Loop_Blank
	bsr.w	WT_Register
WT_Loop_Blank:
	move.w	d4, d0
	subq.w	#1, d0
-
	move.b	#$26, (a1)+
	dbf	d0, -
	moveq	#-1, d2
	rts

; Record a run: a1 = its first cell in the art, d4 = cells, d5 = kind, a0 = data.
; A run already recorded at an overlapping place in the art is replaced.
WT_Register:
	movem.l	d0-d3/d6/a2/a4, -(sp)
	lea	(WT_RUNS).w, a2
	moveq	#WT_RUNS_N-1, d0
	move.w	a1, d1			; the art address (the block is below $10000)
	move.w	d1, d2
	add.w	d4, d2			; its end
	suba.l	a4, a4			; the first free entry
WT_Register_Scan:
	move.w	(a2), d3
	beq.s	WT_Register_Free
	cmp.w	d2, d3
	bcc.s	WT_Register_Next	; starts after this run
	moveq	#0, d6
	move.b	2(a2), d6
	add.w	d3, d6
	cmp.w	d1, d6
	bls.s	WT_Register_Next	; ends before it
	clr.w	(a2)			; overlaps: forget it
WT_Register_Free:
	cmpa.w	#0, a4
	bne.s	WT_Register_Next
	movea.l	a2, a4
WT_Register_Next:
	addq.w	#8, a2
	dbf	d0, WT_Register_Scan
	cmpa.w	#0, a4
	beq.s	WT_Register_Full
	move.w	d1, (a4)+
	move.b	d4, (a4)+
	move.b	d5, (a4)+
	move.l	a0, (a4)
WT_Register_Full:
	movem.l	(sp)+, d0-d3/d6/a2/a4
	rts

; ---------------------------------------------------------------------------
; loc_947A calls this in place of `btst #2,(window_index).w` when the window
; in slot current_active_objects_num has been drawn in full; it ends with that
; btst, for the bne that follows the hook.
; ---------------------------------------------------------------------------
WT_WindowDrawn:
	movem.l	d0-d7/a0-a6, -(sp)
	move.w	(current_active_objects_num).w, d7
	andi.w	#$F, d7
	moveq	#0, d6			; the pool index: where window n-1's tiles end
	tst.w	d7
	beq.s	+
	lea	(WT_END-2).w, a0
	move.w	d7, d0
	add.w	d0, d0
	move.w	(a0,d0.w), d6
+
	lea	($FFFFDF00).w, a6	; the window's entry
	move.w	d7, d0
	lsl.w	#4, d0
	adda.w	d0, a6
	clr.w	(WT_HUD_MODE).w
	btst	#2, (window_index).w	; a window drawn outside the stack (the battle box's)
	beq.s	+
	bsr.w	WT_HudStart		; d6 = its tiles' top, counted down
+
	move.l	6(a6), d0		; its art
	cmpi.l	#$FF0000, d0
	bcs.w	WT_Drawn_Static
	; the runs recorded in its art
	move.w	$A(a6), d2
	subq.w	#1, d2
	move.w	$C(a6), d3
	addq.w	#1, d3
	mulu.w	d3, d2			; the art's size
	move.w	d0, d3			; its start (low word)
	lea	(WT_RUNS).w, a5
	moveq	#WT_RUNS_N-1, d5
WT_Drawn_Run:
	move.w	(a5), d0
	beq.s	WT_Drawn_RunNext
	sub.w	d3, d0
	bcs.s	WT_Drawn_RunNext
	cmp.w	d2, d0
	bcc.s	WT_Drawn_RunNext
	movem.w	d2-d3, -(sp)
	moveq	#0, d4
	move.b	2(a5), d4
	moveq	#0, d1
	move.b	3(a5), d1
	movea.l	4(a5), a0
	bsr.w	WT_DrawRun
	movem.w	(sp)+, d2-d3
WT_Drawn_RunNext:
	addq.w	#8, a5
	dbf	d5, WT_Drawn_Run
	; party names: runs of a marker byte $81 + the character
	movea.l	6(a6), a5
	moveq	#0, d0			; the offset
WT_Drawn_Marker:
	moveq	#0, d1
	move.b	(a5,d0.w), d1
	subi.b	#$81, d1
	cmpi.b	#8, d1
	bcc.s	WT_Drawn_MarkerNext
	moveq	#1, d4			; the run's length
-
	move.w	d0, d5
	add.w	d4, d5
	cmp.w	d2, d5
	bcc.s	+
	move.b	(a5,d5.w), d5
	subi.b	#$81, d5
	cmp.b	d1, d5
	bne.s	+
	addq.w	#1, d4
	bra.s	-
+
	movem.w	d0/d2/d4, -(sp)
	movea.w	d1, a0			; the character
	moveq	#WT_RUN_KIND_NAME, d1
	bsr.w	WT_DrawRun
	movem.w	(sp)+, d0/d2/d4
	add.w	d4, d0
	bra.s	WT_Drawn_MarkerTest
WT_Drawn_MarkerNext:
	addq.w	#1, d0
WT_Drawn_MarkerTest:
	cmp.w	d2, d0
	bcs.s	WT_Drawn_Marker
	; letters the code copied into the art (WHO?, ON?, NEXT, HP, the jobs...): the name
	; loops and the templates' labels are runs already, so letter tiles left here are
	; those; each word (single spaces inside) is redrawn, its cells reaching the next
	; thing in the row. Digits keep their cells.
	movea.l	6(a6), a5
	move.w	$A(a6), d1
	subq.w	#1, d1			; the row stride
	lea	(WT_Tile2Script).l, a4
	moveq	#0, d0			; the offset
WT_Drawn_Tile:
	cmp.w	d2, d0
	bcc.w	WT_Drawn_Static
	moveq	#0, d3
	move.b	(a5,d0.w), d3
	move.b	(a4,d3.w), d3
	beq.s	WT_Drawn_TileNext	; a space
	cmpi.b	#$FF, d3
	beq.s	WT_Drawn_TileNext	; no letter
	; the row's end
	moveq	#0, d5
	move.w	d0, d5
	divu.w	d1, d5
	addq.w	#1, d5
	mulu.w	d1, d5			; the offset where the next row starts
	lea	(WT_TEXTBUF).w, a0
	move.w	d0, d4
WT_Drawn_TileWord:
	cmp.w	d5, d4
	bcc.s	WT_Drawn_TileEnd
	moveq	#0, d3
	move.b	(a5,d4.w), d3
	move.b	(a4,d3.w), d3
	cmpi.b	#$FF, d3
	beq.s	WT_Drawn_TileEnd
	tst.b	d3
	bne.s	+
	move.w	d4, d3			; a space: part of the word if a letter follows it
	addq.w	#1, d3
	cmp.w	d5, d3
	bcc.s	WT_Drawn_TileEnd
	move.b	(a5,d3.w), d3
	move.b	(a4,d3.w), d3
	beq.s	WT_Drawn_TileEnd
	cmpi.b	#$FF, d3
	beq.s	WT_Drawn_TileEnd
	moveq	#0, d3
+
	move.b	d3, (a0)+
	addq.w	#1, d4
	bra.s	WT_Drawn_TileWord
WT_Drawn_TileEnd:
	move.b	#$C4, (a0)
-
	cmp.w	d5, d4			; the cells reach over the spaces after it
	bcc.s	+
	cmpi.b	#$26, (a5,d4.w)
	bne.s	+
	addq.w	#1, d4
	bra.s	-
+
	sub.w	d0, d4			; cells
	movem.w	d0-d2/d4, -(sp)
	lea	(WT_TEXTBUF).w, a0
	moveq	#WT_RUN_KIND_TEXT, d1
	bsr.w	WT_DrawRun
	movem.w	(sp)+, d0-d2/d4
	add.w	d4, d0
	bra.w	WT_Drawn_Tile
WT_Drawn_TileNext:
	addq.w	#1, d0
	bra.w	WT_Drawn_Tile
	; then a template's own labels, in WT_StaticRuns too

WT_Drawn_Static:			; the window's own text (fixed art or a template's labels)
	lea	(WT_StaticRuns).l, a5
-
	move.l	(a5)+, d1		; the art the run belongs to
	beq.s	WT_Drawn_Done
	moveq	#0, d0
	move.w	(a5)+, d0		; offset
	moveq	#0, d4
	move.w	(a5)+, d4		; cells
	movea.l	(a5)+, a0		; text
	cmp.l	6(a6), d1
	bne.s	-
	moveq	#WT_RUN_KIND_TEXT, d1
	bsr.w	WT_DrawRun
	bra.s	-

WT_Drawn_Done:
	tst.w	(WT_HUD_MODE).w
	beq.s	+
	cmp.w	(WT_HUD_BUMP).w, d6
	bcc.s	++
	move.w	d6, (WT_HUD_BUMP).w	; the next unstacked window starts below this one
	bra.s	++
+
	lea	(WT_END).w, a0
	add.w	d7, d7
	move.w	d6, (a0,d7.w)
+
	movem.l	(sp)+, d0-d7/a0-a6
	btst	#2, (window_index).w
	rts

; ---------------------------------------------------------------------------
; loc_94EE: a window is closing (its slot is current_active_objects_num once
; decremented). Its tiles are free again: nothing to do but keep the stock
; `andi.w #$F` this hook replaces - the next window drawn in the slot starts
; from WT_END of the slot below.
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; Draw one run: d0 = its offset in the window's art, d4 = cells, d1 = kind,
; a0 = data, a6 = the window's entry, d6 = the pool index (advanced).
; ---------------------------------------------------------------------------
WT_DrawRun:
	movem.l	d0-d5/d7/a0-a5, -(sp)
	cmpi.w	#WT_CELLS_MAX, d4
	bls.s	+
	moveq	#WT_CELLS_MAX, d4
+
	movea.w	d4, a5			; the run's cells
	; where: row d0 / (width - 1), column the rest + 1 (the left border)
	move.w	$A(a6), d2
	subq.w	#1, d2
	andi.l	#$FFFF, d0		; divu divides the whole longword
	divu.w	d2, d0
	move.l	d0, d7			; row in the low word, column - 1 in the high
	bsr.w	WT_Render		; the canvas; d3 = cells holding ink
	tst.w	d3
	beq.w	WT_DrawRun_Done
	lea	(vdp_control_port).l, a2
	lea	(vdp_data_port).l, a3
	move.w	#$8F02, (a2)
	; the run's first cell on the plane
	move.w	(a6), d5		; the window's corner (VDP address high word)
	move.w	d7, d0
	lsl.w	#7, d0
	add.w	d0, d5			; + rows
	andi.w	#$EFFF, d5
	swap	d7
	addq.w	#1, d7			; the column
	add.w	d7, d7
	moveq	#0, d2			; the cell
WT_DrawRun_Cell:
	tst.w	(WT_HUD_MODE).w
	beq.s	WT_DrawRun_Up
	subq.w	#1, d6			; an unstacked window: downwards from its top
	bmi.w	WT_DrawRun_FullHud
	bsr.w	WT_PoolTile
	bmi.w	WT_DrawRun_Full
	bra.s	WT_DrawRun_Got
WT_DrawRun_Up:
	bsr.w	WT_HudFloor		; a stacked window: up to the unstacked ones' tiles
	cmp.w	d0, d6
	bcc.w	WT_DrawRun_Full
	bsr.w	WT_PoolTile		; d0 = tile for index d6, or -1
	bmi.w	WT_DrawRun_Full
	addq.w	#1, d6
WT_DrawRun_Got:
	move.w	d0, d1			; the tile
	moveq	#0, d4			; VRAM write at tile d0
	move.w	d0, d4
	lsl.l	#5, d4
	lsl.l	#2, d4
	lsr.w	#2, d4
	swap	d4
	ori.l	#$40000000, d4
	move.l	d4, (a2)
	lea	(WT_CANVAS).w, a4
	move.w	d2, d0
	lsl.w	#3, d0
	adda.w	d0, a4
	lea	(VWF_Expand).l, a0
	moveq	#7, d0
-
	moveq	#0, d4
	move.b	(a4)+, d4
	lsl.w	#2, d4
	move.l	(a0,d4.w), (a3)
	dbf	d0, -
	; the cell: keep its priority and palette, point it at the tile
	move.w	d5, d0
	move.w	d0, d4
	andi.w	#$FF80, d4
	add.b	d7, d0
	andi.w	#$7F, d0
	or.w	d4, d0			; the cell's address (VDP high word, write form)
	move.w	d0, d4
	andi.w	#$3FFF, d0		; read
	move.w	d0, (a2)
	move.w	#3, (a2)
	move.w	(a3), d0
	andi.w	#$F800, d0
	or.w	d1, d0
	move.w	d4, (a2)		; write
	move.w	#3, (a2)
	move.w	d0, (a3)
	addq.w	#2, d7
	addq.w	#1, d2
	cmp.w	d3, d2
	bcs.w	WT_DrawRun_Cell
WT_DrawRun_Blank:			; the cells past the ink: blank (a label copied in fixed
	move.w	a5, d0			; letters may be longer than its proportional form)
	cmp.w	d0, d2
	bcc.s	WT_DrawRun_Done
	move.w	d5, d0
	move.w	d0, d4
	andi.w	#$FF80, d4
	add.b	d7, d0
	andi.w	#$7F, d0
	or.w	d4, d0
	move.w	d0, d4
	andi.w	#$3FFF, d0
	move.w	d0, (a2)
	move.w	#3, (a2)
	move.w	(a3), d0
	andi.w	#$F800, d0
	ori.w	#$526, d0		; the font's blank
	move.w	d4, (a2)
	move.w	#3, (a2)
	move.w	d0, (a3)
	addq.w	#2, d7
	addq.w	#1, d2
	bra.s	WT_DrawRun_Blank
WT_DrawRun_FullHud:
	moveq	#0, d6
WT_DrawRun_Full:
	addq.w	#1, (WT_OVERFLOW).w
WT_DrawRun_Done:
	movem.l	(sp)+, d0-d5/d7/a0-a5	; d6, the pool index, goes back advanced
	rts

; ---------------------------------------------------------------------------
; Windows outside the stack (window_index bit 2: drawn without saving what they
; cover, never closed on their own - the battle box's windows): each keeps its
; own tiles, counted down from the pool's end, for as long as the screen lasts;
; drawn again at the same place, it gets the same tiles. d6 = its top index.
; ---------------------------------------------------------------------------
WT_HudStart:
	movem.l	d0-d2/a0, -(sp)
	move.w	#1, (WT_HUD_MODE).w
	move.b	(game_screen).w, d0
	cmp.b	(WT_HUD_SCREEN).w, d0
	beq.s	+
	move.b	d0, (WT_HUD_SCREEN).w	; another screen: forget the old ones
	lea	(WT_HUD).w, a0
	moveq	#WT_HUD_N*4/4-1, d1
-
	clr.l	(a0)+
	dbf	d1, -
	bsr.w	WT_PoolSize
	move.w	d0, (WT_HUD_BUMP).w
+
	move.w	(a6), d1		; the window's place
	lea	(WT_HUD).w, a0
	moveq	#WT_HUD_N-1, d2
-
	cmp.w	(a0), d1
	beq.s	WT_HudStart_Known
	tst.w	(a0)
	beq.s	WT_HudStart_New
	addq.w	#4, a0
	dbf	d2, -
	move.w	(WT_HUD_BUMP).w, d6	; the table is full: new tiles, not remembered
	bra.s	WT_HudStart_Done
WT_HudStart_New:
	move.w	d1, (a0)+
	move.w	(WT_HUD_BUMP).w, (a0)
	move.w	(WT_HUD_BUMP).w, d6
	bra.s	WT_HudStart_Done
WT_HudStart_Known:
	move.w	2(a0), d6
WT_HudStart_Done:
	movem.l	(sp)+, d0-d2/a0
	rts

; d0 = where the stacked windows must stop: the unstacked windows' lowest index on
; this screen, or the pool's size.
WT_HudFloor:
	move.b	(game_screen).w, d0
	cmp.b	(WT_HUD_SCREEN).w, d0
	bne.s	WT_PoolSize
	move.w	(WT_HUD_BUMP).w, d0
	rts

; d0 = the number of tiles in this screen's pool.
WT_PoolSize:
	movem.l	d1/a0, -(sp)
	bsr.w	WT_PoolFor
	moveq	#0, d0
-
	move.w	(a0)+, d1
	beq.s	+
	neg.w	d1
	add.w	(a0)+, d1
	add.w	d1, d0
	bra.s	-
+
	movem.l	(sp)+, d1/a0
	rts

; a0 = the pool's ranges for this kind of screen.
WT_PoolFor:
	move.w	d0, -(sp)
	lea	(WT_PoolField).l, a0
	move.b	(game_screen).w, d0
	cmpi.b	#ScreenID_Battle, d0
	bne.s	+
	lea	(WT_PoolBattle).l, a0
+
	cmpi.b	#ScreenID_Title, d0
	beq.s	+
	cmpi.b	#ScreenID_Intro, d0
	bne.s	++
+
	lea	(WT_PoolTitle).l, a0
+
	move.w	(sp)+, d0
	rts

WT_Tile2Script:				; a window art byte -> its letter's text byte, $FF: no letter
	binclude	"vwf/tile2script.bin"

; ---------------------------------------------------------------------------
; d0 = the tile of pool index d6 for this kind of screen, or -1 (and N set)
; when the pool is used up.
; ---------------------------------------------------------------------------
WT_PoolTile:
	movem.l	d1/a0, -(sp)
	bsr.w	WT_PoolFor
	move.w	d6, d1
-
	move.w	(a0)+, d0
	beq.s	WT_PoolTile_None
	neg.w	d0
	add.w	(a0)+, d0		; the range's size
	cmp.w	d0, d1
	bcs.s	+
	sub.w	d0, d1
	bra.s	-
+
	move.w	-4(a0), d0
	add.w	d1, d0
	movem.l	(sp)+, d1/a0
	tst.w	d0
	rts
WT_PoolTile_None:
	moveq	#-1, d0
	movem.l	(sp)+, d1/a0
	rts

; ---------------------------------------------------------------------------
; Draw a run's text into the canvas: d1 = kind, a0 = data, d4 = cells.
; Returns d3 = the cells up to the last one holding ink.
; ---------------------------------------------------------------------------
WT_Render:
	movem.l	d0-d2/d4-d7/a0-a5, -(sp)
	lea	(WT_CANVAS).w, a1
	moveq	#(WT_CELLS_MAX+1)*8/4-1, d0
-
	clr.l	(a1)+
	dbf	d0, -
	move.w	d4, d7
	lsl.w	#3, d7			; the pixels the run holds
	moveq	#0, d6			; the pen
	moveq	#0, d3			; ink seen up to this pixel
	cmpi.b	#WT_RUN_KIND_NAME, d1
	beq.s	WT_Render_Name
	move.w	d4, d5			; at most one letter a cell (the record's length)
	subq.w	#1, d5
	moveq	#1, d2			; the step between bytes
	if long_item_names
	cmpi.b	#WT_RUN_KIND_TEXT, d1
	bne.s	WT_Render_Short
	bsr.w	LN_Lookup		; a name in a record: its long name
	beq.s	WT_Render_Short
	moveq	#31, d5			; ended by its $C4, held to the run's pixels
WT_Render_Short:
	endif
	cmpi.b	#WT_RUN_KIND_ODD, d1
	bne.s	WT_Render_Text
	moveq	#2, d2
WT_Render_Text:
	moveq	#0, d1
	move.b	(a0), d1
	adda.w	d2, a0
	cmpi.b	#$C4, d1
	beq.s	WT_Render_End
	bsr.s	WT_Glyph
	dbf	d5, WT_Render_Text
	bra.s	WT_Render_End
WT_Render_Name:				; a0 = the character: character_names, then letters 5-6
	move.w	a0, d4
	lea	(character_names).w, a2
	move.w	d4, d0
	lsl.w	#2, d0
	adda.w	d0, a2
	moveq	#3, d5
-
	moveq	#0, d1
	move.b	(a2)+, d1
	cmpi.b	#$C4, d1
	beq.s	WT_Render_End
	bsr.s	WT_Glyph
	dbf	d5, -
	if long_names
	lea	(NAME_EXT).w, a2
	add.w	d4, d4
	adda.w	d4, a2
	moveq	#1, d5
-
	moveq	#0, d1
	move.b	(a2)+, d1
	cmpi.b	#$C4, d1
	beq.s	WT_Render_End
	tst.b	d1
	beq.s	WT_Render_End
	bsr.s	WT_Glyph
	dbf	d5, -
	endif
WT_Render_End:
	addq.w	#7, d3			; the cells holding ink
	lsr.w	#3, d3
	movem.l	(sp)+, d0-d2/d4-d7/a0-a5
	rts

; OR letter d1 into the canvas at pen d6 (d7 = the run's pixels) and advance;
; d3 = the pixel after the last ink so far. A letter that would not fit is dropped.
WT_Glyph:
	movem.l	d0-d2/d4-d5/a0-a1, -(sp)
	lea	(VWF_Width).l, a0
	moveq	#0, d2
	move.b	(a0,d1.w), d2		; advance
	move.w	d6, d0
	add.w	d2, d0
	subq.w	#1, d0			; the pixel after the letter's ink
	cmp.w	d7, d0
	bhi.s	WT_Glyph_Done
	lea	(VWF_Font).l, a0
	lsl.w	#3, d1
	adda.w	d1, a0
	moveq	#0, d5			; ink seen
	move.w	d6, d4
	lsr.w	#3, d4
	lsl.w	#3, d4
	lea	(WT_CANVAS).w, a1
	adda.w	d4, a1
	move.w	d6, d4
	andi.w	#7, d4
	moveq	#7, d1
-
	moveq	#0, d2
	move.b	(a0)+, d2
	beq.s	+
	moveq	#1, d5
	lsl.w	#8, d2
	lsr.w	d4, d2
	or.b	d2, 8(a1)
	lsr.w	#8, d2
	or.b	d2, (a1)
+
	addq.w	#1, a1
	dbf	d1, -
	tst.w	d5
	beq.s	+
	move.w	d0, d3			; ink reaches this far
+
	move.w	d0, d6			; the pen moves past the letter and its gap
	addq.w	#1, d6
WT_Glyph_Done:
	movem.l	(sp)+, d0-d2/d4-d5/a0-a1
	rts

	endif


; =============================================================================
; vwf_dialogue: proportional text in the script windows.
;
; The stock text engine types one character a frame: RunScript hands each byte
; of text_buffer to DrawScriptToVDP, which writes two plane A cells at the
; cursor ($CD16) - the upper one blank (the JP font's dakuten row), the lower
; one the letter's font tile - and moves the cursor one cell right. A window
; line is 24 cells (20 in the battle box).
;
; Here a line is composed instead: every letter's 1bpp rows (vwf/diafont.bin,
; advance in vwf/diawidth.bin) are OR-ed into a canvas of 24 cells at the pen
; position, and only the one or two cells the letter touched are expanded to
; 4bpp (ink colour 1, paper $B, as the font) and copied to the line's tiles, so
; the typing keeps its pace. When a line starts - the first letter drawn at
; the start of a text row - it takes the next of four slots of 24 tiles in
; the pool, clears them to paper and points the row's cells at them once.
; Scrolling (loc_9666, loc_96AE) copies and clears those cells as it does the
; stock ones, and the four slots outlast the four lines the big window shows.
;
; The pool is VRAM $D000-$DFFF (tiles $680-$6FF): plane A is 64x32 cells at
; $C000-$CFFF, so the second half of its $2000-byte area is never read or
; written on any screen with a script window (work/scripts/vramstates.py and
; tools/vramaudit.py audited the title, the opening, the portrait scenes,
; the big window and the field). The final scene sets 64x64 planes and draws
; seven lines ($CD1C = $C): those windows keep the stock renderer.
;
; RAM: the tail of text_buffer ($CEC0-$CF8F), which paged_text_buffer leaves
; free (a page is at most $180 bytes, tools/linecheck.py).
; =============================================================================
	if vwf_dialogue

VWF_RAM		= text_buffer+$180
VWF_Canvas	= VWF_RAM		; 25 cells x 8 rows, cell-major; the 25th takes a letter's spill
VWF_Pen		= VWF_RAM+$C8		; pixel position of the pen on the line
VWF_Tile	= VWF_RAM+$CA		; the line's first pool tile
VWF_Cells	= VWF_RAM+$CC		; the window's cells per line (24; 20 in the battle box)
VWF_Lines	= VWF_RAM+$CE		; lines started, for the slot ring
VWF_POOL	= $680			; VRAM $D000

; DrawScriptToVDP jumps here. d1 = the text byte, a1 = its place in text_buffer,
; a2/a3 = the VDP control/data ports. As the stock routine: a1 advances by one,
; d0-d2 and a4 are free.
VWF_Draw:
	cmpi.w	#6, ($FFFFCD1C).w
	bhi.w	VWF_Draw_Stock		; the final scene's tall text keeps the stock cells
	movem.l	d3-d7/a0/a5, -(sp)
	move.w	#$8F02, (a2)		; auto-increment 2 for the tile copies
	move.w	($FFFFCD1A).w, d0	; the cursor at the start of its text row: a new line
	lsl.w	#7, d0
	add.w	($FFFFCD18).w, d0
	andi.w	#$CFFF, d0
	move.w	($FFFFCD16).w, d2
	andi.w	#$CFFF, d2
	cmp.w	d0, d2
	bne.s	+
	bsr.w	VWF_NewLine
+
	andi.w	#$FF, d1
	bsr.w	VWF_Glyph
	move.w	($FFFFCD16).w, d0	; the stock cursor advance: one cell
	move.b	d0, d1
	andi.b	#$80, d1
	addq.b	#2, d0
	andi.b	#$7F, d0
	or.b	d1, d0
	andi.w	#$EFFF, d0
	move.w	d0, ($FFFFCD16).w
	addq.w	#1, a1
	movem.l	(sp)+, d3-d7/a0/a5
	rts

VWF_Draw_Stock:
	add.w	d1, d1
	lea	(VDPCharacterMaps).l, a4
	jmp	(DrawScriptToVDP_Stock).l

; ---------------------------------------------------------------------------
; A new line: the next slot of the ring, cleared to paper, and the text row's
; letter cells pointed at it.
; ---------------------------------------------------------------------------
VWF_NewLine:
	move.w	(VWF_Lines).w, d0
	addq.w	#1, (VWF_Lines).w
	andi.w	#3, d0
	mulu.w	#24, d0
	addi.w	#VWF_POOL, d0
	move.w	d0, (VWF_Tile).w
	clr.w	(VWF_Pen).w
	moveq	#24, d3
	tst.w	($FFFFCD1C).w
	bne.s	+
	moveq	#20, d3			; the battle box (the stock clear is 20 cells there too)
+
	move.w	d3, (VWF_Cells).w
	lea	(VWF_Canvas).w, a0
	moveq	#25*8/4-1, d4
-
	clr.l	(a0)+
	dbf	d4, -
	move.w	(VWF_Tile).w, d0
	bsr.w	VWF_VRAMWrite
	move.w	#24*8-1, d4
	move.l	#$BBBBBBBB, d5
-
	move.l	d5, (a3)
	dbf	d4, -
	move.w	($FFFFCD16).w, d0	; the letter row is the row below the cursor's
	addi.w	#$80, d0
	move.w	(VWF_Tile).w, d2
	ori.w	#$8000, d2		; priority, palette 0 - as the stock $8500 + tile
	subq.w	#1, d3
-
	andi.w	#$EFFF, d0
	move.w	d0, (a2)
	move.w	#3, (a2)
	move.w	d2, (a3)
	addq.w	#1, d2
	move.b	d0, d4			; next cell, wrapping in the plane's 64-cell row
	andi.b	#$80, d4
	addq.b	#2, d0
	andi.b	#$7F, d0
	or.b	d4, d0
	dbf	d3, -
	rts

; ---------------------------------------------------------------------------
; Draw text byte d1 at the pen and copy the cells it touched. A letter that
; would cross the end of the line is dropped (the proofreader flags the line).
; ---------------------------------------------------------------------------
VWF_Glyph:
	lea	(VWF_Width).l, a0
	moveq	#0, d3
	move.b	(a0,d1.w), d3		; advance
	move.w	(VWF_Pen).w, d4
	move.w	d4, d5
	add.w	d3, d5
	move.w	(VWF_Cells).w, d6
	lsl.w	#3, d6
	cmp.w	d6, d5
	bhi.s	VWF_Glyph_Done
	move.w	d5, (VWF_Pen).w
	lsl.w	#3, d1
	lea	(VWF_Font).l, a0
	adda.w	d1, a0			; the letter's rows
	move.w	d4, d7
	lsr.w	#3, d7			; its first cell
	andi.w	#7, d4			; and the pixel in that cell
	lea	(VWF_Canvas).w, a5
	move.w	d7, d0
	lsl.w	#3, d0
	adda.w	d0, a5
	moveq	#0, d5			; ink seen
	moveq	#7, d6
-
	moveq	#0, d0
	move.b	(a0)+, d0
	beq.s	+
	moveq	#1, d5
	lsl.w	#8, d0
	lsr.w	d4, d0
	or.b	d0, 8(a5)		; the part that spills into the next cell
	lsr.w	#8, d0
	or.b	d0, (a5)
+
	addq.w	#1, a5
	dbf	d6, -
	tst.w	d5
	beq.s	VWF_Glyph_Done		; a space moves the pen only
	bsr.s	VWF_Upload
	add.w	d3, d4
	cmpi.w	#8, d4
	bls.s	VWF_Glyph_Done
	addq.w	#1, d7
	cmp.w	(VWF_Cells).w, d7
	bcc.s	VWF_Glyph_Done
	bsr.s	VWF_Upload
VWF_Glyph_Done:
	rts

; Copy canvas cell d7 to its pool tile.
VWF_Upload:
	move.w	(VWF_Tile).w, d0
	add.w	d7, d0
	bsr.s	VWF_VRAMWrite
	lea	(VWF_Canvas).w, a5
	move.w	d7, d0
	lsl.w	#3, d0
	adda.w	d0, a5
	lea	(VWF_Expand).l, a0
	moveq	#7, d6
-
	moveq	#0, d0
	move.b	(a5)+, d0
	lsl.w	#2, d0
	move.l	(a0,d0.w), (a3)
	dbf	d6, -
	rts

; Set the VDP to write VRAM at tile d0.
VWF_VRAMWrite:
	moveq	#0, d6
	move.w	d0, d6
	lsl.l	#5, d6			; the address
	lsl.l	#2, d6			; bits 14-15 to the low word of the command's second half
	lsr.w	#2, d6
	swap	d6
	ori.l	#$40000000, d6
	move.l	d6, (a2)
	rts

VWF_Font:
	binclude	"vwf/diafont.bin"
VWF_Width:
	binclude	"vwf/diawidth.bin"
	even
VWF_Expand:				; a 1bpp byte -> 8 nibbles: ink 1, paper $B
	binclude	"vwf/expand.bin"

	endif

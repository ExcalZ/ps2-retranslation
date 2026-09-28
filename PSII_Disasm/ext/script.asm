; =============================================================================
; paged_text_buffer: LoadScript expands a message into text_buffer ($CD40-$CFFF)
; one page at a time.
;
; Stock LoadScript copies a whole message - every page, every insert - into the
; 704 bytes before the sound RAM; a long one (the Lutz scene) writes into the
; sound driver's RAM and the music stops. Here the expansion stops after each
; $C3 (the page wait) and records where the script continues; when the button
; releases the wait, the next page is expanded from there to the start of the
; buffer. RunScript and the window code read the buffer exactly as before.
;
; The resume state lives in the last eight bytes of the buffer, which no page
; reaches (tools/linecheck.py checks a page's expansion against 696 bytes).
; =============================================================================
	if paged_text_buffer

paged_resume	= text_buffer+$2B8	; script pointer after the $C3, or 0
paged_resume_a4	= text_buffer+$2BC	; LoadScript's party-member walker (a4)

; LoadScript's $C3 branch jumps here after storing the $C3.
PagedText_Stop:
	move.l	a1, (paged_resume).w
	move.l	a4, (paged_resume_a4).w
	move.w	#1, (window_active_flag).w
	rts			; out of LoadScript, as its end-code exit does

; LoadScript's end-code exit jumps here after storing the end code.
PagedText_End:
	move.w	#1, (window_active_flag).w
	clr.l	(paged_resume).w
	rts

; loc_FB56 jumps here when a button releases a page wait; a0 points past the $C3.
PagedText_Resume:
	move.l	a0, (text_buffer_pointer).w
	tst.l	(paged_resume).w
	beq.s	.done
	movem.l	d0-d4/a1-a4, -(sp)
	movea.l	(paged_resume).w, a1
	movea.l	(paged_resume_a4).w, a4
	clr.l	(paged_resume).w
	lea	(text_buffer).w, a2
	move.l	a2, (text_buffer_pointer).w
	bsr.s	.continue	; LoadScript's loop, from the point after the $C3
	movem.l	(sp)+, d0-d4/a1-a4
.done:
	rts
.continue:
	cmpi.b	#$C2, (a1)	; the stock $C3 branch: a clear follows directly,
	bne.s	.newline
	jmp	(LoadScript_ChkCharName).l
.newline:
	jmp	(loc_11250).l	; otherwise two line feeds start the next line

	endif

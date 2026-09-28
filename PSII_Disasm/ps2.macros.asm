nametxt macro text
	if strlen(text) > length
		warning	"The name \{text} is longer than \{length} characters"
	endif
	dc.b	text
	if strlen(text) < length
		dc.b	$C4
		rept length-(strlen(text)+1)
			dc.b	$00
		endm
	endif
	endm
	
border macro len, data
	rept len
		dc.b	data
	endm
	endm
	
cursorbox macro text
	dc.b	$B4, $B5, text
	endm

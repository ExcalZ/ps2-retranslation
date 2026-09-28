	cpu Z80
	listing off

PCMDrumsStart:
	di
	di
	ld	sp, 1FF0h
	ld	a, 80h
	ld	c, 2Bh
	call zloc_F
	jp	zloc_68
	
zloc_F:
	push af
	ld	a, 80h
	ld	(1FFDh), a
	ld	a, c
	ld	(4000h), a

zloc_19:
	ld	a, (4000h)
	bit	7, a
	jr	nz, zloc_19
	pop	af
	nop
	ld	(4001h), a
	xor	a
	ld	(1FFDh), a
	ret
	
	rept 14
		db	0
	endm
	
zVBlank:
	reti
	
	rept 44
		db	0
	endm
	
NMI_Handler:
	 retn
	
zloc_68:
	ld	a, (1FFFh)
	bit	7, a
	jp	z, zloc_96
	bit	0, a
	jp	nz, zloc_BA
	bit	1, a
	jp	nz, zloc_C5
	bit	2, a
	jp	nz, zloc_A4
	bit	3, a
	jp	nz, zloc_99
	bit	4, a
	jp	nz, zloc_E6
	bit	5, a
	jp	nz, zloc_D0
	bit	6, a
	jp	nz, zloc_DB
	jp	zloc_AF
	
zloc_96:
	jp	zloc_68
	
zloc_99:
	ld	de, zloc_118
	ld	hl, 181h
	ld	a, 5
	jp	zloc_EE
	
zloc_A4:
	ld	de, zloc_299
	ld	hl, 800h
	ld	a, 7
	jp	zloc_EE
	
zloc_AF:
	ld	de, zloc_A99
	ld	hl, 801h
	ld	a, 2
	jp	zloc_EE
	
zloc_BA:
	ld	de, zloc_A99
	ld	hl, 801h
	ld	a, 4
	jp	zloc_EE
	
zloc_C5:
	ld	de, zloc_A99
	ld	hl,	801h
	ld	a, 8
	jp	zloc_EE
	
zloc_D0:
	ld	de, zloc_129A
	ld	hl, 601h
	ld	a, 4
	jp	zloc_EE
	
zloc_DB:
	ld	de, zloc_189B
	ld	hl, 201h
	ld	a, 4
	jp	zloc_EE
	
zloc_E6:
	ld	de, zloc_1A9C
	ld	hl, 201h
	ld	a, 4
	
zloc_EE:
	ld	(1FFEh), a
	xor	a
	ld	(1FFFh), a
	ld	a, (1FFEh)
zloc_F8:
	ld	b, a
	
-	djnz -

	ex	af, af'
	ld	a, (de)
	srl	a
	ld	c, 2Ah
	call zloc_F
	inc	de
	dec	hl
	ld	a, l
	or	h
	jr	z, zloc_115
	ld	a, (1FFFh)
	or	a
	jp	nz, zloc_68
	ex	af, af'
	jp	zloc_F8
	
zloc_115:
	jp	zloc_68
	
zloc_118:
	db	78h, 6Eh, 58h, 51h, 4Ch, 00h, 00h, 00h
	db	00h, 00h, 02h, 00h, 00h, 04h, 00h, 04h, 00h, 00h, 11h, 8Dh, 00h, 33h, 00h, 7Dh
	db	0E2h, 0FFh, 0FFh, 0FFh, 0FFh, 92h, 0FFh, 4Eh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
	db	0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
	db	0A5h, 0CAh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 2Ch, 36h, 49h, 5Fh
	db	0B6h, 50h, 0FFh, 0D7h, 0D1h, 0FFh, 0FFh, 0EFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
	db	0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0EEh, 0FFh, 0FFh, 0FFh
	db	0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0BFh, 0FFh, 0FFh, 0ABh, 0E3h, 0EAh, 0A3h, 0FFh
	db	97h, 0A7h, 0B8h, 0BEh, 80h, 0E9h, 0C1h, 91h, 85h, 90h, 0C5h, 8Ch, 2Fh, 0B4h, 39h, 7Fh
	db	5Eh, 0AFh, 64h, 6Eh, 59h, 0E6h, 4Eh, 85h, 0D3h, 7Dh, 87h, 0F9h, 0A8h, 0BFh, 0F6h, 0B6h
	db	0E4h, 0CCh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
	db	0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0F9h, 0FFh, 0FFh, 0F7h, 0ADh, 0B5h, 0B1h, 85h, 74h
	db	5Bh, 49h, 33h, 3Ah, 00h, 19h, 13h, 00h, 1Dh, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	1Ah, 07h, 0Ah, 13h, 00h, 15h, 41h, 45h, 24h, 2Ch, 3Bh, 00h, 31h, 71h, 43h, 3Dh
	db	31h, 61h, 4Dh, 37h, 2Bh, 41h, 31h, 3Bh, 3Fh, 3Fh, 4Ch, 71h, 36h, 6Dh, 47h, 4Ah
	db	63h, 63h, 63h, 54h, 85h, 6Fh, 69h, 8Ch, 7Bh, 6Fh, 59h, 9Fh, 74h, 7Eh, 8Ch, 64h
	db	90h, 77h, 80h, 5Eh, 61h, 7Ah, 70h, 84h, 7Fh, 96h, 85h, 5Fh, 82h, 8Ch, 82h, 6Fh
	db	87h, 88h, 71h, 7Bh, 76h, 80h, 6Ah, 89h, 67h, 81h, 6Eh, 80h, 81h, 71h, 75h, 93h
	db	85h, 77h, 69h, 7Ah, 76h, 8Dh, 91h, 90h, 9Fh, 84h, 0A3h, 96h, 0A3h, 0A5h, 9Bh, 0ACh
	db	0A4h, 0AFh, 0BAh, 0B3h, 99h, 0C4h, 0C1h, 0B2h, 0B3h, 0C4h, 0B6h, 0C7h, 0CDh, 0C9h, 0C2h, 0C1h
	db	0C5h, 0B6h, 0BDh, 0C6h, 0B3h, 0B1h, 0C1h, 0ACh, 0B1h, 0C2h, 0ABh, 0AAh, 0ACh, 0A9h, 9Fh, 0AAh
	db	0A5h, 9Fh, 9Ch, 97h, 9Dh, 92h, 87h, 87h, 7Eh
	
zloc_299:
	db	94h, 0D3h, 1Bh, 61h, 00h, 79h, 58h
	db	83h, 00h, 27h, 81h, 0B7h, 0CCh, 6Bh, 31h, 36h, 0ABh, 0EDh, 63h, 25h, 00h, 00h, 74h
	db	27h, 1Dh, 00h, 19h, 53h, 60h, 42h, 19h, 14h, 4Ch, 65h, 0C1h, 0A5h, 6Ch, 22h, 91h
	db	0A0h, 0FFh, 0D1h, 0A0h, 0A5h, 9Fh, 0A0h, 0D4h, 0C0h, 0D2h, 5Fh, 78h, 7Fh, 0FFh, 0C9h, 0C6h
	db	9Ah, 0D5h, 0C6h, 84h, 8Bh, 91h, 96h, 99h, 0C2h, 89h, 47h, 5Bh, 0AFh, 85h, 96h, 54h
	db	50h, 9Ch, 93h, 0CBh, 83h, 0B2h, 0A4h, 0D7h, 0C8h, 0ABh, 74h, 94h, 9Fh, 0CFh, 0D3h, 0CEh
	db	0B9h, 0B7h, 0C6h, 0F3h, 0F4h, 0B8h, 0C2h, 0AEh, 0D4h, 0D9h, 0F1h, 0BBh, 0A0h, 0AEh, 0CFh, 7Dh
	
; zloc_300:
	db	85h, 8Ch, 6Ah, 4Ch, 37h, 0A5h, 4Dh, 56h, 18h, 4Fh, 1Dh, 2Ah, 00h, 0Eh, 38h, 10h
	db	00h, 00h, 4Fh, 00h, 00h, 00h, 28h, 00h, 04h, 4Ch, 6Bh, 43h, 24h, 39h, 84h, 0B9h
	db	8Bh, 78h, 0B0h, 0A3h, 0A1h, 0BDh, 0BBh, 0CDh, 0A4h, 79h, 0B9h, 0C6h, 89h, 79h, 55h, 6Eh
	db	8Fh, 23h, 40h, 4Bh, 37h, 2Ch, 15h, 21h, 79h, 22h, 5Dh, 0Bh, 21h, 00h, 00h, 07h
	db	0Eh, 22h, 4Ch, 00h, 4Bh, 4Ch, 54h, 56h, 2Eh, 68h, 83h, 0BEh, 0C3h, 0D0h, 0F4h, 0FFh
	db	0F3h, 0D7h, 0FFh, 0F1h, 0FFh, 0D2h, 0FFh, 0FFh, 0C3h, 0FFh, 0E3h, 0F0h, 0FFh, 0FFh, 0FFh, 0B1h
	db	0C0h, 0D9h, 0FFh, 0B3h, 99h, 71h, 90h, 96h, 5Ch, 6Dh, 29h, 47h, 72h, 78h, 7Ch, 59h
	db	42h, 45h, 3Fh, 43h, 0C0h, 0C3h, 85h, 9Eh, 8Eh, 0CBh, 0D5h, 0FFh, 0C1h, 0BEh, 0B3h, 0DEh
	db	0F4h, 0F3h, 0CBh, 0F9h, 0D4h, 0D1h, 0B5h, 0D5h, 0FFh, 0C7h, 0BAh, 9Ch, 0C0h, 0D4h, 5Eh, 3Fh
	db	7Ah, 0CFh, 7Bh, 1Eh, 06h, 37h, 54h, 4Ch, 00h, 00h, 00h, 5Ch, 25h, 2Dh, 23h, 05h
	db	00h, 44h, 37h, 01h, 15h, 00h, 5Ch, 3Fh, 59h, 31h, 53h, 6Ch, 0BCh, 8Fh, 95h, 87h
	db	0B9h, 99h, 0B9h, 0C9h, 9Dh, 0A2h, 84h, 0D3h, 7Eh, 33h, 5Bh, 96h, 5Fh, 75h, 29h, 3Bh
	db	8Ah, 91h, 13h, 34h, 54h, 8Bh, 5Eh, 00h, 24h, 00h, 6Dh, 40h, 87h, 09h, 21h, 5Ch
	db	45h, 56h, 79h, 52h, 5Eh, 53h, 50h, 83h, 79h, 92h, 82h, 0A5h, 0C3h, 96h, 0B3h, 0A3h
	db	7Fh, 0B6h, 0B1h, 0FFh, 64h, 86h, 0CFh, 0B9h, 0AFh, 0B1h, 9Ch, 77h, 90h, 0A9h, 0DAh, 8Ch
	db	9Bh, 3Ah, 0B1h, 83h, 83h, 63h, 0A8h, 0CEh, 4Fh, 50h, 9Dh, 0B9h, 0BEh, 67h, 63h, 0CDh
; zloc_400:
	db	98h, 88h, 46h, 6Bh, 92h, 0A7h, 80h, 3Dh, 65h, 87h, 0C2h, 6Ch, 0A3h, 7Bh, 89h, 0ACh
	db	0B5h, 8Dh, 94h, 8Ch, 0A5h, 70h, 0CAh, 61h, 69h, 93h, 0BEh, 0B7h, 77h, 0A0h, 0C9h, 9Fh
	db	0BDh, 0D7h, 0CBh, 0BFh, 7Eh, 0BBh, 0D9h, 0F2h, 0A0h, 5Fh, 6Dh, 83h, 0C5h, 86h, 25h, 3Fh
	db	52h, 61h, 31h, 46h, 43h, 4Eh, 81h, 4Ah, 3Bh, 51h, 32h, 80h, 41h, 71h, 4Ch, 43h
	db	41h, 9Ch, 62h, 7Ah, 74h, 97h, 7Ch, 9Ch, 0A6h, 0BAh, 0C5h, 95h, 0C0h, 0D3h, 0E7h, 0E0h
	db	9Eh, 90h, 93h, 0BFh, 78h, 8Ah, 8Ah, 0A1h, 0A1h, 93h, 0A7h, 86h, 93h, 54h, 60h, 4Fh
	db	47h, 40h, 4Ah, 4Bh, 63h, 74h, 2Fh, 00h, 56h, 65h, 63h, 5Eh, 41h, 51h, 6Ch, 45h
	db	56h, 7Dh, 88h, 89h, 7Bh, 86h, 0A5h, 97h, 9Ch, 0A5h, 0A6h, 0BAh, 79h, 0ABh, 0A3h, 0DEh
	db	0CEh, 87h, 0AAh, 6Bh, 0B0h, 0C6h, 0B9h, 6Ah, 6Ah, 83h, 98h, 6Ch, 54h, 72h, 64h, 6Eh
	db	0A2h, 5Ch, 70h, 1Fh, 72h, 95h, 64h, 3Eh, 5Ah, 5Ah, 6Bh, 61h, 5Ah, 5Bh, 66h, 0ABh
	db	9Bh, 7Bh, 59h, 73h, 7Fh, 91h, 6Ch, 5Fh, 81h, 0A7h, 95h, 9Ah, 89h, 0A3h, 0BFh, 0A7h
	db	0ADh, 88h, 9Dh, 0D6h, 0B5h, 85h, 0BAh, 0A5h, 0BFh, 0A1h, 9Bh, 51h, 8Dh, 0BEh, 0C7h, 90h
	db	4Eh, 61h, 8Ch, 0B9h, 90h, 7Fh, 71h, 73h, 50h, 53h, 44h, 62h, 45h, 71h, 31h, 70h
	db	51h, 6Dh, 80h, 95h, 55h, 52h, 75h, 0B4h, 77h, 8Bh, 84h, 74h, 9Fh, 7Ah, 86h, 8Bh
	db	0A2h, 0CCh, 96h, 0A6h, 93h, 0C7h, 0A7h, 0A5h, 0BCh, 0A8h, 0BCh, 65h, 78h, 7Dh, 90h, 0BCh
	db	43h, 88h, 37h, 9Dh, 7Dh, 6Dh, 34h, 61h, 5Eh, 88h, 5Bh, 50h, 7Ch, 88h, 35h, 59h
; zloc_500
	db	47h, 87h, 67h, 4Dh, 56h, 7Bh, 92h, 78h, 82h, 7Eh, 8Bh, 7Eh, 77h, 0B8h, 0A8h, 99h
	db	89h, 9Bh, 99h, 0CDh, 80h, 7Ah, 0BAh, 0D0h, 0B6h, 5Ah, 5Dh, 94h, 0D0h, 8Bh, 7Ah, 4Dh
	db	92h, 85h, 98h, 6Bh, 4Eh, 93h, 71h, 7Dh, 5Dh, 7Dh, 84h, 53h, 9Bh, 4Ah, 74h, 4Ch
	db	5Bh, 7Eh, 51h, 58h, 4Fh, 8Eh, 84h, 70h, 84h, 0C5h, 0A1h, 99h, 64h, 91h, 0A4h, 0A3h
	db	8Ch, 96h, 95h, 0ABh, 94h, 0B3h, 62h, 8Bh, 6Bh, 8Eh, 8Eh, 80h, 67h, 73h, 95h, 90h
	db	6Bh, 3Eh, 5Fh, 87h, 9Dh, 90h, 89h, 94h, 70h, 0ABh, 7Dh, 0A4h, 7Eh, 7Fh, 70h, 84h
	db	78h, 8Ch, 92h, 0A7h, 8Fh, 81h, 91h, 77h, 88h, 89h, 73h, 6Ah, 3Fh, 63h, 7Dh, 99h
	db	5Eh, 4Ch, 67h, 96h, 99h, 6Ah, 66h, 95h, 0C1h, 0D4h, 9Ch, 98h, 0ADh, 0B8h, 0AFh, 0D0h
	db	0A5h, 0B8h, 91h, 91h, 8Ch, 9Ch, 96h, 96h, 8Bh, 9Ch, 0B3h, 0B9h, 0A0h, 89h, 89h, 85h
	db	7Fh, 0A0h, 8Eh, 4Fh, 3Ah, 7Ah, 7Eh, 71h, 41h, 2Dh, 5Bh, 6Dh, 84h, 7Ah, 73h, 5Ah
	db	98h, 73h, 73h, 85h, 86h, 8Fh, 80h, 90h, 7Fh, 6Dh, 74h, 0B1h, 83h, 7Dh, 6Eh, 6Ah
	db	99h, 0C0h, 87h, 9Ch, 97h, 0BFh, 0ABh, 63h, 82h, 9Ch, 7Dh, 5Bh, 62h, 61h, 79h, 61h
	db	3Fh, 5Fh, 7Ah, 6Bh, 6Ah, 3Bh, 45h, 52h, 5Ch, 56h, 59h, 61h, 45h, 71h, 5Ah, 79h
	db	8Bh, 87h, 81h, 67h, 80h, 9Ah, 91h, 0ADh, 97h, 90h, 7Eh, 73h, 0B6h, 0BDh, 96h, 77h
	db	56h, 89h, 88h, 82h, 55h, 5Ah, 85h, 97h, 73h, 87h, 62h, 83h, 7Fh, 7Eh, 0B8h, 8Dh
	db	6Fh, 77h, 94h, 85h, 70h, 58h, 8Dh, 91h, 96h, 82h, 84h, 0B3h, 88h, 9Dh, 78h, 0A2h
; zloc_600
	db	0ABh, 0B4h, 89h, 79h, 9Fh, 9Dh, 94h, 6Fh, 57h, 79h, 9Ah, 84h, 77h, 82h, 9Bh, 9Dh
	db	83h, 89h, 89h, 0A7h, 0B4h, 7Bh, 70h, 71h, 90h, 83h, 90h, 81h, 85h, 9Eh, 7Dh, 85h
	db	9Ah, 8Fh, 0C1h, 9Ch, 86h, 69h, 85h, 9Bh, 0A4h, 57h, 8Fh, 80h, 0A5h, 0A3h, 8Ah, 8Ah
	db	95h, 0A1h, 91h, 9Bh, 8Fh, 7Fh, 80h, 78h, 79h, 54h, 45h, 43h, 56h, 59h, 42h, 4Bh
	db	87h, 7Ch, 84h, 58h, 80h, 81h, 70h, 7Ah, 64h, 8Ah, 8Ah, 93h, 51h, 61h, 6Ch, 88h
	db	6Fh, 7Ah, 8Fh, 93h, 91h, 95h, 92h, 8Ch, 0A3h, 86h, 7Ch, 4Eh, 6Bh, 5Eh, 75h, 51h
	db	90h, 5Dh, 4Dh, 6Ch, 91h, 75h, 7Ah, 75h, 7Eh, 6Bh, 97h, 5Bh, 5Bh, 82h, 6Bh, 74h
	db	64h, 72h, 74h, 81h, 8Ch, 99h, 89h, 7Bh, 93h, 99h, 8Ch, 7Ah, 9Ch, 9Eh, 8Eh, 6Eh
	db	76h, 99h, 0ADh, 87h, 6Fh, 8Ch, 8Fh, 9Bh, 9Dh, 83h, 99h, 91h, 8Fh, 91h, 7Ah, 85h
	db	83h, 94h, 90h, 75h, 82h, 90h, 0BBh, 90h, 85h, 88h, 93h, 7Bh, 93h, 6Bh, 90h, 8Ah
	db	85h, 85h, 7Eh, 87h, 8Ch, 7Ch, 83h, 90h, 89h, 82h, 86h, 7Ch, 83h, 95h, 8Bh, 89h
	db	7Ah, 98h, 0A0h, 9Ah, 90h, 73h, 75h, 7Fh, 9Bh, 80h, 87h, 7Eh, 78h, 79h, 78h, 64h
	db	7Eh, 96h, 8Bh, 77h, 4Ah, 78h, 9Dh, 96h, 91h, 87h, 7Fh, 84h, 9Eh, 67h, 69h, 78h
	db	6Ah, 77h, 63h, 73h, 5Eh, 85h, 92h, 8Bh, 7Dh, 8Bh, 92h, 9Ah, 7Ch, 87h, 8Bh, 0BAh
	db	65h, 73h, 4Fh, 8Dh, 8Ch, 83h, 6Ch, 6Bh, 7Dh, 9Ch, 73h, 6Bh, 64h, 80h, 80h, 78h
	db	5Dh, 70h, 71h, 6Bh, 81h, 87h, 75h, 83h, 61h, 73h, 67h, 8Bh, 92h, 78h, 77h, 5Fh
; zloc_700
	db	7Bh, 84h, 87h, 8Dh, 76h, 6Fh, 77h, 7Ch, 93h, 81h, 98h, 7Dh, 95h, 99h, 97h, 9Ch
	db	7Ah, 92h, 0A6h, 83h, 88h, 69h, 7Fh, 8Ch, 7Eh, 7Bh, 65h, 99h, 0A8h, 88h, 8Ch, 7Fh
	db	96h, 93h, 93h, 8Ah, 73h, 5Ch, 61h, 71h, 8Dh, 87h, 86h, 80h, 88h, 8Ah, 84h, 7Eh
	db	8Ah, 92h, 85h, 69h, 78h, 77h, 96h, 6Bh, 91h, 85h, 8Bh, 0A1h, 7Dh, 7Dh, 70h, 97h
	db	0A2h, 96h, 79h, 89h, 90h, 99h, 8Ch, 94h, 95h, 97h, 7Ch, 6Fh, 7Bh, 78h, 7Ch, 78h
	db	6Bh, 73h, 8Bh, 93h, 9Bh, 80h, 8Ah, 6Bh, 82h, 6Bh, 82h, 75h, 83h, 70h, 79h, 6Dh
	db	7Dh, 61h, 6Ah, 76h, 9Eh, 8Fh, 93h, 5Eh, 86h, 68h, 8Fh, 83h, 86h, 63h, 6Fh, 6Bh
	db	94h, 6Dh, 7Bh, 86h, 8Fh, 9Bh, 8Fh, 65h, 7Ch, 5Ch, 8Ch, 83h, 95h, 7Ah, 77h, 90h
	db	8Bh, 83h, 6Ch, 89h, 81h, 8Dh, 87h, 5Ah, 0A1h, 79h, 91h, 84h, 90h, 6Bh, 74h, 67h
	db	73h, 75h, 70h, 7Ch, 5Fh, 79h, 72h, 7Fh, 7Bh, 70h, 78h, 6Dh, 7Dh, 6Bh, 84h, 9Dh
	db	99h, 8Fh, 6Fh, 84h, 76h, 88h, 8Fh, 76h, 96h, 71h, 91h, 7Eh, 89h, 7Eh, 83h, 8Ch
	db	98h, 0A3h, 8Fh, 84h, 65h, 90h, 87h, 9Ah, 80h, 75h, 81h, 77h, 7Fh, 86h, 7Dh, 66h
	db	76h, 8Bh, 8Ch, 84h, 66h, 6Dh, 90h, 8Eh, 85h, 84h, 94h, 80h, 91h, 61h, 74h, 79h
	db	9Bh, 71h, 78h, 7Ah, 95h, 0A8h, 7Eh, 87h, 8Bh, 93h, 8Eh, 88h, 91h, 86h, 95h, 7Eh
	db	79h, 87h, 93h, 87h, 9Ch, 94h, 88h, 79h, 5Bh, 7Ch, 68h, 5Eh, 61h, 75h, 8Eh, 6Eh
	db	6Bh, 7Dh, 8Bh, 8Ch, 7Ah, 81h, 7Dh, 89h, 82h, 74h, 83h, 91h, 0A1h, 87h, 91h, 88h
; zloc_800
	db	8Ah, 96h, 7Bh, 77h, 83h, 75h, 76h, 60h, 87h, 8Ah, 84h, 82h, 70h, 7Ch, 8Ah, 7Eh
	db	7Eh, 5Ah, 85h, 69h, 87h, 6Dh, 86h, 87h, 93h, 9Bh, 92h, 8Eh, 67h, 6Bh, 78h, 8Eh
	db	95h, 8Dh, 7Bh, 5Eh, 80h, 71h, 8Bh, 71h, 8Bh, 8Bh, 70h, 7Fh, 62h, 72h, 7Bh, 7Bh
	db	91h, 7Ch, 7Eh, 94h, 82h, 90h, 0A5h, 83h, 7Ch, 78h, 80h, 72h, 82h, 86h, 7Dh, 8Eh
	db	80h, 94h, 6Eh, 72h, 83h, 81h, 87h, 78h, 79h, 83h, 84h, 9Ah, 74h, 8Dh, 7Bh, 90h
	db	78h, 7Ch, 71h, 83h, 87h, 8Ch, 8Dh, 63h, 70h, 6Ch, 97h, 7Ch, 87h, 83h, 73h, 88h
	db	86h, 77h, 75h, 77h, 78h, 79h, 74h, 87h, 87h, 7Dh, 81h, 83h, 93h, 8Bh, 78h, 5Ah
	db	6Fh, 8Eh, 9Ah, 89h, 75h, 78h, 91h, 8Fh, 83h, 89h, 8Eh, 81h, 83h, 71h, 88h, 7Ch
	db	7Ah, 7Bh, 6Fh, 8Ah, 84h, 87h, 65h, 7Dh, 9Ah, 0A5h, 7Dh, 6Ah, 6Ah, 91h, 0A5h, 8Fh
	db	7Dh, 83h, 8Dh, 93h, 8Eh, 89h, 89h, 77h, 7Dh, 6Eh, 84h, 7Ch, 70h, 85h, 78h, 9Eh
	db	87h, 88h, 81h, 90h, 0A2h, 8Fh, 6Dh, 70h, 8Bh, 93h, 7Ch, 63h, 65h, 86h, 8Dh, 93h
	db	7Ah, 6Dh, 73h, 85h, 91h, 9Ah, 82h, 8Eh, 6Bh, 86h, 84h, 98h, 87h, 8Eh, 7Dh, 75h
	db	85h, 83h, 87h, 7Bh, 6Fh, 81h, 80h, 8Fh, 87h, 76h, 88h, 95h, 98h, 79h, 83h, 8Dh
	db	8Ah, 76h, 64h, 71h, 69h, 86h, 64h, 72h, 56h, 79h, 84h, 7Fh, 8Bh, 6Eh, 8Dh, 87h
	db	97h, 71h, 84h, 80h, 9Ch, 93h, 8Ah, 80h, 89h, 8Dh, 8Ch, 8Dh, 75h, 78h, 74h, 84h
	db	6Eh, 7Ah, 73h, 8Ch, 85h, 76h, 80h, 6Dh, 77h, 78h, 81h, 77h, 7Dh, 61h, 6Dh, 63h
; zloc_900
	db	9Eh, 82h, 7Dh, 65h, 88h, 77h, 78h, 65h, 7Ah, 90h, 77h, 97h, 7Eh, 93h, 97h, 8Fh
	db	8Ah, 7Dh, 8Dh, 8Eh, 8Bh, 7Ah, 77h, 82h, 8Dh, 8Ah, 7Fh, 67h, 91h, 92h, 8Bh, 8Dh
	db	80h, 7Ch, 6Ah, 7Fh, 74h, 7Bh, 76h, 77h, 6Ch, 6Fh, 73h, 82h, 79h, 68h, 6Dh, 83h
	db	84h, 87h, 87h, 79h, 82h, 8Fh, 9Ch, 90h, 7Ch, 88h, 8Ch, 95h, 83h, 90h, 92h, 9Ah
	db	92h, 81h, 72h, 84h, 93h, 0A2h, 82h, 77h, 83h, 84h, 8Bh, 83h, 6Ah, 82h, 74h, 81h
	db	75h, 6Fh, 89h, 85h, 92h, 70h, 82h, 72h, 7Fh, 6Eh, 87h, 8Eh, 7Dh, 7Eh, 80h, 8Bh
	db	8Ch, 7Dh, 8Eh, 8Dh, 85h, 68h, 79h, 7Dh, 9Ch, 8Ah, 8Ch, 7Ah, 8Bh, 8Bh, 93h, 8Fh
	db	8Ch, 8Eh, 7Fh, 7Fh, 7Eh, 7Bh, 7Dh, 75h, 7Eh, 6Fh, 94h, 8Dh, 73h, 76h, 70h, 8Bh
	db	79h, 87h, 75h, 85h, 7Ah, 78h, 75h, 86h, 83h, 72h, 69h, 77h, 80h, 84h, 8Ch, 85h
	db	86h, 8Bh, 9Bh, 9Ah, 86h, 8Ch, 82h, 83h, 70h, 71h, 76h, 79h, 73h, 6Ch, 81h, 7Eh
	db	82h, 7Eh, 7Ch, 81h, 8Bh, 86h, 84h, 74h, 7Fh, 7Fh, 8Ah, 7Fh, 71h, 71h, 8Bh, 92h
	db	81h, 76h, 7Eh, 94h, 8Fh, 87h, 74h, 82h, 89h, 94h, 7Fh, 6Bh, 71h, 87h, 86h, 77h
	db	6Eh, 7Bh, 8Bh, 8Ah, 85h, 8Eh, 85h, 81h, 8Eh, 83h, 8Bh, 6Fh, 82h, 85h, 79h, 80h
	db	76h, 8Ch, 87h, 86h, 7Bh, 82h, 86h, 7Fh, 82h, 8Ch, 71h, 78h, 7Fh, 8Fh, 8Ch, 81h
	db	7Ah, 82h, 8Bh, 84h, 85h, 86h, 80h, 7Fh, 74h, 96h, 98h, 83h, 70h, 80h, 87h, 80h
	db	7Dh, 73h, 7Fh, 83h, 86h, 73h, 79h, 77h, 83h, 87h, 80h, 83h, 7Bh, 84h, 7Dh, 85h
	db	7Eh, 7Eh, 81h, 82h, 7Fh, 81h, 86h, 80h, 87h, 87h, 93h, 7Eh, 75h, 8Dh, 83h, 8Fh
	db	72h, 79h, 74h, 80h, 82h, 87h, 7Fh, 8Bh, 84h, 79h, 87h, 78h, 7Eh, 80h, 78h, 8Ah
	db	79h, 89h, 79h, 79h, 7Fh, 82h, 86h, 8Fh, 7Dh, 80h, 7Eh, 89h, 80h, 85h, 80h, 7Ah
	db	7Bh, 73h, 80h, 85h, 85h, 7Bh, 7Dh, 89h, 82h, 88h, 87h, 89h, 8Ch, 85h, 87h, 81h
	db	7Ch, 7Dh, 83h, 81h, 7Bh, 8Eh, 7Fh, 7Fh, 86h, 71h, 8Fh, 82h, 91h, 74h, 81h, 86h
	db	87h, 82h, 79h, 86h, 87h, 8Dh, 7Dh, 6Dh, 79h, 83h, 84h, 71h, 82h, 77h, 91h, 7Dh
	db	8Bh, 7Bh, 7Ah, 87h, 7Ah, 85h, 7Fh, 7Dh, 81h, 83h, 8Ch, 85h, 89h, 83h, 94h, 7Dh
	db	86h, 7Fh, 92h, 89h, 80h, 7Bh, 78h, 81h, 84h, 87h, 81h, 7Dh, 8Eh, 8Bh, 8Ch, 88h
	db	83h, 7Ah, 73h, 7Ch, 7Eh, 7Ah, 73h, 7Ah, 79h, 85h, 74h, 75h, 80h, 8Ah, 91h, 77h
	db	7Ah, 8Ah, 8Eh, 82h, 7Fh, 83h, 8Eh, 90h, 84h
	
zloc_A99:
	db	7Fh, 80h, 81h, 82h, 83h, 84h, 85h
	db	86h, 85h, 85h, 86h, 86h, 86h, 87h, 88h, 89h, 89h, 8Ah, 8Ah, 8Ah, 8Ah, 89h, 88h
	db	88h, 89h, 88h, 87h, 87h, 87h, 86h, 84h, 84h, 83h, 82h, 81h, 81h, 7Fh, 7Fh, 7Eh
	db	7Dh, 7Bh, 7Bh, 7Bh, 7Ah, 79h, 79h, 79h, 78h, 77h, 77h, 76h, 76h, 76h, 76h, 76h
	db	76h, 77h, 77h, 77h, 78h, 79h, 79h, 7Eh, 82h, 85h, 84h, 89h, 92h, 98h, 0A6h, 95h
	db	9Eh, 0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0Bh, 00h, 0DBh, 3Ch, 00h, 07h
	db	0C6h, 0E6h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 7Dh, 00h, 2Bh
; zloc_B00:
	db	00h, 7Fh, 0FFh, 0FDh, 0FFh, 0FFh, 0BAh, 4Ah, 23h, 48h, 40h, 65h, 0B1h, 0A9h, 0FFh, 0FFh
	db	0FFh, 0DCh, 0AEh, 3Ah, 00h, 00h, 00h, 00h, 00h, 00h, 6Eh, 0B9h, 8Fh, 97h, 0A6h, 21h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 43h, 51h, 0B9h, 98h, 96h, 0F7h, 0CAh, 90h, 0E1h
	db	0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0E9h, 0F6h, 0CFh, 0E0h, 0B0h, 67h, 6Bh
	db	0C6h, 0C9h, 0E4h, 0F7h, 95h, 44h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 3Ah, 2Ch, 24h
	db	45h, 50h, 41h, 2Dh, 3Fh, 00h, 00h, 54h, 58h, 90h, 0CBh, 0D1h, 0A0h, 0C4h, 90h, 0A2h
	db	0AAh, 8Ch, 50h, 67h, 76h, 0FDh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0F5h, 0FFh, 0FDh, 0FFh, 0CBh
	db	0CAh, 0E9h, 0CBh, 0BDh, 86h, 0D5h, 96h, 5Fh, 27h, 4Fh, 00h, 10h, 2Fh, 27h, 53h, 35h
	db	35h, 18h, 2Bh, 2Eh, 00h, 00h, 00h, 00h, 00h, 04h, 00h, 5Fh, 2Fh, 70h, 85h, 4Eh
	db	4Ch, 50h, 93h, 0F9h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0D0h, 0C9h, 9Fh
	db	86h, 7Dh, 9Bh, 0B5h, 0D5h, 0DBh, 9Fh, 92h, 8Dh, 76h, 58h, 3Ch, 5Bh, 3Dh, 1Dh, 5Bh
	db	79h, 52h, 57h, 4Eh, 4Dh, 34h, 56h, 61h, 4Ah, 4Eh, 59h, 54h, 54h, 4Bh, 5Fh, 23h
	db	27h, 5Dh, 51h, 25h, 1Dh, 35h, 5Ah, 6Ah, 65h, 85h, 72h, 4Fh, 65h, 75h, 9Ch, 0B7h
	db	0A8h, 0D0h, 0FFh, 0FFh, 0EBh, 0FBh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0DBh, 0C1h, 87h, 6Ah, 97h
	db	8Ah, 5Ah, 54h, 5Eh, 75h, 2Ah, 11h, 20h, 03h, 22h, 6Fh, 7Dh, 5Eh, 59h, 59h, 38h
	db	5Fh, 43h, 1Fh, 0Eh, 3Dh, 2Ah, 17h, 53h, 61h, 54h, 5Bh, 67h, 72h, 67h, 59h, 5Ah
; zloc_C00:
	db	75h, 7Ch, 7Ch, 76h, 89h, 0B3h, 0BBh, 0A3h, 0CEh, 0C2h, 0CFh, 0D6h, 0B6h, 0D5h, 0CAh, 0C5h
	db	0D7h, 0DFh, 0ECh, 0BFh, 0D9h, 0E5h, 0E5h, 0C8h, 0D8h, 0A7h, 0A4h, 99h, 54h, 42h, 2Fh, 2Ch
	db	3Ch, 3Dh, 16h, 04h, 19h, 07h, 01h, 0Fh, 28h, 16h, 15h, 21h, 3Dh, 43h, 4Ch, 4Ah
	db	3Ah, 54h, 6Ch, 82h, 90h, 8Bh, 81h, 8Dh, 0B1h, 0AFh, 0C3h, 0A7h, 0BAh, 9Ah, 9Dh, 0A8h
	db	0A2h, 0B5h, 0B1h, 0BDh, 0C7h, 0DEh, 0DAh, 0C8h, 0AFh, 0C7h, 0B2h, 9Eh, 0A9h, 9Ch, 93h, 90h
	db	92h, 8Fh, 8Dh, 91h, 0AFh, 9Fh, 7Ch, 47h, 44h, 43h, 37h, 25h, 37h, 31h, 3Bh, 35h
	db	42h, 25h, 29h, 3Ah, 30h, 2Dh, 1Dh, 23h, 2Ah, 49h, 5Eh, 6Dh, 81h, 85h, 88h, 87h
	db	0A1h, 9Bh, 95h, 0BFh, 0C3h, 0BBh, 0CBh, 0C6h, 0BFh, 0A4h, 0BFh, 9Fh, 0A0h, 0A6h, 0B3h, 0B3h
	db	0A7h, 0ADh, 0ACh, 0BFh, 0BCh, 0ADh, 9Eh, 0A9h, 98h, 7Ah, 78h, 7Bh, 69h, 7Eh, 7Bh, 6Ah
	db	5Bh, 53h, 4Bh, 58h, 5Eh, 5Eh, 61h, 59h, 5Ah, 48h, 37h, 41h, 52h, 63h, 6Dh, 67h
	db	60h, 4Ah, 37h, 34h, 49h, 50h, 5Bh, 54h, 58h, 80h, 8Eh, 85h, 97h, 0ADh, 97h, 0A2h
	db	9Eh, 0ADh, 0B6h, 0B6h, 0B3h, 0BBh, 0BAh, 0B7h, 0B8h, 0AAh, 0A7h, 0A3h, 0B1h, 0B2h, 0B9h, 0ADh
	db	9Fh, 9Bh, 0A9h, 0A3h, 9Bh, 91h, 9Eh, 78h, 69h, 5Ah, 63h, 5Ah, 65h, 65h, 65h, 56h
	db	4Eh, 3Ch, 3Dh, 45h, 40h, 47h, 5Ch, 61h, 56h, 44h, 41h, 4Ah, 55h, 5Eh, 6Ch, 6Dh
	db	69h, 70h, 6Eh, 72h, 74h, 80h, 77h, 7Ch, 78h, 74h, 80h, 95h, 0A0h, 0B4h, 0ACh, 0BAh
	db	0C2h, 0BDh, 0B7h, 0B6h, 0B7h, 0ABh, 0B1h, 0AEh, 0B4h, 0BBh, 0BCh, 0B7h, 0BCh, 0B2h, 96h, 7Ch
; zloc_D00:
	db	8Ah, 87h, 96h, 83h, 70h, 74h, 79h, 69h, 5Ch, 61h, 60h, 58h, 4Dh, 54h, 4Ah, 3Dh
	db	45h, 45h, 53h, 4Ah, 4Dh, 4Ch, 4Dh, 4Ah, 44h, 46h, 51h, 6Bh, 5Eh, 6Eh, 7Eh, 83h
	db	89h, 8Ch, 8Ch, 8Ah, 90h, 9Eh, 9Dh, 0AFh, 0ABh, 0AAh, 0A5h, 0B2h, 0B0h, 0ADh, 0B5h, 0AFh
	db	0A9h, 0A0h, 98h, 0A5h, 0A7h, 0A9h, 0A6h, 9Bh, 0A1h, 98h, 92h, 89h, 93h, 97h, 96h, 90h
	db	90h, 85h, 73h, 5Ah, 5Eh, 58h, 55h, 57h, 58h, 52h, 4Fh, 4Fh, 4Eh, 51h, 52h, 54h
	db	58h, 5Eh, 5Eh, 50h, 4Eh, 62h, 6Bh, 69h, 66h, 63h, 6Ah, 67h, 69h, 65h, 73h, 87h
	db	94h, 98h, 9Ah, 9Bh, 9Eh, 0A5h, 0B4h, 0AFh, 0A9h, 0A4h, 0ACh, 0B2h, 0A7h, 0A5h, 0A4h, 0B3h
	db	0B3h, 0A9h, 0A8h, 0ABh, 0A3h, 9Bh, 91h, 98h, 8Ah, 8Dh, 8Dh, 91h, 8Ah, 7Fh, 78h, 75h
	db	6Fh, 6Ah, 67h, 5Dh, 52h, 4Fh, 51h, 4Ah, 51h, 56h, 58h, 59h, 57h, 59h, 53h, 4Fh
	db	51h, 52h, 57h, 67h, 6Fh, 71h, 80h, 7Eh, 76h, 7Ah, 81h, 79h, 79h, 81h, 88h, 9Bh
	db	0A1h, 0A6h, 0A4h, 0A4h, 0A7h, 0A0h, 0A5h, 0A7h, 0A9h, 0B2h, 0AFh, 0B6h, 0AFh, 0A5h, 0AFh, 0A5h
	db	0A7h, 9Dh, 9Bh, 97h, 94h, 8Fh, 93h, 8Fh, 83h, 7Eh, 78h, 6Eh, 62h, 62h, 60h, 60h
	db	62h, 60h, 5Ch, 59h, 52h, 4Dh, 57h, 5Ch, 59h, 54h, 50h, 4Ch, 4Ch, 4Fh, 55h, 60h
	db	70h, 78h, 73h, 76h, 77h, 75h, 77h, 7Dh, 85h, 90h, 9Ah, 9Eh, 0A9h, 0A8h, 0B1h, 0B3h
	db	0B2h, 0A7h, 9Dh, 97h, 97h, 9Ah, 96h, 9Bh, 9Bh, 9Fh, 95h, 95h, 91h, 8Bh, 8Ah, 8Dh
	db	95h, 95h, 8Fh, 95h, 94h, 98h, 98h, 93h, 8Bh, 83h, 7Ch, 76h, 6Dh, 68h, 62h, 5Ah
; zloc_E00:
	db	5Bh, 5Ah, 53h, 55h, 54h, 54h, 57h, 5Ah, 5Bh, 5Eh, 5Ah, 5Ah, 5Ah, 5Fh, 61h, 6Bh
	db	6Bh, 65h, 69h, 6Dh, 6Bh, 73h, 79h, 81h, 89h, 8Dh, 8Ch, 94h, 9Ch, 9Ah, 9Eh, 0A9h
	db	0ACh, 0AAh, 0A7h, 0A7h, 0A9h, 0A7h, 0AAh, 0AFh, 0ADh, 0A9h, 0A7h, 0A1h, 9Bh, 9Ah, 94h, 96h
	db	95h, 92h, 8Ah, 84h, 89h, 88h, 7Bh, 73h, 74h, 75h, 6Ch, 60h, 5Dh, 64h, 65h, 5Fh
	db	61h, 62h, 5Fh, 5Fh, 5Dh, 64h, 65h, 67h, 67h, 61h, 5Eh, 5Ah, 61h, 6Bh, 6Ch, 6Ah
	db	65h, 64h, 66h, 65h, 5Bh, 69h, 76h, 78h, 7Ch, 88h, 98h, 9Ah, 9Bh, 99h, 9Dh, 9Eh
	db	9Bh, 9Fh, 9Fh, 9Fh, 0A7h, 0AAh, 0ACh, 0ADh, 0B0h, 0B4h, 0B4h, 0AEh, 0A6h, 0A3h, 9Eh, 9Ch
	db	93h, 99h, 97h, 92h, 89h, 7Fh, 78h, 72h, 6Fh, 6Fh, 64h, 5Fh, 5Eh, 58h, 55h, 5Ah
	db	5Bh, 5Ch, 5Bh, 55h, 54h, 51h, 54h, 5Dh, 61h, 5Dh, 5Bh, 61h, 67h, 63h, 5Bh, 5Eh
	db	62h, 68h, 73h, 7Eh, 81h, 86h, 87h, 91h, 93h, 95h, 95h, 95h, 99h, 0A1h, 0A9h, 0A7h
	db	0A1h, 98h, 99h, 94h, 97h, 99h, 9Eh, 0A5h, 0AFh, 0AEh, 0AEh, 0AEh, 0A7h, 0ADh, 0ADh, 0A7h
	db	0A6h, 0A2h, 98h, 91h, 8Eh, 87h, 7Eh, 74h, 64h, 5Eh, 5Ah, 55h, 4Eh, 4Eh, 4Fh, 53h
	db	52h, 50h, 50h, 4Fh, 54h, 54h, 56h, 5Bh, 63h, 5Eh, 5Fh, 63h, 64h, 67h, 69h, 69h
	db	6Bh, 70h, 76h, 79h, 78h, 7Ah, 7Dh, 80h, 8Ah, 99h, 0A3h, 0ADh, 0B1h, 0B3h, 0B0h, 0AEh
	db	0AAh, 0A7h, 0AEh, 0AFh, 0B2h, 0ADh, 0AFh, 0A7h, 9Dh, 97h, 98h, 95h, 93h, 91h, 91h, 91h
	db	90h, 8Bh, 86h, 84h, 86h, 80h, 7Dh, 7Ah, 73h, 73h, 74h, 6Eh, 65h, 61h, 5Eh, 5Fh
; zloc_F00:
	db	62h, 62h, 5Eh, 54h, 53h, 50h, 4Ch, 4Fh, 4Fh, 52h, 52h, 53h, 53h, 51h, 52h, 58h
	db	63h, 6Fh, 77h, 85h, 8Dh, 8Fh, 93h, 98h, 9Dh, 0A5h, 0A4h, 0A3h, 0A6h, 0ACh, 0AAh, 0A9h
	db	0A7h, 0A7h, 0ACh, 0A5h, 0A7h, 0A2h, 0A1h, 0A3h, 0A7h, 0A5h, 0A0h, 9Ch, 98h, 93h, 97h, 9Ah
	db	99h, 95h, 90h, 89h, 85h, 81h, 79h, 73h, 6Bh, 61h, 59h, 50h, 49h, 4Ah, 4Dh, 52h
	db	56h, 58h, 5Bh, 59h, 5Ah, 5Bh, 5Eh, 5Eh, 5Dh, 61h, 68h, 6Eh, 6Bh, 6Bh, 67h, 6Ah
	db	69h, 68h, 6Ch, 74h, 7Ah, 83h, 8Dh, 95h, 9Bh, 9Bh, 9Ch, 0A0h, 0A5h, 0A7h, 0A5h, 0A4h
	db	0A5h, 0A2h, 0A2h, 0A5h, 0AAh, 0A9h, 0A5h, 0A7h, 0A8h, 0ACh, 0A9h, 9Ch, 98h, 94h, 95h, 91h
	db	91h, 91h, 8Dh, 83h, 77h, 72h, 6Dh, 6Dh, 68h, 6Ch, 6Bh, 67h, 5Fh, 5Ch, 58h, 57h
	db	56h, 59h, 5Bh, 5Ch, 5Dh, 5Dh, 59h, 58h, 5Bh, 5Eh, 60h, 5Fh, 5Eh, 64h, 6Ah, 6Dh
	db	6Dh, 72h, 7Ch, 82h, 87h, 8Eh, 90h, 92h, 95h, 98h, 9Ah, 9Eh, 0A1h, 0A3h, 0A5h, 0A3h
	db	9Eh, 9Bh, 9Bh, 9Eh, 9Dh, 9Ah, 97h, 94h, 98h, 99h, 9Dh, 9Dh, 0A0h, 9Dh, 9Bh, 95h
	db	8Fh, 86h, 82h, 7Fh, 7Dh, 79h, 75h, 72h, 72h, 70h, 6Fh, 6Fh, 6Bh, 68h, 68h, 69h
	db	67h, 63h, 61h, 66h, 67h, 64h, 64h, 65h, 67h, 66h, 67h, 64h, 64h, 62h, 64h, 68h
	db	6Ch, 71h, 71h, 77h, 77h, 7Ah, 7Dh, 83h, 8Bh, 90h, 93h, 91h, 94h, 92h, 92h, 93h
	db	97h, 9Bh, 9Eh, 9Eh, 99h, 98h, 99h, 9Ch, 0A0h, 0A2h, 0A3h, 0A3h, 0A3h, 0A1h, 9Fh, 9Ch
	db	97h, 92h, 8Eh, 8Bh, 84h, 7Ch, 73h, 6Dh, 6Ch, 69h, 69h, 68h, 6Ah, 69h, 67h, 63h
; zloc_1000:
	db	67h, 6Dh, 70h, 73h, 76h, 76h, 73h, 70h, 6Bh, 67h, 64h, 61h, 61h, 61h, 62h, 61h
	db	63h, 67h, 69h, 69h, 6Ch, 6Fh, 72h, 77h, 79h, 7Eh, 82h, 87h, 8Dh, 95h, 9Ch, 0A3h
	db	0A6h, 0A5h, 0A1h, 9Eh, 9Dh, 9Dh, 9Eh, 9Fh, 0A3h, 0A4h, 0A5h, 0A1h, 9Dh, 9Dh, 9Ch, 9Ch
	db	99h, 96h, 94h, 90h, 8Ch, 88h, 86h, 81h, 7Eh, 78h, 77h, 75h, 6Dh, 64h, 5Fh, 5Fh
	db	60h, 61h, 5Eh, 5Ch, 5Ch, 5Dh, 5Eh, 5Ch, 5Ch, 5Bh, 5Bh, 5Ch, 5Fh, 60h, 63h, 6Ah
	db	6Fh, 71h, 75h, 7Ah, 7Bh, 7Dh, 80h, 83h, 86h, 88h, 8Bh, 8Eh, 93h, 95h, 92h, 90h
	db	90h, 93h, 93h, 95h, 99h, 9Eh, 0A0h, 0A0h, 0A1h, 0A2h, 0A3h, 9Fh, 9Eh, 9Eh, 9Eh, 9Fh
	db	9Dh, 9Bh, 97h, 93h, 8Fh, 88h, 81h, 7Bh, 77h, 75h, 75h, 72h, 6Dh, 69h, 64h, 60h
	db	5Fh, 5Fh, 62h, 64h, 65h, 67h, 67h, 67h, 65h, 63h, 63h, 62h, 60h, 5Fh, 60h, 62h
	db	66h, 68h, 6Ch, 6Fh, 72h, 78h, 7Dh, 81h, 85h, 8Ah, 8Fh, 95h, 98h, 9Ah, 9Ch, 9Ch
	db	9Ch, 9Ch, 9Bh, 99h, 97h, 94h, 91h, 91h, 93h, 95h, 96h, 97h, 98h, 97h, 94h, 90h
	db	8Dh, 8Bh, 8Ch, 8Dh, 8Ch, 8Dh, 8Dh, 8Bh, 86h, 81h, 7Eh, 7Bh, 78h, 73h, 6Fh, 6Dh
	db	69h, 67h, 65h, 65h, 69h, 6Dh, 6Bh, 69h, 66h, 63h, 62h, 61h, 63h, 65h, 69h, 6Dh
	db	6Fh, 6Fh, 6Fh, 71h, 73h, 73h, 73h, 73h, 74h, 7Ah, 80h, 85h, 8Ah, 8Fh, 91h, 92h
	db	93h, 95h, 96h, 97h, 97h, 9Ah, 9Ah, 9Ch, 9Eh, 9Eh, 9Eh, 9Dh, 9Ch, 9Ah, 99h, 97h
	db	96h, 93h, 8Fh, 8Eh, 8Eh, 8Ch, 87h, 83h, 7Fh, 7Ah, 77h, 73h, 73h, 74h, 75h, 75h
; zloc_1100:
	db	77h, 77h, 74h, 6Fh, 6Bh, 6Ah, 67h, 67h, 69h, 6Bh, 6Bh, 6Bh, 69h, 67h, 66h, 68h
	db	69h, 68h, 67h, 67h, 68h, 6Ch, 71h, 74h, 76h, 7Ah, 7Dh, 7Fh, 81h, 85h, 89h, 8Bh
	db	8Ch, 90h, 92h, 92h, 92h, 94h, 96h, 99h, 99h, 9Ah, 9Bh, 9Ch, 9Ch, 9Eh, 9Fh, 9Fh
	db	9Eh, 9Ch, 9Ah, 99h, 96h, 92h, 90h, 8Dh, 89h, 83h, 7Eh, 78h, 74h, 73h, 72h, 71h
	db	6Eh, 6Dh, 6Ah, 67h, 69h, 6Ah, 6Ah, 6Ah, 6Bh, 6Ch, 6Bh, 69h, 67h, 65h, 63h, 62h
	db	63h, 65h, 68h, 6Dh, 6Fh, 72h, 76h, 79h, 7Ch, 7Dh, 7Fh, 80h, 82h, 85h, 88h, 8Ch
	db	90h, 93h, 93h, 93h, 92h, 93h, 92h, 91h, 91h, 92h, 93h, 93h, 96h, 97h, 98h, 96h
	db	96h, 95h, 95h, 95h, 93h, 92h, 91h, 90h, 8Dh, 8Ah, 87h, 83h, 80h, 7Dh, 79h, 75h
	db	72h, 6Fh, 6Dh, 6Ah, 68h, 68h, 67h, 69h, 6Ch, 6Eh, 6Fh, 6Fh, 6Fh, 6Fh, 6Fh, 6Dh
	db	6Dh, 6Bh, 6Bh, 6Ch, 6Eh, 6Fh, 6Fh, 71h, 72h, 75h, 76h, 79h, 7Bh, 7Dh, 80h, 85h
	db	89h, 8Bh, 8Ch, 8Dh, 8Fh, 90h, 92h, 94h, 95h, 96h, 96h, 96h, 97h, 98h, 97h, 97h
	db	97h, 96h, 95h, 93h, 91h, 90h, 8Eh, 8Ch, 8Ah, 88h, 87h, 85h, 83h, 81h, 80h, 7Fh
	db	7Dh, 7Bh, 79h, 77h, 75h, 72h, 6Fh, 6Eh, 6Eh, 6Dh, 6Dh, 6Dh, 6Dh, 6Bh, 68h, 68h
	db	69h, 69h, 68h, 69h, 6Ah, 6Ch, 6Eh, 70h, 72h, 75h, 78h, 79h, 7Bh, 7Eh, 81h, 84h
	db	87h, 8Bh, 8Dh, 8Eh, 8Ch, 8Bh, 89h, 89h, 88h, 89h, 89h, 89h, 8Bh, 8Dh, 90h, 93h
	db	97h, 98h, 98h, 98h, 97h, 96h, 95h, 95h, 94h, 95h, 93h, 90h, 8Ch, 89h, 87h, 83h
; zloc_1200:
	db	80h, 7Dh, 79h, 76h, 74h, 73h, 71h, 6Fh, 6Dh, 6Dh, 6Ch, 6Dh, 6Eh, 6Dh, 6Dh, 6Dh
	db	6Fh, 6Fh, 6Fh, 6Eh, 6Eh, 6Dh, 6Dh, 6Fh, 6Fh, 71h, 71h, 73h, 73h, 75h, 77h, 79h
	db	7Bh, 7Fh, 83h, 84h, 87h, 89h, 8Ch, 8Fh, 90h, 91h, 91h, 92h, 92h, 92h, 91h, 91h
	db	91h, 91h, 91h, 92h, 93h, 91h, 91h, 91h, 91h, 91h, 90h, 8Fh, 8Ch, 8Ah, 87h, 83h
	db	81h, 7Fh, 7Eh, 7Ch, 7Ch, 7Ch, 7Bh, 7Bh, 7Ah, 79h, 77h, 75h, 73h, 72h, 71h, 6Fh
	db	6Dh, 6Bh, 6Bh, 6Bh, 6Bh, 69h, 67h, 67h, 67h, 69h, 6Dh, 70h, 73h, 74h, 75h, 77h
	db	7Bh, 7Fh, 81h, 83h, 86h, 89h, 8Ah, 8Bh, 8Bh, 8Dh, 8Eh, 8Eh, 8Fh, 8Fh, 8Fh, 8Fh
	db	8Fh, 8Eh, 8Fh, 90h, 91h, 92h, 93h, 93h, 91h, 90h, 8Fh, 8Eh, 8Dh, 8Bh, 8Bh, 8Ah
	db	89h, 87h, 85h, 83h, 81h, 7Fh, 7Ch, 79h, 77h, 77h, 75h, 75h, 75h, 75h, 75h, 75h
	db	75h, 74h, 73h, 71h, 70h, 6Fh, 6Eh, 6Eh, 6Ch, 6Bh
	
zloc_129A:
	db	82h, 4Dh, 7Eh, 81h, 6Bh, 79h
	db	0ADh, 0A0h, 0AEh, 78h, 78h, 6Bh, 0B7h, 79h, 9Ah, 7Dh, 96h, 61h, 4Ah, 52h, 78h, 94h
	db	0B2h, 82h, 79h, 93h, 74h, 4Ah, 97h, 66h, 5Ah, 7Ch, 80h, 84h, 87h, 88h, 70h, 62h
	db	84h, 88h, 0A6h, 9Dh, 0BBh, 7Fh, 80h, 61h, 6Ch, 46h, 0A1h, 55h, 9Ch, 88h, 0A9h, 6Fh
	db	8Eh, 7Fh, 69h, 83h, 58h, 8Ah, 6Dh, 0AFh, 72h, 97h, 5Fh, 81h, 4Ah, 72h, 51h, 0B1h
	db	94h, 9Bh, 78h, 4Bh, 6Ah, 68h, 72h, 0A5h, 78h, 0A3h, 96h, 97h, 9Dh, 96h, 83h, 82h
	db	69h, 7Bh, 71h, 0A3h, 8Bh, 74h, 90h, 40h, 6Eh, 99h, 0BFh, 0B4h, 9Bh, 77h, 64h, 3Bh
;zloc_1300:
	db	83h, 63h, 8Bh, 6Bh, 64h, 58h, 98h, 0ACh, 95h, 79h, 8Dh, 42h, 95h, 98h, 9Fh, 84h
	db	91h, 56h, 55h, 7Ch, 79h, 68h, 0BEh, 0AAh, 0A3h, 82h, 96h, 87h, 75h, 72h, 62h, 70h
	db	91h, 91h, 6Dh, 9Dh, 80h, 7Eh, 66h, 0A9h, 78h, 7Ch, 0BAh, 89h, 64h, 9Ah, 75h, 6Dh
	db	7Eh, 73h, 7Bh, 8Ch, 94h, 65h, 6Ch, 6Eh, 4Bh, 6Ah, 76h, 84h, 7Eh, 7Bh, 90h, 77h
	db	73h, 7Ch, 54h, 6Fh, 77h, 84h, 81h, 91h, 65h, 69h, 85h, 6Ch, 8Eh, 92h, 9Dh, 7Fh
	db	90h, 77h, 9Ch, 58h, 81h, 72h, 83h, 81h, 8Bh, 98h, 0A2h, 91h, 79h, 62h, 99h, 73h
	db	91h, 6Ch, 8Bh, 65h, 63h, 62h, 75h, 87h, 8Fh, 80h, 7Fh, 8Fh, 86h, 0A1h, 9Eh, 7Fh
	db	7Fh, 76h, 5Fh, 76h, 57h, 88h, 79h, 6Eh, 54h, 87h, 77h, 91h, 86h, 76h, 92h, 90h
	db	97h, 8Eh, 70h, 7Ch, 69h, 7Eh, 56h, 8Dh, 70h, 8Bh, 7Fh, 68h, 7Bh, 89h, 72h, 7Dh
	db	8Fh, 7Ah, 0A7h, 87h, 0A6h, 75h, 84h, 7Bh, 79h, 6Eh, 6Ah, 78h, 50h, 67h, 81h, 83h
	db	85h, 9Bh, 6Fh, 8Eh, 79h, 98h, 84h, 85h, 71h, 6Bh, 67h, 73h, 5Eh, 83h, 9Ch, 65h
	db	84h, 6Eh, 97h, 89h, 93h, 80h, 6Ch, 85h, 71h, 7Eh, 88h, 83h, 74h, 78h, 73h, 87h
	db	7Fh, 0A4h, 87h, 8Ah, 90h, 84h, 74h, 79h, 6Ch, 72h, 74h, 87h, 79h, 9Dh, 93h, 96h
	db	6Bh, 70h, 79h, 86h, 85h, 8Dh, 84h, 82h, 80h, 6Ch, 68h, 76h, 85h, 8Fh, 99h, 7Ch
	db	9Bh, 83h, 9Ah, 78h, 7Eh, 79h, 5Eh, 86h, 7Bh, 80h, 8Fh, 99h, 7Dh, 64h, 67h, 85h
	db	63h, 95h, 6Eh, 79h, 72h, 6Dh, 7Fh, 82h, 80h, 8Eh, 6Fh, 87h, 84h, 79h, 82h, 85h
;zloc_1400:
	db	4Fh, 6Dh, 78h, 8Dh, 95h, 96h, 8Dh, 7Fh, 7Fh, 79h, 79h, 97h, 7Fh, 8Eh, 60h, 81h
	db	7Eh, 62h, 8Bh, 75h, 80h, 8Bh, 90h, 73h, 97h, 7Eh, 7Bh, 7Bh, 8Eh, 85h, 8Fh, 86h
	db	87h, 7Bh, 94h, 63h, 9Ch, 5Bh, 7Fh, 74h, 84h, 7Bh, 80h, 5Ch, 8Ch, 5Ah, 96h, 73h
	db	7Bh, 7Fh, 84h, 54h, 89h, 0A0h, 8Dh, 7Bh, 87h, 7Bh, 59h, 99h, 8Fh, 6Bh, 8Ah, 55h
	db	6Fh, 65h, 95h, 94h, 70h, 83h, 6Fh, 63h, 9Eh, 79h, 90h, 9Bh, 6Eh, 5Ah, 6Dh, 90h
	db	7Ah, 89h, 0A7h, 72h, 74h, 8Bh, 8Ah, 79h, 83h, 8Ah, 67h, 8Dh, 90h, 74h, 8Ch, 0AFh
	db	6Ch, 86h, 81h, 7Bh, 71h, 9Ch, 87h, 7Fh, 89h, 77h, 70h, 80h, 86h, 75h, 7Eh, 78h
	db	7Eh, 66h, 98h, 6Ch, 81h, 78h, 76h, 57h, 99h, 8Eh, 98h, 7Fh, 87h, 6Dh, 71h, 6Bh
	db	77h, 67h, 7Fh, 65h, 6Dh, 57h, 8Fh, 83h, 8Bh, 96h, 85h, 7Dh, 0A1h, 88h, 8Ah, 5Fh
	db	80h, 50h, 61h, 78h, 82h, 8Dh, 9Bh, 84h, 78h, 7Ch, 6Bh, 83h, 9Bh, 81h, 99h, 8Bh
	db	8Ah, 90h, 8Fh, 83h, 63h, 78h, 66h, 7Bh, 88h, 61h, 87h, 6Ah, 65h, 6Bh, 6Bh, 81h
	db	94h, 0B3h, 87h, 9Ch, 69h, 77h, 7Fh, 77h, 59h, 84h, 5Dh, 78h, 5Fh, 80h, 81h, 85h
	db	63h, 7Ah, 75h, 9Bh, 0A7h, 0B9h, 97h, 7Dh, 70h, 69h, 80h, 96h, 0AAh, 86h, 7Ah, 79h
	db	7Ah, 50h, 94h, 74h, 6Dh, 7Ch, 9Fh, 71h, 0A3h, 8Eh, 93h, 61h, 8Eh, 85h, 93h, 85h
	db	8Ch, 89h, 77h, 5Ch, 5Fh, 81h, 82h, 7Fh, 8Eh, 0A1h, 7Fh, 83h, 8Eh, 71h, 66h, 8Bh
	db	83h, 7Dh, 75h, 86h, 7Dh, 80h, 7Fh, 87h, 6Fh, 7Ch, 65h, 6Eh, 85h, 73h, 84h, 7Bh
;zloc_1500:
	db	83h, 81h, 87h, 96h, 89h, 9Fh, 7Dh, 91h, 87h, 6Eh, 6Ch, 94h, 6Dh, 91h, 62h, 9Fh
	db	81h, 83h, 78h, 84h, 6Fh, 78h, 88h, 9Bh, 71h, 7Bh, 81h, 6Ch, 80h, 72h, 99h, 81h
	db	62h, 97h, 69h, 7Dh, 8Dh, 7Dh, 8Ch, 75h, 7Ch, 73h, 77h, 88h, 86h, 8Dh, 90h, 65h
	db	8Eh, 80h, 70h, 0A7h, 7Ch, 9Bh, 61h, 85h, 73h, 90h, 96h, 87h, 82h, 84h, 6Dh, 82h
	db	6Ah, 0A6h, 92h, 61h, 88h, 7Fh, 7Bh, 90h, 81h, 82h, 70h, 5Ch, 91h, 90h, 0A0h, 6Ah
	db	93h, 6Bh, 7Ah, 61h, 82h, 93h, 8Fh, 78h, 81h, 71h, 69h, 85h, 9Ah, 8Ch, 88h, 96h
	db	6Fh, 6Dh, 6Dh, 82h, 73h, 6Fh, 95h, 92h, 7Bh, 81h, 0A5h, 68h, 90h, 80h, 74h, 90h
	db	78h, 82h, 7Ah, 77h, 8Ah, 71h, 7Fh, 78h, 7Ah, 6Bh, 8Dh, 84h, 8Fh, 8Eh, 8Ah, 8Ch
	db	89h, 80h, 56h, 9Ch, 8Eh, 7Ah, 7Dh, 90h, 61h, 7Bh, 7Eh, 0AAh, 78h, 99h, 8Eh, 5Eh
	db	7Ch, 82h, 63h, 79h, 72h, 74h, 6Dh, 66h, 83h, 6Bh, 9Fh, 63h, 87h, 86h, 90h, 67h
	db	9Dh, 70h, 8Dh, 69h, 9Ah, 67h, 7Fh, 9Bh, 73h, 5Ah, 99h, 73h, 74h, 86h, 91h, 81h
	db	8Eh, 8Ah, 8Bh, 80h, 84h, 7Eh, 75h, 8Fh, 7Ah, 87h, 8Ah, 89h, 72h, 60h, 84h, 69h
	db	84h, 85h, 73h, 7Dh, 91h, 86h, 8Ah, 8Bh, 98h, 60h, 9Eh, 6Bh, 8Dh, 68h, 6Bh, 5Dh
	db	4Eh, 62h, 69h, 77h, 89h, 95h, 8Fh, 8Dh, 65h, 79h, 55h, 9Bh, 6Bh, 7Dh, 74h, 73h
	db	56h, 70h, 6Dh, 75h, 78h, 90h, 84h, 97h, 97h, 91h, 89h, 86h, 7Eh, 8Dh, 80h, 6Fh
	db	88h, 61h, 95h, 69h, 6Bh, 8Ah, 8Dh, 81h, 81h, 85h, 8Fh, 7Bh, 78h, 6Bh, 7Fh, 6Dh
;zloc_1600:
	db	7Ah, 81h, 7Fh, 89h, 8Eh, 85h, 82h, 7Fh, 61h, 75h, 78h, 8Ch, 86h, 73h, 85h, 81h
	db	76h, 74h, 8Ah, 76h, 90h, 79h, 85h, 73h, 93h, 5Ch, 88h, 8Dh, 78h, 70h, 88h, 7Fh
	db	87h, 88h, 84h, 7Ah, 7Fh, 96h, 70h, 9Fh, 89h, 8Dh, 78h, 87h, 68h, 69h, 7Bh, 89h
	db	5Bh, 95h, 70h, 91h, 75h, 9Ah, 71h, 91h, 7Ch, 90h, 6Fh, 96h, 70h, 86h, 82h, 64h
	db	66h, 87h, 87h, 75h, 71h, 90h, 7Ah, 84h, 77h, 92h, 68h, 8Ch, 75h, 73h, 75h, 82h
	db	7Fh, 68h, 77h, 61h, 7Ch, 8Ch, 6Dh, 7Ah, 7Ch, 73h, 82h, 83h, 9Ah, 8Eh, 94h, 7Ah
	db	6Eh, 76h, 79h, 78h, 7Bh, 72h, 80h, 7Eh, 79h, 7Fh, 77h, 8Bh, 81h, 90h, 70h, 78h
	db	91h, 91h, 73h, 93h, 68h, 82h, 77h, 70h, 7Bh, 79h, 7Fh, 87h, 6Eh, 76h, 80h, 7Ch
	db	84h, 94h, 7Ch, 83h, 78h, 86h, 77h, 96h, 63h, 7Dh, 86h, 6Bh, 80h, 7Ch, 6Bh, 7Ah
	db	79h, 6Bh, 88h, 75h, 88h, 86h, 8Ch, 78h, 8Bh, 74h, 7Fh, 86h, 7Ch, 83h, 8Dh, 85h
	db	8Bh, 8Bh, 6Fh, 7Bh, 80h, 79h, 8Ch, 82h, 75h, 92h, 8Eh, 8Dh, 89h, 87h, 8Fh, 85h
	db	8Eh, 87h, 7Fh, 86h, 67h, 7Fh, 6Ah, 71h, 76h, 82h, 97h, 90h, 89h, 86h, 8Bh, 85h
	db	86h, 6Fh, 7Fh, 73h, 88h, 71h, 90h, 61h, 7Dh, 6Dh, 89h, 7Dh, 92h, 7Bh, 7Fh, 77h
	db	8Eh, 7Bh, 8Bh, 8Bh, 81h, 86h, 84h, 87h, 7Ch, 81h, 6Dh, 62h, 68h, 6Dh, 89h, 7Eh
	db	8Fh, 86h, 88h, 86h, 85h, 88h, 83h, 80h, 77h, 77h, 8Dh, 79h, 7Ah, 85h, 70h, 95h
	db	7Fh, 7Dh, 0A0h, 82h, 8Ah, 87h, 99h, 61h, 83h, 74h, 81h, 83h, 8Eh, 7Ah, 7Fh, 7Eh
;zloc_1700:
	db	80h, 7Ch, 71h, 80h, 90h, 6Ch, 95h, 91h, 72h, 91h, 7Eh, 7Bh, 89h, 80h, 74h, 8Bh
	db	86h, 79h, 7Dh, 84h, 70h, 8Ah, 86h, 87h, 94h, 77h, 85h, 89h, 6Eh, 83h, 7Bh, 87h
	db	85h, 7Dh, 6Fh, 8Dh, 84h, 83h, 8Ah, 6Fh, 7Bh, 78h, 8Bh, 80h, 8Fh, 71h, 8Dh, 7Fh
	db	8Eh, 75h, 94h, 85h, 8Fh, 7Eh, 77h, 79h, 73h, 83h, 84h, 7Ch, 89h, 87h, 7Bh, 79h
	db	8Eh, 7Fh, 7Fh, 75h, 80h, 79h, 7Dh, 90h, 7Bh, 73h, 80h, 66h, 79h, 87h, 7Fh, 9Bh
	db	78h, 81h, 77h, 8Bh, 89h, 71h, 88h, 7Bh, 79h, 8Dh, 6Fh, 90h, 74h, 72h, 6Ch, 72h
	db	7Eh, 73h, 78h, 8Eh, 74h, 84h, 85h, 90h, 79h, 7Dh, 86h, 7Eh, 71h, 7Bh, 6Eh, 79h
	db	87h, 70h, 7Bh, 79h, 84h, 82h, 89h, 82h, 90h, 76h, 88h, 6Bh, 84h, 74h, 7Eh, 87h
	db	82h, 76h, 7Dh, 78h, 80h, 80h, 84h, 8Bh, 7Bh, 84h, 7Eh, 7Eh, 8Ah, 86h, 76h, 82h
	db	8Dh, 75h, 83h, 97h, 7Fh, 79h, 6Eh, 7Eh, 81h, 8Fh, 8Ah, 8Eh, 5Dh, 80h, 7Bh, 7Dh
	db	80h, 87h, 76h, 84h, 84h, 70h, 7Fh, 7Fh, 7Dh, 85h, 78h, 7Ch, 89h, 88h, 79h, 91h
	db	6Fh, 80h, 6Dh, 81h, 82h, 88h, 7Ah, 7Fh, 7Dh, 76h, 7Ch, 8Bh, 78h, 78h, 8Bh, 78h
	db	83h, 7Dh, 8Ah, 84h, 80h, 6Fh, 72h, 7Fh, 87h, 81h, 7Bh, 75h, 83h, 75h, 83h, 6Eh
	db	8Fh, 85h, 85h, 6Fh, 8Dh, 7Bh, 7Ah, 85h, 86h, 6Ch, 87h, 87h, 7Ch, 77h, 86h, 81h
	db	78h, 7Ah, 79h, 81h, 8Dh, 7Bh, 71h, 73h, 73h, 7Fh, 80h, 80h, 88h, 83h, 85h, 81h
	db	7Bh, 80h, 81h, 7Fh, 87h, 76h, 71h, 6Fh, 89h, 83h, 7Fh, 84h, 69h, 7Dh, 85h, 84h
;zloc_1800:
	db	7Ah, 8Fh, 74h, 85h, 6Fh, 83h, 6Ah, 80h, 85h, 7Bh, 78h, 7Dh, 88h, 85h, 84h, 76h
	db	7Eh, 77h, 81h, 78h, 82h, 7Fh, 85h, 89h, 89h, 85h, 83h, 83h, 81h, 83h, 78h, 77h
	db	8Ah, 7Dh, 75h, 89h, 88h, 7Bh, 82h, 84h, 69h, 93h, 89h, 86h, 8Ah, 94h, 7Ch, 85h
	db	8Ah, 83h, 7Fh, 8Dh, 8Ah, 67h, 63h, 7Bh, 80h, 7Dh, 7Bh, 7Ch, 75h, 82h, 97h, 79h
	db	91h, 8Dh, 77h, 89h, 8Bh, 7Fh, 81h, 79h, 7Bh, 7Dh, 78h, 7Ch, 79h, 7Eh, 77h, 83h
	db	69h, 86h, 92h, 97h, 8Bh, 91h, 85h, 8Fh, 87h, 8Dh, 7Dh, 8Ch, 84h, 78h, 61h, 7Eh
	db	85h, 84h, 86h, 85h, 75h, 7Dh, 8Bh, 82h, 97h, 89h, 84h, 82h, 70h, 79h, 74h, 8Bh
	db	7Fh, 67h, 8Fh, 73h, 6Dh, 7Fh, 86h, 75h, 84h, 83h, 70h, 82h, 97h, 8Bh, 7Ch, 7Dh
	db	86h, 7Ah, 87h, 80h, 8Bh, 7Dh, 7Eh, 86h, 7Bh, 8Ch, 83h, 84h, 84h, 65h, 76h, 8Fh
	db	85h, 7Dh, 83h, 70h, 87h, 7Eh, 7Fh, 78h, 90h, 86h, 70h
	
zloc_189B:
	db	93h, 51h, 6Fh, 3Ch, 3Bh
	db	6Ch, 0E0h, 0A8h, 50h, 3Eh, 67h, 8Bh, 40h, 56h, 85h, 6Bh, 23h, 5Ah, 69h, 71h, 81h
	db	38h, 0DEh, 52h, 96h, 79h, 91h, 87h, 87h, 9Fh, 93h, 87h, 0B4h, 0B7h, 8Ch, 63h, 9Ah
	db	89h, 9Fh, 0FFh, 73h, 7Dh, 51h, 91h, 8Ch, 64h, 94h, 9Fh, 7Fh, 61h, 80h, 7Fh, 7Bh
	db	72h, 5Fh, 0ACh, 56h, 82h, 6Bh, 6Fh, 80h, 0D4h, 55h, 8Bh, 9Ch, 86h, 0A4h, 7Fh, 6Ah
	db	5Eh, 95h, 92h, 88h, 98h, 98h, 0A1h, 54h, 60h, 60h, 69h, 6Dh, 75h, 74h, 0BEh, 10h
	db	0B5h, 99h, 0C0h, 62h, 43h, 8Ch, 2Bh, 0AEh, 0A0h, 0B1h, 58h, 7Ch, 7Ah, 64h, 0B3h, 8Bh
	db	5Eh, 73h, 6Ch, 74h, 0C3h, 61h, 82h, 9Bh, 7Dh, 9Dh, 0CFh, 56h, 70h, 88h, 83h, 9Ah
	db	0A2h, 0C0h, 8Fh, 8Ah, 6Ch, 86h, 69h, 76h, 8Dh, 79h, 0BAh, 81h, 6Dh, 7Dh, 86h, 7Dh
	db	9Bh, 0A9h, 5Ch, 8Eh, 50h, 71h, 94h, 78h, 73h, 80h, 44h, 9Eh, 3Dh, 0A7h, 43h, 0C1h
	db	8Fh, 0A9h, 8Ch, 9Eh, 64h, 0B6h, 0A3h, 8Fh, 8Eh, 86h, 7Fh, 92h, 92h, 57h, 7Ah, 61h
	db	67h, 0A1h, 47h, 8Dh, 7Dh, 95h, 7Dh, 0A4h, 47h, 5Dh, 41h, 8Bh, 75h, 97h, 9Bh, 95h
	db	5Eh, 9Bh, 61h, 54h, 95h, 65h, 76h, 0A6h, 0A7h, 6Eh, 9Eh, 0B4h, 6Dh, 7Ch, 0A4h, 8Dh
	db	89h, 8Bh, 6Bh, 58h, 59h, 0A6h, 8Bh, 92h, 5Bh, 7Ch, 76h, 83h, 74h, 7Ch, 99h, 84h
	db	5Fh, 97h, 76h, 4Ch, 76h, 79h, 5Bh, 83h, 7Fh, 7Dh, 6Eh, 94h, 6Ah, 88h, 60h, 0A9h
	db	97h, 79h, 86h, 63h, 90h, 8Eh, 90h, 85h, 73h, 80h, 85h, 43h, 93h, 6Eh, 8Bh, 74h
	db	80h, 77h, 75h, 7Fh, 81h, 7Bh, 7Fh, 61h, 8Ah, 7Bh, 8Dh, 70h, 7Dh, 87h, 84h, 89h
	db	9Eh, 5Dh, 91h, 8Bh, 86h, 79h, 87h, 8Dh, 5Eh, 7Dh, 81h, 79h, 86h, 79h, 8Bh, 6Ch
	db	7Ah, 7Fh, 76h, 81h, 86h, 6Dh, 74h, 71h, 7Bh, 85h, 8Bh, 6Ch, 76h, 74h, 79h, 91h
	db	78h, 74h, 6Fh, 80h, 7Dh, 89h, 7Ah, 8Fh, 7Eh, 91h, 7Fh, 81h, 61h, 73h, 8Dh, 85h
	db	8Fh, 84h, 92h, 8Bh, 8Fh, 84h, 7Eh, 85h, 93h, 77h, 75h, 89h, 70h, 7Eh, 7Dh, 6Bh
	db	75h, 91h, 77h, 7Fh, 89h, 84h, 7Fh, 7Fh, 87h, 74h, 6Dh, 72h, 77h, 7Ch, 7Eh, 7Bh
	db	79h, 8Bh, 7Fh, 8Ah, 89h, 88h, 8Dh, 8Fh, 7Dh, 82h, 8Dh, 78h, 8Fh, 76h, 81h, 78h
; zloc_1A00:
	db	7Eh, 85h, 7Fh, 6Eh, 78h, 81h, 7Dh, 79h, 86h, 7Fh, 79h, 7Ch, 81h, 83h, 72h, 86h
	db	80h, 7Eh, 89h, 72h, 79h, 87h, 80h, 87h, 86h, 84h, 84h, 86h, 87h, 82h, 87h, 7Ch
	db	82h, 86h, 85h, 83h, 7Ch, 86h, 89h, 7Bh, 80h, 83h, 7Eh, 7Ah, 82h, 7Ch, 7Ah, 81h
	db	7Bh, 84h, 7Fh, 77h, 7Fh, 74h, 82h, 83h, 83h, 7Bh, 7Ch, 84h, 7Ch, 80h, 83h, 87h
	db	7Bh, 84h, 83h, 80h, 80h, 80h, 82h, 84h, 7Fh, 81h, 85h, 7Bh, 7Fh, 7Fh, 81h, 7Ch
	db	7Ch, 83h, 7Ch, 7Ah, 83h, 7Fh, 7Bh, 86h, 83h, 85h, 7Bh, 84h, 7Eh, 7Fh, 83h, 83h
	db	85h, 7Dh, 82h, 80h, 80h, 7Fh, 7Dh, 82h, 7Ch, 7Ch, 83h, 84h, 7Dh, 83h, 85h, 7Dh
	db	81h, 7Eh, 7Ah, 79h, 7Dh, 7Ch, 7Eh, 7Dh, 7Fh, 80h, 7Dh, 7Fh, 7Fh, 81h, 7Eh, 7Eh
	db	82h, 81h, 84h, 7Dh, 87h, 7Dh, 7Fh, 85h, 83h, 80h, 82h, 80h, 84h, 83h, 81h, 7Eh
	db	7Dh, 83h, 7Fh, 7Dh, 7Ch, 7Eh, 80h, 7Dh, 7Ch, 80h, 80h, 81h
	
zloc_1A9C:
	db	0FFh, 0FFh, 0FFh, 0FFh
	db	0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
	
PCMDrumsEnd:
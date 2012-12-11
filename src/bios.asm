	INCLUDE	DOS.INC

;ALL THESE DEFINITIONS ARE DUPLICATED IN BIOS.INC. BE CAREFULL WITH
;THE DIFFERENCE BETWEEN THEM

RDSLT		EQU	0CH
CALSLT		EQU	001CH
EXPTBL		EQU	0FCC1H

RG0SAV		EQU	0F3DFH
RG1SAV		EQU	0F3E0H
RG2SAV		EQU	0F3E1H
RG3SAV		EQU	0F3E2H
RG4SAV		EQU	0F3E3H
RG5SAV		EQU	0F3E4H
RG6SAV		EQU	0F3E5H
RG7SAV		EQU	0F3E6H
RG8SAV		EQU	0FFE7H
RG9SAV		EQU	0FFE8H
RG10SAV		EQU	0FFE9H
RG11SAV		EQU	0FFEAH
RG12SAV		EQU	0FFEBH
RG13SAV		EQU	0FFECH
RG14SAV		EQU	0FFEDH

DPPAGE		EQU	0FAF5H
ACPAGE		EQU	0FAF6H

SPRITEATT	EQU	07600H
SPRITECOL	EQU	07400H
SPRITEGEN	EQU	07800H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		HL = ADDRESS WHERE WRITE 0
;		BC = NUMBER OF BYTES
;		A = BYTE TO WRITE (IN THE CASE OF MEMSET)
	CSEG
	PUBLIC	BZERO,MEMSET

BZERO:
	XOR	A
MEMSET:
	LD	E,L
	LD	D,H
	INC	DE
	DEC	BC
	LD	(HL),A
	LDIR
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OUTPUT:	Z = 0 WHEN EXITS SOME PROBLEM WITH THIS MSX

	CSEG
	PUBLIC	CHKMSX,PWRVDP,PRDVDP

CHKMSX:
	LD	A,(EXPTBL)
	LD	HL,6
	CALL	RDSLT
	LD	(PRDVDP),A

	LD	A,(EXPTBL)
	LD	HL,7
	CALL	RDSLT
	LD	(PWRVDP),A

	LD	A,1
	OR	A
	RET

	DSEG
PRDVDP:	DB	0	;VDP PORT READING
PWRVDP:	DB	0	;VDP PORT WRITING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	MSXTERM

MSXTERM:
	LD	C,TERM0
	JP	BDOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		C = REGISTER NUMBER
;		B = VALUE

	CSEG
	PUBLIC	WRTVDP

WRTVDP:
	PUSH	HL

	LD	L,C
	LD	A,(PWRVDP)
	INC	A
	LD	C,A
	LD	A,L
	OR	80H
	DI
	OUT	(C),B
	OUT	(C),A

	LD	A,L		;UPDATE THE RAM SHADOW VARIABLES
	CP	8
	JR	NC,.WVDP7
	LD	HL,RG8SAV
	JR	.WVDP
.WVDP7:	LD	HL,RG0SAV
.WVDP:	ADD	A,L
	LD	L,A
	JR	NC,.WNINC
	INC	H
.WNINC:	LD	(HL),B

	POP	HL
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		A = SCREEN MODE

	CSEG
	PUBLIC	CHGMOD

CHGMOD:
	LD	IY,(EXPTBL-1)
	LD	IX,5FH		;WE CAN NOT USE THE SAME NAME THAT OWN FUNCTION
	JP	CALSLT		;BUT 5FH IS THE REAL CHGMOD ADDRESS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	DISSCR

DISSCR:
	DI
	LD	A,(RG1SAV)
	AND	0BFH
	LD	B,A
	LD	C,1
	JP	WRTVDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	ENASCR

ENASCR:
	DI
	LD	A,(RG1SAV)
	OR	40H
	LD	B,A
	LD	C,1
	JP	WRTVDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       HL = VRAM ADDRESS

	CSEG
	PUBLIC	SETWRT

SETWRT:
	PUSH	BC
	LD	A,(PWRVDP)
	INC	A
	LD	C,A
	LD	A,H
	AND	3FH
	OR	40H

	DI
	OUT	(C),L
	OUT	(C),A
	POP	BC
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		HL = VRAM ADDRESS

	CSEG
	PUBLIC	SETRD

SETRD:
	PUSH	BC
	LD	A,(PWRVDP)
	INC	A
	LD	C,A
	LD	A,H
	AND	3FH

	DI
	OUT	(C),L
	OUT	(C),A
	POP	BC
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       HL = VRAM ADDRESS
	CSEG
	PUBLIC	NSTWRT

NSTWRT:
	PUSH	BC

	LD	A,(PWRVDP)
	INC	A
	LD	C,A
	LD	A,H
	RLCA
	RLCA
	AND	3
	LD	B,A
	LD	(ACPAGE),A
	LD	(RG14SAV),A
	LD	A,128+14
	DI
	OUT	(C),B		;WRITE THE PAGE INFORMATION
	OUT	(C),A
	OUT	(C),L		;WRITE THE LOW 14 BITS NOW
	LD	A,H
	AND	3FH
	OR	40H
	OUT	(C),A

	POP	BC
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       HL = VRAM ADDRESS

	CSEG
	PUBLIC	NSETRD

NSETRD:
	PUSH	BC

	LD	A,(PWRVDP)
	INC	A
	LD	C,A
	LD	A,H
	RLCA
	RLCA
	AND	3
	LD	B,A
	LD	(ACPAGE),A
	LD	(RG14SAV),A
	LD	A,128+14
	DI
	OUT	(C),B		;WRITE THE PAGE INFORMATION
	OUT	(C),A
	OUT	(C),L		;WRITE THE LOW 14 BITS NOW
	LD	A,H
	AND	3FH
	OUT	(C),A

	POP	BC
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		HL = ADDRESS
;		BC = LENGTH
;		A  = VALUE

	CSEG
	PUBLIC	FILVRM

FILVRM:
	PUSH	HL
	PUSH	AF

	CALL	NSTWRT
	LD	L,C
	LD	H,B		;DE = COUNT
	POP	BC		;B = VALUE
	LD	A,(PWRVDP)
	LD	C,A		;C = VDP WRITING PORT

.FILLOOP:			;IS IS SLOW?, YEAH, A LOT. IF YOU WANT
	OUT	(C),B		;SPEED THEN DON'T USE IT AND GET AN UNROLL
	DEC	HL		;VERSION
	LD	A,L
	OR	H
	JP	NZ,.FILLOOP

	POP	HL
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	CLRSPR

CLRSPR: LD	HL,SPRITEGEN
	LD	BC,8*256
	XOR	A
	CALL	FILVRM		;CLEAR THE SPRITE PATTERNS

	LD	HL,SPRITEATT
	CALL	SETWRT
	LD	B,32
	LD	A,(PWRVDP)
	LD	C,A
	XOR	A
	LD	L,A
	LD	H,217

.CLOOP:	OUT	(C),H		; Y = 217
	OUT	(C),L		; X = 0
	OUT	(C),A		; PATTERN = NUMBER OF PLANE
	OUT	(C),L		; COLOUR = 0
	INC	A
	DJNZ	.CLOOP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       HL = ORIGIN RAM ADDRESS
;             DE = DESTINE VRAM ADDRESS
;             BC = NUMBER OF BYTES
;TODO: USE ALL THE BITS IN HL

	CSEG
	PUBLIC	LDIRVM

LDIRVM:
	EX	DE,HL		;HL = VRAM ADDRESS
	CALL	NSTWRT
	EX	DE,HL		;HL = RAM ADDRESS

	LD	D,B		;D = UPPER COUNT
	LD	B,C		;B = LOWER COUNT
	LD	A,(PWRVDP)
	LD	C,A		;C = VDP PORT
	LD	A,B
	OR	A
	JR	Z,.VLOOP
	INC	D

.VLOOP:	OTIR			;IS IT SLOW? READ THE COMMENT FILVRM
	DEC	D
	JR	NZ,.VLOOP

	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       HL = ORIGIN VRAM ADDRESS
;             DE = DESTINE RAM ADDRESS
;             BC = NUMBER OF BYTES
;TODO: USE ALL THE BITS IN HL

	CSEG
	PUBLIC	LDIRMV

LDIRMV:
	CALL	NSETRD
	EX	DE,HL		;HL = RAM ADDRESS

	LD	D,B		;D = UPPER COUNT
	LD	B,C		;B = LOWER COUNT
	LD	A,(PRDVDP)
	LD	C,A		;C = VDP PORT
	LD	A,B
	OR	A
	JR	Z,.MLOOP
	INC	D

.MLOOP:	INIR			;IS IT SLOW? READ THE COMMENT FILVRM
	DEC	D
	JR	NZ,.MLOOP

	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		A = ROW NUMBER

	CSEG
	PUBLIC	SNMAT

SNMAT:
	LD	C,A
	DI
	IN	A,(0AAH)
	AND	0F0H
	OR	C
	OUT	(0AAH),A
	IN	A,(0A9H)
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	RESISR

RESISR:
	LD	DE,038H
	LD	HL,OLDISR
	LD	BC,5
	DI
	LDIR
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	SETISR

SETISR:
	LD	HL,038H
	LD	DE,OLDISR
	LD	BC,5
	DI
	LDIR			;SAVE OLD ISR

	LD	A,0C3H
	LD	HL,ISR
	LD	(38H),A		;PUT OUR ISR
	LD	(39H),HL
	RET

	DSEG
OLDISR:		DS	5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	VDPHOOK,KBDHOOK

ISR:
	PUSH	AF
	IN	A,(99H)		;TODO: CHANGE THIS
	RLCA
	JP	NC,.ENDISR

	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	IX
	PUSH	IY
	EX	AF,AF'
	EXX
	PUSH	AF
	PUSH	HL
	PUSH	DE
	PUSH	BC

	CALL	VDPHOOK
	CALL	KBDHOOK

	POP	BC
	POP	DE
	POP	HL
	POP	AF
	EXX
	EX	AF,AF'
	POP	IY
	POP	IX
	POP	BC
	POP	DE
	POP	HL

.ENDISR:
	POP	AF
	EI
	RET


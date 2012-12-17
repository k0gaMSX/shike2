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

FORCLR		EQU	0F3E9H
BAKCLR		EQU	0F3EAH
BDRCLR		EQU	0F3EBH

H.TIMI		EQU	0FD9FH

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
	PUBLIC	CHKMSX,VDPW,VDPR

CHKMSX:
	LD	A,(EXPTBL)
	LD	HL,6
	CALL	RDSLT
	LD	(VDPR),A

	LD	A,(EXPTBL)
	LD	HL,7
	CALL	RDSLT
	LD	(VDPW),A

	LD	A,1
	OR	A
	RET

	DSEG
VDPR:		DB	0	;VDP PORT READING
VDPW:		DB	0	;VDP PORT WRITING
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
	PUSH	DE

	LD	A,C		;UPDATE THE RAM SHADOW VARIABLES
	CP	8
	JR	NC,.WVDP7
	LD	HL,RG0SAV
	JR	.WVDP
.WVDP7:	LD	HL,RG8SAV
.WVDP:	ADD	A,L
	LD	L,A
	JR	NC,.WNINC
	INC	H

.WNINC:	LD	E,C
	LD	D,B
	LD	BC,(VDPW)
	INC	C
	LD	A,E
	OR	80H

	DI
	OUT	(C),D
	OUT	(C),A
	LD	(HL),D          ;UPDATE THE RAM SHADOW VARIABLES
	EI

	POP	DE
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
	LD	A,(RG1SAV)
	AND	0BFH
	LD	B,A
	LD	C,1
	JP	WRTVDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	ENASCR

ENASCR:
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
	LD	BC,(VDPW)
	INC	C
	RES	7,H
	SET	6,H

	DI
	OUT	(C),L
	OUT	(C),H
	EI

	POP	BC
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		HL = VRAM ADDRESS

	CSEG
	PUBLIC	SETRD

SETRD:
	PUSH	BC
	LD	BC,(VDPW)
	INC	C
	RES	7,H
	RES	6,H

	DI
	OUT	(C),L
	OUT	(C),A
	EI

	POP	BC
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       HL = VRAM ADDRESS
	CSEG
	PUBLIC	NSTWRT

NSTWRT:
	PUSH	BC

	LD	BC,(VDPW)
	INC	C
	LD	A,H
	RLCA
	RLCA
	AND	3
	LD	B,A
	LD	A,128+14
	RES	7,H
	SET	6,H

	DI
	OUT	(C),B		;WRITE THE PAGE INFORMATION
	OUT	(C),A
	OUT	(C),L		;WRITE THE LOW 14 BITS NOW
	OUT	(C),H
	LD	(RG14SAV),A
	EI

	POP	BC
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       HL = VRAM ADDRESS

	CSEG
	PUBLIC	NSETRD

NSETRD:
	PUSH	BC

	LD	BC,(VDPW)
	INC	C
	LD	A,H
	RLCA
	RLCA
	AND	3
	LD	B,A
	LD	A,128+14
	RES	7,H
	RES	6,H

	DI
	OUT	(C),B		;WRITE THE PAGE INFORMATION
	OUT	(C),A
	OUT	(C),L		;WRITE THE LOW 14 BITS NOW
	OUT	(C),H
	LD	(RG14SAV),A
	EI

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
	LD	A,(VDPW)
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
;INPUT:       (FORCLR) = FOREGROUND COLOR (IT IS IGNORED)
;             (BAKCLR) = BACKGROUND COLOR (IT IS IGNORED)
;             (BDRCLR) = BORDER COLOR

	CSEG
	PUBLIC	CHGCLR

CHGCLR:
	LD	A,(BDRCLR)
	LD	B,A
	LD	C,7
	JP	WRTVDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	CLRSPR

CLRSPR: LD	HL,SPRITEGEN
	LD	BC,8*256
	XOR	A
	CALL	FILVRM		;CLEAR THE SPRITE PATTERNS

	LD	HL,SPRITEATT
	CALL	NSTWRT
	LD	BC,(VDPW)
	LD	B,32
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
	LD	A,(VDPW)
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
	LD	A,(VDPR)
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
	LD	HL,OLDHOOK
	LD	DE,H.TIMI
	LD	BC,5
	DI
	LDIR
	EI
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	SETISR

SETISR:
        LD	HL,.HOOK
	LD	DE,H.TIMI
	LD	BC,5
	EXX
	LD	HL,H.TIMI
	LD	DE,OLDHOOK
	LD	BC,5
	DI
	LDIR
	EXX
	LDIR
	EI
	RET

.HOOK:	JP	ISR
	NOP
	NOP

	DSEG
OLDHOOK:	DS	5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	VDPHOOK,KBDHOOK

ISR:
	CALL	VDPHOOK
	CALL	KBDHOOK
	RET



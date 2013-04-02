
BIOS.ASM	EQU	1

	INCLUDE	BIOS.INC

	PUBLIC	KBDQUEUE,KBDOLD,KBDBUF,VDPR,VDPW,SPRBUF

VDPR		EQU	KBUF		;VDP PORT READING
VDPW		EQU	VDPR+1		;VDP PORT WRITING
SPRBUF		EQU	VDPW+1		;SHADOW SPRITE ATTRIBUTE TABLE
KBDQUEUE	EQU	SPRBUF + 32*4	;QUEUE POINTER
KBDOLD		EQU	KBDQUEUE+2	;OLD MATRIX STATUS
KBDBUF		EQU	KBDOLD+11	;QUEUE BUFFER

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: E = CARTRIDGE PAGE

	CSEG
	PUBLIC	CARTPAGE

CARTPAGE:
	LD	A,7
	ADD	A,E
	OUT	(0FDH),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = DEVICE ID (12,13,14 FOR MOUSE 1 AND 16,17,18 FOR MOUSE 2)

	CSEG
	PUBLIC	GTPAD

GTPAD:	LD	IY,(EXPTBL-1)
	LD	IX,0DBH		;WE CAN NOT USE THE SAME NAME THAT OWN FUNCTION
	JP	CALSLT		;BUT 0D8H IS THE REAL GTPAD ADDRESS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OUTPUT:	Z = 0 WHEN EXITS SOME PROBLEM WITH THIS MSX

	CSEG
	PUBLIC	CHKMSX

CHKMSX:	LD	A,(EXPTBL)
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		C = REGISTER NUMBER
;		B = VALUE

	CSEG
	PUBLIC	WRTVDP
	EXTRN	ADDAHL

WRTVDP:	PUSH	HL
	PUSH	DE

	LD	A,C		;UPDATE THE RAM SHADOW VARIABLES
	CP	8
	JR	NC,.WVDP7
	LD	HL,RG0SAV
	JR	.WVDP
.WVDP7:	LD	HL,RG8SAV
.WVDP:	CALL	ADDAHL
	LD	E,C
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
;INPUT:	HL = 1ST OPERAND
;	DE = 2ND OPERAND
;OUTPUT:Z = 1 WHEN HL = DE, CY = 1 WHEN HL < DE

	CSEG
	PUBLIC	DCOMPR

DCOMPR:	LD	A,H
	CP	D
	RET	NZ
	LD	A,L
	CP	E
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		A = SCREEN MODE

	CSEG
	PUBLIC	CHGMOD

CHGMOD:	LD	IY,(EXPTBL-1)
	LD	IX,5FH		;WE CAN NOT USE THE SAME NAME THAT OWN FUNCTION
	JP	CALSLT		;BUT 5FH IS THE REAL CHGMOD ADDRESS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	DISSCR

DISSCR:	LD	A,(RG1SAV)
	AND	0BFH
	LD	B,A
	LD	C,1
	JP	WRTVDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	ENASCR

ENASCR:	LD	A,(RG1SAV)
	OR	40H
	LD	B,A
	LD	C,1
	JP	WRTVDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       HL = VRAM ADDRESS

	CSEG
	PUBLIC	SETWRT

SETWRT:	PUSH	BC
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

SETRD:	PUSH	BC
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

NSTWRT:	PUSH	BC

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

NSETRD:	PUSH	BC

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

FILVRM:	PUSH	HL
	PUSH	AF

	CALL	NSTWRT
	LD	L,C
	LD	H,B		;DE = COUNT
	POP	BC		;B = VALUE
	LD	A,(VDPW)
	LD	C,A		;C = VDP WRITING PORT

	DI
.FILLOOP:			;IS IS SLOW?, YEAH, A LOT. IF YOU WANT
	OUT	(C),B		;SPEED THEN DON'T USE IT AND GET AN UNROLL
	DEC	HL		;VERSION
	LD	A,L
	OR	H
	JP	NZ,.FILLOOP
	EI

	POP	HL
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       (FORCLR) = FOREGROUND COLOR (IT IS IGNORED)
;             (BAKCLR) = BACKGROUND COLOR (IT IS IGNORED)
;             (BDRCLR) = BORDER COLOR

	CSEG
	PUBLIC	CHGCLR

CHGCLR:	LD	A,(BDRCLR)
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

	DI
.CLOOP:	OUT	(C),H		; Y = 217
	OUT	(C),L		; X = 0
	OUT	(C),A		; PATTERN = NUMBER OF PLANE
	OUT	(C),L		; COLOUR = 0
	INC	A
	DJNZ	.CLOOP
	EI
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       HL = ORIGIN RAM ADDRESS
;             DE = DESTINE VRAM ADDRESS
;             BC = NUMBER OF BYTES
;TODO: USE ALL THE BITS IN HL

	CSEG
	PUBLIC	LDIRVM

LDIRVM:	EX	DE,HL		;HL = VRAM ADDRESS
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

	DI
.VLOOP:	OTIR			;IS IT SLOW? READ THE COMMENT FILVRM
	DEC	D
	JR	NZ,.VLOOP
	EI

	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       HL = ORIGIN VRAM ADDRESS
;             DE = DESTINE RAM ADDRESS
;             BC = NUMBER OF BYTES
;TODO: USE ALL THE BITS IN HL

	CSEG
	PUBLIC	LDIRMV

LDIRMV:	CALL	NSETRD
	EX	DE,HL		;HL = RAM ADDRESS

	LD	D,B		;D = UPPER COUNT
	LD	B,C		;B = LOWER COUNT
	LD	A,(VDPR)
	LD	C,A		;C = VDP PORT
	LD	A,B
	OR	A
	JR	Z,.MLOOP
	INC	D

	DI
.MLOOP:	INIR			;IS IT SLOW? READ THE COMMENT FILVRM
	DEC	D
	JR	NZ,.MLOOP
	EI

	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	KILBUF

KILBUF:	DI
	LD	HL,KEYBUF
	LD	(PUTPNT),HL
	LD	(GETPNT),HL
	EI
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		A = ROW NUMBER

	CSEG
	PUBLIC	SNMAT

SNMAT:	LD	C,A
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

RESISR:	LD	HL,OLDHOOK
	LD	DE,H.TIMI
	LD	BC,5
	DI
	LDIR
	EI
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	SETISR

SETISR:	IN	A,(0A8H)		;SAVE GAME SLOT CONFIGURATION
	LD	(OLDA8),A
	LD	A,(0FFFFH)
	CPL
	LD	(OLDFFFF),A

	LD	HL,ISR			;COPY ROUTINE TO PAGE 2
	LD	DE,ISRSHADOW
	LD	BC,ISR.END-ISR
	LDIR

	LD	HL,.HOOK
	LD	DE,H.TIMI
	LD	BC,5
	EXX
	LD	HL,H.TIMI
	LD	DE,OLDHOOK
	LD	BC,5
	DI
	LDIR				;SAVE OLD HOOK
	EXX
	LDIR				;PUT OUT HOOK
	EI
	HALT				;WAIT ONE INTERRUPT
	RET

.HOOK:	JP	ISRSHADOW
	NOP
	NOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	VDPHOOK,KBDHOOK,MOUSEHOOK

ISR:	LD	A,(0FFFFH)		;SAVE BIOS SLOT SLOT CONFIGURATION
	CPL
	PUSH	AF
	IN	A,(0A8H)
	PUSH	AF

	LD	A,(OLDA8)		;RESTORE GAME SLOT CONFIGURATION
	OUT	(0A8H),A
	LD	A,(OLDFFFF)
	LD	(0FFFFH),A

	CALL	VDPHOOK
	CALL	MOUSEHOOK
	CALL	KBDHOOK

	POP	AF			;RESTORE BIOS SLOT CONFIGURATION
	OUT	(0A8H),A
	POP	AF
	LD	(0FFFFH),A
	JP	OLDHOOK			;JUMP TO PREVIOUS HOOK
ISR.END:

	DSEG
ISRSHADOW:	DS	ISR.END-ISR
OLDA8:		DB	0
OLDFFFF:	DB	0
OLDHOOK:	DS	5


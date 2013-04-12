	INCLUDE	SHIKE2.INC
	INCLUDE	BIOS.INC

;VDP COMMANDS OPCODES
OPHMMC		EQU	0F0H
OPYMMM		EQU	0E0H
OPHMMM		EQU	0D0H
OPHMMV		EQU	0C0H
OPLMMC		EQU	0B0H
OPLMCM		EQU	0A0H
OPLMMM		EQU	090H
OPLMMV		EQU	080H
OPLINE		EQU	070H
OPSRCH		EQU	060H
OPPSET		EQU	050H
OPPOINT		EQU	040H
OPSTOP		EQU	000H

CMDSIZE	EQU	15
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	INITVDP

INITVDP:LD	A,1
	LD	(BDRCLR),A      ;BLACK BORDER
	LD	A,15
	LD	(FORCLR),A	;WHITE FOREGROUND COLOR
	LD	A,14
	LD	(BAKCLR),A	;BLACK BACKGROUND COLOR
	LD	A,5
	CALL	CHGMOD

	CALL	SPR16X16
	CALL	SPRNDBL
	CALL	ENASPR

	LD	A,(RG9SAV)
	SET	7,A		;SET 212 PIXELS IN Y
	LD	B,A
	LD	C,9
	CALL	WRTVDP

	CALL	CLRSPR
	LD	HL,SPRITEATT
	LD	DE,SPRBUF
	LD	BC,32*4
	CALL	LDIRMV		;GET A COPY OF THE SPRITE ATTRIBUTE TABLE

	LD	A,LOGIMP	;DEFAULT PARAMETERS FOR VDP COMMANDS
	LD	(LOGOP),A
	XOR	A
	LD	(CMDARG),A	;DEFAULT VALUE OF VDP ARGUMENT
	LD	A,1
	LD	(DPPAGE),A

	XOR	A
	LD	(ACPAGE),A	;INITIALISE THE PAGES TO CORRECT VALUES
	LD	(DPPAGE),A
	CALL	SETPAGE
	CALL	RESSCROLL	;RESET SCROLL VALUE
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	SPR16X16,SPR8X8,SPRDBL,SPRNDBL

SPR16X16:
	LD	A,(RG1SAV)
	OR	2		;SET SPRITES 16X16
	JR	S.WR

SPR8X8:	LD	A,(RG1SAV)
	AND	0FDH		;RESET SPRITES 16X16
	JR	S.WR

SPRNDBL:LD	A,(RG1SAV)
	AND	0FEH		;RESET DOUBLE SIZE SPRITES
	JR	S.WR

SPRDBL:	LD	A,(RG1SAV)
	OR	1		;SET DOUBLE SIZE SPRITES

S.WR:	LD	B,A
	LD	C,1
	JP	WRTVDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	DISSPR,ENASPR

DISSPR:	LD	A,(RG8SAV)
	SET	1,A		;DISABLE SPRITES
	JR	SP.WR

ENASPR:	LD	A,(RG8SAV)
	RES	1,A		;ENABLE SPRITES

SP.WR:	LD	B,A
	LD	C,8
	JP	WRTVDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		HL = PALLETE

	CSEG
	PUBLIC	SETPAL

SETPAL:	LD	BC,(VDPW)
	INC	C
	INC	C
	LD	B,32
	EXX
	LD	BC,(VDPW)
	INC	C
	XOR	A
	LD	B,128+16
	DI
	OUT	(C),A
	OUT	(C),B
	EXX
	OTIR
	EI
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		E -> SCROLL INCREMENT

	CSEG
	PUBLIC	SCROLL,RESSCROLL

RESSCROLL:
	XOR	A
	JR	S.SET

SCROLL:	LD	A,(S.DATA)
	ADD	A,E

S.SET:	LD	(S.DATA),A
	LD	B,A
	LD	C,23
	JP	WRTVDP


	DSEG
S.DATA:	DB	0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       (ACPAGE) = ACTUAL PAGE
;             (DPPAGE) = DISPLAY PAGE
	CSEG
	PUBLIC	SETPAGE

SETPAGE:LD	A,(DPPAGE)
	LD	B,A

SHOWPAGE:	;INPUT: B = DISPLAY PAGE
	LD	A,B
	RRCA
	RRCA
	RRCA
	OR	01FH
	LD	B,A
	LD	C,2
	CALL	WRTVDP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	E = ORIGIN PAGE
;	C = DESTINE PAGE

	CSEG
	PUBLIC	CPVPAGE

CPVPAGE:LD	A,(ACPAGE)
	PUSH	AF
	LD	A,C
	LD	(ACPAGE),A		;COPY A FULL PAGE
	LD	A,E
	LD	(VDPPAGE),A
	LD	HL,0
	LD	DE,0
	LD	BC,000D4H
	CALL	HMMM
	POP	AF
	LD	(ACPAGE),A
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		E = PAGE NUMBER

	CSEG
	PUBLIC	CLRVPAGE

CLRVPAGE:
	LD	A,(ACPAGE)
	PUSH	AF
	LD	A,E
	LD	(ACPAGE),A
	XOR	A
	LD	(FORCLR),A

	LD	BC,00D4H
	LD	DE,0
	CALL	HMMV
	POP	AF
	LD	(ACPAGE),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = RAM ADDRESS
;	DE = VRAM ADDRESS	(UNTIL 3FFF)
;	BC = COUNT		(UNTIL 4000)
;	A = VRAM PAGE

	CSEG
	PUBLIC	VLDIR
	EXTRN	WRTVDP,SETWRT,VDPW

VLDIR:	PUSH	HL
	PUSH	BC
	PUSH	DE

	LD	B,A
	LD	C,14
	CALL	WRTVDP		;WRITE VRAM PAGE
	POP	HL
	CALL	SETWRT		;SET ADDRESS

	POP	DE		;D = UPPER COUNT
	LD	B,E		;B = LOWER COUNT
	POP	HL		;HL = ADDRESS

	LD	A,(VDPW)
	LD	C,A		;C = VDP PORT
	LD	A,B
	OR	A
	JR	Z,V.LOOP
	INC	D

V.LOOP:	OTIR
	DEC	D
	JR	NZ,V.LOOP

	EI
	RET





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       C = PATTERN NUMBER
;             DE = PATTERN DATA
;             B = NUMBER SPRITES
	CSEG
	PUBLIC	SPRITE

SPRITE:	LD	L,B
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	PUSH	HL
	LD	L,C
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	BC,SPRITEGEN
	ADD	HL,BC
	EX	DE,HL

	POP	BC
	CALL	LDIRVM
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       C = SPRITE NUMBER
;             E = COLOUR NUMBER
;             B = NUMBER SPRITES

	CSEG
	PUBLIC	SETCOLSPR
	EXTRN	MEMSET

SETCOLSPR:
	PUSH	BC
	LD	BC,16
	LD	A,E
	LD	HL,S.COL
	CALL	MEMSET
	POP	BC
	LD	DE,S.COL
	; CONTINUE IN COLORNSPRITE

	DSEG
S.COL:	DS	16

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       C = SPRITE NUMBER
;             DE = COLOUR DATA
;             B = NUMBER SPRITES

	CSEG
	PUBLIC	COLORNSPRITE

COLORNSPRITE:
	PUSH	BC
	PUSH	DE
	LD	B,1
	CALL	COLORSPRITE
	POP	DE
	POP	BC
	INC	C
	DJNZ	COLORNSPRITE
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       C = SPRITE NUMBER
;             DE = COLOUR DATA
;             B = NUMBER SPRITES

	CSEG
	PUBLIC	COLORSPRITE

COLORSPRITE:
	LD	L,B
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	PUSH	HL
	LD	L,C
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	BC,SPRITECOL
	ADD	HL,BC
	EX	DE,HL

	POP	BC
	CALL	LDIRVM
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	DELSPR

DELSPR:	LD	C,32

.DLOOP:	DEC	C
	PUSH	BC
	CALL	HIDESPRITE
	POP	BC
	LD	A,C
	OR	A
	JR	NZ,.DLOOP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		C = NUMBER SPRITE

	CSEG
	PUBLIC	HIDESPRITE

HIDESPRITE:
	LD	B,C
	LD	DE,218
	;CONTINUE IN PUTSPRITE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       C = NUMBER SPRITE
;             B = NUMBER PATTERN
;             D = X
;             E = Y

	CSEG
	PUBLIC	PUTSPRITE

PUTSPRITE:
	DEC	E			;SPRITES ARE LOCATED -1
	LD	L,C
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	PUSH	DE
	LD	DE,SPRBUF
	ADD	HL,DE
	POP	DE

	DI
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),B
	EI
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       C = NUMBER WHICH WILL BE MULTIPLIED BY 15
;OUTPUT:	HL = PRODUCT

	CSEG

MUL15:	LD	L,C
	LD	H,0
	PUSH	HL
	ADD	HL,HL
	LD	E,L
	LD	D,H		;DE = IN * 2
	ADD	HL,HL
	LD	C,L
	LD	B,H		;BC = IN * 4
	ADD	HL,HL		;HL = IN * 8
	ADD	HL,DE
	ADD	HL,BC	;HL = IN * 14
	POP	DE	;DE = IN
	ADD	HL,DE	;HL = IN * 15 (SIZE OF EACH COMMAND)
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		CMDBUF	= COMMAND DATA
;
	CSEG
	PUBLIC	VDPCMD,VDPEND
	EXTRN	VDPW

VDPCMD:	LD	BC,(QPOINTER)	; C = IN, B = OUT
	LD	A,C
	INC	A
	AND	NR_CMDBUF - 1	;NR_CMDBUF MUST BE A POWER OF 2
	CP	B
	JR	NZ,.CMD1
	CALL	VDPEND		;NO ROOM FOR NEW COMMANDS, MUST BE ONE RUNNING
	JR	VDPCMD		;TRY AGAIN

.CMD1:	PUSH	BC
	EX	AF,AF'		;SAVE NEXT POSITION
	CALL	MUL15		;HL = C * CMDSIZE
	LD	DE,QUEUE
	ADD	HL,DE
	EX	DE,HL
	LD	HL,CMDBUF
	LD	BC,CMDSIZE
	LDIR			;COPY THE COMMAND TO THE QUEUE
	EX	AF,AF'		;RESTORE NEXT POSITION
	POP	BC

	LD	C,A
	LD	(QPOINTER),BC	;CONTINUE IN VDPEND

;OUTPUT:	Z = 1 WHEN IT FREES A COMMAND

VDPEND:	CALL	ISBUSY		;COMMAND IS STILL RUNNING
	JR	NZ,.FERR

	LD	BC,(QPOINTER)	;C = IN, B = OUT
	LD	A,B
	CP	C
	JR	Z,.FERR		;THERE ISN'T ANY NEW COMMAND

	PUSH	BC
	LD	C,B
	CALL	MUL15           ;HL = C * CMDSIZE
	LD	DE,QUEUE
	ADD	HL,DE
	LD	BC,(VDPW)
	INC	C
	LD	B,CMDSIZE
	LD	E,32
	LD	D,128+17

	DI
	OUT	(C),E
	OUT	(C),D		;SET INDIRECT REGISTER
	INC	C
	INC	C
	OTIR			;SEND THE COMMAND
	EI
	POP	BC

	LD	A,B             ;A = OUT COUNTER
	INC	A
	AND	NR_CMDBUF - 1	;NR_CMDBUF MUST BE A POWER OF 2
	LD	B,A		;UPDATE THE OUT COUNTER
	LD	(QPOINTER),BC

	LD	A,1
	OR	A		;SET NZ FLAG
	RET

.FERR:	XOR	A		;SET Z FLAG
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OUTPUT:	Z = 1 WHEN CMD IS RUNNING
	CSEG
	EXTRN	VDPR

ISBUSY:	LD	BC,(VDPR)
	INC	C
	EXX
	LD	BC,(VDPW)
	INC	C
	LD	B,128+15
	LD	L,2
	LD	H,0
	DI
	OUT	(C),L
	OUT	(C),B
	EXX
	IN	A,(C)
	EXX
	OUT	(C),H
	OUT	(C),B
	EI
	AND	1
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	VDPSYNC

VDPSYNC:LD	BC,(QPOINTER)
	LD	A,B
	CP	C
	RET	Z
	CALL	VDPEND
	JR	VDPSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		D = ORIGIN X
;		E = ORIGIN Y
;		B = NUMBER OF DOTS IN X
;		C = NUMBER OF DOTS IN Y
;		(ACPAGE) = PAGE
;		(FORCLR) = COLOR
;		(CMDARG) = VDP COMMAND ARGUMENT
	CSEG
	PUBLIC	HMMV,LMMV

HMMV:	LD	IY,CMDBUF
	LD	(IY+14),OPHMMV	;CMD
	JR	RECT

;		(LOGOP) = LOGICAL OPERATION

LMMV:	LD	IY,CMDBUF
	LD	A,(LOGOP)
	OR	OPLMMV
	LD	(IY+14),A

RECT:	LD	(IY+4),D	;ORIGIN X
	LD	(IY+5),0
	LD	(IY+6),E	;ORIGIN Y
	LD	A,(ACPAGE)
	LD	(IY+7),A	;PAGE
	LD	(IY+8),B	;NX
	LD	(IY+9),0
	LD	(IY+10),C	;NY
	LD	(IY+11),0
	LD	A,(FORCLR)
	LD	E,A
	RLCA
	RLCA
	RLCA
	RLCA
	OR	E
	LD	(IY+12),A	;CLR
	LD	A,(CMDARG)	;ARG
	LD	(IY+13),A
	JP	VDPCMD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		H = ORIGIN X
;		L = ORIGIN Y
;		D = DESTINE X
;		E = DESTINE Y
;		B = X SIZE
;		C = Y SIZE
;		(ACPAGE) = PAGE
;		(CMDARG) = VDP COMMAND ARGUMENT
;		(VDPPAGE) = VDP SOURCE PAGE
	CSEG
	PUBLIC	HMMM,LMMM
HMMM:	LD	IY,CMDBUF
	LD	(IY+14),OPHMMM	;CMD
	JR	COPY

;		(LOGOP) = LOGICAL OPERATION

LMMM:	LD	IY,CMDBUF
	LD	A,(LOGOP)
	OR	OPLMMM
	LD	(IY+14),A

COPY:	LD	(IY+0),H	;<- SX
	LD	(IY+1),0
	LD	(IY+2),L	;<- SY
	LD	A,(VDPPAGE)
	LD	(IY+3),A	;<- GRAPHIC SOURCE PAGE
	LD	(IY+4),D	;<- DX
	LD	(IY+5),0
	LD	(IY+6),E	;<- DY
	LD	A,(ACPAGE)
	LD	(IY+7),A	;ACTUAL PAGE
	LD	(IY+8),B	;NX
	LD	(IY+9),0
	LD	(IY+10),C	;NY
	LD	(IY+11),0
	LD	A,(CMDARG)
	LD	(IY+13),A	;ARG
	JP	VDPCMD


	DSEG
	PUBLIC	VDPPAGE
VDPPAGE:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		D = ORIGIN X
;		E = ORIGIN Y
;		B = DESTINE X
;		C = DESTINE Y
;		(ACPAGE) = PAGE
;		(LOGOP) = LOGICAL OPERATION
;		(FORCLR) = COLOR
;		(CMDARG) = VDP COMMAND ARGUMENT
	CSEG
	PUBLIC	LINE

LINE:	LD	IY,CMDBUF
	LD	(IY+4),D	;<- ORIGIN X
	LD	(IY+5),0
	LD	(IY+6),E	;<- ORIGIN Y
	LD	A,(ACPAGE)
	LD	(IY+7),A	;<- PAGE

	LD	A,D		;CALCULATE B = NX, D = DIX
	SUB	B
	LD	D,4
	JR	NC,.L1
	LD	D,0
	NEG

.L1:	LD	B,A
	LD	A,E		;CALCULATE C = NY, E = DIY
	SUB	C
	LD	E,8
	JR	NC,.L2
	LD	E,0
	NEG

.L2:	LD	C,A		;CALCULATE B = MAJ, C = MIN
	CP	B
	LD	L,0
	JR	C,.L3
	LD	L,1
	LD	A,B
	LD	B,C
	LD	C,A

.L3:	LD	(IY+8),B	;<- MAJ
	LD	(IY+9),0
	LD	(IY+10),C	;<- MIN
	LD	(IY+11),0
	LD	A,(FORCLR)
	LD	(IY+12),A	;<- COLOR
	LD	A,(CMDARG)
	AND	0F0H
	OR	L
	OR	E
	OR	D
	LD	(IY+13),A	;<- ARG
	LD	A,(LOGOP)
	OR	OPLINE
	LD	(IY+14),A
	JP	VDPCMD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	VDPHOOK

VDPHOOK:CALL	SETPAGE
	LD	HL,SPRBUF
	LD	DE,SPRITEATT
	LD	BC,32*4
	CALL	LDIRVM		;TODO: CHANGE TO FAST COPY
	RET

	DSEG

CMDBUF:		DS	CMDSIZE			;BUFFER WHERE BUILD VDP COMMANDS
QUEUE:		DS	CMDSIZE*NR_CMDBUF	;QUEUE BUFFER FOR VDP COMMANDS
QPOINTER:	DW	0			;QUEUE POINTERS
SPRBUF:		DS	32*4			;SHADOW SPRITE ATTRIBUTE TABLE


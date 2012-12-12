	INCLUDE	BIOS.INC


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	INITVDP

INITVDP:
	LD	A,5
	CALL	CHGMOD

	LD	A,(RG1SAV)
	OR	2		;SET SPRITES 16X16
	AND	0FEH		;RESET DOUBLE SIZE SPRITE
	LD	B,A
	LD	C,1
	CALL	WRTVDP

	LD	A,(RG8SAV)
	RES	1,A		;ENABLE SPRITES
	LD	B,A
	LD	C,8
	CALL	WRTVDP

	CALL	CLRSPR
	LD	HL,SPRITEATT
	LD	DE,SPRITEBUF
	LD	BC,32*4
	CALL	LDIRMV		;GET A COPY OF THE SPRITE ATTRIBUTE TABLE

	XOR	A
	LD	(ACPAGE),A	;INITIALISE THE PAGES TO CORRECT VALUES
	LD	(DPPAGE),A
	CALL	SETPAGE

	EI
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       (ACPAGE) = ACTUAL PAGE
;             (DPPAGE) = DISPLAY PAGE
	CSEG
	PUBLIC	SETPAGE

SETPAGE:
	LD	A,(ACPAGE)
	LD	B,A
	LD	C,14
	CALL	WRTVDP
	EI
	LD	A,(DPPAGE)
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
	EI
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       C = PATTERN NUMBER
;             DE = PATTERN DATA

	CSEG
	PUBLIC	SPRITE

SPRITE:
	LD	L,C
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	BC,SPRITEGEN
	ADD	HL,BC
	EX	DE,HL

	LD	BC,32
	CALL	LDIRVM
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       C = SPRITE NUMBER
;             DE = COLOUR DATA

	CSEG
	PUBLIC	COLORSPRITE

COLORSPRITE:
	LD	L,C
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	BC,SPRITECOL
	ADD	HL,BC
	EX	DE,HL

	LD	BC,16
	CALL	LDIRVM
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:       C = NUMBER SPRITE
;             B = NUMBER PATTERN
;             D = X
;             E = Y

	CSEG
	PUBLIC	PUTSPRITE

PUTSPRITE:
	LD	L,C
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	PUSH	DE
	LD	DE,SPRITEBUF
	ADD	HL,DE
	POP	DE

	DI
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),B
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	VDPHOOK

VDPHOOK:
	DI
	LD	HL,SPRITEBUF
	LD	DE,SPRITEATT
	LD	BC,32*4
	CALL	LDIRVM		;TODO: CHANGE TO FAST COPY
	RET

	DSEG
SPRITEBUF:	DS	32*4	;RAM SHADOW SPRITE ATTRIBUTE TABLE


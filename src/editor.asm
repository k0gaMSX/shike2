	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	EDITOR.INC

TILEMARKCOL	EQU	12

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	EDINIT
	EXTRN	SETCOLSPR,DELSPR,SPRITE

EDINIT:	CALL	CLRSPR
	LD	BC,29*256 + TOPSPR
	LD	E,TILEMARKCOL
	CALL	SETCOLSPR

	LD	BC,3*256 + TILEPAT
	LD	DE,TILEGEN
	JP	SPRITE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	TILESPRITE
	EXTRN	PUTSPRITE

TILESPRITE:
	LD	(MT.COORD),DE
	LD	A,C
	LD	(MT.ZVAL),A
	CALL	DELSPR

	LD	DE,(MT.COORD)
	LD	A,(MT.ZVAL)
	ADD	A,A
	ADD	A,A
	ADD	A,A
	NEG
	ADD	A,E
	LD	E,A
	LD	BC,TILEPAT*256 + TOPSPR
	CALL	PUTSPRITE			;PAINT THE TILE MARK

	LD	A,(MT.ZVAL)
	OR	A
	RET	Z

	LD	DE,(MT.COORD)			;WE HAVE HEIGTH, SO WE HAVE
	LD	A,E				;TO PAINT THE BOTTON PART
	SUB	8
	LD	E,A
	LD	(MT.COORD),DE
	LD	BC,BOTPAT*256 + BOTSPR
	CALL	PUTSPRITE

	LD	A,(MT.ZVAL)
	DEC	A
	RET	Z
	LD	B,A				;AND LIKE THE HEIGTH > 1
	LD	C,ZSPR				;WE HAVE TO PAINT THE MIDDLE
	LD	DE,(MT.COORD)			;PART

MT.LOOP:PUSH	BC
	PUSH	DE
	LD	B,ZPAT
	LD	A,E
	SUB	4
	LD	E,A
	CALL	PUTSPRITE
	POP	DE
	LD	A,E
	SUB	8
	LD	E,A
	POP	BC
	INC	C
	DJNZ	MT.LOOP
	RET

	DSEG
MT.COORD:	DW	0
MT.ZVAL:	DB	0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

TILEGEN:DB	003H,00CH,030H,0C0H,0C0H,030H,00CH,003H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	0C0H,030H,00CH,003H,003H,00CH,030H,0C0H
	DB	000H,000H,000H,000H,000H,000H,000H,000H


BOTGEN:	DB	000H,000H,000H,000H,080H,080H,080H,080H
	DB	080H,080H,080H,080H,0C0H,030H,00CH,003H
	DB	000H,000H,000H,000H,001H,001H,001H,001H
	DB	081H,081H,081H,081H,083H,08CH,0B0H,0C0H

ZGEN:	DB	080H,080H,080H,080H,080H,080H,080H,080H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	001H,001H,001H,001H,081H,081H,081H,081H
	DB	080H,080H,080H,080H,000H,000H,000H,000H



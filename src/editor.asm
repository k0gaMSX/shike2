	INCLUDE SHIKE2.INC
	INCLUDE BIOS.INC
	INCLUDE MAPPER.INC
	INCLUDE	KBD.INC
	INCLUDE GEOMETRY.INC

POINTERSPR	EQU	0
BLANKSPR	EQU	1*4
MAPCMDPAT	EQU	0
CUADPAT		EQU	NR_MAPCMD*4
BLANKPAT	EQU	CUADPAT+4
TILEPAT		EQU	BLANKPAT+4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	CSEG
	PUBLIC	EDITOR
	EXTRN	GRID,PATTERN,TILE,SPRITE,COLORSPRITE,DRAWREGION


EDITOR:	LD	BC,9*256 + MAPCMDPAT	;CUAD + BLANK + TILE + NR_MAPCMD
	LD	DE,ED.SPRITES
	CALL	SPRITE

	LD	BC,1*256 + POINTERSPR	;POINTER
ED.1:	PUSH	BC
	LD	B,1
	LD	DE,POINTERCOL
	CALL	COLORSPRITE
	POP	BC
	INC	C
	DJNZ	ED.1

	LD	BC,1*256 + BLANKSPR
	LD	DE,BLANKCOL
	CALL	COLORSPRITE

	LD	HL,0
	LD	(E.TILE),HL
	XOR	A
	LD	(PATTERN),A

	LD	A,TILPAGE
	LD	(ACPAGE),A
	CALL	GRID			;SHOW ISOMETRIC GRID

	LD	HL,0
	ADD	HL,SP
	LD	(EDSTACK),HL		;SAVE SP FOR CANCEL OPERATIONS

	;MAIN EDITOR LOOP
EDLOOP: CALL	VDPSYNC			;WAIT TO THE VDP
	CALL	SELTILE			;SELECT THE TILE
	CALL	SELCMD			;SELECT THE COMMAND
	CALL	SELPATTERN		;SELECT THE PATTERN
	CALL	SELREGION		;SELECT THE REGION, ONLY IN REGION MODE
	CALL	DRAWREGION		;EXECUTE CMD
	JR	EDLOOP

	DSEG
E.TILE:		DW	0
EDSTACK:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	CSEG

CANCEL:	LD	HL,(EDSTACK)		;LONGJMP TO EDITOR LOOP. CANCEL
	LD	SP,HL			;ANY OPERATION
	JR	EDLOOP

EXIT:	LD	HL,(EDSTACK)		;LONGJMP FOR EXITING OF EDITOR.
	LD	SP,HL
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	(PATTERN) = ACTUAL SELECTED PATTERN

	CSEG
	EXTRN	GETKEV,PAT2TILE,METAPAT,MARKMETAPAT,MOVEUC,KEY2DIR

SELMETAPAT:
	CALL	DELSPR
	LD	A,(PATTERN)		;TRANSFORM PATTERN NUMBER TO
	CALL	PAT2TILE
	LD	(M.TILE),DE
	LD	BC,0101H
	LD	(METAPAT),BC

M.LOOP:	CALL	MARKMETAPAT		;MARK THE META PATTERN
	CALL	VDPSYNC			;WAIT TO THE VDP
	CALL	GETKEV			;GET NEXT KEYBOARD EVENT
	PUSH	AF
	CALL	MARKMETAPAT		;ERASE META PATTERN MARK
	POP	AF
	CP	KB_SPACE
	RET	Z

	CP	KB_ESC
	CALL	Z,CANCEL

	CALL	KEY2DIR
	JR	C,M.LOOP
	LD	DE,(METAPAT)
	CALL	MOVEUC
	LD	BC,(M.TILE)

	LD	A,D			;METAPAT SIZE MUST BE BIGGER THAN
	OR	A			;1,1
	JR	Z,M.LOOP		;AND METAPAT+TILE SHOULD BE SMALLER
	ADD	A,B			;THAN NR_PATCOL,NR_PATROW
	CP	NR_PATCOL
	JR	Z,M.LOOP

	LD	A,E
	OR	A
	JR	Z,M.LOOP
	ADD	A,C
	CP	NR_PATROW
	JR	Z,M.LOOP

	LD	(METAPAT),DE
	JR	M.LOOP

	DSEG
M.TILE:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	(PATTERN) = ACTUAL SELECTED PATTERN

	CSEG
	EXTRN	GETKEV,METAPAT,DELSPR,SETPAGE,PATTERN,PUTSPRITE
	EXTRN	PAT2XY,TILE2PAT,PAT2TILE,KEY2DIR,MOVEUC,MOVISO

SELPATTERN:
	CALL	DELSPR
	LD	A,PATPAGE
	LD	(DPPAGE),A
	LD	(ACPAGE),A
	CALL	SETPAGE			;SHOW PATTERNS PAGE
	LD	DE,0101H
	LD	(METAPAT),DE

P.LOOP:	LD	A,(PATTERN)
	CALL	PAT2XY
	LD	BC,CUADPAT*256 + POINTERSPR
	CALL	PUTSPRITE		;PAINT THE PATTERN MARQUEE
	CALL	GETKEV			;WAIT A KEYBOARD EVENT

	CP	KB_ESC
	CALL	Z,CANCEL

P.SPC:	CP	KB_SPACE		;SPACE SELECT PATTERN
	JR	NZ,P.DIR
	LD	A,(MAPCMD)		;MAPXY DOESN'T ADMIT META PATTERNS
	CP	MAPXY
	CALL	NZ,SELMETAPAT
	RET

P.DIR:	CALL	KEY2DIR
	JR	C,P.LOOP

	PUSH	AF
	LD	A,(PATTERN)
	CALL	PAT2TILE
	POP	AF
	CALL	MOVEUC
	CALL	TILE2PAT
	LD	(PATTERN),A		;SAVE THE POSITION OF THE PATTERN
	JR	P.LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(ACPAGE) = PAGE WHERE WILL BE PAINTED
;		(TILE) = ACTUAL TILE

	CSEG
	EXTRN	GETKEV,PUTSPRITE,TILE2XY,MAPCMD

SELCMD:	LD	A,(MAPCMD)
	LD	E,A
C.LOOP:	LD	A,E
	LD	(MAPCMD),A
	ADD	A,A
	ADD	A,A
	LD	B,A
	LD	C,POINTERSPR
	LD	DE,(TILE)
	CALL	TILE2XY
	PUSH	DE
	CALL	PUTSPRITE		;PAINT THE CMD MARK
	POP	DE
	LD	BC,BLANKPAT*256 + BLANKSPR
	CALL	PUTSPRITE
	CALL	GETKEV
	LD	DE,(MAPCMD)

	CP	KB_SPACE		;SPACE SELECTS THE COMMAND
	RET	Z

	CP	KB_ESC
	CALL	Z,CANCEL

	CP	KB_LEFT			;LEFT DECREMENT THE COMMAND
	JR	NZ,C.RGTH
	XOR	A
	CP	E
	JR	Z,C.LOOP
	DEC	E
	JR	C.LOOP

C.RGTH:	CP	KB_RIGTH		;RIGTH INCREMENT THE COMMAND
	JR	NZ,C.LOOP
	LD	A,NR_MAPCMD-1
	CP	E
	JR	Z,C.LOOP
	INC	E
	JR	C.LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(ACPAGE) = PAGE WHERE WILL BE PAINTED
;		(TILE) = ACTUAL TILE

	CSEG
	EXTRN	GETKEV,SETPAGE,DELSPR,TILEINC,MARKREGION,VDPSYNC
	EXTRN	KEY2DIR,MOVEUC,MOVISO

SELREGION:
	CALL	DELSPR
	LD	A,TILPAGE
	LD	(ACPAGE),A
	LD	(DPPAGE),A
	CALL	SETPAGE			;SHOW WORKING PAGE
	XOR	A
	LD	(IR.MODE),A		;SET DEFAULT MODE
	LD	DE,0101H
	LD	(TILEINC),DE		;INIT TILEINC

IR.LOOP:CALL	MARKREGION		;PAINT THE RECTANGULE REGION
	CALL	VDPSYNC			;WAIT UNTIL THE END OF PAINTING
	CALL	GETKEV			;WAIT A KEYBOARD EVENT
	PUSH	AF
	CALL	MARKREGION		;DELETE PREVIOUS REGION
	POP	AF
	CP	KB_ESC
	CALL	Z,CANCEL

	LD	HL,IR.MODE
IR.SHF:	CP	KB_SHIFT		;SHIFT CHANGES THE MODE(PRESS/RELEASE)
	JR	NZ,IR.USHF		;MOVE (TILE) WITH ISOMETRIC GEOMETRY
	SET	0,(HL)
	JR	IR.LOOP

IR.USHF:CP	128+KB_SHIFT
	JR	NZ,IR.CTR
	RES	0,(HL)
	JR	IR.LOOP

IR.CTR:	CP	KB_CRTL			;CONTROL CHANGES THE MODE(PRESS/RELEASE)
	JR	NZ,IR.UCTR		;MOVE (TILE) WITH EUCLIDEAN GEOMETRY
	SET	1,(HL)
	JR	IR.LOOP

IR.UCTR:CP	128+KB_CRTL
	JR	NZ,IR.SPC
	RES	1,(HL)
	JR	IR.LOOP

IR.SPC:	CP	KB_SPACE		;SPACE SELECTS THE REGION
	RET	Z

	CALL	KEY2DIR
	JR	C,IR.LOOP

	LD	DE,(TILE)
	BIT	0,(HL)
	JR	NZ,IR.ISO
	BIT	1,(HL)
	JR	NZ,IR.EUC

	LD	DE,(TILEINC)
	CALL	MOVEUC
	LD	A,E			;SIZE OF REGIONS MUST BE BIGGER
	OR	A			;THAN 1,1
	JR	Z,IR.LOOP
	LD	A,D
	OR	A
	JR	Z,IR.LOOP
	LD	(TILEINC),DE
	JR	IR.LOOP

IR.ISO:	CALL	MOVISO
	JR	IR.TILE

IR.EUC:	CALL	MOVEUC

IR.TILE:LD	(TILE),DE
	JR	IR.LOOP


	DSEG
IR.MODE:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(TILE) = ACTUAL TILE SELECTED

	CSEG
	EXTRN	GETKEV,DELSPR,SETPAGE,TILE,TILE2XY,PUTSPRITE
	EXTRN	KEY2DIR,MOVISO,MOVEUC

SELTILE:
	LD	DE,(E.TILE)		;RESTORE SAVED TILE
	LD	(TILE),DE
	CALL	DELSPR
	LD	A,TILPAGE
	LD	(ACPAGE),A
	LD	(DPPAGE),A
	CALL	SETPAGE			;SHOW WORKING PAGE

T.LOOP:	LD	DE,(TILE)
	LD	B,TILEPAT
	LD	C,POINTERSPR
	CALL	TILE2XY
	CALL	PUTSPRITE		;PAINT THE TILE MARK
	CALL	GETKEV			;WAIT NEXT KEYBOARD EVENT
	CP	KB_ESC
	CALL	Z,EXIT

T.SHFT:	CP	KB_SHIFT		;SHIFT SELECT ISOMETRIC MOVEMENT
	JR	NZ,T.USHFT
	LD	A,1
	JR	T.SETM

T.USHFT:CP	KB_SHIFT + 128		;UNSHIFT SELECT ISOMETRIC MOVEMENT
	JR	NZ,T.SPACE
	XOR	A

T.SETM:	LD	(T.MODE),A
	JR	T.LOOP


T.SPACE:LD	DE,(TILE)
	CP	KB_SPACE		;SPACE = SELECT THE TILE
	JR	NZ,T.MOVE
	LD	(E.TILE),DE		;SAVE TILE SELECTED BY THE USER
	RET

T.MOVE:	CALL	KEY2DIR
	JR	C,T.LOOP

	LD	HL,T.MODE
	BIT	0,(HL)
	JR	NZ,T.ISO

	CALL	MOVEUC
	JR	T.TEST

T.ISO:	CALL	MOVISO

T.TEST:	LD	A,D
	CP	NR_SCRCOL
	JR	Z,T.LOOP
	CP	-1
	JR	Z,T.LOOP

	LD	A,E
	CP	NR_SCRROW
	JR	Z,T.LOOP
	CP	-1
	JR	Z,T.LOOP

	LD	(TILE),DE
	JR	T.LOOP

	DSEG
T.MODE:	DB	0

	CSEG

ED.SPRITES:
MAPXYGEN:
	DB	001H,002H,004H,008H,008H,004H,002H,001H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	080H,040H,020H,010H,010H,020H,040H,080H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

MAPXZGEN:
	DB	000H,000H,003H,00CH,008H,008H,00BH,00CH
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	030H,0D0H,010H,010H,030H,0C0H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
MAPYZGEN:
	DB	00CH,00BH,008H,008H,00CH,003H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,0C0H,030H,010H,010H,0D0H,030H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

MAPXZGEN_:
	DB	000H,000H,003H,00FH,00FH,00FH,00FH,00CH
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	030H,0F0H,0F0H,0F0H,0F0H,0C0H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

MAPYZGEN_:
	DB	00CH,00FH,00FH,00FH,00FH,003H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,0C0H,0F0H,0F0H,0F0H,0F0H,030H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

MAPTILEGEN:
	DB	00FH,008H,008H,008H,008H,008H,008H,00FH
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	0F0H,010H,010H,010H,010H,010H,010H,0F0H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

CUADGEN:
	DB	0FFH,080H,080H,080H,080H,080H,080H,0FFH
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	0FFH,001H,001H,001H,001H,001H,001H,0FFH
	DB	000H,000H,000H,000H,000H,000H,000H,000H

BLANKGEN:
	DB	0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH
	DB	000H,000H,000H,000H,000H,000H,000H,000H

TILEGEN:
	DB	003H,00CH,030H,0C0H,0C0H,030H,00CH,003H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	0C0H,030H,00CH,003H,003H,00CH,030H,0C0H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

POINTERCOL:
	DB	0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH
	DB	0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH

BLANKCOL:
	DB	0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH
	DB	0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH


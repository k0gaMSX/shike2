	INCLUDE SHIKE2.INC
	INCLUDE BIOS.INC
	INCLUDE MAPPER.INC
	INCLUDE	KBD.INC
	INCLUDE GEOMETRY.INC


MAPSIZ		EQU	200

PATSPR		EQU	0
CMDSPR		EQU	0
TOPSPR		EQU	0
BOTSPR		EQU	1
ZSPR		EQU	2
BLANKSPR	EQU	31

MAPCMDPAT	EQU	0
CUADPAT		EQU	NR_MAPCMD*4
BLANKPAT	EQU	CUADPAT+4
TILEPAT		EQU	BLANKPAT+4
BOTPAT		EQU	TILEPAT+4
ZPAT		EQU	BOTPAT+4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	CSEG
	PUBLIC	EDITOR
	EXTRN	GRID,PATTERN,DRAWREGION,RESETMAP,VDPSYNC

EDITOR:	LD	DE,MAPBUF
	CALL	NEWMAP

	CALL	INITSPRITES
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
	CALL	ADDCMD			;ADD THE COMMAND TO THE MAP BUFFER
	JR	EDLOOP

	DSEG
E.TILE:		DW	0
EDSTACK:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	SPRITE,COLORSPRITE,DELSPR,SPR8X8

INITSPRITES:
	CALL	DELSPR
	LD	BC,11*256 + MAPCMDPAT	;CUAD+BLANK+TILE+BOT+Z+NR_MAPCMD
	LD	DE,ED.SPRITES
	CALL	SPRITE

	LD	BC,31*256 + PATSPR	;ALL THE SPRITES EXCEPT THE LAST
IS.LOOP:PUSH	BC
	LD	B,1
	LD	DE,POINTERCOL
	CALL	COLORSPRITE
	POP	BC
	INC	C
	DJNZ	IS.LOOP

	LD	BC,1*256 + BLANKSPR	;AND NOW THE LAST
	LD	DE,BLANKCOL
	JP	COLORSPRITE


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

	LD	A,(MAPCMD)		;WE ONLY ACCEPT WIDTH METAPAT IN 
	CP	MAPTILE			;MAPTILE COMMAND
	JR	Z,M.1
	LD	D,1

M.1:	LD	A,D			;METAPAT SIZE MUST BE BIGGER THAN
	OR	A			;1,1
	JR	Z,M.LOOP		;AND METAPAT+TILE SHOULD BE SMALLER
	ADD	A,B			;THAN NR_PATCOL,NR_PATROW
	CP	NR_PATCOL
	JR	Z,M.LOOP

	LD	A,E			;CHECK LIMITS
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
	EXTRN	GETKEV,METAPAT,DELSPR,SETPAGE,PATTERN
	EXTRN	TILE2PAT,PAT2XY,PAT2TILE,KEY2DIR,MOVEUC

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
	LD	BC,CUADPAT*256 + PATSPR
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
	EXTRN	GETKEV,PUTSPRITE,TILE2XY,MAPCMD,ZTILE

SELCMD:	LD	A,(MAPCMD)
	ADD	A,A
	ADD	A,A
	LD	B,A
	LD	C,CMDSPR
	CALL	ZTILE
	CALL	TILE2XY
	PUSH	DE
	CALL	PUTSPRITE		;PAINT THE CMD MARK
	POP	DE
	LD	BC,BLANKPAT*256 + BLANKSPR
	CALL	PUTSPRITE		;PAINT THE BLANK SPRITE
	CALL	GETKEV

	CP	KB_SPACE		;SPACE SELECTS THE COMMAND
	RET	Z

	CP	KB_ESC
	CALL	Z,CANCEL

	LD	DE,(MAPCMD-1)
	CALL	KEY2DIR
	JR	C,SELCMD
	CALL	MOVEUC
	LD	A,D			;CHECK LIMITS
	CP	-1
	JR	Z,SELCMD
	CP	NR_MAPCMD
	JR	Z,SELCMD
	LD	(MAPCMD),A
	JR	SELCMD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(ACPAGE) = PAGE WHERE WILL BE PAINTED
;		(TILE) = ACTUAL TILE

	CSEG
	EXTRN	GETKEV,SETPAGE,DELSPR,TILEINC,MARKREGION,VDPSYNC
	EXTRN	KEY2DIR,MOVEUC,MOVISO,SWTCH

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

IR.LOOP:CALL	MARKTILE		;SHOW THE TILE SELECTION
	CALL	MARKREGION		;PAINT THE RECTANGULE REGION
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
	EXX
	EX	AF,AF'
	LD	HL,IR.JUMP
	LD	A,(MAPCMD)		;SELECT THE CORRECT POSITION
	CALL	SWTCH			;IN THE JUMP TABLE
	LD	A,E			;SIZE OF REGIONS MUST BE BIGGER
	OR	A			;THAN 1,1
	JR	Z,IR.LOOP
	LD	A,D
	OR	A
	JR	Z,IR.LOOP
	LD	(TILEINC),DE
	JR	IR.LOOP

;;;;;;;; TILE MOVEMENT PART ;;;;;;;;;;;

IR.ISO:	CALL	MOVISO
	JR	IR.TILE

IR.EUC:	CALL	MOVEUC

IR.TILE:LD	(TILE),DE
	JR	IR.LOOP

	EXTRN	MOVEUC,MOVIEUC,MOVIYEUC

	;MOVEUC => NORMAL EUCLIDEAN MOVEMENT
	;MOVIEUC => INVERSE EUCLIDEAN MOVEMENT
	;MOVIYEUC => INVERSE Y EUCLIDEAN MOVEMENT

IR.JUMP:	DW	MOVEUC,MOVIEUC,MOVIYEUC,MOVIEUC,MOVIYEUC,MOVIEUC

	DSEG
IR.MODE:	DB	0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	ZTILE,PUTSPRITE,DELSPR,TILE2XY,ZVALUE

MARKTILE:
	CALL	DELSPR
	CALL	ZTILE
	LD	BC,TILEPAT*256 + TOPSPR
	CALL	TILE2XY
	CALL	PUTSPRITE			;PAINT THE TILE MARK

	LD	A,(ZVALUE)
	OR	A
	RET	Z

	LD	DE,(TILE)			;WE HAVE HEIGTH, SO WE HAVE
	DEC	E				;TO PAINT THE BOTTON PART
	LD	BC,BOTPAT*256 + BOTSPR
	CALL	TILE2XY
	CALL	PUTSPRITE

	LD	A,(ZVALUE)
	DEC	A
	RET	Z
	LD	B,A				;AND LIKE THE HEIGTH > 1
	LD	C,ZSPR				;WE HAVE TO PAINT THE MIDDLE
	LD	DE,(TILE)			;PART
	DEC	E

MT.LOOP:PUSH	BC
	PUSH	DE
	LD	B,ZPAT
	CALL	TILE2XY
	LD	A,E
	SUB	4
	LD	E,A
	CALL	PUTSPRITE
	POP	DE
	DEC	E
	POP	BC
	INC	C
	DJNZ	MT.LOOP

	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	MOVIEUC,ZVALUE,GETKEV,KEY2DIR,MOVEUC


SELZVAL:CALL	MARKTILE
	CALL	GETKEV			;WAIT NEXT KEYBOARD EVENT
	CP	KB_CRTL + 128		;EXIT OF ZMODE RELEASING THE CRTL
	RET	Z

	CALL	KEY2DIR
	JR	C,SELZVAL
	LD	DE,(ZVALUE)
	CALL	MOVIEUC			;INVERSE EUCLIDEAN MOVEMENT
	LD	A,E
	CP	-1
	JR	Z,SELZVAL		;CHECK LIMITS
	CP	NR_SCRROW
	JR	Z,SELZVAL
	LD	(ZVALUE),A
	JR	SELZVAL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = ADDRESS WHERE NEXT MAP WILL BE STORED

	CSEG
	EXTRN	CLRVPAGE,RESETMAP

NEWMAP:	EX	DE,HL
	LD	(CMDBUF),HL
	LD	(HL),0
	INC	HL
	LD	(CMDPTR),HL
	CALL	RESETMAP
	LD	E,TILPAGE
	JP	CLRVPAGE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	(CMDBUF) = POINTER TO THE BUFFER WHERE IS STORED THE MAP
;	(CMDPTR) = ACTUAL POSITION INTO CMDPTR
;	(ZVALUE)
;	(MAPCMD)
;	(TILE)
;	(PATTERN)
;	(TILEINC)
;	(METAPAT)

	CSEG
	EXTRN	CRUNCH,DRAWREGION

ADDCMD:	LD	DE,(CMDBUF)
	LD	HL,MAPSIZ
	ADD	HL,DE
	EX	DE,HL
	LD	HL,(CMDPTR)
	LD	BC,8
	ADD	HL,BC
	EX	DE,HL

	OR	A
	SBC	HL,DE		;TODO: HANDLE ERROR CASE
	RET	C		;NOT ENOUGH SPACE FOR A NEW COMMAND

	LD	HL,(CMDBUF)	;INCREMENT NUMBER OF COMMANDS
	INC	(HL)
	LD	DE,(CMDPTR)	;CRUNCH MAP VALUES
	CALL	CRUNCH
	LD	(CMDPTR),HL	;STORE ACTUAL COMMAND POINTER
	JP	DRAWREGION	;DRAW THE REGION


	DSEG
CMDPTR:	DW	0
CMDBUF:	DW	0

	PUBLIC	MAPBUF
MAPBUF:	DS	MAPSIZ

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(TILE) = ACTUAL TILE SELECTED

	CSEG
	EXTRN	GETKEV,DELSPR,SETPAGE,TILE,KEY2DIR,MOVISO,MOVEUC

SELTILE:LD	DE,(E.TILE)		;RESTORE SAVED TILE
	LD	(TILE),DE
	CALL	DELSPR
	LD	A,TILPAGE
	LD	(ACPAGE),A
	LD	(DPPAGE),A
	CALL	SETPAGE			;SHOW WORKING PAGE

T.LOOP:	CALL	MARKTILE
	CALL	GETKEV			;WAIT NEXT KEYBOARD EVENT
	CP	KB_ESC
	CALL	Z,EXIT

	CP	KB_CRTL
	CALL	Z,SELZVAL

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

MAPYZGEN:
	DB	00CH,00BH,008H,008H,00CH,003H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,0C0H,030H,010H,010H,0D0H,030H
	DB	000H,000H,000H,000H,000H,000H,000H,000H


MAPXZGEN:
	DB	000H,000H,003H,00CH,008H,008H,00BH,00CH
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	030H,0D0H,010H,010H,030H,0C0H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

MAPYZGEN_:
	DB	00CH,00FH,00FH,00FH,00FH,003H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,0C0H,0F0H,0F0H,0F0H,0F0H,030H
	DB	000H,000H,000H,000H,000H,000H,000H,000H


MAPXZGEN_:
	DB	000H,000H,003H,00FH,00FH,00FH,00FH,00CH
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	030H,0F0H,0F0H,0F0H,0F0H,0C0H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H


MAPTILEGEN:
	DB	00FH,008H,008H,008H,008H,008H,008H,00FH
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	0F0H,010H,010H,010H,010H,010H,010H,0F0H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

TILEGEN:DB	0FFH,080H,080H,080H,080H,080H,080H,0FFH
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	0FFH,001H,001H,001H,001H,001H,001H,0FFH
	DB	000H,000H,000H,000H,000H,000H,000H,000H

BLANKGEN:
	DB	0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH
	DB	000H,000H,000H,000H,000H,000H,000H,000H

CUADGEN:DB	003H,00CH,030H,0C0H,0C0H,030H,00CH,003H
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


POINTERCOL:
	DB	0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH
	DB	0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH

BLANKCOL:
	DB	0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH
	DB	0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH


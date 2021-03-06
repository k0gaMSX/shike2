

	INCLUDE	LEVEL.INC
	INCLUDE	DATA.INC

DOORPAT	EQU	4*4*3


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	DOORINIT
	EXTRN	PUTLPAGE,DOORSDAT

DOORINIT:
	PUSH	IX
	CALL	PUTLPAGE
	LD	HL,DOORSDAT
	LD	B,NR_DOORS
	LD	IX,DOORBUF

D.LOOP:	PUSH	BC			;INITIALIZE ALL THE DOORS IN THE
	PUSH	HL			;GAME
	LD	E,L
	LD	D,H
	LD	BC,SIZPOINT
	ADD	HL,BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	A,(HL)
	CALL	DOOR
	POP	HL
	LD	DE,SIZDINFO
	ADD	HL,DE
	LD	DE,SIZDOOR
	ADD	IX,DE
	POP	BC
	DJNZ	D.LOOP

	POP	IX
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE DOOR
;	DE = POINTER TO INITIAL POINT
;	C = DOOR TYPE
;	B = DOOR KEY
;	A = INITIAL STATE


	CSEG
	EXTRN	MOB

DOOR:	LD	(IX+DOOR.TYPE),C
	LD	(IX+DOOR.KEY),B
	LD	(IX+DOOR.OPEN),A
	LD	C,IXL
	LD	B,IXU
	LD	HL,DOOR.POINT
	ADD	HL,BC
	EX	DE,HL
	LD	BC,SIZPOINT
	LDIR
	PUSH	IX
	CALL	MOB
	LD	DE,SIZMOB
	ADD	IX,DE
	CALL	MOB
	POP	IX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: E = DOOR NUMBER

	CSEG
	PUBLIC	GETNDOOR
	EXTRN	MULTEA

GETNDOOR:
	LD	A,SIZDOOR
	CALL	MULTEA
	LD	DE,DOORBUF
	ADD	HL,DE
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE DOOR
;	DE = POINTER TO THE RINFO

	CSEG
	PUBLIC	CLOSE,OPEN
	EXTRN	MULTEA,ARYDE,WRLD2SCR

OPEN:	LD	(IX+DOOR.OPEN),1
	LD	A,(IX+DOOR.Z)
	JR	C.AUX

CLOSE:	LD	(IX+DOOR.OPEN),0
	LD	A,(IX+DOOR.Z)
	ADD	A,4

C.AUX:	LD	(C.ZVAL),A
	PUSH	DE
	PUSH	DE
	POP	IY
	LD	E,(IY+RINFO.XR)
	LD	D,(IY+RINFO.XR+1)
	LD	C,(IY+RINFO.YR)
	LD	B,(IY+RINFO.YR+1)
	LD	L,(IX+DOOR.Y)
	LD	H,(IX+DOOR.X)
	LD	A,(IX+DOOR.Z)
	CALL	WRLD2SCR
	CALL	DRAW

	LD	E,(IX+DOOR.Y)
	LD	A,MAPYSIZ
	CALL	MULTEA			;HL = Y HEIGHT OFFSET
	LD	E,(IX+DOOR.X)
	LD	D,0
	ADD	HL,DE			;HL = HEIGHT OFFSET
	POP	DE
	ADD	HL,DE			;HL = HEIGHT OFFSET + RINFO
	LD	DE,RINFO.HMATRIX
	ADD	HL,DE			;HL = HEIGHT POINTER
	LD	A,(C.ZVAL)
	PUSH	AF
	LD	(HL),A			;MARK FIRST POSITION
	LD	A,(IX+DOOR.TYPE)
	LD	DE,C.INCS
	CALL	ARYDE
	ADD	HL,DE
	POP	AF
	LD	(HL),A			;MARK SECOND POSITION
	RET

C.INCS:	DW	-MAPYSIZ,1

	DSEG
C.ZVAL:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	SHOWDOORS
	EXTRN	GETRINFO

SHOWDOORS:
	PUSH	IX
	LD	B,NR_DOORS
	LD	IX,DOORBUF

S.LOOP:	PUSH	BC
	LD	E,(IX+DOOR.LEVEL)
	LD	D,(IX+DOOR.LEVEL+1)
	LD	C,(IX+DOOR.ROOM)
	LD	B,(IX+DOOR.ROOM+1)
	CALL	GETRINFO		;TAKE THE INFORMATION OF THE
	EX	DE,HL			;ROOM DISPLAYED
	CALL	NZ,S.STATE
	LD	DE,SIZDOOR
	ADD	IX,DE
	POP	BC
	DJNZ	S.LOOP
	POP	IX
	RET


S.STATE:LD	A,(IX+DOOR.OPEN)
	OR	A
	JP	Z,CLOSE
	JP	OPEN


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE DOOR
;	HL = X COORDENATE
;	DE = Y COORDENATE

	CSEG
	EXTRN	PUTMOB,ARYDE

DRAW:	PUSH	IX
	LD	A,(IX+DOOR.OPEN)	;PAT = OPEN*4 + TYPE*2 + DOORPAT
	ADD	A,A
	ADD	A,A
	LD	B,A
	LD	A,(IX+DOOR.TYPE)
	ADD	A,A
	ADD	A,DOORPAT
	ADD	A,B
	LD	B,A
	LD	A,(IX+DOOR.Z)
	PUSH	BC
	PUSH	AF
	PUSH	HL
	PUSH	DE
	CALL	PUTMOB			;DRAW FIRST MOB

	LD	A,(IX+DOOR.TYPE)
	LD	DE,SIZMOB		;POINT TO SECOND MOB
	ADD	IX,DE

	LD	DE,D.INCS
	CALL	ARYDE			;TAKES Y INCREMENT

	POP	HL
	ADD	HL,DE
	EX	DE,HL			;DE = Y POSITION

	POP	HL
	LD	BC,16
	ADD	HL,BC			;HL = X POSITION
	POP	AF
	POP	BC
	INC	B			;INCREMENT PATTERN
	CALL	PUTMOB			;DRAW SECOND MOB
	POP	IX
	RET

D.INCS:	DW	-5,5

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
DOORBUF:DS	NR_DOORS*SIZDOOR


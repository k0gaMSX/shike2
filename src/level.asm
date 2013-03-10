
	INCLUDE	SHIKE2.INC
	INCLUDE	EDITOR.INC
	INCLUDE	GEOMETRY.INC

LEFT.P1X	EQU	CENTRAL.P1X-80H
LEFT.P1Y	EQU	CENTRAL.P1Y-40H

RIGTH.P1X	EQU	CENTRAL.P1X+80H
RIGTH.P1Y	EQU	CENTRAL.P1Y+40H

UP.P1X		EQU	CENTRAL.P1X+80H
UP.P1Y		EQU	CENTRAL.P1Y-40H

DOWN.P1X	EQU	CENTRAL.P1X-80H
DOWN.P1Y	EQU	CENTRAL.P1Y+40H

LUP.P1X		EQU	CENTRAL.P1X
LUP.P1Y		EQU	CENTRAL.P1Y-80H

RDOWN.P1X	EQU	CENTRAL.P1X
RDOWN.P1Y	EQU	CENTRAL.P1Y+80H


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	LEVELINIT

LEVELINIT:
	LD	A,-1			;IN THE BEGINNING WE ARE NOT
	LD	(LEVEL),A		;DISPLAYING ANY ROOM
	LD	L,A
	LD	H,A
	LD	(ROOM),HL
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = LOCATION OF THE MAP IN THE LEVEL
;OUTPUT:HL = ADRESS OF THE ROOM IN THE LEVEL

	CSEG
	PUBLIC	ROOMADDR
	EXTRN	MULTEA

ROOMADDR:
	PUSH	DE
	LD	D,0
	LD	A,(LVLYSIZ)
	CALL	MULTEA
	POP	DE			;HL = Y*LVLYSIZ
	LD	E,D
	LD	D,0
	ADD	HL,DE			;HL = Y*LVLYSIZ + X
	LD	DE,LVLROOM
	ADD	HL,DE			;HL = LVLROOM + Y*LVLYSIZ + X
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = LOCATION OF THE MAP IN THE LEVEL
;OUTPUT:A = ACCESS BYTE

	CSEG
	PUBLIC	GETACC

GETACC:	CALL	ACCADDR
	LD	A,(HL)
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = LOCATION OF THE MAP IN THE LEVEL
;OUTPUT:HL = ADRESS OF THE ACCESS BYTE

	CSEG
	PUBLIC	ACCADDR

ACCADDR:CALL	ROOMADDR
	LD	DE,LVLACC-LVLROOM	;ROOM MATRIX AND ACCESS MATRIX
	ADD	HL,DE			;HAVE THE SAME SIZE AND THEY
	RET				;ARE CONTIGUOUS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = POSIITON OF THE ROOM
;OUTPUT:A = ROOM NUMBER

	CSEG
	PUBLIC	GETROOM

GETROOM:LD	A,-1			;ROOM = -1,-1 IS MARK OF INVALID ROOM
	CP	D
	JR	NZ,G.1
	CP	E
	JR	NZ,G.1
	LD	A,-1
	JR	G.RET

G.1:	CALL	ROOMADDR
	LD	A,(HL)
G.RET:	CP	-1
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = POSITION OF ROOM
;OUTPUT:HL = ADRESS OF ROOM MAP

	CSEG
	PUBLIC	ROOM2MAP
	EXTRN	MULTDEA

ROOM2MAP:
	CALL	GETROOM
	LD	HL,0
	RET	Z
	LD	DE,MAPSIZ
	CALL	MULTDEA				;HL = ROOM*MAPSIZ
	LD	DE,LVLMAP
	ADD	HL,DE				;HL = ROOM*MAPSIZ+LVLMAP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = POSITION OF ROOM
;OUTPUT:HL = ADDRESS OF ROOM HEIGTH

	CSEG
	PUBLIC	ROOM2HGT
	EXTRN	MULTDEA

ROOM2HGT:
	CALL	GETROOM
	LD	HL,0
	RET	Z
	LD	DE,HEIGTHSIZ
	CALL	MULTDEA				;HL = ROOM*HEIGTHSIZ
	LD	DE,LVLHGT
	ADD	HL,DE				;HL = ROOM*HEIGTHSIZ+LVLHGT
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: A = NUMBER OF LEVEL


	CSEG
	PUBLIC	PUTLEVEL

PUTLEVEL:
	ADD	A,7
	OUT	(0FEH),A
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = ROOM LOCATION
;	B = LEVEL
;OUTPUT:HL = ROOM DATA WHEN IT IS VISIBLE, 0 IN OTHER CASE

	CSEG
	PUBLIC	ROOMINFO
	EXTRN	ADDAHL

ROOMINFO:
	LD	A,(LEVEL)
	CP	B
	JR	NZ,G.NOK		;DIFFERENT LEVEL, SO NO HEIGTH

	CALL	LOOKUP			;IS IT THE SCREEN ONE OF VISIBLES?
	JR	Z,G.NOK
	ADD	A,A			;A=INDEX*2
	PUSH	AF
	ADD	A,A			;A=INDEX*4
	POP	HL
	ADD	A,H			;A=INDEX*4+INDEX*2
	LD	HL,G.DATA
	CALL	ADDAHL			;HL=G.DATA+INDEX*4+INDEX*2
	RET

G.NOK:	LD	HL,0
	RET


G.DATA:	DW	HGT.IN,CENTRAL.P1X,CENTRAL.P1Y
	DW	HGT.LEFT,LEFT.P1X,LEFT.P1Y
	DW	HGT.RIGTH,RIGTH.P1X,RIGTH.P1Y
	DW	HGT.UP,UP.P1X,UP.P1Y
	DW	HGT.DOWN,DOWN.P1X,DOWN.P1Y
	DW	HGT.LUP,LUP.P1X,LUP.P1Y
	DW	HGT.RDOWN,RDOWN.P1X,RDOWN.P1Y



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = ROOM POSITION
;OUTPUT:A = POSITION INTO THE ARRAY, OR -1 WHEN IT IS NOT FOUND
;	Z = 1 WHEN ROOM IS NOT DISPLAYED

	CSEG

LOOKUP:	LD	HL,ROOM.IN
	LD	BC,16

L.LOOP:	LD	A,E			;LOOK THE LOWER BYTE
	OR	80H			;(BIT 7 = 1 HELP SEARCHING)
	CPIR
	JR	NZ,L.NOT
	LD	A,D
	CPI				;AND NOW LOOK THE UPPER BYTE
	JR	Z,L.FOUND
	JP	PO,L.NOT
	JR	L.LOOP

L.FOUND:DEC	HL
	DEC	HL
	LD	DE,ROOM.IN
	OR	A
	SBC	HL,DE
	LD	A,L
	RRCA				;A = (HL - ROOM.IN) / 2
	CP	-1
	RET

L.NOT:	LD	A,-1
	CP	-1
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = ROOM LOCATION
;OUTPUT:DE = INPUT PARAMETER WHEN CORRECT, OR -1 IF INCORRECT

	CSEG

CHKROOM:LD	A,-1			;CHECK IF THE ROOM LOCATION IS CORRECT
	CP	D
	JR	Z,C.WRONG
	CP	E
	JR	Z,C.WRONG
	LD	A,(LVLYSIZ)
	CP	E
	JR	Z,C.WRONG
	LD	A,(LVLXSIZ)
	CP	D
	JR	Z,C.WRONG
	SET	7,E			;MARK IT LIKE LOWER BYTE
	RET

C.WRONG:LD	DE,-1
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	(ROOM) = ROOM LOCATION OF CENTRAL ROOM
;OUTPUT:ROOM.IN,ROOM.LEFT,ROOM.RIGTH,ROOM.UP,ROOM.DOWN,ROOM.LUP,ROOM.RDOWN,

	CSEG

GETVISIBLES:				;CALCULATE COORDENATES OF VISIBLES ROOMS
	LD	DE,(ROOM)
	LD	B,6
	LD	IY,V.DATA
	LD	IX,ROOM.IN

G.LOOP:	LD	L,(IY+0)		;TAKE THE INCREMENT
	LD	H,(IY+1)

	LD	A,E
	ADD	A,L
	LD	L,A
	LD	A,D
	ADD	A,H
	LD	H,A

	EX	DE,HL			;DE = NEW ROOM
	CALL	CHKROOM			;IS IT CORRECT?
	LD	(IX+0),E
	LD	(IX+1),D		;STORE THE RESULT IN ROOM VARIABLES
	LD	DE,2
	ADD	IX,DE
	ADD	IY,DE			;NEXT ITERATION
	EX	DE,HL
	DJNZ	G.LOOP
	RET

V.DATA:	DW	00000H,0FF00H,00100H,000FFH,00001H,0FFFFH,00101H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = LEVEL
;	DE = ROOM LOCATION

	CSEG
	PUBLIC	MOVECAMARA
	EXTRN	HMATRIX,PTRDE,MAP

MOVECAMARA:
	PUSH	IX
	LD	(LEVEL),A
	LD	(ROOM),DE
	CALL	PUTLEVEL
	CALL	ROOM2MAP
	EX	DE,HL			;DE = MAP ADDRESS
	CALL	MAP			;MAP THE ROOM

	CALL	GETVISIBLES		;CALCULATE VISIBLES ROOMS

	LD	DE,HGT.IN
	LD	(H.PTR),DE
	LD	B,6
	LD	DE,ROOM.IN

M.LOOP:	PUSH	BC			;GET THE HEIGTH MATRIX FOR EACH
	PUSH	DE			;VISIBLE ROOM
	CALL	PTRDE
	RES	7,E
	CALL	ROOM2HGT
	EX	DE,HL
	LD	BC,(H.PTR)
	CALL	HMATRIX

	LD	HL,(H.PTR)
	LD	DE,HEIGTHMATRIXSIZ
	ADD	HL,DE
	LD	(H.PTR),HL
	POP	DE
	INC	DE
	POP	BC
	DJNZ	M.LOOP
	POP	IX
	RET


	DSEG
H.PTR:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG


LEVEL:		DB	0
ROOM:		DW	0

HGT.IN:		DS	HEIGTHMATRIXSIZ
HGT.LEFT:	DS	HEIGTHMATRIXSIZ
HGT.RIGTH:	DS	HEIGTHMATRIXSIZ
HGT.UP:		DS	HEIGTHMATRIXSIZ
HGT.DOWN:	DS	HEIGTHMATRIXSIZ
HGT.LUP:	DS	HEIGTHMATRIXSIZ
HGT.RDOWN:	DS	HEIGTHMATRIXSIZ


ROOM.IN:	DW	0
ROOM.LEFT:	DW	0
ROOM.RIGTH:	DW	0
ROOM.UP:	DW	0
ROOM.DOWN:	DW	0
ROOM.LUP:	DW	0
ROOM.RDOWN:	DW	0


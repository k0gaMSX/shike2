

	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	LEVEL.INC
	INCLUDE	DATA.INC


NR_RINFO	EQU	7		;4 DIRECTIONS,2 DIAGONALS AND CENTER
P1X		EQU	CENTRAL.P1X*16
P1Y		EQU	CENTRAL.P1Y*8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INCLUDE	LEVELDEF.INC
	PUBLIC	CHARSDAT,DOORSDAT,FONTGR5,LEVELDEF,MAPDEF,PALETES,CAMDAT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

	PUBLIC	LEVELINIT

LEVELINIT:
	LD	HL,-1
	LD	(LEVEL),HL		;IN THE BEGINNING WE ARE NOT IN ANY
	LD	(ROOM),HL		;ROOM

	LD	HL,0
	ADD	HL,SP
	LD	(I.STACK),HL
	LD	SP,I.RINFO
	LD	A,-1
	LD	B,NR_RINFO
	LD	IY,RINFO
	LD	DE,SIZRINFO		;INITIALIZE STATIC FIELDS IN RINFO

I.LOOP:	EXX
	POP	HL			;HL = X RENDER
	POP	DE			;DE = Y RENDER
	POP	BC			;BC = ROOM INCREMENT
	LD	(IY+RINFO.XR),L
	LD	(IY+RINFO.XR+1),H
	LD	(IY+RINFO.YR),E
	LD	(IY+RINFO.YR+1),D
	LD	(IY+RINFO.INC),C
	LD	(IY+RINFO.INC+1),B
	LD	(IY+RINFO.ROOM),A	;THIS RINFO IS NOT RENDERING ANY
	LD	(IY+RINFO.ROOM+1),A	;ROOM YET
	EXX
	ADD	IY,DE
	DJNZ	I.LOOP
	LD	HL,(I.STACK)
	LD	SP,HL
	RET

I.RINFO:DW	P1X    ,P1Y    ,00000H	;CENTRAL
	DW	P1X-80H,P1Y-40H,0FF00H	;LEFT
	DW	P1X+80H,P1Y+40H,00100H	;RIGTH
	DW	P1X+80H,P1Y-40H,000FFH	;UP
	DW	P1X-80H,P1Y+40H,00001H	;DOWN
	DW	P1X    ,P1Y-80H,0FFFFH	;LEFT UP
	DW	P1X    ,P1Y+80H,00101H	;RIGTH DOWN

I.REND:

	DSEG
I.STACK:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	PUTLPAGE
	EXTRN	CARTPAGE

PUTLPAGE:
	LD	E,LEVELPAGE
	JP	CARTPAGE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = LEVEL COORDENATES
;	BC = ROOM COORDENATES
;OUTPUT:HL = ROOM DATA WHEN IT IS VISIBLE, 0 IN OTHER CASE
;	Z = 1 WHEN IT IS NOT VISIBLE

	CSEG
	PUBLIC	GETRINFO
	EXTRN	ADDAHL

GETRINFO:
	LD	HL,(LEVEL)
	CALL	DCOMPR
	JR	NZ,G.NOK		;DIFFERENT LEVEL, SO NO RINFO

	LD	IY,RINFO
	LD	E,C
	LD	D,B
	LD	B,NR_RINFO

R.LOOP:	LD	A,E			;IS IT THE SAME ROOM?
	CP	(IY+RINFO.ROOM)
	JR	NZ,R.NEXT
	LD	A,D
	CP	(IY+RINFO.ROOM+1)
	JR	NZ,R.NEXT
	PUSH	IY			;OK, RETURN IT
	POP	HL
	OR	1			;SET Z=0
	RET

R.NEXT:	EXX
	LD	DE,SIZRINFO
	ADD	IY,DE
	EXX
	DJNZ	R.LOOP

G.NOK:	LD	HL,0			;I'M SORRY, YOU ARE NOT SHOWED
	CP	A			;SET Z=1
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;INPUT:	E = PALETE NUMBER
;OUTPUT:HL = PALETE DATA

	CSEG
	PUBLIC	GETPAL

GETPAL:	EX	DE,HL
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	DE,PALETES
	ADD	HL,DE
	JP	PUTLPAGE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = LEVEL NUMBER

	CSEG
	PUBLIC	LDLEVEL
	EXTRN	SETPAL,GETLEVEL

LDLEVEL:CALL	GETLEVEL		;GET THE LEVEL DEFINITION STRUCTURE
	RET	Z
	PUSH	HL
	PUSH	HL

	POP	IY
	LD	E,(IY+LVL.PAL)		;SET THE LEVEL PALETE
	CALL	GETPAL
	CALL	SETPAL

	POP	IY
	LD	E,(IY+LVL.GFX)
	CALL	LDPATSET		;LOAD THE LEVEL PATTERN SET
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	E = SET NUMBER

	CSEG
	PUBLIC	LDPATSET
	EXTRN	VLDIR,CARTPAGE

LDPATSET:LD	A,PAT0PAGE
	ADD	A,E
	LD	E,A
	CALL	CARTPAGE		;SET THE PAGE OF THE GRAPHICS
	LD	HL,CARTSEG
	LD	DE,00000H
	LD	BC,04000H
	LD	A,PATPAGE*2
	JP	VLDIR			;COPY THEM TO VRAM (256*128)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = ROOM LOCATION
;OUTPUT:Z = 1 WHEN DE IS NOT CORRECT

	CSEG

CHKROOM:LD	A,-1			;CHECK IF THE ROOM LOCATION IS CORRECT
	CP	D
	RET	Z
	CP	E
	RET	Z
	LD	A,(ROOMYSIZ)
	CP	E
	RET	Z
	LD	A,(ROOMXSIZ)
	CP	D
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = LEVEL POSITION
;	BC = ROOM POSITION
;	IY = RINFO POINTER
;	A = HEIGHT LEVEL
;OUTPUT:HL = POINTER TO THE HEIGHT MATRIX
;	Z = 1 WHEN ERROR

	CSEG

GETHMATRIX:
	EX	AF,AF'			;A' = HEIGHT LEVEL
	LD	A,IYL
	OR	IYU
	JR	Z,H.NINFO

	EX	AF,AF'			;A = HEIGHT LEVEL
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A			;A = HEIGHT*64 (MAPXSIZ*MAPYSIZ)
	LD	L,A
	LD	H,0			;HL = SIZHMATRIX*HEIGHT

	LD	E,IYL			;DE = RINFO
	LD	D,IYU
	ADD	HL,DE			;HL = RINFO + HMATRIX[HEIGHT]
	LD	DE,RINFO.HMATRIX
	ADD	HL,DE			;HL = RINFO->HMATRIX[HEIGHT]
	OR	1
	RET

H.NINFO:EX	AF,AF'			;RESTORE INPUT PARAMETERS
	CALL	GETROOM			;HL = POINTER TO MAP ADDRESS
	RET	Z
	LD	E,(HL)
	INC	HL
	LD	D,(HL)			;DE = MAP NUMBER
	LD	A,E
	OR	D
	RET	Z			;DE = MAPNO = 0 MEANS NO ROOM
	CALL	GETHMAP			;HL = HEIGHT ADDRESS (HMAP)
	OR	1
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = LEVEL POSITION
;	BC = ROOM POSITION
;	HL = MAP POSITION
;	IY = RINFO POINTER
;	A = HEIGHT LEVEL
;OUTPUT:A = HEIGHT VALUE
;	HL = POINTER TO THE HEIGHT VALUE
;	Z = 1 WHEN ERROR

	CSEG
	PUBLIC	GETHEIGHT

GETHEIGHT:
	PUSH	HL
	CALL	GETHMATRIX		;HL = HMATRIX
	POP	DE
	RET	Z
	CALL	MOFFSET
	LD	A,(HL)			;HL = &HMATRIX[Y][X]
	CP	-1
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = ROOM COORDENATES
;	IY = POINTER TO THE RINFO

	CSEG
	EXTRN	GETROOM

FILLHMATRIX:
	LD	(F.ROOM),DE		;FILL THE HMATRIX OF THE RINFO
	LD	E,IYL
	LD	D,IYU
	LD	HL,RINFO.HMATRIX
	ADD	HL,DE
	EX	DE,HL
	XOR	A

M.LOOPH:LD	(F.HEIGHT),A
	LD	(F.PTR),DE
	LD	DE,(LEVEL)
	LD	BC,(F.ROOM)
	LD	A,(F.HEIGHT)
	CALL	GETROOM			;GET THE MAP NUMBER
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	A,E
	OR	D
	RET	Z			;MAPNO = 0 MEANS EMPTY MAP
	CALL	GETHMAP			;GET THE ADDRESS OF THE HMATRIX
	LD	DE,(F.PTR)
	LD	BC,SIZHMATRIX
	LDIR
	LD	A,(F.HEIGHT)
	INC	A
	CP	NR_HEIGHTS
	JR	NZ,M.LOOPH
	RET

	DSEG
F.HEIGHT:	DB	0
F.ROOM:		DW	0
F.PTR:		DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = LEVEL
;	BC = ROOM

	CSEG
	PUBLIC	FOCUSCAM
	EXTRN	MAP,CLRVPAGE,CPVPAGE,GETHMAP,SHOWDOORS

FOCUSCAM:
	LD	(LEVEL),DE
	LD	(ROOM),BC
	PUSH	DE
	PUSH	BC
	LD	DE,(ACPAGE)
	CALL	CLRVPAGE		;CLEAR ACTIVE PAGE
	POP	BC
	POP	DE
	CALL	MAP			;MAP THE ROOM IN ACTIVE PAGE
	LD	DE,(ACPAGE)
	LD	BC,(DPPAGE)
	CALL	CPVPAGE			;COPY FROM ACTIVE PAGE TO DISPLAY PAGE

	LD	IY,RINFO
	LD	B,NR_RINFO

M.LOOP:	PUSH	BC
	PUSH	IY

	LD	DE,(ROOM)
	LD	L,(IY+RINFO.INC)
	LD	H,(IY+RINFO.INC+1)	;HL=ROOM INCREMENTS
	LD	A,E
	ADD	A,L
	LD	E,A
	LD	A,D
	ADD	A,H
	LD	D,A
	CALL	CHKROOM
	LD	(IY+RINFO.ROOM),E	;DE = NEW ROOM LOCATION
	LD	(IY+RINFO.ROOM+1),D
	CALL	FILLHMATRIX

	POP	IY
	LD	DE,SIZRINFO
	ADD	IY,DE			;IY POINTING TO NEXT RINFO
	POP	BC
	DJNZ	M.LOOP
	CALL	SHOWDOORS		;SHOW THE DOORS IN THE VISIBLE ROOMS
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG

RINFO:	DS	SIZRINFO*NR_RINFO
LEVEL:	DW	0
ROOM:	DW	0



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	PATHFINDER
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = COORDENATE 1
;	BC = COORDENATE 2
;OUTPUT:A = DISTANCE BETWEEN BOTH POINTS
;	Z = 1 WHEN DE == BC
;MODIFY:H

	CSEG
	PUBLIC	DISTANCE

DISTANCE:
	LD	A,D
	SUB	B
	JP	P,D.1
	NEG
D.1:	LD	H,A
	LD	A,E
	SUB	C
	JP	P,D.2
	NEG
D.2:	ADD	A,H
	RET				;A = ABS(P1.X-P2.X) + ABS(P1.Y-P2.Y)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = A POINT
;OUTPUT:Z = 1 WHEN NO VALID NODE

	CSEG

ISGOOD:	LD	A,D
	CP	-1
	RET	Z
	CP	MAPXSIZ
	RET	Z
	LD	A,E
	CP	-1
	RET	Z
	CP	MAPYSIZ
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = A POINT
;OUTPUT:Z = 1 WHEN NO ACCESSIBLE

	CSEG

ISACCESS:
	LD	A,(HEIGHT)
	LD	E,A
	LD	A,(HL)
	SUB	E
	JP	P,A.POS
	NEG
A.POS:	CP	2
	JR	C,A.OK
	XOR	A
	RET
A.OK:	OR	1
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = MARK POINTER
;	E = DIRECTION OF THIS NODE
;OUTPUT:Z = 1 WHEN NO VALID NODE

	CSEG

ISMARKED:
	LD	A,(HL)
	CP	-1
	RET	NZ
	LD	(HL),E			;MARK THIS NODE AS VISITED
	RET				;USE THE DIRECTION

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OUTPUT:HL = POINTER TO NODE
;	Z = 1 WHEN NO MORE AVAIBLE NODES

	CSEG
	EXTRN	PTRHL

GETNODE:LD	HL,(BESTP)
	LD	A,H
	OR	L
	RET	Z

	PUSH	HL			;TAKE IT FROM BEST QUEUE
	LD	DE,NODE.NEXT		;PTR = BESTP
	ADD	HL,DE			;BESTP = BESTP->NEXT
	CALL	PTRHL
	LD	(BESTP),HL
	LD	A,L
	OR	H
	JP	NZ,G.BEST1
	LD	HL,(BADP)		;IF !BESTP THEN
	LD	DE,(WORSTP)		;   BESTP = BADP
	LD	(BADP),DE		;   BADP = WORSTP
	LD	DE,0			;   WORSTP = TAILP = NULL
	LD	(WORSTP),DE
	LD	(TAILP),DE
G.BEST1:LD	(BESTP),HL
	POP	HL			;RETURN PTR
	OR	1
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = NODE COORDENATES
;	(DESTINE) = DESTINE NODE
;	A = DISTANCE

	CSEG

NEWNODE:LD	BC,(DESTINE)
	CALL	DISTANCE
	RET	Z			;WE HAVE FOUND THE DESTINE, STOP

	LD	HL,STEP
	ADD	A,(HL)
	LD	(N.COST),A
	LD	HL,(NODEPTR)
	PUSH	HL
	PUSH	HL
	LD	BC,SIZNODE
	ADD	HL,BC
	LD	(NODEPTR),HL
	POP	HL
	LD	(HL),A			;STORE THE DISTANCE
	INC	HL
	LD	A,(STEP)
	LD	(HL),A			;STORE NUMBER OF STEPS
	INC	HL
	LD	(HL),E			;STORE COORDENATES
	INC	HL
	LD	(HL),D
	INC	HL
	EX	DE,HL			;DE = POINTER TO ACTUAL->NEXT
	POP	BC			;BC = ACTUAL NODE POINTER

	LD	HL,(BESTP)
	LD	A,H
	OR	L
	JP	Z,N.BEST		;BEST IS EMPTY, INSERT
	LD	A,(N.COST)
	CP	(HL)
	JP	Z,N.BEST		;COST <= BESTP->COST, INSERT
	JP	C,N.BEST

	LD	HL,(BADP)
	LD	A,H
	OR	L
	JP	Z,N.BAD			;BAD IS EMPTY, INSERT
	LD	A,(N.COST)
	CP	(HL)
	JP	Z,N.BAD			;COST <= BADP->COST, INSERT
	JP	C,N.BAD

	LD	HL,(WORSTP)
	LD	A,L
	OR	H
	JP	NZ,N.TAIL
	LD	(WORSTP),BC		;IF WORSTP == NULL
	LD	(TAILP),BC		;   TAILP = WORSTP = NODE
	JP	N.AUX			;   NODE->NEXT = NULL

N.TAIL:	LD	IY,(TAILP)		;IF WORSTP != NULL
	LD	(TAILP),BC		;   NODE->NEXT = NULL
	LD	(IY+NODE.NEXT),C	;   TAILP->NEXT = NODE
	LD	(IY+NODE.NEXT+1),B	;   TAILP = NODE
	LD	HL,0
	JP	N.AUX

N.BAD:	LD	(BADP),BC
	JP	N.AUX

N.BEST:	LD	(BESTP),BC

N.AUX:	EX	DE,HL
	LD	(HL),E
	INC	HL
	LD	(HL),D
	OR	1
	RET

	DSEG
N.COST:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	(NODE) = ACTUAL NODE
;	(HEIGHT) = NODE HEIGHT
;	(HPTR) = ACTUAL HEIGHT POINTER
;	(MPTR) = ACTUAL MARKED POINTER
;	(DESTINE) = DESTINE
;OUTPUT:Z = 1 WHEN WE HAVE REACHED THE DESTINE

	CSEG

ADDNODES:				;DON'T EXPAND THE ORIGIN NODE
	LD	HL,(MPTR)		;SO, DON'T TRY THE INVERSE DIRECTION
	LD	B,(HL)			;OF OUR FATHER
	INC	B

N.0:	DJNZ	N.1			;RIGHT
	CALL	A.RIGHT
	CALL	NZ,A.UP
	CALL	NZ,A.DOWN
	RET

N.1:	DJNZ	N.2			;DOWN
	CALL	A.RIGHT
	CALL	NZ,A.LEFT
	CALL	NZ,A.DOWN
	RET

N.2:	DJNZ	N.3			;UP
	CALL	A.RIGHT
	CALL	NZ,A.LEFT
	CALL	NZ,A.UP
	RET

N.3:	DJNZ	N.4
	CALL	A.LEFT			;LEFT
	CALL	NZ,A.UP
	CALL	NZ,A.DOWN
	RET

N.4:	CALL	A.RIGHT			;NODIR
	CALL	NZ,A.LEFT
	CALL	NZ,A.UP
	CALL	NZ,A.DOWN
	RET

A.RIGHT:LD	DE,(NODE)		;IF ISGOOD && ISACCESS && ISMARKED THEN
	INC	D			;   IF NEWNODE == DESTINE THEN
	CALL	ISGOOD			;      RETURN FOUND
	JP	Z,A.SET
	LD	HL,(HPTR)
	INC	HL
	CALL	ISACCESS
	JP	Z,A.SET
	LD	HL,(MPTR)
	INC	HL
	LD	E,DRIGHT
	CALL	ISMARKED
	RET	NZ
	LD	DE,(NODE)
	INC	D
	CALL	NEWNODE
	RET


A.LEFT:	LD	DE,(NODE)
	DEC	D
	CALL	ISGOOD
	JP	Z,A.SET
	LD	HL,(HPTR)
	DEC	HL
	CALL	ISACCESS
	JP	Z,A.SET
	LD	HL,(MPTR)
	DEC	HL
	LD	E,DLEFT
	CALL	ISMARKED
	RET	NZ
	LD	DE,(NODE)
	DEC	D
	CALL	NEWNODE
	RET

A.UP:	LD	DE,(NODE)
	DEC	E
	CALL	ISGOOD
	JP	Z,A.SET
	LD	HL,(HPTR)
	LD	DE,-MAPYSIZ
	ADD	HL,DE
	CALL	ISACCESS
	JP	Z,A.SET
	LD	HL,(MPTR)
	LD	DE,-MAPYSIZ
	ADD	HL,DE
	LD	E,DUP
	CALL	ISMARKED
	RET	NZ
	LD	DE,(NODE)
	DEC	E
	CALL	NEWNODE
	RET

A.DOWN:	LD	DE,(NODE)
	INC	E
	CALL	ISGOOD
	JP	Z,A.SET
	LD	HL,(HPTR)
	LD	DE,MAPYSIZ
	ADD	HL,DE
	CALL	ISACCESS
	JP	Z,A.SET
	LD	HL,(MPTR)
	LD	DE,MAPYSIZ
	ADD	HL,DE
	LD	E,DDOWN
	CALL	ISMARKED
	RET	NZ
	LD	DE,(NODE)
	INC	E
	CALL	NEWNODE
	RET

A.SET:	OR	1
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = ORIGIN
;	BC = DESTINE
;	HL = HEIGHT MATRIX
;OUTPUT:Z = 1 WHEN NO PATH

	CSEG
	PUBLIC	PSEARCH
	EXTRN	MEMSET


PSEARCH:LD	(P.MATRIX),HL
	LD	IY,POINT.Y
	ADD	IY,DE
	LD	E,(IY)
	LD	D,(IY+1)
	LD	(ORIGIN),DE		;INITIALIZE DESTINE
	LD	(NODE),DE

	LD	IY,POINT.Y
	ADD	IY,BC
	LD	C,(IY)
	LD	B,(IY+1)
	LD	(DESTINE),BC		;INITIALIZE DESTINE

	LD	HL,0
	LD	(BESTP),HL		;AND DATA POINTERS
	LD	(BADP),HL
	LD	(WORSTP),HL
	LD	(TAILP),HL
	LD	A,1
	LD	(STEP),A
	LD	HL,NODEBUF
	LD	(NODEPTR),HL
	LD	HL,MARKBUF		;CLEAR MARK BUF
	LD	BC,MAPYSIZ*MAPXSIZ
	LD	A,-1
	CALL	MEMSET

	LD	HL,(P.MATRIX)		;TODO: REMOVE THIS PART
	LD	DE,(ORIGIN)
	CALL	MOFFSET
	LD	(HL),0
	LD	HL,(P.MATRIX)
	LD	DE,(DESTINE)
	CALL	MOFFSET
	LD	(HL),0

	LD	HL,MARKBUF		;MARK AS EXPLORED THE ORIGIN
	LD	DE,(ORIGIN)
	CALL	MOFFSET
	LD	(HL),DNODIR

P.LOOP:	LD	(MPTR),HL		;MPTR = MARKBUF + Y*MAPYSIZ + X

	LD	HL,(P.MATRIX)
	CALL	MOFFSET
	LD	(HPTR),HL		;HPTR = P.MATRIX + Y*MAPYSIZ + X
	LD	A,(HL)
	LD	(HEIGHT),A

	CALL	ADDNODES
	JP	NZ,P.NEXT
	CALL	GETPATH
	OR	1
	RET

P.NEXT:	CALL	GETNODE			;GET THE BEST NODE
	RET	Z
	INC	HL
	LD	A,(HL)
	INC	A
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(STEP),A
	LD	(NODE),DE
	LD	HL,MARKBUF
	CALL	MOFFSET
	JP	P.LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	ADDAHL

MOFFSET:LD	A,E			;CALCULATE THE OFFSET IN A MAP
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,D
	JP	ADDAHL

	DSEG
P.MATRIX:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	(DESTINE) = DESTINE LOCATION
;	(ORIGIN) = ORIGIN LOCATION
;	(OUTBUF) = POINTER TO OUTPUT BUFFER
;	(OUTCNT) = SIZE OF OUTPUT BUFFER

	CSEG

GETPATH:LD	DE,(DESTINE)
	CALL	PXXX
	LD	(OUTCNT),A
	RET

PXXX:	LD	HL,(ORIGIN)
	CALL	DCOMPR
	JR	NZ,X.0
	LD	HL,(OUTBUF)
	LD	A,(OUTCNT)
	RET

X.0:	LD	HL,MARKBUF
	CALL	MOFFSET			;TAKE THE ADDRESS OF THE POSITION IN
	LD	B,(HL)			;THE MARK BUFFER
	INC	B

X.RIGHT:DJNZ	X.DOWN
	DEC	D
	CALL	PXXX
	LD	B,DRIGHT
	JR	ADDSTEP

X.DOWN:	DJNZ	X.UP
	DEC	E
	CALL	PXXX
	LD	B,DDOWN
	JR	ADDSTEP

X.UP:	DJNZ	X.LEFT
	INC	E
	CALL	PXXX
	LD	B,DUP
	JR	ADDSTEP

X.LEFT:	DJNZ	X.RET
	INC	D
	CALL	PXXX
	LD	B,DLEFT

ADDSTEP:OR	A
	RET	Z
	DEC	A
	LD	(HL),B
	INC	HL
X.RET:	RET


;;;;;;;;;;;;

NODE.COST	EQU	0
NODE.STEP	EQU	NODE.COST+1
NODE.Y		EQU	NODE.STEP+1
NODE.X		EQU	NODE.Y+1
NODE.NEXT	EQU	NODE.X+1
SIZNODE		EQU	NODE.NEXT+2


	DSEG
	PUBLIC	OUTBUF,OUTCNT

STEP:	DB	0
NODE:	DW	0
HEIGHT:	DB	0
HPTR:	DW	0
MPTR:	DW	0
ORIGIN:	DW	0
DESTINE:DW	0
NODEPTR:DW	0
BESTP:	DW	0
BADP:	DW	0
WORSTP:	DW	0
TAILP:	DW	0
OUTBUF:	DW	0
OUTCNT:	DB	0
MARKBUF:DS	MAPXSIZ*MAPYSIZ
NODEBUF:DS	SIZNODE*MAPXSIZ*MAPYSIZ



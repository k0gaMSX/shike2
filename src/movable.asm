
	INCLUDE	BIOS.INC
	INCLUDE SHIKE2.INC
	INCLUDE	GEOMETRY.INC
	INCLUDE	MOVABLE.INC

NR_STEP		EQU	4		;NUMBER OF ANIMATIONS OF ONE STEP

MOV.LEVEL	EQU	MOV.POINT+POINT.LEVEL
MOV.ROOM	EQU	MOV.POINT+POINT.ROOM
MOV.Y		EQU	MOV.POINT+POINT.Y
MOV.X		EQU	MOV.POINT+POINT.X
MOV.Z		EQU	MOV.POINT+POINT.Z

MOV.DLEVEL	EQU	MOV.DPOINT+POINT.LEVEL
MOV.DROOM	EQU	MOV.DPOINT+POINT.ROOM
MOV.DY		EQU	MOV.DPOINT+POINT.Y
MOV.DX		EQU	MOV.DPOINT+POINT.X
MOV.DZ		EQU	MOV.DPOINT+POINT.Z


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = FUNCTION POINTER

	CSEG
	EXTRN	PTRCALL

FOREACH:PUSH	IX
	LD	(F.FUN),HL
	LD	IY,HEAD

F.LOOP:	LD	E,(IY+MOV.NEXT)
	LD	D,(IY+MOV.NEXT+1)
	LD	HL,HEAD
	CALL	DCOMPR
	JR	Z,F.END

	LD	IXL,E
	LD	IXU,D
	PUSH	IX
	LD	HL,(F.FUN)
	CALL	PTRCALL
	POP	IY
	JR	F.LOOP

F.END:	POP	IX
	RET

	DSEG
F.FUN:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE MOVABLE

	CSEG
	EXTRN	FREEMOB

HIDEMOV:LD	E,(IX+MOV.MOB)
	LD	A,-1
	LD	(IX+MOV.MOB),A			;MARK THE MOB AS INVALID
	LD	(IX+MOV.RINFO),A		;THE CACHED ROOM INFORMATION
	LD	(IX+MOV.RINFO+1),A		;IS NOT VALID ANYMORE
	JP	FREEMOB


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	MOVINIT
	EXTRN	BZERO

MOVINIT:LD	DE,HEAD
	LD	(HEAD+MOV.NEXT),DE
	LD	(HEAD+MOV.PREV),DE
	LD	DE,ANIM
	LD	(ANIM+MOV.ANEXT),DE
	LD	(ANIM+MOV.APREV),DE
	LD	A,-1
	LD	H,A
	LD	L,A
	LD	(LEVEL),A
	LD	(ROOM),HL
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	ANIMATE

ANIMATE:PUSH	IX			;CALL ANIMMOV FOR EACH MOVABLE IN THE
	LD	IY,ANIM			;ANIMATION LIST

A.LOOP:	LD	E,(IY+MOV.ANEXT)
	LD	D,(IY+MOV.ANEXT+1)
	LD	HL,ANIM
	CALL	DCOMPR
	JR	Z,A.END

	LD	IXL,E
	LD	IXU,D
	PUSH	IX
	CALL	ANIMMOV
	POP	IY
	JR	A.LOOP

A.END:	POP	IX
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE MOVABLE

	CSEG
	EXTRN	ISOINC,HEIGTH,GETRINFO,ALLOCMOB

ANIMMOV:XOR	A
	CP	(IX+MOV.STEPCNT)
	JR	Z,A.STOP

	DEC	(IX+MOV.STEPCNT)
	LD	A,(IX+MOV.RINFO)	;IF IT IS NOT VISIBLE THEN RETURN
	OR	(IX+MOV.RINFO+1)
	RET	Z

	LD	E,(IX+MOV.DIR)		;CALCULATE NEXT POSITION
	LD	A,NR_STEP-1		;BASED IN DIRECTION AND NUMBER
	SUB	(IX+MOV.STEPCNT)	;OF ANIMATION STEPS
	LD	C,A
	CALL	ISOINC
	LD	L,(IX+MOV.YR)
	LD	H,(IX+MOV.YR+1)
	ADD	HL,DE
	EX	DE,HL
	LD	L,(IX+MOV.XR)
	LD	H,(IX+MOV.XR+1)
	ADD	HL,BC
	JP	DRAW			;DRAW NEW MOVABLE POSITION

A.STOP:	CALL	UNLINKANIM		;UNLINK FROM ANIMATED MOVABLES
	LD	L,(IX+MOV.RINFO)	;REMOVE THE MOVABLE FROM PREVIOUS
	LD	H,(IX+MOV.RINFO+1)	;POSITION IN THE HMATRIX
	LD	A,L
	OR	H
	JR	Z,A.DST

	LD	DE,RINFO.HMATRIX	;WHEN IT WAS VISIBLE, REMOVE HEIGTH
	ADD	HL,DE			;FROM THE FLOOR
	LD	B,H
	LD	C,L			;BC = HMATRIX
	LD	E,(IX+MOV.Y)
	LD	D,(IX+MOV.X)		;DE = COORDENATES
	CALL	HEIGTH
	SUB	(IX+MOV.ZSIZ)
	LD	(HL),A

A.DST:	LD	E,IXL			;SET POINT FIELD TO DESTINE POINT
	LD	D,IXU
	LD	HL,MOV.POINT
	ADD	HL,DE
	EX	DE,HL			;DE = POINT FIELD OF MOVABLE
	LD	BC,MOV.DPOINT
	ADD	HL,BC			;HL = DPOINT FIELD OF MOVABLE
	LD	BC,POINT.SIZ
	LDIR

	LD	C,(IX+MOV.LEVEL)	;WE CAN NOT CALL TO SETRINFO
	LD	E,(IX+MOV.ROOM)		;BECAUSE IT UPDATES HEIGTH INFORMATION
	LD	D,(IX+MOV.ROOM+1)
	CALL	GETRINFO		;TAKE THE INFORMATION OF THE
	LD	(IX+MOV.RINFO),L	;ROOM WHERE IS LOCATED THE MOVABLE
	LD	(IX+MOV.RINFO+1),H
	RET	Z			;IT IS NOT VISIBLE, RETURN

	LD	A,-1
	CP	(IX+MOV.MOB)
	JR	NZ,A.RENDER		;IT ALREADY HAS MOB, GO TO RENDER
	CALL	ALLOCMOB
	LD	(IX+MOV.MOB),A

A.RENDER:
	CALL	RENDER
	CALL	CHKCAMERA		;IF IT IS RENDERED, MAYBE IT IS
	RET				;THE CAMERA MAN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE MOVABLE
;	A = STEP DIRECTION
;OUTPUT:Z = 1 WHEN IT IS NOT POSSIBLE THE STEP

	CSEG
	PUBLIC	STEP
	EXTRN	NEXTPOINT,HEIGTH

STEP:	LD	(IX+MOV.DIR),A		;STEP ALWAYS CHANGE THE DIRECTION
	LD	E,(IX+MOV.Y)		;OF THE MOVABLE
	LD	D,(IX+MOV.X)
	LD	C,(IX+MOV.ROOM)
	LD	B,(IX+MOV.ROOM+1)
	CALL	NEXTPOINT		;CALCULATE DESTINATION POINT

	LD	A,(IX+MOV.LEVEL)	;TODO: CHECK ROOM IS INSIDE THE LEVEL
	LD	(S.LVL),A
	LD	(S.COOR),DE
	LD	(S.ROOM),BC
	CALL	HPOINTERS		;CALCULATE POINTERS TO HEIGTHS

	LD	HL,(S.HPTR1)
	LD	A,L
	OR	H
	JR	Z,S.OK			;IS ORIGIN VISIBLE?

	LD	DE,(S.HPTR2)
	LD	A,E
	OR	D
	JR	Z,S.OK			;IS DESTINE VISIBLE?

	LD	A,(DE)
	ADD	A,(IX+MOV.ZSIZ)		;ORIGIN HAS FLOOR HEIGTH + MOV HEIGTH
	CP	(HL)
	JR	Z,S.OK

	LD	E,(IX+MOV.DIR)		;DIFFERENT HEIGTHS, FORBIDDEN
	CALL	TURN			;TURN THE MOVABLE IN THE DIRECTION
	XOR	A			;WE WANTED STEP
	RET				;SET Z = 0

S.OK:	LD	A,(S.LVL)		;COPY DESTINE TO THE MOVABLE
	LD	(IX+MOV.DLEVEL),A
	LD	(IX+MOV.STEPCNT),NR_STEP
	LD	DE,(S.ROOM)
	LD	(IX+MOV.DROOM),E
	LD	(IX+MOV.DROOM+1),D
	LD	DE,(S.COOR)
	LD	(IX+MOV.DY),E
	LD	(IX+MOV.DX),D
	CALL	LINKANIM		;LINK IN THE ANIMABLE MOVABLES

	LD	HL,(S.HPTR2)		;MARK THE DESTINATION
	LD	A,L			;HEIGTH WITH THE NEW HEIGTH
	OR	H
	RET	Z
	LD	A,(IX+MOV.ZSIZ)
	ADD	A,(HL)
	LD	(HL),A
	OR	1			;GOOD STEP, SET Z = 0
	RET

;;;;;;;;;;;;;;;;;;;;;;

HPOINTERS:				;AUXILIAR FUNCTION FOR STEP
	LD	HL,0			;CALCULATE HEIGTH POINTERS
	LD	(S.HPTR1),HL
	LD	(S.HPTR2),HL

	LD	L,(IX+MOV.RINFO)
	LD	H,(IX+MOV.RINFO+1)
	LD	A,L			;IS IT VISIBLE THE MOVABLE IN ORIGIN?
	OR	H
	JR	Z,H.2ND

	LD	DE,RINFO.HMATRIX	;HL = RINFO STRUCTURE
	ADD	HL,DE			;HL = HMATRIX
	LD	C,L
	LD	B,H			;BC = HMATRIX
	LD	E,(IX+MOV.Y)
	LD	D,(IX+MOV.X)		;DE = ORIGIN COORDENATES
	CALL	HEIGTH
	LD	(S.HPTR1),HL

H.2ND:	LD	BC,(S.LVL)		;NO, TAKE THE RINFO OF THE SECOND
	LD	DE,(S.ROOM)
	CALL	GETRINFO
	RET	Z			;HL = RINFO STRUCTURE
	LD	DE,RINFO.HMATRIX
	ADD	HL,DE			;HL = HMATRIX
	LD	C,L
	LD	B,H			;BC = MATRIX
	LD	DE,(S.COOR)		;DE = COORDENATES
	CALL	HEIGTH
	LD	(S.HPTR2),HL
	RET

	DSEG
S.LVL:	DB	0
S.ROOM:	DW	0
S.COOR:	DW	0
S.HPTR1:DW	0
S.HPTR2:DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE MOVABLE
;	E = DIRECTION

	CSEG
	PUBLIC	TURN

TURN:	LD	(IX+MOV.DIR),E
	LD	L,(IX+MOV.XR)
	LD	H,(IX+MOV.XR+1)
	LD	E,(IX+MOV.YR)
	LD	D,(IX+MOV.YR+1)
	JP	DRAW

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE MOVABLE

	CSEG
	EXTRN	WRLD2SCR

RENDER:	LD	E,(IX+MOV.RINFO)
	LD	D,(IX+MOV.RINFO+1)
	LD	A,E
	OR	D
	RET	Z			;THIS MOVABLE ISN'T SHOWED BY THE CAMERA

	LD	IYL,E
	LD	IYU,D
	LD	E,(IY+RINFO.XR)
	LD	D,(IY+RINFO.XR+1)
	LD	C,(IY+RINFO.YR)
	LD	B,(IY+RINFO.YR+1)
	LD	L,(IX+MOV.Y)
	LD	H,(IX+MOV.X)
	CALL	WRLD2SCR
	LD	(IX+MOV.XR),L
	LD	(IX+MOV.XR+1),H
	LD	(IX+MOV.YR),E
	LD	(IX+MOV.YR+1),D		;INITIALIZE RENDER COORDENATES

	;CONTINUE IN DRAW

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE MOVABLE
;	HL = X POSIITON
;	DE = Y POSIITON

	CSEG
	EXTRN	PUTMOB

DRAW:	LD	C,(IX+MOV.MOB)
	LD	A,-1
	CP	C
	RET	Z			;RETURN IF NOT VALID MOB

	XOR	A
	CP	(IX+MOV.STEPCNT)
	JR	Z,D.STOP		;WE ARE STOPPED, SO IGNORE JIFFY

	LD	A,(JIFFY)		;USE JIFFY COUNTER FOR ANIMATIONS
	SRL	A
	SRL	A
	AND	3
	CP	3
	JR	NZ,D.STOP
	XOR	A

D.STOP:	ADD	A,A			;WE HAVE 16 PATTERNS IN EACH ROW
	ADD	A,A			;ANE EACH ROW HAS GRAPHICHS FOR ONE
	ADD	A,A			;ANIMATION, SO WE HAVE TO MULTIPLY
	ADD	A,A			;BY 16
	LD	B,A
	LD	A,(IX+MOV.PAT)		;WE HAVE 4 DIRECTIONS, SO
	ADD	A,A			;EACH PATTERN MEANS MULTIPLY BY 4
	ADD	A,A
	ADD	A,B
	ADD	A,(IX+MOV.DIR)
	LD	B,A
	LD	A,(IX+MOV.Z)
	JP	PUTMOB			;DRAW THE MOVABLE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE MOVABLE

	CSEG

LINKANIM:
	LD	DE,(ANIM+MOV.ANEXT)	;DE = ANIM.NEXT
	LD	IYL,E
	LD	IYU,D			;IY = HEAD.NEXT
	LD	C,IXL
	LD	B,IXU			;BC = PTR
	LD	HL,ANIM			;HL = &HEAD

	LD	(IX+MOV.APREV),L
	LD	(IX+MOV.APREV+1),H	;PTR->APREV = &ANIM
	LD	(IX+MOV.ANEXT),E
	LD	(IX+MOV.ANEXT+1),D	;PTR->ANEXT = ANIM.ANEXT

	LD	(ANIM+MOV.ANEXT),BC	;ANIM.ANEXT = PTR
	LD	(IY+MOV.APREV),C
	LD	(IY+MOV.APREV+1),B	;ANIM.ANEXT->APREV = PTR
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE MOVABLE

	CSEG

UNLINKANIM:
	LD	C,(IX+MOV.APREV)
	LD	B,(IX+MOV.APREV+1)	;BC = PTR->APREV
	LD	E,(IX+MOV.ANEXT)
	LD	D,(IX+MOV.ANEXT+1)	;DE = PTR->ANEXT

	LD	IYL,C
	LD	IYU,B
	LD	(IY+MOV.ANEXT),E
	LD	(IY+MOV.ANEXT+1),D	;PTR->APREV->ANEXT = PTR->ANEXT

	LD	IYL,E
	LD	IYU,D
	LD	(IY+MOV.APREV),C
	LD	(IY+MOV.APREV+1),B	;PTR->ANEXT->APREV = PTR->APREV
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: IX = POINTER TO MOVABLE
;	E = NUMBER OF PATTERN
;	C = Z SIZE

	CSEG
	PUBLIC	NEWMOV
	EXTRN	BZERO

NEWMOV:	LD	B,E
	PUSH	BC
	PUSH	IX
	POP	HL
	LD	BC,MOV.SIZ
	CALL	BZERO			;INITIALIZE TO 0

	POP	BC
	LD	(IX+MOV.ZSIZ),C
	LD	(IX+MOV.PAT),B
	LD	A,-1
	LD	(IX+MOV.MOB),A		;IT IS NOT VISIBLE NOW
	LD	(IX+MOV.LEVEL),A	;COLOCATE IT IN NO VALID ROOM
	LD	(IX+MOV.ROOM),A
	LD	(IX+MOV.ROOM+1),A

	LD	DE,(HEAD+MOV.NEXT)	;DE = HEAD.NEXT
	LD	IYL,E
	LD	IYU,D			;IY = HEAD.NEXT
	LD	C,IXL
	LD	B,IXU			;BC = PTR
	LD	HL,HEAD			;HL = &HEAD

	LD	(IX+MOV.PREV),L
	LD	(IX+MOV.PREV+1),H	;PTR->PREV = &HEAD
	LD	(IX+MOV.NEXT),E
	LD	(IX+MOV.NEXT+1),D	;PTR->NEXT = HEAD.NEXT

	LD	(HEAD+MOV.NEXT),BC	;HEAD.NEXT = PTR
	LD	(IY+MOV.PREV),C
	LD	(IY+MOV.PREV+1),B	;HEAD.NEXT->PREV = PTR
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: IX = POINTER TO MOVABLE
;	DE = POINTER TO INITIAL POINT
;	C = INITIAL DIRECTION

	CSEG
	PUBLIC	PLACE

PLACE:	LD	(IX+MOV.DIR),C

	LD	C,IXL
	LD	B,IXU
	LD	HL,MOV.POINT
	ADD	HL,BC
	EX	DE,HL
	LD	BC,POINT.SIZ
	LDIR				;COPY MOVABLE POINT

	CALL	SETRINFO
	JP	RENDER

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;IX = POINTER TO THE MOVABLE

	CSEG
	EXTRN	HEIGTH,GETRINFO,ALLOCMOB

SETRINFO:
	LD	C,(IX+MOV.LEVEL)
	LD	E,(IX+MOV.ROOM)
	LD	D,(IX+MOV.ROOM+1)
	CALL	GETRINFO		;TAKE THE INFORMATION OF THE
	LD	(IX+MOV.RINFO),L	;ROOM WHERE IS LOCATED THE MOVABLE
	LD	(IX+MOV.RINFO+1),H
	LD	(IX+MOV.Z),-1		;WE DON'T KNOW IF WE ARE IN A VISIBLE
	JR	Z,S.DEST		;ROOM

	LD	DE,RINFO.HMATRIX	;UPDATE THE HEIGTH MATRIX
	ADD	HL,DE
	LD	C,L
	LD	B,H
	LD	E,(IX+MOV.Y)
	LD	D,(IX+MOV.X)
	CALL	HEIGTH
	LD	(IX+MOV.Z),A		;CATCH THIS VALUE BECAUSE IT WILL
	ADD	A,(IX+MOV.ZSIZ)		;BE USED LATER
	LD	(HL),A
	CALL	ALLOCMOB		;WE ARE IN CAMERA AREA, SO WE NEED
	LD	(IX+MOV.MOB),A		;A MOB.

S.DEST:	XOR	A			;ARE WE IN A ANIMATION?
	CP	(IX+MOV.STEPCNT)
	RET	Z
	LD	C,(IX+MOV.DLEVEL)	;UPDATE THE DESTINATION HEIGTH
	LD	E,(IX+MOV.DROOM)
	LD	D,(IX+MOV.DROOM+1)
	CALL	GETRINFO
	RET	Z			;IS DESTINATION VISIBLE?

	LD	DE,RINFO.HMATRIX	;UPDATE THE HEIGTH MATRIX
	ADD	HL,DE
	LD	C,L
	LD	B,H
	LD	E,(IX+MOV.DY)
	LD	D,(IX+MOV.DX)
	CALL	HEIGTH
	ADD	A,(IX+MOV.ZSIZ)
	LD	(HL),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	RESETCAMERA

RESETCAMERA:				;FORCE RESET OF THE CAMERA
	PUSH	IX
	LD	A,-1
	LD	L,A
	LD	H,A
	LD	(LEVEL),A
	LD	(ROOM),HL
	LD	IX,(CAMPTR)
	CALL	CHGCAMERA
	POP	IX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = POINTER TO NEW CAMERA MOVABLE

	CSEG
	PUBLIC	SETCAMERA
	EXTRN	MOVECAMERA

SETCAMERA:
	LD	HL,(CAMPTR)
	CALL	DCOMPR
	RET	Z			;IT IS THE SAME NO CHANGE

	PUSH	IX
	LD	(CAMPTR),DE		;UPDATE THE POINTER
	LD	IXL,E
	LD	IXU,D
	CALL	CHGCAMERA
	POP	IX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO MOVABLE

	CSEG

CHKCAMERA:
	LD	E,IXL			;DOES THIS USER GET THE CAMERA?
	LD	D,IXU
	LD	HL,(CAMPTR)
	CALL	DCOMPR
	RET	NZ
	;CONTINUE IN CHGCAMERA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO CAMERA MOVABLE

	CSEG
	EXTRN	VDPSYNC,DISSCR,ENASCR,MOVECAMARA,MOB.ON,MOB.OFF

CHGCAMERA:
	LD	C,(IX+MOV.LEVEL)	;CHECK IF THE MOVABLE IS LOCATED
	LD	E,(IX+MOV.ROOM)		;IN THE SAME ROOM, BECAUSE IN THIS
	LD	D,(IX+MOV.ROOM+1)	;CASE IT IS NOT NECESSARY DO
	LD	A,(LEVEL)		;ANYTHING
	CP	C
	JR	NZ,C.DO
	LD	HL,(ROOM)
	CALL	DCOMPR
	RET	Z

C.DO:	LD	A,C
	LD	(LEVEL),A
	LD	(ROOM),DE
	CALL	DISSCR			;DISABLE SCREEN
	CALL	MOB.OFF			;SWITCH OFF THE MOB ENGINE
	LD	HL,HIDEMOV
	CALL	FOREACH			;MOVABLE RENDERS ARE NOT VALID ANYMORE
	LD	C,(IX+MOV.LEVEL)
	LD	E,(IX+MOV.ROOM)
	LD	D,(IX+MOV.ROOM+1)
	CALL	MOVECAMARA		;MOVE THE CAMERA
	CALL	MOB.ON			;SWITCH ON THE MOB ENGINE
	LD	HL,SETRINFO
	CALL	FOREACH			;UPDATE RINFO INFORMATION IN MOVABLES
	LD	HL,RENDER
	CALL	FOREACH			;RENDER AGAIN ALL THE MOVABLES
	CALL	VDPSYNC			;WAIT TO THE VDP
	CALL	ENASCR			;ENABLE THE SCREEN
	RET

	DSEG
CAMPTR:		DW	0		;MOVABLE POINTER TO ACTUAL CAMERA
LEVEL:		DB	0		;LEVEL WHERE CAMARA IS POINTING
ROOM:		DB	0		;ROOM WHERE CAMARA IS POINTING
HEAD:		DS	MOV.PREV+2	;HEAD OF MOVABLE OBJECTS
ANIM:		DS	MOV.APREV+2	;HEAD OF ANIMATED MOVABLE



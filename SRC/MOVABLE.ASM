
	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	LEVEL.INC
	INCLUDE	DATA.INC

NR_STEP		EQU	8



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	MOVINIT

MOVINIT:LD	DE,HEAD
	LD	(HEAD+MOV.NEXT),DE
	LD	(HEAD+MOV.PREV),DE
	LD	DE,ANIM
	LD	(ANIM+MOV.ANEXT),DE
	LD	(ANIM+MOV.APREV),DE
	LD	H,-1
	LD	(LEVEL),HL
	LD	(ROOM),HL
	LD	(CAMERAOP),HL
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: IX = POINTER TO MOVABLE
;	E = NUMBER OF PATTERN
;	C = Z SIZE
;	HL = CALLBACK FUNCITON

	CSEG
	PUBLIC	MOVABLE
	EXTRN	MOB

MOVABLE:LD	B,E
	PUSH	BC
	PUSH	HL
	CALL	MOB
	POP	HL
	POP	BC
	LD	(IX+MOV.CALLBACK),L
	LD	(IX+MOV.CALLBACK+1),H
	LD	(IX+MOV.ZSIZ),C
	LD	(IX+MOV.PAT),B
	LD	A,-1
	LD	(IX+MOV.LEVEL),A	;COLOCATE IT IN NO VALID ROOM
	LD	(IX+MOV.LEVEL),A
	LD	(IX+MOV.ROOM),A
	LD	(IX+MOV.ROOM+1),A
	XOR	A
	LD	(IX+MOV.RINFO),A
	LD	(IX+MOV.RINFO+1),A
	LD	(IX+MOV.STEPCNT),A

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
;INPUT:	IX = POINTER TO THE MOVABLE
;	A = STEP DIRECTION
;OUTPUT:Z = 1 WHEN IT IS NOT POSSIBLE THE STEP

	CSEG
	PUBLIC	STEP
	EXTRN	NEXTPOINT

STEP:	LD	(IX+MOV.DIR),A		;STEP ALWAYS CHANGE THE DIRECTION
	LD	E,(IX+MOV.Y)		;OF THE MOVABLE
	LD	D,(IX+MOV.X)
	LD	L,(IX+MOV.LEVEL)
	LD	H,(IX+MOV.LEVEL+1)
	LD	C,(IX+MOV.ROOM)
	LD	B,(IX+MOV.ROOM+1)
	CALL	NEXTPOINT		;CALCULATE DESTINATION POINT
	LD	(IX+MOV.DY),E		;COPY DESTINE TO THE MOVABLE
	LD	(IX+MOV.DX),D
	LD	(IX+MOV.DROOM),C
	LD	(IX+MOV.DROOM+1),B
	LD	(IX+MOV.DLEVEL),L
	LD	(IX+MOV.DLEVEL+1),H
	LD	A,(IX+MOV.Z)
	LD	(IX+MOV.DZ),A

	CALL	DHPOINTER		;GET THE HPOINTER TO THE DESTINE
	JR	Z,S.NOK			;DESTINATION NOT POSIBLE
	LD	(IX+MOV.DZ),A		;SAVE DZ VALUE
	NEG
	ADD	A,(IX+MOV.Z)		;D = HO - HD, IF D==0||D==1||D==2 THEN
	JR	Z,S.OK			;IT IS CORRECT
	CP	-1
	JR	Z,S.OK
	CP	1
	JR	NZ,S.NOK

S.OK:	LD	A,(IX+MOV.DZ)		;UPDATE THE HMATRIX
	ADD	A,(IX+MOV.ZSIZ)
	LD	(HL),A

S.NINFO:LD	(IX+MOV.STEPCNT),NR_STEP
	CALL	LINKANIM		;LINK IN THE ANIMABLE MOVABLES
	OR	1
	RET

S.NOK:	LD	E,(IX+MOV.DIR)		;DIFFERENT HEIGTHS, FORBIDDEN
	CALL	TURN			;TURN THE MOVABLE IN THE DIRECTION
	XOR	A
	RET

	DSEG
S.HEIGHT:	DB	0

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
	LD	BC,SIZPOINT
	LDIR				;COPY MOVABLE POINT

	CALL	SETRINFO
	JP	RENDER

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

	CSEG
	PUBLIC	ANIMATE

ANIMATE:PUSH	IX			;CALL ANIMMOV FOR EACH MOVABLE IN THE
	LD	DE,(ANIM+MOV.ANEXT)	;ANIMATION LIST

A.LOOP:	LD	HL,ANIM
	CALL	DCOMPR
	JR	Z,A.END

	LD	IXL,E
	LD	IXU,D
	LD	E,(IX+MOV.ANEXT)
	LD	D,(IX+MOV.ANEXT+1)
	PUSH	DE
	CALL	ANIMMOV
	POP	DE
	JR	A.LOOP

A.END:	POP	IX
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE MOVABLE

	CSEG
	EXTRN	GETRINFO
	EXTRN	PTRCALL

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
	LD	A,(IX+MOV.RINFO)
	OR	(IX+MOV.RINFO+1)
	JR	Z,A.DST

	CALL	HPOINTER		;REMOVE HEIGHT OF CHARACTER IN THE
	LD	A,(IX+MOV.Z)		;ORIGIN
	LD	(HL),A

A.DST:	LD	E,IXL			;SET POINT FIELD TO DESTINE POINT
	LD	D,IXU
	LD	HL,MOV.POINT
	ADD	HL,DE
	EX	DE,HL			;DE = POINT FIELD OF MOVABLE
	LD	BC,MOV.DPOINT
	ADD	HL,BC			;HL = DPOINT FIELD OF MOVABLE
	LD	BC,SIZPOINT
	LDIR

	LD	E,(IX+MOV.LEVEL)	;WE CAN NOT CALL TO SETRINFO
	LD	D,(IX+MOV.LEVEL+1)	;BECAUSE IT UPDATES HEIGTH INFORMATION
	LD	C,(IX+MOV.ROOM)
	LD	B,(IX+MOV.ROOM+1)
	CALL	GETRINFO		;TAKE THE INFORMATION OF THE
	LD	(IX+MOV.RINFO),L	;ROOM WHERE IS LOCATED THE MOVABLE
	LD	(IX+MOV.RINFO+1),H

	LD	L,(IX+MOV.CALLBACK)	;CALL THE CALLBACK FUNCTION IF PRESENT
	LD	H,(IX+MOV.CALLBACK+1)
	LD	A,L
	OR	H
	CALL	NZ,PTRCALL
	CALL	RENDER			;UPDATE RENDER COORDENATES
	LD	E,IXL
	LD	D,IXU
	LD	HL,(CAMERAOP)
	CALL	DCOMPR			;MOVE THE CAMERA IF IT IS THE CAMERA
	CALL	Z,PLACECAM		;OPERATOR
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	E = DIRECTION
;	C = COUNT
;OUTPUT:DE = Y INCREMENT
;	BC = X INCREMENT

	CSEG

ISOINC:	LD	A,E			;THIS FUNCTION RETURNS THE ISOMETRIC
	EX	AF,AF'			;INCREMENT DUE TO A NUMBER OF MINIMAL
	INC	C			;STEPS (2X1) IN A DIRECTION

	XOR	A
	LD	B,C
I.LOOPY:ADD	A,8/NR_STEP
	DEC	B
	JR	NZ,I.LOOPY
	LD	E,A			;E = (8/NR_STEP)*COUNT

	XOR	A
	LD	B,C
I.LOOPX:ADD	A,16/NR_STEP
	DEC	B
	JR	NZ,I.LOOPX
	LD	C,A			;C = (16/NR_STEP)*COUNT

	EX	AF,AF'
I.RIGHT:CP	DRIGHT			;CALCULATE SIGN NOW
	JR	Z,I.SEXP

I.LEFT:	CP	DLEFT
	JR	NZ,I.UP
	LD	A,E
	NEG
	LD	E,A
	LD	A,C
	NEG
	LD	C,A
	JR	I.SEXP

I.UP:	CP	DUP
	JR	NZ,I.DOWN
	LD	A,E
	NEG
	LD	E,A
	JR	I.SEXP

I.DOWN:	LD	A,C
	NEG
	LD	C,A

I.SEXP:	LD	A,E			;ADJUST SIGN
	RLCA
	SBC	A,A
	LD	D,A
	LD	A,C
	RLCA
	SBC	A,A
	LD	B,A
	RET


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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE MOVABLE
;OUTPUT:HL = POINTER TO THE HEIGHT MATRIX
;	Z = 1 WHEN ERROR

	CSEG
	PUBLIC	MOVHMATRIX
	EXTRN	HMATRIX

MOVHMATRIX:
	LD	A,(IX+MOV.Z)
	AND	0FCH
	RRCA
	RRCA
	LD	E,(IX+MOV.RINFO)
	LD	D,(IX+MOV.RINFO+1)
	LD	IYL,E
	LD	IYU,D
	LD	E,(IX+MOV.LEVEL)
	LD	D,(IX+MOV.LEVEL+1)
	LD	C,(IX+MOV.ROOM)
	LD	B,(IX+MOV.ROOM+1)
	LD	L,(IX+MOV.Y)
	LD	H,(IX+MOV.X)
	JP	HMATRIX

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE MOVABLE
;OUTPUT:Z = 1 WHEN ERROR
;       A = HEIGHT VALUE
;	HL = ADDRESS POINTER (0 WHEN IS LOCATED IN ROM)

	CSEG
	PUBLIC	HPOINTER
	EXTRN	GETHEIGHT

HPOINTER:
	LD	A,(IX+MOV.Z)
	AND	0FCH
	RRCA
	RRCA
	LD	(H.AUX),A
H.LOOP:	LD	E,(IX+MOV.RINFO)
	LD	D,(IX+MOV.RINFO+1)
	LD	IYL,E
	LD	IYU,D
	LD	E,(IX+MOV.LEVEL)
	LD	D,(IX+MOV.LEVEL+1)
	LD	C,(IX+MOV.ROOM)
	LD	B,(IX+MOV.ROOM+1)
	LD	L,(IX+MOV.Y)
	LD	H,(IX+MOV.X)
	LD	A,(H.AUX)
	CALL	GETHEIGHT
	RET	Z			;RETURN IF ERROR
	CP	NOHEIGHT
	RET	NZ			;RETURN IF HEIGHT DIFFERENT OF NOHEIGHT
	LD	HL,H.AUX
	XOR	A
	OR	(HL)
	RET	Z			;RETURN IF WE ARE LOOKING IN HEIGHT 0
	DEC	(HL)			;DECREMENT HEIGHT AND TRY AGAIN
	JR	H.LOOP


DHPOINTER:
	LD	A,(IX+MOV.DZ)
	AND	0FCH
	RRCA
	RRCA
	LD	(H.AUX),A
DH.LOOP:LD	E,(IX+MOV.RINFO)
	LD	D,(IX+MOV.RINFO+1)
	LD	IYL,E
	LD	IYU,D
	LD	E,(IX+MOV.DLEVEL)
	LD	D,(IX+MOV.DLEVEL+1)
	LD	C,(IX+MOV.DROOM)
	LD	B,(IX+MOV.DROOM+1)
	LD	A,E
	CP	(IX+MOV.LEVEL)
	JR	NZ,DH.0
	LD	A,D
	CP	(IX+MOV.LEVEL+1)
	JR	NZ,DH.0
	LD	A,C
	CP	(IX+MOV.ROOM)
	JR	NZ,DH.0
	LD	A,B
	CP	(IX+MOV.ROOM+1)
	JR	NZ,DH.0
	JR	DH.1

DH.0:	LD	IY,0
DH.1:	LD	L,(IX+MOV.DY)
	LD	H,(IX+MOV.DX)
	LD	A,(H.AUX)
	CALL	GETHEIGHT
	RET	Z			;RETURN IF ERROR
	CP	NOHEIGHT
	RET	NZ			;RETURN IF HEIGHT DIFFERENT OF NOHEIGHT
	LD	HL,H.AUX
	XOR	A
	OR	(HL)
	RET	Z			;RETURN IF WE ARE LOOKING IN HEIGHT 0
	DEC	(HL)			;DECREMENT HEIGHT AND TRY AGAIN
	JR	DH.LOOP

	DSEG
H.AUX:	DB	0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE MOVABLE

	CSEG
	EXTRN	GETRINFO

SETRINFO:
	LD	E,(IX+MOV.LEVEL)
	LD	D,(IX+MOV.LEVEL+1)
	LD	C,(IX+MOV.ROOM)
	LD	B,(IX+MOV.ROOM+1)
	CALL	GETRINFO		;TAKE THE INFORMATION OF THE
	LD	(IX+MOV.RINFO),L	;ROOM WHERE IS LOCATED THE MOVABLE
	LD	(IX+MOV.RINFO+1),H
	JR	Z,S.DEST		;ROOM
	CALL	HPOINTER		;WE KNOW WE ARE IN A VISIBLE MAP
	LD	(IX+MOV.Z),A
	ADD	A,(IX+MOV.ZSIZ)
	LD	(HL),A
	RET

S.DEST:	XOR	A			;ARE WE IN A ANIMATION?
	CP	(IX+MOV.STEPCNT)
	RET	Z
	LD	C,(IX+MOV.DLEVEL)	;UPDATE THE DESTINATION HEIGTH
	LD	E,(IX+MOV.DROOM)
	LD	D,(IX+MOV.DROOM+1)
	CALL	GETRINFO
	RET	Z			;IS DESTINATION VISIBLE?
	CALL	DHPOINTER		;WE KNOW WE ARE IN A VISIBLE MAP
	LD	(IX+MOV.DZ),A
	ADD	A,(IX+MOV.ZSIZ)
	LD	(HL),A
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

REFRESH:PUSH	IX			;RUN OVER ALL THE MOVABLES AND
	LD	DE,(HEAD+MOV.NEXT)	;RE RENDER THEM. IT IS NECESSARY
	JR	R.ELOOP			;UPDATE THE RINFO FIRST, BECAUSE

R.LOOP:	LD	IXL,E			;WE CAN NOT BE SURE THE LEVEL-ROOM
	LD	IXU,D			;IS NOT CHANGED
	CALL	SETRINFO
	CALL	RENDER
	LD	E,(IX+MOV.NEXT)
	LD	D,(IX+MOV.NEXT+1)

R.ELOOP:LD	HL,HEAD
	CALL	DCOMPR
	JR	NZ,R.LOOP

	POP	IX
	RET

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
	LD	A,(IX+MOV.Z)
	CALL	WRLD2SCR
	LD	(IX+MOV.XR),L
	LD	(IX+MOV.XR+1),H
	LD	(IX+MOV.YR),E
	LD	(IX+MOV.YR+1),D		;INITIALIZE RENDER COORDENATES

	;CONTINUE IN DRAW

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE MOVABLE
;	HL = X POSITION
;	DE = Y POSITION

	CSEG
	EXTRN	PUTMOB

DRAW:	LD	A,(IX+MOV.PAT)		;IS IT A ANIMATE MOVABLE?
	BIT	7,A
	JR	Z,D.END

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
	ADD	A,A			;AND EACH ROW HAS GRAPHICHS FOR ONE
	ADD	A,A			;ANIMATION, SO WE HAVE TO MULTIPLY
	ADD	A,A			;BY 16
	LD	B,A
	LD	A,(IX+MOV.PAT)
	RES	7,A
	ADD	A,B
	ADD	A,(IX+MOV.DIR)

D.END:	LD	B,A
	LD	A,(IX+MOV.Z)
	JP	PUTMOB			;DRAW THE MOVABLE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	RESETCAM

RESETCAM:
	PUSH	IX			;FORCE RESET OF THE CAMERA
	LD	A,-1
	LD	L,A
	LD	H,A
	LD	(LEVEL),A
	LD	(ROOM),HL
	LD	IX,(CAMERAOP)
	CALL	PLACECAM
	POP	IX
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE MOVABLE

	CSEG
	PUBLIC	SETCAMOP
	EXTRN	EDRUN

SETCAMOP:
	LD	E,IXL
	LD	D,IXU
	LD	HL,(CAMERAOP)
	CALL	DCOMPR
	RET	Z			;IT IS THE SAME NO CHANGE

	LD	(CAMERAOP),DE		;UPDATE THE POINTER
	LD	A,(EDRUN)		;IF WE ARE IN THE EDITOR, DON'T FOCUS
	OR	A			;THE CAM
	RET	NZ
	;CONTINUE IN PLACECAM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO CAMERA MOVABLE

	CSEG
	EXTRN	VDPSYNC,DISSCR,ENASCR,FOCUSCAM,DELMOBS

PLACECAM:
	LD	E,(IX+MOV.ROOM)		;CHECK IF THE MOVABLE IS LOCATED
	LD	D,(IX+MOV.ROOM+1)	;IN THE SAME ROOM, BECAUSE IN THIS
	LD	HL,(ROOM)		;CASE IT IS NOT NECESSARY DO
	CALL	DCOMPR			;ANYTHING
	JR	NZ,C.DO
	LD	C,E
	LD	B,D
	LD	E,(IX+MOV.LEVEL)
	LD	D,(IX+MOV.LEVEL+1)
	LD	HL,(LEVEL)
	CALL	DCOMPR
	RET	Z

C.DO:	CALL	DISSCR			;DISABLE SCREEN
	CALL	DELMOBS			;MOBS ARE NOT VALID ANYMORE
	XOR	A			;SET UP ACCESS AND DISPLAY PAGES
	LD	(DPPAGE),A
	INC	A
	LD	(ACPAGE),A
	LD	E,(IX+MOV.LEVEL)
	LD	D,(IX+MOV.LEVEL+1)
	LD	C,(IX+MOV.ROOM)
	LD	B,(IX+MOV.ROOM+1)
	LD	(LEVEL),DE
	LD	(ROOM),BC
	CALL	FOCUSCAM		;MOVE THE CAMERA
	CALL	REFRESH			;REFRESH THE MOVABLES IN THE SCREEN
	CALL	VDPSYNC			;WAIT UNTIL VDP QUEUE IS EMPTY
	CALL	ENASCR			;ENABLE THE SCREEN
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG

CAMERAOP:	DW	0		;CAMERA OPERATOR POINTER
LEVEL:		DW	0		;LEVEL WHERE CAMARA IS POINTING
ROOM:		DW	0		;ROOM WHERE CAMARA IS POINTING
HEAD:		DS	MOV.PREV+2	;HEAD OF MOVABLE OBJECTS
ANIM:		DS	MOV.APREV+2	;HEAD OF ANIMATED MOVABLE


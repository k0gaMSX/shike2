
	INCLUDE	BIOS.INC
	INCLUDE SHIKE2.INC
	INCLUDE	GEOMETRY.INC
	INCLUDE	MOVABLE.INC


MOV.LEVEL	EQU	MOV.POINT+POINT.LEVEL
MOV.ROOM	EQU	MOV.POINT+POINT.ROOM
MOV.Y		EQU	MOV.POINT+POINT.Y
MOV.X		EQU	MOV.POINT+POINT.X
MOV.Z		EQU	MOV.POINT+POINT.Z


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = FUNCTION POINTER

	CSEG
	EXTRN	PTRDE,PTRCALL

FOREACH:PUSH	IX
	LD	(F.FUN),HL
	LD	DE,BUFFER
	LD	B,NR_MOVABLES

F.LOOP:	PUSH	BC
	PUSH	DE
	CALL	PTRDE
	LD	A,E
	OR	D
	JR	Z,F.ELOOP
	LD	IXL,E
	LD	IXU,D
	LD	HL,(F.FUN)
	CALL	PTRCALL

F.ELOOP:POP	DE
	INC	DE
	INC	DE
	POP	BC
	DJNZ	F.LOOP
	POP	IX
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

MOVINIT:LD	HL,BUFFER
	LD	BC,NR_MOVABLES*2
	JP	BZERO

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE MOVABLE

	CSEG
	EXTRN	WRLD2SCR,PUTMOB

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

	LD	C,(IX+MOV.MOB)
	LD	A,-1
	CP	C
	RET	Z			;RETURN IF NOT VALID MOB

	LD	A,(IX+MOV.PAT)		;WE HAVE 4 DIRECTIONS, SO
	ADD	A,A			;EACH PATTERN MEANS MULTIPLY BY 4
	ADD	A,A
	ADD	A,(IX+MOV.DIR)
	LD	B,A
	JP	PUTMOB			;RENDER THE CHARACTER

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: IX = POINTER TO MOVABLE
;	DE = POINTER TO INITIAL POINT
;	C = NUMBER OF PATTERN

	CSEG
	PUBLIC	NEWMOV
	EXTRN	BZERO

NEWMOV:	PUSH	BC
	PUSH	DE

	PUSH	IX
	POP	HL
	LD	BC,MOV.SIZ
	CALL	BZERO			;INITIALIZE TO 0

	POP	HL
	LD	E,IXL
	LD	D,IXU
	INC	DE
	LD	BC,POINT.SIZ
	LDIR				;COPY MOVABLE POINT

	POP	BC
	LD	(IX+MOV.PAT),C
	LD	(IX+MOV.MOB),-1		;IT IS NOT VISIBLE NOW
	LD	HL,BUFFER
	LD	B,NR_MOVABLES

N.LOOP:	LD	A,(HL)
	INC	HL
	OR	(HL)
	JR	Z,N.FOUND
	INC	HL
	DJNZ	N.LOOP
	RET				;NO MOVABLE PLACE FOR A NEW ONE

N.FOUND:LD	E,IXL
	LD	D,IXU
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	CALL	SETRINFO
	JP	RENDER

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;IX = POINTER TO THE MOVABLE

	CSEG
	EXTRN	GETRINFO,ALLOCMOB

SETRINFO:
	LD	C,(IX+MOV.LEVEL)
	LD	E,(IX+MOV.ROOM)
	LD	D,(IX+MOV.ROOM+1)
	CALL	GETRINFO		;TAKE THE INFORMATION OF THE
	LD	(IX+MOV.RINFO),L	;ROOM WHERE IS LOCATED THE MOVABLE
	LD	(IX+MOV.RINFO+1),H
	LD	A,L
	OR	H
	RET	Z

	CALL	ALLOCMOB		;WE ARE IN CAMERA AREA, SO WE NEED
	LD	(IX+MOV.MOB),A		;A MOB.
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = POINTER TO NEW CAMERA MOVABLE

	;CALLED WHEN CAMERA IS MOVED TO OTHER MOVABLE

	CSEG
	PUBLIC	SETCAMERA
	EXTRN	DCOMPR,MOVECAMERA

SETCAMERA:
	LD	HL,(CAMPTR)
	CALL	DCOMPR
	RET	Z			;IT IS THE SAME NO CHANGE

	PUSH	IX
	LD	(CAMPTR),DE		;UPDATE THE POINTER
	LD	IXL,E
	LD	IXU,D
	LD	A,H
	OR	L			;IT IS THE FIRST CALL, CHANGE CAMERA POS
	JR	Z,C.CHG

	PUSH	HL
	POP	IY
	LD	A,(IY+MOV.LEVEL)
	CP	(IX+MOV.LEVEL)
	JR	NZ,C.CHG		;DIFFERENT LEVEL, CHANGE CAMERA POS
	LD	A,(IY+MOV.ROOM)
	CP	(IX+MOV.ROOM)
	JR	NZ,C.CHG		;DIFFERENT YROOM, CHANGE CAMERA POS
	LD	A,(IY+MOV.ROOM+1)
	CP	(IX+MOV.ROOM+1)
	JR	NZ,C.CHG		;DIFFERENT XROOM, CHANGE CAMERA POS
	JR	C.RET			;ROOM AND LEVEL ARE THE SAME, NO CHANGE

C.CHG:	CALL	CHGCAMERA
C.RET:	POP	IX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO CAMERA MOVABLE

	;CALLED WHEN CAMERA IS MOVED FROM ONE ROOM TO ANOTHER

	PUBLIC	CHGCAMERA
	EXTRN	VDPSYNC,DISSCR,ENASCR,MOVECAMARA,TURNON,TURNOFF

CHGCAMERA:
	CALL	DISSCR			;DISABLE SCREEN
	CALL	TURNOFF			;SWITCH OFF THE MOB ENGINE
	LD	HL,HIDEMOV
	CALL	FOREACH			;MOVABLE RENDERS ARE NOT VALID ANYMORE
	LD	C,(IX+MOV.LEVEL)
	LD	E,(IX+MOV.ROOM)
	LD	D,(IX+MOV.ROOM+1)
	CALL	MOVECAMARA		;MOVE THE CAMERA
	CALL	TURNON			;SWITCH ON THE MOB ENGINE
	LD	HL,SETRINFO
	CALL	FOREACH			;UPDATE RINFO INFORMATION IN MOVABLES
	LD	HL,RENDER
	CALL	FOREACH			;RENDER AGAIN ALL THE MOVABLES
	CALL	VDPSYNC			;WAIT TO THE VDP
	CALL	ENASCR			;ENABLE THE SCREEN
	RET

	DSEG
CAMPTR:		DW	0		;MOVABLE POINTER TO ACTUAL CAMERA
BUFFER:		DS	2*NR_MOVABLES	;BUFFER FOR MOVABLE POINTER ARRAY



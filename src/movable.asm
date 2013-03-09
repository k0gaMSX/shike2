
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

	CSEG
	EXTRN	FREEMOB

HIDEMOVS:
	LD	HL,BUFFER
	LD	B,NR_MOVABLES

H.LOOP:	LD	IYL,(HL)
	INC	HL
	LD	IYU,(HL)
	INC	HL
	LD	A,IYL
	OR	IYU
	JR	Z,H.ELOOP
	LD	E,(IY+MOV.MOB)
	CP	-1
	JR	Z,H.ELOOP
	PUSH	BC
	PUSH	HL
	LD	(IY+MOV.MOB),-1
	CALL	FREEMOB
	POP	HL
	POP	BC

H.ELOOP:DJNZ	H.LOOP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	MOVINIT
	EXTRN	BZERO

MOVINIT:LD	HL,BUFFER
	LD	BC,NR_MOVABLES*2
	JP	BZERO

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: IX = POINTER TO MOVABLE
;	HL = POINTER TO INITIAL POINT

	CSEG
	PUBLIC	NEWMOV
	EXTRN	BZERO

NEWMOV:	PUSH	HL
	LD	L,IXL
	LD	H,IXU
	LD	BC,MOV.SIZ
	CALL	BZERO
	POP	HL
	LD	E,IXL
	LD	D,IXU
	LD	BC,POINT.SIZ
	LDIR

	LD	(IX+MOV.MOB),-1		;IT IS NOT VISIBLE NOW
	LD	HL,BUFFER
	LD	B,NR_MOVABLES
N.LOOP:	LD	A,(HL)
	INC	HL
	CP	(HL)
	JR	Z,N.FOUND
	INC	HL
	DJNZ	N.LOOP
	RET				;NO MOVABLE PLACE FOR A NEW ONE

N.FOUND:LD	(HL),IXU
	DEC	HL
	LD	(HL),IXL
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: HL = POINTER TO NEW CAMERA MOVABLE

	CSEG
	PUBLIC	SETCAMERA
	EXTRN	DCOMPR,MOVECAMERA

SETCAMERA:				;CALLED WHEN CAMERA IS MOVED TO OTHER
	LD	DE,(CAMPTR)		;MOVABLE
	CALL	DCOMPR
	RET	Z			;IT IS THE SAME NO CHANGE

	PUSH	IX
	LD	(CAMPTR),HL		;UPDATE THE POINTER
	LD	IXL,L
	LD	IXU,H
	LD	A,E
	OR	D			;IT IS THE FIRST CALL, CHANGE CAMERA POS
	JR	Z,C.CHG

	LD	IYL,E
	LD	IYU,D
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

	PUBLIC	CHGCAMERA
	EXTRN	MOVECAMARA,TURNON,TURNOFF

CHGCAMERA:				;CALLED EACH TIME CAMERA IS MOVED FROM
	CALL	TURNOFF			;ONE ROOM TO ANOTHER
	CALL	HIDEMOVS		;MOVABLE RENDERS ARE NOT VALID ANYMORE
	LD	A,(IX+MOV.LEVEL)
	LD	E,(IX+MOV.ROOM)
	LD	D,(IX+MOV.ROOM+1)
	CALL	MOVECAMARA
	JP	TURNON	


	DSEG
CAMPTR:		DW	0		;MOVABLE POINTER TO ACTUAL CAMERA
BUFFER:		DS	2*NR_MOVABLES	;BUFFER FOR MOVABLE POINTER ARRAY




	INCLUDE	SHIKE2.INC
	INCLUDE	KBD.INC

	INCLUDE	GEOMETRY.INC
	INCLUDE MOVABLE.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	GAME
	EXTRN	CLRSPR,LEVELINIT,MOBINIT,MOVINIT,NEWFRAME
	EXTRN	DISSCR,TURNOFF,NEWMOV,SETCAMERA,GAMELAYERS

GAME:   CALL	DISSCR
	CALL	TURNOFF
	CALL	CLRSPR
	CALL	LEVELINIT
	CALL	MOBINIT
	CALL	MOVINIT
	CALL	GAMELAYERS

	LD	IX,MOV1
	LD	DE,POINT1
	LD	C,0
	LD	B,4
	CALL	NEWMOV

	LD	IX,MOV2
	LD	DE,POINT2
	LD	C,1
	LD	B,4
	CALL	NEWMOV

	LD	DE,MOV1
	CALL	SETCAMERA

G.LOOP: CALL	NEWFRAME
	CALL	GETKEY
	CP	KB_ESC
	JR	NZ,G.LOOP
	RET


POINT1:	DB	0		;LEVEL=0
	DW	0101H		;ROOM=0
	DB	15,0,0		;Y=X=Z=0

POINT2:	DB	0		;LEVEL=0
	DW	0202H		;ROOM=0
	DB	0,0,0		;Y=15,X=Z=0

	DSEG
MOV1:	DS	MOV.SIZ		;TODO: TEMPORAL BUFFER
MOV2:	DS	MOV.SIZ		;TODO: TEMPORAL BUFFER

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	KBHIT,CHGCAMERA,FUNKEYS

GETKEY:	CALL	KBHIT
	RET	Z

	CALL	FUNKEYS
	RET	Z

	PUSH	AF
	LD	IX,MOV1
	CALL	CHGCAMERA
	POP	AF
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	ENGINE

ENGINE:	RET


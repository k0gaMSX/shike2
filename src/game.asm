
	INCLUDE	SHIKE2.INC
	INCLUDE	KBD.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	GAME
	EXTRN	CLRSPR,MOBINIT,MOVINIT,NEWFRAME
	EXTRN	KBHIT,NEWMOV,SETCAMERA

GAME:   CALL	CLRSPR
	CALL	MOBINIT
	CALL	MOVINIT
	LD	IX,MOV
	LD	HL,POINT
	CALL	NEWMOV
	CALL	SETCAMERA

G.LOOP: CALL	NEWFRAME
	CALL	KBHIT
	CP	KB_ESC
	JR	NZ,G.LOOP
	RET


POINT:	DB	0		;LEVEL=0
	DW	0		;ROOM=0
	DB	0,0,0		;X=Y=Z=0

	DSEG
MOV:	DS	50		;TODO: TEMPORAL BUFFER

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	ENGINE

ENGINE:	RET


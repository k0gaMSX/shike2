
	INCLUDE	SHIKE2.INC
	INCLUDE	KBD.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	GAME
	EXTRN	CLRSPR,INITMOB,NEWFRAME
	EXTRN	KBHIT,NEWMOVABLE,SETCAMERA

GAME:   CALL	CLRSPR
	CALL	INITMOB
	LD	IX,MOV
	LD	HL,POINT
	CALL	NEWMOVABLE
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
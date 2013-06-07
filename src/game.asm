

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	GAME
	EXTRN	LEVELINIT,MOBINIT,MOVINIT,CHARINIT,TALKINIT,DOORINIT
	EXTRN	NEWFRAME,CAMDAT,GETNCHAR,SETCAMOP

GAME:	CALL	MOBINIT
	CALL	MOVINIT
	CALL	TALKINIT
	CALL	LEVELINIT
	CALL	CHARINIT
	CALL	DOORINIT

	LD	A,(CAMDAT)
	CP	-1
	JR	Z,G.LOOP
	LD	E,A
	CALL	GETNCHAR
	PUSH	HL
	POP	IX
	CALL	SETCAMOP

G.LOOP:	CALL	NEWFRAME
	LD	A,(FINISH)
	OR	A
	JR	Z,G.LOOP

	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	PUBLIC	ENGINE
	EXTRN	THINK,ANIMATE

ENGINE:	CALL	THINK
	CALL	ANIMATE
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
	PUBLIC	FINISH,EDRUN

FINISH:	DB	0
EDRUN:	DB	0


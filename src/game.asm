

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	GAME
	EXTRN	LEVELINIT,MOBINIT,MOVINIT,CHARINIT,TALKINIT,DOORINIT
	EXTRN	NEWFRAME

GAME:	CALL	MOBINIT
	CALL	MOVINIT
	CALL	TALKINIT
	CALL	LEVELINIT
	CALL	CHARINIT
	CALL	DOORINIT

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
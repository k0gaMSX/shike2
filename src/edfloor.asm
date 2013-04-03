
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	PUBLIC	EDFLOOR
	EXTRN	GLINES,EDINIT,MPRESS,VDPSYNC

EDFLOOR:CALL	EDINIT
	LD	DE,FLOORG
	LD	C,15
	CALL	GLINES

ED.LOOP:CALL	VDPSYNC
	CALL	MPRESS
	CP	2
	JR	NZ,ED.LOOP
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	       REP  X0  Y0    X1  Y1 IX0 IY0 IX1 IY1
FLOORG:	DB	3,  80, 80,  112, 80,  0,  8,  0,  8
	DB	3,  80, 80,   80, 96, 16,  0, 16,  0
	DB	0

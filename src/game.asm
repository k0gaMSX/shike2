
	INCLUDE	BIOS.INC
	INCLUDE	DATA.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	GAME
	EXTRN	LEVELINIT,MOBINIT,MOVINIT,EDITOR
	EXTRN	SETPAGE,NEWFRAME,KBHIT,MOVABLE

	INCLUDE	EVENT.INC

GAME:	CALL	MOBINIT
	CALL	MOVINIT
	CALL	LEVELINIT
	CALL	EDITOR

	EXTRN	EDLEVEL,EDROOM,FOCUSCAM,PLACE

	XOR	A
	LD	(DPPAGE),A
	INC	A
	LD	(ACPAGE),A
	CALL	SETPAGE

	LD	DE,(EDLEVEL)
	LD	BC,(EDROOM)
	LD	(P1+POINT.LEVEL),DE
	LD	(P1+POINT.ROOM),BC
	CALL	FOCUSCAM

	LD	IX,MOV1
	CALL	MOVABLE
 	LD	DE,P1
	LD	C,0
	CALL	PLACE

G.LOOP:	CALL	NEWFRAME
	CALL	KBHIT
	CP	KB_ESC
	JR	NZ,G.LOOP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	PUBLIC	ENGINE

ENGINE:	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
MOV1:	DS	SIZMOV
P1:	DW	0,0
	DB	0,0,0


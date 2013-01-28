
	INCLUDE	SHIKE2.INC
	INCLUDE BIOS.INC
	INCLUDE KBD.INC

	CSEG
	PUBLIC	GAME
	EXTRN	HMMM,VDPPAGE,GETCHAR,NEWFRAME,SETPAGE,INITMOB,VDPSYNC,PUTMOB

TIL2PAGE:
	LD	(ACPAGE),A
	LD	HL,0
	LD	DE,0
	LD	BC,0FFD8H
	LD	A,TILPAGE
	LD	(VDPPAGE),A
	JP	HMMM		;COPY TILPAGE TO TILPAGE + 1

GAME:	LD	A,TILPAGE+1
	CALL	TIL2PAGE
	LD	A,BAKPAGE
	CALL	TIL2PAGE
	CALL	INITMOB

	LD	A,TILPAGE
	LD	(DPPAGE),A
	INC	A
	LD	(ACPAGE),A
	CALL	VDPSYNC
	CALL	SETPAGE



G.LOOP: CALL	NEWFRAME

	LD	HL,(VAR)
	INC	HL
	LD	(VAR),HL
	LD	DE,50
	LD	B,0
	LD	C,0
	CALL	PUTMOB

	CALL	GETCHAR
	CP	KB_ESC
	RET	Z
	JR	G.LOOP

VAR:	DW	23

	PUBLIC	ENGINE

ENGINE:	RET

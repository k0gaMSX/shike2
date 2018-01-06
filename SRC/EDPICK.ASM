	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	EVENT.INC
	

	CSEG
	PUBLIC	ED.PICK
	EXTRN	EDINIT,LMMM,VDPSYNC,LISTEN


ED.PICK:CALL	EDINIT

	LD	HL,0
	LD	(PATERN),A

	LD	A,LOGIMP
	LD	(LOGOP),A
	LD	A,PATPAGE
	LD	(VDPPAGE),A

	LD	HL,0
	LD	DE,0
	LD	BC,0080H
	CALL	LMMM
	CALL	VDPSYNC

ED.LOOP:LD	DE,RECEIVERS
	CALL	LISTEN
	RET	Z

	LD	HL,(PATERN)
	LD	A,H
	OR	A
	JR	Z,ED.LOOP
	LD	A,L
	RET

RECEIVERS:
	DB	1,254,1,128
	DW	PATSEL
	DB	0
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: A  = EVENT
;       DE = SCREEN COORDINATES

	CSEG
	EXTRN	CLRVPAGE,LMMM,VDPPAGE

PATSEL:	CP	MS_BUTTON1
	RET	NZ

	LD	A,D
	RRCA
	RRCA
	RRCA
	RRCA
	AND	0FH
	LD	D,A

	LD	A,E
	AND	078H
	RLCA
	ADD	A,D
	LD	H,1
	LD	L,A
	LD	(PATERN),HL
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DSEG
PATERN:	DW	0

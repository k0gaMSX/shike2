	INCLUDE	SHIKE2.INC
	INCLUDE	BIOS.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	MAIN
	EXTRN	BZERO,SETISR,CHKMSX,INITVDP,KBDCLR,INITMOUSE,GAME

MAIN:	LD	HL,DATASEG
	LD	BC,DATASIZ
	CALL	BZERO		;CLEAR THE DATA SEGMENT

	LD	HL,0
	ADD	HL,SP
	LD	(E.RET),HL

	CALL	CHKMSX
	RET	Z		;THIS MSX HAS SOME PROBLEM FOR US

	CALL	INITVDP
	CALL	INITMOUSE
	CALL	SETISR		;SET GAME ISR
	CALL	KBDCLR		;CLEAR KEYBOARD BUFFER

	CALL	GAME
	;CONTINUE IN EXIT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	EXIT
	EXTRN	RESISR

EXIT:	CALL	RESISR		;RESTORE SYSTEM ISR
	EI
	XOR	A
	CALL	CHGMOD
	CALL	KILBUF
	LD	SP,(E.RET)
	RET

	DSEG
E.RET:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	ERRSTR

ERRSTR:	DW	0


	INCLUDE	SHIKE2.INC
	INCLUDE	BIOS.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	MAIN
	EXTRN	BZERO,SETISR,CHKMSX,INITVDP,EDLEVEL,EDMAPPER,EDHEIGTH,GAME
MAIN:

	.PHASE	100H
.RELOC:
	LD	HL,.RELOC
        LD	DE,CODESEG
	LD	BC,CODESIZ
	LDIR
	JP	.CONT
	.DEPHASE

.CONT:
	LD	HL,DATASEG
	LD	BC,DATASIZ
	CALL	BZERO		;CLEAR THE DATA SEGMENT

	CALL	CHKMSX
	RET	Z		;THIS MSX HAS SOME PROBLEM FOR US

	CALL	INITVDP
	CALL	SETISR		;SET GAME ISR
	CALL	EDLEVEL
	CALL	EDMAPPER
	CALL	EDHEIGTH
	CALL	GAME
	;CONTINUE IN EXIT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	EXIT
	EXTRN	RESISR,MSXTERM

EXIT:	CALL	RESISR		;RESTORE SYSTEM ISR
	EI
	XOR	A
	CALL	CHGMOD
	JP	MSXTERM



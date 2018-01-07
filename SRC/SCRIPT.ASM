
	INCLUDE	SHIKE2.INC
	INCLUDE	DATA.INC

STOP	EQU	00H
RDVAR	EQU	01H
WRAR	EQU	02H
CONST	EQU	03H
ADD	EQU	04H
SUB	EQU	05H
EQ	EQU	06H
NE	EQU	07
LT	EQU	08H
LE	EQU	09H
GT	EQU	0AH
GE	EQU	0BH
GOTO	EQU	0CH
GOTOZ	EQU	0DH
GOTONZ	EQU	0EH

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	CSEG


INSTBL:	DW	STOPFN		; 00
	DW	RD.VARFN	; 01
	DW	WR.VARFN	; 02
	DW	CONSTFN		; 03
	DW	ADDFN		; 04
	DW	SUBFN		; 05
	DW	EQFN		; 06
	DW	NEFN		; 07
	DW	LTFN		; 08
	DW	LEFN		; 09
	DW	GTFN		; 0A
	DW	GEFN		; 0B
	DW	GOTOFN		; 0C
	DW	GOTO.ZFN      	; 0D
	DW	GOTO.NZFN	; 0E

VARTBL:	DS	1

SCRIPTBL:
	DW	SCRIPT1

SCRIPT1:
	DB	STOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: IX = POINTER TO CHAR

	CSEG
	PUBLIC	EXEC
	EXTRN	ADDAHL,ARYHL

NEXTOP:	LD	A,(IX+CHAR.SCRIPT)	;TAKE CHAR SCRIPT
	LD	HL,SCRIPTBL
	CALL	ARYHL
	LD	A,(IX+CHAR.PC)
	INC	(IX+CHAR.PC)		;TAKE NEXT BYTE
	CALL	ADDAHL
	LD	A,(HL)
	RET

EXEC:	CALL	NEXTOP			;TAKE NEXT OPCODE
	LD	HL,INSTBL
	CALL	ARYHL
	JP	(HL)			;EXECUTE IT


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR
;       A  = VALUE TO BE PUSHED

	CSEG
	EXTRN	ADDAHL

PUSHVAL:LD	E,IXL
	LD	D,IXU
	LD	HL,CHAR.STACK
	ADD	HL,DE
	LD	E,A
	LD	A,(IX+CHAR.SP)
	INC	(IX+CHAR.SP)
	CALL	ADDAHL
	LD	(HL),E
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR
;OUTPUT:A  = POPED VALUE

	CSEG
	EXTRN	ADDAHL

POPVAL:	LD	E,IXL
	LD	H,IXU
	LD	HL,CHAR.STACK
	ADD	HL,DE
	DEC	(IX+CHAR.SP)
	LD	A,(IX+CHAR.SP)
	CALL	ADDAHL
	LD	A,(HL)
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR

	CSEG

STOPFN:RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR
;OUTPUT:HL = ADDRESS OF VARIABLE INDICATED BY NEXT OPCODE

	CSEG

	EXTRN	ARYHL

VARFN:	CALL	NEXTOP
	LD	HL,VARTBL
	CALL	ADDAHL
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR

	CSEG

RD.VARFN:
	CALL	VARFN
	LD	A,(HL)
	JP	PUSHVAL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR

	CSEG

WR.VARFN:
	CALL	VARFN
	PUSH	HL
	CALL	POPVAL
	POP	HL
	LD	(HL),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR

	CSEG

CONSTFN:CALL	NEXTOP
	JP	PUSHVAL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR

	CSEG

ADDFN:	CALL	POPVAL
	PUSH	AF
	CALL	POPVAL
	POP	HL
	ADD	A,H
	JP	PUSHVAL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR

	CSEG

SUBFN:	CALL	POPVAL
	PUSH	AF
	CALL	POPVAL
	POP	HL
	SUB	H
	JP	PUSHVAL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR

	CSEG

EQFN:	CALL	POPVAL
	PUSH	AF
	CALL	POPVAL
	POP	HL
	CP	H
	LD	A,0
	JR	Z,EQ.1
	LD	A,1
EQ.1:	JP	PUSHVAL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR

	CSEG

NEFN:	CALL	POPVAL
	PUSH	AF
	CALL	POPVAL
	POP	HL
	CP	H
	LD	A,0
	JR	NZ,NE.1
	LD	A,1
NE.1:	JP	PUSHVAL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR

	CSEG

LTFN:	CALL	POPVAL
	PUSH	AF
	CALL	POPVAL
	POP	HL
	CP	H
	LD	A,0
	JR	Z,LT.1
	JR	C,LT.1
	LD	A,1
LT.1:	JP	PUSHVAL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR

	CSEG

LEFN:	CALL	POPVAL
	PUSH	AF
	CALL	POPVAL
	POP	HL
	CP	H
	LD	A,1
	JR	NC,LE.1
	LD	A,0
LE.1:	JP	PUSHVAL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR

	CSEG

GTFN:	CALL	POPVAL
	PUSH	AF
	CALL	POPVAL
	POP	HL
	CP	H
	LD	A,1
	JR	C,GT.1
	LD	A,0
GT.1:	JP	PUSHVAL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR

	CSEG

GEFN:	CALL	POPVAL
	PUSH	AF
	CALL	POPVAL
	POP	HL
	CP	H
	LD	A,1
	JR	Z,GE.1
	JR	C,GE.1
	LD	A,0
GE.1:	JP	PUSHVAL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR

	CSEG

GOTOFN:	CALL	NEXTOP
	LD	(IX+CHAR.PC),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR

	CSEG

GOTO.ZFN:CALL	POPVAL
	OR	A
	JR	Z,GOTOFN
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR

	CSEG

GOTO.NZFN:
	CALL	POPVAL
	OR	A
	JR	NZ,GOTOFN
	RET



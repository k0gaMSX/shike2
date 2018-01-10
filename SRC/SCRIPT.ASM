
	INCLUDE	SHIKE2.INC
	INCLUDE	DATA.INC

ISTOP	EQU	00H
IRDVAR	EQU	01H
IWRAR	EQU	02H
ICONST	EQU	03H
IADD	EQU	04H
ISUB	EQU	05H
IEQ	EQU	06H
INE	EQU	07
ILT	EQU	08H
ILE	EQU	09H
IGT	EQU	0AH
IGE	EQU	0BH
IGOTO	EQU	0CH
IGOTOZ	EQU	0DH
IGOTON	EQU	0EH
IUSER	EQU	0FH
IFOLLOW	EQU	10H

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
	DW	GOTO.NFN	; 0E
	DW	USERFN		; 0F
	DW	FOLLOWFN	; 10

VARTBL:	DS	1

SCRIPTBL:
	DW	SCRIPT0
	DW	SCRIPT1
	DW	SCRIPT2

SCRIPTNM:
	DW	S.1
	DW	S.2
	DW	S.3

S.1:	DB	"STOP",0
S.2:	DB	"USER",0
S.3:	DB	"FOLLOW",0

SCRIPT0:DB	ISTOP
SCRIPT1:DB	IUSER
SCRIPT2:DB	IFOLLOW

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: E = SCRIPT NUMBER
;OUTPUT:HL= SCRIPT NAME

	CSEG
	PUBLIC	SCRNAME
	EXTRN	ARYHL

SCRNAME:	LD	A,E
	LD	HL,SCRIPTNM
	JP	ARYHL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: IX = POINTER TO CHAR

	CSEG
	PUBLIC	GETICACHE
	EXTRN	ADDAHL,ARYHL

GETICACHE:
	LD	A,(IX+CHAR.SCRIPT)	;RETURN A POINTER TO
	LD	HL,SCRIPTBL		;THE CURRENT SEQUENCE OF INS
	CALL	ARYHL			;OF COURSE, ICACHE COMES FROM
	LD	A,(IX+CHAR.PC)		;INSTRUCTION CACHE
	JP	ADDAHL

NEXTOP:	CALL	GETICACHE
	INC	(IX+CHAR.PC)
	LD	A,(HL)
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: IX = POINTER TO CHAR

	CSEG
	PUBLIC	EXEC
	EXTRN	ARYHL

EXEC:	LD	HL,0
	ADD	HL,SP
	LD	(OLDSP),HL
	CALL	NEXTOP			;TAKE NEXT OPCODE
	LD	HL,INSTBL
	CALL	ARYHL
	JP	(HL)			;EXECUTE IT


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

YIELD:	LD	HL,(OLDSP)
	LD	SP,HL
	RET

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
	EXTRN	DUMMY

STOPFN:
	DEC	(IX+CHAR.PC)
	CALL	DUMMY
	JP	YIELD

	CSEG
	EXTRN	USER

USERFN:	LD	HL,(.UFUN)
	LD	(IX+CHAR.CONTROL),L
	LD	(IX+CHAR.CONTROL+1),H
	JP	YIELD

.UFUN:	DW	USER

	CSEG
	EXTRN	FOLLOW

FOLLOWFN:
	LD	HL,(.FFUN)
	LD	(IX+CHAR.CONTROL),L
	LD	(IX+CHAR.CONTROL),H
	JP	YIELD

.FFUN:	DW	FOLLOW

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

GOTO.NFN:
	CALL	POPVAL
	OR	A
	JR	NZ,GOTOFN
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DSEG
OLDSP:	DW	0



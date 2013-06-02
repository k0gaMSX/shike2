
	INCLUDE	SPRITE.INC
	INCLUDE	DATA.INC

GLOBEPAT	EQU	TALKPAT
WHITEPAT	EQU	TALKPAT+16

GLOBESPR	EQU	TALKSPR
WHITESPR	EQU	TALKSPR+4

TIMECNT		EQU	15


	CSEG
	PUBLIC	TALKINIT
	EXTRN	SPRITE,SETCOLSPR

TALKINIT:
	LD	C,WHITEPAT
	LD	DE,WHITE
	LD	B,4
	CALL	SPRITE

	LD	C,GLOBESPR
	LD	E,1
	LD	B,4
	CALL	SETCOLSPR

	LD	C,WHITESPR
	LD	E,15
	LD	B,4
	JP	SETCOLSPR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHARACTER
;	DE = STRING POINTER
;	BC = CALLBACK FUNCTION
;OUTPUT: Z = 1 WHEN THERE IS SOME ERROR

	CSEG
	PUBLIC	TELL

TELL:	LD	A,(TIME)
	OR	A
	JR	Z,T.1
	XOR	A
	RET

T.1:	LD	(CALBACK),BC
	LD	(TELLER),IX
	DEC	DE
	LD	(STRING),DE
	LD	A,1
	LD	(TIME),A
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	(STRING) = STRING
;	(TELLER) = SCREEN LOCATION
;	(TIME) = TIME OF THE TALK
;	(CALBACK) = CALLBACK FUNCTION

	CSEG
	PUBLIC	TALKHOOK
	EXTRN	STRLEN,PTRCAL


TALKHOOK:
	LD	A,(TIME)		;TIME = 0 => NO TALK, RETURN
	OR	A
	RET	Z

	DEC	A
	LD	(TIME),A
	JP	NZ,PUTTALK		;--TIME != 0 => UPDATE COORDENATES

T.NEXT:	LD	DE,(STRING)		;--TIME = 0 => NEXT CHARACTER
	INC	DE
	LD	(STRING),DE
	CALL	STRLEN			;TAKE THE LENGTH OF THE STRING
	OR	A
	JR	NZ,T.BODY
	CALL	HIDETALK		;HIDE TALK WHEN STRING IS EMPTY
	LD	IX,(TELLER)
	LD	HL,(CALBACK)
	LD	A,L
	OR	H
	CALL	NZ,PTRCAL
	RET

T.BODY:	CP	14
	JR	C,T.COPY
	LD	A,14

T.COPY:	LD	HL,(STRING)		;COPY PARTIAL STRING TO BUFFER
	LD	DE,T.BUF
	LD	C,A
	LD	B,0
	LDIR
	XOR	A
	LD	(DE),A
	LD	A,TIMECNT
	LD	(TIME),A

	LD	DE,T.BUF
	CALL	DEFTALK			;DEFINE SPRITE
	LD	DE,TALKBUF
	LD	C,GLOBEPAT
	LD	B,4
	CALL	SPRITE			;COPY TO VRAM THE NEW SPRITE
	JP	PUTTALK

	DSEG
T.BUF:	DS	15
T.PTR:	DW	0
T.POS:	DW	0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = POINTER TO STRING

	CSEG
	EXTRN	ADDAHL

DEFTALK:PUSH	DE			;SAVE STRING POINTER
	LD	HL,GLOBE		;COPY EMPTY GLOBE TO BUFFER
	LD	DE,TALKBUF
	LD	BC,4*32
	LDIR
	LD	HL,TALKBUF+4
	LD	(D.PTR),HL

D.LOOP:	POP	DE			;RECOVER STRING POINTER
	LD	A,(DE)			;NEXT CHARACTER, CHECK END OF STRING
	OR	A
	RET	Z

	INC	DE
	PUSH	DE			;SAVE STRING POINTER
	SUB	' '			;FONTS BEGIN IN SPACE
	LD	L,A
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	DE,FONTSPR
	ADD	HL,DE
	EX	DE,HL
	LD	HL,(D.PTR)
	LD	B,8

D.LOOP1:LD	A,(DE)			;COPY THE FONT GRAPHIC
	OR	(HL)
	LD	(HL),A
	INC	HL
	INC	DE
	DJNZ	D.LOOP1
	LD	A,8			;INCREMENT POINTER TO NEXT
	CALL	ADDAHL			;POSITION
	LD	(D.PTR),HL

	POP	DE			;RECOVER STRING POINTER
	LD	A,(DE)			;NEXT CHARACTER, CHECK END OF STRING
	OR	A
	RET	Z

	INC	DE
	PUSH	DE			;SAVE STRING POINTER
	SUB	' '			;FONTS BEGIN IN SPACE
	LD	L,A
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	DE,FONTSPR
	ADD	HL,DE
	EX	DE,HL
	LD	HL,(D.PTR)
	LD	B,8

D.LOOP2:LD	A,(DE)			;COPY THE GRAPHIC FONT, SHIFTED
	RLCA
	RLCA
	RLCA
	RLCA
	OR	(HL)
	LD	(HL),A
	INC	HL
	INC	DE
	DJNZ	D.LOOP2
	JR	D.LOOP

	DSEG
D.PTR:	DW	0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	HIDESPRITE

HIDETALK:
	LD	B,8
	LD	C,TALKSPR
H.LOOP:	PUSH	BC
	CALL	HIDESPRITE
	POP	BC
	INC	C
	DJNZ	H.LOOP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	(TELLER) = CHARACTER POINTER


	CSEG
	EXTRN	PUTSPRITE

PUTTALK:LD	IY,(TELLER)
	LD	A,(IX+MOB.YD)
	SUB	16
	LD	E,A
	LD	A,(IX+MOB.XD)
	ADD	A,8
	LD	D,A

	LD	HL,P.DATA
	LD	C,GLOBESPR
	LD	B,GLOBEPAT

P.LOOP:	PUSH	HL
	PUSH	BC
	PUSH	DE
	LD	A,(HL)
	ADD	A,D
	LD	D,A
	CALL	PUTSPRITE
	POP	DE
	POP	BC
	POP	HL
	INC	HL
	LD	A,(HL)
	CP	-1
	RET	Z
	INC	C
	LD	A,B
	ADD	A,4
	LD	B,A
	JR	P.LOOP

P.DATA:	DB	0,16,32,48,0,16,32,48,-1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

GLOBE:	DB	01FH,020H,040H,080H,080H,080H,080H,080H
	DB	080H,080H,080H,080H,080H,080H,0BFH,0C0H
	DB	0FFH,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,0FFH,000H

	DB	0FFH,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,0FFH,000H
	DB	0FFH,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,0FFH,000H

	DB	0FFH,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,0FFH,000H
	DB	0FFH,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,0FFH,000H

     	DB 	0FFH,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,0FFH,000H
	DB	0F8H,004H,002H,001H,001H,001H,001H,001H
	DB	001H,001H,001H,001H,002H,004H,0F8H,000H


WHITE:	DB	000H,03FH,07FH,0FFH,0FFH,0FFH,0FFH,0FFH
	DB	0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,000H
	DB	0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH
	DB	0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,000H

	DB	0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH
	DB	0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,000H
	DB	0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH
	DB	0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,000H

	DB	0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH
	DB	0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,000H
	DB	0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH
	DB	0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,000H

	DB	0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH
	DB	0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,000H
	DB	0F8H,0FCH,0FEH,0FFH,0FFH,0FFH,0FFH,0FFH
	DB	0FFH,0FFH,0FFH,0FFH,0FEH,0FCH,0F8H,000H

	INCLUDE	FONTSPR.ASM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DSEG

STRING:	DW	0
TELLER:	DW	0
CALBACK:DW	0
TIME:	DB	0
TALKBUF:DS	32*4


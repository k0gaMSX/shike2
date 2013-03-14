	INCLUDE SHIKE2.INC
	INCLUDE	BIOS.INC


OFFSET		EQU	128		;OFFSET INTO MOB PAGE WHERE ARE
					;LOCATED THE MOB PATTERNS

;A MOB (MOVABLE OBJECT BLOCK) IS EQUIVALENT TO SOFTWARE SPRITES

MOB.YD		EQU	0	;Y COORDENATE IN DISPLAY PAGE (DPPAGE)
MOB.XD		EQU	1	;X COORDENATE IN DISPLAY PAGE (DPPAGE)
MOB.YDSIZ	EQU	2	;Y SIZE IN DISPLAY PAGE (DPPAGE)
MOB.XDSIZ	EQU	3	;X SIZE IN DISPLAY PAGE (DPPAGE)

MOB.YE		EQU	4	;Y COORDENATE FOR ERASING
MOB.XE		EQU	5	;X COORDENATE FOR ERASING
MOB.YESIZ	EQU	6	;Y SIZE FOR ERASING
MOB.XESIZ	EQU	7	;X SIZE FOR ERASING

MOB.Y		EQU	8	;Y COORDENATE IN LAST CALL TO PUTMOB
MOB.X		EQU	9	;X COORDENATE IN LAST CALL TO PUTMOB
MOB.YSIZ	EQU	10	;Y SIZE IN LAST CALL TO PUTMOB
MOB.XSIZ	EQU	11	;X SIZE IN LAST CALL TO PUTMOB

MOB.YO		EQU	12	;Y COORDENATE OF THE GRAPHIC ORIGIN
MOB.XO		EQU	13	;X COORDENATE OF THE GRAPHIC ORIGIN
MOB.SIZ		EQU	14


MOBXSIZ		EQU	16
MOBYSIZ		EQU	32

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = FUNCTION POINTER

	CSEG
	EXTRN	PTRCALL

FOREACH:LD	IX,BUFFER
	LD	B,NR_MOBS

F.LOOP:	PUSH	BC
	PUSH	HL
	CALL	PTRCALL
	POP	HL
	POP	BC

	LD	DE,MOB.SIZ
	ADD	IX,DE
	DJNZ	F.LOOP
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = X DESTINE
;	DE = Y DESTINE
;	B = PATTERN
;	C = MOB NUMBER
;

	CSEG
	PUBLIC	PUTMOB

PUTMOB:	PUSH	IX
	LD	A,C
	LD	(M.MOB),A

	PUSH	DE			;ADJUST COORDENATES, BECAUSE
	LD	DE,-8			;WRLD2SCR RETURNS THE CENTER OF TILE
	ADD	HL,DE
	LD	(CLIP.X),HL

	POP	HL
	LD	DE,-MOBYSIZ+4
	ADD	HL,DE
	LD	(CLIP.Y),HL

	LD	A,MOBXSIZ
	LD	(CLIP.XSIZ),A
	LD	A,MOBYSIZ
	LD	(CLIP.YSIZ),A

	LD	A,B
	AND	0F0H
	RLCA
	ADD	A,OFFSET
	LD	(CLIP.YO),A
	LD	A,B
	AND	0FH
	RLCA
	RLCA
	RLCA
	RLCA
	LD	(CLIP.XO),A
	CALL	CLIP
	JR	Z,M.NVIS

	LD	A,(CLIP.X)
	LD	D,A
	LD	A,(CLIP.Y)
	LD	E,A
	LD	A,(CLIP.XO)
	LD	H,A
	LD	A,(CLIP.YO)
	LD	L,A
	LD	A,(CLIP.XSIZ)
	LD	B,A
	LD	A,(CLIP.YSIZ)
	LD	C,A
	LD	A,(M.MOB)
	CALL	MOB
	POP	IX
	LD	A,1
	OR	A
	RET

M.NVIS:	LD	E,255
	LD	A,(M.MOB)
	CALL	MOB
	XOR	A
	RET

	DSEG

M.MOB:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT/OUTPUT:	CLIP.X = X BEFORE/AFTER CLIPPING
;		CLIP.Y = Y BEFORE/AFTER CLIPPING
;		CLIP.XSIZ = X SIZE BEFORE/AFTER CLIPPING
;		CLIP.XO = ORIGIN X BEFORE/AFTER CLIPPING
;		CLIP.YSIZ = Y SIZE BEFORE/AFTER CLIPPING
;		CLIP.YO = ORIGIN Y BEFORE/AFTER CLIPPING

	CSEG

CLIP:	LD	DE,(CLIP.X)
	LD	BC,(CLIP.XSIZ)
	LD	HL,NR_SCRCOL*16
	CALL	CLIP1
	RET	Z
	LD	(CLIP.X),DE
	LD	(CLIP.XSIZ),BC

	LD	DE,(CLIP.Y)
	LD	BC,(CLIP.YSIZ)
	LD	HL,NR_SCRROW*8
	CALL	CLIP1
	LD	(CLIP.Y),DE
	LD	(CLIP.YSIZ),BC
	RET

	DSEG
CLIP.X:		DW	0
CLIP.Y:		DW	0
CLIP.XSIZ:	DB	0
CLIP.XO:	DB	0
CLIP.YSIZ:	DB	0
CLIP.YO:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: C = SIZE     (16 <= C <= 64)
;	B = ORIGIN
;	DE = DESTINE (-255 <= DE <= 512)
;	HL = MAXIMUM VALUE
;OUTPUT:E = DESTINE (0 <= E <= 255)
;       B = ORIGIN
;       C = SIZE

	CSEG

CLIP1:	LD	(C.MAX),HL
	LD	L,C
	LD	H,0
	ADD	HL,DE		;HL = DESTINE + SIZE
	JP	M,C.NOVIS	;RESULT IS A NEGATIVE NUMBER
	JR	C,C.LEFT	;DE WAS < 0 AND THE RESULT IS >= 0

	PUSH	DE
	LD	DE,(C.MAX)
	OR	A
	SBC	HL,DE
	POP	DE
	JR	C,C.VIS		;DE WAS >= 0 AND THE RESULT IS < (C.MAX)
	JR	C.RIGTH		;DE WAS >= 0 AND THE RESULT IS >= (C.MAX)

C.LEFT:	LD	A,L
	OR	H
	JR	Z,C.NOVIS	;HL = 0 -> DE + SIZE = 0
	LD	E,0		;DESTINE=0
	LD	A,C
	SUB	L		;A = SIZE - VISIBLE PART
	ADD	A,B		;A = ORIGIN + NON VISIBLE PART
	LD	B,A
	LD	C,L		;C = VISIBLE PART
	JR	C.VIS

C.RIGTH:LD	A,C
	SUB	L
	JR	Z,C.NOVIS	;L == SIZE MEANS DE WAS = 255
	JR	C,C.NOVIS	;L > SIZE MEANS DE WAS > 255
C.RGTH1:LD	C,A		;C = SIZE - NON VISIBLE PART
	JR	C.VIS

C.VIS:	LD	A,1
	OR	A
	RET

C.NOVIS:XOR	A
	RET

	DSEG
C.MAX:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: E = MOB NUMBER
;OUTPUT:IX = MOB ADDRESS

	CSEG

MOBADDR:EX	DE,HL
	LD	H,0			;CALCULATE MOB ADDRESS
	ADD	HL,HL			;HL = E*2
	PUSH	HL
	ADD	HL,HL			;HL = E*4
	PUSH	HL
	ADD	HL,HL			;HL = E*8
	POP	DE
	ADD	HL,DE			;HL = E*8 + E*4
	POP	DE
	ADD	HL,DE			;HL = E*8 + E*4 +E*2
	EX	DE,HL
	LD	IX,BUFFER
	ADD	IX,DE
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	D = X
;	E = Y
;	H = XO
;	L = YO
;	B = X SIZE
;	C = Y SIZE
;	A = MOB NUMBER

	CSEG
	EXTRN	VDPEND

MOB:	EXX
	LD	E,A
	CALL	MOBADDR			;IX = MOB ADDRESS
	EXX

	LD	(IX+MOB.Y),E		;STORE Y COORDENATE
	LD	(IX+MOB.X),D		;STORE X COORDENATE
	LD	(IX+MOB.YO),L		;STORE YO
	LD	(IX+MOB.XO),H		;STORE XO
	LD	(IX+MOB.YSIZ),C		;STORE Y SIZE
	LD	(IX+MOB.XSIZ),B		;STORE X SIZE
	JP	VDPEND			;IT IS POSSIBLE RUN SOME VDP COMMAND?

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OUTPUT:A = MOB NUMBER, OR -1 WHEN NO MORE FREE MOBS

	CSEG
	PUBLIC	ALLOCMOB

ALLOCMOB:
	LD	HL,USED
	LD	BC,NR_MOBS
	XOR	A
	CPIR				;SEARCH FIRST FREE MOB
	JR	Z,A.FOUND
	LD	A,-1			;NO FREE MOBS,SET A = -1
	RET

A.FOUND:DEC	HL
	LD	(HL),1			;MARK IT AS USED
	LD	DE,USED
	OR	A
	SBC	HL,DE
	LD	A,L
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	E = MOB NUMBER

	CSEG
	PUBLIC	FREEMOB

FREEMOB:LD	A,-1
	CP	E
	RET	Z		;NO VALID MOB, RETURN
	PUSH	IX
	LD	HL,USED
	LD	D,0
	ADD	HL,DE
	LD	(HL),0		;MARK IT AS UNUSED
	CALL	MOBADDR
	LD	(IX+MOB.Y),255	;AND ERASE IT FROM THE SCREEN
	POP	IX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	MOBINIT
	EXTRN	BZERO,MEMSET


MOBINIT:PUSH	IX
	LD	HL,USED
	LD	BC,NR_MOBS
	CALL	BZERO

	LD	HL,BUFFER
	LD	BC,MOB.SIZ * NR_MOBS
	LD	A,255
	CALL	MEMSET
	LD	IY,INDEXBUF
	LD	HL,I.INDEX		;INITIALISE THE INDEX ARRAY
	CALL	FOREACH
	POP	IX
	RET

I.INDEX:LD	A,IXL
	LD	(IY),A
	INC	IY
	LD	A,IXU
	LD	(IY),A
	INC	IY
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = MOB POINTER
;	(ACPAGE) = ACTION PAGE

	CSEG
	EXTRN	REMAP,LMMM,VDPPAGE

DRAW:	LD	E,(IX+MOB.Y)		;GET ALL THE PARAMETERS FROM
	LD	D,(IX+MOB.X)		;THE MOB STRUCTURE
	LD	L,(IX+MOB.YO)
	LD	H,(IX+MOB.XO)
	LD	C,(IX+MOB.YSIZ)
	LD	B,(IX+MOB.XSIZ)
	LD	A,MOBPAGE
	LD	(VDPPAGE),A
	LD	A,LOGTIMP
	LD	(LOGOP),A
	CALL	LMMM

	LD	D,(IX+MOB.X)
	LD	E,(IX+MOB.Y)
	LD	B,(IX+MOB.XSIZ)
	LD	C,(IX+MOB.YSIZ)
	JP	REMAP			;RESTORE PART OF BACKGROUND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = MOB POINTER

	CSEG
	EXTRN	HMMM

ERASE:	LD	A,(IX+MOB.YE)
	CP	255
	RET	Z

	LD	E,A
	LD	D,(IX+MOB.XE)
	LD	H,D
	LD	L,E
	LD	B,(IX+MOB.XESIZ)
	LD	C,(IX+MOB.YESIZ)
	LD	A,BAKPAGE
	LD	(VDPPAGE),A
	JP	HMMM		;RESTORE BACKGROUND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO MOB

	CSEG

SHOW:	PUSH	IX
	POP	DE

	PUSH	DE
	LD	HL,4
	ADD	HL,DE
	EX	DE,HL
	LD	BC,4
	LDIR			;DISPLAY COORDENATES TO ERASE COORDENATES

	EX	DE,HL
	POP	DE
	LD	BC,4
	LDIR			;PUTMOB COORDENATES TO DISPLAY COORDENATES
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

DRAWMOBS:
	LD	HL,INDEXBUF
	LD	(D.ACTUAL),HL
	LD	(D.SMALL),HL
	LD	B,NR_MOBS

D.LOOPE:PUSH	BC
        LD	A,255
	LD	HL,(D.ACTUAL)

D.LOOPI:LD	E,(HL)			;SELECT THE MOB WHOSE Y IS THE SMALLEST
	LD	IYL,E
	INC	HL
	LD	E,(HL)
	LD	IYU,E
	INC	HL

	CP	(IY+MOB.Y)
	JR	Z,D.LE
	JR	C,D.NEXT
D.LE:	LD	(D.SMALL),HL		;STORE IN D.SMALL THE POSITION IN THE
	LD	A,(IY+MOB.Y)		;INDEX + 2
D.NEXT:	DJNZ	D.LOOPI

	LD	HL,(D.SMALL)
	DEC	HL
	DEC	HL			;HL = SMALL INDEX POSITION
	LD	DE,(D.ACTUAL)		;DE = ACTUAL INDEX POSIITON

	LD	C,(HL)			;SWAP THE CONTENTS OF (SMALL)
	LD	A,(DE)			;AND THE CONTENTS OF (ACTUAL)
	EX	DE,HL
	LD	(HL),C
	LD	(DE),A
	INC	HL
	INC	DE

	EX	DE,HL
	LD	B,(HL)
	LD	A,(DE)
	EX	DE,HL
	LD	(HL),B
	LD	(DE),A
	INC	HL
	LD	(D.ACTUAL),HL		;POINT ACTUAL FOR THE NEXT ITERATION

	LD	IXL,C
	LD	IXU,B
	LD	A,(IX+MOB.Y)		;IF THE SMALLEST Y IS EQUAL TO 255
	CP	255			;IT MEANS WE DON'T HAVE TO DO
	JR	Z,D.RET			;ANYTHING ELSE

	CALL	DRAW
	POP	BC
	DJNZ	D.LOOPE
	RET

D.RET:	POP	BC
	RET


	DSEG
D.SMALL:	DW	0
D.ACTUAL:	DW	0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	TURNOFF
	EXTRN	CLRVPAGE

TURNOFF:LD	E,TILPAGE
	CALL	CLRVPAGE		;CLEAN THE TILPAGE
	LD	E,TILPAGE+1
	CALL	CLRVPAGE		;CLEAN THE SHADOW TILPAGE
	LD	E,BAKPAGE
	CALL	CLRVPAGE		;CLEAN THE BACKGROUND PAGE

	LD	A,TILPAGE		;RESET VISUALITATION PAGES
	LD	(ACPAGE),A
	INC	A
	LD	(DPPAGE),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	TURNON
	EXTRN	CPVPAGE

TURNON:	LD	A,(ACPAGE)
	PUSH	AF
	LD	E,TILPAGE
	LD	C,TILPAGE+1		;MAKE SHADOW TILPAGE EQUAL TO TILPAGE
	CALL	CPVPAGE
	LD	E,TILPAGE
	LD	C,BAKPAGE		;MAKE BACKGROUND PAGE EQUAL TO TILPAGE
	CALL	CPVPAGE
	POP	AF
	LD	(ACPAGE),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: (ACPAGE) = ACTION PAGE
;	(DPPAGE) = DISPLAY PAGE

	CSEG
	PUBLIC	NEWFRAME
	EXTRN	ENGINE,VDPSYNC

NEWFRAME:
	LD	HL,ERASE
	CALL	FOREACH		;RESTORE BACKGROUND OF ALL THE MOBS
	CALL	DRAWMOBS	;DRAW THE MOBS
	CALL	ENGINE
	CALL	VDPSYNC		;WAIT TO THE VDP

	LD	HL,SHOW
	CALL	FOREACH		;UPDATE THE STATUS OF ALL THE MOBS
	LD	HL,ACPAGE
	LD	DE,DPPAGE
	LD	C,(HL)
	LD	A,(DE)
	EX	DE,HL
	LD	(HL),C		;SWAP THE PAGES
	LD	(DE),A
	EI
	HALT			;WAIT THE VBLANK
	RET

	DSEG
BUFFER:		DS	MOB.SIZ * NR_MOBS
INDEXBUF:	DS	NR_MOBS * 2
USED:		DS	NR_MOBS


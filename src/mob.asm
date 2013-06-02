

	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	DATA.INC

MOBXSIZ		EQU	16
MOBYSIZ		EQU	32
MOBYSAV		EQU	224
DISABLED	EQU	255
MOBSBANK	EQU	16*3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	MOBINIT
	EXTRN	CARTPAGE,VLDIR

MOBINIT:LD	HL,HEAD
	LD	(HEAD+MOB.NEXT),HL
	LD	(HEAD+MOB.PREV),HL

	LD	E,CHAR0PAGE
	CALL	CARTPAGE		;SET THE PAGE OF THE GRAPHICS
	LD	HL,CARTSEG
	LD	DE,00000H
	LD	BC,04000H
	LD	A,MOBPAGE*2
	CALL	VLDIR			;COPY THEM TO VRAM (256*128)

	LD	E,CHAR1PAGE
	CALL	CARTPAGE		;SET THE PAGE OF THE GRAPHICS
	LD	HL,CARTSEG
	LD	DE,00000H
	LD	BC,04000H
	LD	A,MOBPAGE*2+1
	JP	VLDIR			;COPY THEM TO VRAM (256*128)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO MOB

	CSEG

UNLINK:	LD	C,(IX+MOB.NEXT)		;BC = IX->NEXT
	LD	B,(IX+MOB.NEXT+1)
	LD	E,(IX+MOB.PREV)		;DE = IX->PREV
	LD	D,(IX+MOB.PREV+1)
	LD	A,C
	OR	B
	RET	Z

	LD	IYL,C			;IY = IX->NEXT
	LD	IYU,B
	LD	(IY+MOB.PREV),E		;IX->NEXT->PREV = IX->PREV
	LD	(IY+MOB.PREV+1),D
	LD	IYL,E			;IY = IX->PREV
	LD	IYU,D
	LD	(IY+MOB.NEXT),C		;IX->PREV->NEXT = IX->NEXT
	LD	(IY+MOB.NEXT+1),B
	XOR	A
	LD	(IX+MOB.NEXT),A
	LD	(IX+MOB.NEXT+1),A
	LD	(IX+MOB.PREV),A
	LD	(IX+MOB.PREV+1),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO MOB

	CSEG

LINK:	LD	IY,HEAD
	LD	HL,HEAD
	JR	L.NEXT

L.LOOP:	LD	A,(IY+MOB.Y)		;LOOK FOR FIRST MOB WITH SMALLER Y
	CP	(IX+MOB.Y)
	JR	NZ,L.LNK
L.NEXT:	LD	E,(IY+MOB.NEXT)
	LD	D,(IY+MOB.NEXT+1)
	LD	IYL,E
	LD	IYU,D
	CALL	DCOMPR
	JR	NZ,L.LOOP

L.LNK:	LD	E,IYL			;DE = IY
	LD	D,IYU
	LD	(IX+MOB.NEXT),E		;IX->NEXT = IY
	LD	(IX+MOB.NEXT+1),D
	LD	C,(IY+MOB.PREV)		;BC = IY->PREV
	LD	B,(IY+MOB.PREV+1)
	LD	(IX+MOB.PREV),C		;IX->PREV = IY->PREV
	LD	(IX+MOB.PREV+1),B

	LD	E,IXL			;DE = IX
	LD	D,IXU
	LD	(IY+MOB.PREV),E		;IY->PREV = IX
	LD	(IY+MOB.PREV+1),D
	LD	IYL,C			;IY = IY->PREV
	LD	IYU,B
	LD	(IY+MOB.NEXT),E		;IY->PREV->NEXT = IX
	LD	(IY+MOB.NEXT+1),D
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: IX = POINTER TO MOB

	CSEG
	PUBLIC	MOB

MOB:	XOR	A
	LD	(IX+MOB.NEXT),A		;SET NEXT AND PREV TO NULL
	LD	(IX+MOB.NEXT+1),A
	LD	(IX+MOB.PREV),A
	LD	(IX+MOB.PREV+1),A
	CPL
	LD	(IX+MOB.Y),A		;SET ALL Y VALUES TO DISABLED
	LD	(IX+MOB.YD),A
	LD	(IX+MOB.YE),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	DELMOBS

DELMOBS:PUSH	IX
	LD	DE,(HEAD+MOB.NEXT)
	JR	M.ELOOP

M.LOOP:	LD	IXL,E
	LD	IXU,D
	LD	E,(IX+MOB.NEXT)
	LD	D,(IX+MOB.NEXT+1)
	PUSH	DE
	CALL	MOB
	POP	DE

M.ELOOP:LD	HL,HEAD
	CALL	DCOMPR
	JR	NZ,M.LOOP

	LD	HL,HEAD
	LD	(HEAD+MOB.NEXT),HL
	LD	(HEAD+MOB.PREV),HL
	POP	IX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	HMMM,VDPPAGE

ERASE:	LD	A,MOBPAGE
	LD	(VDPPAGE),A
	LD	IY,HEAD
	JR	E.NEXT

E.LOOP:	LD	IYL,E
	LD	IYU,D
	LD	A,(IY+MOB.YE)		;Y = DISABLED MARKS NO ERASABLE MOB
	CP	DISABLED
	JR	Z,E.NEXT

	LD	E,A
	LD	D,(IY+MOB.XE)
	LD	C,(IY+MOB.YESIZ)
	LD	B,(IY+MOB.XESIZ)
	LD	L,(IY+MOB.YB)
	LD	H,(IY+MOB.XB)
	PUSH	IY
	CALL	HMMM
	POP	IY

E.NEXT:	LD	E,(IY+MOB.NEXT)
	LD	D,(IY+MOB.NEXT+1)
	LD	HL,HEAD
	CALL	DCOMPR
	JR	NZ,E.LOOP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	VDPPAGE,HMMM

SAVEBG:	XOR	A
	LD	(S.XSAV),A
	LD	A,(ACPAGE)
	PUSH	AF
	LD	(VDPPAGE),A		;COPY FROM ACPAGE TO MOBPAGE
	LD	A,MOBPAGE
	LD	(ACPAGE),A
	LD	IY,HEAD
	JR	S.NEXT

S.LOOP:	LD	IYL,E
	LD	IYU,D
	LD	A,(IY+MOB.YD)
	CP	DISABLED
	JR	Z,S.NEXT		;Y=DISABLED MARKS MOB AS NOT DISPLAYED

	LD	L,A
	LD	H,(IY+MOB.XD)
	LD	C,(IY+MOB.YDSIZ)
	LD	B,(IY+MOB.XDSIZ)
	BIT	0,H
	JR	Z,S.1
	INC	B			;HMMM COPY BYTES, NOT DOT. IT MEANS
	INC	B			;IN EVEN CASES WE HAVE TO INCREMENT
	LD	(IY+MOB.XDSIZ),B	;IN TWO IN ORDER TO COPY NEXT BYTE

S.1:	LD	A,(S.XSAV)
	LD	D,A
	ADD	A,B
	LD	(S.XSAV),A
	LD	E,MOBYSAV
	LD	(IY+MOB.XB),D
	LD	(IY+MOB.YB),E

	PUSH	IY
	CALL	HMMM
	POP	IY

S.NEXT:	LD	E,(IY+MOB.NEXT)
	LD	D,(IY+MOB.NEXT+1)
	LD	HL,HEAD
	CALL	DCOMPR
	JR	NZ,S.LOOP

	POP	AF
	LD	(ACPAGE),A		;RESTORE ACTUAL ACPAGE
	RET

	DSEG
S.XSAV:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	VDPPAGE,LMMM,REMAP

DRAW:	PUSH	IX
	LD	A,LOGTIMP
	LD	(LOGOP),A
	LD	A,MOBPAGE
	LD	(VDPPAGE),A
	LD	DE,(HEAD+MOB.NEXT)
	PUSH	DE
	JR	D.NEXT

D.LOOP:	LD	IXL,E
	LD	IXU,D

	LD	HL,MOB.YE		;COPY DISPLAY PARAMETERS TO ERASE
	ADD	HL,DE
	EX	DE,HL
	LD	BC,MOB.YD
	ADD	HL,BC
	LD	BC,MOB.YE-MOB.YD
	LDIR

	LD	E,(IX+MOB.Y)		;COPY PUTMOB PARAMETERS TO DISPLAY
	LD	D,(IX+MOB.X)
	LD	C,(IX+MOB.YSIZ)
	LD	B,(IX+MOB.XSIZ)
	LD	(IX+MOB.YD),E
	LD	(IX+MOB.XD),D
	LD	(IX+MOB.YDSIZ),C
	LD	(IX+MOB.XDSIZ),B
	LD	A,DISABLED		;Y=DISABLED MARKS IT AS NOT DRAWABLE MOB
	CP	E
	JR	Z,D.TEST
	LD	L,(IX+MOB.YO)
	LD	H,(IX+MOB.XO)
	PUSH	DE
	PUSH	BC
	CALL	LMMM			;DRAW THE MOB
	POP	BC
	POP	DE
	LD	L,(IX+MOB.BASE)
	LD	H,(IX+MOB.BASE+1)
	LD	A,(IX+MOB.Z)
	CALL	REMAP			;RESTORE UPPER PATTERNS

D.TEST:	LD	E,(IX+MOB.NEXT)		;SAVE NEXT POINTER, IF WE UNLINK THIS
	LD	D,(IX+MOB.NEXT+1)	;MOB THIS VALUE WILL BE LOST
	PUSH	DE
	LD	A,DISABLED		;IF ALL THE Y VALUES ARE DISABLED
	CP	(IX+MOB.Y)		;WE CAN UNLINK THIS MOB BECAUSE
	JR	NZ,D.NEXT		;IT IS NO LONGER INTERESTING FOR
	CP	(IX+MOB.YD)		;ANYTHING
	JR	NZ,D.NEXT
	CP	(IX+MOB.YE)
	JR	NZ,D.NEXT
	CALL	UNLINK
	CALL	MOB

D.NEXT:	POP	DE			;RESTORE NEXT POINTER
	LD	HL,HEAD
	CALL	DCOMPR
	JR	NZ,D.LOOP
	POP	IX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	NEWFRAME
	EXTRN	ENGINE,VDPSYNC

NEWFRAME:
	CALL	ERASE			;RESTORE BACKGROUND
	CALL	SAVEBG			;SAVE BACKGROUND OF DPPAGE FROM ACPAGE
	CALL	DRAW			;DRAW THE MOBS
	CALL	ENGINE			;CALLBACK TO ENGINE
	CALL	VDPSYNC			;WAIT TO VDP

	LD	HL,ACPAGE
	LD	DE,DPPAGE
	LD	C,(HL)
	LD	A,(DE)
	EX	DE,HL
	LD	(HL),C			;SWAP THE PAGES
	LD	(DE),A
	EI
	HALT				;WAIT THE VBLANK
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE MOB
;	HL = X DESTINE
;	DE = Y DESTINE
;	B = PATTERN
;	A = Z VALUE

	CSEG
	PUBLIC	PUTMOB
	EXTRN	VDPEND

PUTMOB:	LD	(CLIP.X),HL		;SET INPUT PARAMETERS FOR CLIP
	LD	(IX+MOB.Z),A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	L,A
	LD	H,0
	ADD	HL,DE
	LD	(P.BASE),HL
	LD	HL,-MOBYSIZ
	ADD	HL,DE
	LD	(CLIP.Y),HL
	LD	A,MOBXSIZ
	LD	(CLIP.XSIZ),A
	LD	A,MOBYSIZ
	LD	(CLIP.YSIZ),A
	LD	A,B
	LD	C,0
	CP	MOBSBANK
	JR	C,P.1
	LD	C,128			;IT IS THE 2ND BANK, BEGINS IN HALF PAGE

P.1:	AND	0F0H
	RLCA
	ADD	A,C
	LD	(CLIP.YO),A
	LD	A,B
	AND	0FH
	RLCA
	RLCA
	RLCA
	RLCA
	LD	(CLIP.XO),A

	CALL	CLIP
	JR	NZ,M.VIS
	LD	A,(IX+MOB.NEXT)
	OR	(IX+MOB.NEXT+1)
	RET	Z			;RETURN IF MOB IS NOT LINKED
	LD	A,DISABLED		;IF LINKED DISABLE THIS MOB
	LD	(CLIP.Y),A

M.VIS:	LD	A,(CLIP.X)		;COPY CLIP PARAMETERS TO THE MOB
	LD	(IX+MOB.X),A
	LD	A,(CLIP.Y)
	LD	(IX+MOB.Y),A
	LD	A,(CLIP.XO)
	LD	(IX+MOB.XO),A
	LD	A,(CLIP.YO)
	LD	(IX+MOB.YO),A
	LD	A,(CLIP.XSIZ)
	LD	(IX+MOB.XSIZ),A
	LD	A,(CLIP.YSIZ)
	LD	(IX+MOB.YSIZ),A
	LD	HL,(P.BASE)
	LD	(IX+MOB.BASE),L
	LD	(IX+MOB.BASE+1),H
	CALL	UNLINK			;THE POSITION OF THE MOB CAN CHANGE IN
	CALL	LINK			;THE LIST, SO IT IS NEEDED RE-LINK IT
	JP	VDPEND

	DSEG
P.BASE:	DW	0

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



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
HEAD:	DS	MOB.PREV+2


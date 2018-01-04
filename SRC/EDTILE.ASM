	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	EVENT.INC
	INCLUDE	LEVEL.INC


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	ED.TILE
	EXTRN	EDINIT,VDPSYNC,LISTEN,CLRVPAGE

ED.TILE:LD	A,E
	LD	(TILE),A
	CALL	EDINIT

ED.LOOP:LD	E,EDPAGE
	CALL	CLRVPAGE
	CALL	SHOWSCR
	CALL	VDPSYNC
	LD	DE,RECEIVERS
	CALL	LISTEN
	JR	NZ,ED.LOOP
	RET

RECEIVERS:
	DB	40H,38H,32,48
	DW	PEVENT
	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	CSEG
	EXTRN	GLINES,LOCATE,PRINTF,DRAWTILE,LOCATE,MULTDEA
	EXTRN	TILEDEF

SHOWSCR:LD	DE,27H
	CALL	LOCATE

	LD	DE,TILEG
	LD	C,15
	CALL	GLINES

	LD	A,(TILE)
	PUSH	AF

	LD	DE,TILE.SIZ
	CALL	MULTDEA
	EX	DE,HL
	LD	IX,TILEDEF
	ADD	IX,DE
	LD	(TADDR),IX

	LD	H,0
	LD	L,(IX+6)
	PUSH	HL
	LD	L,(IX+0)
	PUSH	HL
	LD	L,(IX+7)
	PUSH	HL
	LD	L,(IX+1)
	PUSH	HL
	LD	L,(IX+8)
	PUSH	HL
	LD	L,(IX+2)
	PUSH	HL
	LD	L,(IX+9)
	PUSH	HL
	LD	L,(IX+3)
	PUSH	HL
	LD	L,(IX+10)
	PUSH	HL
	LD	L,(IX+4)
	PUSH	HL
	LD	L,(IX+11)
	PUSH	HL
	LD	L,(IX+5)
	PUSH	HL
	LD	DE,TINFO
	CALL	PRINTF

	POP	AF
	LD	C,A
	LD	DE,4060H
	CALL	DRAWTILE
	RET


TINFO:	DB	"%02x %02x",10
	DB	"%02x %02x",10
	DB	"%02x %02x",10
	DB	"%02x %02x",10
	DB	"%02x %02x",10
	DB	"%02x %02x",0

	PUBLIC	TILEG

;	       REP  X0  Y0    X1  Y1 IX0 IY0 IX1 IY1
TILEG:	DB	7, 40H, 38H, 60H,38H,  0,  8,  0,  8
	DB	3, 40H, 38H, 40H,68H, 16,  0, 16,  0
	DB	0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: A  = EVENT
;       DE = SCREEN COORDINATES

	CSEG
	EXTRN	ADDAHL
	PUBLIC	PEVENT

PEVENT:	CP	MS_BUTTON1
	RET	NZ

	LD	L,0
	LD	A,D
	SUB	40H
	RRCA
	RRCA
	RRCA
	RRCA
	AND	1
	JR	Z,P.Y	
	LD	A,6
	ADD	A,L
	LD	L,A

P.Y:	LD	A,E
	SUB	38H
	RRCA
	RRCA
	RRCA
	AND	7
	ADD	A,L
	LD	(PATERN),A
	CALL	PATSEL
	PUSH	AF
	LD	HL,(TADDR)
	LD	A,(PATERN)
	CALL	ADDAHL
	POP	AF
	LD	(HL),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	CSEG
	EXTRN	CLRVPAGE,LMMM,VDPPAGE


PATSEL:	LD	E,EDPAGE
	CALL	CLRVPAGE

	LD	A,LOGIMP
	LD	(LOGOP),A
	LD	A,PATPAGE
	LD	(VDPPAGE),A
	
	LD	HL,0
	LD	DE,3C05H
	LD	BC,32
	CALL	LMMM
	CALL	VDPSYNC
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DSEG
TILE:	DB	0
PATERN:	DB	0
TADDR:	DW	0

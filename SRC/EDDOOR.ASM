
	INCLUDE	SHIKE2.INC
	INCLUDE	DATA.INC
	INCLUDE	LEVEL.INC
	INCLUDE	EVENT.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = LEVEL
;	BC = ROOM
;	HL = COORDENATES
;	A = HEIGHT

	CSEG
	PUBLIC	ED.DOOR
	EXTRN	EDINIT,CLRVPAGE,PUTLPAGE,VDPSYNC,LISTEN

ED.DOOR:LD	(POINT1+POINT.LEVEL),DE
	LD	(POINT1+POINT.ROOM),BC
	LD	(POINT1+POINT.Y),HL
	LD	(POINT1+POINT.Z),A
	CALL	EDINIT

ED.LOOP:LD	E,EDPAGE
	CALL	CLRVPAGE
	CALL	PUTLPAGE
	CALL	SHOWSCR
	CALL	VDPSYNC
	LD	DE,RECEIVERS
	CALL	LISTEN
	JR	NZ,ED.LOOP
	RET

RECEIVERS:
	DB	1,29,8,8
	DW	DOOREVENT
	DB	1,29,16,8
	DW	STATEEVENT
	DB	1,29,24,8
	DW	TYPEEVENT
	DB	1,29,32,8
	DW	KEYEVENT
	DB	1,29,40,8
	DW	PLACEEVENT
	DB	1,29,48,8
	DW	SAVEEVENT
	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	GETNDOOR,LOCATE,PRINTF,GLINES

SHOWSCR:LD	DE,1
	CALL	LOCATE
	LD	DE,(NDOOR)
	CALL	GETNDOOR
	LD	(DOORPTR),HL
	PUSH	HL
	POP	IY
	LD	H,0
	LD	L,(IY+DOOR.Z)
	PUSH	HL
	LD	L,(IY+DOOR.X)
	PUSH	HL
	LD	L,(IY+DOOR.Y)
	PUSH	HL
	LD	L,(IY+DOOR.ROOM)
	PUSH	HL
	LD	L,(IY+DOOR.ROOM+1)
	PUSH	HL
	LD	L,(IY+DOOR.LEVEL)
	PUSH	HL
	LD	L,(IY+DOOR.LEVEL+1)
	PUSH	HL
	LD	L,(IY+DOOR.KEY)
	PUSH	HL
	LD	A,(IY+DOOR.TYPE)
	OR	A
	LD	DE,YZSTR
	JR	Z,S.1
	LD	DE,XZSTR
S.1:	PUSH	DE
	LD	A,(IY+DOOR.OPEN)
	OR	A
	LD	DE,CLOSE
	JR	Z,S.2
	LD	DE,OPEN
S.2:	PUSH	DE
	LD	A,(NDOOR)
	LD	L,A
	PUSH	HL
	LD	DE,DINFO
	CALL	PRINTF
	LD	C,15
	LD	DE,DOORG
	CALL	GLINES
	RET



YZSTR:	DB	"YZ",0
XZSTR:	DB	"XZ",0
OPEN:	DB	"OPEN",0
CLOSE:	DB	"CLOSE",0

DINFO:	DB	" DOOR",9,"%d",10
	DB	" STATE",9,"%s",10
	DB	" TYPE",9,"%s",10
	DB	" KEY",9,"%d",10
	DB	" PLACE",10," SAVE",10
	DB	" LEVEL",9,"%02dX%02d",10
	DB	" ROOM",9,"%02dX%02d",10
	DB	" X",9,"%02d",10
	DB	" Y",9,"%02d",10
	DB	" Z",9,"%02d",0

;	       REP  X0  Y0    X1  Y1 IX0 IY0 IX1 IY1
DOORG:	DB	7,   0,  7,   30,  7,  0,  8,  0,  8
	DB	2,   0,  7,    0, 55, 30,  0, 30,  0
	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT

	CSEG

STATEEVENT:
	CP	MS_BUTTON1
	RET	NZ
	LD	IY,(DOORPTR)
	LD	A,1
	XOR	(IY+DOOR.OPEN)
	LD	(IY+DOOR.OPEN),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT

	CSEG

TYPEEVENT:
	CP	MS_BUTTON1
	RET	NZ
	LD	IY,(DOORPTR)
	LD	A,1
	XOR	(IY+DOOR.TYPE)
	LD	(IY+DOOR.TYPE),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT

	CSEG

PLACEEVENT:
	CP	MS_BUTTON1
	RET	NZ

	LD	HL,(DOORPTR)
	LD	DE,DOOR.POINT
	ADD	HL,DE
	EX	DE,HL
	LD	HL,POINT1
	LD	BC,SIZPOINT
	LDIR
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT

	CSEG

KEYEVENT:
	LD	IY,(DOORPTR)
	CP	MS_BUTTON1
	JR	NZ,K.1
	LD	A,(IY+DOOR.KEY)
	CP	NR_KEYS-1
	RET	Z
	INC	A
	JR	K.END

K.1:	CP	MS_BUTTON2
	RET	NZ
	LD	A,(IY+DOOR.KEY)
	OR	A
	RET	Z
	DEC	A

K.END:	LD	(IY+DOOR.KEY),A
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: A = EVENT

	CSEG

DOOREVENT:
	CP	MS_BUTTON1		;BUTTON 1 INCREMENTS DOOR NUMBER
	JR	NZ,D.1
	LD	A,(NDOOR)
	CP	NR_DOORS-1
	RET	Z
	INC	A
	JR	D.END

D.1:	CP	MS_BUTTON2		;BUTTON 2 DECREMENTS DOOR NUMBER
	RET	NZ
	LD	A,(NDOOR)
	OR	A
	RET	Z
	DEC	A

D.END:	LD	(NDOOR),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: A = EVENT

	CSEG
	EXTRN	MULTEA,DOORSDAT

SAVEEVENT:
	CP	MS_BUTTON1
	RET	NZ

	PUSH	IX
	LD	DE,(NDOOR)
	LD	A,SIZDINFO
	CALL	MULTEA
	LD	DE,DOORSDAT
	ADD	HL,DE
	PUSH	HL
	POP	IY
	LD	IX,(DOORPTR)

	LD	A,(IX+DOOR.LEVEL)
	LD	(IY+DINFO.LEVEL),A
	LD	A,(IX+DOOR.LEVEL+1)
	LD	(IY+DINFO.LEVEL+1),A

	LD	A,(IX+DOOR.ROOM)
	LD	(IY+DINFO.ROOM),A
	LD	A,(IX+DOOR.ROOM+1)
	LD	(IY+DINFO.ROOM+1),A

	LD	A,(IX+DOOR.X)
	LD	(IY+DINFO.X),A
	LD	A,(IX+DOOR.Y)
	LD	(IY+DINFO.Y),A
	LD	A,(IX+DOOR.Z)
	LD	(IY+DINFO.Z),A

	LD	A,(IX+DOOR.TYPE)
	LD	(IY+DINFO.TYPE),A
	LD	A,(IX+DOOR.KEY)
	LD	(IY+DINFO.KEY),A
	LD	A,(IX+DOOR.OPEN)
	LD	(IY+DINFO.STAT),A
	POP	IX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DSEG
NDOOR:	DB	0
DOORPTR:DW	0
POINT1:	DS	SIZPOINT




	INCLUDE	SHIKE2.INC
	INCLUDE	BIOS.INC
	INCLUDE	LEVEL.INC
	INCLUDE	DATA.INC
	INCLUDE	EVENT.INC


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = LEVEL
;	BC = ROOM
;	HL = COORDENATES
;	A = HEIGHT

	CSEG
	PUBLIC	ED.CHAR
	EXTRN	EDINIT,CARTPAGE,VDPSYNC,LISTEN,CLRVPAGE

ED.CHAR:LD	(POINT1+POINT.LEVEL),DE
	LD	(POINT1+POINT.ROOM),BC
	LD	(POINT1+POINT.Y),HL
	LD	(POINT1+POINT.Z),A
	CALL	EDINIT

ED.LOOP:LD	E,EDPAGE
	CALL	CLRVPAGE
	LD	E,LEVELPAGE
	CALL	CARTPAGE
	CALL	SHOWSCR
	CALL	VDPSYNC
	LD	DE,RECEIVERS
	CALL	LISTEN
	JR	NZ,ED.LOOP
	RET


RECEIVERS:
	DB	1,29,8,8
	DW	CHAREVENT
	DB	1,29,16,8
	DW	PATEVENT
	DB	1,29,28,8
	DW	CTRLEVENT
	DB	1,29,36,8
	DW	PLACEEVENT
	DB	1,29,54,8
	DW	CAMEVENT
	DB	0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	GLINES,GETNCHAR,LOCATE,PRINTF,ARYHL,CHARCTL

SHOWSCR:LD	DE,1
	CALL	LOCATE

	LD	DE,(NCHAR)
	CALL	GETNCHAR
	LD	(CHARPTR),HL
	PUSH	HL
	POP	IY
	LD	H,0
	LD	L,(IY+MOV.Z)
	PUSH	HL
	LD	L,(IY+MOV.Y)
	PUSH	HL
	LD	L,(IY+MOV.X)
	PUSH	HL
	LD	L,(IY+MOV.LEVEL)
	PUSH	HL
	LD	L,(IY+MOV.LEVEL+1)
	PUSH	HL
	LD	L,(IY+MOV.ROOM)
	PUSH	HL
	LD	L,(IY+MOV.ROOM+1)
	PUSH	HL

	PUSH	IY
	LD	E,(IY+CHAR.CONTROL)
	LD	D,(IY+CHAR.CONTROL+1)
	LD	C,-1
	CALL	CHARCTL
	PUSH	HL
	POP	IY
	LD	E,(IY+CHARCTL.STR)
	LD	D,(IY+CHARCTL.STR+1)
	LD	A,(IY+CHARCTL.CODE)
	LD	(CTRLNUM),A
	POP	IY
	PUSH	DE

	LD	A,(IY+MOV.DIR)
	LD	HL,DIRS
	CALL	ARYHL
	PUSH	HL
	LD	H,0
	LD	A,(IY+CHAR.PAT)
	LD	(PAT),A
	LD	L,A
	PUSH	HL
	LD	A,(NCHAR)
	LD	L,A
	PUSH	HL

	LD	DE,CINFO
	CALL	PRINTF

	LD	C,15
	LD	DE,CHARG
	CALL	GLINES
	JP	DRAWCHAR


CINFO:	DB	" CHAR",9,"%02d",10
	DB	" PATERN",9,"%02d",10
	DB	" DIR",9,"%s",10
	DB	" CTRL",9,"%6s",10
	DB	" PLACE",10," SAVE",10," SETCAM",10
	DB	" LEVEL",9,"%02dX%02d",10
	DB	" ROOM",9,"%02dX%02d",10
	DB	" X",9,"%02d",10
	DB	" Y",9,"%02d",10
	DB	" Z",9,"%02d",0

;	       REP  X0  Y0    X1  Y1 IX0 IY0 IX1 IY1
CHARG:	DB	2,  60,  5,   76,  5,  0, 32,  0, 32
	DB	2,  60,  5,   60, 37, 16,  0, 16,  0
	DB	8,   0,  6,   30,  6,  0,  8,  0,  8
	DB	2,   0,  6,    0, 62, 30,  0, 30,  0
	DB	0

DIRS:	DW	RIGTH,LEFT,UP,DOWN,NODIR
RIGTH:	DB	"RIGTH",0
LEFT:	DB	"LEFT",0
UP:	DB	"UP",0
DOWN:	DB	"DOWN",0
NODIR:	DB	"NO DIR",0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	VDPPAGE,LMMM,CHARPAT,MOB2XY

DRAWCHAR:
	LD	A,LOGTIMP
	LD	(LOGOP),A
	LD	A,MOBPAGE
	LD	(VDPPAGE),A

	LD	IY,(CHARPTR)
	LD	E,(IY+CHAR.PAT)
	CALL	CHARPAT
	OR	80H
	LD	(IY+MOV.PAT),A		;UPDATE THE MOB PATTERN BECAUSE
	LD	E,A			;MAYBE USER HAS CHANGED IT
	CALL	MOB2XY
	LD	DE,3C05H
	LD	BC,1020H
	JP	LMMM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT

	CSEG
	EXTRN	PLACE

PLACEEVENT:
	CP	MS_BUTTON1
	RET	NZ

	PUSH	IX
	LD	IX,(CHARPTR)
	LD	C,(IX+MOV.DIR)
	LD	DE,POINT1
	CALL	PLACE
	POP	IX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT

	CSEG
	EXTRN	SETCAMOP

CAMEVENT:
	CP	MS_BUTTON1
	RET	NZ

	PUSH	IX
	LD	IX,(CHARPTR)
	CALL	SETCAMOP
	POP	IX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: A = EVENT

	CSEG
	EXTRN	CHARCTL

CTRLEVENT:
	LD	HL,CTRLNUM
	CP	MS_BUTTON1		;BUTTON 1 INCREMENTS CONTROL CODE
	JR	NZ,C.1
	LD	A,(CTRLNUM)
	CP	NR_CHARCTL-1
	RET	Z
	INC	A
	JR	C.END

C.1:	CP	MS_BUTTON2		;BUTTON 2 DECREMENTS CONTROL CODE
	RET	NZ
	LD	A,(CTRLNUM)
	OR	A
	RET	Z
	DEC	A

C.END:	LD	DE,-1
	LD	C,A
	CALL	CHARCTL			;GET THE CONTROL FUNCTION
	LD	IY,(CHARPTR)
	LD	(IY+CHAR.CONTROL),L
	LD	(IY+CHAR.CONTROL+1),H
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: A = EVENT

	CSEG

PATEVENT:
	CP	MS_BUTTON1		;BUTTON 1 INCREMENTS PAT NUMBER
	JR	NZ,P.1
	LD	A,(PAT)
	CP	NR_CHARSET*4-1		;THERE ARE 4 PATTERNS IN EACH PAGE
	RET	Z
	INC	A
	JR	P.END

P.1:	CP	MS_BUTTON2		;BUTTON 2 DECREMENTS PAT NUMBER
	RET	NZ
	LD	A,(PAT)
	OR	A
	RET	Z
	DEC	A

P.END:	LD	IY,(CHARPTR)
	LD	(IY+CHAR.PAT),A
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: A = EVENT

	CSEG

CHAREVENT:
	CP	MS_BUTTON1		;BUTTON 1 INCREMENTS CHAR NUMBER
	JR	NZ,CH.1
	LD	A,(NCHAR)
	CP	NR_CHARS-1
	RET	Z
	INC	A
	JR	CH.END

CH.1:	CP	MS_BUTTON2		;BUTTON 2 DECREMENTS CHAR NUMBER
	RET	NZ
	LD	A,(NCHAR)
	OR	A
	RET	Z
	DEC	A

CH.END:	LD	(NCHAR),A
	RET




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG

POINT1:	DS	SIZPOINT
PAT:	DB	0
NCHAR:	DB	0
CHARPTR:DW	0
CTRLNUM:DB	0



	INCLUDE	SHIKE2.INC
	INCLUDE	EDITOR.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	INITLEVELS
	EXTRN	MEMSET

INITLEVELS:
	LD	A,-1
	LD	HL,MAPS.BEGIN
	LD	BC,MAPS.END - MAPS.BEGIN
	JP	MEMSET



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE LEVEL
;	DE = POSITION OF THE MAP INTO THE LEVEL
;OUTPUT:A = MAP NUMBER
;	Z = 1 WHEN NO MAP

	CSEG
	PUBLIC	GETMAP
	EXTRN	MULTEA

GETMAP:	PUSH	DE
	LD	A,(IX+LEVEL.YSIZ)
	CALL	MULTEA		;HL = YOFFSET
	LD	E,(IX+LEVEL.MAP)
	LD	D,(IX+LEVEL.MAP+1)
	ADD	HL,DE		;HL = MAP + YOFFSET
	POP	DE
	LD	E,D
	LD	D,0
	ADD	HL,DE		;HL = MAP + YOFFSET + XOFFSET

	LD	A,(HL)
	CP	-1
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	LEVELS


LEVELS:	DB	8,8
	DW	MOSQUE
	DW	MOSQUE.MAP
	DB	4,4
	DW	ZAHRA
	DW	ZAHRA.MAP
	DB	6,6
	DW	ZAHIRA
	DW	ZAHIRA.MAP


MOSQUE:	DB	"QURTUBA MOSQUE",0
ZAHRA:	DB	"MEDINA AL-ZAHRA",0
ZAHIRA:	DB	"MEDINA AL-ZAHIRA",0

	DSEG

MAPS.BEGIN:
MOSQUE.MAP:	DS	8*8
ZAHRA.MAP:	DS	4*4
ZAHIRA.MAP:	DS	6*6
MAPS.END:




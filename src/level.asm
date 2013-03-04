
	INCLUDE	SHIKE2.INC
	INCLUDE	EDITOR.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	INITLEVEL
	EXTRN	BZERO,MEMSET

INITLEVEL:
	LD	A,MAXROOMX-1			;INITIALIZE THE SIZE
	LD	(LVLXSIZ),A
	LD	A,MAXROOMY-1
	LD	(LVLYSIZ),A

	LD	A,-1
	LD	HL,LVLROOM
	LD	BC,LVLROOMSIZ
	CALL	MEMSET				;CLEAN MAP IN LEVELS

	LD	HL,LVLMAP
	LD	BC,LVLMAPSIZ
	CALL	BZERO

	LD	HL,LVLHGT
	LD	BC,LVLHGTSIZ
	JP	BZERO


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: A = NUMBER OF LEVEL


	CSEG
	PUBLIC	LEVEL

LEVEL:	ADD	A,7
	OUT	(0FEH),A
	RET





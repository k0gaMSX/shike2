
	INCLUDE	SHIKE2.INC
	INCLUDE	EDITOR.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = LOCATION OF THE MAP IN THE LEVEL
;OUTPUT:HL = ADRESS OF THE ROOM IN THE LEVEL

	CSEG
	PUBLIC	ROOMADDR
	EXTRN	MULTEA

ROOMADDR:
	PUSH	DE
	LD	D,0
	LD	A,(LVLYSIZ)
	CALL	MULTEA
	POP	DE			;HL = Y*LVLYSIZ
	LD	E,D
	LD	D,0
	ADD	HL,DE			;HL = Y*LVLYSIZ + X
	LD	DE,LVLROOM
	ADD	HL,DE			;HL = LVLROOM + Y*LVLYSIZ + X
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = POSIITON OF THE ROOM
;OUTPUT:A = ROOM NUMBER

	CSEG
	PUBLIC	GETROOM

GETROOM:CALL	ROOMADDR
	LD	A,(HL)
	CP	-1
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = POSITION OF ROOM
;OUTPUT:HL = ADRESS OF ROOM MAP

	CSEG
	PUBLIC	ROOM2MAP
	EXTRN	MULTDEA

ROOM2MAP:
	CALL	GETROOM
	LD	DE,MAPSIZ
	CALL	MULTDEA				;HL = ROOM*MAPSIZ
	LD	DE,LVLMAP
	ADD	HL,DE				;HL = ROOM*MAPSIZ+LVLMAP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = POSITION OF ROOM
;OUTPUT:HL = ADDRESS OF ROOM HEIGTH

	CSEG
	PUBLIC	ROOM2HGT
	EXTRN	MULTDEA

ROOM2HGT:
	CALL	GETROOM
	LD	DE,HEIGTHSIZ
	CALL	MULTDEA				;HL = ROOM*HEIGTHSIZ
	LD	DE,LVLHGT
	ADD	HL,DE				;HL = ROOM*HEIGTHSIZ+LVLHGT
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: A = NUMBER OF LEVEL


	CSEG
	PUBLIC	LEVEL

LEVEL:	ADD	A,7
	OUT	(0FEH),A
	RET





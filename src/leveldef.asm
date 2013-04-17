
	INCLUDE	SHIKE2.INC
	INCLUDE	LEVEL.INC

	ASEG
	ORG	CARTSEG

JTABLE:	JP	GETFLOOR_
	JP	GETTILE_
	JP	GETPAL_
	JP	GETLEVEL_
	JP	GETROOM_

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;INPUT:	E PALETE NUMBER

GETPAL_:EX	DE,HL
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	DE,PALETES
	ADD	HL,DE
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = 1ST OPERAND
;	A = 2ND OPERAND
;OUTPUT:HL = DE*A

MULTDEA:LD	HL,0
	LD	B,8

DE.LOOP:RRCA
	JP	NC,DE.NOT
	ADD	HL,DE
DE.NOT:	SLA	E
	RL	D
	DJNZ	DE.LOOP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	E = NUMBER OF FLOOR
;OUTPUT:HL = ADDRESS

GETFLOOR_:
	LD	A,E
	DEC	A			;FLOOR 0 IS EMPTY FLOOR, SO DECREMENT 1
	LD	DE,SIZFLOOR
	CALL	MULTDEA
	LD	DE,FLOOR
	ADD	HL,DE
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	E = NUMBER OF TILE
;OUTPUT:HL = ADDRESS

GETTILE_:
	LD	A,E
	DEC	A			;TILE 0 IS EMPTY TILE, SO DECREMENT 1
	LD	DE,SIZTILE
	CALL	MULTDEA
	LD	DE,TILE
	ADD	HL,DE
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = LEVEL LOCATION
;OUTPUT:HL = ADDRESS
;	Z = 0 WHEN NO VALID LEVEL

GETLEVEL_:
	LD	A,E
	ADD	A,A
	ADD	A,A
	ADD	A,A			;A = YOOFSET
	ADD	A,D			;A = OFFSET
	LD	L,A
	LD	H,0			;HL = OFFSET
	LD	DE,MAP
	ADD	HL,DE			;MAP[X][Y]
	LD	A,(HL)			;A = LEVEL NUMBER
	OR	A
	LD	HL,0			;LEVEL 0 IS THE EMPTY LEVEL
	RET	Z
	DEC	A
	LD	DE,SIZLEVEL
	CALL	MULTDEA			;HL = LEVEL OFFSET
	LD	DE,LEVEL1
	ADD	HL,DE			;HL = LEVEL ADDRESS
	OR	1			;SET Z=1
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = LEVEL LOCATION
;	BC = ROOM LOCATION
;	A = HEIGTH
;OUTPUT:HL = ROOM ADDRESS
;	DE = MAP VALUE
;	Z = 0 WHEN NO VALID ROOM

GETROOM_:
	PUSH	BC
	PUSH	AF
	CALL	GETLEVEL_
	POP	DE
	POP	BC
	RET	Z			;NO VALID LEVEL

	LD	A,D			;A = HEIGHT
	PUSH	BC			;SAVE ROOM LOCATION
	LD	DE,LVL.HEIGHT1		;HL = LEVEL POINTER
	ADD	HL,DE			;HL = LEVEL HEIGHT1
	PUSH	HL
	LD	DE,SIZRMATRIX
	CALL	MULTDEA			;HL = HEIGHT OFFSET
	POP	DE			;DE = LEVEL HEIGHT1
	ADD	HL,DE			;HL = HEIGHT POINTER
	POP	BC			;BC = ROOM LOCATION

	LD	A,C
	ADD	A,A
	ADD	A,A
	ADD	A,A			;A = Y ROOM OFFSET
	ADD	A,B			;A = ROOM OFFSET
	LD	E,A
	LD	D,0
	ADD	HL,DE			;HL = MAP ADDRESS
	OR	1			;SET Z FLAG
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MAP:	DB	0, 0, 0, 0, 0, 0, 0, 0
	DB	0, 0, 0, 0, 0, 0, 0, 0
	DB	0, 0, 0, 7, 8, 9, 0, 0
	DB	0,10,14, 4, 5, 6,15,11
	DB	0, 0, 0, 1, 2, 3, 0, 0
	DB	0, 0, 0, 0,12, 0, 0, 0
	DB	0, 0, 0, 0,13, 0, 0, 0
	DB	0, 0, 0, 0, 0, 0, 0, 0

ACCS:	DB	0, 0, 0, 0, 0, 0, 0, 0
	DB	0, 0, 0, 0, 0, 0, 0, 0
	DB	0, 0, 0, 0, 0, 0, 0, 0
	DB	0, 0, 0, 0, 0, 0, 0, 0
	DB	0, 0, 0, 0, 0, 0, 0, 0
	DB	0, 0, 0, 0, 0, 0, 0, 0
	DB	0, 0, 0, 0, 0, 0, 0, 0
	DB	0, 0, 0, 0, 0, 0, 0, 0

LEVEL1:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 1

ALCAZAR:DB	"AL-QASR            ",0	;LEVEL 1
L1_PAL:	DB	0
L1_GFX:	DB	0
L1_1:	DS	8*8*2
L1_2:	DS	8*8*2
L1_3:	DS	8*8*2
L1_ACC:	DS	8*8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 2

MOSQUE:	DB	"MASCHID AL-HAMA    ",0	;LEVEL 2
L2_PAL:	DB	0
L2_GFX:	DB	0
L2_1:	DS	8*8*2
L2_2:	DS	8*8*2
L2_3:	DS	8*8*2
L2_ACC:	DS	8*8


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 3

SOUK:	DB	"SUQ                ",0	;LEVEL 3
L3_PAL:	DB	0
L3_GFX:	DB	0
L3_1:	DS	8*8*2
L3_2:	DS	8*8*2
L3_3:	DS	8*8*2
L3_ACC:	DS	8*8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 4

RAYAHUD:DB	"RABAD AL-YAHUD     ",0	;LEVEL 4
L4_PAL:	DB	0
L4_GFX:	DB	0
L4_1:	DS	8*8*2
L4_2:	DS	8*8*2
L4_3:	DS	8*8*2
L4_ACC:	DS	8*8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 5
CENTER:	DB	"MADINAT AL-ATICA   ",0	;LEVEL 5
L5_PAL:	DB	0
L5_GFX:	DB	0
L5_1:	DS	8*8*2
L5_2:	DS	8*8*2
L5_3:	DS	8*8*2
L5_ACC:	DS	8*8


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 6

FARAN:	DB	"FARAN BARBAL       ",0	;LEVEL 6
L6_PAL:	DB	0
L6_GFX:	DB	0
L6_1:	DS	8*8*2
L6_2:	DS	8*8*2
L6_3:	DS	8*8*2
L6_ACC:	DS	8*8


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 7

RUSAFA:	DB	"AL-RUSAFA          ",0	;LEVEL 7
L7_PAL:	DB	0
L7_GFX:	DB	0
L7_1:	DS	8*8*2
L7_2:	DS	8*8*2
L7_3:	DS	8*8*2
L7_ACC:	DS	8*8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 8

MUSLIMA:DB	"MASCHID UMM-MUSLIMA",0	;LEVEL 8
L8_PAL:	DB	0
L8_GFX:	DB	0
L8_1:	DS	8*8*2
L8_2:	DS	8*8*2
L8_3:	DS	8*8*2
L8_ACC:	DS	8*8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 9

BAYAHUD:DB	"BAB AL-YAHUD       ",0	;LEVEL 9
L9_PAL:	DB	0
L9_GFX:	DB	0
L9_1:	DS	8*8*2
L9_2:	DS	8*8*2
L9_3:	DS	8*8*2
L9_ACC:	DS	8*8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 10

AZAHARA:DB	"MADINAT AL-ZAHRA   ",0	;LEVEL 10
L10_PAL:DB	0
L10_GFX:DB	0
L10_1:	DS	8*8*2
L10_2:	DS	8*8*2
L10_3:	DS	8*8*2
L10_ACC:DS	8*8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 11

ZAHIRA:	DB	"MADINAT AL-ZAHIRA  ",0	;LEVEL 11
L11_PAL:DB	0
L11_GFX:DB	0
L11_1:	DS	8*8*2
L11_2:	DS	8*8*2
L11_3:	DS	8*8*2
L11_ACC:DS	8*8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 12

BRIDGE:	DB	"BAB AL-QANTARA     ",0 ;LEVEL 12
L12_PAL:DB	0
L12_GFX:DB	0
L12_1:	DS	8*8*2
L12_2:	DS	8*8*2
L12_3:	DS	8*8*2
L12_ACC:DS	8*8


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 13

SACUNDA:DB	"SACUNDA            ",0	;LEVEL 13
L13_PAL:DB	0
L13_GFX:DB	0
L13_1:	DS	8*8*2
L13_2:	DS	8*8*2
L13_3:	DS	8*8*2
L13_ACC:DS	8*8
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 14

GALLEGO:DB	"BAB AMIR AL-QURASI ",0	;LEVEL 14
L14_PAL:DB	0
L14_GFX:DB	0
L14_1:	DS	8*8*2
L14_2:	DS	8*8*2
L14_3:	DS	8*8*2
L14_ACC:DS	8*8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 15

HIERRO:	DB	"IBN ABD AL-YABBAR  ",0	;LEVEL 15
L15_PAL:DB	0
L15_GFX:DB	0
L15_1:	DS	8*8*2
L15_2:	DS	8*8*2
L15_3:	DS	8*8*2
L15_ACC:DS	8*8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FLOOR:	DS	NR_FLOORS*SIZFLOOR
TILE:	DS	NR_TILES*SIZTILE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

       INCLUDE	PALETE.ASM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	PUBLIC	END
END:	DS	CARTSEG+4000H-$,0



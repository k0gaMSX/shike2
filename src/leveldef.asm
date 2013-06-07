
	INCLUDE	SHIKE2.INC
	INCLUDE	LEVEL.INC

	ASEG
	ORG	CARTSEG

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	PUBLIC	MAPDEF,LEVELDEF

MAPDEF:	DB	0, 0, 0, 0, 0, 0, 0, 0
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

LEVELDEF:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 1

ALCAZAR:DB	"AL-QASR"			;LEVEL 1
L1_STR:	DS	SIZLVLNAME - (L1_STR - ALCAZAR) 
L1_PAL:	DB	0
L1_GFX:	DB	0
L1_1:	DS	8*8*2
L1_2:	DS	8*8*2
L1_3:	DS	8*8*2
L1_ACC:	DS	8*8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 2

MOSQUE:	DB	"MASCHID AL-HAMA"		;LEVEL 2
L2_STR:	DS	SIZLVLNAME - (L2_STR - MOSQUE) 
L2_PAL:	DB	0
L2_GFX:	DB	0
L2_1:	DS	8*8*2
L2_2:	DS	8*8*2
L2_3:	DS	8*8*2
L2_ACC:	DS	8*8


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 3

SOUK:	DB	"SUQ"				;LEVEL 3
L3_STR:	DS	SIZLVLNAME - (L3_STR - SOUK) 
L3_PAL:	DB	0
L3_GFX:	DB	0
L3_1:	DS	8*8*2
L3_2:	DS	8*8*2
L3_3:	DS	8*8*2
L3_ACC:	DS	8*8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 4

RAYAHUD:DB	"RABAD AL-YAHUD"		;LEVEL 4
L4_STR:	DS	SIZLVLNAME - (L4_STR - RAYAHUD) 
L4_PAL:	DB	0
L4_GFX:	DB	0
L4_1:	DS	8*8*2
L4_2:	DS	8*8*2
L4_3:	DS	8*8*2
L4_ACC:	DS	8*8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 5
CENTER:	DB	"MADINAT AL-ATICA"		;LEVEL 5
L5_STR:	DS	SIZLVLNAME - (L5_STR - CENTER) 
L5_PAL:	DB	0
L5_GFX:	DB	0
L5_1:	DS	8*8*2
L5_2:	DS	8*8*2
L5_3:	DS	8*8*2
L5_ACC:	DS	8*8


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 6

FARAN:	DB	"FARAN BARBAL"			;LEVEL 6
L6_STR:	DS	SIZLVLNAME - (L6_STR - FARAN) 
L6_PAL:	DB	0
L6_GFX:	DB	0
L6_1:	DS	8*8*2
L6_2:	DS	8*8*2
L6_3:	DS	8*8*2
L6_ACC:	DS	8*8


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 7

RUSAFA:	DB	"AL-RUSAFA"			;LEVEL 7
L7_STR:	DS	SIZLVLNAME - (L7_STR - RUSAFA) 
L7_PAL:	DB	0
L7_GFX:	DB	0
L7_1:	DS	8*8*2
L7_2:	DS	8*8*2
L7_3:	DS	8*8*2
L7_ACC:	DS	8*8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 8

MUSLIMA:DB	"MASCHID UMM-MUSLIMA"		;LEVEL 8
L8_STR:	DS	SIZLVLNAME - (L8_STR - MUSLIMA) 
L8_PAL:	DB	0
L8_GFX:	DB	0
L8_1:	DS	8*8*2
L8_2:	DS	8*8*2
L8_3:	DS	8*8*2
L8_ACC:	DS	8*8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 9

BAYAHUD:DB	"BAB AL-YAHUD"			;LEVEL 9
L9_STR:	DS	SIZLVLNAME - (L9_STR - BAYAHUD) 
L9_PAL:	DB	0
L9_GFX:	DB	0
L9_1:	DS	8*8*2
L9_2:	DS	8*8*2
L9_3:	DS	8*8*2
L9_ACC:	DS	8*8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 10

AZAHARA:DB	"MADINAT AL-ZAHRA"		;LEVEL 10
L10_STR:DS	SIZLVLNAME - (L10_STR - AZAHARA) 
L10_PAL:DB	0
L10_GFX:DB	0
L10_1:	DS	8*8*2
L10_2:	DS	8*8*2
L10_3:	DS	8*8*2
L10_ACC:DS	8*8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 11

ZAHIRA:	DB	"MADINAT AL-ZAHIRA"		;LEVEL 11
L11_STR:DS	SIZLVLNAME - (L11_STR - ZAHIRA) 
L11_PAL:DB	0
L11_GFX:DB	0
L11_1:	DS	8*8*2
L11_2:	DS	8*8*2
L11_3:	DS	8*8*2
L11_ACC:DS	8*8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 12

BRIDGE:	DB	"BAB AL-QANTARA"		;LEVEL 12
L12_STR:DS	SIZLVLNAME - (L12_STR - BRIDGE) 
L12_PAL:DB	0
L12_GFX:DB	0
L12_1:	DS	8*8*2
L12_2:	DS	8*8*2
L12_3:	DS	8*8*2
L12_ACC:DS	8*8


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 13

SACUNDA:DB	"SACUNDA"			;LEVEL 13
L13_STR:DS	SIZLVLNAME - (L13_STR - SACUNDA) 
L13_PAL:DB	0
L13_GFX:DB	0
L13_1:	DS	8*8*2
L13_2:	DS	8*8*2
L13_3:	DS	8*8*2
L13_ACC:DS	8*8
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 14

GALLEGO:DB	"BAB AMIR AL-QURASI"		;LEVEL 14
L14_STR:DS	SIZLVLNAME - (L14_STR - GALLEGO) 
L14_PAL:DB	0
L14_GFX:DB	0
L14_1:	DS	8*8*2
L14_2:	DS	8*8*2
L14_3:	DS	8*8*2
L14_ACC:DS	8*8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEVEL 15

HIERRO:	DB	"IBN ABD AL-YABBAR"		;LEVEL 15
L15_STR:DS	SIZLVLNAME - (L15_STR - HIERRO) 
L15_PAL:DB	0
L15_GFX:DB	0
L15_1:	DS	8*8*2
L15_2:	DS	8*8*2
L15_3:	DS	8*8*2
L15_ACC:DS	8*8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	PUBLIC	CHARSDAT,DOORSDAT,CAMDAT

DOORSDAT:
	DS	NR_DOORS*SIZDINFO
CHARSDAT:
	DW	0,0			;WE NEED AT LEAST ONE USER CHARACTER
	DB	0,0,0,0,1,0
	DS	SIZCINFO*(NR_CHARS-1)
CAMDAT:	DB	-1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INCLUDE	PALETE.ASM
	INCLUDE	FONT.ASM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

END:	DS	CARTSEG+4000H-$,0



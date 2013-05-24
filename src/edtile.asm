
	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	EVENT.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	ED.TILE
	EXTRN	CLRVPAGE,EDINIT,VDPSYNC,LISTEN

ED.TILE:CALL	EDINIT
	LD	E,EDPAGE
	CALL	CLRVPAGE
	CALL	SHOWSCR
	CALL	VDPSYNC

	LD	DE,RECEIVERS
	CALL	LISTEN
	RET

RECEIVERS:
	DB	0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

SHOWSCR:RET






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	EDMAP
	EXTRN	EDINIT,VDPSYNC,LISTEN

EDMAP:	CALL	EDINIT


E.LOOP:	CALL	VDPSYNC
	LD	DE,RECEIVERS
	CALL	LISTEN
	JR	NZ,E.LOOP


RECEIVERS:
	DB	0

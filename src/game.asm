
	INCLUDE	SHIKE2.INC
	INCLUDE BIOS.INC
	INCLUDE KBD.INC
	INCLUDE	EDITOR.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	GAME
	EXTRN	INITMOB,NEWFRAME
	EXTRN	KBHIT

GAME:	CALL	INITMOB

G.LOOP: CALL	NEWFRAME
	CALL	KBHIT
	CP	KB_ESC
	JR	NZ,G.LOOP
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	PUBLIC	ENGINE
ENGINE:	RET


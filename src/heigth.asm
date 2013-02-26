
	INCLUDE	SHIKE2.INC
	INCLUDE	EDITOR.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = POINTER TO HEIGTH BUFFER

	CSEG
	PUBLIC	NEWHEIGTH
	EXTRN	BZERO

NEWHEIGTH:
	EX	DE,HL
	LD	BC,HEIGTHSIZ
	JP	BZERO




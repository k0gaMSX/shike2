
	INCLUDE	SHIKE2.INC
	INCLUDE	EDITOR.INC

	PUBLIC	LVLYSIZ
	PUBLIC	LVLXSIZ
	PUBLIC	LVLNAME
	PUBLIC	LVLROOM
	PUBLIC	LVLMAP
	PUBLIC	LVLHGT



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: A = NUMBER OF LEVEL


	CSEG
	PUBLIC	LEVEL

LEVEL:	ADD	A,7
	OUT	(0FEH),A
	RET





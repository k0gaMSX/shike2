10 SCREEN 5:CLS
11 PAINT(0,0),0,0
12 H=8:W=3:R=26
14 OX=64:OY=128+32
15 P1=OX:P2=OY:P3=R:P4=4:GOSUB 200
30 P1=OX:P2=OY:P3=R-H:P4=0:GOSUB 200
45 OY=32
50 P1=OX:P2=OY:P3=R:P4=5:GOSUB 200
80 P1=OX:P2=OY:P3=R-H:P4=0:GOSUB 200
90 COPY (0,0)-(255,128) TO (0+W*2,128+W),0,TPSET
160 BSAVE"circle.sr5",0,27143,S
170 GOTO 170
199 REM draw isometric circle in (p1,p2) with color p3
200 FOR I=0 TO 400
210 X=P3*COS(I)
220 Y=P3*SIN(I)
230 PSET(P1+(X-Y/2),P2+Y),P4
240 NEXT I
249 PAINT (P1,P2),P4
250 RETURN
999 SAVE"circle.bas",A

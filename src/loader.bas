1 IF PEEK(&HF677)=128 THEN POKE &HD000,0:POKE &HF677,&HD0:RUN"LOADER.BAS
10 SCREEN 5:CLS
11 BLOAD"LEVELDEF.BIN",R
12 BLOAD"PATSET0.BIN",R
13 BLOAD"PATSET1.BIN",R
14 BLOAD"CHARSET0.BIN",R
15 BLOAD"CHARSET1.BIN",R
16 BLOAD"MAP0.BIN",R
17 BLOAD"MAP1.BIN",R
18 BLOAD"MAP2.BIN",R
19 BLOAD"MAP3.BIN",R
20 BLOAD"HEIGHT0.BIN",R
21 BLOAD"HEIGHT1.BIN",R
998 CALL SYSTEM("SHIKE2.COM")
999 SAVE"LOADER.BAS",A

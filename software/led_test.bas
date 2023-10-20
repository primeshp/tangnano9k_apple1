
10 DIM A(6)
11 A(1)=1
12 A(2)=2
13 A(3)=4
14 A(4)=8
15 A(5)=16
16 A(6)=32
30 FOR i = 1 TO 6
40 POKE -12268,A(i)
45 gosub 80
60 next I
70 goto 30
75 REM 
80 FOR J=1 TO 1500
110  next j
120 RETurn

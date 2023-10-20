How to create and run a program

make sure you use .org to position at right memory location.
Create the a.out

Below modify 1%03 to reflect actual start address

hexdump -e '"1%03_ax: " 16/1 "%02X " "\n"' a.out | awk '{print toupper($0)}'
page the output on wozmon
R enter





(1) How to Build a program using CC65
CC65_HOME=/usr/local/share/cc65 cl65 -O -vm -m hello.map -t replica1 hello.c
hexdump -e '"1%03_ax: " 16/1 "%02X " "\n"' hello | awk '{print toupper($0)}'
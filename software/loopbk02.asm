; how to assemblle to have bin file
; vasm6502_oldstyle -Fbin -dotdir hello.asm
; to view bin file hexdump -C a.out

  .org $FF00

RESET:      
NEXTCHAR:
   lda $D011
   bpl NEXTCHAR
   lda $D010
   
ECHO:
   bit $D012
   bmi ECHO
   sta $D012 
   jmp NEXTCHAR

  
  .org $fffc
  .word RESET
  .word $0000

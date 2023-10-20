; how to assemblle to have bin file
; vasm6502_oldstyle -Fbin -dotdir hello.asm
; to view bin file hexdump -C a.out

; If RAM is working you should see 'A' on Serial terminal

  .org $FF00

RESET:      
   ;lda #'X' ; D
   ;sta $0200
   ;lda #'Y' ; E
   ;sta $0201
   ;lda #'Z' ; F
   ;sta $0202

   lda $0000 
ECHO:
   bit $D012
   bmi ECHO
   sta $D012 
   ;jmp NEXTCHAR
 
   lda $0001 
ECHO1:
   bit $D012
   bmi ECHO1
   sta $D012 
   ;jmp NEXTCHAR
   
   
   lda $0002 
ECHO2:
   bit $D012
   bmi ECHO2
   sta $D012 
   ;jmp NEXTCHAR
      


LOOP:
   jmp LOOP
   
  .org $fffc
  .word RESET
  .word $0000

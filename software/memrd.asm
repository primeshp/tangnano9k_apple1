; how to assemblle to have bin file
; vasm6502_oldstyle -Fbin -dotdir hello.asm
; to view bin file hexdump -C a.out

; If RAM is working you should see 'A' on Serial terminal
TEST_START = $0
;TEST_START = $0200

  .org $FF00

RESET:  
   LDY #$0
   LDA #33
UPDATE1:   
   STA TEST_START,Y
   INY
   ADC #01
   BNE UPDATE1

   LDY #$0
   LDA #65

   
GETNEXT:    
  lda #$80 
  bit $D011
  BPL GETNEXT
  lda $D010 
    
  lda TEST_START,y
  
ECHO:
   bit $D012
   bmi ECHO
   sta $D012
   INY 
 
   jmp GETNEXT
 

      


LOOP:
   jmp LOOP
   
  .org $FFFC
  .word RESET
  .word $0000

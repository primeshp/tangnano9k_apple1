; how to assemblle to have bin file
; vasm6502_oldstyle -Fbin -dotdir hello.asm
; to view bin file hexdump -C a.out

; If RAM is working you should see 'A' on Serial terminal
TEST_START = $0
;TEST_START = $0200

ADDR0 = $2A
ADDR1 = $2B
STORE = $0200

  .org $FF00

RESET: 

  LDA #'P' ; Print P
ECHO2:
   bit $D012
   bmi ECHO2
   sta $D012


  LDA #'Z'
  STA $200    ; Memory location $200 has 'Z';

  LDA #$00
  STA ADDR0
  LDA #$02
  STA ADDR1
  LDA #'T'    ; Just to make sure
  LDY #00

  LDA (ADDR0),Y 

ECHO3:
   bit $D012
   bmi ECHO3
   sta $D012  

  LDA #'N'
  STA $200    ; Memory location $200 has 'Z';

  LDA #$00
  STA ADDR0
  LDA #$02
  STA ADDR1
  LDA #'T'    ; Just to make sure
  LDY #00

  LDA (ADDR0),Y 

ECHO4:
   bit $D012
   bmi ECHO4
   sta $D012  


  LDA #$80  ; Save Indirect Address to Zero page
  STA ADDR0
  LDA #$FF
  STA ADDR1
  LDA #'X'
  JMP (ADDR0) ; Indirect Address Jump
  
loop2:
   jmp loop2



  .org $FF80
  
ECHO:
   bit $D012
   bmi ECHO
   sta $D012

loop:
   jmp loop
 

 

   
  .org $FFFC
  .word RESET
  .word $0000

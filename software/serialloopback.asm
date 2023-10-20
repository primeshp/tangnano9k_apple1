; how to assemblle to have bin file
; vasm6502_oldstyle -Fbin -dotdir hello.asm
; to view bin file hexdump -C a.out

  .org $FF00
reset:
  lda #$80  
  ldx #$5C  ; load immidiate value
next_char:
  bit $D012 ; Read Dsiplay 
  bmi next_char ; Is Display Busy
  ;inx
  stx $D012  ; store to address
  
cha_rxed:  
  lda #$80 
  bit $D011
  beq cha_rxed  
  
  ldx $D010
  
  lda #$80 
next_char2:
  bit $D012 ; Read Dsiplay 
  bmi next_char2 ; Is Display Busy
  ;inx
  stx $D012  ; store to address 
  
  


loop  
  jmp cha_rxed  ;reset
  
  .org $fffc
  .word reset
  .word $0000

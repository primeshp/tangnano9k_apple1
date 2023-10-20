; how to assemblle to have bin file
; vasm6502_oldstyle -Fbin -dotdir hello.asm
; to view bin file hexdump -C a.out
  .org $0000
reset:
  lda #$80  
  ldx #64  ; load immidiate value
next_char:
  bit $D012 ; Read Dsiplay 
  bmi next_char ; Is Display Busy
  inx
  stx $D012  ; store to address
  cpx #90    ; Char Z
  bne next_char
  jmp $FF00 
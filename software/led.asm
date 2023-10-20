; how to assemblle to have bin file
; vasm6502_oldstyle -Fbin -dotdir hello.asm
; to view bin file hexdump -C a.out

  .org $FF00
reset:
 
  lda #$00   ; load immidiate value
  sta $D010  ; store to address
disp_wait:
  bit $D012  ; Check if negative
  bpl display
  jmp disp_wait
display:  
  lda #68   ; load immidiate value
  sta $D011  ; store to address
  jmp disp_wait


loop:
  jmp loop  
  
  .org $fffc
  .word reset
  .word $0000

; how to assemblle to have bin file
; vasm6502_oldstyle -Fbin -dotdir hello.asm
; to view bin file hexdump -C a.out

  .org $FF00
reset:
 
  lda #$00   ; load immidiate value
  sta $D010  ; store to address
  
  lda #65   ; load immidiate value
  sta $D011  ; store to address

loop:
  jmp loop  
  
  .org $fffc
  .word reset
  .word $0000

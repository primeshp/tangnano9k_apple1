; how to assemblle to have bin file
; vasm6502_oldstyle -Fbin -dotdir hello.asm
; to view bin file hexdump -C a.out

  .org $FF00
reset:
  lda #$ff   ; load immidiate value
  sta $6002  ; store to address

  
  lda #$50
  sta $6000

loop:
  ror  
  sta $6000
  
  jmp loop  
  
  .org $fffc
  .word reset
  .word $0000

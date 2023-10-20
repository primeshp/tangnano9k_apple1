; how to assemblle to have bin file
; vasm6502_oldstyle -Fbin -dotdir hello.asm
; to view bin file hexdump -C a.out

IN              = $0200         ;  Input buffer to $027F
KBD             = $D010         ;  PIA.A keyboard input
KBDCR           = $D011         ;  PIA.A keyboard control register
DSP             = $D012         ;  PIA.B display output register
DSPCR           = $D013         ;  PIA.B display control register

  .org $FF00
RESET:
  lda #203; load immidiate value A
  jsr ECHO
  lda #205  ; load immidiate value B
  jsr ECHO
  lda #207  ; load immidiate value C
  jsr ECHO
  

loop:  
  jmp loop  
  

ECHO:
  bit $D012 ; Read Dsiplay 
  bmi ECHO; Is Display Busy
  sta $D012  ; store to address
  rts
  
loop2:  
  jmp loop2  
  
  .org $fffc
  .word RESET
  .word $0000

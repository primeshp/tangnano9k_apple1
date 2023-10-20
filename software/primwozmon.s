;  The WOZ Monitor for the Apple 1
;  Written by Steve Wozniak in 1976


; Page 0 Variables

XAML            = $24           ;  Last "opened" location Low
XAMH            = $25           ;  Last "opened" location High
STL             = $26           ;  Store address Low
STH             = $27           ;  Store address High
L               = $28           ;  Hex value parsing Low
H               = $29           ;  Hex value parsing High
YSAV            = $2A           ;  Used to see if hex value is given
MODE            = $2B           ;  $00=XAM, $7F=STOR, $AE=BLOCK XAM


; Other Variables

IN              = $0200         ;  Input buffer to $027F
KBD             = $D010         ;  PIA.A keyboard input
KBDCR           = $D011         ;  PIA.A keyboard control register
DSP             = $D012         ;  PIA.B display output register
DSPCR           = $D013         ;  PIA.B display control register

               .org $FF00
               ;.export RESET

RESET:          CLD             ; Clear decimal arithmetic mode.
                CLI
                LDY #$7F        ; Primesh Change from 7F Mask for DSP data direction register.
                NOP
                NOP
                ;STY DSP         ; Set it up.
                LDA #$A7        ; KBD and DSP control register mask.
                NOP
                NOP
                NOP
                ;STA KBDCR       ; Enable interrupts, set CA1, CB1, for
                NOP
                NOP
                NOP
                ;STA DSPCR       ; positive edge sense/output mode.
NOTCR:          CMP #$88        ; Primesh Changed from #$DF "_"?
                BEQ BACKSPACE   ; Yes.
                CMP #$9B        ; ESC?
                BEQ ESCAPE      ; Yes.
                INY             ; Advance text index.
                BPL NEXTCHAR    ; Auto ESC if > 127.
ESCAPE:         LDA #'\'+$80    ; "\".
                JSR ECHO        ; Output it.
GETLINE:        LDA #$8D        ; CR.
                JSR ECHO        ; Output it.I get a 
                LDY #$01        ; Initialize text index.
BACKSPACE:      DEY             ; Back up text index.
                BMI GETLINE     ; Beyond start of line, reinitialize.
NEXTCHAR:       LDA KBDCR       ; Key ready?
                BPL NEXTCHAR    ; Loop until ready.
                LDA KBD         ; Load character. B7 should be ‘1’.
                STA IN,Y        ; Add to text buffer.
                JSR ECHO        ; Display character.
                CMP #$8D        ; CR?
                BNE NOTCR       ; No.

   LDY #$0 
   
GETNEXT:    
  lda #$80 
  bit $D011
  BPL GETNEXT
  ldx $D010 
    
  lda $0200,y
  
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
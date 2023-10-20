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
   ; This write printerble characters to memory at $200  
   LDX #$0
   LDY #33
UPDATE:   
   STY $0200,X
   INY
   INX
   BNE UPDATE 
   
   
 
   ; This write printerble characters to memory at $200  
   LDX #$0
   LDY #48
UPDATE2:   
   STY $20,X
   INY
   INX
   BNE UPDATE2 

 



loop:  
  jmp loop  



PRBYTE:         PHA             ; Save A for LSD.
                LSR
                LSR
                LSR             ; MSD to LSD position.
                LSR
                JSR PRHEX       ; Output hex digit.
                PLA             ; Restore A.
PRHEX:          AND #$0F        ; Mask LSD for hex print.
                ORA #'0'+$80    ; Add "0".
                CMP #$BA        ; Digit?
                BCC ECHO        ; Yes, output it.
                ADC #$06        ; Add offset for letter.
ECHO:           BIT DSP         ; bit (B7) cleared yet?
                BMI ECHO        ; No, wait for display.
                STA DSP        ; Output character. Sets DA.
                RTS             ; Return.

                BRK             ; unused
                BRK             ; unused

; Interrupt Vectors
                .org $fffc
                .WORD $0F00     ; NMI
                .WORD RESET     ; RESET
                .WORD $0000     ; BRK/IRQ

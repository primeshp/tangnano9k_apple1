	.org $FF00	; starting address

h_Reset:
Start: 
      	sei
	    cld
	    ldx #$ff
        txs

CmdLoop:
        jsr GetChar
        jmp CmdLoop


GetChar:
    lda #$80
	bit $D011
	bpl GetChar
	sta $D010
	;and #$7f
PutChar:
	bit $D012
	bmi PutChar
	ora #0x80
	sta $D012
	and #$7f ; Primesh Moved from GetChar
    rts

  .org $FFFC
  .word h_Reset
  .word $0000
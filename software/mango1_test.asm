
Temp = $2a
Addr = $2c

	
	.org $FF00	; starting address

h_Reset:
Start:
	sei
	cld
	ldx #$FF
        txs

DoCommand:
        lda #'>'
        JSR PutChar
        LDA #$23
        Sta Addr+1
        LDA #$45
        sta Addr
        ;jsr PutHexAddr
	LDA Addr+1
        JSR PutHexByte
        LDA Addr
        JSR PutHexByte
        NOP

        lda #'>'
        JSR PutChar
        LDA #$57
        sta Addr+1
        LDA #$68
        Sta Addr
        NOP
        ;jsr PutHexAddr
	LDA Addr+1
        JSR PutHexByte
        LDA Addr
        JSR PutHexByte

        lda #'>'
        JSR PutChar
        LDA #$89
        sta Addr+1
        LDA #$90
        Sta Addr
        NOP
        ;jsr PutHexAddr
	LDA Addr+1
        JSR PutHexByte
        LDA Addr
        JSR PutHexByte


loop:   JMP loop        

        ;end the testing



GetHexWord:
	lda #0
        sta Addr
        sta Addr+1
	jsr GetHexDigit
        bcs Bailout
        beq GetHexWord	; eat leading zeroes
NextHexDigit:
        asl
        asl
        asl
        asl
	ldy #4
ShiftAddr:
        asl
        rol Addr
        rol Addr+1
        dey
        bne ShiftAddr
	jsr GetHexDigit
        bcs Bailout
        jmp NextHexDigit
GetHexByte:
	jsr GetHexDigit
        bcs Bailout
        asl
        asl
        asl
        asl
        sta Temp
	jsr GetHexDigit
        bcs Bailout
        ora Temp
Success:
	clc
        rts
GetHexDigit:
	jsr GetChar
        sec
        sbc #'0'
        cmp #10
        bcc Return
        sbc #('A'-'0')	; carry already set
        cmp #6
        bcs Bailout
        clc
        adc #10
        rts
Bailout:
        lda #'B'
        jsr PutChar
	sec
Return:
        rts
PutCR:
        lda #13
        jmp PutChar
GetChar:
        lda #$80
	bit $D011
	bpl GetChar
	lda $D010
	and #$7f
PutChar:
        ;ora #$80
	bit $D012
	bmi PutChar
	sta $D012
	;and #$7f ; Primesh Moved from GetChar
        rts
PutHexAddr:
	lda Addr+1
        jsr PutHexByte
        lda Addr

PutHexByte:
	pha
        lsr
        lsr
        lsr
        lsr
        jsr PutHexDigit
        pla
        
PutHexDigit:
	and #$0f
        clc
        adc #'0'
        cmp #':'
        bcc PutChar
        adc #'A'-':'-1
        bcc PutChar
IncAddr:
	inc Addr
        bne Return
        inc Addr+1
        rts
h_BRK:
;	jsr PutChar
h_NMI:
	rti

	.org $FFFA
Vectors:
        .word h_NMI
        .word h_Reset
        .word h_BRK

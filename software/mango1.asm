
Temp = $2a
Addr = $2c

	
	.org $FF00	; starting address

h_Reset:
Start:
	sei
	cld
	ldx #$ff
        txs
CmdLoop: 
        jsr DoCommand
	jmp CmdLoop	; endless loop
DoCommand:
        jsr PutCR
	lda #"#"	; prompt
        jsr PutChar
	jsr GetChar
        cmp #'R'
        beq DumpBytes
        cmp #'W'
        beq WriteBytes
        cmp #'G'
        beq GotoAddr
        cmp #13
        beq DumpNext
Invalid:
	jsr PutCR
        lda #'?'
        jsr PutChar
        jmp Start
DumpBytes:
	jsr GetHexWord
DumpNext:
        jsr PutHexAddr
        lda #':'
        jsr PutChar
DumpLoop:
        lda #' '
        jsr PutChar
        ldy #0
        lda (Addr),y
        jsr PutHexByte
        jsr IncAddr
        lda Addr
        and #$07
        bne DumpLoop
	rts
WriteBytes:
	jsr GetHexWord
        lda #':'
        jsr PutChar
        jsr GetHexByte
        ldy #0
        sta (Addr),y
	rts
GotoAddr:
	jsr GetHexWord
        jmp (Addr)

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
	sec
        ;CLC
Return:
        rts
PutCR:   ; This corrupts A content
        lda #13
        jmp PutChar
GetChar:
	bit $D011
	bpl GetChar
	lda $D010
	and #$7f


PutChar:
	bit $D012
	bmi PutChar
	sta $D012
        rts
PutHexAddr:                   ; not working
	lda Addr+1
        jsr PutHexByte
        lda Addr
PutHexByte:                    ;working
	pha
        lsr
        lsr
        lsr
        lsr
        jsr PutHexDigit
        pla
PutHexDigit:                    ;working
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

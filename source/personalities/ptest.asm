

	.if TARGET=1
	.include 	"personality_mega65.asm"
	.endif
	.if TARGET=2
	.include 	"personality_6502.asm"
	.endif
	.include	"personality_io.asm"

Start:
	jsr 	IOInitialise
	ldx 	#St1 & 255
	ldy 	#St1 >> 8
	jsr 	IOPrintString
Loop:
	ldx 	#$80
	ldy 	#$00
	jsr		IOReadLine	
	.byte 	3
	bra 	Loop

St1:.text 	"7167 BYTES FREE",0

	#EXTEndCode	
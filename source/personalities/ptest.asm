

	.if TARGET=1
	.include 	"personality_mega65.asm"
	.endif
	.if TARGET=2
	.include 	"personality_6502.asm"
	.endif

Start:
	lda 	#0
	tax
	tay
SLoop:
	txa	
	and 	#$7F
	jsr 	EXTWriteScreen
	inx
	bne 	SLoop
	iny 	
	cpy 	#8
	bne 	SLoop

WaitKey:
	jsr 	EXTReadKey
	ora 	#0
	beq 	WaitKey
	pha	
	jsr 	EXTScrollDisplay
	sta 	EXTScreen+0
	bra 	WaitKey

	#EXTEndCode	
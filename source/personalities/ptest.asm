


	.include 	"personality_mega65.asm"

Start:
	lda 	#0
	tax
	tay
SLoop:
	txa	
	and 	#$7F
;	jsr 	EXTWriteScreen
	inx
	bne 	SLoop
	iny 	
	cpy 	#8
	bne 	SLoop
	jsr 	EXTScrollDisplay
Start2:
	clc
	adc 	#1
	sta 	EXTScreen+2
	sta 	EXTScreen+4
	bra 	Start2

	#EXTEndCode	



	.include 	"personality_mega65.asm"

Start:
	clc
	adc 	#1
	sta 	EXTScreen+2
	sta 	EXTScreen+4
	bra 	Start

	#EXTEndCode	
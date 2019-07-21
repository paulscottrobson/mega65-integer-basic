		
		* = 	$0000
		.byte 	0

vwrite 	.macro
		ldz 	#\1
		lda 	#\2
		nop
		sta 	($04),z
.endm

		* = 	$F000
Start:		
		lda 	#$0F 						; set up to write to video system.
		sta 	$07
		lda 	#$FD
		sta 	$06
		lda 	#$30
		sta 	$05
		lda 	#$00
		sta 	$04

		#vwrite $30,$40 					; Charset
		#vwrite $20,$00 					; border
		#vwrite $21,$00	 					; background
		#vwrite $6F,$60						; 60Hz

		#vwrite $18,$42	 					; screen address $0800 video address $2000
		#vwrite $11,$1B
		#vwrite $16,$C8

		#vwrite $54,$C5
		#vwrite $58,80
		#vwrite $59,0

		#vwrite $00,$FF
		#vwrite $01,$FF

		#vwrite $30,4
		#vwrite $70,$FF

		lda 	#$00						; colour RAM at $1F800-1FFFF (2kb)
		sta 	$0B 						; char RAM appears to be here.
		lda 	#$01
		sta 	$0A
		lda 	#$F9
		sta 	$09
		lda 	#$00
		sta 	$08
		ldz 	#0
SetColorRam:	
		tza
		nop
		sta 	($08),z
		dez
		bne 	SetColorRam


Screen = $1000								; 2k screen RAM here

		ldx 	#0
Clear2:
		txa
		and 	#1									; odd bits write zero
		eor 	#1
		beq 	_CL2Write
		txa
		;and 	#2
		lsr 	a
_CL2Write:									
		sta 	Screen,x
		sta 	Screen+$100,x
		sta 	Screen+$200,x
		sta 	Screen+$300,x
		sta 	Screen+$400,x
		sta 	Screen+$500,x
		sta 	Screen+$600,x
		sta 	Screen+$700,x
		inx
		bne 	Clear2

CSet = $800

		ldx 	#0
CopyPetFont:
		lda 	PETFont,x
		sta 	CSet,x
		lda 	PETFont+$100,x
		sta 	CSet+$100,x
		lda 	PETFont+$200,x
		sta 	CSet+$200,x
		lda 	PETFont+$300,x
		sta 	CSet+$300,x
		dex
		bne 	CopyPetFont

Halt:	inx
		bra 	Halt

Dummy:	rti

PETFont:
		.binary "c64-chargen.rom"
		rts

		* = 	$FFFA
		.word 	Dummy
		.word 	Start		
		.word 	Dummy

; ******************************************************************************
; ******************************************************************************
;
;		Name: 		personality_mega65.asm
;		Purpose:	Mega65 Personality Code
;		Date: 		22nd July 2019
;		Author:		Paul Robson
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;								Constants
;
; ******************************************************************************

EXTWidth = 40 								; screen width
EXTHeight = 24 								; screen height

; ******************************************************************************
;
;							Memory Allocation
;
; ******************************************************************************

EXTZPWork = 4								; Zero Page work for EXT

EXTZeroPage = $10 							; Zero Page allocated from here
EXTNonZeroPage = $2000 						; Non-Zero page allocated from here
EXTEndOfMemory = $4000 						; Memory ends.

EXTScreen = $1000							; 2k screen RAM here
EXTCharSet = $800							; 2k character set (0-7F) here

EXTAltSpace = 64

; ******************************************************************************
;
;				Initialisation, Vector Tables, Character Set
;
; ******************************************************************************

	* = 0
	.word 	0 								; forces it to be a 128k ROM (at least)

	* = 	$FFFA 							; create the vectors.
	.word 	EXTDummyInterrupt
	.word 	EXTStartPersonalise
	.word 	EXTDummyInterrupt

	* = 	$A000							; put the font at $A000
EXTCBMFont:
	.binary "c64-chargen.rom"

	* = 	$E000

EXTDummyInterrupt:							; interrupt that does nothing.
	rti

; ******************************************************************************
;
;			Macro which resets the 65x02 stack to its default value.
;
; ******************************************************************************

EXTResetStack: .macro
	ldx 	#$FF 							; reset 6502 stack.
	txs
	.endm

; ******************************************************************************
;
;		Set up code. Initialise everything except the video code (done
;		by ExtReset. Puts in Dummy NMI,IRQ and Reset vectors is required
;		Code will start assembly after this point via "jmp Start"
;
; ******************************************************************************

EXTStartPersonalise:	
	#EXTResetStack							; reset stack
	jsr 	EXTReset 						; reset video
	jsr 	EXTClearScreen 					; clear screen
	jmp 	Start 							; start main application

; ******************************************************************************
;
;		Macro called at the end of assembly to pad the ROM out to the
;		relevant size and any other tidying up.
;
; ******************************************************************************

EXTEndCode:	.macro 							; don't need to do anything.
	.endm

; ******************************************************************************
;
;		Read a key from the keyboard buffer, or whatever. This should return
;		non-zero values once for every key press (e.g. a successful read
;		removes the key from the input Queue)
;
; ******************************************************************************

EXTReadKey:
	lda 	#0
	rts

; ******************************************************************************
;
;		Read a byte from the screen (C64 codes, e.g. @ = 0) at XY -> A
;
; ******************************************************************************

EXTReadScreen:
	rts

; ******************************************************************************
;
;	   Write a byte A to the screen (C64 codes, e.g. @ = 0) at XY 
;
; ******************************************************************************

EXTWriteScreen:
	rts

; ******************************************************************************
;
;								Clear the screen
;
; ******************************************************************************

EXTClearScreen:
	pha 										; save registers
	phy
	lda 	#EXTScreen & $FF 					; set up pointer
	sta 	EXTZPWork
	lda 	#EXTScreen >> 8
	sta 	EXTZPWork+1
	ldy 	#0
_EXTCSLoop:
	lda 	#EXTAltSpace
	sta 	(EXTZPWork),y
	iny
	lda 	#0
	sta 	(EXTZPWork),y
	iny 	
	bne 	_EXTCSLoop
	inc 	EXTZPWork+1 						; next screen page	
	lda 	EXTZPWork+1
	cmp 	#(EXTScreen>>8)+8 					; done 2k ?
	bne 	_EXTCSLoop
	ply 										; restore
	pla
	rts

; ******************************************************************************
;
;					Scroll the whole display up one line.
;
; ******************************************************************************

EXTScrollDisplay:
	rts	

; ******************************************************************************
;
;						 Reset the Display System
;
; ******************************************************************************

EXTWrite 	.macro 							; write to register using
	ldz 	#\1 							; address already set up
	lda 	#\2
	nop
	sta 	(EXTZPWork),z
.endm

EXTReset:
	pha 									; save registers
	phx
	phy
	lda 	#$0F 							; set up to write to video system.
	sta 	EXTZPWork+3
	lda 	#$FD
	sta 	EXTZPWork+2
	lda 	#$30
	sta 	EXTZPWork+1
	lda 	#$00
	sta 	EXTZPWork+0

	#EXTWrite $30,$40 						; Charset
	#EXTWrite $20,$00 						; border
	#EXTWrite $21,$00	 					; background
	#EXTWrite $6F,$60						; 60Hz

	#EXTWrite $18,$42	 					; screen address $0800 video address $2000
	#EXTWrite $11,$1B
	#EXTWrite $16,$C8

	#EXTWrite $54,$C5
	#EXTWrite $58,80
	#EXTWrite $59,0

	#EXTWrite $00,$FF
	#EXTWrite $01,$FF

	#EXTWrite $30,4
	#EXTWrite $70,$FF

	lda 	#$00							; colour RAM at $1F800-1FFFF (2kb)
	sta 	EXTZPWork+3 
	lda 	#$01
	sta 	EXTZPWork+2
	lda 	#$F8
	sta 	EXTZPWork+1
	lda 	#$00
	sta 	EXTZPWork+0
	ldz 	#0
_EXTClearColorRam:	
	lda 	#8 								; fill that with this colour.
	nop
	sta 	(EXTZPWork),z
	dez
	bne 	_EXTClearColorRam
	inc 	EXTZPWork+1
	bne 	_EXTClearColorRam

	ldx 	#0 								; copy PET Font into memory.
_EXTCopyCBMFont:
	lda 	EXTCBMFont,x
	sta 	EXTCharSet,x
	lda 	EXTCBMFont+$100,x
	sta 	EXTCharSet+$100,x
	lda 	EXTCBMFont+$200,x
	sta 	EXTCharSet+$200,x
	lda 	EXTCBMFont+$300,x
	sta 	EXTCharSet+$300,x
	dex
	bne 	_EXTCopyCBMFont
	ply 									; restore and exit.
	plx
	pla
	rts

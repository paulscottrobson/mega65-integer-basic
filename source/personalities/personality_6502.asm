; ******************************************************************************
; ******************************************************************************
;
;		Name: 		personality_6502.asm
;		Purpose:	Personality Code for Development Platform.
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
EXTHeight = 25 								; screen height

; ******************************************************************************
;
;							Memory Allocation
;
; ******************************************************************************

EXTZPWork = 4								; Zero Page work for EXT

EXTZeroPage = $10 							; Zero Page allocated from here
EXTNonZeroPage = $1000 						; Non-Zero page allocated from here
EXTEndOfMemory = $8000 						; Memory ends.

EXTScreen = $F000							; 1k screen RAM here

EXTAltSpace = 64

; ******************************************************************************
;
;				Initialisation, Vector Tables, Character Set
;
; ******************************************************************************

	* = $C000
	.word 	0 								; forces it to be a 16k ROM

	* = 	$FFFA 							; create the vectors.
	.word 	EXTDummyInterrupt
	.word 	EXTStartPersonalise
	.word 	EXTDummyInterrupt

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
	lda 	$F800 								; read key
	beq 	_EXTExit
	pha 										; key pressed clear queue byte.
	lda 	#0
	sta 	$F800
	pla
_EXTExit:	
	rts

; ******************************************************************************
;
;		Read a byte from the screen (C64 codes, e.g. @ = 0) at XY -> A
;
; ******************************************************************************

EXTReadScreen:
	phy 										; save Y
	stx 	EXTZPWork							; into EXTZPWork
	tya
	ora 	#EXTScreen>>8 						; move into screen area
	sta 	EXTZPWork+1 						; read character there
	ldy 	#0
	lda 	(EXTZPWork),y
	ply 										; restore Y and exit.
	rts

; ******************************************************************************
;
;	   Write a byte A to the screen (C64 codes, e.g. @ = 0) at XY 
;
; ******************************************************************************

EXTWriteScreen:
	phy
	pha
	jsr		EXTReadScreen 						; set up the address into EXTZPWork
	ldy 	#0
	pla 										; restore and write.
	sta 	(EXTZPWork),y
	ply
	rts

; ******************************************************************************
;
;								Clear the screen
;
; ******************************************************************************

EXTClearScreen:
	pha 										; save registers
	phx
	ldx 	#0
_EXTCSLoop:
	lda 	#EXTAltSpace
	sta 	EXTScreen+0,x
	sta 	EXTScreen+1,x
	sta 	EXTScreen+2,x
	sta 	EXTScreen+3,x
	inx	
	bne 	_EXTCSLoop
	plx 										; restore
	pla
	rts

; ******************************************************************************
;
;					Scroll the whole display up one line.
;
; ******************************************************************************


EXTScrollDisplay:
	pha 										; save registers
	phy
	lda 	#EXTScreen & $FF 					; set pointer to screen
	sta 	EXTZPWork+0
	lda 	#EXTScreen >> 8
	sta 	EXTZPWork+1
_EXTScroll:	
	ldy 	#EXTWidth
	lda 	(EXTZPWork),y
	ldy 	#0
	sta 	(EXTZPWork),y
	inc 	EXTZPWork 							; bump address
	bne 	_EXTNoCarry
	inc 	EXTZPWork+1
_EXTNoCarry:
	lda 	EXTZPWork 							; done ?
	cmp	 	#(EXTScreen+EXTWidth*(EXTHeight-1)) & $FF
	bne 	_EXTScroll
	lda 	EXTZPWork+1
	cmp	 	#(EXTScreen+EXTWidth*(EXTHeight-1)) >> 8
	bne 	_EXTScroll
	;
	ldy 	#0									; clear bottom line.
_EXTLastLine:
	lda 	#EXTAltSpace
	sta 	(EXTZPWork),y
	iny
	cpy 	#EXTWidth
	bne 	_EXTLastLine	
	ply 										; restore and exit.
	pla
	rts	

; ******************************************************************************
;
;						 Reset the Display System
;
; ******************************************************************************

EXTReset:
	rts


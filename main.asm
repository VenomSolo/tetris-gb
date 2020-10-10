INCLUDE "hardware.inc"
POS EQU $FFA0
OPOS EQU $FFA1
H_JOY EQU $fff8
H_JOYOLD EQU $fff9
H_JOYNEW EQU $fffA


SECTION "Header", ROM0[$100] ;

EntryPoint:	
	ei
	jp Start 
	
REPT $150 - $104
	db 0
ENDR

SECTION "Interrupts", ROM0[$A0]

TimerInterrupt:
.update
	ld a, [rLY]
	cp 144
	jr c, .update
	ld hl, $FE01
	ld a, [hl]
	inc a
	ld [hl], a
	ei
	call .lockup
	
.lockup
    jr .lockup


SECTION "Game Code", ROM0[$200]
	
Start:
.waitVBlank
	ld a, [rLY]
	cp 144
	jr c, .waitVBlank

	xor a
	ld [rLCDC], a
	
	ld hl, $8800
	ld de, Tiles
	ld bc, TilesEnd-Tiles
.prepareTiles
	ld a, [de]
	ld [hl], a
	inc hl
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .prepareTiles
	
	;ld hl, $9800
	;ld a, 128
	;ld [hl], a
.renderOnePiece
	ld a, 32
	ld hl, $FE00
	ld [hli], a
	ld a, 16
	ld [hli], a
	ld a, 128
	ld [hli], a
	ld a, 0
	ld [hli], a
	
	; Init display registers
    ld a, %11100100
	ld [rOBP0], a
    ld [rBGP], a

    xor a ; ld a, 0
    ld [rSCY], a
    ld [rSCX], a

    ; Shut sound down
    ld [rNR52], a

	call .prepareTimer
    ; Turn screen on, display background
    ld a, %10000011
    ld [rLCDC], a
.lockup
    jr .lockup
	
.prepareTimer
	ld hl, $FFFF
	ld a, %00000100
	ld [hl], a
	ld hl, $FF07 ; timer TAC
	ld a, %00000100
	ld [hl], a
	ld a, $A0
	ld hl, $0050
	ld [hl], a
	ret
	
.update
	ld a, [rLY]
	cp 144
	jr c, .update
	ld hl, $FE01
	ld a, [hl]
	inc a
	ld [hl], a
	call .lockup
	
.waitVBlankOnce
	ld a, [rLY]
	cp 144
	jr c, .waitVBlank
	ret
	
SECTION "Tiles", ROM0

Tiles:
	; 1
	dw %1111111111111111
REPT 6
	dw %1111111110000001
ENDR
	dw %1111111111111111
	; 2
	dw %1111111111111111
	dw %1000000111111111
	dw %1000000111111111
	dw %1001100111111111
	dw %1001100111111111
	dw %1000000111111111
	dw %1000000111111111
	dw %1111111111111111
	; 3
	dw %1111111111111111
	dw %1000000111111111
	dw %1011110111111111
	dw %1010010111100111
	dw %1010010111100111
	dw %1011110111111111
	dw %1000000111111111
	dw %1111111111111111
	
TilesEnd:
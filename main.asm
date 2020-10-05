INCLUDE "hardware.inc"
POS EQU $FFA0
OPOS EQU $FFA1
H_JOY EQU $fff8
H_JOYOLD EQU $fff9
H_JOYNEW EQU $fffA


SECTION "Header", ROM0[$100] ;

EntryPoint:	
	di 
	jp Start 
	
REPT $150 - $104
	db 0
ENDR

SECTION "Game Code", ROM0
	
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
	
	; Init display registers
    ld a, %11100100
    ld [rBGP], a

    xor a ; ld a, 0
    ld [rSCY], a
    ld [rSCX], a

    ; Shut sound down
    ld [rNR52], a

    ; Turn screen on, display background
    ld a, %10000001
    ld [rLCDC], a
.lockup
    jr .lockup
	
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
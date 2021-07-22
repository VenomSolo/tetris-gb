INCLUDE "hardware.inc"
INCLUDE "sprite_tiles.inc"
; INCLUDE "tetromino.asm"
INCLUDE "variables.inc"
INCLUDE "interrupts.inc"


SECTION "Header", ROM0[$100] ;

EntryPoint:	
	di
	jp Start 
	
REPT $150 - $104
	db 0
ENDR

SECTION "Game Code", ROM0[$200]
	
Start:
	xor a
	ld [FRAMES_COUNT], a
.waitVBlank
	ld a, [rLY]
	cp 144
	jr c, .waitVBlank

	xor a
	ld [rLCDC], a
	call .loadTiles
	call GenerateMap
	
	jr .renderOnePiece
	
	
	;ld hl, $9800
	;ld a, 128
	;ld [hl], a
.renderOnePiece
	ld a, 64
	ld [BLOCK_X], a
	ld [BLOCK_Y], a
	ld a, 0
	ld [CURRENT_BLOCK], a
	;call .waitUntilNextVBlank
	call .clearOAM
	call renderTetromino
	
	; Init display registers
	; Colors palettes
    ld a, %11100100 
	ld [rOBP0], a ; objects palette
    ld [rBGP], a ; background palette

    xor a ; ld a, 0
    ld [rSCY], a ; screen Y scroll
    ld [rSCX], a ; screen X scroll

    ; Shut sound down
    ld [rNR52], a

	;call .prepareTimer
    ; Turn screen on, display background
    ld a, %10000011
    ld [rLCDC], a
	
	ei
.update ; wait for VBlank
	ld a, [rLY] ;sprawdzamy linie
	cp 144 ; porównujemy z 144
	jr c, .update	;jeśli jest mniejsza, powtarzamy
.shit
	ld hl, FRAMES_COUNT ;bierzemy liczbę "klatek"
	ld a, [hl] ;i wsadzamy ją do A
	inc a	;inkrementujemy
	ld [hl], a	;i wsadzamy z powrotem na swoje miejsce
	cp FRAMES_PER_TICK ;porównujemy z naszym ogarnicznikiem
	jr c, .lockup ;jeśli jest mniesza, to czekamy kolejną klatkę
	xor a ;jeśli nie - zerujemy
	ld [hl], a ;i zapisujemy to 0 w pamieci
	ld hl, $FE00
	ld b, 4
.letTheBlocksFall
	ld a, [hl]
	add a, 8
	;inc a
	ld [hl], a	
	ld a, l
	add a, 4
	ld l, a
	dec b
	jr nz, .letTheBlocksFall
	call .randomBlock
	ld hl , $FF00
.lockup ; wait for next frame
	ld [hl], %00010000
	ld a, [rLY]
	cp 152
	jr c, .lockup
    jr .update
	
	
.waitUntilNextVBlank
.waitnext ; wait for next frame
	ld a, [rLY]
	cp 152
	jr c, .lockup
.waitblank
	ld a, [rLY]
	cp 144
	jr c, .waitblank
	ret
	
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
	

	
.waitVBlankOnce
	ld a, [rLY]
	cp 144
	jr c, .waitVBlankOnce
	ret
	
.randomBlock
	ld hl, NEXT_BLOCK
	ld a, [rDIV] ; divider register
	and %00000111 ; 
	jr z, .randomBlock
	ld [hl], a
	ret
	
	
.loadTiles
	ld hl, $8800 ; tiledata starting point
	ld de, Tiles ; tiles starting point
	ld bc, TilesEnd-Tiles ; tiles count
.prepareTiles
	ld a, [de]
	ld [hl], a ; move starting point from de to hl
	inc hl
	inc de
	dec bc ; decrement counter
	ld a, b ; check if counter equals 0 <- only when b or c returns zero
	or c
	jr nz, .prepareTiles ; go back if there are tiles in queue
	ret
	
.clearOAM
	ld hl, $FE10
REPT 36*4
    ld [hl], 131
	inc hl
ENDR
	ret
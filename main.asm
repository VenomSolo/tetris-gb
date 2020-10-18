INCLUDE "hardware.inc"
H_JOY EQU $fff8
H_JOYOLD EQU $fff9
H_JOYNEW EQU $fffA
FRAMES_PER_TICK EQU 255
FRAMES_COUNT EQU $ffa0
NEXT_BLOCK EQU $C100
CURRENT_BLOCK EQU $C101
BLOCK_X EQU $C102
BLOCK_Y EQU $C103
BLOCK_ROT EQU $C104


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
	ld a, 64
	ld [BLOCK_X], a
	ld [BLOCK_Y], a
	ld a, 1
	ld [CURRENT_BLOCK], a
	call .renderTetromino
	
	; Init display registers
    ld a, %11100100
	ld [rOBP0], a
    ld [rBGP], a

    xor a ; ld a, 0
    ld [rSCY], a
    ld [rSCX], a

    ; Shut sound down
    ld [rNR52], a

	;call .prepareTimer
    ; Turn screen on, display background
    ld a, %10000011
    ld [rLCDC], a
	
.update
	ld a, [rLY] ;sprawdzamy linie
	cp 144 ; porównujemy z 144
	jr c, .update	;jeśli jest mniejsza, powtarzamy
	;call .waitVBlankOnce
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
	;add a, 8
	inc a
	ld [hl], a	
	ld a, l
	add a, 4
	ld l, a
	dec b
	jr nz, .letTheBlocksFall
	call .randomBlock ;wywołujemy randomBlock
.lockup
	ld a, [rLY]
	cp 153
	jr c, .update
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
	

	
.waitVBlankOnce
	ld a, [rLY]
	cp 144
	jr c, .waitVBlankOnce
	ret
	
.randomBlock
	ld hl, NEXT_BLOCK
	ld a, [rDIV]
	and %00000111
	jr z, .randomBlock
	ld [hl], a
	ret
	
.renderTetromino
	ld de, $FE00
	ld a, [CURRENT_BLOCK]
	add a
	ld hl, Blocks
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hli]
	and 128
	jr z, .assign0
.assignMiddle
	ld b, 8
	ld c, 8
	call .setPiece
.assign0
	;ld b, [hl] ;Tu trzeba bedzie dodac rotacje
	ld a, %10000000
	and b
	jr z, .assign1
	ld b, 0
	ld c, 0
	call .setPiece
.assign1
	ld a, %01000000
	and b
	jr z, .assign2
	ld b, 0
	ld c, 8
	call .setPiece
.assign2
	ld a, %00100000
	and b
	jr z, .assign3
	ld b, 0
	ld c, 16
	call .setPiece
.assign3
	ld a, %00010000
	and b
	jr z, .assign4
	ld b, 8
	ld c, 16
	call .setPiece
.assign4
	ld a, %00001000
	and b
	jr z, .assign5
	ld b, 16
	ld c, 16
	call .setPiece
.assign5
	ld a, %00000100
	and b
	jr z, .assign6
	ld b, 16
	ld c, 8
	call .setPiece
.assign6
	ld a, %00000010
	and b
	jr z, .assign7
	ld b, 16
	ld c, 0
	call .setPiece
.assign7
	ld a, %00000001
	and b
	jr z, .return
	ld b, 8
	ld c, 0
	call .setPiece
.return
	ret
	
.setPiece; B - offset Y, C - offset X
	ld a, [BLOCK_Y]
	add b
	ld [de], a
	inc e
	ld a, [BLOCK_X]
	add c
	ld [de], a
	inc e
	ld a, [CURRENT_BLOCK]
	add 128
	ld [de], a
	inc e
	xor a
	ld [de], a
	inc e	;Pomijamy 4 bajt sprite'u
	ld b, [hl] ;Tu trzeba bedzie dodac rotacje?
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

SECTION "Tetromino", ROM0

Blocks:
	;I
	;O
	;L
	db %10000000
	db %00110001
	;R
	db %10000000
	db %10010001
	
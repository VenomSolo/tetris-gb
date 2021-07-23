INCLUDE "variables.inc"
INCLUDE "hardware.inc"

SECTION "Tetromino", ROM0[$3000]

Blocks:
	;L
	db %10000000
	db %00110001
	;R
	db %10000000
	db %10010001
	;Z
	db %10000000
	db %11010000
	;S
	db %10000000
	db %01100001
	;
	;O
	db %10000000
	db %00011100
	;T
	db %10000000
	db %11100000
	;I
	db %00000000
	db %11100000
	; first byte - indicates middle field / being an I
	; second byte - block layout
	; 7 0 1
	; 6 x 2
	; 5 4 3
	
;LocalOAM::
;REPT 16
;	DB 0
;ENDR
	;00110001
	;00011000
	;10001100
	;01000110
	;00100011
	
InitTetromino::
.randomBlock
	ld hl, NEXT_BLOCK
	ld a, [rDIV] ; divider register
	and %00000111 ; 
	jr z, .randomBlock
	dec a
	ld [hl], a
	;
	xor a
	ld [BLOCK_ROT], a
	ld a, 56
	ld [BLOCK_X], a
	ld a, 24
	ld [BLOCK_Y], a
	ld a, 4
	ld [BLOCK_X_POS], a
	ld a, 1
	ld [BLOCK_Y_POS], a
	ld a, [NEXT_BLOCK]
	ld [CURRENT_BLOCK], a
	;call CopyToNew
	;call .waitUntilNextVBlank
	call CheckCollision
	ld a, [BLOCK_Y_POS_NEW] 
	cp 1 ; if it collided at the init
	jr nz, .yeet
	call CalculateTetromino
	ret
.yeet
	;don't want to write it so just turn screen the fuck down
	xor a
	ld [rLCDC], a
	ret

	
CheckCollision::
	jr .checkEachSegment
.checkPosition
	ld a, 8 ; horizontal
	;ld b, [BLOCK_X_POS]
	;ld c, [BLOCK_Y_POS]
	; using hl instead
	ld hl, BLOCK_X_POS
	sub a, [hl]
	jp c, .colliding
	inc hl
	ld a, 16
	sub a, [hl]
	jp c, .colliding
	jp .notcolliding
.checkEachSegment
	ld a, [CURRENT_BLOCK]
	add a ; double a because each tetromino takes 2 bytes
	ld hl, Blocks
	ld c, a
	ld b, 0
	add hl, bc ; offset 2*a from Blocks
	ld a, [hli] ; save middle field byte to a
	and 128 ; check if tetromino has middle field
	jr z, .rotate 
.checkMiddle
	ld b, 1
	ld c, 1
	call .checkPiece
	and 255
	jp nz, .colliding
.rotate
	ld c, [hl]
	ld hl, BLOCK_ROT
	ld b, [hl]
	ld a, b
	inc a
	ld b, a
	ld a, c
.loop	
	dec b
	jr z, .setRotated
	rrca
	jr .loop
.setRotated
	ld hl, ROTATED_BLOCK
	ld [hl], a
.check0
	ld a, %10000000 
	and [hl] ; check if tetromino contains piece
	jr z, .check1 ; else skip
	ld b, 0 ; pass Y offset
	ld c, 0	; pass X offset
	call .checkPiece
	and 255
	jr nz, .colliding
.check1
	ld a, %01000000
	and [hl]
	jr z, .check2
	ld b, 0
	ld c, 1
	call .checkPiece
	and 255
	jr nz, .colliding
.check2
	ld a, %00100000
	and [hl]
	jr z, .check3
	ld b, 0
	ld c, 2
	call .checkPiece
	and 255
	jr nz, .colliding
.check3
	ld a, %00010000
	and [hl]
	jr z, .check4
	ld b, 1
	ld c, 2
	call .checkPiece
	and 255
	jr nz, .colliding
.check4
	ld a, %00001000
	and [hl]
	jr z, .check5
	ld b, 2
	ld c, 2
	call .checkPiece
	and 255
	jr nz, .colliding
.check5
	ld a, %00000100
	and [hl]
	jr z, .check6
	ld b, 2
	ld c, 1
	call .checkPiece
	and 255
	jr nz, .colliding
.check6
	ld a, %00000010
	and [hl]
	jr z, .check7
	ld b, 2
	ld c, 0
	call .checkPiece
	and 255
	jr nz, .colliding
.check7
	ld a, %00000001
	and [hl]
	jr z, .notcolliding
	ld b, 1
	ld c, 0
	call .checkPiece
	and 255
	jr nz, .colliding
.notcolliding
	call CopyToNew
	ret
.colliding
	call CopyToOld
	ret

.checkPiece ; B - offset Y, C - offset X
.save
	ld e, l
	ld d, h
	ld hl, MAP
	ld a, [BLOCK_X_POS]
	add a, c ; add C (x_offset) so it is not needed
	ld l, a ; set L to x + offset
.checkX
	ld a, 9
	sub a, l
	jr c, .load
.calcBG
	ld a, [BLOCK_Y_POS]
	add a, b ; y + y_offset
	; first calc y so B is not needed
	; ld l, c
	; now that BC is free save 32 into it
	ld bc, 10
.loopY
	add hl, bc ; use it here to bypass need for adding with carry
	dec a
	jr nz, .loopY
	;call WaitVBlank
	ld a, [hl] ; save index to A
.load
	ld l, e
	ld h, d
	ret


CopyToNew::
	ld hl, BLOCK_X
	ld de, BLOCK_X_NEW
REPT 5
	ld a, [hl]
	ld [de], a
	inc hl
	inc de
ENDR
	ret
	
CopyToOld::
	ld hl, BLOCK_X_NEW
	ld de, BLOCK_X
REPT 5
	ld a, [hl]
	ld [de], a
	inc hl
	inc de
ENDR
	ret

AdjustLocalOAM::
	ld hl, LocalOAM
	ld a, [BLOCK_Y_NEW]
	ld [hli], a
	ld a, [BLOCK_X_NEW]
	ld [hl], a
	ret
	
UpdateBlock::
	call CheckCollision
	;call CopyToNew
	call AdjustLocalOAM
	ret
	
RenderTetromino:: ; copy LocalOAM to OAM
	ld hl, LocalOAM
	ld de, $FE00
	ld b, 16
.loop
	ld a, [hl]
	ld [de], a
	inc hl
	inc de
	dec b
	jr nz, .loop
	ret
	
	
CalculateTetromino::
	ld de, LocalOAM ; OAM start
	ld a, [CURRENT_BLOCK]
	add a ; double a because each tetromino takes 2 bytes
	ld hl, Blocks
	ld c, a
	ld b, 0
	add hl, bc ; offset 2*a from Blocks
	ld a, [hli] ; save middle field byte to a
	;ld b, h
	;ld c, l
	;rotate
	
	;ld hl, BLOCK_ROT
	
	;rr [hl]
	;ld h, b
	;ld l, c
	and 128 ; check if tetromino has middle field
	jr z, .rotate 
.assignMiddle
	ld b, 8
	ld c, 8
	call .setPiece
.rotate
	ld c, [hl]
	ld hl, BLOCK_ROT_NEW
	ld b, [hl]
	ld a, b
	inc a
	ld b, a
	ld a, c
.loop	
	dec b
	jr z, .setRotated
	rrca
	jr .loop
.setRotated
	ld hl, ROTATED_BLOCK
	ld [hl], a
.assign0
	;ld b, [hl] ;Tu trzeba bedzie dodac rotacje
	ld a, %10000000 
	and [hl] ; check if tetromino contains piece
	jr z, .assign1 ; else skip
	ld b, 0 ; pass Y offset
	ld c, 0	; pass X offset
	call .setPiece
.assign1
	ld a, %01000000
	and [hl]
	jr z, .assign2
	ld b, 0
	ld c, 8
	call .setPiece
.assign2
	ld a, %00100000
	and [hl]
	jr z, .assign3
	ld b, 0
	ld c, 16
	call .setPiece
.assign3
	ld a, %00010000
	and [hl]
	jr z, .assign4
	ld b, 8
	ld c, 16
	call .setPiece
.assign4
	ld a, %00001000
	and [hl]
	jr z, .assign5
	ld b, 16
	ld c, 16
	call .setPiece
.assign5
	ld a, %00000100
	and [hl]
	jr z, .assign6
	ld b, 16
	ld c, 8
	call .setPiece
.assign6
	ld a, %00000010
	and [hl]
	jr z, .assign7
	ld b, 16
	ld c, 0
	call .setPiece
.assign7
	ld a, %00000001
	and [hl]
	jr z, .return
	ld b, 8
	ld c, 0
	call .setPiece
.return
	ret
	
.setPiece; B - offset Y, C - offset X
	ld a, [BLOCK_Y_NEW]
	add b
	ld [de], a ; set y offset in LOCAL OAM
	inc e ; next field in OAM
	ld a, [BLOCK_X_NEW]
	add c
	ld [de], a ; set x offset in LOCAL OAM
	inc e
	ld a, [CURRENT_BLOCK]
	add 128 ; consequence of indexing mode 8800
	ld [de], a ; set tile index in OAM
	inc e 
	xor a
	ld [de], a ; set flags in OAM to 0 - Palette set to OBP0
	inc e	;Pomijamy 4 bajt sprite'u
	;ld b, [hl] ;Tu trzeba bedzie dodac rotacje?
	ret
	
	
BurnTetromino::
	ld de, LocalOAM ; OAM start
	ld a, [CURRENT_BLOCK]
	add a ; double a because each tetromino takes 2 bytes
	ld hl, Blocks
	ld c, a
	ld b, 0
	add hl, bc ; offset 2*a from Blocks
	ld a, [hli] ; save middle field byte to a
	and 128 ; check if tetromino has middle field
	jr z, .rotate 
.assignMiddle
	ld b, 1
	ld c, 1
	call .setPiece
.rotate
	ld c, [hl]
	ld hl, BLOCK_ROT_NEW
	ld b, [hl]
	ld a, b
	inc a
	ld b, a
	ld a, c
.loop	
	dec b
	jr z, .setRotated
	rrca
	jr .loop
.setRotated
	ld hl, ROTATED_BLOCK
	ld [hl], a
.assign0
	;ld b, [hl] ;Tu trzeba bedzie dodac rotacje
	ld a, %10000000 
	and [hl] ; check if tetromino contains piece
	jr z, .assign1 ; else skip
	ld b, 0 ; pass Y offset
	ld c, 0	; pass X offset
	call .setPiece
.assign1
	ld a, %01000000
	and [hl]
	jr z, .assign2
	ld b, 0
	ld c, 1
	call .setPiece
.assign2
	ld a, %00100000
	and [hl]
	jr z, .assign3
	ld b, 0
	ld c, 2
	call .setPiece
.assign3
	ld a, %00010000
	and [hl]
	jr z, .assign4
	ld b, 1
	ld c, 2
	call .setPiece
.assign4
	ld a, %00001000
	and [hl]
	jr z, .assign5
	ld b, 2
	ld c, 2
	call .setPiece
.assign5
	ld a, %00000100
	and [hl]
	jr z, .assign6
	ld b, 2
	ld c, 1
	call .setPiece
.assign6
	ld a, %00000010
	and [hl]
	jr z, .assign7
	ld b, 2
	ld c, 0
	call .setPiece
.assign7
	ld a, %00000001
	and [hl]
	jr z, .return
	ld b, 1
	ld c, 0
	call .setPiece
.return
	ret
	
.setPiece ; B - offset Y, C - offset X
.save
	ld e, l
	ld d, h
.calcBG
	ld hl, MAP
	ld a, [BLOCK_X_POS]
	add a, c ; add C (x_offset) so it is not needed
	ld l, a ; set L to x + offset
	ld a, [BLOCK_Y_POS]
	add a, b ; y + y_offset
	; first calc y so B is not needed
	; ld l, c
	; now that BC is free save 32 into it
	ld bc, 10
.loopY
	add hl, bc ; use it here to bypass need for adding with carry
	dec a
	jr nz, .loopY
	;call WaitVBlank
	ld a, [CURRENT_BLOCK]
	inc a ; 0 should mean free space
	ld [hl], a ; burn tile index to map
.load
	ld l, e
	ld h, d
	ret


Fall::
.real
	ld hl, BLOCK_Y
	ld a, [hl]
	add a, 8 
	ld [hl], a
.normalized
	ld hl, BLOCK_Y_POS
	ld a, [hl]
	inc a 
	ld [hl], a
	call CheckCollision
	jr z, .calc
	call BurnTetromino
	call CopyMapToVRAM
	call InitTetromino
.calc
	call AdjustLocalOAM
	call CalculateTetromino
	ret
	;inc a
	;ld [hl], a	
	;ld a, l
	;add a, 4
	;ld l, a
	;dec b
	;jr nz, .letTheBlocksFall
	;call .randomBlock
	
MoveRight::
.real
	ld hl, BLOCK_X
	ld a, [hl]
	add a, 8
	ld [hl], a
.normalized
	ld hl, BLOCK_X_POS
	ld a, [hl]
	inc a 
	ld [hl], a
	call UpdateBlock
	call CalculateTetromino
	ret

MoveLeft::
.real
	ld hl, BLOCK_X
	ld a, [hl]
	sub a, 8
	ld [hl], a
.normalized
	ld hl, BLOCK_X_POS
	ld a, [hl]
	dec a 
	ld [hl], a
	call UpdateBlock
	call CalculateTetromino
	ret
	
RotateRight::
	ld a, [BLOCK_ROT]
	cp 6
	jr z, .overflow
	inc a
	inc a
	ld [BLOCK_ROT], a
	jr .calc
.overflow
	xor a
	ld [BLOCK_ROT], a
.calc
	call UpdateBlock
	call CalculateTetromino
	ret
	
RotateLeft::
	call Fall
	call Fall
	call Fall
	call Fall
	ret
	ld a, [BLOCK_ROT]
	cp 0
	jr z, .underflow
	dec a
	dec a
	ld [BLOCK_ROT], a
	jr .calc
.underflow
	ld a, 6
	ld [BLOCK_ROT], a
.calc
	call UpdateBlock
	call CalculateTetromino
	ret
	

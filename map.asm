INCLUDE "variables.inc"
INCLUDE "hardware.inc"

SECTION "Map", ROM0[$3800]

WALL EQU $87

Map:
REPT 18
DB WALL,WALL,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,WALL,WALL,WALL,WALL,WALL,WALL,WALL,WALL,WALL,WALL,WALL,WALL,WALL,WALL,WALL,WALL,WALL,WALL,WALL,WALL
ENDR
REPT 14*32
DB WALL
ENDR

GenerateBackground::
	ld hl, $9800
	ld b, 0
	ld c, 0
	ld de, Map
.loopLines
.loopLine
	ld a, [de]
	inc de
	ld [hl], a
	inc hl
	inc b
	ld a, b
	cp 32
	jr c, .loopLine
	ld b, 0
	inc c
	ld a, c
	cp 32
	jr c, .loopLines
	ret
	
InitMap::
	ld hl, MAP
	ld a, 180
.loop
	ld [hl], 0
	inc hl
	dec a
	jr nz, .loop
	ret
	
ClearRows:: ; don't know why the fuck there are carries here
			; if I need only 180 entries but ok
	xor a
	ld [ROWS_TO_DELETE], a
	ld hl, MAP
	ld b, 19 ; dec doesn't change carry flag :/
.scanrow
	;copy start of row
	ld d, h
	ld e, l
	dec b
	jr z, .additionalcheck
	ld c, 10
.scannigloop
	ld a, [hl]
	cp 0
	jr z, .stopscan ; if field is empty stop scannig row
	inc hl
	dec c
	jr nz, .scannigloop
.eraserow
	ld c, 10
	;count cleared rows
	ld a, [ROWS_TO_DELETE]
	inc a
	ld [ROWS_TO_DELETE], a
	;rewind to start of row
	ld h, d
	ld l, e
.erasingloop
	ld [hl], 0
	inc hl
	dec c
	jr nz, .erasingloop
.stoperase
	jr .scanrow
.stopscan
	; add 10 with carry to de
	ld a, e
	add a, 10
	ld e, a
	jr nc, .nocarry
	inc d
.nocarry
	; set hl to start of the next row
	ld h, d
	ld l, e
	; check if there was cleared row below
	ld a, [ROWS_TO_DELETE]
	cp 0
	jr nz, .fall ; if there were, just let rows fall and return
	jr .scanrow
.fall
	;de and hl points at the exact 
	;same segment - first in the next row
	;rewind them to the end of last row
	dec hl
	dec de
	;rewind hl ROWS_TO_DELETE rows up
	ld a, [ROWS_TO_DELETE]
	ld b, a
.rewindloop
	ld a, l
	sub a, 10
	ld l, a
	dec b
	jr nz, .rewindloop
.replaceloop
	ld a, [hl]
	ld [de], a
	dec e
	dec l 
	jr nz, .replaceloop ; this won't check first segment
						; but we don't need first row anyway
	jr .return
.additionalcheck
	ld a, [ROWS_TO_DELETE]
	cp 0
	jr nz, .fall ; if there were, just let rows fall and return
.return
	ret

	
	
	
	
CopyMapToVRAM::
	call ClearRows
	call WaitVBlank
	ld hl, $9802
	ld de, MAP
	ld b, 18
	ld c, 10
.loop
	ld a, [de]
	add a, 127
	ld [hl], a
	inc hl
	inc e
	dec c
	jr nz, .loop
.nextRow
	ld a, [rLY]
	cp 152 ; if it's dangerously close to end of VBlank, just wait for another
	jr nc, .nowait
	call WaitVBlank
.nowait
	ld a, l
	add a, 22
	jr nc, .nocarry
	inc h
.nocarry
	ld l, a
	ld c, 10
	dec b
	jr nz, .loop
.end
	ret
	

INCLUDE "variables.inc"
INCLUDE "hardware.inc"

SECTION "Map", ROM0[$3800]

WALL EQU $84

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
	
ClearRows::
	ld hl, MAP
	ld b, 19 ; dec doesn't change carry flag :/
.scanrow
	;copy start of row
	ld d, h
	ld e, l
	dec b
	jr z, .return
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
	; add 10 with carry to bc
	ld a, e
	add a, 10
	ld e, a
	jr nc, .nocarry
	inc d
.nocarry
	; set hl to start of the next row
	ld h, d
	ld l, e
	jr .scanrow
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
	cp 152 ; if it's dangerously enough end of VBlank, just wait for another
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
	

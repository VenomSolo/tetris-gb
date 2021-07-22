INCLUDE "variables.inc"
INCLUDE "hardware.inc"

SECTION "Player", ROM0[$3400] ;

ReadJoypad:
.selectDirection
	ld hl, rP1
	ld a, $20
	ld [hl], a
	ld a, [hl]
	ld hl, JOYDNEW
	ld b, [hl]
	ld [hl], a
	ld hl, JOYDOLD
	ld [hl], b
	;jr .reset
.selectAction
	ld hl, rP1
	ld a, $10
	ld [hl], a
	ld a, [hl]
	ld hl, JOYANEW
	ld b, [hl]
	ld [hl], a
	ld hl, JOYAOLD
	ld [hl], b
.reset
	ld hl, rP1
	ld a, $FF
	ld [hl], a
	ret
	
Input::
.selectDirection
	ld hl, rP1
	ld a, $20
	ld [hl], a
REPT 30
	ld a, [hl]
ENDR
	ld hl, JOYDNEW
	ld b, [hl]
	ld [hl], a
	ld hl, JOYDOLD
	ld [hl], b
	;jr .reset
.selectAction
	ld hl, rP1
	ld a, $10
	ld [hl], a
REPT 300
	ld a, [hl]
ENDR
	ld hl, JOYANEW
	ld b, [hl]
	ld [hl], a
	ld hl, JOYAOLD
	ld [hl], b
.reset
	ld hl, rP1
	ld a, $FF
	ld [hl], a
	;ret
	;call ReadJoypad
	;call ReadJoypad
	;call ReadJoypad
.initAction
	;ld hl, LocalOAM+1
.right
	ld a, [JOYDNEW]
	bit 0, a
	jr nz, .left
	ld a, [JOYDOLD]
	bit 0, a
	jr z, .left
	;jr z
	call MoveRight
	jr .endActionUpdate
.left
	ld a, [JOYDNEW]
	bit 1, a
	jr nz, .rotRight
	ld a, [JOYDOLD]
	bit 1, a
	jr z, .rotRight
	;jr z
	call MoveLeft
	jr .endActionUpdate
.rotRight
	ld a, [JOYDNEW]
	bit 2, a
	jr nz, .rotLeft
	ld a, [JOYDOLD]
	bit 2, a
	jr z, .rotLeft
	call RotateRight
	jr .endActionUpdate
.rotLeft
	ld a, [JOYDNEW]
	bit 3, a
	jr nz, .endActionNoUpdate
	ld a, [JOYDOLD]
	bit 3, a
	jr z, .endActionNoUpdate
	call RotateLeft
	jr .endActionUpdate
.endActionUpdate
	call ClearJoypad
	call WaitVBlank
	call RenderTetromino
	ret
.endActionNoUpdate
	ret
	


;MoveRight::
;REPT 4
;	ld a, [hl]
;	add 8
;	ld [hl], a
;	ld bc, 4
;	add hl, bc
;ENDR
;	ret

;MoveLeft::
;REPT 4
;	ld a, [hl]
;	sub 8
;	ld [hl], a
;	ld bc, 4
;	add hl, bc
;ENDR
;	ret
	
	

	
ClearJoypad::
	ld hl, JOYANEW
	ld [hl], 0
	ld hl, JOYAOLD
	ld [hl], 0
	ld hl, JOYDNEW
	ld [hl], 0
	ld hl, JOYDOLD
	ld [hl], 0
	ret
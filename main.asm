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
	; Turn off LCD
	call EnableLCD
	ld a,[rLCDC]
	set 5,a 
	set 1,a 
	ld [rLCDC],a
	xor a
	ld [POS], a
	call SingleWaitVBlank
	ld a, %11100100
    ld [rBGP], a
    xor a 
    ld [rSCY], a
    ld [rSCX], a
    ld [rNR52], a
	call WaitVBlank
	
	
.lockup
	jr .lockup
	
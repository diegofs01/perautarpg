DEF _VRAM8000 EQU $8000
DEF _OAMRAM EQU $FE00

SECTION "Sprite Functions", ROMX
GetSpriteTiles::
	ld de, SpritesTiles					;	move o endereço da label pro registrador DE
	ld hl, _VRAM8000					;	move o endereço da VRAM pro regisrador HL
	ld bc, SpriteTilesBytesLength		;	move o tamanho em bytes da label pro registrador BC
	ret									;	retorna para a função anterior

GetSpritePalettes::
	ld hl, SpritesPaletteData			;	move o endereço da label pro registrador HL
	ld b, SpritesPaletteBytesToWrite	;	move valor da label pro registrador B
	ret									;	retorna para a função anterior

GetSpriteOAMData::
	ld de, SpritesData					;	move o endereço da label pro registrador DE
	ld hl, _OAMRAM						;	move o endereço da VRAM pro regisrador HL
	ld bc, SpritesDataBytesLength		;	move o tamanho em bytes da label pro registrador BC
	ret									;	retorna para a função anterior

SECTION "Sprite Data", ROMX
SpritesTiles: ;sprites
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $FF,$00,$FF,$7E,$C3,$7E,$C3,$66
	DB $C3,$66,$C3,$7E,$FF,$7E,$FF,$00
	DB $1F,$1F,$01,$01,$01,$01,$03,$03
	DB $06,$06,$0C,$0C,$18,$18,$10,$10
	DB $C0,$C0,$70,$30,$70,$30,$20,$20
	DB $20,$A0,$C0,$C0,$86,$86,$8C,$8C
	DB $F8,$F8,$80,$80,$80,$80,$C0,$C0
	DB $60,$60,$30,$30,$18,$18,$08,$08
DEF SpriteTilesBytesLength EQU 96

  ; DB Y, X, Tile Index, Attributes/Flags
  ; 					 Bit7   BG and Window over OBJ (0=No, 1=BG and Window colors 1-3 over the OBJ)
  ; 					 Bit6   Y flip          (0=Normal, 1=Vertically mirrored)
  ; 					 Bit5   X flip          (0=Normal, 1=Horizontally mirrored)
  ; 					 Bit4   Palette number  **Non CGB Mode Only** (0=OBP0, 1=OBP1)
  ; 					 Bit3   Tile VRAM-Bank  **CGB Mode Only**     (0=Bank 0, 1=Bank 1)
  ; 					 Bit2-0 Palette number  **CGB Mode Only**     (OBP0-7)
SpritesData:
	DB 0, 0, 0, 0
	DB 0, 0, 2, %00000000
	DB 0, 0, 4, %00000000
DEF SpritesDataBytesLength EQU 12

SpritesPaletteData:
	; Gameboy Color palette 0
	db %11111111, %01111111, %00010000, %01000010, %00011111, %00000000, %00000000, %00000000
	; Gameboy Color palette 1
	db %10111100, %00010111, %11100111, %00100010, %11000100, %00011001, %11100000, %00010100
	; Gameboy Color palette 2
	db %10111100, %00010111, %11100111, %00100010, %11000100, %00011001, %11100000, %00010100
	; Gameboy Color palette 3
	db %10111100, %00010111, %11100111, %00100010, %11000100, %00011001, %11100000, %00010100
	; Gameboy Color palette 4
	db %10111100, %00010111, %11100111, %00100010, %11000100, %00011001, %11100000, %00010100
	; Gameboy Color palette 5
	db %10111100, %00010111, %11100111, %00100010, %11000100, %00011001, %11100000, %00010100
	; Gameboy Color palette 6
	db %10111100, %00010111, %11100111, %00100010, %11000100, %00011001, %11100000, %00010100
	; Gameboy Color palette 7
	db %10111100, %00010111, %11100111, %00100010, %11000100, %00011001, %11100000, %00010100
DEF SpritesPaletteBytesToWrite EQU 64 ; fixed, 8 pallete, 4 color, 2 bytes/color = 64 bytes
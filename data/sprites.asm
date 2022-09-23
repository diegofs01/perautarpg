INCLUDE "hardware.inc"

SECTION "Sprite Functions", ROMX
CopySpritesToVRAM::
	ld de, SpritesTiles					;	move o endereço da label pro registrador DE
	ld hl, _VRAM8000					;	move o endereço da VRAM pro regisrador HL
	ld bc, SpriteTilesBytesLength		;	move o tamanho em bytes da label pro registrador BC
.copyTiles:
	ld a, [de]			                ;   Copia tile/dado do tileset/sprite pro acumulador
	ld [hl+], a			                ;   Copia o tile/dado do acumulador pra VRAM e incrementa o ponteiro da VRAM
	inc de				                ;   Incrementa o ponteiro do tileset/sprite
	dec bc				                ;   Decrementa a quantidade de bytes a copiar
	ld a, b				                ;   ┐ Copia a quantidade de bytes restantes pro acumulador
	or a, c				                ;   ┘
	jp nz, .copyTiles	                ;   Pula de volta pro começo da função caso a flag Z (zero) nao estiver setado
;   Função para copiar os dados de palheta de cor das sprites para a VRAM
.prepareSpritePaletteData:
    ld a, OCPSF_AUTOINC                 ;   ┐ Seta o auto-incremento no reg de 'especificação de palheta de cor (sprites)'
    ld [rOCPS], a 		                ;   ┘
    ld de, rOCPD                        ;   Copia o ponteiro do registrador de palheta de cores da sprite
	ld hl, SpritesPaletteData			;	move o endereço da label pro registrador HL
	ld b, SpritesPaletteBytesToWrite	;	move valor da label pro registrador B
.copyPaletteData
    ld a, [hl] 			                ;   ┐ Copia o valor do acumulador pro registrador de palheta de cor (I/O)
    ld [de], a 		                    ;   ┘
    inc hl				                ;   Incrementa o ponteiro dos dados de palette do TileSet
    dec b				                ;   Decrementa a quantidade de bytes a copiar
    ld a, b				                ;   Copia a quantidade de bytes restantes pro acumulador
    cp 0 				                ;   Compara o acumulador
	jp nz, .copyPaletteData	            ;   Pula de volta se o acumulador nao for Zero
	ret					                ;   Retorna para a função anterior

CopySpriteOAMDataToWRAM::
	ld de, SpritesData					;	move o endereço da label pro registrador DE
	ld hl, SpritesDataRAM				;	move o endereço da VRAM pro regisrador HL
	ld bc, SpritesDataBytesLength		;	move o tamanho em bytes da label pro registrador BC
.copyTiles:
	ld a, [de]			                ;   Copia tile/dado do tileset/sprite pro acumulador
	ld [hl+], a			                ;   Copia o tile/dado do acumulador pra VRAM e incrementa o ponteiro da VRAM
	inc de				                ;   Incrementa o ponteiro do tileset/sprite
	dec bc				                ;   Decrementa a quantidade de bytes a copiar
	ld a, b				                ;   ┐ Copia a quantidade de bytes restantes pro acumulador
	or a, c				                ;   ┘
	jp nz, .copyTiles	                ;   Pula de volta pro começo da função caso a flag Z (zero) nao estiver setado
	ret									;	retorna para a função anterior

SECTION "Sprite Data", ROMX

DEF CursorTile		EQU 0
DEF PlayerLeftTile	EQU 2
DEF PlayerRightTile	EQU 6
DEF PlayerDownTile	EQU 14
DEF PlayerUpTile	EQU 10

;Tiles:
TileIndexes::
	db CursorTile
	db PlayerLeftTile
	db PlayerRightTile
	db PlayerDownTile
	db PlayerUpTile

SpritesTiles:			INCBIN "data/sprites/sprites01.chr"
SpriteTilesBytesLength	EQU 288

; DB Y, X, Tile Index, Attributes/Flags
;						Bit7   BG and Window over OBJ (0=No, 1=BG and Window colors 1-3 over the OBJ)
;						Bit6   Y flip          (0=Normal, 1=Vertically mirrored)
;						Bit5   X flip          (0=Normal, 1=Horizontally mirrored)
;						Bit4   Palette number  **Non CGB Mode Only** (0=OBP0, 1=OBP1)
;						Bit3   Tile VRAM-Bank  **CGB Mode Only**     (0=Bank 0, 1=Bank 1)
;						Bit2-0 Palette number  **CGB Mode Only**     (OBP0-7)
SpritesData:
	DB 0, 0, CursorTile, %00000000
	DB 80, 80, PlayerUpTile, %00000000
	DB 80, 88, PlayerUpTile+2, %00000000
DEF SpritesDataBytesLength EQU 12

SpritesPaletteData:			INCBIN "data/sprites/sprites01.pal"
SpritesPaletteBytesToWrite	EQU 8
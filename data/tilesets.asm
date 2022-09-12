DEF _VRAM8800 EQU $8800
DEF rBCPS EQU $FF68
DEF rBCPD EQU $FF69

SECTION "Tile Set Functions", ROMX
;   Copia os ponteiros de dados do Tileset
;   Retorna:
;       DE = Endereço dos dados do TileSet
;       BC = Tamanho em bytes do TileSet
;       HL = Endereço da VRAM pertencente ao TileSet
GetTileSetData::
    ld a, [ActiveTilesetId]         ;   Copia o ID do Tileset Atual no acumulador
    sla a                           ;   ┐ 
    sla a                           ;   ├ Converte o ID em Offset (ID 1 = Offset 8, ID 2 = Offset 16, etc)
    sla a                           ;   ┘ 
    ld d, 0                         ;   ┐ Copia o offset pro reg DE
    ld e, a                         ;   ┘
    ld hl, TileSets                 ;   Copia o ponteiro da tabela de tileset pro reg HL
    add hl, de                      ;   Adiciona o offset no ponteiro

    ld de, TileSetBank_D
    ld a, [hl+]
    ld [de], a
    
    ld de, TileSetData_P            ;   ┐
    ld a, [hl+]                     ;   │
    ld [de], a                      ;   ├ Copia o ponteiro com os dados do tileset na memoria
    inc de                          ;   │
    ld a, [hl+]                     ;   │
    ld [de], a                      ;   ┘

    ld de, TileSetDataSize_D        ;   ┐
    ld a, [hl+]                     ;   │        
    ld [de], a                      ;   ├ Copia o tamanho em bytes do tileset na memoria
    inc de                          ;   │
    ld a, [hl+]                     ;   │        
    ld [de], a                      ;   ┘

    ld de, TileSetPaletteData_P     ;   ┐
    ld a, [hl+]                     ;   │
    ld [de], a                      ;   ├ Copia o ponteiro com os dados do pallete do tileset na memoria
    inc de                          ;   │
    ld a, [hl+]                     ;   │
    ld [de], a                      ;   ┘

    ld de, TileSetPaletteDataSize_D ;   ┐
    ld a, [hl+]                     ;   ├ Copia o tamanho em bytes do pallete do tileset na memoria
    ld [de], a                      ;   ┘

    ret                             ;   Retorna pra função anterior

;   Dados e Atributos do Tileset da com a Fonte do Menu
CopyFontTilesData::
    ld de, TextFont_Data
    ld bc, TextFont_DataSize
    ld hl, _VRAM8800
.copyFontTiles:
	ld a, [de]			                ;   Copia tile/dado do tileset/sprite pro acumulador
	ld [hl+], a			                ;   Copia o tile/dado do acumulador pra VRAM e incrementa o ponteiro da VRAM
	inc de				                ;   Incrementa o ponteiro do tileset/sprite
	dec bc				                ;   Decrementa a quantidade de bytes a copiar
	ld a, b				                ;   ┐ Copia a quantidade de bytes restantes pro acumulador
	or a, c				                ;   ┘
	jp nz, .copyFontTiles               ;   Pula de volta pro começo da função caso a flag Z (zero) nao estiver setado

    ld a, %10111000                     ;   ┐ Seta a flag no registrador de palheta de cores do background (mapa)
    ld [rBCPS], a                       ;   ┘
    ld de, rBCPD                        ;   Copia o registrador de palheta de cores do background
    ld hl, TextFont_PaletteData
    ld b, TextFont_PaletteDataSize
.copyFontPalette
    ld a, [hl] 			                ;   ┐ Copia o valor do acumulador pro registrador de palheta de cor (I/O)
    ld [de], a 		                    ;   ┘
    inc hl				                ;   Incrementa o ponteiro dos dados de palette do TileSet
    dec b				                ;   Decrementa a quantidade de bytes a copiar
    ld a, b				                ;   Copia a quantidade de bytes restantes pro acumulador
    cp 0 				                ;   Compara o acumulador
	jp nz, .copyFontPalette             ;   Pula de volta se o acumulador nao for Zero
	ret					                ;   Retorna para a função anterior

SECTION "Tile Set Pointer Table", ROMX
TileSets:                               ; 8 bytes per entry
    ; id 0
    db Exterior01_Bank                  ; 1 byte    -   bank do tileset
    dw Exterior01_Data                  ; 2 bytes   -   data do tileset
    dw Exterior01_DataSize              ; 2 bytes   -   tamnhanho do tileset em bytes 
    dw Exterior01_PaletteData           ; 2 bytes   -   palettes
    db Exterior01_PaletteDataSize       ; 1 byte    -   bytes
    ; id 1                      
    db House01_Bank                     ; 1 byte    -   bank do tileset
    dw House01_Data                     ; 2 bytes   -   data do tileset
    dw House01_DataSize                 ; 2 bytes   -   tamnhanho do tileset em bytes 
    dw House01_PaletteData              ; 2 bytes   -   palettes
    db House01_PaletteDataSize          ; 1 byte    -   bytes
    ; id 2
    db Exterior02_Bank
    dw Exterior02_Data
    dw Exterior02_DataSize       
    dw Exterior02_PaletteData    
    db Exterior02_PaletteDataSize
    ;id 3
    db Lab01_Bank
    dw Lab01_Data
    dw Lab01_DataSize       
    dw Lab01_PaletteData    
    db Lab01_PaletteDataSize

TextFont_Data:              INCBIN "data/tilesets/textfont.chr"
TextFont_DataSize           EQU 2048
TextFont_PaletteData:       INCBIN "data/tilesets/textfont.pal"
TextFont_PaletteDataSize    EQU 8

SECTION "Tile Set Data", ROMX, BANK[2]

Exterior01_Bank             EQU 2
Exterior01_Data:            INCBIN "data/tilesets/exterior01.chr"
Exterior01_DataSize         EQU 2048
Exterior01_PaletteData:     INCBIN "data/tilesets/exterior01.pal"
Exterior01_PaletteDataSize  EQU 32

Exterior02_Bank             EQU 2
Exterior02_Data:            INCBIN "data/tilesets/exterior02.chr"
Exterior02_DataSize         EQU 1024
Exterior02_PaletteData:     INCBIN "data/tilesets/exterior02.pal"
Exterior02_PaletteDataSize  EQU 32

House01_Bank                EQU 2
House01_Data:               INCBIN "data/tilesets/interior01.chr"
House01_DataSize            EQU 1024
House01_PaletteData:        INCBIN "data/tilesets/interior01.pal"
House01_PaletteDataSize     EQU 48

Lab01_Bank                  EQU 2
Lab01_Data:                 INCBIN "data/tilesets/lab01.chr"
Lab01_DataSize              EQU 2048
Lab01_PaletteData:          INCBIN "data/tilesets/lab01.pal"
Lab01_PaletteDataSize       EQU 16

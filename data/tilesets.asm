DEF _VRAM9000 EQU $9000
DEF _VRAM8800 EQU $8800

SECTION "Tile Set Functions", ROMX
;   in:
;       A = ID do Tile Set
;   out:
;       DE = Endereço dos dados do TileSet
;       BC = Tamanho em bytes do TileSet
;       HL = Endereço da VRAM pertencente ao TileSet
GetTileSetFromID::
    sla a               ;   ┐ 3 Bit Shift Left Aritmetic, equivalente a multiplicar o acumulador por 8
    sla a               ;   ├ Offset da tabela de tileset com base no ID
    sla a               ;   ┘ ID 0 = Offset 0, ID 1 = Offset 16, etc
    ld e, a             ;   ┐ move o offset pro reg DE
    ld d, 0             ;   ┘
    ld hl, TileSets     ;   move o ponteiro da tabela de tileset pro reg HL
    add hl, de          ;   adiciona o offset no ponteiro
    ld a, [hl+]         ;   ┐
    ld e, a             ;   │ copia o ponteiro do tileset pro reg DE
    ld a, [hl+]         ;   │
    ld d, a             ;   ┘
    ld a, [hl+]         ;   ┐
    ld c, a             ;   │ copia o tamanho em bytes do tileset no reg BC
    ld a, [hl+]         ;   │
    ld b, a             ;   ┘
    ld hl, _VRAM9000    ;   copia o endereço da VRAM no reg HL
    ret                 ;   retorna pra função anterior

;   in:
;       A = ID do Tile Set
;   out:
;       HL = Endereço dos dados de palette do TileSet
;       B = Tamanho em bytes dos dados da palette do TileSet
GetTileSetPaletteFromID::
    sla a               ;   ┐ 3 Bit Shift Left Aritmetic, equivalente a multiplicar o acumulador por 8
    sla a               ;   ├ Offset da tabela de tileset com base no ID
    sla a               ;   ┘ ID 0 = Offset 0, ID 1 = Offset 16, etc
    add a, 4            ;   incrementa o offset em 4
    ld e, a             ;   ┐ move o offset pro reg DE
    ld d, 0             ;   ┘
    ld hl, TileSets     ;   move o ponteiro da tabela de tileset pro reg HL
    add hl, de          ;   adiciona o offset no ponteiro
    ld a, [hl+]         ;   ┐
    ld e, a             ;   │ copia o ponteiro do palette do tileset pro reg DE
    ld a, [hl+]         ;   │
    ld d, a             ;   ┘
    ld b, [hl]          ;   copia o tamanho em bytes do tilemap no reg B
    ld a, d             ;   ┐
    ld h, a             ;   │ copia o ponteiro do palette do tileset 
    ld a, e             ;   │  do reg DE
    ld l, a             ;   ┘  pro reg HL
    ret                 ;   retorna pra função anterior

; Funções para retornar a localização do tile set responsavel pelo 'window' que fica na parte de baixo da tela
GetBorderTileData::
    ld de, TextFont_Data
    ld bc, TextFont_DataSize
    ld hl, _VRAM8800
    ret
GetBorderTilePalette::
    ld hl, TextFont_PaletteData
    ld b, TextFont_PaletteDataSize
    ret

SECTION "Tile Set Data", ROMX
TileSets:                               ; 8 bytes per entry
    ; id 0
    dw Exterior01_Data                  ; 2 bytes   -   data do tileset
    dw Exterior01_DataSize              ; 2 bytes   -   tamnhanho do tileset em bytes 
    dw Exterior01_PaletteData           ; 2 bytes   -   palettes
    db Exterior01_PaletteDataSize       ; 1 byte    -   bytes
    db 0                                ; 1 byte    -   zeros
    ; id 1                      
    dw House01_Data                     ; 2 bytes   -   data do tileset
    dw House01_DataSize                 ; 2 bytes   -   tamnhanho do tileset em bytes 
    dw House01_PaletteData              ; 2 bytes   -   palettes
    db House01_PaletteDataSize          ; 1 byte    -   bytes
    db 0                                ; 1 byte    -   zeros
    ; id 2
    dw Exterior02_Data           
    dw Exterior02_DataSize       
    dw Exterior02_PaletteData    
    db Exterior02_PaletteDataSize
    db 0   
    ;id 3
    dw Lab01_Data           
    dw Lab01_DataSize       
    dw Lab01_PaletteData    
    db Lab01_PaletteDataSize
    db 0   

Exterior01_Data:            INCBIN "data/tilesets/exterior01.chr"
Exterior01_DataSize         EQU 2048
Exterior01_PaletteData:     INCBIN "data/tilesets/exterior01.pal"
Exterior01_PaletteDataSize  EQU 32

Exterior02_Data:            INCBIN "data/tilesets/exterior02.chr"
Exterior02_DataSize         EQU 1024
Exterior02_PaletteData:     INCBIN "data/tilesets/exterior02.pal"
Exterior02_PaletteDataSize  EQU 32

House01_Data:               INCBIN "data/tilesets/interior01.chr"
House01_DataSize            EQU 1024
House01_PaletteData:        INCBIN "data/tilesets/interior01.pal"
House01_PaletteDataSize     EQU 48

Lab01_Data:                 INCBIN "data/tilesets/lab01.chr"
Lab01_DataSize              EQU 2048
Lab01_PaletteData:          INCBIN "data/tilesets/lab01.pal"
Lab01_PaletteDataSize       EQU 16

TextFont_Data:              INCBIN "data/tilesets/textfont.chr"
TextFont_DataSize           EQU 2048
TextFont_PaletteData:       INCBIN "data/tilesets/textfont.pal"
TextFont_PaletteDataSize    EQU 8

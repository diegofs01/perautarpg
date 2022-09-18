INCLUDE "hardware.inc"

SECTION "Tile Set Functions", ROMX
;   Copia os ponteiros de dados do Tileset
;   Retorna:
;       DE = Endereço dos dados do TileSet
;       BC = Tamanho em bytes do TileSet
;       HL = Endereço da VRAM pertencente ao TileSet
GetTileSetData::
    ld a, [ActiveTilesetId]         ;   Copia o ID do Tileset Atual no acumulador
    sla a                           ;   ┐
    sla a                           ;   ├ Converte o ID em Offset (ID 1 = Offset 16, ID 2 = Offset 32, etc)
    sla a                           ;   │
    sla a                           ;   ┘
    ld d, 0                         ;   ┐ Copia o offset pro reg DE
    ld e, a                         ;   ┘
    ld hl, TileSets                 ;   Copia o ponteiro da tabela de tileset pro reg HL
    add hl, de                      ;   Adiciona o offset no ponteiro

    ld de, TileSetBank_D
    ld a, [hl+]
    ld [de], a

    ld de, TileSetId_D
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

SECTION "Tile Set Pointer Table", ROMX
TileSets:                                      ; 16 bytes per entry
    ; id 0
    db TextFont_Bank                            ; 1 byte     -   bank do tileset
    db TextFont_ID                              ; 1 byte     -   id do tileset
    dw TextFont_Data                            ; 2 bytes    -   data do tileset
    dw TextFont_DataSize                        ; 2 bytes    -   tamnhanho do tileset em bytes 
    dw TextFont_PaletteData                     ; 2 bytes    -   palettes
    db TextFont_PaletteDataSize                 ; 1 byte     -   bytes
    ds 7
    ; id 1
    db Machi_Exterior_01_Bank                   ; 1 byte     -   bank do tileset
    db Machi_Exterior_01_ID                     ; 1 byte     -   id do tileset
    dw Machi_Exterior_01_Data                   ; 2 bytes    -   data do tileset
    dw Machi_Exterior_01_DataSize               ; 2 bytes    -   tamnhanho do tileset em bytes 
    dw Machi_Exterior_01_PaletteData            ; 2 bytes    -   palettes
    db Machi_Exterior_01_PaletteDataSize        ; 1 byte     -   bytes
    ds 7
    ; id 2
    db Machi_Exterior_02_Bank
    db Machi_Exterior_02_ID
    dw Machi_Exterior_02_Data
    dw Machi_Exterior_02_DataSize       
    dw Machi_Exterior_02_PaletteData    
    db Machi_Exterior_02_PaletteDataSize
    ds 7
    ; id 3
    db Machi_Interior_01_Bank
    db Machi_Interior_01_ID
    dw Machi_Interior_01_Data
    dw Machi_Interior_01_DataSize
    dw Machi_Interior_01_PaletteData
    db Machi_Interior_01_PaletteDataSize
    ds 7
    ; id 4
    db Machi_Interior_02_Bank
    db Machi_Interior_02_ID
    dw Machi_Interior_02_Data
    dw Machi_Interior_02_DataSize       
    dw Machi_Interior_02_PaletteData    
    db Machi_Interior_02_PaletteDataSize
    ds 7

DEF TileSetsBank EQU 2
SECTION "Tile Set Data", ROMX, BANK[TileSetsBank]
TextFont_Bank                       EQU TileSetsBank
TextFont_ID                         EQU 0
TextFont_Data:                      INCBIN "data/tilesets/textfont.chr"
TextFont_DataSize                   EQU 2048
TextFont_PaletteData:               INCBIN "data/tilesets/textfont.pal"
TextFont_PaletteDataSize            EQU 8

Machi_Exterior_01_Bank              EQU TileSetsBank
Machi_Exterior_01_ID                EQU 1
Machi_Exterior_01_Data:             INCBIN "data/tilesets/Machi_Exterior_01.chr"
Machi_Exterior_01_DataSize          EQU 2048
Machi_Exterior_01_PaletteData:      INCBIN "data/tilesets/Machi_Exterior_01.pal"
Machi_Exterior_01_PaletteDataSize   EQU 32

Machi_Exterior_02_Bank              EQU TileSetsBank
Machi_Exterior_02_ID                EQU 2
Machi_Exterior_02_Data:             INCBIN "data/tilesets/Machi_Exterior_02.chr"
Machi_Exterior_02_DataSize          EQU 1024
Machi_Exterior_02_PaletteData:      INCBIN "data/tilesets/Machi_Exterior_02.pal"
Machi_Exterior_02_PaletteDataSize   EQU 32

Machi_Interior_01_Bank              EQU TileSetsBank
Machi_Interior_01_ID                EQU 3
Machi_Interior_01_Data:             INCBIN "data/tilesets/Machi_Interior_01.chr"
Machi_Interior_01_DataSize          EQU 1024
Machi_Interior_01_PaletteData:      INCBIN "data/tilesets/Machi_Interior_01.pal"
Machi_Interior_01_PaletteDataSize   EQU 48

Machi_Interior_02_Bank              EQU TileSetsBank
Machi_Interior_02_ID                EQU 4
Machi_Interior_02_Data:             INCBIN "data/tilesets/Machi_Interior_02.chr"
Machi_Interior_02_DataSize          EQU 2048
Machi_Interior_02_PaletteData:      INCBIN "data/tilesets/Machi_Interior_02.pal"
Machi_Interior_02_PaletteDataSize   EQU 16

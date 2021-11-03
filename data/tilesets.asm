DEF _VRAM9000 EQU $9000
DEF BorderStart EQU $9590

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
    ld de, Border
    ld bc, Border_BytesLength
    ld hl, BorderStart
    ret
GetBorderTilePalette::
    ld hl, Border_PaletteData
    ld b, Border_PaletteBytesToWrite
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

Exterior01_Data:            INCBIN "data/tilesets/exterior01.chr"
Exterior01_DataSize         EQU 1024
Exterior01_PaletteData:     INCBIN "data/tilesets/exterior01.pal"
Exterior01_PaletteDataSize  EQU 32

House01_Data:               INCBIN "data/tilesets/house01.chr"
House01_DataSize            EQU 1024
House01_PaletteData:        INCBIN "data/tilesets/house01.pal"
House01_PaletteDataSize     EQU 48

Border:
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$18,$18,$24,$24,$42,$42
    DB $42,$42,$7E,$7E,$42,$42,$42,$42
    DB $00,$00,$7C,$7C,$42,$42,$42,$42
    DB $7C,$7C,$42,$42,$42,$42,$7C,$7C
    DB $00,$00,$1E,$1E,$20,$20,$40,$40
    DB $40,$40,$40,$40,$20,$20,$1E,$1E
    DB $00,$00,$78,$78,$44,$44,$42,$42
    DB $42,$42,$42,$42,$44,$44,$78,$78
    DB $00,$00,$7E,$7E,$40,$40,$40,$40
    DB $7E,$7E,$40,$40,$40,$40,$7E,$7E
    DB $00,$00,$7E,$7E,$40,$40,$40,$40
    DB $7E,$7E,$40,$40,$40,$40,$40,$40
    DB $00,$00,$1E,$1E,$20,$20,$40,$40
    DB $4E,$4E,$42,$42,$22,$22,$1C,$1C
    DB $00,$00,$42,$42,$42,$42,$42,$42
    DB $7E,$7E,$42,$42,$42,$42,$42,$42
    DB $00,$00,$7C,$7C,$10,$10,$10,$10
    DB $10,$10,$10,$10,$10,$10,$7C,$7C
    DB $00,$00,$04,$04,$04,$04,$04,$04
    DB $04,$04,$44,$44,$44,$44,$38,$38
    DB $00,$00,$42,$42,$44,$44,$48,$48
    DB $70,$70,$48,$48,$44,$44,$42,$42
    DB $00,$00,$40,$40,$40,$40,$40,$40
    DB $40,$40,$40,$40,$40,$40,$7E,$7E
    DB $00,$00,$42,$42,$66,$66,$5A,$5A
    DB $42,$42,$42,$42,$42,$42,$42,$42
    DB $00,$00,$42,$42,$62,$62,$52,$52
    DB $4A,$4A,$46,$46,$42,$42,$42,$42
    DB $00,$00,$3C,$3C,$42,$42,$42,$42
    DB $42,$42,$42,$42,$42,$42,$3C,$3C
    DB $00,$00,$7C,$7C,$42,$42,$42,$42
    DB $7C,$7C,$40,$40,$40,$40,$40,$40
    DB $00,$00,$18,$18,$24,$24,$42,$42
    DB $42,$42,$4A,$4A,$24,$24,$1A,$1A
    DB $00,$00,$7C,$7C,$42,$42,$42,$42
    DB $7C,$7C,$48,$48,$44,$44,$42,$42
    DB $00,$00,$3E,$3E,$40,$40,$40,$40
    DB $3C,$3C,$02,$02,$02,$02,$7C,$7C
    DB $00,$00,$7C,$7C,$10,$10,$10,$10
    DB $10,$10,$10,$10,$10,$10,$10,$10
    DB $00,$00,$42,$42,$42,$42,$42,$42
    DB $42,$42,$42,$42,$42,$42,$3C,$3C
    DB $00,$00,$42,$42,$42,$42,$42,$42
    DB $24,$24,$24,$24,$18,$18,$18,$18
    DB $00,$00,$42,$42,$42,$42,$42,$42
    DB $42,$42,$5A,$5A,$5A,$5A,$24,$24
    DB $00,$00,$42,$42,$42,$42,$24,$24
    DB $18,$18,$24,$24,$42,$42,$42,$42
    DB $00,$00,$44,$44,$44,$44,$28,$28
    DB $10,$10,$10,$10,$10,$10,$10,$10
    DB $00,$00,$7E,$7E,$02,$02,$04,$04
    DB $08,$08,$10,$10,$20,$20,$7E,$7E
    DB $00,$00,$3C,$3C,$46,$46,$4E,$4E
    DB $5A,$5A,$72,$72,$62,$62,$3C,$3C
    DB $00,$00,$08,$08,$18,$18,$28,$28
    DB $08,$08,$08,$08,$08,$08,$3E,$3E
    DB $00,$00,$7E,$7E,$02,$02,$02,$02
    DB $7E,$7E,$40,$40,$40,$40,$7E,$7E
    DB $00,$00,$7E,$7E,$02,$02,$02,$02
    DB $3E,$3E,$02,$02,$02,$02,$7E,$7E
    DB $00,$00,$42,$42,$42,$42,$42,$42
    DB $7E,$7E,$02,$02,$02,$02,$02,$02
    DB $00,$00,$7E,$7E,$40,$40,$40,$40
    DB $7E,$7E,$02,$02,$02,$02,$7E,$7E
    DB $00,$00,$7E,$7E,$40,$40,$40,$40
    DB $7E,$7E,$42,$42,$42,$42,$7E,$7E
    DB $00,$00,$7E,$7E,$02,$02,$02,$02
    DB $02,$02,$02,$02,$02,$02,$02,$02
    DB $00,$00,$7E,$7E,$42,$42,$42,$42
    DB $7E,$7E,$42,$42,$42,$42,$7E,$7E
    DB $00,$00,$7E,$7E,$42,$42,$42,$42
    DB $7E,$7E,$02,$02,$02,$02,$7E,$7E
    DB $00,$00,$10,$10,$10,$10,$00,$00
    DB $00,$00,$10,$10,$10,$10,$00,$00
    DB $10,$10,$10,$10,$10,$10,$10,$10
    DB $10,$10,$10,$10,$10,$10,$10,$10
DEF Border_BytesLength EQU 624
Border_PaletteData:
    DB $FF, $7F, $18, $63, $10, $42, $00, $00
DEF Border_PaletteBytesToWrite EQU 8 ; fixed, 1 pallete, 4 color, 2 bytes/color = 8 bytes

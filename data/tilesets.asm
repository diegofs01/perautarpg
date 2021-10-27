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
    dw Exterior_01                      ; 2 bytes   -   data do tileset
    dw Exterior_01_BytesLength          ; 2 bytes   -   tamnhanho do tileset em bytes 
    dw Exterior_01_PaletteData          ; 2 bytes   -   palettes
    db Exterior_01_PaletteBytesToWrite  ; 1 byte    -   bytes
    db 0                                ; 1 byte    -   zeros
    ; id 1
    dw Interior_01                      ; 2 bytes   -   data
    dw Interior_01_BytesLength          ; 2 bytes   -   tamnhanho em bytes
    dw Interior_01_PaletteData          ; 2 bytes   -   palettes
    db Interior_01_PaletteBytesToWrite  ; 1 byte    -   bytes
    db 0                                ; 1 byte    -   zeros

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

Exterior_01:
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $02,$FF,$20,$FF,$84,$FF,$01,$FF
    DB $54,$FF,$00,$FF,$44,$FF,$0A,$FF
    DB $20,$00,$08,$00,$80,$00,$02,$00
    DB $64,$00,$10,$00,$88,$00,$41,$00
    DB $FF,$00,$3F,$DF,$3F,$D0,$38,$D0
    DB $F8,$10,$38,$D0,$38,$D0,$3F,$D0
    DB $FF,$1F,$3F,$DF,$3F,$DF,$3F,$DF
    DB $FF,$1F,$3F,$DF,$3F,$DF,$FF,$00
    DB $2F,$10,$28,$17,$A8,$17,$38,$07
    DB $6F,$10,$28,$17,$A8,$17,$78,$07
    DB $2F,$10,$28,$17,$A8,$17,$38,$07
    DB $6F,$10,$28,$17,$98,$07,$4F,$00
    DB $F4,$08,$14,$E8,$14,$E8,$1E,$E0
    DB $F4,$08,$14,$E8,$14,$E8,$1D,$E0
    DB $F4,$08,$14,$E8,$14,$E8,$1E,$E0
    DB $F4,$08,$14,$E8,$18,$E0,$F1,$00
    DB $FF,$00,$10,$EF,$10,$EF,$10,$EF
    DB $FF,$00,$81,$7E,$81,$7E,$81,$7E
    DB $FF,$00,$10,$EF,$10,$EF,$10,$EF
    DB $FF,$00,$81,$7E,$81,$7E,$FF,$00
    DB $20,$21,$08,$0B,$82,$85,$06,$09
    DB $66,$79,$16,$29,$B6,$C9,$76,$89
    DB $76,$89,$76,$89,$76,$89,$76,$89
    DB $76,$89,$76,$89,$76,$89,$76,$89
    DB $76,$89,$74,$8B,$72,$8D,$76,$89
    DB $66,$99,$56,$A9,$36,$C9,$00,$FF
    DB $20,$A0,$08,$C8,$40,$A0,$62,$92
    DB $64,$9C,$68,$94,$6C,$92,$6E,$91
    DB $6E,$91,$6E,$91,$6E,$91,$6E,$91
    DB $6E,$91,$6E,$91,$6E,$91,$6E,$91
    DB $6E,$91,$2E,$D1,$4E,$B1,$6E,$91
    DB $66,$99,$6A,$95,$6C,$93,$00,$FF
    DB $00,$FF,$DB,$24,$DB,$24,$DB,$24
    DB $DB,$24,$DB,$24,$DB,$24,$DB,$24
    DB $DB,$24,$DB,$24,$DB,$24,$DB,$24
    DB $DB,$24,$DB,$24,$DB,$24,$DB,$24
    DB $00,$FF,$DB,$24,$DB,$24,$DB,$24
    DB $DB,$24,$DB,$24,$DB,$24,$00,$FF
    DB $03,$03,$2F,$0C,$9F,$10,$3F,$28
    DB $7F,$44,$7F,$44,$FF,$82,$7F,$42
    DB $7F,$41,$FF,$A1,$FF,$93,$7F,$4C
    DB $7F,$34,$7F,$42,$FF,$A4,$FF,$93
    DB $7F,$4C,$37,$34,$87,$02,$03,$03
    DB $56,$03,$02,$03,$46,$03,$0B,$01
    DB $C2,$C0,$F0,$30,$FC,$08,$FD,$14
    DB $FE,$22,$FE,$22,$FF,$41,$FE,$42
    DB $FE,$82,$FF,$85,$FF,$C9,$FF,$32
    DB $FC,$2C,$FE,$42,$FF,$25,$FF,$C9
    DB $FE,$32,$EC,$2C,$C4,$40,$C1,$C0
    DB $54,$C0,$40,$C0,$44,$C0,$8A,$80
    DB $02,$FF,$20,$FF,$84,$FF,$01,$FF
    DB $54,$FF,$00,$FE,$44,$FC,$09,$F8
    DB $00,$F8,$20,$FC,$84,$FE,$01,$FF
    DB $54,$FF,$00,$FF,$44,$FF,$0A,$FF
    DB $02,$FF,$20,$FF,$84,$FF,$01,$FF
    DB $54,$FF,$00,$7F,$84,$3F,$4A,$1F
    DB $22,$1F,$20,$3F,$84,$7F,$01,$FF
    DB $54,$FF,$00,$FF,$44,$FF,$0A,$FF
    DB $20,$00,$08,$00,$80,$00,$02,$00
    DB $74,$18,$00,$3C,$C4,$7E,$0A,$FF
    DB $20,$80,$08,$C0,$80,$E0,$02,$F0
    DB $54,$F0,$10,$E0,$48,$C0,$41,$80
    DB $20,$01,$08,$03,$84,$07,$01,$0F
    DB $64,$0F,$10,$07,$88,$03,$40,$01
    DB $02,$FF,$20,$7E,$84,$3C,$02,$18
    DB $64,$00,$10,$00,$88,$00,$41,$00
    DB $20,$00,$08,$00,$80,$00,$02,$00
    DB $64,$03,$10,$07,$84,$0F,$4A,$0F
    DB $22,$0F,$00,$0F,$84,$07,$01,$03
    DB $64,$00,$10,$00,$88,$00,$41,$00
    DB $20,$00,$08,$00,$80,$00,$02,$00
    DB $64,$C0,$10,$E0,$48,$F0,$01,$F0
    DB $00,$F0,$28,$F0,$80,$E0,$02,$C0
    DB $64,$00,$10,$00,$88,$00,$41,$00
    DB $02,$FF,$20,$FF,$84,$FF,$01,$FF
    DB $64,$00,$10,$00,$88,$00,$41,$00
    DB $20,$00,$08,$00,$80,$00,$02,$00
    DB $54,$FF,$00,$FF,$44,$FF,$0A,$FF
    DB $00,$F0,$28,$F0,$80,$F0,$02,$F0
    DB $54,$F0,$00,$F0,$48,$F0,$01,$F0
    DB $22,$0F,$00,$0F,$84,$0F,$01,$0F
    DB $64,$0F,$10,$0F,$84,$0F,$4A,$0F
    DB $20,$01,$08,$03,$84,$07,$01,$0F
    DB $74,$1F,$00,$3F,$C4,$7F,$0A,$FF
    DB $02,$FF,$20,$7F,$84,$3F,$01,$1F
    DB $64,$0F,$10,$07,$88,$03,$40,$01
    DB $20,$80,$08,$C0,$80,$E0,$02,$F0
    DB $54,$F8,$00,$FC,$44,$FE,$0A,$FF
    DB $02,$FF,$20,$FE,$84,$FC,$02,$F8
    DB $54,$F0,$10,$E0,$48,$C0,$41,$80
DEF Exterior_01_BytesLength EQU 736
Exterior_01_PaletteData:
    DB $FF, $7F, $18, $63, $00, $03, $00, $01
    DB $FF, $7F, $08, $21, $10, $00, $10, $01
    DB $FF, $7F, $18, $63, $08, $21, $10, $00
    DB $00, $03, $00, $01, $10, $01, $00, $00
    DB $FF, $7F, $1F, $3F, $10, $01, $18, $63
    DB $E1, $71, $41, $70, $00, $03, $00, $01
    DB $1F, $3F, $1F, $3F, $1F, $3F, $1F, $3F
DEF Exterior_01_PaletteBytesToWrite EQU 56 ; fixed, 7 pallete, 4 color, 2 bytes/color = 56 bytes

Interior_01:
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $AA,$00,$55,$00,$AA,$00,$55,$00
    DB $AA,$00,$55,$00,$AA,$00,$55,$00
    DB $FF,$00,$00,$FF,$00,$FF,$00,$FF
    DB $FF,$00,$00,$FF,$00,$FF,$00,$FF
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
    DB $7F,$7F,$80,$80,$BF,$80,$BF,$80
    DB $BF,$80,$BF,$80,$BF,$80,$BF,$80
    DB $FE,$FE,$01,$01,$FD,$03,$FD,$03
    DB $FD,$03,$FD,$03,$FD,$03,$FD,$03
    DB $C0,$BF,$BF,$FF,$BF,$EA,$BA,$EA
    DB $AA,$EA,$AF,$EF,$BF,$FF,$80,$FF
    DB $01,$FF,$FD,$FF,$FD,$97,$FD,$97
    DB $95,$97,$9D,$9F,$FD,$FF,$01,$FF
    DB $80,$FF,$BF,$FF,$BD,$E7,$A7,$FD
    DB $A5,$E5,$BD,$FD,$BF,$FF,$80,$FF
    DB $1D,$FF,$DD,$FF,$DD,$7F,$DD,$7F
    DB $51,$7F,$DD,$FF,$DD,$FF,$1D,$FF
    DB $BF,$FF,$A0,$FF,$A0,$F7,$AC,$F7
    DB $AC,$FF,$BF,$FF,$A0,$EA,$F5,$E0
    DB $FD,$FF,$05,$FF,$05,$FF,$05,$FF
    DB $05,$FF,$FD,$FF,$05,$AF,$57,$07
    DB $7F,$7F,$80,$80,$81,$84,$83,$88
    DB $87,$90,$8F,$A0,$9F,$80,$BF,$80
    DB $FE,$FE,$03,$01,$81,$23,$C1,$13
    DB $E1,$0B,$F1,$07,$F9,$03,$FD,$03
    DB $BF,$80,$BF,$80,$9F,$80,$8F,$A0
    DB $87,$90,$83,$88,$81,$84,$80,$82
    DB $FD,$03,$FD,$03,$F9,$03,$F1,$07
    DB $E1,$0B,$C1,$13,$81,$23,$01,$43
    DB $FF,$FF,$C0,$BF,$C0,$BF,$C1,$BF
    DB $C7,$BE,$CA,$BD,$FA,$70,$55,$00
    DB $FF,$FF,$01,$FF,$01,$FF,$81,$FF
    DB $61,$FF,$B1,$5F,$AE,$0E,$55,$00
    DB $FF,$FF,$00,$FF,$00,$FF,$FF,$FF
    DB $55,$AA,$AA,$55,$AA,$00,$55,$00
    DB $FF,$FF,$00,$00,$FF,$00,$FF,$00
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
    DB $BF,$80,$BF,$80,$BF,$80,$BF,$80
    DB $BF,$80,$BF,$80,$BF,$80,$BF,$80
    DB $FD,$03,$FD,$03,$FD,$03,$FD,$03
    DB $FD,$03,$FD,$03,$FD,$03,$FD,$03
    DB $FA,$70,$4D,$4D,$E7,$67,$B5,$85
    DB $FA,$65,$41,$7F,$A7,$3F,$F9,$F9
    DB $AF,$87,$D9,$99,$E7,$E1,$BB,$A6
    DB $47,$BF,$93,$F1,$F6,$CE,$9F,$9F
    DB $62,$63,$94,$93,$4E,$43,$9A,$87
    DB $7B,$4F,$AB,$9F,$DE,$FF,$FE,$AE
    DB $47,$C7,$2B,$CA,$B2,$C2,$99,$E1
    DB $D6,$FA,$DB,$FD,$FD,$FF,$7F,$FB
    DB $AA,$0A,$56,$02,$AB,$02,$5F,$0E
    DB $B4,$1E,$4E,$2D,$AC,$2E,$66,$2F
    DB $6A,$C8,$D5,$40,$6A,$C0,$F5,$70
    DB $AA,$78,$79,$B4,$BE,$74,$6D,$F4
    DB $B3,$27,$68,$30,$B5,$18,$57,$1F
    DB $B1,$1C,$49,$0C,$AF,$07,$54,$01
    DB $DE,$E4,$15,$0C,$EE,$18,$EB,$FC
    DB $0C,$FA,$1B,$F4,$F4,$EA,$A9,$54
    DB $91,$FF,$BB,$D1,$B7,$D1,$AF,$E1
    DB $BF,$E1,$FF,$C1,$BF,$E1,$BD,$E1
    DB $89,$FF,$8D,$8B,$9D,$8B,$AD,$87
    DB $DD,$87,$BF,$83,$FD,$87,$FD,$87
    DB $BB,$D1,$BE,$DF,$BE,$F1,$DE,$E1
    DB $FE,$01,$00,$FF,$00,$FF,$00,$FF
    DB $FD,$8B,$7D,$FB,$7D,$8F,$7B,$87
    DB $7F,$80,$00,$FF,$00,$FF,$00,$FF
    DB $FF,$00,$7F,$FF,$40,$C0,$40,$DF
    DB $CC,$53,$4C,$D3,$40,$DF,$41,$DE
    DB $C3,$5C,$4F,$D0,$40,$DF,$40,$C0
    DB $FF,$7F,$00,$FF,$00,$FF,$00,$FF
    DB $FF,$00,$FE,$FF,$02,$03,$02,$FB
    DB $03,$FA,$02,$FB,$C2,$3B,$E2,$1B
    DB $F3,$0A,$F2,$0B,$02,$FB,$02,$03
    DB $FF,$FE,$00,$FF,$00,$FF,$00,$FF
    DB $FF,$3F,$5F,$C0,$7F,$FF,$BF,$80
    DB $BF,$80,$80,$FF,$BF,$FF,$BE,$E1
    DB $B2,$E1,$BE,$E1,$A0,$FF,$A0,$FF
    DB $A0,$FF,$BF,$FF,$88,$FF,$7F,$FF
    DB $FF,$FC,$FE,$03,$FE,$FF,$FF,$01
    DB $FF,$01,$01,$FF,$FD,$FF,$05,$FF
    DB $05,$FF,$05,$FF,$05,$FF,$05,$FF
    DB $05,$FF,$FD,$FF,$11,$FF,$FE,$FF
    DB $FF,$00,$00,$FF,$00,$FF,$1F,$FF
    DB $E0,$60,$40,$C0,$BF,$BF,$C0,$C0
    DB $FF,$04,$0A,$FB,$0A,$FB,$FA,$FB
    DB $07,$06,$02,$03,$FD,$FD,$03,$03
    DB $96,$94,$AE,$A8,$9F,$94,$BF,$A8
    DB $FF,$80,$C0,$FF,$FF,$BF,$80,$FF
    DB $FD,$FB,$85,$FB,$FD,$03,$05,$FB
    DB $FD,$AB,$03,$FF,$FF,$FD,$01,$FF
    DB $AA,$00,$55,$00,$AA,$00,$55,$00
    DB $AA,$00,$57,$07,$B7,$18,$7C,$20
    DB $BB,$24,$7C,$23,$AF,$30,$70,$3F
    DB $AF,$2F,$64,$27,$A7,$27,$5E,$1D
    DB $AA,$00,$55,$00,$AA,$00,$55,$00
    DB $AA,$00,$F5,$E0,$EA,$18,$3D,$04
    DB $DE,$24,$3D,$C4,$F6,$0C,$0D,$FC
    DB $F6,$F4,$25,$E4,$E6,$E4,$BD,$78
    DB $00,$00,$00,$FF,$FF,$00,$00,$FF
    DB $F0,$0F,$F0,$0F,$0F,$F0,$0F,$F0
    DB $F0,$0F,$F0,$0F,$0F,$F0,$0F,$F0
    DB $00,$FF,$FF,$00,$00,$FF,$00,$00
DEF Interior_01_BytesLength EQU 832
Interior_01_PaletteData:
    db $FB, $6F, $58, $1E, $F4, $0D, $E7, $1C
    db $F6, $2B, $2C, $07, $C5, $01, $E7, $1C
    db $F7, $7E, $72, $7E, $8D, $7D, $E7, $1C
    db $FB, $6F, $7F, $62, $5E, $19, $E7, $1C
    db $FB, $6F, $B5, $56, $AD, $35, $E7, $1C
    db $FF, $7F, $FF, $7F, $FF, $7F, $FF, $7F
    db $FF, $7F, $FF, $7F, $FF, $7F, $FF, $7F
    ;db $FF, $7F, $FF, $7F, $FF, $7F, $FF, $7F
DEF Interior_01_PaletteBytesToWrite EQU 56 ; fixed, 7 pallete, 4 color, 2 bytes/color = 56 bytes
DEF WindowVRAMLoc EQU $9C00

SECTION "Window Functions", ROMX

;   in:
;       A = ID do Window
;   out:
;       DE = Endereço dos dados do Window
;       BC = Tamanho em bytes do Window
;       HL = Endereço da VRAM pertencente ao Window
GetWindowDataFromID::
    sla a                       ;   ────┐ 3 Bit Shift Left Aritmetic, equivalente a multiplicar o acumulador por 8
    sla a                       ;       ├ Offset da tabela de Window com base no ID
    sla a                       ;   ────┘ ID 0 = Offset 0, ID 1 = Offset 16, etc
    ld e, a                     ;   ┐ move o offset pro reg DE
    ld d, 0                     ;   ┘
    ld hl, WindowData             ;   move o ponteiro da tabela de Window pro reg HL
    add hl, de                  ;   adiciona o offset no ponteiro
    ld a, [hl+]                 ;   ┐
    ld e, a                     ;   │ copia o ponteiro do Window pro reg DE
    ld a, [hl+]                 ;   │
    ld d, a                     ;   ┘
    inc hl                      ;   ┐ incrementa o ponteiro do Window 2 vezes
    inc hl                      ;   ┘
    ld a, [hl+]                 ;   ┐
    ld c, a                     ;   │ copia o tamanho em bytes do Window no reg BC
    ld a, [hl+]                 ;   │
    ld b, a                     ;   ┘
    ld hl, WindowVRAMLoc           ;   copia o endereço da VRAM no reg HL
    ret                         ;   retorna pra função anterior

;   in:
;       A = ID do Window
;   out:
;       DE = Endereço dos dados de atributos do Window
;       BC = Tamanho em bytes dos atributos do Window
;       HL = Endereço da VRAM pertencente aos atributos do Window
GetWindowAttributesFromID::
    sla a                       ;   ────┐ 3 Bit Shift Left Aritmetic, equivalente a multiplicar o acumulador por 8
    sla a                       ;       ├ Offset da tabela de Window com base no ID
    sla a                       ;   ────┘ ID 0 = Offset 0, ID 1 = Offset 16, etc
    add a, 2                    ;   adiciona 2 no acumulador
    ld e, a                     ;   ┐ move o offset pro reg DE
    ld d, 0                     ;   ┘
    ld hl, WindowData             ;   move o ponteiro da tabela de Window pro reg HL
    add hl, de                  ;   adiciona o offset no ponteiro
    ld a, [hl+]                 ;   ┐
    ld e, a                     ;   │ copia o ponteiro dos atributos do Window pro reg DE
    ld a, [hl+]                 ;   │
    ld d, a                     ;   ┘
    ld a, [hl+]                 ;   ┐
    ld c, a                     ;   │ copia o tamanho em bytes do Window no reg BC
    ld a, [hl+]                 ;   │
    ld b, a                     ;   ┘
    ld hl, WindowVRAMLoc        ;   copia o endereço da VRAM no reg HL
    ret                         ;   retorna pra função anterior

GetWindowWitdhFromID::
    sla a                       ;   ────┐ 3 Bit Shift Left Aritmetic, equivalente a multiplicar o acumulador por 8
    sla a                       ;       ├ Offset da tabela de Window com base no ID
    sla a                       ;   ────┘ ID 0 = Offset 0, ID 1 = Offset 16, etc
    add 6
    ld d, 0
    ld e, a
    ld hl, WindowData             ;   move o ponteiro da tabela de Window pro reg HL
    add hl, de
    ld de, TempWindowWidth
    ld a, [hl+]
    ld [de], a
    ld de, TempWindowVRAMLineOffset
    ld a, [hl]
    ld [de], a
    ret

SECTION "Window Pointer Table", ROMX
WindowData:
    ;ID 0
    dw Menu_Tiles
    dw Menu_Attributes
    dw Menu_BytesLength
    db Menu_Width
    db Menu_VRAMLineOffset
    ;ID 1
    dw PlayerInfo_Tiles
    dw PlayerInfo_Attributes
    dw PlayerInfo_BytesLength
    db PlayerInfo_Width
    db PlayerInfo_VRAMLineOffset

    dw StatusBar_Tiles
    dw StatusBar_Attributes
    dw StatusBar_BytesLength
    db StatusBar_Width
    db StatusBar_VRAMLineOffset

SECTION "Window Data", ROMX
Menu_Tiles:                 INCBIN "data/windows/menu.tilemap"
Menu_Attributes:            INCBIN "data/windows/menu.attrmap"
Menu_BytesLength            EQU 144
Menu_Width                  EQU 8
Menu_VRAMLineOffset         EQU 24

PlayerInfo_Tiles:           INCBIN "data/windows/PlayerInfo.tilemap"
PlayerInfo_Attributes:      INCBIN "data/windows/PlayerInfo.attrmap"
PlayerInfo_BytesLength      EQU 360
PlayerInfo_Width            EQU 20
PlayerInfo_VRAMLineOffset   EQU 12

StatusBar_Tiles:            INCBIN "data/maps/statusbar.tilemap"
StatusBar_Attributes:       INCBIN "data/maps/statusbar.attrmap"
StatusBar_BytesLength       EQU 40
StatusBar_Width             EQU 20
StatusBar_VRAMLineOffset    EQU 12
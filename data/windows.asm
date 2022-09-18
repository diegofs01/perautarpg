INCLUDE "hardware.inc"

SECTION "Window Functions", ROMX

;   Copia os ponteiros e dados da Janela na Memoria
GetWindowData::
    ld a, [ActiveWindowID]
    sla a                       ;   ┐
    sla a                       ;   ├ Converte o ID em Offset (ID 1 = Offset 16, ID 2 = Offset 32, etc)
    sla a                       ;   │
    sla a                       ;   ┘
    ld d, 0                     ;   ┐ Copia o offset pro reg DE
    ld e, a                     ;   ┘
    ld hl, WindowData           ;   move o ponteiro da tabela de Window pro reg HL
    add hl, de                  ;   adiciona o offset no ponteiro
    ld de, WindowBank_D
    ld a, [hl+]
    ld [de], a
    ld de, WindowId_D
    ld a, [hl+]
    ld [de], a
    ld de, WindowTiles_P
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a
    ld de, WindowAttributes_P
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a
    ld de, WindowBytesLength_P
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a  
    ld de, WindowWidth_D
    ld a, [hl+]
    ld [de], a
    ld de, WindowVRAMLineOffset_D
    ld a, [hl+]
    ld [de], a
    ret                         ;   retorna pra função anterior

SECTION "Window Pointer Table", ROMX
WindowData:
    ;ID 0
    db StatusBar_Bank
    db StatusBar_ID
    dw StatusBar_Tiles
    dw StatusBar_Attributes
    dw StatusBar_BytesLength
    db StatusBar_Width
    db StatusBar_VRAMLineOffset
    ds 6
    ;ID 1
    db Menu_Bank
    db Menu_ID
    dw Menu_Tiles
    dw Menu_Attributes
    dw Menu_BytesLength
    db Menu_Width
    db Menu_VRAMLineOffset
    ds 6
    ;ID 2
    db PlayerInfo_Bank
    db PlayerInfo_ID
    dw PlayerInfo_Tiles
    dw PlayerInfo_Attributes
    dw PlayerInfo_BytesLength
    db PlayerInfo_Width
    db PlayerInfo_VRAMLineOffset
    ds 6

SECTION "Window Data", ROMX, BANK[4]
StatusBar_Bank              EQU 4
StatusBar_ID                EQU 0
StatusBar_Tiles:            INCBIN "data/windows/StatusBar.tilemap"
StatusBar_Attributes:       INCBIN "data/windows/StatusBar.attrmap"
StatusBar_BytesLength       EQU 40
StatusBar_Width             EQU 20
StatusBar_VRAMLineOffset    EQU 12

StartMenu_Bank              EQU 4
StartMenu_ID                EQU 1
StartMenu_Tiles:            INCBIN "data/windows/StartMenu.tilemap"
StartMenu_Attributes:       INCBIN "data/windows/StartMenu.attrmap"
StartMenu_BytesLength       EQU 144
StartMenu_Width             EQU 8
StartMenu_VRAMLineOffset    EQU 24

PlayerInfo_Bank             EQU 4
PlayerInfo_ID               EQU 2
PlayerInfo_Tiles:           INCBIN "data/windows/PlayerInfo.tilemap"
PlayerInfo_Attributes:      INCBIN "data/windows/PlayerInfo.attrmap"
PlayerInfo_BytesLength      EQU 360
PlayerInfo_Width            EQU 20
PlayerInfo_VRAMLineOffset   EQU 12

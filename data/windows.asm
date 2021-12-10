DEF MenuVRAMLoc EQU $9C00

SECTION "Window Functions", ROMX

; Funções para retornar a localização do menu
GetMenuData::
    ld de, Menu_Tiles
    ld bc, Menu_BytesLength
    ld hl, MenuVRAMLoc
    ret
GetMenuAttributes::
    ld de, Menu_Attributes
    ld bc, Menu_BytesLength
    ld hl, MenuVRAMLoc
    ret

SECTION "Window Data", ROMX

Menu_Tiles:        INCBIN "data/windows/menu.tilemap"
Menu_Attributes:   INCBIN "data/windows/menu.attrmap"
Menu_BytesLength   EQU 128
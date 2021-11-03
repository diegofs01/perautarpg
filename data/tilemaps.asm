DEF _SCRN0 EQU $9800
DEF WindowStart EQU $9A00

SECTION "Tile Map Functions", ROMX
;   in:
;       A = ID do Tile Map
;   out:
;       DE = Endereço dos dados do TileMap
;       BC = Tamanho em bytes do TileMap
;       HL = Endereço da VRAM pertencente ao TileMap
GetTileMapDataFromID::
    sla a                       ;   ────┐ 4 Bit Shift Left Aritmetic, equivalente a multiplicar o acumulador por 16
    sla a                       ;       ├ 
    sla a                       ;       │ Offset da tabela de tilemap com base no ID
    sla a                       ;   ────┘ ID 0 = Offset 0, ID 1 = Offset 16, etc
    ld e, a                     ;   ┐ move o offset pro reg DE
    ld d, 0                     ;   ┘
    ld hl, TileMaps             ;   move o ponteiro da tabela de tilemap pro reg HL
    add hl, de                  ;   adiciona o offset no ponteiro
    ld a, [hl+]                 ;   ┐
    ld e, a                     ;   │ copia o ponteiro do tilemap pro reg DE
    ld a, [hl+]                 ;   │
    ld d, a                     ;   ┘
    inc hl                      ;   ┐ incrementa o ponteiro do tilemap 2 vezes
    inc hl                      ;   ┘
    ld a, [hl+]                 ;   ┐
    ld c, a                     ;   │ copia o tamanho em bytes do tilemap no reg BC
    ld a, [hl+]                 ;   │
    ld b, a                     ;   ┘
    ld hl, _SCRN0               ;   copia o endereço da VRAM no reg HL
    ret                         ;   retorna pra função anterior

;   in:
;       A = ID do Tile Map
;   out:
;       DE = Endereço dos dados de atributos do TileMap
;       BC = Tamanho em bytes dos atributos do TileMap
;       HL = Endereço da VRAM pertencente aos atributos do TileMap
GetTileMapAttributeFromID::
    sla a                       ;   ────┐ 4 Bit Shift Left Aritmetic, equivalente a multiplicar o acumulador por 16
    sla a                       ;       ├ 
    sla a                       ;       │ Offset da tabela de tilemap com base no ID
    sla a                       ;   ────┘ ID 0 = Offset 0, ID 1 = Offset 16, etc
    add a, 2                    ;   adiciona 2 no acumulador
    ld e, a                     ;   ┐ move o offset pro reg DE
    ld d, 0                     ;   ┘
    ld hl, TileMaps             ;   move o ponteiro da tabela de tilemap pro reg HL
    add hl, de                  ;   adiciona o offset no ponteiro
    ld a, [hl+]                 ;   ┐
    ld e, a                     ;   │ copia o ponteiro dos atributos do tilemap pro reg DE
    ld a, [hl+]                 ;   │
    ld d, a                     ;   ┘
    ld a, [hl+]                 ;   ┐
    ld c, a                     ;   │ copia o tamanho em bytes do tilemap no reg BC
    ld a, [hl+]                 ;   │
    ld b, a                     ;   ┘
    ld hl, _SCRN0               ;   copia o endereço da VRAM no reg HL
    ret                         ;   retorna pra função anterior

;   in:
;       A = ID do Tile Map
;   out:
;       A = ID do Tile Set
GetTileSetIDFromTileMapID::   
    sla a                       ;   ────┐ 4 Bit Shift Left Aritmetic, equivalente a multiplicar o acumulador por 16
    sla a                       ;       ├ 
    sla a                       ;       │ Offset da tabela de tilemap com base no ID
    sla a                       ;   ────┘ ID 0 = Offset 0, ID 1 = Offset 16, etc
    add a, 6                    ;   adiciona 2 no acumulador
    ld e, a                     ;   ┐ move o offset pro reg DE
    ld d, 0                     ;   ┘
    ld hl, TileMaps             ;   move o ponteiro da tabela de tilemap pro reg HL
    add hl, de                  ;   adiciona o offset no ponteiro da tabela de tilemap
    ld a, [hl]                  ;   move o byte apontado pelo registrador HL pro acumulador
    ret                         ;   retorna pra função anterior

; Funções para retornar a localização da 'window' que fica na parte de baixo da tela
GetWindowData::
    ld de, Window_Tiles
    ld bc, Window_BytesLength
    ld hl, WindowStart
    ret
GetWindowAttributes::
    ld de, Window_Attributes
    ld bc, Window_BytesLength
    ld hl, WindowStart
    ret

;   in:
;       A = ID do Tile Map
;       DE = Offset pro array de colisão de acordo com a posição do jogador
;   out:
;       A = Byte/Data em uma posição específica do 'array' de colisão
GetColisionData::
    sla a                       ;   ────┐ 4 Bit Shift Left Aritmetic, equivalente a multiplicar o acumulador por 16
    sla a                       ;       ├              
    sla a                       ;       │ Offset da tabela de tilemap com base no ID
    sla a                       ;   ────┘ ID 0 = Offset 0, ID 1 = Offset 16, etc
    add a, 7                    ;   Offset pro ponteiro com a tabela de colisao
    ld c, a                     ;   ┐ move o offset pro reg BC
    ld b, 0                     ;   ┘
    ld hl, TileMaps             ;   move o ponteiro da tabela de tilemap pro reg HL
    add hl, bc                  ;   adiciona o offset no ponteiro
    ld a, [hl+]                 ;   ┐
    ld c, a                     ;   │ move o ponteiro da tabela de colisao pro reg BC
    ld a, [hl]                  ;   │
    ld b, a                     ;   ┘
    ld h, a                     ;   ┐
    ld a, c                     ;   │ copia o ponteiro da tabela de colisao pro reg HL   
    ld l, a                     ;   ┘      
    add hl, de                  ;   incrementa o ponteiro com o offset no reg DE
    ld a, [hl]                  ;   copia o byte/data de colisao pro acumulador
    ret                         ;   retorna pra função anterior

;   in:
;       A = ID do Tile Map
;       D = Posição X no Mapa
;       E = Posição Y no Mapa
;   out:
;       A = ID do Tile Map a ser carregado OU 255 em caso de warp nao encontrado
;       D = Posição X no Mapa a ser carregado
;       E = Posição Y no Mapa a ser carregado
GetMapWarpData::
    sla a                       ;   ┐ 4 Bit Shift Left Aritmetic, equivalente a multiplicar o acumulador por 16
    sla a                       ;   │ 
    sla a                       ;   ├ Offset da tabela de tilemap com base no ID
    sla a                       ;   ┘ ID 0 = Offset 0, ID 1 = Offset 16, etc
    add a, 9                    ;   Offset pro ponteiro com a tabela de warps
    ld c, a                     ;   ┐ move o offset pro reg BC
    ld b, 0                     ;   ┘
    ld hl, TileMaps             ;   move o ponteiro da tabela de tilemap pro reg HL
    add hl, bc                  ;   adiciona o offset no ponteiro
    ld a, [hl+]                 ;   ┐
    ld c, a                     ;   │ move o ponteiro do warp data pro reg BC
    ld a, [hl]                  ;   │
    ld b, a                     ;   ┘
    ld h, a                     ;   ┐
    ld a, c                     ;   │ copia o ponteiro do warp data pro reg HL
    ld l, a                     ;   ┘
;       D = Posição X no Mapa a ser carregado
;       E = Posição Y no Mapa a ser carregado
;       BC = Posição do primeiro Warp
;       Verificando PosX
.verificarPosX:
    ld a, [hl]                  ;   move a PosX da tabela de warps pro acumulador
    cp 255                      ;   compara se esta no final da warp table
    jp z, .failed               ;   pula pra função .failed se sim
    cp d                        ;   compara a PosX do acumulador com o recebido
    jp z, .prepararPosY         ;   se existir, pula pra checar a PosY
    ld b, 0                     ;   
    ld c, 5                     ;   
    add hl, bc                  ;   
    jp .verificarPosX           ;   pula de volta pro começo da função
.prepararPosY:
    inc hl                      ;   incrementa o ponteiro pra posição Y
.verificarPosY:
    ld a, [hl]                  ;   move a PosY da tabela de warps pro acumulador
    cp 255                      ;   compara se esta no final da warp table
    jp z, .failed               ;   pula pra função .failed se sim
    cp e                        ;   compara a PosY do acumulador com o recebido
    jp z, .prepararRetorno      ;   se existir, pula pra gerar o retorno
    ld b, 0                     ;   ┐
    ld c, 4                     ;   │
    add hl, bc                  ;   
    jp .verificarPosX           ;   pula de volta pra verificar um novo warp data
.prepararRetorno:
    inc hl                      ;   incrementa o ponteiro 
    ld a, [hl+]                 ;   ┐
    ld d, a                     ;   │ copia a nova posição da sprite
    ld a, [hl+]                 ;   │
    ld e, a                     ;   ┘
    ld a, [hl]                  ;   copia o id do mapa a ser carregado
    jp .end                     ;   pula pra função .end
.failed:
    ld a, 255                   ;   move o valor pro acumulador
.end:
    ret                         ;   retorna pra função anterior

SECTION "Tile Map Data", ROMX
TileMaps:                       ; 16 bytes per entry
    ;ID 0
    dw Map01_Tiles                ; 2 bytes   -   data do tilemap
    dw Map01_Attributes           ; 2 bytes   -   atributos do tilemap
    dw Map01_BytesLength          ; 2 bytes   -   tamanho em bytes do tilemap
    db Map01_TileSetId            ; 1 byte    -   id do tileset usado pelo tilemap
    dw Map01_Colision             ; 2 bytes   -   colisao do tilemap
    dw Map01_Warps                ; 2 bytes   -   tabela de warps do mapa
    dw                            ; 2 bytes   -   zeros
    db                            ; 1 byte    -   zeros   ────┐ Possível uso futuro
    dw                            ; 2 bytes   -   zeros   ────┘
    ; ID 1
    dw House01_Tiles              ; 2 bytes   -   data do tilemap
    dw House01_Attributes         ; 2 bytes   -   atributos do tilemap
    dw House01_BytesLength        ; 2 bytes   -   tamanho em bytes do tilemap
    db House01_TileSetId          ; 1 byte    -   id do tileset usado pelo tilemap
    dw House01_Colision           ; 2 bytes   -   colisao do tilemap
    dw House01_Warps              ; 2 bytes   -   tabela de warps do mapa
    dw                            ; 2 bytes   -   zeros
    db                            ; 1 byte    -   zeros   ────┐ Possível uso futuro
    dw                            ; 2 bytes   -   zeros   ────┘
    ; ID 2
    dw House02_Tiles                
    dw House02_Attributes           
    dw House02_BytesLength          
    db House02_TileSetId            
    dw House02_Colision             
    dw House02_Warps                
    dw
    db
    dw
    ;ID 3
    dw Map02_Tiles      
    dw Map02_Attributes 
    dw Map02_BytesLength
    db Map02_TileSetId  
    dw Map02_Colision   
    dw Map02_Warps      
    dw 
    db 
    dw 

Map01_Tiles:        INCBIN "data/maps/map01.tilemap"
Map01_Attributes:   INCBIN "data/maps/map01.attrmap"
Map01_BytesLength   EQU 320
Map01_TileSetId     EQU 0  
Map01_Colision:
    DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    DB 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    DB 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    DB 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    DB 0, 0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0
    DB 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
    DB 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
    DB 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
    DB 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 0
    DB 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 0
    DB 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
    DB 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0 
    DB 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    DB 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0
    DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
Map01_Warps:
    ;  MapPosX, MapPosY, To Map Pos X, To Map Pos Y, To Map ID,
    DB      32,      40,           72,          112,         1,
    DB      96,      40,           40,          112,         2,
    DB     144,      72,            0,           72,         3,
    DB     144,      80,            0,           80,         3,
    DB     255,     255

House01_Tiles:        INCBIN "data/maps/house01.tilemap"
House01_Attributes:   INCBIN "data/maps/house01.attrmap"
House01_BytesLength   EQU 320
House01_TileSetId     EQU 1
House01_Colision:
	DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	DB 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0
	DB 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0
	DB 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0
	DB 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0
	DB 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0
	DB 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0
	DB 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0
	DB 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 0, 0, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
House01_Warps:
    ;  MapPosX, MapPosY, To Map Pos X, To Map Pos Y, To Map ID,
    DB      72,     112,           32,           56,         0,
    DB     255,     255

House02_Tiles:        INCBIN "data/maps/house02.tilemap"
House02_Attributes:   INCBIN "data/maps/house02.attrmap"
House02_BytesLength   EQU 320
House02_TileSetId     EQU 1
House02_Colision:
	DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	DB 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0
	DB 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0
    DB 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    DB 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0
	DB 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0
    DB 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0
    DB 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0
	DB 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1
	DB 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 0, 0, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
House02_Warps:
    ;  MapPosX, MapPosY, To Map Pos X, To Map Pos Y, To Map ID,
    DB      40,     112,           96,           56,         0,
    DB     255,     255

Map02_Tiles:        INCBIN "data/maps/map02.tilemap"
Map02_Attributes:   INCBIN "data/maps/map02.attrmap"
Map02_BytesLength   EQU 320
Map02_TileSetId     EQU 0  
Map02_Colision:
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$01,$01,$01,$01,$01,$01,$01,$01
    DB $01,$01,$01,$01,$01,$01,$01,$00,$00,$00
    DB $00,$00,$01,$01,$01,$01,$01,$01,$01,$01
    DB $01,$01,$01,$01,$01,$01,$01,$00,$00,$00
    DB $00,$00,$01,$01,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$01,$01,$00,$00,$00
    DB $00,$00,$01,$01,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$01,$01,$00,$00,$00
    DB $00,$00,$01,$01,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$01,$01,$00,$00,$00
    DB $00,$00,$01,$01,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$01,$01,$00,$00,$00
    DB $00,$00,$01,$01,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$01,$01,$00,$00,$00
    DB $02,$01,$01,$01,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$01,$01,$00,$00,$00
    DB $02,$01,$01,$01,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$01,$01,$00,$00,$00
    DB $00,$00,$01,$01,$01,$01,$01,$01,$01,$01
    DB $01,$01,$01,$01,$01,$01,$01,$00,$00,$00
    DB $00,$00,$01,$01,$01,$01,$01,$01,$01,$01
    DB $01,$01,$01,$01,$01,$01,$01,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
Map02_Warps:
    ;  MapPosX, MapPosY, To Map Pos X, To Map Pos Y, To Map ID,
    DB       0,      72,          144,           72,         0,
    DB       0,      80,          144,           80,         0,
    DB     255,     255

Window_Tiles:
    DB $59,$59,$59,$59,$59,$59,$59,$59,$59,$59
    DB $59,$59,$59,$59,$59,$59,$59,$59,$59,$59
    DB $71,$74,$74,$74,$72,$74,$74,$74,$5C,$74
    DB $66,$74,$6D,$74,$59,$59,$59,$59,$59,$59                
DEF Window_BytesLength EQU 40
Window_Attributes:
    DB $07,$07,$07,$07,$07,$07,$07,$07,$07,$07
    DB $07,$07,$07,$07,$07,$07,$07,$07,$07,$07
    DB $07,$07,$07,$07,$07,$07,$07,$07,$07,$07
    DB $07,$07,$07,$07,$07,$07,$07,$07,$07,$07

INCLUDE "hardware.inc"
;DEF MapVRAMLoc EQU $9800
;DEF StatusBarVRAMLoc EQU $9A00

SECTION "Tile Map Functions", ROMX
;   Copia os ponteiros e dados do Mapa na Memoria
GetMapData::
    ld a, [ActiveMapId]         ;   Copia o ID do Mapa Atual no acumulador
    sla a                       ;   ┐
    sla a                       ;   ├ Converte o ID em Offset (ID 1 = Offset 16, ID 2 = Offset 32, etc)
    sla a                       ;   │
    sla a                       ;   ┘
    ld d, 0                     ;   ┐ Copia o offset pro reg DE
    ld e, a                     ;   ┘
    ld hl, TileMaps             ;   Copia o ponteiro da tabela de tilemap pro reg HL
    add hl, de                  ;   Adiciona o offset no ponteiro

    ld de, MapBank_D
    ld a, [hl+]
    ld [de], a

    ld de, MapData_P            ;   ┐
    ld a, [hl+]                 ;   │
    ld [de], a                  ;   ├ Copia o ponteiro com os dados do mapa na memoria
    inc de                      ;   │
    ld a, [hl+]                 ;   │
    ld [de], a                  ;   ┘

    ld de, MapAttr_P            ;   ┐
    ld a, [hl+]                 ;   │
    ld [de], a                  ;   ├ Copia o ponteiro com os atributos do mapa na memoria
    inc de                      ;   │
    ld a, [hl+]                 ;   │
    ld [de], a                  ;   ┘
    
    ld de, MapByteSize_D        ;   ┐
    ld a, [hl+]                 ;   │        
    ld [de], a                  ;   ├ Copia o tamanho em bytes do mapa na memoria
    inc de                      ;   │
    ld a, [hl+]                 ;   │        
    ld [de], a                  ;   ┘

    ld de, MapTileSetId_D       ;   ┐
    ld a, [hl+]                 ;   ├ Copia o ID do tileset do mapa na memoria
    ld [de], a                  ;   ┘

    ld de, MapColision_P        ;   ┐
    ld a, [hl+]                 ;   │
    ld [de], a                  ;   ├ Copia o ponteiro com a colisao do mapa na memoria
    inc de                      ;   │
    ld a, [hl+]                 ;   │
    ld [de], a                  ;   ┘

    ld de, MapWarps_P           ;   ┐
    ld a, [hl+]                 ;   │
    ld [de], a                  ;   ├ Copia o ponteiro com os warps do mapa na memoria
    inc de                      ;   │
    ld a, [hl+]                 ;   │
    ld [de], a                  ;   ┘

    ld de, MapWidth_D           ;   ┐
    ld a, [hl+]                 ;   ├ Copia a largura mapa na memoria
    ld [de], a                  ;   ┘

    ld de, MapHeigth_D          ;   ┐
    ld a, [hl+]                 ;   ├ Copia a altura mapa na memoria
    ld [de], a                  ;   ┘

    ret                         ;   Retorna pra função anterior

;   Copia o ID do Tileset usado pelo Mapa atual
GetTileSetIDFromTileMapID::
    ld a, [ActiveMapId]
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
    ld [ActiveTilesetId], a
    ret                         ;   retorna pra função anterior

; Byte de colisao de acordo com a posição do jogador e do scroll da tela
GetColisionData::
; Processando a posição do jogador
.playerPos:
    ld a, [TempPlayerPosY]  ; joga a posição y do jogador no acumulador
    sub 16                  ; subtrai 16 (compensa o offset da camada das sprites)
    srl a                   ; ┐
    srl a                   ; │ 3 bit shift pra direita, divide a posição por 8
    srl a                   ; ┘
    ld e, a                 ; ┐ joga o a posição processada no registrador DE
    ld d, 0                 ; ┘
    ld hl, 0                ; prepara o registrador HL
    ld a, [MapWidth_D]      ; joga a largura do mapa no acumulador
.loopMulPosY:
    add hl, de              ; adiciona o valor processado no reg HL
    dec a                   ; decrementa o valor da largura do mapa
    cp 0                    ; compara se é zero
    jp nz, .loopMulPosY     ; volta pro começo se o valor da largura do mapa nao for zero

    ld a, [TempPlayerPosX]  ; joga a posição x do jogador no acumulador
    sub 8                   ; subtrai 8 (compensa o offset da camada das sprites)
    srl a                   ; ┐
    srl a                   ; │ 3 bit shift pra direita, divide a posição por 8
    srl a                   ; ┘
    ld e, a                 ; ┐ joga o a posição processada no registrador DE
    ld d, 0                 ; ┘

    add hl, de              ; HL = posição do jogador processado (((Y-16)/8)*20)+((X-8)/8) 
    push hl                 ; joga a posição do jogador processado na stack

.windowPos:
    ld a, [rSCY]
    srl a
    srl a
    srl a
    ld e, a
    ld d, 0
    ld hl, 0
    ld a, [MapWidth_D]
.loopMulScrY:
    add hl, de
    dec a
    cp 0
    jp nz, .loopMulScrY
    
    ld a, [rSCX]
    srl a
    srl a
    srl a
    ld e, a
    ld d, 0

    add hl, de
    push hl

    pop de
    pop bc

    ld a, 3
    ld [rSVBK], a

    ld hl, MapColision

    add hl, bc
    add hl, de

    ld a, [hl] 
    ld [ByteColisao], a
    
    ld a, 1
    ld [rSVBK], a

    ret


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
    ld bc, 5   
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

SECTION "Tile Map Pointer Table", ROMX
TileMaps:                       ; 16 bytes per entry
    ;ID 0
    db Map01_Bank                   ; 1 byte    -   bank do tilemap
    dw Map01_Tiles                  ; 2 bytes   -   data do tilemap
    dw Map01_Attributes             ; 2 bytes   -   atributos do tilemap
    dw Map01_BytesLength            ; 2 bytes   -   tamanho em bytes do tilemap
    db Map01_TileSetId              ; 1 byte    -   id do tileset usado pelo tilemap
    dw Map01_Colision               ; 2 bytes   -   colisao do tilemap
    dw Map01_Warps                  ; 2 bytes   -   tabela de warps do mapa
    db Map01_Width                  ; 1 byte    -   largura / X
    db Map01_Heigth                 ; 1 byte    -   altura  / Y
    dw                              ; 2 bytes   -   zeros   ───── Possível uso futuro
    ; ID 1
    db House01_Bank                 ; 1 byte    -   bank do tilemap
    dw House01_Tiles                ; 2 bytes   -   data do tilemap
    dw House01_Attributes           ; 2 bytes   -   atributos do tilemap
    dw House01_BytesLength          ; 2 bytes   -   tamanho em bytes do tilemap
    db House01_TileSetId            ; 1 byte    -   id do tileset usado pelo tilemap
    dw House01_Colision             ; 2 bytes   -   colisao do tilemap
    dw House01_Warps                ; 2 bytes   -   tabela de warps do mapa
    db House01_Width                ; 1 byte    -   largura / X
    db House01_Heigth               ; 1 byte    -   altura  / Y
    dw                              ; 2 bytes   -   zeros   ───── Possível uso futuro
    ; ID 2
    db House02_Bank                 ; 1 byte    -   bank do tilemap
    dw House02_Tiles                
    dw House02_Attributes           
    dw House02_BytesLength          
    db House02_TileSetId            
    dw House02_Colision             
    dw House02_Warps                
    db House02_Width
    db House02_Heigth
    dw
    ;ID 3
    db Map02_Bank      
    dw Map02_Tiles      
    dw Map02_Attributes 
    dw Map02_BytesLength
    db Map02_TileSetId  
    dw Map02_Colision   
    dw Map02_Warps      
    db Map02_Width
    db Map02_Heigth 
    dw 
    ;ID 4
    db Lab01_Bank      
    dw Lab01_Tiles      
    dw Lab01_Attributes 
    dw Lab01_BytesLength
    db Lab01_TileSetId  
    dw Lab01_Colision   
    dw Lab01_Warps      
    db Lab01_Width
    db Lab01_Heigth 
    dw 

SECTION "Tile Map Data", ROMX, BANK[3]
Map01_Bank          EQU 3
Map01_ID            EQU 0
Map01_Tiles:        INCBIN "data/maps/map01.tilemap"
Map01_Attributes:   INCBIN "data/maps/map01.attrmap"
Map01_BytesLength   EQU 320
Map01_TileSetId     EQU 0  
Map01_Width         EQU 20
Map01_Heigth        EQU 16
Map01_Colision:
    DB   0, 0, 0, 0,   0, 0, 0, 0,   0,   0, 0, 0,   0, 0, 0, 0, 0, 0,   0, 0
    DB   0, 0, 0, 0,   0, 0, 0, 0,   0,   0, 0, 0,   0, 0, 0, 0, 0, 0,   0, 0
    DB   0, 0, 0, 0,   0, 0, 0, 0,   1,   0, 0, 0,   0, 0, 0, 0, 0, 0,   0, 0
    DB   0, 0, 0, 0,   0, 0, 0, 0,   1,   0, 0, 0,   0, 0, 0, 0, 0, 0,   0, 0
    DB   0, 0, 0, 0,   0, 0, 0, 0,   1,   0, 0, 0,   0, 0, 0, 0, 0, 0,   0, 0
    DB   0, 0, 0, 0, 128, 0, 0, 0,   1,   0, 0, 0, 129, 0, 0, 0, 0, 0,   0, 0
    DB   0, 0, 0, 0,   1, 0, 0, 0,   1,   0, 0, 0,   1, 0, 0, 0, 0, 0,   0, 0
    DB   0, 0, 1, 1,   1, 1, 1, 1,   1,   1, 1, 1,   1, 1, 1, 1, 1, 0,   0, 0
    DB   0, 0, 1, 1,   1, 1, 1, 1,   1,   1, 1, 1,   1, 1, 1, 1, 1, 0,   0, 0
    DB 132, 1, 1, 1,   1, 1, 1, 1,   1,   1, 1, 1,   1, 1, 1, 1, 1, 1, 130, 0
    DB 133, 1, 1, 1,   1, 1, 1, 1,   1,   1, 1, 1,   1, 1, 1, 1, 1, 1, 131, 0
    DB   0, 0, 1, 1,   1, 1, 1, 1,   1,   1, 1, 1,   1, 1, 1, 1, 1, 0,   0, 0
    DB   0, 0, 1, 1,   1, 1, 1, 1,   1,   1, 1, 1,   1, 1, 1, 1, 1, 0,   0, 0 
    DB   0, 0, 0, 0,   0, 0, 0, 0,   1,   1, 1, 0,   0, 0, 0, 0, 0, 0,   0, 0 
    DB   0, 0, 0, 0,   0, 0, 0, 0, 255, 255, 0, 0,   0, 0, 0, 0, 0, 0,   0, 0
    DB   0, 0, 0, 0,   0, 0, 0, 0,   0,   0, 0, 0,   0, 0, 0, 0, 0, 0,   0, 0 
Map01_Warps:
    ;  MapPosX, MapPosY, To Map Pos X, To Map Pos Y,  To Map ID,
    ;DB      32,      40,           72,          112, House01_ID,
    ;DB      96,      40,           40,          112, House02_ID,
    ;DB     144,      72,            0,           72,   Map02_ID,
    ;DB     144,      80,            0,           80,   Map02_ID,
    ;DB       0,      72,           80,          112,   Lab01_ID,
    ;DB       0,      80,           80,          112,   Lab01_ID,
    ;DB     255,     255
    ;Warp ID, To Map Pos X, To Map Pos Y, To SCX, To SCY, To Map ID,
    DB 0, 72, 112,  0,  0, House01_ID,
    DB 1, 40, 112,  0,  0, House02_ID,
    DB 2,  0,  72,  0,  0,   Map02_ID,
    DB 3,  0,  80,  0,  0,   Map02_ID,
    DB 4, 72, 112, 48, 64,   Lab01_ID,
    DB 5, 72, 112, 48, 64,   Lab01_ID,
    DB 127

House01_Bank          EQU 3
House01_ID            EQU 1
House01_Tiles:        INCBIN "data/maps/house01.tilemap"
House01_Attributes:   INCBIN "data/maps/house01.attrmap"
House01_BytesLength   EQU 320
House01_TileSetId     EQU 1
House01_Width         EQU 20
House01_Heigth        EQU 16
House01_Colision:
	DB 0, 0, 0, 0, 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	DB 0, 0, 0, 0, 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	DB 1, 0, 0, 0, 0, 0, 0, 0, 1,   1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0
	DB 1, 0, 0, 0, 0, 0, 0, 0, 1,   1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0
	DB 1, 1, 1, 1, 1, 1, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 1, 1, 1, 1, 1, 1, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 1, 1, 1, 1, 1, 1, 1, 0, 0,   0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0
	DB 1, 1, 1, 1, 1, 1, 1, 0, 0,   0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0
	DB 1, 1, 1, 1, 1, 1, 1, 0, 0,   0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0
	DB 1, 1, 1, 1, 1, 1, 1, 0, 0,   0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0
	DB 1, 1, 1, 1, 1, 1, 1, 0, 0,   0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0
	DB 0, 0, 1, 1, 1, 1, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 0, 0, 1, 1, 1, 1, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 0, 0, 1, 1, 1, 1, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 0, 0, 1, 1, 1, 1, 1, 1, 1, 128, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 0, 0, 0, 0, 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
House01_Warps:
    ;  MapPosX, MapPosY, To Map Pos X, To Map Pos Y, To Map ID,
    ;DB      72,     112,           32,           56,  Map01_ID,
    ;DB     255,     255
    ;Warp ID, To Map Pos X, To Map Pos Y, To SCX, To SCY, To Map ID,
    DB 0, 32, 56, 0, 0, Map01_ID,
    DB 127

House02_Bank          EQU 3
House02_ID            EQU 2
House02_Tiles:        INCBIN "data/maps/house02.tilemap"
House02_Attributes:   INCBIN "data/maps/house02.attrmap"
House02_BytesLength   EQU 320
House02_TileSetId     EQU 1
House02_Width         EQU 20
House02_Heigth        EQU 16
House02_Colision:
	DB 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	DB 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	DB 0, 0, 0, 0, 1,   1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0
	DB 0, 0, 0, 0, 1,   1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0
    DB 1, 1, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0
    DB 0, 0, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 0, 0, 1, 1, 1,   1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0
	DB 0, 0, 1, 1, 1,   1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0
    DB 0, 0, 1, 1, 1,   1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0
    DB 0, 0, 1, 1, 1,   1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0
	DB 1, 1, 1, 1, 1,   1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0
	DB 0, 0, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 0, 0, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 0, 0, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 0, 0, 1, 1, 1, 128, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
	DB 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
House02_Warps:
    ;  MapPosX, MapPosY, To Map Pos X, To Map Pos Y, To Map ID,
    ;DB      40,     112,           96,           56,  Map01_ID,
    ;DB     255,     255
    ;Warp ID, To Map Pos X, To Map Pos Y, To SCX, To SCY, To Map ID,
    DB 0, 96, 56, 0, 0, Map01_ID,
    DB 127

Map02_Bank          EQU 3
Map02_ID            EQU 3
Map02_Tiles:        INCBIN "data/maps/map02.tilemap"
Map02_Attributes:   INCBIN "data/maps/map02.attrmap"
Map02_BytesLength   EQU 320
Map02_TileSetId     EQU 2
Map02_Width         EQU 20
Map02_Heigth        EQU 16
Map02_Colision:
    DB   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    DB   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    DB   0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
    DB   0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
    DB   0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
    DB   0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
    DB   0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
    DB   0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
    DB   0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
    DB 128, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
    DB 129, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
    DB   0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
    DB   0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
    DB   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    DB   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    DB   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
Map02_Warps:
    ;  MapPosX, MapPosY, To Map Pos X, To Map Pos Y, To Map ID,
    ;DB       0,      72,          144,           72,  Map01_ID,
    ;DB       0,      80,          144,           80,  Map01_ID,
    ;DB     255,     255
    ;Warp ID, To Map Pos X, To Map Pos Y, To SCX, To SCY, To Map ID,
    DB 0, 144, 72, 0, 0, Map01_ID,
    DB 1, 144, 80, 0, 0, Map01_ID,
    DB 127

Lab01_Bank          EQU 3
Lab01_ID            EQU 4
Lab01_Tiles:        INCBIN "data/maps/lab01.tilemap"
Lab01_Attributes:   INCBIN "data/maps/lab01.attrmap"
Lab01_BytesLength   EQU 768
Lab01_TileSetId     EQU 3
Lab01_Width         EQU 32
Lab01_Heigth        EQU 24
Lab01_Colision: 
    DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    DB 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    DB 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    DB 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    DB 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0,   0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0,
    DB 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0,   0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0,
    DB 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0,   0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0,
    DB 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0,   0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0,
    DB 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0,   0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    DB 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0,   0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    DB 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0,   0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    DB 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0,
    DB 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0,
    DB 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0,
    DB 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0,
    DB 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    DB 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    DB 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    DB 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    DB 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    DB 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 128, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
;Lab01_Colision2:
;    ;   00,  01,  02,  03,  04,  05,  06,  07,  08,  09,  0A,  0B,  0C,  0D,  0E,  0F,  10,  11,  12,  13,  14,  15,  16,  17,  18,  19,  1A,  1B,  1C,  1D,  1E,  1F
;    DB  00,  01,  02,  03,  04,  05,  06,  07,  08,  09,  10,  11,  12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29,  30,  31, ;00
;    DB  32,  33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47,  48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63, ;01
;    DB  64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,  80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  91,  92,  93,  94,  95, ;02
;    DB  96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, ;03
;    DB 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, ;04
;    DB 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, ;05
;    DB 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, ;06
;    DB 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, ;07
;    DB  00,  01,  02,  03,  04,  05,  06,  07,  08,  09,  10,  11,  12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29,  30,  31, ;08
;    DB  32,  33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47,  48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63, ;09
;    DB  64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,  80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  91,  92,  93,  94,  95, ;0A
;    DB  96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, ;0B
;    DB 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, ;0C
;    DB 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, ;0D
;    DB 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, ;0E
;    DB 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, ;0F
;    DB  00,  01,  02,  03,  04,  05,  06,  07,  08,  09,  10,  11,  12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29,  30,  31, ;10
;    DB  32,  33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47,  48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63, ;11
;    DB  64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,  80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  91,  92,  93,  94,  95, ;12
;    DB  96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, ;13
;    DB 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, ;14
;    DB 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, ;15
;    DB 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, ;16
;    DB 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, ;17
Lab01_Warps:
;    DB 128, 184, 0, 72, Map01_ID,
    ;Warp ID, To Map Pos X, To Map Pos Y, To SCX, To SCY, To Map ID,
    DB 0, 0, 72, 0, 0, Map01_ID,
    DB 127

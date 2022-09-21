INCLUDE "hardware.inc"

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
    db Machi_Centro_Bank                   ; 1 byte    -   bank do tilemap
    dw Machi_Centro_Tiles                  ; 2 bytes   -   data do tilemap
    dw Machi_Centro_Attributes             ; 2 bytes   -   atributos do tilemap
    dw Machi_Centro_BytesLength            ; 2 bytes   -   tamanho em bytes do tilemap
    db Machi_Centro_TileSetId              ; 1 byte    -   id do tileset usado pelo tilemap
    dw Machi_Centro_Colision               ; 2 bytes   -   colisao do tilemap
    dw Machi_Centro_Warps                  ; 2 bytes   -   tabela de warps do mapa
    db Machi_Centro_Width                  ; 1 byte    -   largura / X
    db Machi_Centro_Heigth                 ; 1 byte    -   altura  / Y
    dw                              ; 2 bytes   -   zeros   ───── Possível uso futuro
    ; ID 1
    db Machi_Casa_01_Bank                 ; 1 byte    -   bank do tilemap
    dw Machi_Casa_01_Tiles                ; 2 bytes   -   data do tilemap
    dw Machi_Casa_01_Attributes           ; 2 bytes   -   atributos do tilemap
    dw Machi_Casa_01_BytesLength          ; 2 bytes   -   tamanho em bytes do tilemap
    db Machi_Casa_01_TileSetId            ; 1 byte    -   id do tileset usado pelo tilemap
    dw Machi_Casa_01_Colision             ; 2 bytes   -   colisao do tilemap
    dw Machi_Casa_01_Warps                ; 2 bytes   -   tabela de warps do mapa
    db Machi_Casa_01_Width                ; 1 byte    -   largura / X
    db Machi_Casa_01_Heigth               ; 1 byte    -   altura  / Y
    dw                              ; 2 bytes   -   zeros   ───── Possível uso futuro
    ; ID 2
    db Machi_Casa_02_Bank                 ; 1 byte    -   bank do tilemap
    dw Machi_Casa_02_Tiles                
    dw Machi_Casa_02_Attributes           
    dw Machi_Casa_02_BytesLength          
    db Machi_Casa_02_TileSetId            
    dw Machi_Casa_02_Colision             
    dw Machi_Casa_02_Warps                
    db Machi_Casa_02_Width
    db Machi_Casa_02_Heigth
    dw
    ;ID 3
    db Machi_Lago_Bank      
    dw Machi_Lago_Tiles      
    dw Machi_Lago_Attributes 
    dw Machi_Lago_BytesLength
    db Machi_Lago_TileSetId  
    dw Machi_Lago_Colision   
    dw Machi_Lago_Warps      
    db Machi_Lago_Width
    db Machi_Lago_Heigth 
    dw 
    ;ID 4
    db Machi_Lab_01_Bank      
    dw Machi_Lab_01_Tiles      
    dw Machi_Lab_01_Attributes 
    dw Machi_Lab_01_BytesLength
    db Machi_Lab_01_TileSetId  
    dw Machi_Lab_01_Colision   
    dw Machi_Lab_01_Warps      
    db Machi_Lab_01_Width
    db Machi_Lab_01_Heigth 
    dw 

SECTION "Tile Map Data", ROMX, BANK[3]
Machi_Centro_Bank          EQU 3
Machi_Centro_ID            EQU 0
Machi_Centro_Tiles:        INCBIN "data/maps/Machi_Centro.tilemap"
Machi_Centro_Attributes:   INCBIN "data/maps/Machi_Centro.attrmap"
Machi_Centro_BytesLength   EQU 320
Machi_Centro_TileSetId     EQU 1 ;Machi_Exterior_01_ID
Machi_Centro_Width         EQU 20
Machi_Centro_Heigth        EQU 16
Machi_Centro_Colision:     INCBIN "data/maps/Machi_Centro.colmap"
Machi_Centro_Warps:
    ;Warp ID, To Map Pos X, To Map Pos Y, To SCX, To SCY, To Map ID,
    DB 0, 72, 112,  0,  0, Machi_Casa_01_ID,
    DB 1, 40, 112,  0,  0, Machi_Casa_02_ID,
    DB 2,  0,  72,  0,  0, Machi_Lago_ID,
    DB 3,  0,  80,  0,  0, Machi_Lago_ID,
    DB 4, 72, 112, 48, 64, Machi_Lab_01_ID,
    DB 5, 72, 112, 48, 64, Machi_Lab_01_ID,
    DB 127

Machi_Casa_01_Bank          EQU 3
Machi_Casa_01_ID            EQU 1
Machi_Casa_01_Tiles:        INCBIN "data/maps/Machi_Casa_01.tilemap"
Machi_Casa_01_Attributes:   INCBIN "data/maps/Machi_Casa_01.attrmap"
Machi_Casa_01_BytesLength   EQU 320
Machi_Casa_01_TileSetId     EQU 3 ;Machi_Interior_01_ID
Machi_Casa_01_Width         EQU 20
Machi_Casa_01_Heigth        EQU 16
Machi_Casa_01_Colision:     INCBIN "data/maps/Machi_Casa_01.colmap"
Machi_Casa_01_Warps:
    ;Warp ID, To Map Pos X, To Map Pos Y, To SCX, To SCY, To Map ID,
    DB 0, 32, 56, 0, 0, Machi_Centro_ID,
    DB 127

Machi_Casa_02_Bank          EQU 3
Machi_Casa_02_ID            EQU 2
Machi_Casa_02_Tiles:        INCBIN "data/maps/Machi_Casa_02.tilemap"
Machi_Casa_02_Attributes:   INCBIN "data/maps/Machi_Casa_02.attrmap"
Machi_Casa_02_BytesLength   EQU 320
Machi_Casa_02_TileSetId     EQU 3 ;Machi_Interior_01_ID
Machi_Casa_02_Width         EQU 20
Machi_Casa_02_Heigth        EQU 16
Machi_Casa_02_Colision:     INCBIN "data/maps/Machi_Casa_02.colmap"
Machi_Casa_02_Warps:
    ;Warp ID, To Map Pos X, To Map Pos Y, To SCX, To SCY, To Map ID,
    DB 0, 96, 56, 0, 0, Machi_Centro_ID,
    DB 127

Machi_Lago_Bank          EQU 3
Machi_Lago_ID            EQU 3
Machi_Lago_Tiles:        INCBIN "data/maps/Machi_Lago.tilemap"
Machi_Lago_Attributes:   INCBIN "data/maps/Machi_Lago.attrmap"
Machi_Lago_BytesLength   EQU 320
Machi_Lago_TileSetId     EQU 2 ;Machi_Exterior_02_ID
Machi_Lago_Width         EQU 20
Machi_Lago_Heigth        EQU 16
Machi_Lago_Colision:     INCBIN "data/maps/Machi_Lago.colmap"
Machi_Lago_Warps:
    ;Warp ID, To Map Pos X, To Map Pos Y, To SCX, To SCY, To Map ID,
    DB 0, 144, 72, 0, 0, Machi_Centro_ID,
    DB 1, 144, 80, 0, 0, Machi_Centro_ID,
    DB 127

Machi_Lab_01_Bank          EQU 3
Machi_Lab_01_ID            EQU 4
Machi_Lab_01_Tiles:        INCBIN "data/maps/Machi_Lab_01.tilemap"
Machi_Lab_01_Attributes:   INCBIN "data/maps/Machi_Lab_01.attrmap"
Machi_Lab_01_BytesLength   EQU 768
Machi_Lab_01_TileSetId     EQU 4 ;Machi_Interior_02_ID
Machi_Lab_01_Width         EQU 32
Machi_Lab_01_Heigth        EQU 24
Machi_Lab_01_Colision:     INCBIN "data/maps/Machi_Lab_01.colmap"
Machi_Lab_01_Warps:
    ;Warp ID, To Map Pos X, To Map Pos Y, To SCX, To SCY, To Map ID,
    DB 0, 0, 72, 0, 0, Machi_Centro_ID,
    DB 127

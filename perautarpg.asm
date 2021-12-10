INCLUDE "hardware.inc"

; Key status
KEY_START   EQU %10000000           ;   ────┐
KEY_SELECT  EQU %01000000           ;       │
KEY_B       EQU %00100000           ;       │
KEY_A       EQU %00010000           ;       ├── Keypad Related
KEY_DOWN    EQU %00001000           ;       │
KEY_UP      EQU %00000100           ;       │
KEY_LEFT    EQU %00000010           ;       │
KEY_RIGHT   EQU %00000001           ;   ────┘

DEF PlayerSpriteOffsetL EQU 4       ;   Offset em bytes da sprite esquerda do jogador
DEF PlayerSpriteOffsetR EQU 8       ;   Offset em bytes da sprite direita do jogador
DEF CursorSpriteOffset EQU 12       ;   Offset em bytes da sprite direita do jogador

SECTION "Header", ROM0[$100]
	jp Start                        ;   pula/chama a função Start

SECTION "Title", ROM0[$134]
	db "PERALTARPGRGBDS"	        ;   nome do jogo (max 16 char)

SECTION "GB Type", ROM0[$143]
	db CART_COMPATIBLE_DMG_GBC      ;   compatibilidade GB only/GB-GBC/GBC only

SECTION "Cart Type", ROM0[$147]
	db CART_ROM	                    ;   tipo do cartucho

SECTION "ROM Size", ROM0[$148]
	db CART_ROM_32KB                ;   tamanho da ROM do cartucho

SECTION "RAM Size", ROM0[$149]
	db CART_SRAM_NONE               ;   tamanho da RAM do cartucho

SECTION "Main", ROM0[$150]
Start:
	    ; Shut down audio circuitry
	ld a, 0			                    ;   move valor 0 pro acumulador
	ld [rNR52], a	                    ;   move valor do acumulador pro registrador 'mestre' do audio
    call WaitVBlank                     ;   chama a função WaitVBlank
    call DesligarLCD                    ;   chama a função DesligarLCD

    ld a, 144                           ;   ┐ seta a posição Y da window layer
    ld [rWY], a                         ;   ┘
    ld a, 103                           ;   ┐ seta a posição X da window layer
    ld [rWX], a                         ;   ┘

    call init                           ;   chama a função init
    call LigarLCD                       ;   chama a função LigarLCD

GameLoop:
    call JoypadRead                     ;   chama a função JoypadRead
    call CheckKeyRead                   ;   chama a função CheckKeyRead
    call WaitVBlank                     ;   chama a função WaitVBlank
    call ArtificialDelay
    jp GameLoop                             ;   Eternal Loop

init:
	ld a, 80                            ;   move o valor 80 pro acumulador
	ld [PlayerPosY], a                  ;   move o valor do acumulador pro byte apontado pela label
	ld a, 48                            ;   move o valor 48 pro acumulador
	ld [PlayerPosX], a                  ;   move o valor do acumulador pro byte apontado pela label
	ld a, 0                             ;   move o valor 0 pro acumulador
    ld [ActiveTilesetId], a             ;   move o valor do acumulador pro byte apontado pela label
    ld [ActiveMapId], a                 ;   move o valor do acumulador pro byte apontado pela label

    ld a, [ActiveTilesetId]             ;   move o valor apontado pela label pro acumulador
    call GetTileSetFromID               ;   chama a função GetTileSetFromID
    call CopyTiles                      ;   chama a função CopyTiles
    ld a, [ActiveTilesetId]             ;   move o valor apontado pela label pro acumulador
    call GetTileSetPaletteFromID        ;   chama a função GetTileSetPaletteFromID
    call CopyTileSetPaletteData         ;   chama a função CopyTileSetPaletteData

    ld a, [ActiveMapId]                 ;   move o valor apontado pela label pro acumulador
    call GetTileMapDataFromID           ;   chama a função GetTileSetFromID
    call CopyMapData                    ;   chama a função CopyTiles
    call SetCGBVRAMBank1                ;   chama a função SetCGBVRAMBank1
    ld a, [ActiveMapId]                 ;   move o valor apontado pela label pro acumulador
    call GetTileMapAttributeFromID      ;   chama a função GetTileSetFromID
    call CopyMapData                    ;   chama a função CopyTiles
    call SetCGBVRAMBank0                ;   chama a função SetCGBVRAMBank1

    ; Start DEBUG Stuff
    call GetBorderTileData              ;   chama a função GetBorderTileData
    call CopyTiles                      ;   chama a função CopyTiles

    call GetBorderTilePalette           ;   chama a função GetBorderTilePalette
    ld a, %10111000                     ;   move valor pro acumulador
    ld [rBCPS], a                       ;   move valor do acumulador pro registrador de palheta de cores do background (mapa)
    ld de, rBCPD                        ;   move o valor da label pro registrador DE
    call WritePaletteData               ;   chama a função WritePaletteData

    call GetStatusBarData               ;   chama a função GetStatusBarData
    call CopyStatusBarData              ;   chama a função CopyStatusBarData
    call SetCGBVRAMBank1                ;   chama a função SetCGBVRAMBank1
    call GetStatusBarAttributes         ;   chama a função GetStatusBarAttributes
    call CopyStatusBarData              ;   chama a função CopyStatusBarData
    call SetCGBVRAMBank0                ;   chama a função SetCGBVRAMBank0
    ; End DEBUG Stuff

    call GetSpriteTiles                 ;   chama a função GetSpriteTiles
    call CopyTiles                      ;   chama a função CopyTiles

    call GetSpritePalettes              ;   chama a função GetSpritePalettes
    call CopySpritePaletteData          ;   chama a função CopySpritePaletteData

    call GetSpriteOAMData               ;   chama a função GetSpriteOAMData
    ld hl, SpritesDataRAM               ;   move o valor da label pro reg HL
    call CopyTiles                      ;   chama a função CopyTiles

    call CopyDMARoutine                 ;   chama a função CopyDMARoutine

    ld a, HIGH(SpritesDataRAM)          ;   move o byte 'alto' da label pro acumulador
    call DMARoutine                     ;   chama a função DMARoutine

    call UpdatePlayerSpritePosition     ;   chama a função UpdatePlayerSpritePosition

    ld a, 222
    ld[Health], a
    ld[Mana], a
    ld[Experience], a
    ld[Attack], a
    ld[Defense], a
    ld[Speed], a

	ret                                 ;   retorna pra função anterior

;   Funções
;   Função para esperar o 'V-Blank' do LCD
WaitVBlank:
	ld a, [rLY]			                ;   move valor do registrador de posição vertical do lcd pro acumulador
	cp 144				                ;   compara valor do acumulador com o valor 144 (inicio do V-Blank)
	jp c, WaitVBlank	                ;   pula de volta pro inicio do loop se a flag carry (c) estiver setada (1)
	ret                                 ;   retorna pra função anterior

;   Função pra copiar os tiles das sprites e tilesets
CopyTiles:
	ld a, [de]			                ;   copia tile/dado do tileset/sprite pro acumulador
	ld [hl+], a			                ;   copia o tile/dado do acumulador pra VRAM e incrementa o ponteiro da VRAM
	inc de				                ;   incrementa o ponteiro do tileset/sprite
	dec bc				                ;   decrementa a quantidade de bytes a copiar
	ld a, b				                ;   ┐ copia a quantidade de bytes restantes pro acumulador
	or a, c				                ;   ┘
	jp nz, CopyTiles	                ;   pula de volta pro começo da função caso a flag Z (zero) nao estiver setado
	ret					                ;   retorna para a função anterior

;   Função para copiar os dados de palheta de cor dos tiles para a VRAM
CopyTileSetPaletteData:
    ld a, %10000000                     ;   We use auto-increment for simplicity
    ld [rBCPS], a 		                ;   Move valor do acumulador pro registrador de 'especificação de palheta de cor (tilemap)'
    ld de, rBCPD                        ;   move o valor da label pro registrador DE
    call WritePaletteData               ;   chama a função WritePaletteData
    ret					                ;   retorna para a função anterior

;   Função para copiar os dados de palheta de cor das sprites para a VRAM
CopySpritePaletteData:
    ld a, %10000000                     ;   We use auto-increment for simplicity
    ld [rOCPS], a 		                ;   Move valor do acumulador pro registrador de 'especificação de palheta de cor (sprites)'
    ld de, rOCPD                        ;   move o valor da label pro registrador DE
    call WritePaletteData               ;   chama a função WritePaletteData
    ret					                ;   retorna para a função anterior

;   Função para copiar os dados de palheta de cores
WritePaletteData:
    ld a, [hl] 			                ;   move byte apontado pelo registrador HL pro acumulador
    ld [de], a 		                    ;   GBC_BG_PALETTE // move valor do acumulador pro registrador de palheta de cor (I/O)
    inc hl				                ;   incrementa valor do registrador HL em 1
    dec b				                ;   decrementa valor do registrador DE em 1
    ld a, b				                ;   move valor do registrador B pro acumulador
    cp 0 				                ;   Is B equal to zero?
	jp nz, WritePaletteData	            ;   pula de volta pro começo da função caso a flag Z (zero) nao estiver setado
	ret					                ;   retorna para a função anterior

;   Troca o banco da VRAM (Somente CGB)
SetCGBVRAMBank0:
    ld a, 0			                    ;   move valor 0 pro acumulador
	ld [rVBK], a	                    ;   move o valor do acumulador pro seletor de BANK da VRAM
	ret				                    ;   retorna para a função anterior
SetCGBVRAMBank1:
    ld a, 1			                    ;   move valor 1 pro acumulador
	ld [rVBK], a	                    ;   move o valor do acumulador pro seletor de BANK da VRAM
	ret				                    ;   retorna para a função anterior

;   Função para atualizar a posição da sprite do jogador
UpdatePlayerSpritePosition:
    ld hl, SpritesDataRAM               ;   move o valor da label pro registrador HL
    ld de, PlayerSpriteOffsetL          ;   move o valor da label pro registrador DE
    add hl, de                          ;   adiciona o valor do reg DE no reg HL
    ld a, [PlayerPosY]                  ;   move o byte apontado pela label no acumulador
    ld [hl+], a                         ;   move o valor do acumulador pro byte apontado pelo reg HL e incrementa HL
    ld a, [PlayerPosX]                  ;   move o byte apontado pela label no acumulador
    ld [hl], a                          ;   move o valor do acumulador pro byte apontado pelo reg HL

    ld hl, SpritesDataRAM               ;   move o valor da label pro registrador HL
    ld de, PlayerSpriteOffsetR          ;   move o valor da label pro registrador DE
    add hl, de                          ;   adiciona o valor do reg DE no reg HL
    ld a, [PlayerPosY]                  ;   move o byte apontado pela label no acumulador
    ld [hl+], a                         ;   move o valor do acumulador pro byte apontado pelo reg HL e incrementa HL
    ld a, [PlayerPosX]                  ;   move o byte apontado pela label no acumulador
    add a, 8                            ;   adiciona 8 no acumulador
    ld [hl], a                          ;   move o valor do acumulador pro byte apontado pelo reg HL

    ld a, HIGH(SpritesDataRAM)          ;   move o byte 'alto' da label pro acumulador
    call DMARoutine                     ;   chama a função DMARoutine

    call MostrarPosicaoNoMapa           ;   chama a função MostrarPosicaoNoMapa

    ret				                    ;   retorna para a função anterior

;   Função para a Leitura do Joypad
JoypadRead:
	ld a, P1F_5                         ;   move o valor da label pro acumulador
	ld [rP1], a                         ;   move o valor do acumulador no registrador de leitura do joypad
	ld a, [rP1]                         ;   move o byte apontado pela label no acumulador
	ld a, [rP1]                         ;   move o byte apontado pela label no acumulador
	ld a, [rP1]                         ;   move o byte apontado pela label no acumulador
	ld a, [rP1]                         ;   move o byte apontado pela label no acumulador
	ld a, [rP1]                         ;   move o byte apontado pela label no acumulador
	cpl                                 ;   ComPLementa acumulador (A = ~A)
	and %00001111                       ;   operação lógica AND no acumulador com o valor
	ld b, a                             ;   move o valor do acumulador pro reg B

	ld a, P1F_4                         ;   move o valor da label pro acumulador
	ld [rP1], a                         ;   move o valor do acumulador no registrador de leitura do joypad
	ld a, [rP1]                         ;   move o byte apontado pela label no acumulador
	ld a, [rP1]                         ;   move o byte apontado pela label no acumulador
	ld a, [rP1]                         ;   move o byte apontado pela label no acumulador
	ld a, [rP1]                         ;   move o byte apontado pela label no acumulador
	ld a, [rP1]                         ;   move o byte apontado pela label no acumulador
	cpl                                 ;   ComPLementa acumulador (A = ~A)
	and %00001111                       ;   operação lógica AND no acumulador com o valor

	swap a                              ;   troca os 4 bits 'alto' com os 4 bits 'baixo'
	or b                                ;   operação lógica OR no acumulador com o reg B
	ld b, a                             ;   move o valor do acumulador pro reg B
	ld a, P1F_GET_NONE                  ;   move o valor da label pro acumulador
	ld [rP1], a                         ;   move o valor do acumulador no registrador de leitura do joypad
	ld a, b                             ;   move o valor do reg B pro acumulador
    ld [KeyRead], a                     ;   move o valor do acumulador pro byte apontado pela label
	ret                                 ;   retorna para a função anterior

;   Função para mover a sprite do jogador para a direita
MoverSpriteDireita:
    ld a, [PlayerPosX]                  ;   move o valor da label pro acumulador 
    add a, 8                            ;   adiciona 8 no acumulador
    cp 160                              ;   verifica se a sprite ja esta na borda direita do mapa
    jp z, .end                          ;   pula pra função caso a flag Z (zero) estiver setado
    ld a, [PlayerPosY]                  ;   move o valor da label pro acumulador 
    ld b, a                             ;   move o valor do acumulador pro reg B
    ld a, [PlayerPosX]                  ;   move o valor da label pro acumulador 
	add a, 8                            ;   adiciona 8 no acumulador
    ld c, a                             ;   move o valor do acumulador pro reg C
    call GetColisionFromPlayerPos       ;   chama a função GetColisionFromPlayerPos
    cp 0                                ;   compara acumulador com o valor
    jp z, .end                          ;   pula pra função caso a flag Z (zero) estiver setado
    cp 2
    jp nz, .setNewPos
    ld a, KEY_RIGHT
    jp z, ChangeMapFromColision
.end:
    ret                                 ;   retorna para a função anterior
.setNewPos:
    ld a, [PlayerPosX]                  ;   move o valor do acumulador no byte apontado pela label
    add a, 8                            ;   subtrai 8 no acumulador
    ld [PlayerPosX], a                  ;   move o valor do acumulador no byte apontado pela label
    call UpdatePlayerSpritePosition     ;   chama a função UpdatePlayerSpritePosition
    jp .end

;   Função para mover a sprite do jogador para a esquerda
MoverSpriteEsquerda:
    ld a, [PlayerPosX]                  ;   move o valor da label pro acumulador 
    sub a, 8                            ;   subtrai 8 no acumulador
    cp 0                                ;   verifica se a sprite ja esta na borda esquerda do mapa
    jp z, .end                          ;   pula pra função caso a flag Z (zero) estiver setado
    ld a, [PlayerPosY]                  ;   move o valor da label pro acumulador 
    ld b, a                             ;   move o valor do acumulador pro reg B
    ld a, [PlayerPosX]                  ;   move o valor da label pro acumulador 
    sub a, 8                            ;   subtrai 8 no acumulador
    ld c, a                             ;   move o valor do acumulador pro reg C
    call GetColisionFromPlayerPos       ;   chama a função GetColisionFromPlayerPos
    cp 0                                ;   compara acumulador com o valor
    jp z, .end                          ;   pula pra função caso a flag Z (zero) estiver setado
    cp 2
    jp nz, .setNewPos
    ld a, KEY_LEFT
    jp z, ChangeMapFromColision
.end:
    ret                                 ;   retorna para a função anterior
.setNewPos:
    ld a, [PlayerPosX]                  ;   move o valor do acumulador no byte apontado pela label
    sub a, 8                            ;   subtrai 8 no acumulador
    ld [PlayerPosX], a                  ;   move o valor do acumulador no byte apontado pela label
    call UpdatePlayerSpritePosition     ;   chama a função UpdatePlayerSpritePosition
    jp .end

;   Função para mover a sprite do jogador para baixo
MoverSpriteBaixo:
    ld a, [PlayerPosY]                  ;   move o valor da label pro acumulador 
    add a, 8                            ;   adiciona 8 no acumulador
    cp 136                              ;   verifica se a sprite ja esta na borda de baixo do mapa
    jp z, .end                          ;   pula pra função caso a flag Z (zero) estiver setado
    ld a, [PlayerPosY]                  ;   move o valor da label pro acumulador 
	add a, 8                            ;   adiciona 8 no acumulador
    ld b, a                             ;   move o valor do acumulador pro reg B
    ld a, [PlayerPosX]                  ;   move o valor da label pro acumulador 
    ld c, a                             ;   move o valor do acumulador pro reg C
    call GetColisionFromPlayerPos       ;   chama a função GetColisionFromPlayerPos
    cp 0                                ;   compara acumulador com o valor
    jp z, .end                          ;   pula pra função caso a flag Z (zero) estiver setado
    cp 2
    jp nz, .setNewPos
    ld a, KEY_DOWN
    jp z, ChangeMapFromColision
.end:
    ret                                 ;   retorna para a função anterior
.setNewPos:
    ld a, [PlayerPosY]                  ;   move o valor do acumulador no byte apontado pela label
    add a, 8                            ;   subtrai 8 no acumulador
    ld [PlayerPosY], a                  ;   move o valor do acumulador no byte apontado pela label
    call UpdatePlayerSpritePosition     ;   chama a função UpdatePlayerSpritePosition
    jp .end

;   Função para mover a sprite do jogador para cima
MoverSpriteCima:    
    ld a, [PlayerPosY]                  ;   move o valor da label pro acumulador 
    sub a, 8                            ;   subtrai 8 no acumulador
    cp 8                                ;   verifica se a sprite ja esta na borda de baixo do mapa
    jp z, .end                          ;   pula pra função caso a flag Z (zero) estiver setado
    ld a, [PlayerPosY]                  ;   move o valor da label pro acumulador 
	sub a, 8                            ;   subtrai 8 no acumulador
    ld b, a                             ;   move o valor do acumulador pro reg B
    ld a, [PlayerPosX]                  ;   move o valor da label pro acumulador 
    ld c, a                             ;   move o valor do acumulador pro reg C
    call GetColisionFromPlayerPos       ;   chama a função GetColisionFromPlayerPos
    cp 0                                ;   compara acumulador com o valor
    jp z, .end                          ;   pula pra função caso a flag Z (zero) estiver setado
    cp 2
    jp nz, .setNewPos
    ld a, KEY_UP
    jp z, ChangeMapFromColision
.end:
    ret                                 ;   retorna para a função anterior
.setNewPos:
    ld a, [PlayerPosY]                  ;   move o valor do acumulador no byte apontado pela label
    sub a, 8                            ;   subtrai 8 no acumulador
    ld [PlayerPosY], a                  ;   move o valor do acumulador no byte apontado pela label
    call UpdatePlayerSpritePosition     ;   chama a função UpdatePlayerSpritePosition
    jp .end

;   Função para mudar o mapa atual
MudarMapa:
    ld a, [ActiveMapId]                 ;   move o valor apontado pela label pro acumulador

    call GetTileSetIDFromTileMapID      ;   chama a função GetTileSetIDFromTileMapID   
    ld [ActiveTilesetId], a             ;   move o valor do acumulador pro byte apontado pela label

    call WaitVBlank                     ;   chama a função WaitVBlank   
    call DesligarLCD                    ;   chama a função DesligarLCD   

    ld a, [ActiveTilesetId]             ;   move o valor apontado pela label pro acumulador
    call GetTileSetFromID               ;   chama a função GetTileSetFromID
    call CopyTiles                      ;   chama a função CopyTiles
    ld a, [ActiveTilesetId]             ;   move o valor apontado pela label pro acumulador
    call GetTileSetPaletteFromID        ;   chama a função GetTileSetPaletteFromID
    call CopyTileSetPaletteData         ;   chama a função CopyTileSetPaletteData

    ld a, [ActiveMapId]                 ;   move o valor apontado pela label pro acumulador
    call GetTileMapDataFromID           ;   chama a função GetTileSetFromID
    call CopyMapData                    ;   chama a função CopyTiles
    call SetCGBVRAMBank1                ;   chama a função SetCGBVRAMBank1
    ld a, [ActiveMapId]                 ;   move o valor apontado pela label pro acumulador
    call GetTileMapAttributeFromID      ;   chama a função GetTileSetFromID
    call CopyMapData                    ;   chama a função CopyTiles
    call SetCGBVRAMBank0                ;   chama a função SetCGBVRAMBank0

    call LigarLCD                       ;   chama a função LigarLCD
    ret                                 ;   retorna para a função anterior

;   Função para verificar se teve alguma tecla pressionada
CheckKeyRead:
    ld a, [KeyRead]                     ;   move o byte apontado pela label pro acumulador
	and KEY_RIGHT                       ;   operação lógica AND no acumulador com o valor da label
	cp 0                                ;   compara o acumulador com o valor
	call nz, MoverSpriteDireita         ;   chama a função MoverSpriteDireita caso a flag Z (zero) nao estiver setado

    ld a, [KeyRead]                     ;   move o byte apontado pela label pro acumulador
    and KEY_LEFT                        ;   operação lógica AND no acumulador com o valor da label
    cp 0                                ;   compara o acumulador com o valor
    call nz, MoverSpriteEsquerda        ;   chama a função MoverSpriteEsquerda caso a flag Z (zero) nao estiver setado

    ld a, [KeyRead]                     ;   move o byte apontado pela label pro acumulador
    and KEY_UP                          ;   operação lógica AND no acumulador com o valor da label
    cp 0                                ;   compara o acumulador com o valor
    call nz, MoverSpriteCima            ;   chama a função MoverSpriteCima caso a flag Z (zero) nao estiver setado

    ld a, [KeyRead]                     ;   move o byte apontado pela label pro acumulador
    and KEY_DOWN                        ;   operação lógica AND no acumulador com o valor da label
    cp 0                                ;   compara o acumulador com o valor
    call nz, MoverSpriteBaixo           ;   chama a função MoverSpriteBaixo caso a flag Z (zero) nao estiver setado

    ld a, [KeyRead]                     ;   move o byte apontado pela label pro acumulador
    and KEY_START                       ;   operação lógica AND no acumulador com o valor da label
    cp 0                                ;   compara o acumulador com o valor
    call nz, ToggleStartMenu                 ;   chama a função ToggleStartMenu caso a flag Z (zero) nao estiver setado

    ret                                 ;   retorna para a função anterior

;   Função para copiar a Função de cópia por DMA para a HRAM
CopyDMARoutine:
    ld  hl, DMARoutine                  ;   Localização da Função a ser copiada
    ld  b, 8                            ;   Tamanho em bytes da função a ser copiada
    ld  c, LOW(hOAMDMA)                 ;   Byte 'baixo' do endereço de memoria da HRAM
.copy
    ld  a, [hli]                        ;   Move o byte apontado pelo reg HL pro acumulador e incrementa o reg HL
    ldh [c], a                          ;   Move o valor do acumulador no byte apontado pelo reg C ($FF00 + C)
    inc c                               ;   Incrementa reg C
    dec b                               ;   Decrementa reg B
    jr  nz, .copy                       ;   Pula de volta pro começo da função caso a flag Z (zero) nao estiver setado
    ret                                 ;   Retorna a função anterior

;   Função para copiar bytes para a OAM (Object Atribute Memory) por DMA (Direct Memory Access)
DMARoutine:
    ldh [rDMA], a                       ;   Move o valor do acumulador no registrador de DMA
    ld  a, 40                           ;   Move o valor pro acumulador
.wait
    dec a                               ;   Decremtenta acumulador
    jr  nz, .wait                       ;   Pula de volta pro começo da função caso a flag Z (zero) nao estiver setado
    ret                                 ;   Retorna a função anterior

;   Função para ligar/desligar o LCD
DesligarLCD:
    ld a, 0			                    ;   Move valor 0 pro acumulador 
    ld [rLCDC], a	                    ;   Move valor do acumulador pro registrador de controle do LCD
    ret                                 ;   Retorna a função anterior
LigarLCD:
    ld a, LCDCF_ON | LCDCF_WINON | LCDCF_WIN9C00 | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_BGON ;   Move valor resultado do OR das labels pro acumulador 
    ld [rLCDC], a	                    ;   move valor do acumulador pro registrador de controle do LCD
    ret                                 ;   Retorna a função anterior

;   Função para saber a colisao do tile
;   in:
;       B = PosY
;       C = PosX
;   out:
;       A = Byte/Data de colisão
GetColisionFromPlayerPos:
    ld a, b                             ;   move a posição Y (reg B) do jogador no acumulador
    sub 16                              ;   subtrai 16 do acumulador
    sra a                               ;   ────┐
    sra a                               ;       ├── 3 Bit Shift Right Aritmetic, equivalente a dividir o acumulador por 8
    sra a                               ;   ────┘
    ld e, a                             ;   move valor do acumulador pro reg E
    ld d, 0                             ;   move valor pro reg D
    ld hl, 0                            ;   move valor pro reg HL
    ld a, 20                            ;   move valor pro acumulador
    ;   DE = posição Y base
.loopMul:
    add hl, de                          ;   adiciona o valor do reg DE pro reg HL
    dec a                               ;   decrementa o acumulador
    cp 0                                ;   compara acumulador com o valor
    jp nz, .loopMul                     ;   pula de volta pro começo da função caso a flag Z (zero) nao estiver setado
    ;   DE = posição Y base
    ;   HL = posição Y processado
    ld a, c                             ;   move posição X (reg C) do jogador no acumulador
    sub 8                               ;   subtrai 8 do acumulador
    srl a                               ;   ────┐
    srl a                               ;       ├── 3 Bit Shift Right Aritmetic, equivalente a dividir o acumulador por 8
    srl a                               ;   ────┘
    ld d, 0                             ;   move valor pro reg D
    ld e, a                             ;   move valor do acumulador pro reg E
    add hl, de                          ;   adiciona o valor do reg DE pro reg HL
    ld e, l                             ;   move valor do reg L pro reg E
    ld d, h                             ;   move valor do reg H pro reg D
    ;   DE = posição do jogador processado (((Y-16)/8)*20)+((X-8)/8)
    ld a, [ActiveMapId]                 ;   move o byte apontado pela label pro acumulador
    call GetColisionData                ;   chama a função GetColisionData
    ret

;   Função para mostar a posição do jogador no mapa
MostrarPosicaoNoMapa:
.posicaoX:                      ;   Preparando para calcular a 'centena' da posição X (X >= 100)
    ld a, [PlayerPosX]                  ;   copia a Posição X da sprite pro acumulador
    sub 8                               ;   subtrai 8 da posição (sprites tem offset 8x16 por padrao)
    cp 100                              ;   compara o valor da posição no acumulador com o valor fixo 100
    ld hl, 0                            ;   prepara o contador de 'centena'
    jp c, .continuarPosX1               ;   se a posição for menor que 100, pula pra função .continuarPosX1
.loopCentenaPosX:               ;   Loop para calcular a 'centena' da posição X
    sub 100                             ;   subtrai 100 da posição
    inc hl                              ;   incrementa contador de 'centena'
    cp 100                              ;   compara o valor da posição no acumulador com o valor fixo 100
    jp nc, .loopCentenaPosX             ;   se o valor for maior que o fixo, continua no loop: .loopCentenaPosX
.continuarPosX1:                ;   Preparando para calcular a 'dezena' da posição X (X >= 10, X < 100)
    ld b, l                             ;   armazena a 'centena' no reg B (0 -> 9)
    ld hl, 0                            ;   prepara o contador de 'dezena'
    cp 10                               ;   compara o valor da posição no acumulador com o valor fixo 10
    jp c, .continuarPosX2               ;   se a posição for menor que 10, pula pra função .continuarPosX2
.loopDezenaPosX:                ;   Loop para calcular a 'dezena' da posição X
    sub 10                              ;   subtrai 10 da posição
    inc hl                              ;   incrementa contador de 'dezena'
    cp 10                               ;   compara o valor da posição no acumulador com o valor fixo 10
    jp nc, .loopDezenaPosX              ;   se o valor for maior que o fixo, continua no loop: .loopDezenaPosX
.continuarPosX2:
    ld c, l                             ;   armazena a 'dezena' no reg C (0 -> 9)
    ld d, a                             ;   armazena a 'unidade' no reg D (0 -> 9)
.endPosX:
    ld hl, TilesPosX                    ;   copia ponteiro pra armazenar os tiles da posição X
    ld a, 144                           ;   adiciona o offset dos tiles no acumulador
    add b                               ;   adiciona o valor da 'centena' (ex: 144 + 1 = tile id 117 / '1')
    ld [hl+], a                         ;   armazena o tileid na WRAM e incrementa o ponteiro da WRAM
    ld a, 144                           ;   adiciona o offset dos tiles no acumulador
    add c                               ;   adiciona o valor da 'dezena' (ex: 144 + 3 = tile id 119 / '3')
    ld [hl+], a                         ;   armazena o tileid na WRAM e incrementa o ponteiro da WRAM
    ld a, 144                           ;   adiciona o offset dos tiles no acumulador
    add d                               ;   adiciona o valor da 'unidade' (ex: 144 + 6 = tile id 122 / '6')
    ld [hl], a                          ;   armazena o tileid na WRAM

.posicaoY:                      ;   Preparando para calcular a 'centena' da posição Y (Y >= 100)
    ld a, [PlayerPosY]                  ;   copia a Posição Y da sprite pro acumulador
    sub 16                              ;   subtrai 8 da posição (sprites tem offset 8x16 por padrao)
    cp 100                              ;   compara o valor da posição no acumulador com o valor fixo 100
    ld hl, 0                            ;   prepara o contador de 'centena'
    jp c, .continuarPosY1               ;   se a posição for menor que 100, pula pra função .continuarPosY1
.loopCentenaPosY1:              ;   Loop para calcular a 'centena' da posição Y
    sub 100                             ;   subtrai 100 da posição
    inc hl                              ;   incrementa contador de 'centena'
    cp 100                              ;   compara o valor da posição no acumulador com o valor fixo 100
    jp nc, .loopCentenaPosY1            ;   se o valor for maior que o fixo, continua no loop: .loopCentenaPosY
.continuarPosY1:                ;   Preparando para calcular a 'dezena' da posição Y (Y >= 10, Y < 100)
    ld b, l                             ;   armazena a 'centena' no reg B (0 -> 9)
    ld hl, 0                            ;   prepara o contador de 'dezena'
    cp 10                               ;   compara o valor da posição no acumulador com o valor fixo 10
    jp c, .continuarPosY2               ;   se a posição for menor que 10, pula pra função .continuarPosY2
.loopDezenaPosY:                ;   Loop para calcular a 'dezena' da posição Y
    sub 10                              ;   subtrai 10 da posição
    inc hl                              ;   incrementa contador de 'dezena'
    cp 10                               ;   compara o valor da posição no acumulador com o valor fixo 10
    jp nc, .loopDezenaPosY              ;   se o valor for maior que o fixo, continua no loop: .loopDezenaPosY
.continuarPosY2:
    ld c, l                             ;   armazena a 'dezena' no reg C (0 -> 9)
    ld d, a                             ;   armazena a 'unidade' no reg D (0 -> 9)
.endPosY:
    ld hl, TilesPosY                    ;   copia ponteiro pra armazenar os tiles da posição Y
    ld a, 144                           ;   adiciona o offset dos tiles no acumulador
    add b                               ;   adiciona o valor da 'centena' (ex: 144 + 1 = tile id 117 / '1')
    ld [hl+], a                         ;   armazena o tileid na WRAM e incrementa o ponteiro da WRAM
    ld a, 144                           ;   adiciona o offset dos tiles no acumulador
    add c                               ;   adiciona o valor da 'dezena' (ex: 144 + 3 = tile id 119 / '3')
    ld [hl+], a                         ;   armazena o tileid na WRAM e incrementa o ponteiro da WRAM
    ld a, 144                           ;   adiciona o offset dos tiles no acumulador
    add d                               ;   adiciona o valor da 'unidade' (ex: 144 + 6 = tile id 122 / '6')
    ld [hl], a                          ;   armazena o tileid na WRAM
.endF
    ld a, [PlayerPosY]                  ;   ┐ copia a posição Y no reg B
    ld b, a                             ;   ┘
    ld a, [PlayerPosX]                  ;   ┐ copia a posição X no reg C
    ld c, a                             ;   ┘
    call GetColisionFromPlayerPos       ;   chama a função GetColisionFromPlayerPos
    ld d, a                             ;   move o dado da colisão no reg D
.endCol:
    ld hl, TilesCol                     ;   copia ponteiro pra armazenar o tile da colisão
    ld a, 144                           ;   adiciona o offset dos tiles no acumulador
    add d                               ;   adiciona o dado da colisão (ex: 144 + 1 = tile id 117 / '1')
    ld [hl], a                          ;   armazena o tileid na WRAM

    call DesligarLCD                    ;   chama a função DesligarLCD

    ld de, TilesPosX                    ;   copia o ponteiro dos tiles pro reg DE
    ld bc, 3                            ;   copia a quantidade em bytes de tiles pra copiar no reg BC
    ld hl, $9A21                        ;   copia o endereço da VRAM para copiar os tiles no reg HL
    call CopyTiles                      ;   chama a função CopyTiles

    ld de, TilesPosY                    ;   copia o ponteiro dos tiles pro reg DE
    ld bc, 3                            ;   copia a quantidade em bytes de tiles pra copiar no reg BC
    ld hl, $9A25                        ;   copia o endereço da VRAM para copiar os tiles no reg HL
    call CopyTiles                      ;   chama a função CopyTiles

    ld de, TilesCol                     ;   copia o ponteiro do tile pro reg DE
    ld bc, 1                            ;   copia a quantidade em bytes de tiles pra copiar no reg BC
    ld hl, $9A2F                        ;   copia o endereço da VRAM para copiar o tile no reg HL
    call CopyTiles                      ;   chama a função CopyTiles

    ld a, [ActiveMapId]                 ;   ┐ copia a o id do mapa no reg D
    ld d, a                             ;   ┘
    ld hl, TilesCol                     ;   copia ponteiro pra armazenar o tile da id do mapa
    ld a, 144                           ;   adiciona o offset dos tiles no acumulador
    add d                               ;   adiciona o id do mapa (ex: 144 + 1 = tile id 117 / '1')
    ld [hl], a                          ;   copia o tile na WRAM
    ld de, TilesCol                     ;   copia ponteiro pra armazenar o tile da id do mapa
    ld bc, 1                            ;   copia a quantidade em bytes de tiles pra copiar no reg BC
    ld hl, $9A31                        ;   copia o endereço da VRAM para copiar o tile no reg HL
    call CopyTiles                      ;   chama a função CopyTiles

    ld a, [ActiveTilesetId]             ;   ┐ copia a o id do tileset no reg D
    ld d, a                             ;   ┘
    ld hl, TilesCol                     ;   copia ponteiro pra armazenar o tile da id do tileset
    ld a, 144                           ;   adiciona o offset dos tiles no acumulador
    add d                               ;   adiciona o id do tileset (ex: 144 + 1 = tile id 117 / '1')
    ld [hl], a                          ;   copia o tile na WRAM
    ld de, TilesCol                     ;   copia ponteiro pra armazenar o tile da id do tileset
    ld bc, 1                            ;   copia a quantidade em bytes de tiles pra copiar no reg BC
    ld hl, $9A33                        ;   copia o endereço da VRAM para copiar o tile no reg HL
    call CopyTiles                      ;   chama a função CopyTiles

    call LigarLCD                       ;   chama a função LigarLCD
    ret                                 ;   retorna para a função anterior 

ChangeMapFromColision:
.compararKeyDown
    cp a, KEY_DOWN
    jp nz, .compararKeyUp
    ld a, [PlayerPosY]                  ;   move o valor da label pro acumulador 
    sub a, 16
    add a, 8                            ;   subtrai 8 no acumulador
    ld e, a                             ;   move o valor do acumulador pro reg E
    ld a, [PlayerPosX]                  ;   move o valor da label pro acumulador
    sub a, 8 
    ld d, a                             ;   move o valor do acumulador pro reg D
    ld a, [ActiveMapId]
    call GetMapWarpData
    jp .changeSpritePosAndMap
.compararKeyUp
    cp a, KEY_UP
    jp nz, .compararKeyLeft
    ld a, [PlayerPosY]                  ;   move o valor da label pro acumulador 
    sub a, 16
    sub a, 8                            ;   subtrai 8 no acumulador
    ld e, a                             ;   move o valor do acumulador pro reg E
    ld a, [PlayerPosX]                  ;   move o valor da label pro acumulador
    sub a, 8 
    ld d, a                             ;   move o valor do acumulador pro reg D
    ld a, [ActiveMapId]
    call GetMapWarpData
    jp .changeSpritePosAndMap
.compararKeyLeft
    cp a, KEY_LEFT
    jp nz, .compararKeyRight
    ld a, [PlayerPosY]                  ;   move o valor da label pro acumulador 
    sub a, 16
    ld e, a                             ;   move o valor do acumulador pro reg E
    ld a, [PlayerPosX]                  ;   move o valor do acumulador no byte apontado pela label
    sub a, 8                            ;   subtrai 8 no acumulador
    sub a, 8                            ;   subtrai 8 no acumulador
    ld d, a                             ;   move o valor do acumulador pro reg D
    ld a, [ActiveMapId]
    call GetMapWarpData
    jp .changeSpritePosAndMap
.compararKeyRight
    cp a, KEY_RIGHT
    jp nz, .end
    ld a, [PlayerPosY]                  ;   move o valor da label pro acumulador 
    sub a, 16
    ld e, a                             ;   move o valor do acumulador pro reg E
    ld a, [PlayerPosX]                  ;   move o valor do acumulador no byte apontado pela label
    sub a, 8                            ;   subtrai 8 no acumulador
    add a, 8                            ;   subtrai 8 no acumulador
    ld d, a                             ;   move o valor do acumulador pro reg D
    ld a, [ActiveMapId]
    call GetMapWarpData
    jp .changeSpritePosAndMap
;       A = ID do Tile Map a ser carregado OU 255 em caso de warp nao encontrado
;       D = Posição X no Mapa a ser carregado
;       E = Posição Y no Mapa a ser carregado
.changeSpritePosAndMap
    cp 255
    jp z, .end
    ld [ActiveMapId], a
    ld a, e
    add 16
    ld [PlayerPosY], a
    ld a, d
    add 8
    ld [PlayerPosX], a
    call UpdatePlayerSpritePosition
    call MudarMapa
.end:
    ret

    ; Função pra copia o mapa da ROM pra VRAM
CopyMapData:
    ld a, 0                             ;   copia o valor inicial do contador de linha no acumulador
    ld [MapLineCount], a                ;   armazena o contador de linha na WRAM 
.loop:
	ld a, [de]			                ;   copia tile pro acumulador
	ld [hli], a			                ;   copia tile do acumulador pra VRAM apontado pelo registrador HL e incrementa HL
	inc de				                ;   incremtenta o ponteiro com os tiles
	dec bc				                ;   decrementa a quantidade de tiles a ser copiado 
    ld a, d                             ;   ┐
    ld [TempMapD], a                    ;   │ armazena o ponteiro dos tiles na WRAM
    ld a, e                             ;   │
    ld [TempMapE], a                    ;   ┘
    ld a, [MapLineCount]                ;   copia o contador de linha pro acumulador
    add 1                               ;   incrementa o contador
    cp a, 20                            ;   compara o contador
    jp nz, .continue                    ;   pula pra função .continue caso a flag Z (zero) nao estiver setado
    ld a, 0                             ;   copia o valor inicial do contador de linha no acumulador
    ld [MapLineCount], a                ;   copia o valor no acumulador na WRAM
    ld d, 0                             ;   ┐ copia o valor em bytes para incrementar o ponteiro da VRAM no reg DE
    ld e, 12                            ;   ┘
    add hl, de                          ;   incrementa a posição do ponteiro da VRAM em DE bytes
.continue:
    ld [MapLineCount], a                ;   armazena o contador de linha na WRAM 
    ld a, [TempMapD]                    ;   ┐
    ld d, a                             ;   │ recupera o ponteiro dos tiles
    ld a, [TempMapE]                    ;   │
    ld e, a                             ;   ┘
	ld a, b				                ;   ┐ copia a quantidade de tiles restanes no acumulador
	or a, c				                ;   ┘
	jp nz, .loop    	                ;   pula de volta pro começo da função caso a flag Z (zero) nao estiver setado
	ret					                ;   retorna para a função anterior

    ;Barra de status na parte de baixo da tela
CopyStatusBarData:
    ld a, 0                             ;   copia o valor inicial do contador de linha no acumulador
    ld [MapLineCount], a                ;   armazena o contador de linha na WRAM 
.loop:
	ld a, [de]			                ;   copia tile pro acumulador
    add 128
	ld [hli], a			                ;   copia tile do acumulador pra VRAM apontado pelo registrador HL e incrementa HL
	inc de				                ;   incremtenta o ponteiro com os tiles
	dec bc				                ;   decrementa a quantidade de tiles a ser copiado 
    ld a, d                             ;   ┐
    ld [TempMapD], a                    ;   │ armazena o ponteiro dos tiles na WRAM
    ld a, e                             ;   │
    ld [TempMapE], a                    ;   ┘
    ld a, [MapLineCount]                ;   copia o contador de linha pro acumulador
    add 1                               ;   incrementa o contador
    cp a, 20                            ;   compara o contador
    jp nz, .continue                    ;   pula pra função .continue caso a flag Z (zero) nao estiver setado
    ld a, 0                             ;   copia o valor inicial do contador de linha no acumulador
    ld [MapLineCount], a                ;   copia o valor no acumulador na WRAM
    ld d, 0                             ;   ┐ copia o valor em bytes para incrementar o ponteiro da VRAM no reg DE
    ld e, 12                            ;   ┘
    add hl, de                          ;   incrementa a posição do ponteiro da VRAM em DE bytes
.continue:
    ld [MapLineCount], a                ;   armazena o contador de linha na WRAM 
    ld a, [TempMapD]                    ;   ┐
    ld d, a                             ;   │ recupera o ponteiro dos tiles
    ld a, [TempMapE]                    ;   │
    ld e, a                             ;   ┘
	ld a, b				                ;   ┐ copia a quantidade de tiles restanes no acumulador
	or a, c				                ;   ┘
	jp nz, .loop    	                ;   pula de volta pro começo da função caso a flag Z (zero) nao estiver setado
	ret					                ;   retorna para a função anterior

    ;Função pra copiar os menus/windows
CopyMenuData:
    ld a, 0                             ;   copia o valor inicial do contador de linha no acumulador
    ld [MapLineCount], a                ;   armazena o contador de linha na WRAM 
.loop:
    ld a, [rVBK]                        ;   copia o banco da vram atual
    and %00000001                       ;   'filtra' o valor (0 ou 1)
    cp 1                                ;   compara se o valor é igual a 1
    ld a, [de]			                ;   copia o tile pro acumulador
    jp z, .copy                         ;   pula pra função .copy se a flag Z (zero) estiver setada
    add 128                             ;   adiciona 128 no acumulador
.copy:
	ld [hli], a			                ;   copia tile do acumulador pra VRAM apontado pelo registrador HL e incrementa HL
	inc de				                ;   incremtenta o ponteiro com os tiles
	dec bc				                ;   decrementa a quantidade de tiles a ser copiado 
    ld a, d                             ;   ┐
    ld [TempMapD], a                    ;   │ armazena o ponteiro dos tiles na WRAM
    ld a, e                             ;   │
    ld [TempMapE], a                    ;   ┘
    ld a, [MapLineCount]                ;   copia o contador de linha pro acumulador
    add 1                               ;   incrementa o contador
    cp a, 8                             ;   compara o contador
    jp nz, .continue                    ;   pula pra função .continue caso a flag Z (zero) nao estiver setado
    ld a, 0                             ;   copia o valor inicial do contador de linha no acumulador
    ld [MapLineCount], a                ;   copia o valor no acumulador na WRAM
    ld d, 0                             ;   ┐ copia o valor em bytes para incrementar o ponteiro da VRAM no reg DE
    ld e, 24                            ;   ┘
    add hl, de                          ;   incrementa a posição do ponteiro da VRAM em DE bytes
.continue:
    ld [MapLineCount], a                ;   armazena o contador de linha na WRAM 
    ld a, [TempMapD]                    ;   ┐
    ld d, a                             ;   │ recupera o ponteiro dos tiles
    ld a, [TempMapE]                    ;   │
    ld e, a                             ;   ┘
	ld a, b				                ;   ┐ copia a quantidade de tiles restanes no acumulador
	or a, c				                ;   ┘
	jp nz, .loop    	                ;   pula de volta pro começo da função caso a flag Z (zero) nao estiver setado
	ret					                ;   retorna para a função anterior

    ; Delay artificial
ArtificialDelay:
    ld hl, 15000                        ;   move o valor pro reg HL
.loop
    dec hl                              ;   decrementa HL
    ld a, h                             ;   move valor do reg H pro acumulador
    or a, l                             ;   operação lógica OU com acumulador e o reg L
    cp 0                                ;   compara acumulador com o valor
    jp nz, .loop                        ;   pula de volta pro começo da função caso a flag Z (zero) nao estiver setado
    ret					                ;   retorna para a função anterior

    ; Mostra/Esconde o menu e trava o input do keypad
ToggleStartMenu:
    call WindowFunctions.RenderStartMenu    ;   Renderiza o Start Menu
    ld a, 1                                 ;   ┐ Seta o índice do cursor do Start Menu
    ld [MenuEntry], a                       ;   ┘
    ld a, 0                                 ;   ┐ Move o Menu pra tela
    ld [rWY], a                             ;   ┘
    jp .initCursor                          ;   Pula pra função que 'inicia' o cursor

.hideStartMenu:
    ld hl, SpritesDataRAM               ;   ┐ Copia o endereço das sprites da memoria
    ld de, CursorSpriteOffset           ;   │ Copia o offset do cursor
    add hl, de                          ;   ┘ Incrementa o offset no endereço
    ld a, 0                             ;   ┐
    ld [hl+], a                         ;   │ move/esconde a sprite pra fora da tela
    ld [hl+], a                         ;   ┘

    ld a, HIGH(SpritesDataRAM)          ;   ┐ persiste a pos da sprite na vram
    call DMARoutine                     ;   ┘

    ld a, 144                           ;   ┐ Move o Menu pra fora tela
    ld [rWY], a                         ;   ┘
    ret
    
.initCursor:
    ld hl, SpritesDataRAM               ;   ┐ Copia o endereço das sprites da memoria
    ld de, CursorSpriteOffset           ;   │ Copia o offset do cursor
    add hl, de                          ;   ┘ Incrementa o offset no endereço
    ld a, 24                            ;   ┐
    ld [hl+], a                         ;   │ move a sprite pra posição certa do menu
    ld a, 104                           ;   │
    ld [hl], a                          ;   ┘

    ld a, HIGH(SpritesDataRAM)          ;   ┐ persiste a pos da sprite na vram
    call DMARoutine                     ;   ┘

;loop de leitura do keypad no primeiro menu
.menuKeyreadLoop:
    call ArtificialDelay                ;   chama a função de delay
    call JoypadRead                     ;   chama a função de leitura do keypad

    ld a, [KeyRead]                     ;   ┐
    and KEY_START                       ;   │ START fecha o StartMenu
    cp 0                                ;   │
    jp nz, .hideStartMenu               ;   ┘

    ld a, [KeyRead]                     ;   ┐
    and KEY_B                           ;   │ B fecha o StartMenu
    cp 0                                ;   │
    jp nz, .hideStartMenu               ;   ┘

    ld a, [KeyRead]                     ;   ┐
    and KEY_A                           ;   │ A executa uma ação de acordo com a posição do cursor
    cp 0                                ;   │
    call nz, MoverCursor.Acao           ;   ┘
    
    ld a, [KeyRead]                     ;   ┐
    and KEY_DOWN                        ;   │ DOWN move o cursor pra baixo
    cp 0                                ;   │
    call nz, MoverCursor.Baixo          ;   ┘

    ld a, [KeyRead]                     ;   ┐
    and KEY_UP                          ;   │ UP move o cursor pra cima
    cp 0                                ;   │
    call nz, MoverCursor.Cima           ;   ┘

    jp .menuKeyreadLoop                 ;   Pula de volta pro começo do loop

WindowFunctions:
.RenderStartMenu:
    call WaitVBlank                     ;   Loop de espera do VBlank
    call DesligarLCD                    ;   Desliga a tela

    call GetMenuData                    ;   chama a função GetMenuData
    call CopyMenuData                   ;   chama a função CopyMenuData
    call SetCGBVRAMBank1                ;   chama a função SetCGBVRAMBank1
    call GetMenuAttributes              ;   chama a função GetMenuAttributes
    call CopyMenuData                   ;   chama a função CopyMenuData
    call SetCGBVRAMBank0                ;   chama a função SetCGBVRAMBank0

    call LigarLCD                       ;   Liga a tela
    ret

MoverCursor:
.Baixo:
    ld a, [MenuEntry]                   ;   Copia o indice do menu no acumulador
    cp 5                                ;   Compara se o índice é igual a 5 (Z)
    ret z                               ;   Retorna a função anterior se sim (Z)

    add 1                               ;   ┐ incrementa o índice do cursor
    ld [MenuEntry], a                   ;   ┘

    ld hl, SpritesDataRAM               ;   move o valor da label pro registrador HL
    ld de, CursorSpriteOffset           ;   move o valor da label pro registrador DE
    add hl, de                          ;   adiciona o valor do reg DE no reg HL
    ld a, [hl]                          ;   ┐
    add 16                              ;   │ incrementa a posição do cursor
    ld [hl], a                          ;   ┘

    ld a, HIGH(SpritesDataRAM)          ;  ┐ persiste a posição do cursor
    call DMARoutine                     ;  ┘
    ret

.Cima:
    ld a, [MenuEntry]                   ;   Copia o indice do menu no acumulador
    cp 1                                ;   Compara se o índice é igual a 5 (Z)
    ret z                               ;   Retorna a função anterior se sim (Z)

    sub 1                               ;   ┐ decrementa o índice do cursor
    ld [MenuEntry], a                   ;   ┘

    ld hl, SpritesDataRAM               ;   move o valor da label pro registrador HL
    ld de, CursorSpriteOffset           ;   move o valor da label pro registrador DE
    add hl, de                          ;   adiciona o valor do reg DE no reg HL
    ld a, [hl]                          ;   ┐
    sub 16                              ;   │ decrementa a posição do cursor
    ld [hl], a                          ;   ┘

    ld a, HIGH(SpritesDataRAM)          ;   ┐ persiste a posição do cursor
    call DMARoutine                     ;   ┘
    ret

.Acao:
    ld a, [MenuEntry]                   ;   Copia o indice do menu no acumulador
    cp 5                                ;   Compara se o índice é igual a 5 (Z)
    jp z, .hideMenu                     ;   Pula pra função de esconder o menu se sim (Z)
    ret

.hideMenu:
    call ToggleStartMenu.hideStartMenu  ;   chama a função que fecha/esconde o StartMenu
    pop hl                              ;   remove o ponteiro da função ToggleStartMenu.menuKeyreadLoop
                                        ;   da stack, previne que fique em loop como se estivesse no StartMenu
    ret

SECTION "OAM DMA", HRAM
hOAMDMA: ds 8                           ;   Espaço na HRAM para alocar a função de cópia de bytes pra OAM

SECTION "Variaveis", WRAM0
PlayerPosY: ds 1                        ;   Posição Y do jogador
PlayerPosX: ds 1                        ;   Posição X do jogador
ActiveMapId: ds 1                       ;   ID do mapa atual
ActiveTilesetId: ds 1                   ;   ID do tileset atual
KeyRead: ds 1                           ;   Buffer de leitura do keypad
TilesPosX: ds 3                         ;   Tiles para exibir a posição X do player no mapa
TilesPosY: ds 3                         ;   Tiles para exibir a posição Y do player no mapa
TilesCol: ds 1                          ;   Tiles para exibir o tipo de colisão do tile
TempMapD: ds 1                          ;   Armazenamento temporario do reg D
TempMapE: ds 1                          ;   Armazenamento temporario do reg E
MapLineCount: ds 1                      ;   Armazenamento do contador de linha do CopyMapData
MenuEntry: ds 1                         ;   Índice do Menu

SECTION "Player", WRAM0
Health: ds 1                            ;   ┐
Mana: ds 1                              ;   │
Experience: ds 1                        ;   │
Attack: ds 1                            ;   │ Player Status
Defense: ds 1                           ;   │
Speed: ds 1                             ;   │
;Inventory                              ;   ┘

SECTION "Variaveis_OAM", WRAM0[$C100]
SpritesDataRAM: ds 12                   ;   Data das sprites para copiar a OAM

INCLUDE "hardware.inc"

;Definitions
LCD_FLAG EQU LCDCF_ON | LCDCF_WINON | LCDCF_WIN9C00 | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_BGON    ; FLAG para ligar o LCD
;Keypad related
KEY_START           EQU %10000000       ;   ────┐
KEY_SELECT          EQU %01000000       ;       │
KEY_B               EQU %00100000       ;       │
KEY_A               EQU %00010000       ;       ├── Keypad Related
KEY_DOWN            EQU %00001000       ;       │
KEY_UP              EQU %00000100       ;       │
KEY_LEFT            EQU %00000010       ;       │
KEY_RIGHT           EQU %00000001       ;   ────┘
;Sprite stuff
PlayerSpriteOffsetL EQU 4               ;   Offset em bytes da sprite esquerda do jogador
PlayerSpriteOffsetR EQU 8               ;   Offset em bytes da sprite direita do jogador
CursorSpriteOffset  EQU 12              ;   Offset em bytes da sprite direita do jogador
;IDs dos menus
StartMenuID         EQU 0
PlayerInfoMenuID    EQU 1
StatusBarID         EQU 2

SECTION "Some Defs", ROM0
NomeHardCoded: DB "PERALTA[\\]RGBDS"     ; temporario, max 15 caracteres

SECTION "Header", ROM0[$100]
	jp Start                            ;   Pula/chama a função Start

SECTION "Title", ROM0[$134]
	db "PERALTARPGRGBDS"                ;   Nome do jogo (max 16 char)

SECTION "GB Type", ROM0[$143]
	db CART_COMPATIBLE_GBC              ;   Compatibilidade somente com o GBC

SECTION "Cart Type", ROM0[$147]
	db CART_ROM_MBC5                    ;   Tipo do cartucho

SECTION "ROM Size", ROM0[$148]
	db CART_ROM_256KB                   ;   Tamanho da ROM do cartucho

SECTION "RAM Size", ROM0[$149]
	db CART_SRAM_NONE                   ;   Tamanho da RAM do cartucho

SECTION "Main", ROM0[$150]
Start:
    ; Shut down audio circuitry
    ld a, 0			                    ;   ┐ Desliga o audio do gameboy
    ld [rNR52], a	                    ;   ┘ 
    call DesligarLCD                    ;   Chama a função DesligarLCD

    ld a, 128                           ;   ┐ Seta a posição Y da window layer
    ld [rWY], a                         ;   ┘
    ld a, 7                             ;   ┐ Seta a posição X da window layer
    ld [rWX], a                         ;   ┘
    
    call InitGame                       ;   Chama a função InitGame
    call LigarLCD                       ;   Chama a função LigarLCD
    ; Main loop
GameLoop:
    call ReadJoypad                     ;   Chama a função ReadJoypad
    call CheckKeyRead                   ;   Chama a função CheckKeyRead
    ;call RenderDebugData
    call Debug_RenderPlayerPos
    call WaitVBlank                     ;   Chama a função WaitVBlank
    call ArtificialDelay                ;   Chama a função ArtificialDelay
    jp GameLoop                         ;   Eternal Loop

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

;   ╔════════════════════════╗
;   ║   "Função de Inicio"   ║
;   ╚════════════════════════╝

;   Função executada somente no boot do jogo
InitGame:
    ld a, 80                            ;   ┐ Posição Y inicial do jogador
    ld [PlayerPosY], a                  ;   ┘
    ld a, 80                            ;   ┐ Posição X inicial do jogador
    ld [PlayerPosX], a                  ;   ┘
    ld a, 0
    ld [ScreenPosY], a
    ld [ScreenPosX], a
    ld a, 0                             ;   ┐ Seta ID 0 no ActiveMapId
    ld [ActiveMapId], a                 ;   ┘

    call ChangeMap

    call CopyFontTilesData
    call RenderStatusBar

    call CopySpritesToVRAM              ;   Chama a função GetSpriteTiles
    call CopySpriteOAMDataToWRAM
    call CopyDMARoutine                 ;   Chama a função CopyDMARoutine

    ld a, HIGH(SpritesDataRAM)          ;   move o byte 'alto' da label pro acumulador
    call DMARoutine                     ;   Chama a função DMARoutine

    ret

;   ╔══════════════════════╗
;   ║   "Funções do LCD"   ║
;   ╚══════════════════════╝

;   Função para esperar o 'V-Blank' do LCD
WaitVBlank:
	ld a, [rLY]		    ;   Copia o valor do registrador de posição vertical do lcd pro acumulador
	cp 144			    ;   Compara o valor do acumulador com o valor 144 (inicio do V-Blank)
	jp c, WaitVBlank    ;   Pula de volta pro inicio do loop se a flag carry (c) estiver setada (1)
	ret                 ;   Retorna pra função anterior

;   Função para desligar o LCD
DesligarLCD:
    ld a, [rLCDC]       ;   ┐
    and LCDCF_ON        ;   │   Verifica se o LCD está LIGADO
    cp LCDCF_ON         ;   ┘
    ret nz              ;   ─   Retorna se o LCD ja estiver DESLIGADO
    call WaitVBlank     ;   ─   Chama a função WaitVBlank
    ld a, 0			    ;   ┐   Desliga o LCD setando o registrador do LCD em 0
    ld [rLCDC], a	    ;   ┘
    ret                 ;   ─   Retorna a função anterior

;   Função para ligar o LCD
LigarLCD:
    ld a, [rLCDC]       ;   ┐
    and LCDCF_ON        ;   │   Verifica se o LCD está LIGADO
    cp LCDCF_ON         ;   ┘
    ret z               ;   ─   Retorna se o LCD ja estiver LIGADO
    ld a, LCD_FLAG      ;   ┐   Liga o LCD setando a flag LCD_FLAG no registrador do LCD
    ld [rLCDC], a	    ;   ┘
    ret                 ;   ─   Retorna a função anterior

;   Seleciona o Banco 0 da VRAM (Map Data)
SetCGBVRAMBank0:
    ld a, 0             ;   ┐   Seta a VRAM pro bank 0
	ld [rVBK], a        ;   ┘
	ret                 ;   ─   Retorna para a função anterior

;   Seleciona o Banco 1 da VRAM (Map Attr)
SetCGBVRAMBank1:
    ld a, 1			     ;   ┐   Seta a VRAM pro bank 1
	ld [rVBK], a	     ;   ┘
	ret				     ;   ─   Retorna para a função anterior

;   ╔═══════════════════════════════════════════════════╗
;   ║   "Funções de Cópia de Tiles/Data/Attr/Palette"   ║
;   ╚═══════════════════════════════════════════════════╝
CopyTileSetToVRAM:
    call DesligarLCD    
    ld a, 0
    ld [rVBK], a
.setupTileData:
    ld hl, TileSetData_P                ;   ┐
    ld e, [hl]                          ;   │   armazena o ponteiro do tileset no reg DE
    inc hl                              ;   │
    ld d, [hl]                          ;   ┘
    ld hl, TileSetDataSize_D            ;   ┐
    ld c, [hl]                          ;   │   armazena o tamanho em bytes do tileset no reg BC
    inc hl                              ;   │
    ld b, [hl]                          ;   ┘
    ld hl, _VRAM9000                    ;   ─   copia o ponteiro da VRAM do tileset no reg HL
    ld a, [TileSetBank_D]
    ld [rROMB0], a
.copyTileData:
    ld a, [de]			                ;   ┐   copia o tile pra VRAM
    ld [hli], a			                ;   ┘
    inc de				                ;   ─   incrementa o ponteiro com os tiles
    dec bc				                ;   ─   decrementa a quantidade de tiles a ser copiado
    ld a, b				                ;   ┐   Copia a quantidade de bytes restantes pro acumulador
	or c				                ;   ┘
	jp nz, .copyTileData                ;   ─   Pula de volta pro começo da função caso a flag Z (zero) nao estiver setado
.setupPaletteData:
    ld a, BCPSF_AUTOINC                 ;   ┐ Seta o auto-incremento no reg de 'especificação de palheta de cor (tilemap)'
    ld [rBCPS], a 		                ;   ┘
    ld de, rBCPD                        ;   Copia o ponteiro do registrador de palheta de cores do background
    ld bc, TileSetPaletteData_P
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    ld a, [TileSetPaletteDataSize_D]
    ld b, a
.copyPaletteData
    ld a, [hl] 			                ;   ┐ Copia o valor do acumulador pro registrador de palheta de cor (I/O)
    ld [de], a 		                    ;   ┘
    inc hl				                ;   Incrementa o ponteiro dos dados de palette do TileSet
    dec b				                ;   Decrementa a quantidade de bytes a copiar
    ld a, b				                ;   Copia a quantidade de bytes restantes pro acumulador
    cp 0 				                ;   Compara o acumulador
	jp nz, .copyPaletteData             ;   Pula de volta se o acumulador nao for Zero
    ld a, 1
    ld [rROMB0], a
	ret					                ;   Retorna para a função anterior

; Função pra copia o mapa da ROM pra VRAM 
CopyMapToVRAM:
    call DesligarLCD 
    ld a, 0                             ;   ┐ armazena o valor inicial do contador de coluna no acumulador na WRAM
    ld [VRAMColumnCount], a             ;   ┘
    ld a, [rVBK]                        ;   copia o valor do registrador de banco da VRAM pro acumulador
    bit 0, a                            ;   verifica o bit 0 do acumulador e seta a flag de acordo (Z = 0, NZ <> 0)
    jp nz, .prepareMapAttr              ;   pula pra função .prepareMapAttr se a flag Zero nao estiver setada (jp @ NZ)
.prepareMapData:
    ld hl, MapData_P                    ;   ┐
    ld e, [hl]                          ;   │ armazena o ponteiro dos tiles no reg DE
    inc hl                              ;   │
    ld d, [hl]                          ;   ┘
    jp .finishSetup                     ;   pula pra função .finishSetup
.prepareMapAttr:
    ld hl, MapAttr_P                    ;   ┐
    ld e, [hl]                          ;   │ armazena o ponteiro dos atributos dos tiles no reg DE
    inc hl                              ;   │
    ld d, [hl]                          ;   ┘
    jp .finishSetup                     ;   pula pra função .finishSetup
.finishSetup:
    ld hl, MapByteSize_D                ;   ┐
    ld c, [hl]                          ;   │ armazena o tamanho do mapa no reg BC
    inc hl                              ;   │
    ld b, [hl]                          ;   ┘
    ld hl, _SCRN0                       ;   copia o ponteiro da VRAM do mapa no reg HL
    ld a, [MapBank_D]
    ld [rROMB0], a
.loopCopy:
	ld a, [de]			                ;   ┐ copia o tile/attr pra VRAM
	ld [hli], a			                ;   ┘
	inc de				                ;   incremtenta o ponteiro com os tiles
	dec bc				                ;   decrementa a quantidade de tiles a ser copiado
    ld a, d                             ;   ┐
    ld [VRAMTempD], a                   ;   │ armazena o ponteiro dos tiles na WRAM
    ld a, e                             ;   │
    ld [VRAMTempE], a                   ;   ┘
    push de                             ;   armazena o ponteiro dos tiles na Stack
    ld d, 0                             ;   ┐
    ld a, [MapWidth_D]                  ;   │ copia a largura do mapa no reg DE
    ld e, a                             ;   ┘
    ld a, [VRAMColumnCount]             ;   ┐
    inc a                               ;   │ incrementa o contador de coluna
    ld [VRAMColumnCount], a             ;   ┘ 
    cp a, e                             ;   compara o contador de linha com a largura do mapa
    pop de                              ;   recupera o ponteiro dos tiles na Stack
    jp nz, .continue                    ;   pula pra função .continue caso o contador de coluna for menor que a largura do mapa
    ld a, 0                             ;   ┐ copia o valor pro contador de coluna na WRAM
    ld [VRAMColumnCount], a             ;   ┘
    ld d, 0                             ;   ┐
    ld a, [MapWidth_D]                  ;   │ copia a largura do mapa no reg DE
    ld e, a                             ;   ┘
    ld a, 32                            ;   copia o largura maxima na VRAM
    sub e                               ;   subtrai a largura do mapa
    ld e, a                             ;   copia o resultado no reg E
    add hl, de                          ;   incrementa a posição do ponteiro da VRAM em DE bytes
    ld a, 0                             ;   ┐ armazena o valor inicial do contador de coluna no acumulador
    ld [VRAMColumnCount], a             ;   ┘
.continue:
    ld a, [VRAMTempD]                   ;   ┐
    ld d, a                             ;   │ recupera o ponteiro dos tiles
    ld a, [VRAMTempE]                   ;   │
    ld e, a                             ;   ┘
	ld a, b				                ;   ┐ copia a quantidade de tiles restanes no acumulador
	or a, c				                ;   ┘
	jp nz, .loopCopy  	                ;   pula de volta pro começo da função caso a flag Z (zero) nao estiver setado
    ld a, 1
    ld [rROMB0], a
	ret					                ;   retorna para a função anterior

    ;   Função pra copiar os menus/windows
CopyWindowData:
    ld a, 0                             ;   copia o valor inicial do contador de linha no acumulador
    ld [VRAMColumnCount], a              ;   armazena o contador de coluna na WRAM 
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
    ld [VRAMTempD], a                   ;   │ armazena o ponteiro dos tiles na WRAM
    ld a, e                             ;   │
    ld [VRAMTempE], a                   ;   ┘
    ld a, [VRAMColumnCount]                ;   copia o contador de coluna pro acumulador
    add 1                               ;   incrementa o contador
    push hl
    ld hl, TempWindowWidth
    cp a, [hl]                          ;   compara o contador
    pop hl
    jp nz, .continue                    ;   pula pra função .continue caso a flag Z (zero) nao estiver setado
    ld a, 0                             ;   copia o valor inicial do contador de linha no acumulador
    ld [VRAMColumnCount], a              ;   armazena o contador de coluna na WRAM 
    push af
    ld d, 0
    ld a, [TempWindowVRAMLineOffset]
    ld e, a
    pop af
    add hl, de                          ;   incrementa a posição do ponteiro da VRAM em DE bytes
.continue:
    ld [VRAMColumnCount], a                ;   armazena o contador de coluna na WRAM 
    ld a, [VRAMTempD]                   ;   ┐
    ld d, a                             ;   │ recupera o ponteiro dos tiles
    ld a, [VRAMTempE]                   ;   │
    ld e, a                             ;   ┘
	ld a, b				                ;   ┐ copia a quantidade de tiles restanes no acumulador
	or a, c				                ;   ┘
	jp nz, .loop    	                ;   pula de volta pro começo da função caso a flag Z (zero) nao estiver setado
	ret					                ;   retorna para a função anterior

RenderStatusBar:
    call DesligarLCD                    ;   Desliga a tela

    ld a, StatusBarID
    call GetWindowWitdhFromID

    ld a, StatusBarID
    call GetWindowDataFromID            ;   chama a função GetMenuData
    call CopyWindowData                 ;   chama a função CopyWindowData
    call SetCGBVRAMBank1                ;   chama a função SetCGBVRAMBank1

    ld a, StatusBarID
    call GetWindowAttributesFromID      ;   chama a função GetMenuAttributes
    call CopyWindowData                 ;   chama a função CopyWindowData
    call SetCGBVRAMBank0                ;   chama a função SetCGBVRAMBank0
    ret

;   ╔═══════════════════════╗
;   ║   "Funções de Mapa"   ║
;   ╚═══════════════════════╝

ChangeMapFromColision:
    ld a, [ByteColisao]
    xor 128

    cp a, 127
    ret z

    ld b, a

    ld a, [MapBank_D]
    ld [rROMB0], a

    ld de, MapWarps_P

    ld a, [de]
    ld l, a
    inc de
    ld a, [de]
    ld h, a

    ld de, 6

.checkWarps:
    ld a, [hl]
    cp a, 127
    jp z, .checkFail
    cp a, b
    jp z, .changeMap
    add hl, de
    jp .checkWarps

.checkFail:
    ld a, 1
    ld [rROMB0], a
    ret

.changeMap:
    call DesligarLCD
    
    inc hl

    ld a, [hl+]
    add 8
    ld [PlayerPosX], a

    ld a, [hl+]
    add 16
    ld [PlayerPosY], a

    ld a, [hl+]
    ld [ScreenPosX], a
    ld [rSCX], a

    ld a, [hl+]
    ld [ScreenPosY], a
    ld [rSCY], a

    ld a, [hl]
    ld [ActiveMapId], a

    call UpdatePlayerSpritePosition

    ld a, 1
    ld [rROMB0], a

    call ChangeMap
    call LigarLCD

    ret

ChangeMap:
    call GetMapData                     ;   Chama a função GetMapData
    call SetCGBVRAMBank0                ;   Chama a função SetCGBVRAMBank0
    call CopyMapToVRAM                  ;   Chama a função CopyMapToVRAM
    call SetCGBVRAMBank1                ;   Chama a função SetCGBVRAMBank1
    call CopyMapToVRAM                  ;   Chama a função CopyMapToVRAM

    ld a, 3
    ld [rSVBK], a

    ld a, [MapBank_D]
    ld [rROMB0], a

    ld hl, MapByteSize_D
    ld c, [hl]
    inc hl
    ld b, [hl]

    ld hl, MapColision_P
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld d, a

    ld hl, MapColision

.copyMapColisionToWRAM:
    ld a, [de]
    ld [hl+], a
    inc de
    dec bc
    ld a, b
    or c
    cp 0
    jp nz, .copyMapColisionToWRAM

    ld a, 1
    ld [rSVBK], a
    ld [rROMB0], a
    

    ld a, [MapTileSetId_D]              ;   ┐ Seta o ID do tileset com o ID fornecido pelo tilemap
    ld [ActiveTilesetId], a             ;   ┘
    call GetTileSetData                 ;   Chama a função GetTileSetFromID
    call CopyTileSetToVRAM              ;   Chama a função CopyTiles

    call SetCGBVRAMBank0                ;   Chama a função SetCGBVRAMBank0

    ret

;   ╔══════════════════════╗
;   ║   "Funções de DMA"   ║
;   ╚══════════════════════╝

;   Função para copiar a Função de cópia por DMA para a HRAM
CopyDMARoutine:
    ld hl, DMARoutine                           ;   Localização da Função a ser copiada
    ld b, ((DMARoutine.end - DMARoutine) + 1)   ;   Tamanho em bytes da função a ser copiada
    ld c, LOW(hOAMDMA)                          ;   Byte 'baixo' do endereço de memoria da HRAM
.copy
    ld a, [hli]                                 ;   Move o byte apontado pelo reg HL pro acumulador e incrementa o reg HL
    ldh [c], a                                  ;   Move o valor do acumulador no byte apontado pelo reg C ($FF00 + C)
    inc c                                       ;   Incrementa reg C
    dec b                                       ;   Decrementa reg B
    jr nz, .copy                                ;   Pula de volta pro começo da função caso a flag Z (zero) nao estiver setado
    ret                                         ;   Retorna a função anterior

;   Função para copiar bytes para a OAM (Object Atribute Memory) por DMA (Direct Memory Access)
DMARoutine:
    ldh [rDMA], a                       ;   Move o valor do acumulador no registrador de DMA
    ld a, 40                           ;   Move o valor pro acumulador
.wait
    dec a                               ;   Decremtenta acumulador
    jr nz, .wait                       ;   Pula de volta pro começo da função caso a flag Z (zero) nao estiver setado
.end:
    ret                                 ;   Retorna a função anterior

;   ╔═════════════════════════╗
;   ║   "Funções do Joypad"   ║
;   ╚═════════════════════════╝

;   Função para a Leitura do Joypad
ReadJoypad:
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
    ;call nz, ToggleStartMenu            ;   chama a função ToggleStartMenu caso a flag Z (zero) nao estiver setado

    ld a, [KeyRead]                     ;   move o byte apontado pela label pro acumulador
    and KEY_SELECT                      ;   operação lógica AND no acumulador com o valor da label
    cp 0                                ;   compara o acumulador com o valor
    ;call nz, Reset                      ;   chama a função ToggleStartMenu caso a flag Z (zero) nao estiver setado

    ret                                 ;   retorna para a função anterior

;   ╔═════════════════════════╗
;   ║   "Funções de Sprite"   ║
;   ╚═════════════════════════╝

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
    ret				                    ;   retorna para a função anterior

;   Função para mover a sprite do jogador para a direita
MoverSpriteDireita:
    ld a, [PlayerPosX]
    add 8
    ld [TempPlayerPosX], a
    ld a, [PlayerPosY]
    ld [TempPlayerPosY], a
    call GetColisionData

    ld a, [ByteColisao]
    cp 0
    ret z

    ld a, [ByteColisao]
    and 128 ; $80 / %10000000
    cp 128
    jp z, ChangeMapFromColision

    ld a, [PlayerPosX]
    cp 80
    jp c, .moverSpriteDireita

    ld a, [MapWidth_D]
    sub 20
    sla a
    sla a
    sla a
    ld l, a
    ld a, [ScreenPosX]
    cp l
    jp nz, .moverScreenDireita

    ld a, [PlayerPosX]
    cp 160
    jp nz, .moverSpriteDireita
    ret
.moverScreenDireita:
    ld a, [ScreenPosX]
    add 8
    ld [ScreenPosX], a
    ld [rSCX], a
    ret
.moverSpriteDireita:
    ld a, [PlayerPosX]
    add 8
    ld [PlayerPosX], a
    call UpdatePlayerSpritePosition
    ret

;   Função para mover a sprite do jogador para a esquerda
MoverSpriteEsquerda:
    ld a, [PlayerPosX]
    sub 8
    ld [TempPlayerPosX], a
    ld a, [PlayerPosY]
    ld [TempPlayerPosY], a
    call GetColisionData

    ld a, [ByteColisao]
    cp 0
    ret z

    ld a, [ByteColisao]
    and 128 ; $80 / %10000000
    cp 128
    jp z, ChangeMapFromColision

    ld a, [PlayerPosX]
    cp 88
    jp nc, .moverSpriteEsquerda

    ld a, [ScreenPosX]
    cp 0
    jp nz, .moverScreenEsquerda

    ld a, [PlayerPosX]
    cp 8
    jp nz, .moverSpriteEsquerda
    ret
.moverScreenEsquerda:
    ld a, [ScreenPosX]
    sub 8
    ld [ScreenPosX], a
    ld [rSCX], a
    ret
.moverSpriteEsquerda:
    ld a, [PlayerPosX]
    sub 8
    ld [PlayerPosX], a
    call UpdatePlayerSpritePosition
    ret

;   Função para mover a sprite do jogador para baixo
MoverSpriteBaixo:
    ld a, [PlayerPosX]
    ld [TempPlayerPosX], a
    ld a, [PlayerPosY]
    add 8
    ld [TempPlayerPosY], a
    call GetColisionData

    ld a, [ByteColisao]
    cp 0
    ret z

    ld a, [ByteColisao]
    and 128 ; $80 / %10000000
    cp 128
    jp z, ChangeMapFromColision

    ld a, [PlayerPosY]
    cp 72
    jp c, .moverSpriteBaixo

    ld a, [MapHeigth_D]
    sub 16
    sla a
    sla a
    sla a
    ld l, a
    ld a, [ScreenPosY]
    cp l
    jp nz, .moverScreenBaixo

    ld a, [PlayerPosY]
    cp 152
    jp nz, .moverSpriteBaixo
    ret
.moverScreenBaixo:
    ld a, [ScreenPosY]
    add 8
    ld [ScreenPosY], a
    ld [rSCY], a
    ret
.moverSpriteBaixo
    ld a, [PlayerPosY]
    add 8
    ld [PlayerPosY], a
    call UpdatePlayerSpritePosition
    ret

;   Função para mover a sprite do jogador para cima
MoverSpriteCima:
    ld a, [PlayerPosX]
    ld [TempPlayerPosX], a
    ld a, [PlayerPosY]
    sub 8
    ld [TempPlayerPosY], a
    call GetColisionData

    ld a, [ByteColisao]
    cp 0
    ret z

    ld a, [ByteColisao]
    and 128 ; $80 / %10000000
    cp 128
    jp z, ChangeMapFromColision

    ld a, [PlayerPosY]
    cp 72
    jp nc, .moverSpriteCima

    ld a, [ScreenPosY]
    cp 0
    jp nz, .moverScreenCima
    
    ld a, [PlayerPosY]
    cp 16
    jp nz, .moverSpriteCima
    ret
.moverScreenCima:
    ld a, [ScreenPosY]
    sub 8
    ld [ScreenPosY], a
    ld [rSCY], a
    ret
.moverSpriteCima
    ld a, [PlayerPosY]
    sub 8
    ld [PlayerPosY], a
    call UpdatePlayerSpritePosition
    ret

;   ╔═══════════════════╗
;   ║   "Debug Stuff"   ║
;   ╚═══════════════════╝ 

; PX: 9C02, 3 | WX: 9C08, 3
; PY: 9C22, 3 | WY: 9C28, 3 | C: 9C2D, 3
Debug_RenderPlayerPos:

    ld a, [PlayerPosX]
    sub 8
    ld [Debug_DataToProcess], a
    ld hl, Debug_WRAMLoc
    ld [hl], $9C
    inc hl
    ld [hl], $02
    call Debug_ConvertPosToTile

    ld a, [PlayerPosY]
    sub 16
    ld [Debug_DataToProcess], a
    ld hl, Debug_WRAMLoc
    ld [hl], $9C
    inc hl
    ld [hl], $22
    call Debug_ConvertPosToTile

    ld a, [rSCX]
    ld [Debug_DataToProcess], a
    ld hl, Debug_WRAMLoc
    ld [hl], $9C
    inc hl
    ld [hl], $08
    call Debug_ConvertPosToTile

    ld a, [rSCY]
    ld [Debug_DataToProcess], a
    ld hl, Debug_WRAMLoc
    ld [hl], $9C
    inc hl
    ld [hl], $28
    call Debug_ConvertPosToTile

    ld a, [PlayerPosY]
    ld [TempPlayerPosY], a
    ld a, [PlayerPosX]
    ld [TempPlayerPosX], a

    call GetColisionData
    ld [Debug_DataToProcess], a
    ld hl, Debug_WRAMLoc
    ld [hl], $9C
    inc hl
    ld [hl], $2D
    call Debug_ConvertPosToTile

    ret

Debug_ConvertPosToTile:    
    ld hl, Debug_DataProcessed
    ld a, 0
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld hl, Debug_DataProcessed

    ld a, [Debug_DataToProcess]
    cp 100
    ld c, 0
    jp c, .endCentena              ; a < 100
.processCentena:
    sub 100
    inc c
    cp 100
    jp nc, .processCentena
.endCentena:
    ld b, a
    ld a, c
    add 144
    ld [hl], a
    ld a, b
.checkDezena:
    inc hl
    cp 10
    ld c, 0
    jp c, .endDezena           ; a < 10
    ld c, 0
.processDezena:
    sub 10
    inc c
    cp 10
    jp nc, .processDezena
.endDezena:
    ld b, a
    ld a, c
    add 144
    ld [hl], a
    ld a, b
.processUnidade:
    inc hl
    add 144
    ld [hl], a 
.prepareDataToVRAM:
    ld bc, Debug_WRAMLoc
    ld a, [bc]
    ld h, a
    inc bc
    ld a, [bc]
    ld l, a
    ld bc, 3
    ld de, Debug_DataProcessed
.copyDataToVRAM:
    ld a, [rSTAT]           ; puxa os status do lcd
    and STATF_VBL           ; filta o bit do vblank
    jp nz, .copyDataToVRAM  ; pula pro começo se o lcd nao estiver em vblank 
    ld a, [de]              ; copia o tile da wram pro acumulador
    ld [hl+], a             ; copia o tile do acumulador pra vram e incrementa o ponteiro da vram
    inc de                  ; incrementa o ponteiro da wram
    dec bc                  ; decrementa o contador
    ld a, b                 ; copia o byte alto do contador pro acumulador
    or c                    ; "soma" o acumulador com o byte baixo do contador
    jp nz, .copyDataToVRAM  ; pula pro começo se a soma for maior que zero
.end:
    ret 


;   ╔═════════════════╗
;   ║   "Variables"   ║
;   ╚═════════════════╝ 

SECTION "OAM DMA", HRAM
hOAMDMA: ds 8                           ;   Espaço na HRAM para alocar a função de cópia de bytes pra OAM

SECTION "Variaveis_OAM", WRAM0[$C100]
SpritesDataRAM:: ds 12                   ;   Data das sprites para copiar a OAM

SECTION "Variaveis", WRAM0[$C000]
KeyRead: ds 1                           ;   Buffer de leitura do keypad
MenuEntry: ds 1                         ;   Índice do Menu
TempRenderStatsTiles: ds 15
ScreenPosY: ds 1
ScreenPosX: ds 1
;VRAM Load Variables
VRAMTempD: ds 1                         ;   Armazenamento temporario do reg D
VRAMTempE: ds 1                         ;   Armazenamento temporario do reg E
VRAMColumnCount: ds 1                   ;   Armazenamento do contador de coluna da VRAM
TempPlayerPosY:: ds 1
TempPlayerPosX:: ds 1
ByteColisao:: ds 1
;SECTION "Player Data", WRAM0[$C000]
PlayerPosY:: ds 1    ;   Posição Y do jogador
PlayerPosX:: ds 1    ;   Posição X do jogador
Name: ds 15         ;   ┐
Health: ds 1        ;   │
Mana: ds 1          ;   │
Experience: ds 2    ;   │
Attack: ds 1        ;   │ Player Data
Defense: ds 1       ;   │
Speed: ds 1         ;   │
Money: ds 2         ;   │
;Inventory          ;   ┘
;SECTION "Map WRAM", WRAM0[$C000]
MapBank_D:: ds 1        ; (data) rom bank do mapa
MapData_P:: ds 2        ; (ponteiro) data do tilemap
MapAttr_P:: ds 2        ; (ponteiro) atributos do tilemap
MapByteSize_D:: ds 2    ; (data) tamanho em bytes do tilemap
MapTileSetId_D:: ds 1   ; (data) id do tileset usado pelo tilemap
MapColision_P:: ds 2    ; (ponteiro) colisao do tilemap
MapWarps_P:: ds 2       ; (ponteiro) tabela de warps do mapa
MapWidth_D:: ds 1       ; (data) largura (X) do mapa
MapHeigth_D:: ds 1      ; (data) altura (Y) do mapa
MapUnused: ds 2         ; Possível uso futuro
ActiveMapId:: ds 1      ; ID do mapa atual
;SECTION "TileSet WRAM", WRAM0[$C000]
TileSetBank_D:: ds 1                ; (data) rom bank do mapa
TileSetData_P:: ds 2                ; (ponteiro) data do tileset
TileSetDataSize_D:: ds 2            ; (data) tamanho em bytes do tileset
TileSetPaletteData_P:: ds 2         ; (ponteiro) palheta de cores do tileset
TileSetPaletteDataSize_D:: ds 1     ; (data) tamanho em bytes do tileset
TileSetUnused: ds 1                 ; Possível uso futuro
ActiveTilesetId:: ds 1              ; ID do tileset atual
TileSetPallete:: ds 64              ; Palheta de cores do tileset   
;SECTION "Window WRAM", WRAM0[$C000]
TempWindowWidth::           ds 1
TempWindowVRAMLineOffset::  ds 1
;BytesLivre: ds 111

SECTION "TileSet Data", WRAMX, BANK[2]
TileSetData:: ds 2048               ; Dados do tileSet

SECTION "Map Data", WRAMX, BANK[3]
MapData:: ds 768        ; Data do mapa atual
MapAttributes:: ds 768  ; Atributos do mapa atual
MapColision:: ds 768    ; Tabela de colisao do mapa atual

SECTION "Debug", WRAM0[$CF00]
Debug_DataToProcess: ds 1
Debug_DataProcessed: ds 3
Debug_WRAMLoc: ds 2
; http://win32assembly.programminghorizon.com/tut25.html
; http://win32assembly.programminghorizon.com/tut3.html

;Ainda não acabamos os detalhes do projeto porque ao rodar, as imagens simplesmente não aparecem
;e precisamos rodar para aos poucos achar o melhor posicionamento pro pac-man, fantasmas e paredes
;por enquanto esses objetos estão com valores aleatórios puramente para teste.

.386 
.model flat,stdcall
option casemap:none

include pacman.inc

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD


TEXT_ MACRO your_text:VARARG
    LOCAL text_string
    .data
     text_string db your_text,0
    .code
    EXITM <addr text_string>
ENDM

.DATA
ClassName db "PacmanWindowClass",0 
AppName db "PACMAN",0         

.DATA?
hInstance HINSTANCE ? 
CommandLine LPSTR ? 

.CODE
start: 

    ;invoke  uFMOD_PlaySong,TEXT_("Speedball.xm"),0,XM_FILE
    ;invoke  uFMOD_PlaySong,0,0,0   comando para parar a musica 
    invoke GetModuleHandle, NULL             
                                            
    mov hInstance,eax 

    invoke GetCommandLine                   
    mov CommandLine,eax 

    invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT ;chama a função principal
    invoke ExitProcess, eax                                           


; _ PROCEDURES ___________________________________________________________________________
;procedimento para carregar o número certo para cada imagem
loadImages proc              

    ;Carregando as imagens dos fantasmas:
    invoke LoadBitmap, hInstance, 100
    mov G0, eax
    invoke LoadBitmap, hInstance, 101
    mov G1, eax
    invoke LoadBitmap, hInstance, 102
    mov G2, eax
    invoke LoadBitmap, hInstance, 103
    mov G3, eax
    invoke LoadBitmap, hInstance, 104
    mov G4, eax
    invoke LoadBitmap, hInstance, 131
    mov G1_DEAD, eax
    invoke LoadBitmap, hInstance, 132
    mov G2_DEAD, eax
    invoke LoadBitmap, hInstance, 133
    mov G3_DEAD, eax
    invoke LoadBitmap, hInstance, 134
    mov G4_DEAD, eax

    ;Carregando as imagens do pac:
    invoke LoadBitmap, hInstance, 115
    mov PAC_RIGHT_OPEN, eax
    invoke LoadBitmap, hInstance, 116
    mov PAC_RIGHT_CLOSED, eax
    invoke LoadBitmap, hInstance, 117
    mov PAC_TOP_OPEN, eax
    invoke LoadBitmap, hInstance, 118
    mov PAC_TOP_CLOSED, eax
    invoke LoadBitmap, hInstance, 119
    mov PAC_LEFT_OPEN, eax
    invoke LoadBitmap, hInstance, 120
    mov PAC_LEFT_CLOSED, eax
    invoke LoadBitmap, hInstance, 121
    mov PAC_DOWN_OPEN, eax
    invoke LoadBitmap, hInstance, 122
    mov PAC_DOWN_CLOSED, eax


    ;Imagens de coisas do mapa:
    invoke LoadBitmap, hInstance, 112
    mov WALL_TILE, eax
    invoke LoadBitmap, hInstance, 113
    mov FOOD_IMG, eax
    invoke LoadBitmap, hInstance, 114
    mov PILL_IMG, eax

    ;Imagens de background, carregamento e menu:
    invoke LoadBitmap, hInstance, 107
    mov h_background, eax
    invoke LoadBitmap, hInstance, 108
    mov h_loading, eax
    invoke LoadBitmap, hInstance, 109
    mov h_menu, eax

    ;Imagens de vitória e derrota:
    invoke LoadBitmap, hInstance, 110
    mov p_won, eax
    invoke LoadBitmap, hInstance, 111
    mov game_over, eax

    ret
loadImages endp
;______________________________________________________________________________
;Função para saber se objetos estão colidindo, guarda true ou false no edx
isColliding proc obj1Pos:point, obj2Pos:point, obj1Size:point, obj2Size:point
    
    push eax
    push ebx

    mov eax, obj1Pos.x
    add eax, obj1Size.x 
    mov ebx, obj2Pos.x
    add ebx, obj2Size.x

    .if obj1Pos.x < ebx && eax > obj2Pos.x
        mov eax, obj1Pos.y
        add eax, obj1Size.y
        mov ebx, obj2Pos.y
        add ebx, obj2Size.y
        
        .if obj1Pos.y < ebx && eax > obj2Pos.y ;estão colidindo
            mov edx, TRUE
        .else
            mov edx, FALSE
        .endif
    .else
        mov edx, FALSE
    .endif

    pop ebx
    pop eax

    ret

isColliding endp
;______________________________________________________________________________
;decide o background dependendo do gamestate
paintBackground proc _hdc:HDC, _hMemDC:HDC, _hMemDC2:HDC

.if GAMESTATE == 0 ;tela de carregamento
    ;print "game state 0 yeah", 13,10
    invoke SelectObject, _hMemDC2, h_loading
    invoke BitBlt, _hMemDC, 0, 0, 800, 600, _hMemDC2, 0, 0, SRCCOPY
.endif

.if GAMESTATE == 1 ;menu inicial
    ;print "game state1 yeah", 13,10
    invoke SelectObject, _hMemDC2, h_menu
    invoke BitBlt, _hMemDC, 0, 0, 800, 600, _hMemDC2, 0, 0, SRCCOPY
.endif

.if GAMESTATE == 2 ;jogo em si
    ;print "game state2 yeah", 13,10
    invoke SelectObject, _hMemDC2, h_background
    invoke BitBlt, _hMemDC, 0, 0, 800, 600, _hMemDC2, 0, 0, SRCCOPY
.endif

.if GAMESTATE == 3 ;perdeu
    invoke SelectObject, _hMemDC2, game_over
    invoke BitBlt, _hMemDC, 0, 0, 800, 600, _hMemDC2, 0, 0, SRCCOPY
.endif

.if GAMESTATE == 4 ;ganhou
    invoke SelectObject, _hMemDC2, p_won
    invoke BitBlt, _hMemDC, 0, 0, 800, 600, _hMemDC2, 0, 0, SRCCOPY
.endif

    ret
paintBackground endp
;____________________________________________________________________________
;pinta a quantidade de vidas na tela
paintLifes proc _hdc:HDC, _hMemDC:HDC, _hMemDC2:HDC
    invoke SelectObject, _hMemDC2, PAC_RIGHT_OPEN ;(a vida tem a imagem do pac man)
    mov ebx, 0
    movzx ecx, pac.life ;guarda quantas vidas ele tem
    .while ebx != ecx 
        mov eax, LIFE_SIZE
        mul ebx
        push ecx
        invoke TransparentBlt, _hMemDC, eax, 0,\
                LIFE_SIZE, LIFE_SIZE, _hMemDC2,\
                0, 0, LIFE_SIZE, LIFE_SIZE, 16777215
        pop ecx
        inc ebx
    .endw
    ret
paintLifes endp
;____________________________________________________________________________
;pinta um objeto qualquer baseado na posição e tamanho dele
paintPos proc  uses eax _hMemDC:HDC, _hMemDC2:HDC, addrPoint:dword, addrPos:dword
assume edx:ptr point
assume ecx:ptr point

    mov edx, addrPoint
    mov ecx, addrPos

    mov eax, [ecx].x
    mov ebx, [ecx].y
    invoke TransparentBlt, _hMemDC, eax, ebx, [edx].x, [edx].y, _hMemDC2, 0, 0, [edx].x, [edx].y, 16777215

ret
paintPos endp
;____________________________________________________________________________
;decide o sprite do pacman baseado na direção e vai mudando a boca de aberta para fechada e passa pro edx
decideAnimation proc

    .if pac.animation == 0
        .if pac.direction == D_RIGHT
            mov edx, PAC_RIGHT_OPEN
        .elseif pac.direction == D_TOP
            mov edx, PAC_TOP_OPEN
        .elseif pac.direction == D_LEFT
            mov edx, PAC_LEFT_OPEN
        .elseif pac.direction == D_DOWN
            mov edx, PAC_DOWN_OPEN
        .endif
    .elseif pac.animation == 1
        .if pac.direction == D_RIGHT
            mov edx, PAC_RIGHT_CLOSED
        .elseif pac.direction == D_TOP
            mov edx, PAC_TOP_CLOSED
        .elseif pac.direction == D_LEFT
            mov edx, PAC_LEFT_CLOSED
        .elseif pac.direction == D_DOWN
            mov edx, PAC_DOWN_CLOSED
        .endif
    .endif

    .if pac.anim_counter >= 20
        mov pac.animation, 1
    .elseif pac.anim_counter <= 0
        mov pac.animation, 0
    .endif

    .if pac.animation == 0
        add pac.anim_counter, 1
    .elseif pac.animation == 1
        add pac.anim_counter, -1
    .endif
ret
decideAnimation endp
;____________________________________________________________________________
;desenha o pac na tela
paintPlayer proc _hdc:HDC, _hMemDC:HDC, _hMemDC2:HDC

    invoke decideAnimation ;decide a animação, passa pro edx
    invoke SelectObject, _hMemDC2, edx ;seleciona essa imagem para pintar
    invoke paintPos, _hMemDC, _hMemDC2, addr PAC_SIZE_POINT, addr pac.playerObj.pos ;pinta

    ret
paintPlayer endp

;________________________________________________________________________________
;desenha os fantasmas na tela
paintGhosts proc _hdc:HDC, _hMemDC:HDC, _hMemDC2:HDC

    ;Fantasma 1:
    .if ghost1.alive == FALSE
        invoke SelectObject, _hMemDC2, G1_DEAD
    .elseif ghost1.afraid == 1 
        invoke SelectObject, _hMemDC2, G0
    .else
        invoke SelectObject, _hMemDC2, G1
    .endif
    invoke paintPos, _hMemDC, _hMemDC2, addr GHOST_SIZE_POINT, addr ghost1.ghostObj.pos

;Fantasma 2:
    .if ghost2.alive == FALSE
        invoke SelectObject, _hMemDC2, G2_DEAD
    .elseif ghost2.afraid == 1 
        invoke SelectObject, _hMemDC2, G0
    .else
        invoke SelectObject, _hMemDC2, G2
    .endif
    invoke paintPos, _hMemDC, _hMemDC2, addr GHOST_SIZE_POINT, addr ghost2.ghostObj.pos

;Fantasma 3:
    .if ghost3.alive == FALSE
        invoke SelectObject, _hMemDC2, G3_DEAD
    .elseif ghost3.afraid == 1 
        invoke SelectObject, _hMemDC2, G0
    .else
        invoke SelectObject, _hMemDC2, G3
    .endif
    invoke paintPos, _hMemDC, _hMemDC2, addr GHOST_SIZE_POINT, addr ghost3.ghostObj.pos

;Fantasma 4:
    .if ghost4.alive == FALSE
        invoke SelectObject, _hMemDC2, G4_DEAD
    .elseif ghost4.afraid == 1 
        invoke SelectObject, _hMemDC2, G0
    .else
        invoke SelectObject, _hMemDC2, G4
    .endif
    invoke paintPos, _hMemDC, _hMemDC2, addr GHOST_SIZE_POINT, addr ghost4.ghostObj.pos

    ret
paintGhosts endp
;________________________________________________________________________________
;desenha os objetos do mapa (paredes, comida, pílulas)
paintMap proc _hdc:HDC, _hMemDC:HDC, _hMemDC2:HDC

    ;________PAREDES________________________________________________________________
    invoke SelectObject, _hMemDC2, WALL_TILE

    push eax
    assume eax:ptr wallTile
    mov eax, map.first_wall 
    .while eax != 0
        invoke paintPos, _hMemDC, _hMemDC2, addr WALL_SIZE_POINT, addr [eax].pos
        mov eax, [eax].next_wall
    .endw
    assume eax:nothing
    pop eax

    ;________COMIDAS_________________________________________________________________
    invoke SelectObject, _hMemDC2, FOOD_IMG

    invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food1.foodObj.pos
    invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food2.foodObj.pos
    invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food3.foodObj.pos
    invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food4.foodObj.pos
    invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food5.foodObj.pos
    invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food6.foodObj.pos
    invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food7.foodObj.pos
    invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food8.foodObj.pos
    invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food9.foodObj.pos
    invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food10.foodObj.pos
    invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food11.foodObj.pos
    invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food12.foodObj.pos
    invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food13.foodObj.pos
    ;invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food14.foodObj.pos
    ;invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food15.foodObj.pos
    ;invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food16.foodObj.pos
    ;invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food17.foodObj.pos
    ;invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food18.foodObj.pos
    ;invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food19.foodObj.pos
    ;invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food20.foodObj.pos
    ;invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food21.foodObj.pos
    ;invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food22.foodObj.pos
    ;invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food23.foodObj.pos
    ;invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr food24.foodObj.pos
    ;aqui

    ;push eax
    ;assume eax:ptr food
    ;mov eax, map.first_food
    ;.while [eax].next_food != 0
        ;invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr [eax].foodObj.pos
        ;mov eax, [eax].next
        ;invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr [eax].foodObj.pos
    ;.endw
    ;assume eax:nothing
    ;pop eax

    ;________PÍLULAS_________________________________________________________________
    invoke SelectObject, _hMemDC2, PILL_IMG

    invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr pill1.pillObj.pos
    invoke paintPos, _hMemDC, _hMemDC2, addr FOOD_SIZE_POINT, addr pill2.pillObj.pos
    ;aqui

    ;push eax
    ;assume eax:ptr pill
    ;mov eax, map.first_pill 
    ;.while eax != 0
        ;invoke paintPos, _hMemDC, _hMemDC2, addr WALL_SIZE_POINT, addr [eax].pillObj.pos
        ;mov eax, [eax].next_pill
    ;.endw
    ;assume eax:nothing
    ;pop eax

    ret
paintMap endp

;________________________________________________________________________________
;chama todas as funções de desenho (dependendo do gamestate)
updateScreen proc
    LOCAL hMemDC:HDC
    LOCAL hMemDC2:HDC
    LOCAL hBitmap:HDC
    LOCAL hDC:HDC

    invoke BeginPaint, hWnd, ADDR paintstruct
    mov hDC, eax
    invoke CreateCompatibleDC, hDC
    mov hMemDC, eax
    invoke CreateCompatibleDC, hDC
    mov hMemDC2, eax
    invoke CreateCompatibleBitmap, hDC, WINDOW_SIZE_X, WINDOW_SIZE_Y
    mov hBitmap, eax

    invoke SelectObject, hMemDC, hBitmap

    invoke paintBackground, hDC, hMemDC, hMemDC2 ;verifica se é necessário mudar o background

    .if GAMESTATE == 2 ;se o gamestate for o do jogo, desenha os objetos
        invoke paintMap, hDC, hMemDC, hMemDC2
        invoke paintPlayer, hDC, hMemDC, hMemDC2
        invoke paintGhosts, hDC, hMemDC, hMemDC2
        invoke paintLifes, hDC, hMemDC, hMemDC2
    .endif

    invoke BitBlt, hDC, 0, 0, WINDOW_SIZE_X, WINDOW_SIZE_Y, hMemDC, 0, 0, SRCCOPY

    invoke DeleteDC, hMemDC
    invoke DeleteDC, hMemDC2
    invoke DeleteObject, hBitmap
    invoke EndPaint, hWnd, ADDR paintstruct

    ret
updateScreen endp

;______________________________________________________________________________
;thread de desenho
paintThread proc p:DWORD
    .while !over
        invoke Sleep, 17 ; 60 FPS

        invoke InvalidateRect, hWnd, NULL, FALSE

    .endw

    ret
paintThread endp

;_______________________________________________________________________________
;verifica se um objeto vai colidir com outro, antes da colisão ocorrer
;isso é necessário para o pacman e os fantasmas não ficarem presos na parede
willCollide proc uses ebx direction:BYTE, addrObj:dword
assume eax:ptr gameObject
    mov eax, addrObj

    mov ebx, [eax].pos.x
    mov tempPos.x, ebx
    mov ebx, [eax].pos.y
    mov tempPos.y, ebx

    .if direction == 0 ;right
        add tempPos.x, 6
    .elseif direction == 1 ;top
        add tempPos.y, -6
    .elseif direction == 2 ;left
        add tempPos.x, -6
    .elseif direction == 3 ;down
        add tempPos.y, 6
    .endif

    push eax

    assume eax:ptr wallTile
    mov eax, map.first_wall 
    .while eax != 0
        invoke isColliding, tempPos, [eax].pos, PAC_SIZE_POINT, WALL_SIZE_POINT
        .if edx == TRUE
            pop eax
            ret
        .endif
        mov eax, [eax].next_wall
    .endw

    pop eax

ret
willCollide endp

;______________________________________________________________________________
;roda a variável de "próxima direção" de cada fantasma
randomizeGhost proc uses eax addrGhost:dword 
assume eax:ptr ghost
    mov eax, addrGhost

    .if [eax].random_dir < 3
        add [eax].random_dir, 1
    .elseif [eax].random_dir == 3
        mov [eax].random_dir, 0
    .endif

    ret
randomizeGhost endp
;______________________________________________________________________________
;função para um objeto n sair da tela, mas sim voltar pelo outro lado
fixCoordinates proc addrObj:dword
assume eax:ptr gameObject
    mov eax, addrObj

    .if [eax].pos.x > WINDOW_SIZE_X && [eax].pos.x < 80000000h
        mov [eax].pos.x, 20
    .endif
    .if [eax].pos.x <= 10 || [eax].pos.x > 80000000h
        mov [eax].pos.x, WINDOW_SIZE_X - 20 
    .endif
    .if [eax].pos.y > WINDOW_SIZE_Y - 30 && [eax].pos.y < 80000000h
        mov [eax].pos.y, 20
    .endif
    .if [eax].pos.y <= 10 || [eax].pos.y > 80000000h
        mov [eax].pos.y, WINDOW_SIZE_Y - 80 
    .endif
assume eax:nothing
ret
fixCoordinates endp
;______________________________________________________________________________
;move o fantasma baseado na sua direção
moveGhost proc uses eax ebx ecx addrGhost:dword
    assume eax:ptr ghost
    mov eax, addrGhost

    mov ebx, [eax].ghostObj.speed.x
    mov ecx, [eax].ghostObj.speed.y

    invoke willCollide, [eax].direction, addr [eax].ghostObj
    .if edx == FALSE
        .if [eax].direction == D_TOP
            add [eax].ghostObj.pos.y, -GHOST_SPEED
        .elseif [eax].direction == D_RIGHT
            add [eax].ghostObj.pos.x,  GHOST_SPEED
        .elseif [eax].direction == D_DOWN
            add [eax].ghostObj.pos.y,  GHOST_SPEED
        .elseif [eax].direction == D_LEFT
            add [eax].ghostObj.pos.x,  -GHOST_SPEED
        .endif
    .else ;se o fantasma for colidir, muda a direção dele para a aleatória pré selecionada
        mov bh, [eax].random_dir
        mov [eax].direction, bh
    .endif
    invoke fixCoordinates, addr [eax].ghostObj
    invoke randomizeGhost, eax

    assume eax:nothing
    ret
moveGhost endp
;______________________________________________________________________________
;função para o personagem se mover, baseado na velocidade
movePlayer proc uses eax

    invoke willCollide, pac.direction, addr pac.playerObj
    .if edx == FALSE
        mov eax, pac.playerObj.pos.x
        mov ebx, pac.playerObj.speed.x
        .if bx > 7fh
            or bx, 65280
        .endif
        add eax, ebx
        mov pac.playerObj.pos.x, eax
        mov eax, pac.playerObj.pos.y
        mov ebx, pac.playerObj.speed.y
        .if bx > 7fh 
            or bx, 65280
        .endif
        add ax, bx
        mov pac.playerObj.pos.y, eax
        invoke fixCoordinates, addr pac.playerObj
    .endif
    ret
movePlayer endp
;______________________________________________________________________________
;faz verificações no fantasma para decrescer o timer de medo e morte, e voltar ao normal se o timer acabar
checkGhost proc uses eax addrGhost:dword
assume eax:ptr ghost
    mov eax, addrGhost

    .if [eax].afraid_timer > 0
        add [eax].afraid_timer, -1
    .elseif [eax].afraid == TRUE
        mov [eax].afraid, FALSE
    .endif

    .if [eax].death_timer > 0
        add [eax].death_timer, -1
    .elseif [eax].alive == FALSE
        mov [eax].alive, TRUE
    .endif

ret
checkGhost endp
;______________________________________________________________________________
;função pra mover todos os fantasmas de uma vez e deixar o código do gameManager mais limpo
moveGhosts proc

    .if ghost1.alive
        invoke moveGhost, addr ghost1
    .endif
    .if ghost2.alive
        invoke moveGhost, addr ghost2
    .endif
    .if ghost3.alive
        invoke moveGhost, addr ghost3
    .endif
    .if ghost4.alive
        invoke moveGhost, addr ghost4
    .endif
    invoke checkGhost, addr ghost1
    invoke checkGhost, addr ghost2
    invoke checkGhost, addr ghost3
    invoke checkGhost, addr ghost4

ret
moveGhosts endp

;______________________________________________________________________________
;reposiciona um objeto qualquer
reposition proc uses eax ebx addrObj:dword
assume ecx:ptr  gameObject
    mov ecx, addrObj

    mov eax, [ecx].initPos.x
    mov ebx, [ecx].initPos.y

    mov [ecx].pos.x, eax
    mov [ecx].pos.y, ebx 

    mov [ecx].speed.x, 0
    mov [ecx].speed.y, 0

ret
reposition endp
;______________________________________________________________________________
;reinicia todas as variáveis de um fantasma para o inicial
restartGhost proc uses eax ebx addrGhost:dword
assume eax: ptr ghost
    mov eax, addrGhost
    
    mov [eax].afraid, FALSE
    mov [eax].afraid_timer, 0
    mov bh, [eax].init_dir
    mov [eax].direction, bh
    invoke reposition, addr [eax].ghostObj

ret
restartGhost endp
;______________________________________________________________________________
;reposiciona tudo no lugar quando o jogo acaba
gameOver proc

    mov pac.life, 4
    mov pac.direction, D_RIGHT
    invoke reposition, addr pac.playerObj

    invoke restartGhost, addr ghost1
    invoke restartGhost, addr ghost2
    invoke restartGhost, addr ghost3
    invoke restartGhost, addr ghost4

    invoke reposition, addr food1.foodObj
    invoke reposition, addr food2.foodObj
    invoke reposition, addr food3.foodObj
    invoke reposition, addr food4.foodObj
    invoke reposition, addr food5.foodObj
    invoke reposition, addr food6.foodObj
    invoke reposition, addr food7.foodObj
    invoke reposition, addr food8.foodObj
    invoke reposition, addr food9.foodObj
    invoke reposition, addr food10.foodObj
    invoke reposition, addr food11.foodObj
    invoke reposition, addr food12.foodObj
    invoke reposition, addr food13.foodObj
    ;invoke reposition, addr food14.foodObj
    ;invoke reposition, addr food15.foodObj
    ;invoke reposition, addr food16.foodObj
    ;invoke reposition, addr food17.foodObj
    ;invoke reposition, addr food18.foodObj
    ;invoke reposition, addr food19.foodObj
    ;invoke reposition, addr food21.foodObj
    ;invoke reposition, addr food22.foodObj
    ;invoke reposition, addr food23.foodObj
    ;invoke reposition, addr food24.foodObj
    ;invoke reposition, addr food25.foodObj
    ;invoke reposition, addr food26.foodObj
    ;invoke reposition, addr food27.foodObj
    ;invoke reposition, addr food28.foodObj
    ;invoke reposition, addr food29.foodObj
    ;invoke reposition, addr food30.foodObj
    ;invoke reposition, addr food31.foodObj
    ;invoke reposition, addr food32.foodObj
    ;invoke reposition, addr food33.foodObj
    ;invoke reposition, addr food34.foodObj
    ;invoke reposition, addr food35.foodObj
    ;invoke reposition, addr food36.foodObj
    ;invoke reposition, addr food37.foodObj
    ;invoke reposition, addr food38.foodObj
    ;invoke reposition, addr food39.foodObj
    ;invoke reposition, addr food40.foodObj

    ;aqui

    ;push eax
    ;assume eax:ptr food
    ;mov eax, allFood.first
    ;.while eax != 0
    ;    invoke reposition, addr [eax].foodObj
    ;    mov eax, [eax].next
    ;.endw
    ;pop eax

    invoke reposition, addr pill1.pillObj
    invoke reposition, addr pill2.pillObj
    ;aqui

    mov food_left, 13

    ret
gameOver endp
;_____________________________________________________________________________
;verifica se o pac bateu em um fantasma e faz ele matar ou perder uma vida, dependendo da situação
hitGhost proc addrGhost:dword
assume ecx:ptr ghost

    mov ecx, addrGhost
    invoke isColliding, pac.playerObj.pos, [ecx].ghostObj.pos, PAC_SIZE_POINT, GHOST_SIZE_POINT
    .if edx == TRUE
        .if [ecx].afraid == 0 ; se o fantasma matar o pac
            ;vai para posição de reinício
            mov pac.direction, D_RIGHT
            invoke reposition, addr pac.playerObj

            dec pac.life ;perde uma vida
            .if pac.life == 0 ;se for a última morreu
                invoke gameOver
                mov GAMESTATE, 3 ;perdeu
                ret
            .endif
        .else ;se o pacman estiver buffado e conseguir matar
            ;reinicia o fantasma pro meio, parado por um tempo
            mov [ecx].death_timer, 100
            mov [ecx].alive, FALSE
            invoke restartGhost, addr [ecx]
        .endif
    .endif

ret
hitGhost endp
;_____________________________________________________________________________
;verifica se o pac comeu uma comida e ganha o jogo se for a última
colideWithFood proc addrFood:dword
assume eax:ptr food
    mov eax, addrFood
   
    invoke isColliding, pac.playerObj.pos, [eax].foodObj.pos, PAC_SIZE_POINT, FOOD_SIZE_POINT
        .if edx == TRUE
            mov [eax].foodObj.pos.x, -100
            mov [eax].foodObj.pos.y, -100
            add food_left, -1
            .if food_left == 0 ;se as comidas acabarem
                invoke gameOver
                mov GAMESTATE, 4 ;ganhou
            .endif
        .endif

ret
colideWithFood endp
;_____________________________________________________________________________
;deixa todos os fantasmas assustados
scareGhosts proc

    mov ghost1.afraid, TRUE
    mov ghost1.afraid_timer, 100
    mov ghost2.afraid, TRUE
    mov ghost2.afraid_timer, 100
    mov ghost3.afraid, TRUE
    mov ghost3.afraid_timer, 100
    mov ghost4.afraid, TRUE
    mov ghost4.afraid_timer, 100

ret
scareGhosts endp
;_____________________________________________________________________________
;verifica se o pac pegou uma pílula, e se for o caso chama o scareGhosts
colideWithPill proc uses eax addrPill:dword
assume eax:ptr pill
    mov eax, addrPill
   
    invoke isColliding, pac.playerObj.pos, [eax].pillObj.pos, PAC_SIZE_POINT, PILL_SIZE_POINT
        .if edx == TRUE
            mov [eax].pillObj.pos.x, -100
            mov [eax].pillObj.pos.y, -100
            invoke scareGhosts
        .endif

ret
colideWithPill endp
;______________________________________________________________________________
;função principal para o jogo agir de acordo com o gamestate
gameManager proc p:dword
        LOCAL area:RECT

        .if GAMESTATE == 0 ;tela de loading (espera 3s e passa para o próximo)
            invoke Sleep, 2000
            inc GAMESTATE
        .endif

        .while GAMESTATE == 1 ;menu (espera o usuário apertar enter)
            invoke Sleep, 30
        .endw

        game: ;verificações constantes do jogo
        .while GAMESTATE == 2 ;jogo
            invoke Sleep, 30

            ;verifica se bateu nos fantasmas
            invoke hitGhost, addr ghost1
            invoke hitGhost, addr ghost2 
            invoke hitGhost, addr ghost3
            invoke hitGhost, addr ghost4

            ;verifica se tocou nas comidas
            push eax
            assume eax:ptr food
            mov eax, map.first_food
            .while eax != 0
                invoke colideWithFood, eax
                mov eax, [eax].next_food
            .endw
            assume eax:nothing
            pop eax

            ;verifica se tocou nas pílulas
            push eax
            assume eax:ptr pill
            mov eax, map.first_pill
            .while eax != 0
                invoke colideWithPill, eax
                mov eax, [eax].next_pill
            .endw
            assume eax:nothing
            pop eax

            ;move o player e os fantasmas
            invoke movePlayer
            invoke moveGhosts

        .endw 
    
        ;em ambos os casos, só será preciso apertar enter para recomeçar
        .while GAMESTATE == 3 || GAMESTATE == 4
            invoke Sleep, 30
        .endw

        jmp game
ret
gameManager endp

;_____________________________________________________________________________________________________________________________
;muda a velocidade do pac dependendo da tecla q foi apertada
changePlayerSpeed proc direction:BYTE

    .if direction == D_TOP ; w / seta pra cima
        mov pac.playerObj.speed.y, -PAC_SPEED
        mov pac.playerObj.speed.x, 0
        mov pac.direction, D_TOP
    .elseif direction == D_DOWN ; s / seta pra baixo
        mov pac.playerObj.speed.y, PAC_SPEED
        mov pac.playerObj.speed.x, 0
        mov pac.direction, D_DOWN
    .elseif direction == D_LEFT ; a / seta pra esquerda
        mov pac.playerObj.speed.x, -PAC_SPEED
        mov pac.playerObj.speed.y, 0
        mov pac.direction, D_LEFT
    .elseif direction == D_RIGHT ; d / seta pra direita
        mov pac.playerObj.speed.x, PAC_SPEED
        mov pac.playerObj.speed.y, 0
        mov pac.direction, D_RIGHT
    .endif

    assume ecx: nothing
    ret
changePlayerSpeed endp

; _ WINMAIN __________________________________________________________________________________________________________________
;cria a janela e faz os procedimentos padrão do windows
WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD 
    LOCAL clientRect:RECT
    LOCAL wc:WNDCLASSEX                                                
    LOCAL msg:MSG 

    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_BYTEALIGNWINDOW
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 

    push  hInstance 
    pop   wc.hInstance 
    mov   wc.hbrBackground, NULL
    mov   wc.lpszMenuName,NULL 
    mov   wc.lpszClassName ,OFFSET ClassName 

    invoke LoadIcon, NULL, IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 

    invoke LoadCursor, NULL,IDC_ARROW 
    mov   wc.hCursor, eax 

    invoke RegisterClassEx, addr wc

    mov clientRect.left, 0
    mov clientRect.top, 0
    mov clientRect.right, WINDOW_SIZE_X
    mov clientRect.bottom, WINDOW_SIZE_Y

    invoke AdjustWindowRect, addr clientRect, WS_CAPTION, FALSE

    mov eax, clientRect.right
    sub eax, clientRect.left
    mov ebx, clientRect.bottom
    sub ebx, clientRect.top

    invoke CreateWindowEx, NULL, addr ClassName, addr AppName,\ 
        WS_OVERLAPPED or WS_SYSMENU or WS_MINIMIZEBOX,\ 
        CW_USEDEFAULT, CW_USEDEFAULT,\
        eax, ebx, NULL, NULL, hInst, NULL 
        
    mov   hWnd,eax 
    invoke ShowWindow, hWnd, CmdShow 
    invoke UpdateWindow, hWnd

    ;a janela vai ficar sempre recebendo mensagens e tratando elas
    .WHILE TRUE
                invoke GetMessage, ADDR msg,NULL,0,0 
                .BREAK .IF (!eax)
                invoke TranslateMessage, ADDR msg 
                invoke DispatchMessage, ADDR msg 
    .ENDW 
    mov     eax,msg.wParam ;retorna o código de saída no eax
    ret 
WinMain endp

WndProc proc _hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    LOCAL direction : BYTE
    mov direction, -1

    ;quando ele recebe uma mensagem, lê qual é
    .IF uMsg == WM_CREATE ;se ainda for a primeira, tem q cirar tudo
        invoke loadImages

        mov eax, offset gameManager 
        invoke CreateThread, NULL, NULL, eax, 0, 0, addr thread1ID 
        invoke CloseHandle, eax 

        mov eax, offset paintThread
        invoke CreateThread, NULL, NULL, eax, 0, 0, addr thread2ID
        invoke CloseHandle, eax
    ;____________________________________________________________________________

    .ELSEIF uMsg == WM_DESTROY ;se o user fechar
        invoke PostQuitMessage,NULL ;fecha
    
    .ELSEIF uMsg == WM_PAINT ;se alguma coisa tiver q ser desenhada
        invoke updateScreen ;desenha
    ;_____________________________________________________________________________
    .ELSEIF uMsg == WM_CHAR ;se a janela receber enter
        ;Enter faz o jogo começar / recomeçar nos menus
        .if (wParam == 13) ; [ENTER]
            .if GAMESTATE == 1 || GAMESTATE == 3 || GAMESTATE == 4
                mov GAMESTATE, 2
            .endif
        .endif

    .ELSEIF uMsg == WM_KEYDOWN ;se o usuario apertou alguma tecla

        .if (wParam == 77h || wParam == 57h || wParam == VK_UP) ;w ou seta pra cima
            print "cima", 13,10
            mov direction, D_TOP

        .elseif (wParam == 61h || wParam == 41h || wParam == VK_LEFT) ;a ou seta pra esquerda
            print "esquerda", 13,10
            mov direction, D_LEFT

        .elseif (wParam == 73h || wParam == 53h || wParam == VK_DOWN) ;s ou seta pra baixo
            print "baixo", 13,10
            mov direction, D_DOWN

        .elseif (wParam == 64h || wParam == 44h || wParam == VK_RIGHT) ;d ou seta pra direita
            print "direita", 13,10
            mov direction, D_RIGHT
        .endif

        .if direction != -1
            invoke changePlayerSpeed, direction
            mov direction, -1
        .endif

;________________________________________________________________________________

    .ELSE ;se n for nada de importante faz o padrão mesmo isso n importa 

        invoke DefWindowProc,_hWnd,uMsg,wParam,lParam
        ret 

    .ENDIF

    xor eax,eax 
    ret 
WndProc endp

;_ END PROCEDURES ______________________________________________________________________

end start
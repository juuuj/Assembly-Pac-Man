; http://win32assembly.programminghorizon.com/tut25.html
; http://win32assembly.programminghorizon.com/tut3.html

.386 
.model flat,stdcall
option casemap:none

include pacman.inc

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

.DATA
ClassName db "PacmanWindowClass",0        ; nome da classe de janela
AppName db "PACMAN",0         

.DATA?
hInstance HINSTANCE ?        ; Instance handle do programa
CommandLine LPSTR ? 

.CODE                ; Here begins our code 
start: 

    invoke GetModuleHandle, NULL            ; get the instance handle of our program. 
                                            ; Under Win32, hmodule==hinstance mov hInstance,eax 
    mov hInstance,eax 

    invoke GetCommandLine                   ; get the command line. You don't have to call this function IF 
                                            ; your program doesn't process the command line. 
    mov CommandLine,eax 

    invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT      ; call the main function 
    invoke ExitProcess, eax                                           ; quit our program. The exit code is returned in eax from WinMain.


; _ PROCEDURES ___________________________________________________________________________

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

    ;Carregando as imagens do pac:
    invoke LoadBitmap, hInstance, 105
    mov P1, eax
    invoke LoadBitmap, hInstance, 106
    mov P2, eax

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
;Função para saber se objetos estão colidindo, guarda no edx
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
;verifica se o pac está parado
isStopped proc addrPlayer:dword
assume edx:ptr player
    mov edx, addrPlayer

.if [edx].playerObj.speed.x == 0  && [edx].playerObj.speed.y == 0
    mov [edx].stopped, 1
.endif

ret
isStopped endp
;______________________________________________________________________________

;______________________________________________________________________________
;decide o background dependendo do que aconteceu
paintBackground proc _hdc:HDC, _hMemDC:HDC, _hMemDC2:HDC

.if GAMESTATE == 0 ;O jogo ainda está carregando
    invoke SelectObject, _hMemDC2, h_loading
    invoke BitBlt, _hMemDC, 0, 0, 800, 600, _hMemDC2, 0, 0, SRCCOPY
.endif

.if GAMESTATE == 1 ;menu inicial
    print "game state1 yeah", 13,10
    invoke SelectObject, _hMemDC2, h_menu
    invoke BitBlt, _hMemDC, 0, 0, 800, 600, _hMemDC2, 0, 0, SRCCOPY
.endif

.if GAMESTATE == 2 ;jogo em si
    print "game state2 yeah", 13,10
    invoke SelectObject, _hMemDC2, h_background
    invoke BitBlt, _hMemDC, 0, 0, 800, 600, _hMemDC2, 0, 0, SRCCOPY
.endif

.if GAMESTATE == 3 ;pac perdeu
    invoke SelectObject, _hMemDC2, game_over
    invoke BitBlt, _hMemDC, 0, 0, 800, 600, _hMemDC2, 0, 0, SRCCOPY
.endif

.if GAMESTATE == 4 ;pac ganhou
    invoke SelectObject, _hMemDC2, p_won
    invoke BitBlt, _hMemDC, 0, 0, 800, 600, _hMemDC2, 0, 0, SRCCOPY
.endif

    ret
paintBackground endp

;______________________________________________________________________________
;pinta a quantidade de vidas na tela
paintLifes proc _hdc:HDC, _hMemDC:HDC, _hMemDC2:HDC
    invoke SelectObject, _hMemDC2, P1 ;a vida tem a imagem do pac man
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
;______________________________________________________________________________
;desenha o pac na tela
paintPlayer proc _hdc:HDC, _hMemDC:HDC, _hMemDC2:HDC

   ;pac 1___________________________________________
        invoke SelectObject, _hMemDC2, P1

        movsx eax, pac.direction
        mov ebx, PAC_SIZE
        mul ebx
        mov ecx, eax

        invoke isStopped, addr pac

    ;________PAC 1 PAINTING________________________________________________________________________

        mov eax, pac.playerObj.pos.x
        mov ebx, pac.playerObj.pos.y
        sub eax, PAC_HALF_SIZE
        sub ebx, PAC_HALF_SIZE

        invoke TransparentBlt, _hMemDC, eax, ebx,\
            PAC_SIZE, PAC_SIZE, _hMemDC2,\
            edx, ecx, PAC_SIZE, PAC_SIZE, 16777215
    ;________________________________________________________________________________
    ret
paintPlayer endp

;________________________________________________________________________________
;desenha os fantasmas na tela
paintGhosts proc _hdc:HDC, _hMemDC:HDC, _hMemDC2

    ;Fantasma 1:
        .if ghost1.afraid == 1 
            invoke SelectObject, _hMemDC2, G0
        .else
            invoke SelectObject, _hMemDC2, G1
        .endif

        mov eax, ghost1.ghostObj.pos.x
        mov ebx, ghost1.ghostObj.pos.y
        sub eax, GHOST_HALF_SIZE_P.x
        sub ebx, GHOST_HALF_SIZE_P.y

        invoke TransparentBlt, _hMemDC, eax, ebx,\
            GHOST_SIZE_POINT.x, GHOST_SIZE_POINT.y, _hMemDC2,\
            0, 0, GHOST_SIZE_POINT.x, GHOST_SIZE_POINT.y, 16777215


;Fantasma 2:

        .if ghost2.afraid == 1 
            invoke SelectObject, _hMemDC2, G0
        .else
            invoke SelectObject, _hMemDC2, G2
        .endif

        mov eax, ghost2.ghostObj.pos.x
        mov ebx, ghost2.ghostObj.pos.y
        sub eax, GHOST_HALF_SIZE_P.x
        sub ebx, GHOST_HALF_SIZE_P.y

        invoke TransparentBlt, _hMemDC, eax, ebx,\
            GHOST_SIZE_POINT.x, GHOST_SIZE_POINT.y, _hMemDC2,\
            0, 0, GHOST_SIZE_POINT.x, GHOST_SIZE_POINT.y, 16777215

;Fantasma 3:

        .if ghost3.afraid == 1 
            invoke SelectObject, _hMemDC2, G0
        .else
            invoke SelectObject, _hMemDC2, G3
        .endif

        mov eax, ghost3.ghostObj.pos.x
        mov ebx, ghost3.ghostObj.pos.y
        sub eax, GHOST_HALF_SIZE_P.x
        sub ebx, GHOST_HALF_SIZE_P.y

        invoke TransparentBlt, _hMemDC, eax, ebx,\
            GHOST_SIZE_POINT.x, GHOST_SIZE_POINT.y, _hMemDC2,\
            0, 0, GHOST_SIZE_POINT.x, GHOST_SIZE_POINT.y, 16777215

;Fantasma 4:

        .if ghost4.afraid == 1 
            invoke SelectObject, _hMemDC2, G0
        .else
            invoke SelectObject, _hMemDC2, G4
        .endif

        mov eax, ghost4.ghostObj.pos.x
        mov ebx, ghost4.ghostObj.pos.y
        sub eax, GHOST_HALF_SIZE_P.x
        sub ebx, GHOST_HALF_SIZE_P.y

        invoke TransparentBlt, _hMemDC, eax, ebx,\
            GHOST_SIZE_POINT.x, GHOST_SIZE_POINT.y, _hMemDC2,\
            0, 0, GHOST_SIZE_POINT.x, GHOST_SIZE_POINT.y, 16777215

    ret
paintGhosts endp

;________________________________________________________________________________
;desenha tudo no mapa
paintMap proc _hdc:HDC, _hMemDC:HDC, _hMemDC2:HDC



    ;________PAREDES________________________________________________________________

        ;parede 1:
        mov eax, wall1.pos.x
        mov ebx, wall1.pos.y

        invoke TransparentBlt, _hMemDC, eax, ebx, WALL_SIZE, WALL_SIZE, _hMemDC2, edx, ecx, WALL_SIZE, WALL_SIZE, 16777215

    ;________COMIDAS_________________________________________________________________

        ;comida 1:
        mov eax, food1.pos.x
        mov ebx, food1.pos.y

        invoke TransparentBlt, _hMemDC, eax, ebx, WALL_SIZE, WALL_SIZE, _hMemDC2, edx, ecx, WALL_SIZE, WALL_SIZE, 16777215

    ;________PÍLULAS_________________________________________________________________

    ret
paintMap endp

;________________________________________________________________________________
;desenha tudo que for necessário de uma vez
updateScreen proc
    LOCAL hMemDC:HDC
    LOCAL hMemDC2:HDC
    LOCAL hBitmap:HDC
    LOCAL hDC:HDC

    invoke BeginPaint, hWnd, ADDR paintstruct
    mov hDC, eax
    invoke CreateCompatibleDC, hDC
    mov hMemDC, eax
    invoke CreateCompatibleDC, hDC ; for double buffering
    mov hMemDC2, eax
    invoke CreateCompatibleBitmap, hDC, WINDOW_SIZE_X, WINDOW_SIZE_Y
    mov hBitmap, eax

    invoke SelectObject, hMemDC, hBitmap

    invoke paintBackground, hDC, hMemDC, hMemDC2

    .if GAMESTATE == 2
        invoke paintPlayer, hDC, hMemDC, hMemDC2
        invoke paintGhosts, hDC, hMemDC, hMemDC2
        invoke paintLifes, hDC, hMemDC, hMemDC2
        invoke paintMap, hDC, hMemDC, hMemDC2
    .endif

    invoke BitBlt, hDC, 0, 0, WINDOW_SIZE_X, WINDOW_SIZE_Y, hMemDC, 0, 0, SRCCOPY

    invoke DeleteDC, hMemDC
    invoke DeleteDC, hMemDC2
    invoke DeleteObject, hBitmap
    invoke EndPaint, hWnd, ADDR paintstruct
;endif

    ret
updateScreen endp

;______________________________________________________________________________

paintThread proc p:DWORD
    .while !over
        invoke Sleep, 17 ; 60 FPS

        invoke InvalidateRect, hWnd, NULL, FALSE

    .endw

    ret
paintThread endp

;______________________________________________________________________________
;função para o personagem se mover, baseado na velocidade
movePlayer proc uses eax addrPlayer:dword
    assume ecx:ptr gameObject
    mov ecx, addrPlayer

    ;Horizontal
    mov eax, [ecx].pos.x
    mov ebx, [ecx].speed.x
    .if bx > 7fh
        or bx, 65280
    .endif
    add eax, ebx
    mov [ecx].pos.x, eax

    ;Vertical
    mov eax, [ecx].pos.y
    mov ebx, [ecx].speed.y
    .if bx > 7fh 
        or bx, 65280
    .endif
    add ax, bx
    mov [ecx].pos.y, eax

    assume ecx:nothing
    ret
movePlayer endp

;______________________________________________________________________________
;função para decidir a direção em que o pac está olhando
updateDirection proc addrPlayer:dword 
assume eax:ptr player
    mov eax, addrPlayer

    mov ebx, [eax].playerObj.speed.x ;ebx é a velocidade horizontal
    mov edx, [eax].playerObj.speed.y ;edx é a velocidade vertical

    .if ebx != 0 || edx != 0
        .if ebx == 0 ;se o horizontal for 0, vai pra cima ou pra baixo verificando o edx
            .if edx > 7fh ;se for negativo, vai pra cima
                mov [eax].direction, D_TOP       
            .else ;se positivo, vai pra baixo
                mov [eax].direction, D_DOWN     
            .endif 
        .elseif ebx > 7fh ;se a velocidade horizontal for negativa, vai pra esquerda
            mov [eax].direction, D_LEFT 
        .else ;se não, vai pra direita
            mov [eax].direction, D_RIGHT  
        .endif
    .endif
    ret
updateDirection endp

;______________________________________________________________________________
;move o fantasma
moveGhost proc uses eax addrGhost:dword
    assume eax:ptr ghost
    mov eax, addrGhost

    mov ebx, [eax].ghostObj.speed.x
    mov ecx, [eax].ghostObj.speed.y

        .if [eax].direction == D_TOP
            add [eax].ghostObj.pos.y, -GHOST_SPEED
        
        .elseif [eax].direction == D_RIGHT
            add [eax].ghostObj.pos.x,  GHOST_SPEED

        .elseif [eax].direction == D_DOWN
            add [eax].ghostObj.pos.y,  GHOST_SPEED

        .elseif [eax].direction == D_LEFT
            add [eax].ghostObj.pos.x,  -GHOST_SPEED
        .endif
    assume eax:nothing
    ret
moveGhost endp
;______________________________________________________________________________
;função para o pac n sair da tela, mas sim voltar pelo outro lado
fixCoordinates proc addrPlayer:dword
assume eax:ptr player
    mov eax, addrPlayer

    .if [eax].playerObj.pos.x > WINDOW_SIZE_X && [eax].playerObj.pos.x < 80000000h
        mov [eax].playerObj.pos.x, 20
    .endif

    .if [eax].playerObj.pos.x <= 10 || [eax].playerObj.pos.x > 80000000h
        mov [eax].playerObj.pos.x, WINDOW_SIZE_X - 20 
    .endif


    .if [eax].playerObj.pos.y > WINDOW_SIZE_Y - 70 && [eax].playerObj.pos.y < 80000000h
        mov [eax].playerObj.pos.y, 20
    .endif

    .if [eax].playerObj.pos.y <= 10 || [eax].playerObj.pos.y > 80000000h
        mov [eax].playerObj.pos.y, WINDOW_SIZE_Y - 80 
    .endif
ret
fixCoordinates endp

;______________________________________________________________________________
;função para o fantasma n sair da tela, mas sim voltar pelo outro lado
fixGhostCoordinates proc addrGhost:dword
assume eax:ptr ghost
    mov eax, addrGhost

    .if [eax].ghostObj.pos.x > WINDOW_SIZE_X && [eax].ghostObj.pos.x < 80000000h
        mov [eax].ghostObj.pos.x, 20                  
    .endif

    .if [eax].ghostObj.pos.x <= 10 || [eax].ghostObj.pos.x > 80000000h
        mov [eax].ghostObj.pos.x, 1180 
    .endif


    .if [eax].ghostObj.pos.y > WINDOW_SIZE_Y - 80 && [eax].ghostObj.pos.y < 80000000h
        mov [eax].ghostObj.pos.y, 20
    .endif

    .if [eax].ghostObj.pos.y <= 10 || [eax].ghostObj.pos.y > 80000000h
        mov [eax].ghostObj.pos.y, WINDOW_SIZE_Y - 90 
    .endif

ret
fixGhostCoordinates endp

;______________________________________________________________________________
;reposiciona tudo no lugar quando o jogo acaba
gameOver proc
    mov pac.playerObj.pos.x, 100
    mov pac.playerObj.pos.y, 350
    
    mov pac.playerObj.speed.x, 0
    mov pac.playerObj.speed.y, 0

    mov pac.stopped, 1

    mov pac.life, 4

    mov pac.direction, D_RIGHT

    mov ghost1.ghostObj.speed.x, 0
    mov ghost1.ghostObj.speed.y, 0
    mov ghost1.ghostObj.pos.x, -100
    mov ghost1.ghostObj.pos.y, -100
    mov ghost1.afraid, 0
    mov ghost1.alive, 1
    mov ghost1.direction, D_RIGHT

    mov ghost2.ghostObj.speed.x, 0
    mov ghost2.ghostObj.speed.y, 0
    mov ghost2.ghostObj.pos.x, -100
    mov ghost2.ghostObj.pos.y, -100
    mov ghost2.afraid, 0
    mov ghost2.alive, 1
    mov ghost2.direction, D_RIGHT

    mov ghost3.ghostObj.speed.x, 0
    mov ghost3.ghostObj.speed.y, 0
    mov ghost3.ghostObj.pos.x, -100
    mov ghost3.ghostObj.pos.y, -100
    mov ghost3.afraid, 0
    mov ghost3.alive, 1
    mov ghost3.direction, D_RIGHT

    mov ghost4.ghostObj.speed.x, 0
    mov ghost4.ghostObj.speed.y, 0
    mov ghost4.ghostObj.pos.x, -100
    mov ghost4.ghostObj.pos.y, -100
    mov ghost4.afraid, 0
    mov ghost4.alive, 1
    mov ghost4.direction, D_RIGHT

    ret
gameOver endp

;______________________________________________________________________________
;função principal para agir de acordo com o gamestate
gameManager proc p:dword
        LOCAL area:RECT

        .if GAMESTATE == 0 ;tela de loading
            invoke Sleep, 3000
            inc GAMESTATE
        .endif

        .while GAMESTATE == 1 ;menu
            invoke Sleep, 30
        .endw

        game: ;verificações constantes do jogo
        .while GAMESTATE == 2 ;jogo
            invoke Sleep, 30

            ;verifica se o pac tocou no fantasma 1
            invoke isColliding, pac.playerObj.pos, ghost1.ghostObj.pos, PAC_SIZE_POINT, GHOST_SIZE_POINT
            .if edx == TRUE
                .if ghost1.afraid == 0 ; se o fantasma matar o pac
                    ;vai para posição de reinício
                    mov pac.playerObj.pos.x, 1120
                    mov pac.playerObj.pos.y, 350

                    dec pac.life ;perde uma vida
                    .if pac.life == 0 ;se for a última morreu
                        invoke gameOver
                        mov GAMESTATE, 3 ;perdeu
                        .continue
                    .endif
                .else ;se o pacman estiver buffado e conseguir matar
                    ;reinicia o fantasma pro meio
                    mov ghost1.ghostObj.pos.x, 1120
                    mov ghost1.ghostObj.pos.y, 350
                    mov ghost1.afraid, 0
                    mov ghost1.alive, 1
                .endif
            .endif

            ;verifica se o pac tocou no fantasma 2
            invoke isColliding, pac.playerObj.pos, ghost2.ghostObj.pos, PAC_SIZE_POINT, GHOST_SIZE_POINT
            .if edx == TRUE
                .if ghost2.afraid == 0 ; se o fantasma matar o pac
                    ;vai para posição de reinício
                    mov pac.playerObj.pos.x, 1120
                    mov pac.playerObj.pos.y, 350

                    dec pac.life ;perde uma vida
                    .if pac.life == 0 ;se for a última morreu
                        invoke gameOver
                        mov GAMESTATE, 3 ;perdeu
                        .continue
                    .endif
                .else ;se o pacman estiver buffado e conseguir matar
                    ;reinicia o fantasma pro meio
                    mov ghost2.ghostObj.pos.x, 1120
                    mov ghost2.ghostObj.pos.y, 350
                    mov ghost2.afraid, 0
                    mov ghost2.alive, 1
                .endif
            .endif

            ;verifica se o pac tocou no fantasma 3
            invoke isColliding, pac.playerObj.pos, ghost3.ghostObj.pos, PAC_SIZE_POINT, GHOST_SIZE_POINT
            .if edx == TRUE
                .if ghost3.afraid == 0 ; se o fantasma matar o pac
                    ;vai para posição de reinício
                    mov pac.playerObj.pos.x, 1120
                    mov pac.playerObj.pos.y, 350

                    dec pac.life ;perde uma vida
                    .if pac.life == 0 ;se for a última morreu
                        invoke gameOver
                        mov GAMESTATE, 3 ;perdeu
                        .continue
                    .endif
                .else ;se o pacman estiver buffado e conseguir matar
                    ;reinicia o fantasma pro meio
                    mov ghost3.ghostObj.pos.x, 1120
                    mov ghost3.ghostObj.pos.y, 350
                    mov ghost3.afraid, 0
                    mov ghost3.alive, 1
                .endif
            .endif

            ;verifica se o pac tocou no fantasma 4
            invoke isColliding, pac.playerObj.pos, ghost4.ghostObj.pos, PAC_SIZE_POINT, GHOST_SIZE_POINT
            .if edx == TRUE
                .if ghost4.afraid == 0 ; se o fantasma matar o pac
                    ;vai para posição de reinício
                    mov pac.playerObj.pos.x, 1120
                    mov pac.playerObj.pos.y, 350

                    dec pac.life ;perde uma vida
                    .if pac.life == 0 ;se for a última morreu
                        invoke gameOver
                        mov GAMESTATE, 3 ;perdeu
                        .continue
                    .endif
                .else ;se o pacman estiver buffado e conseguir matar
                    ;reinicia o fantasma pro meio
                    mov ghost4.ghostObj.pos.x, 1120
                    mov ghost4.ghostObj.pos.y, 350
                    mov ghost4.afraid, 0
                    mov ghost4.alive, 1
                .endif
            .endif

            ;colisão entre o pac e a parede
            invoke isColliding, pac.playerObj.pos, wall1.pos, PAC_SIZE_POINT, WALL_SIZE_POINT
            .if edx == TRUE
                mov pac.playerObj.speed.x, 0
                mov pac.playerObj.speed.y, 0
                mov pac.stopped, 1 ;n sei pra q a gnt vai usar isso mas sla né
            .endif

            ;Talvez seja melhor pensar em um jeito melhor de fazer as paredes, pq vai ter q ter uma colisão de cada fantasma com cada parede e essa merda vai ficar enorme 
            ;TODO: colisão entre pac e bolinhas de ponto e pílulas pra ficar brabo

            ;colisão entre o pac e as comidas
            invoke isColliding, pac.playerObj.pos, food1.pos, PAC_SIZE_POINT, FOOD_SIZE_POINT
                .if edx == TRUE
                    add score, 10 ;ganha pontos
                    add food_left, -1
                    .if food_left == 0 ;se as comidas acabarem
                        mov GAMESTATE, 4 ;ganhou
                    .endif
                .endif

            ;colisão entre o pac e as pílulas
            invoke isColliding, pac.playerObj.pos, food1.pos, PAC_SIZE_POINT, FOOD_SIZE_POINT
                .if edx == TRUE
                    add score, 30 ;ganha pontos
                    mov ghost1.afraid, 1
                    mov ghost2.afraid, 1
                    mov ghost3.afraid, 1
                    mov ghost4.afraid, 1
                    ;aqui vai ter q ter um timer usando o pill1.time mas eu n faço ideia de como faz isso foi mal
                    mov ghost1.afraid, 0
                    mov ghost2.afraid, 0
                    mov ghost3.afraid, 0
                    mov ghost4.afraid, 0
                .endif
        .endw 

        .while GAMESTATE == 3 || GAMESTATE == 4
            invoke Sleep, 30
        .endw

        jmp game
ret
gameManager endp

;_____________________________________________________________________________________________________________________________

;muda a velocidade do pac dependendo da tecla q foi apertada
changePlayerSpeed proc uses eax addrPlayer : DWORD, direction : BYTE, keydown : BYTE ;provavelmente pd tirar esse keydown mas vou deixar por enquanto so pra ter ctz
    assume eax: ptr player
    mov eax, addrPlayer

    .if direction == 0 ; w / seta pra cima
        mov [eax].playerObj.speed.y, -PAC_SPEED
        mov [eax].stopped, 0
    .elseif direction == 1 ; s / seta pra baixo
        mov [eax].playerObj.speed.y, PAC_SPEED
        mov [eax].stopped, 0
    .elseif direction == 2 ; a / seta pra esquerda
        mov [eax].playerObj.speed.x, -PAC_SPEED
        mov [eax].stopped, 0
    .elseif direction == 3 ; d / seta pra direita
        mov [eax].playerObj.speed.x, PAC_SPEED
        mov [eax].stopped, 0
    .endif


    assume ecx: nothing
    ret
changePlayerSpeed endp

; _ WINMAIN __________________________________________________________________________________________________________________
;cria a janela e faz os procedimentos padrão do windows
WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD 
    LOCAL clientRect:RECT
    LOCAL wc:WNDCLASSEX                                               ; create local variables on stack 
    LOCAL msg:MSG 

    mov   wc.cbSize,SIZEOF WNDCLASSEX ; fill values in members of wc 
    mov   wc.style, CS_BYTEALIGNWINDOW
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 

    push  hInstance 
    pop   wc.hInstance 
    mov   wc.hbrBackground, NULL ; no background
    mov   wc.lpszMenuName,NULL 
    mov   wc.lpszClassName ,OFFSET ClassName 

    invoke LoadIcon, NULL, IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 

    invoke LoadCursor, NULL,IDC_ARROW 
    mov   wc.hCursor, eax 

    invoke RegisterClassEx, addr wc ; register our window class 

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
    invoke ShowWindow, hWnd, CmdShow                                  ; display our window on desktop 
    invoke UpdateWindow, hWnd                                         ; refresh the client area

    .WHILE TRUE                                                       ; Enter message loop 
                invoke GetMessage, ADDR msg,NULL,0,0 
                .BREAK .IF (!eax)
                invoke TranslateMessage, ADDR msg 
                invoke DispatchMessage, ADDR msg 
    .ENDW 
    mov     eax,msg.wParam                                            ; return exit code in eax 
    ret 
WinMain endp

WndProc proc _hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    LOCAL direction : BYTE
    LOCAL keydown   : BYTE
    mov direction, -1
    mov keydown, -1

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
    .ELSEIF uMsg == WM_CHAR ;se a janela receber um char (so enter no caso sla n entendi isso direito)
        ;Enter faz o jogo começar / recomeçar nos menus
        .if (wParam == 13) ; [ENTER]
            .if GAMESTATE == 1 || GAMESTATE == 3 || GAMESTATE == 4
                mov GAMESTATE, 2
            .endif
        .endif

    .ELSEIF uMsg == WM_KEYUP ;se soltou a tecla (acho q a gnt n vai usar ent provavelmente eu to comentando isso aqui a toa)
    ;realmente, aperentemente n vai fazer nada pro nosso codigo mas dps a gnt ve se pode tirar mesmo

        .if (wParam == 77h || wParam == 57h || wParam == VK_UP) ;w ou seta pra cima
            mov keydown, FALSE
            mov direction, 0

        .elseif (wParam == 61h || wParam == 41h || wParam == VK_LEFT) ;a ou seta pra esquerda
            mov keydown, FALSE
            mov direction, 2

        .elseif (wParam == 73h || wParam == 53h || wParam == VK_DOWN) ;s ou seta pra baixo
            mov keydown, FALSE
            mov direction, 1

        .elseif (wParam == 64h || wParam == 44h || wParam == VK_RIGHT) ;d ou seta pra direita
            mov keydown, FALSE
            mov direction, 3
        .endif

        .if direction != -1
            invoke changePlayerSpeed, ADDR pac, direction, keydown
            mov direction, -1
            mov keydown, -1
        .endif

    ;.endif
;________________________________________________________________________________

    .ELSEIF uMsg == WM_KEYDOWN ;apertou uma tecla, tem q mudar a direcao

        ;esses ifs são usados pra decidir os parâmetros da movimentação e mover embaixo
        .if (wParam == 57h || wParam == VK_UP) ; w ou seta pra cima
            mov keydown, TRUE
            mov direction, 0

        .elseif (wParam == 53h || wParam == VK_DOWN) ; s ou seta pra baixo
            mov keydown, TRUE
            mov direction, 1

        .elseif (wParam == 41h || wParam == VK_LEFT) ; a ou seta pra esquerda
            mov keydown, TRUE
            mov direction, 2

        .elseif (wParam == 44h || wParam == VK_RIGHT) ; d ou seta pra direita
            mov keydown, TRUE
            mov direction, 3
        .endif

        .if direction != -1
            invoke changePlayerSpeed, ADDR pac, direction, keydown ;aqui q ele realmente move o personagem
            mov direction, -1
            mov keydown, -1
        .endif

    .ELSE ;se n for nada de importante faz o padrão mesmo isso n importa 

        invoke DefWindowProc,_hWnd,uMsg,wParam,lParam     ; Default message processing 
        ret 

    .ENDIF

    xor eax,eax 
    ret 
WndProc endp

;_ END PROCEDURES ______________________________________________________________________

end start
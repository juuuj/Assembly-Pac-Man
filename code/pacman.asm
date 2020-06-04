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


 ;   invoke LoadLibrary,addr Libname         ; splash screen reasons 
 ;       .if eax!=NULL 
 ;           invoke FreeLibrary,eax 
 ;       .endif
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

    ;Loading background bitmap
    invoke LoadBitmap, hInstance, 169 ;TODO: fazer as imagens
    mov h_background, eax

    invoke LoadBitmap, hInstance, 170 ;TODO: fazer as imagens
    mov h_enterprise, eax

    invoke LoadBitmap, hInstance, 171 ;TODO: fazer as imagens
    mov h_menu, eax

    ;Loading Ghosts' Bitmaps:
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

    ;Loading Player's Bitmaps:
    invoke LoadBitmap, hInstance, 105
    mov P1, eax
    invoke LoadBitmap, hInstance, 106
    mov P2, eax

    ;Loading winner's Bitmaps:
    invoke LoadBitmap, hInstance, 300
    mov p1_won, eax
    invoke LoadBitmap, hInstance, 301
    mov p2_won, eax

    ;Loading Heart Bitmaps:
    invoke LoadBitmap, hInstance, 200
    mov HT_heart1, eax
    invoke LoadBitmap, hInstance, 201
    mov HT_heart2, eax

    ret
loadImages endp

;______________________________________________________________________________

isColliding proc obj1Pos:point, obj2Pos:point, obj1Size:point, obj2Size:point

    ;.if obj1Pos.x < obj2Pos.x + obj2Size.x && \
    ;    obj1Pos.x + obj1Size.x > obj2Pos.x && \
    ;    obj1Pos.y < obj2Pos.y + obj2Size.y && \
    ;    obj1Pos.y + obj1Size.y > obj2Pos.y
    ;    mov eax, TRUE
    ;.else
    ;    mov eax, FALSE
    ;.endif
    
    push eax
    push ebx

    mov eax, obj1Pos.x
    add eax, obj1Size.x ; eax = obj1Pos.x + obj1Size.x
    mov ebx, obj2Pos.x
    add ebx, obj2Size.x ; ebx = obj2Pos.x + obj2Size.x

    .if obj1Pos.x < ebx && eax > obj2Pos.x
        mov eax, obj1Pos.y
        add eax, obj1Size.y ; eax = obj1Pos.y + obj1Size.y
        mov ebx, obj2Pos.y
        add ebx, obj2Size.y ; ebx = obj2Pos.y + obj2Size.y
        
        .if obj1Pos.y < ebx && eax > obj2Pos.y
            ; the objects are colliding
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
;n entendi
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
;TODO: fazer as imagens e planejar essa parte
paintBackground proc _hdc:HDC, _hMemDC:HDC, _hMemDC2:HDC

.if GAMESTATE == 0
    invoke SelectObject, _hMemDC2, h_enterprise
    invoke BitBlt, _hMemDC, 0, 0, 1200, 800, _hMemDC2, 0, 0, SRCCOPY
.endif

.if GAMESTATE == 1
    invoke SelectObject, _hMemDC2, h_menu
    invoke BitBlt, _hMemDC, 0, 0, 1200, 800, _hMemDC2, 0, 0, SRCCOPY
.endif

.if GAMESTATE == 2
    invoke SelectObject, _hMemDC2, h_background
    invoke BitBlt, _hMemDC, 0, 0, 1200, 800, _hMemDC2, 0, 0, SRCCOPY
.endif

.if GAMESTATE == 3 ; player 1 won
    invoke SelectObject, _hMemDC2, p1_won
    invoke BitBlt, _hMemDC, 0, 0, 1200, 800, _hMemDC2, 0, 0, SRCCOPY
.endif

.if GAMESTATE == 4 ; player 2 won
    invoke SelectObject, _hMemDC2, p2_won
    invoke BitBlt, _hMemDC, 0, 0, 1200, 800, _hMemDC2, 0, 0, SRCCOPY
.endif

    ret
paintBackground endp

;______________________________________________________________________________

paintHearts proc _hdc:HDC, _hMemDC:HDC, _hMemDC2:HDC
    ; PLAYER 1
    invoke SelectObject, _hMemDC2, HT_heart1
    mov ebx, 0
    movzx ecx, player.life
    .while ebx != ecx
        mov eax, HEART_SIZE
        mul ebx
        push ecx
        invoke TransparentBlt, _hMemDC, eax, 0,\
                HEART_SIZE, HEART_SIZE, _hMemDC2,\
                0, 0, HEART_SIZE, HEART_SIZE, 16777215
        ;invoke BitBlt, _hdc, eax, 0, HEART_SIZE, HEART_SIZE, _hMemDC, 0, 0, SRCCOPY 
        pop ecx
        inc ebx
    .endw

    ; PLAYER 2
    ;invoke SelectObject, _hMemDC2, HT_heart2
    ;;mov ebx, 1
    ;movzx ecx, player2.life
    ;inc ecx
    ;.while ebx != ecx
    ;    mov eax, HEART_SIZE
    ;    mul ebx
    ;    push ecx
    ;    mov edx, WINDOW_SIZE_X
    ;    sub edx, eax
    ;    invoke TransparentBlt, _hMemDC, edx, 0,\
    ;            HEART_SIZE, HEART_SIZE, _hMemDC2,\
    ;            0, 0, HEART_SIZE, HEART_SIZE, 16777215
    ;    pop ecx
    ;    inc ebx
    ;.endw

    ret
paintHearts endp
;______________________________________________________________________________

paintPlayers proc _hdc:HDC, _hMemDC:HDC, _hMemDC2:HDC

   ;PLAYER 1___________________________________________
        invoke SelectObject, _hMemDC2, p1_spritesheet

        movsx eax, player1.direction
        mov ebx, PLAYER_SIZE
        mul ebx
        mov ecx, eax

        invoke isStopped, addr player1

        ;.if player1.stopped == 1
        ;    mov edx, 0
        ;.if player1.dashsequence == 0
        ;    movsx eax, player1.walksequence
        ;    mov ebx, PLAYER_SIZE               ; se for mudar hitbox, essa e a largura
        ;    mul ebx
        ;    mov edx, eax
        ;.else
        ;    movsx eax, player1.dashsequence
        ;    mov ebx, PLAYER_SIZE               ; se for mudar hitbox, essa e a largura
        ;    mul ebx
        ;    mov edx, eax
        ;.endif

    ;________PLAYER 1 PAINTING________________________________________________________________________

        mov eax, player.playerObj.pos.x
        mov ebx, player.playerObj.pos.y
        sub eax, PLAYER_HALF_SIZE
        sub ebx, PLAYER_HALF_SIZE

        ;invoke BitBlt, _hdc, eax, ebx, PLAYER_SIZE, PLAYER_SIZE, _hMemDC, edx, ecx, SRCCOPY 
        invoke TransparentBlt, _hMemDC, eax, ebx,\
            PLAYER_SIZE, PLAYER_SIZE, _hMemDC2,\
            edx, ecx, PLAYER_SIZE, PLAYER_SIZE, 16777215
    ;________________________________________________________________________________
    ret
paintPlayers endp

;________________________________________________________________________________

paintGhosts proc _hdc:HDC, _hMemDC:HDC, _hMemDC2

    ;________GHOST 1 PAINTING_____________________________________________________________

        .if ghost1.afraid == 1 
            ;invoke wsprintf, ADDR buffer, ADDR test_header_format, 0
            ;invoke MessageBox, NULL, ADDR buffer, ADDR msgBoxTitle, MB_OKCANCEL
            invoke SelectObject, _hMemDC2, G0
            ;invoke SelectObject, _hMemDC, A1_left
        .else
            invoke SelectObject, _hMemDC2, G1
        .endif

        mov eax, ghost1.ghotstObj.pos.x
        mov ebx, ghotst1.ghotstObj.pos.y
        sub eax, GHOST_HALF_SIZE_P.x
        sub ebx, GHOST_HALF_SIZE_P.y

        invoke TransparentBlt, _hMemDC, eax, ebx,\
            GHOST_SIZE_POINT.x, GHOST_SIZE_POINT.y, _hMemDC2,\
            0, 0, GHOST_SIZE_POINT.x, GHOST_SIZE_POINT.y, 16777215
        ;invoke BitBlt, _hdc, eax, ebx, ARROW_SIZE_POINT.x, ARROW_SIZE_POINT.y, _hMemDC, 0, 0, SRCCOPY 


;________GHOST 2 PAINTING_____________________________________________________________

        .if ghost2.afraid == 1 
            invoke SelectObject, _hMemDC2, G0
        .else
            invoke SelectObject, _hMemDC2, G2
        .endif

        mov eax, ghost2.ghotstObj.pos.x
        mov ebx, ghotst2.ghotstObj.pos.y
        sub eax, GHOST_HALF_SIZE_P.x
        sub ebx, GHOST_HALF_SIZE_P.y

        invoke TransparentBlt, _hMemDC, eax, ebx,\
            GHOST_SIZE_POINT.x, GHOST_SIZE_POINT.y, _hMemDC2,\
            0, 0, GHOST_SIZE_POINT.x, GHOST_SIZE_POINT.y, 16777215

;________GHOST 3 PAINTING_____________________________________________________________

        .if ghost3.afraid == 1 
            invoke SelectObject, _hMemDC3, G0
        .else
            invoke SelectObject, _hMemDC3, G3
        .endif

        mov eax, ghost3.ghotstObj.pos.x
        mov ebx, ghotst3.ghotstObj.pos.y
        sub eax, GHOST_HALF_SIZE_P.x
        sub ebx, GHOST_HALF_SIZE_P.y

        invoke TransparentBlt, _hMemDC, eax, ebx,\
            GHOST_SIZE_POINT.x, GHOST_SIZE_POINT.y, _hMemDC2,\
            0, 0, GHOST_SIZE_POINT.x, GHOST_SIZE_POINT.y, 16777215

;________GHOST 4 PAINTING_____________________________________________________________

        .if ghost4.afraid == 1 
            invoke SelectObject, _hMemDC2, G0
        .else
            invoke SelectObject, _hMemDC2, G4
        .endif

        mov eax, ghost4.ghotstObj.pos.x
        mov ebx, ghotst4.ghotstObj.pos.y
        sub eax, GHOST_HALF_SIZE_P.x
        sub ebx, GHOST_HALF_SIZE_P.y

        invoke TransparentBlt, _hMemDC, eax, ebx,\
            GHOST_SIZE_POINT.x, GHOST_SIZE_POINT.y, _hMemDC2,\
            0, 0, GHOST_SIZE_POINT.x, GHOST_SIZE_POINT.y, 16777215

    ret
paintGhosts endp

;________________________________________________________________________________

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
        invoke paintHearts, hDC, hMemDC, hMemDC2
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

        ;invoke updateScreen

        invoke InvalidateRect, hWnd, NULL, FALSE

    .endw

    ret
paintThread endp

;______________________________________________________________________________

movePlayer proc uses eax addrPlayer:dword               ; updates a gameObject position based on its speed
    assume ecx:ptr gameObject
    mov ecx, addrPlayer

    ; X AXIS ______________
    mov eax, [ecx].pos.x
    mov ebx, [ecx].speed.x
    .if bx > 7fh
        or bx, 65280    ; if negative
    .endif
    add eax, ebx
    mov [ecx].pos.x, eax

    ; Y AXIS ______________
    mov eax, [ecx].pos.y
    mov ebx, [ecx].speed.y
    .if bx > 7fh 
        or bx, 65280    ; if negative
    .endif
    add ax, bx
    mov [ecx].pos.y, eax

    assume ecx:nothing
    ret
movePlayer endp

;______________________________________________________________________________


updateDirection proc addrPlayer:dword     ; updates direction based on players axis's speed
assume eax:ptr player
    mov eax, addrPlayer

    mov ebx, [eax].playerObj.speed.x      ; player's x axis 
    mov edx, [eax].playerObj.speed.y      ; player's y axis

    .if ebx != 0 || edx != 0
        .if ebx == 0                                 ; if x axis = 0 then:
            .if edx > 7fh                                  ; if y axis < 0
                mov [eax].direction, D_TOP       
            .else                                          ;    y axis > 0
                mov [eax].direction, D_DOWN     
            .endif 
        .elseif ebx > 7fh                             ; if x axis > 0
            .if edx == 0                                    ; if y axis = 0
                mov [eax].direction, D_LEFT            ; if y axis < 0
            .endif    
        .else                                          ; if x axis < 0
            .if edx == 0                                    ; if y axis = 0
                mov [eax].direction, D_RIGHT  
        .endif
    .endif
    ret
updateDirection endp

;______________________________________________________________________________

moveGhost proc uses eax addrGhost:dword               ; updates a gameObject position based on its speed
    assume eax:ptr ghost
    mov eax, addrGhost

    mov ebx, [eax].ghostObj.speed.x
    mov ecx, [eax].ghostObj.speed.y

        .if [eax].direction == D_TOP
            add [eax].ghostObj.pos.y, -GHOST_SPEED
            sub [eax].remainingDistance, GHOST_SPEED
        
        .elseif [eax].direction == D_RIGHT
            add [eax].ghostObj.pos.x,  GHOST_SPEED
            sub [eax].remainingDistance, GHOST_SPEED

        .elseif [eax].direction == D_DOWN
            add [eax].ghostObj.pos.y,  GHOST_SPEED
            sub [eax].remainingDistance, GHOST_SPEED

        .elseif [eax].direction == D_LEFT
            add [eax].ghostObj.pos.x,  -GHOST_SPEED
            sub [eax].remainingDistance, GHOST_SPEED
        .endif
    assume eax:nothing
    ret
moveGhost endp
;______________________________________________________________________________

fixCoordinates proc addrPlayer:dword
assume eax:ptr player
    mov eax, addrPlayer

    .if [eax].playerObj.pos.x > WINDOW_SIZE_X && [eax].playerObj.pos.x < 80000000h
        mov [eax].playerObj.pos.x, 20                   ;sorry
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

fixGhostCoordinates proc addrGhost:dword
assume eax:ptr ghost
    mov eax, addrGhost
    
.if [eax].onGround == 0
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
.endif
ret
fixGhostCoordinates endp

;______________________________________________________________________________

gameOver proc
    mov player.playerObj.pos.x, 100
    mov player.playerObj.pos.y, 350
    
    mov player.playerObj.speed.x, 0
    mov player.playerObj.speed.y, 0

    mov player.stopped, 1

    mov player.life, 4

    mov player.direction, D_RIGHT

    mov ghost1.ghostObj.speed.x, 0
    mov ghost1.ghostObj.speed.y, 0
    mov ghost1.ghostObj.pos.x, -100
    mov ghost1.ghostObj.pos.y, -100
    mov ghost1.afraid, 0
    mov ghost1.alive, 1
    mov ghost1.direction, D_RIGHT

    ret
gameOver endp

;______________________________________________________________________________

gameManager proc p:dword
        LOCAL area:RECT
        
        .if GAMESTATE == 0
            invoke Sleep, 3000
            inc GAMESTATE
        .endif

        .while GAMESTATE == 1
            invoke Sleep, 30
        .endw

        game:
        .while GAMESTATE == 2
            invoke Sleep, 30

            invoke isColliding, player.playerObj.pos, ghost1.ghostObj.pos, PLAYER_SIZE_POINT, GHOST_SIZE_POINT
            .if edx == TRUE
                .if ghost1.afraid == 0
                    mov player.playerObj.pos.x, 1120 ;posição de reinício
                    mov player.playerObj.pos.y, 350
                    dec player.life
                    .if player.life == 0
                        invoke gameOver
                        mov GAMESTATE, 3 ; player lost
                        .continue
                    .endif
                .else ;fantasma tem q morrer
                    mov player.ghostObj.pos.x, 1120 ;posição de reinício
                    mov player.ghostObj.pos.y, 350
                    mov ghost1.afraid, 0
                    mov ghost1.alive, 0
                    invoke Sleep, 4000
                    mov ghost1.alive, 1
                .endif
            .endif

            ;TODO: Colisão entre pac e fantasma com a parede

        .while GAMESTATE == 3 || GAMESTATE == 4
            invoke Sleep, 30
        .endw

        jmp game
ret
gameManager endp

;_____________________________________________________________________________________________________________________________


changePlayerSpeed proc uses eax addrPlayer : DWORD, direction : BYTE, keydown : BYTE
    assume eax: ptr player
    mov eax, addrPlayer

    ;TODO: checar se ele n ta colidindo c a parede
    .if keydown == FALSE ;ele n ta se movendo (provavelmente n vai mudar nada mas dps a gnt testa sem essa merda)
        .if direction == 0 ; w
            mov [eax].playerObj.speed.y, -PLAYER_SPEED
            mov [eax].stopped, 0
        .elseif direction == 1 ; s
            mov [eax].playerObj.speed.y, PLAYER_SPEED
            mov [eax].stopped, 0
        .elseif direction == 2 ; a
            mov [eax].playerObj.speed.x, -PLAYER_SPEED
            mov [eax].stopped, 0
        .elseif direction == 3 ; d
            mov [eax].playerObj.speed.x, PLAYER_SPEED
            mov [eax].stopped, 0
        .endif
    .else
        .if direction == 0 ; w
            mov [eax].playerObj.speed.y, -PLAYER_SPEED
            mov [eax].stopped, 0
        .elseif direction == 1 ; s
            mov [eax].playerObj.speed.y, PLAYER_SPEED
            mov [eax].stopped, 0
        .elseif direction == 2 ; a
            mov [eax].playerObj.speed.x, -PLAYER_SPEED
            mov [eax].stopped, 0
        .elseif direction == 3 ; d
            mov [eax].playerObj.speed.x, PLAYER_SPEED
            mov [eax].stopped, 0
        .endif
    .endif

    assume ecx: nothing
    ret
changePlayerSpeed endp



;_____________________________________________________________________________________________________________________________
;_____________________________________________________________________________________________________________________________
;_____________________________________________________________________________________________________________________________

; _ WINMAIN __________________________________________________________________________________________________________________
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


    .IF uMsg == WM_CREATE
        invoke loadImages

        mov eax, offset gameManager 
        invoke CreateThread, NULL, NULL, eax, 0, 0, addr thread1ID 
        invoke CloseHandle, eax 

        mov eax, offset paintThread
        invoke CreateThread, NULL, NULL, eax, 0, 0, addr thread2ID
        invoke CloseHandle, eax
    ;____________________________________________________________________________

    .ELSEIF uMsg == WM_DESTROY                                        ; if the user closes our window 
        invoke PostQuitMessage,NULL                                   ; quit our application 
    
    .ELSEIF uMsg == WM_PAINT
        invoke updateScreen
    ;_____________________________________________________________________________
    .ELSEIF uMsg == WM_CHAR
        ;mov eax, offset gameManager
        ;invoke CreateThread, NULL, NULL, eax, 0, 0, addr threadID 
        ;invoke CloseHandle, eax
        .if (wParam == 13) ; [ENTER]
            .if GAMESTATE == 1 || GAMESTATE == 3 || GAMESTATE == 4
                mov GAMESTATE, 2
            .endif
        .endif

    .ELSEIF uMsg == WM_KEYUP
    ; PLAYER 1 ____________________________________________________________________
    ;.if player1.dashsequence == 0

        ; TODO: FAZER VARIAVEL QUE GUARDA SE O KEYUP FOI APERTADO OU NAO

        .if (wParam == 77h || wParam == 57h || wParam == VK_UP) ;w
            ;.if (player1.playerObj.speed.y > 7fh) 
            ;    mov player1.playerObj.speed.y, 0 
            ;.endif
            mov keydown, FALSE
            mov direction, 0

        .elseif (wParam == 61h || wParam == 41h || wParam == VK_LEFT) ;a
            ;.if (player1.playerObj.speed.x > 7fh) 
            ;    mov player1.playerObj.speed.x, 0 
            ;.endif
            mov keydown, FALSE
            mov direction, 1

        .elseif (wParam == 73h || wParam == 53h || wParam == VK_DOWN) ;s
            ;.if (player1.playerObj.speed.y < 80h) 
            ;    mov player1.playerObj.speed.y, 0 
            ;.endif
            mov keydown, FALSE
            mov direction, 2

        .elseif (wParam == 64h || wParam == 44h || wParam == VK_LEFT) ;d
            ;.if (player1.playerObj.speed.x < 80h) 
            ;    mov player1.playerObj.speed.x, 0 
            ;.endif
            mov keydown, FALSE
            mov direction, 3

        .endif

        .if direction != -1
            invoke changePlayerSpeed, ADDR player1, direction, keydown
            mov direction, -1
            mov keydown, -1
        .endif

    ;.endif
;________________________________________________________________________________
;________________________________________________________________________________

    .ELSEIF uMsg == WM_KEYDOWN

    ;___________________PLAYER 1 MOVEMENT KEYS____________________________________
    ;.if player1.dashsequence == 0
        .if (wParam == 57h || wParam == VK_UP) ; w
            ;mov player1.playerObj.speed.y, -PLAYER_SPEED
            ;mov player1.stopped, 0
            mov keydown, TRUE
            mov direction, 0

        .elseif (wParam == 53h || wParam == VK_DOWN) ; s
            ;mov player1.playerObj.speed.y, PLAYER_SPEED
            ;mov player1.stopped, 0
            mov keydown, TRUE
            mov direction, 1

        .elseif (wParam == 41h || wParam == VK_LEFT) ; a
            ;mov player1.playerObj.speed.x, -PLAYER_SPEED
            ;mov player1.stopped, 0
            mov keydown, TRUE
            mov direction, 2

        .elseif (wParam == 44h || wParam == VK_RIGHT) ; d
            ;mov player1.playerObj.speed.x, PLAYER_SPEED
            ;mov player1.stopped, 0
            mov keydown, TRUE
            mov direction, 3
        .endif

        .if direction != -1
            invoke changePlayerSpeed, ADDR player1, direction, keydown
            mov direction, -1
            mov keydown, -1
        .endif

    .ELSE   

        invoke DefWindowProc,_hWnd,uMsg,wParam,lParam                  ; Default message processing 
        ret 

    .ENDIF

    xor eax,eax 
    ret 
WndProc endp

;_ END PROCEDURES ______________________________________________________________________

end start
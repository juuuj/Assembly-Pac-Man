include \masm32\include\masm32rt.inc
include \masm32\include\msimg32.inc

;include \masm32\include\windows.inc 
;include \masm32\include\user32.inc 
;include \masm32\include\kernel32.inc 
;include \masm32\include\gdi32.inc
;include C:\masm32\include\gdi32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\msimg32.lib
;includelib C:\masm32\lib\gdi32.lib   ; pode muda depois so fiz isso pra consegui usa em casa

;include C:\masm32\include\windows.inc
;include C:\masm32\include\masm32.inc
;include C:\masm32\include\gdi32.inc
;include C:\masm32\include\user32.inc
;include C:\masm32\include\kernel32.inc
;include C:\masm32\include\Comctl32.inc
;include C:\masm32\include\comdlg32.inc
;include C:\masm32\include\shell32.inc
;include C:\masm32\include\msimg32.inc

;includelib C:\masm32\lib\masm32.lib
;includelib C:\masm32\lib\gdi32.lib
;includelib C:\masm32\lib\user32.lib
;includelib C:\masm32\lib\kernel32.lib
;includelib C:\masm32\lib\Comctl32.lib
;includelib C:\masm32\lib\comdlg32.lib
;includelib C:\masm32\lib\shell32.lib
;includelib C:\masm32\lib\msimg32.lib

point struct 
    x dd 0      
    y dd 0
point ends

gameObject struct
    pos      point <>
    speed    point <> ; horizontal and vertical speeds
gameObject ends

player struct
    playerObj       gameObject <>
    stopped               BYTE 0
    life                  BYTE 4
    direction             BYTE 0
player ends

ghost struct
    ghostObj          gameObject <>
    afraid            BYTE  0
    alive             BYTE  1
    direction         BYTE  0    
ghost ends                                                      
                      


.CONST
    WINDOW_SIZE_X EQU 800
    WINDOW_SIZE_Y EQU 600

    D_RIGHT       EQU 0 
    D_TOP         EQU 1  
    D_LEFT        EQU 2     
    D_DOWN        EQU 3

    PLAYER_SIZE      EQU 32
    PLAYER_HALF_SIZE EQU PLAYER_SIZE / 2

    GHOST_SIZE       EQU 32
    GHOST_HALF_SIZE EQU GHOST_SIZE / 2

    HEART_SIZE    EQU 32

    PLAYER_SPEED  EQU 6
    GHOST_SPEED   EQU 6

.DATA
    big_buffer  db 65536 dup(?)
                db 65536 dup(?)
                db 65536 dup(?)

    paintstruct        PAINTSTRUCT <>

    PLAYER_SIZE_POINT  point <32,32>
    GHOST_SIZE_POINT   point<32,32>

    ;Background bitmap:
    h_background        dd 0
    h_enterprise        dd 0
    h_menu              dd 0

    ; Player 1 spritesheet
    ;p1_spritesheet    dd 0
    ; Ghost spritesheet
    ;ghost_spritesheet dd 0

    ;Pacman Bitmaps:
    P1    dd 0
    P2    dd 0

    ;Ghost Bitmaps:
    G0      dd 0
    G1      dd 0
    G2      dd 0
    G3      dd 0
    G4      dd 0

    ;Player won
    p_won            dd 0

    ;Heart Bitmap:
    HT_heart1         dd 0

    test_header_format  db  "A: %d",13,10,0
    buffer              db 256 dup(?)
    msgBoxTitle         db "Testing",0

    over byte 0                                ; control game state (occuring or terminated)

    ; Players
    player player <<<100,350>,  <0,0>>, 0, 4, D_RIGHT>  ; dash initialized as 8 because 0 to 7 are directions, so 8 is the same as null 

    ;;TODO: inicializacao dos fantasmas
    ghost1 ghost <<<100,350>,  <0,0>>, 0, 1, D_RIGHT>
    ghost2 ghost <<<200,350>,  <0,0>>, 0, 1, D_RIGHT>
    ghost3 ghost <<<300,350>,  <0,0>>, 0, 1, D_RIGHT>
    ghost4 ghost <<<400,350>,  <0,0>>, 0, 1, D_RIGHT>
    
    RIGHTARROW            BYTE 0
    
    GAMESTATE             BYTE 0

.DATA?
    hWnd HWND ?
    thread1ID DWORD ?
    thread2ID DWORD ?

    
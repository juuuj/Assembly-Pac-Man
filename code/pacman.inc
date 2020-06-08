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

;struct que é usada para definir coisas com x e y (posição e velocidade)
point struct 
    x dd 0      
    y dd 0
point ends

;atributos que todo objeto tem, serve como uma classe mãe
gameObject struct
    pos      point <>
    speed    point <>
gameObject ends

;classe do player
player struct
    playerObj       gameObject <>
    stopped               BYTE 0
    life                  BYTE 4
    direction             BYTE 0
player ends

;fantasma
ghost struct
    ghostObj          gameObject <>
    afraid            BYTE  0
    alive             BYTE  1
    direction         BYTE  0    
ghost ends                 

;parede
wall struct
    pos         point<>
wall ends

food struct
    pos         point<>
    points      dd 0
food ends

pill struct
    pos         point<>
    points      dd 0
    time        dd 0
pill ends


.CONST
    ;tamanho da janela
    WINDOW_SIZE_X EQU 800
    WINDOW_SIZE_Y EQU 600

    ;define as direções, pra poder entender o código mais fácilmente nessa linguagem porca
    D_RIGHT       EQU 0 
    D_TOP         EQU 1  
    D_LEFT        EQU 2     
    D_DOWN        EQU 3

    ;tamanhos de cada objeto:
    PAC_SIZE      EQU 32
    PAC_HALF_SIZE EQU PAC_SIZE / 2

    GHOST_SIZE       EQU 32
    GHOST_HALF_SIZE EQU GHOST_SIZE / 2

    LIFE_SIZE    EQU 32

    ;tem q testar e talvez mudar dps:
    WALL_SIZE EQU 16 
    FOOD_SIZE EQU 8
    PILL_SIZE EQU 8

    PAC_SPEED  EQU 6
    GHOST_SPEED   EQU 6

.DATA
    big_buffer  db 65536 dup(?)
                db 65536 dup(?)
                db 65536 dup(?)

    paintstruct        PAINTSTRUCT <>

    PAC_SIZE_POINT      point <32,32>
    GHOST_SIZE_POINT    point <32,32>
    GHOST_HALF_SIZE_P   point <16,16>
    WALL_SIZE_POINT     point <16,16>
    FOOD_SIZE_POINT     point <8,8>
    PILL_SIZE_POINT     point <8,8>

    score       dd 0
    food_left   dd 1

    ;inicializando as variáveis que vão guardar as imagens (vazias por enquanto):
    h_background        dd 0
    h_loading           dd 0
    h_menu              dd 0
    P1      dd 0
    P2      dd 0
    G0      dd 0
    G1      dd 0
    G2      dd 0
    G3      dd 0
    G4      dd 0
    p_won               dd 0
    game_over           dd 0

    WALL_TILE   dd 0
    FOOD_IMG    dd 0
    PILL_IMG    dd 0

    test_header_format  db  "A: %d",13,10,0
    buffer              db 256 dup(?)
    msgBoxTitle         db "Testing",0

    over byte 0 ;

    ;instancia o pac
    pac player <<<100,450>,  <0,0>>, 0, 4, D_RIGHT> 

    ;instancia os fantasmas
    ghost1 ghost <<<100,350>,  <0,0>>, 0, 1, D_RIGHT>
    ghost2 ghost <<<200,350>,  <0,0>>, 0, 1, D_RIGHT>
    ghost3 ghost <<<300,350>,  <0,0>>, 0, 1, D_RIGHT>
    ghost4 ghost <<<400,350>,  <0,0>>, 0, 1, D_RIGHT>

    ;instancia as paredes
    ;[nome] wall <<x, y>>
    wall1 wall  <<16, 16>>

    ;instancia as comidas
    ;[nome] food <<x, y>, [pontos]>
    food1 food <<64, 64>, 10>

    ;instancia as pílulas
    ;[nome] pill <<x, y>, [pontos], [tempo(s)]>
    pill1 pill <<128, 128>, 30, 5>
    
    RIGHTARROW            BYTE 0
    
    GAMESTATE             BYTE 0

.DATA?
    hWnd HWND ?
    thread1ID DWORD ?
    thread2ID DWORD ?

    

include \masm32\include\winmm.inc
includelib \masm32\lib\winmm.lib
include ufmod.inc
includelib ufmod.lib
include \masm32\include\masm32rt.inc
include \masm32\include\msimg32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\msimg32.lib

;struct que é usada para definir coisas com x e y (posição e velocidade)
point struct 
    x dd 0      
    y dd 0
point ends

;atributos que todo objeto tem, serve como uma classe mãe
gameObject struct
    initPos     point <> 
    pos         point <>
    speed       point <>
gameObject ends

;classe do player
player struct
    playerObj           gameObject <>
    life                BYTE 4
    direction           BYTE 0
    animation           BYTE 0
    anim_counter        dd   0
player ends

;fantasma
ghost struct
    ghostObj          gameObject <>
    afraid            BYTE  0
    afraid_timer      dd    0
    alive             BYTE  1
    death_timer       dd    0
    direction         BYTE  0
    random_dir        BYTE  0
    init_dir          BYTE  0
ghost ends                 

;parede
wallTile struct
    pos         point<>
    next_wall   dd 0
wallTile ends

food struct
    foodObj      gameObject<>
    next_food    dd 0
food ends

pill struct
    pillObj      gameObject<>
    next_pill    dd 0
pill ends

everithing struct
    first_wall  dd 0
    first_food  dd 0
    first_pill  dd 0
everithing ends


.CONST
    ;tamanho da janela
    WINDOW_SIZE_X EQU 800
    WINDOW_SIZE_Y EQU 600

    ;define as direções, pra poder entender essa parte do código mais fácilmente
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

    ;tem q testar e talvez mudar dps
    WALL_SIZE EQU 20 
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

    WALL_SIZE_POINT     point <20,20>

    FOOD_SIZE_POINT     point <8,8>
    FOOD_HALF_SIZE_P    point <4,4>

    PILL_SIZE_POINT     point <8,8>
    PILL_HALF_SIZE_P    point <4,4>

    food_left   dd 13

    ;inicializando as variáveis que vão guardar as imagens (vazias por enquanto):
    h_background        dd 0
    h_loading           dd 0
    h_menu              dd 0

    G0      dd 0
    G1      dd 0
    G2      dd 0
    G3      dd 0
    G4      dd 0
    G1_DEAD dd 0
    G2_DEAD dd 0
    G3_DEAD dd 0
    G4_DEAD dd 0

    PAC_RIGHT_OPEN      dd 0
    PAC_RIGHT_CLOSED    dd 0
    PAC_TOP_OPEN        dd 0
    PAC_TOP_CLOSED      dd 0
    PAC_LEFT_OPEN       dd 0
    PAC_LEFT_CLOSED     dd 0
    PAC_DOWN_OPEN       dd 0
    PAC_DOWN_CLOSED     dd 0

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
    pac player <<<600,500>, <600,500>,  <0,0>>, 4, D_RIGHT, 0, 0> 

    ;instancia os fantasmas
    ghost1 ghost <<<300,300>, <300,300>,  <0,0>>, FALSE, 0, TRUE, 0, D_RIGHT, 1, D_RIGHT>
    ghost2 ghost <<<300,400>, <300,400>,  <0,0>>, FALSE, 0, TRUE, 0, D_LEFT,  2, D_LEFT>
    ghost3 ghost <<<100,300>, <100,300>,  <0,0>>, FALSE, 0, TRUE, 0, D_RIGHT, 3, D_RIGHT>
    ghost4 ghost <<<350,400>, <350,400>,  <0,0>>, FALSE, 0, TRUE, 0, D_LEFT,  0, D_LEFT>

    ;instancia as paredes
    ;[nome] wall <<x, y>, OFFSET next>
    ;parede cima
    wall0 wallTile  <<0, 40>, 0>
    wall1 wallTile  <<20, 40>, OFFSET wall0>
    wall2 wallTile  <<40, 40>, OFFSET wall1>
    wall3 wallTile  <<60, 40>, OFFSET wall2>
    wall4 wallTile  <<80, 40>, OFFSET wall3>
    wall5 wallTile  <<100,40>, OFFSET wall4>
    wall6 wallTile  <<120,40>, OFFSET wall5>
    wall7 wallTile  <<140,40>, OFFSET wall6>
    wall8 wallTile  <<160,40>, OFFSET wall7>
    wall9 wallTile  <<180,40>, OFFSET wall8>
    wall10 wallTile  <<200,40>, OFFSET wall9>
    wall11 wallTile  <<220,40>, OFFSET wall10>
    wall12 wallTile  <<240,40>, OFFSET wall11>
    wall13 wallTile  <<260,40>, OFFSET wall12>
    wall14 wallTile  <<280,40>, OFFSET wall13>
    wall15 wallTile  <<300,40>, OFFSET wall14>
    wall16 wallTile  <<320,40>, OFFSET wall15>
    wall17 wallTile  <<340,40>, OFFSET wall16>
    wall18 wallTile  <<360,40>, OFFSET wall17>
    wall19 wallTile  <<380,40>, OFFSET wall18>
    wall20 wallTile  <<400,40>, OFFSET wall19>
    wall21 wallTile  <<420,40>, OFFSET wall20>
    wall22 wallTile  <<440,40>, OFFSET wall21>
    wall23 wallTile  <<460,40>, OFFSET wall22>
    wall24 wallTile  <<480,40>, OFFSET wall23>
    wall25 wallTile  <<500,40>, OFFSET wall24>
    wall26 wallTile  <<520,40>, OFFSET wall25>
    wall27 wallTile  <<540,40>, OFFSET wall26>
    wall28 wallTile  <<560,40>, OFFSET wall27>
    wall29 wallTile  <<580,40>, OFFSET wall28>
    wall30 wallTile  <<600,40>, OFFSET wall29>
    wall31 wallTile  <<620,40>, OFFSET wall30>
    wall32 wallTile  <<640,40>, OFFSET wall31>
    wall33 wallTile  <<660,40>, OFFSET wall32>
    wall34 wallTile  <<680,40>, OFFSET wall33>
    wall35 wallTile  <<700,40>, OFFSET wall34>
    wall36 wallTile  <<720,40>, OFFSET wall35>
    wall37 wallTile  <<740,40>, OFFSET wall36>
    wall38 wallTile  <<760,40>, OFFSET wall37>
    wall39 wallTile  <<780,40>, OFFSET wall38>
    wall40 wallTile  <<800,40>, OFFSET wall39>


    ;parede baixo

    wallDown0 wallTile  <<0, 580>, OFFSET wall40>
    wallDown1 wallTile  <<20, 580>, OFFSET wallDown0>
    wallDown2 wallTile  <<40,580>, OFFSET wallDown1>
    wallDown3 wallTile  <<60,580>, OFFSET wallDown2>
    wallDown4 wallTile  <<80,580>, OFFSET wallDown3>
    wallDown5 wallTile  <<100,580>, OFFSET wallDown4>
    wallDown6 wallTile  <<120,580>, OFFSET wallDown5>
    wallDown7 wallTile  <<140,580>, OFFSET wallDown6>
    wallDown8 wallTile  <<160,580>, OFFSET wallDown7>
    wallDown9 wallTile  <<180,580>, OFFSET wallDown8>
    wallDown10 wallTile  <<200,580>, OFFSET wallDown9>
    wallDown11 wallTile  <<220,580>, OFFSET wallDown10>
    wallDown12 wallTile  <<240,580>, OFFSET wallDown11>
    wallDown13 wallTile  <<260,580>, OFFSET wallDown12>
    wallDown14 wallTile  <<280,580>, OFFSET wallDown13>
    wallDown15 wallTile  <<300,580>, OFFSET wallDown14>
    wallDown16 wallTile  <<320,580>, OFFSET wallDown15>
    wallDown17 wallTile  <<340,580>, OFFSET wallDown16>
    wallDown18 wallTile  <<360,580>, OFFSET wallDown17>
    wallDown19 wallTile  <<380,580>, OFFSET wallDown18>
    wallDown20 wallTile  <<400,580>, OFFSET wallDown19>
    wallDown21 wallTile  <<420,580>, OFFSET wallDown20>
    wallDown22 wallTile  <<440,580>, OFFSET wallDown21>
    wallDown23 wallTile  <<460,580>, OFFSET wallDown22>
    wallDown24 wallTile  <<480,580>, OFFSET wallDown23>
    wallDown25 wallTile  <<500,580>, OFFSET wallDown24>
    wallDown26 wallTile  <<520,580>, OFFSET wallDown25>
    wallDown27 wallTile  <<540,580>, OFFSET wallDown26>
    wallDown28 wallTile  <<560,580>, OFFSET wallDown27>
    wallDown29 wallTile  <<580,580>, OFFSET wallDown28>
    wallDown30 wallTile  <<600,580>, OFFSET wallDown29>
    wallDown31 wallTile  <<620,580>, OFFSET wallDown30>
    wallDown32 wallTile  <<640,580>, OFFSET wallDown31>
    wallDown33 wallTile  <<660,580>, OFFSET wallDown32>
    wallDown34 wallTile  <<680,580>, OFFSET wallDown33>
    wallDown35 wallTile  <<700,580>, OFFSET wallDown34>
    wallDown36 wallTile  <<720,580>, OFFSET wallDown35>
    wallDown37 wallTile  <<740,580>, OFFSET wallDown36>
    wallDown38 wallTile  <<760,580>, OFFSET wallDown37>
    wallDown39 wallTile  <<780,580>, OFFSET wallDown38>
    wallDown40 wallTile  <<800,580>, OFFSET wallDown39>


    ;parede esquerda


    wallLeft2 wallTile  <<0,60>, OFFSET wallDown40>
    wallLeft3 wallTile  <<0,80>, OFFSET wallLeft2>
    wallLeft4 wallTile  <<0,100>, OFFSET wallLeft3>
    wallLeft5 wallTile  <<0,120>, OFFSET wallLeft4>
    wallLeft6 wallTile  <<0,140>, OFFSET wallLeft5>
    wallLeft7 wallTile  <<0,160>, OFFSET wallLeft6>
    wallLeft8 wallTile  <<0,180>, OFFSET wallLeft7>
    wallLeft9 wallTile  <<0,200>, OFFSET wallLeft8>
    wallLeft10 wallTile <<0,220>, OFFSET wallLeft9>
    wallLeft11 wallTile <<0,240>, OFFSET wallLeft10>
    wallLeft12 wallTile <<0,260>, OFFSET wallLeft11>
    wallLeft13 wallTile <<0,280>, OFFSET wallLeft12>
    wallLeft14 wallTile  <<0,300>, OFFSET wallLeft13>
    ;wallLeft15 wallTile  <<0,320>, OFFSET wallLeft12>
    ;wallLeft16 wallTile  <<0,340>, OFFSET wallLeft15>
    wallLeft17 wallTile  <<0,360>, OFFSET wallLeft14>
    wallLeft18 wallTile  <<0,380>, OFFSET wallLeft17>
    wallLeft19 wallTile  <<0,400>, OFFSET wallLeft18>
    wallLeft20 wallTile  <<0,420>, OFFSET wallLeft19>
    wallLeft21 wallTile  <<0,440>, OFFSET wallLeft20>
    wallLeft22 wallTile  <<0,460>, OFFSET wallLeft21>
    wallLeft23 wallTile  <<0,480>, OFFSET wallLeft22>
    wallLeft24 wallTile  <<0,500>, OFFSET wallLeft23>
    wallLeft25 wallTile  <<0,520>, OFFSET wallLeft24>
    wallLeft26 wallTile  <<0,540>, OFFSET wallLeft25>
    wallLeft27 wallTile  <<0,560>, OFFSET wallLeft26>
    wallLeft28 wallTile  <<0,580>, OFFSET wallLeft27>
    wallLeft29 wallTile  <<0,600>, OFFSET wallLeft28>

  
    ;parede direita


    wallRight2 wallTile  <<780,60>, OFFSET wallLeft29>
    wallRight3 wallTile  <<780,80>, OFFSET wallRight2>
    wallRight4 wallTile  <<780,100>, OFFSET wallRight3>
    wallRight5 wallTile  <<780,120>, OFFSET wallRight4>
    wallRight6 wallTile  <<780,140>, OFFSET wallRight5>
    wallRight7 wallTile  <<780,160>, OFFSET wallRight6>
    wallRight8 wallTile  <<780,180>, OFFSET wallRight7>
    wallRight9 wallTile  <<780,200>, OFFSET wallRight8>
    wallRight10 wallTile <<780,220>, OFFSET wallRight9>
    wallRight11 wallTile <<780,240>, OFFSET wallRight10>
    wallRight12 wallTile <<780,260>, OFFSET wallRight11>
    wallRight13 wallTile <<780,280>, OFFSET wallRight12>
    wallRight14 wallTile  <<780,300>, OFFSET wallRight13>
    ;wallRight15 wallTile  <<780,320>, OFFSET wallRight12>
    ;wallRight16 wallTile  <<780,340>, OFFSET wallRight15>
    wallRight17 wallTile  <<780,360>, OFFSET wallRight14>
    wallRight18 wallTile  <<780,380>, OFFSET wallRight17>
    wallRight19 wallTile  <<780,400>, OFFSET wallRight18>
    wallRight20 wallTile  <<780,420>, OFFSET wallRight19>
    wallRight21 wallTile  <<780,440>, OFFSET wallRight20>
    wallRight22 wallTile  <<780,460>, OFFSET wallRight21>
    wallRight23 wallTile  <<780,480>, OFFSET wallRight22>
    wallRight24 wallTile  <<780,500>, OFFSET wallRight23>
    wallRight25 wallTile  <<780,520>, OFFSET wallRight24>
    wallRight26 wallTile  <<780,540>, OFFSET wallRight25>
    wallRight27 wallTile  <<780,560>, OFFSET wallRight26>
    wallRight28 wallTile  <<780,580>, OFFSET wallRight27>
    wallRight29 wallTile  <<780,600>, OFFSET wallRight28>



    ;instancia as comidas
    food1 food <<<40, 80>, <40, 80>, <0,0>>, 0>
    food2 food <<<40, 120>, <40, 120>, <0,0>>, OFFSET food1>
    food3 food <<<40, 160>, <40, 160>, <0,0>>, OFFSET food2>
    food4 food <<<40, 200>, <40, 200>, <0,0>>, OFFSET food3>
    food5 food <<<40, 240>, <40, 240>, <0,0>>, OFFSET food4>
    food6 food <<<40, 280>, <40, 280>, <0,0>>, OFFSET food5>
    food7 food <<<40, 320>, <40, 320>, <0,0>>, OFFSET food6>
    food8 food <<<40, 360>, <40, 360>, <0,0>>, OFFSET food7>
    food9 food <<<40, 400>, <40, 400>, <0,0>>, OFFSET food8>
    food10 food <<<40, 440>, <40, 440>, <0,0>>, OFFSET food9>
    food11 food <<<40, 480>, <40, 480>, <0,0>>, OFFSET food10>
    food12 food <<<40, 520>, <40, 520>, <0,0>>, OFFSET food11>
    food13 food <<<40, 560>, <40, 560>, <0,0>>, OFFSET food12>
    food14 food <<<40, 560>, <40, 560>, <0,0>>, OFFSET food13>
    food15 food <<<40, 600>, <40, 600>, <0,0>>, OFFSET food14>
    food16 food <<<40, 400>, <300, 400>, <0,0>>, OFFSET food15>
    food17 food <<<40, 400>, <300, 400>, <0,0>>, OFFSET food16>
    food18 food <<<40, 400>, <300, 400>, <0,0>>, OFFSET food17>
    food19 food <<<40, 400>, <300, 400>, <0,0>>, OFFSET food18>
    food20 food <<<40, 400>, <300, 400>, <0,0>>, OFFSET food19>
    food21 food <<<40, 400>, <300, 400>, <0,0>>, OFFSET food20>
    food22 food <<<40, 400>, <300, 400>, <0,0>>, OFFSET food21>
    food23 food <<<40, 400>, <300, 400>, <0,0>>, OFFSET food22>
    food24 food <<<40, 400>, <300, 400>, <0,0>>, OFFSET food23>

    ;instancia as pílulas
    pill1 pill <<<150, 200>, <150, 200>, <0,0>>, 0>
    pill2 pill< <<400, 300>, <400, 300>, <0,0>>, OFFSET pill1>

    map everithing <OFFSET wallRight29, OFFSET food13, OFFSET pill2>

    tempPos     point       <0, 0>
    tempWall    wallTile    <<0, 0>, 0>
    
    RIGHTARROW            BYTE 0
    
    GAMESTATE             BYTE 0

.DATA?
    hWnd HWND ?
    thread1ID DWORD ?
    thread2ID DWORD ?

    

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
    WINDOW_SIZE_X EQU 840
    WINDOW_SIZE_Y EQU 960

    ;define as direções, pra poder entender essa parte do código mais fácilmente
    D_RIGHT       EQU 0 
    D_TOP         EQU 1  
    D_LEFT        EQU 2     
    D_DOWN        EQU 3

    ;tamanhos de cada objeto:
    PAC_SIZE      EQU 32

    GHOST_SIZE   EQU 32

    LIFE_SIZE    EQU 32

    ;tem q testar e talvez mudar dps
    WALL_SIZE EQU 40
    FOOD_SIZE EQU 16
    PILL_SIZE EQU 16

    PAC_SPEED  EQU 6
    GHOST_SPEED   EQU 6

.DATA
    big_buffer  db 65536 dup(?)
                db 65536 dup(?)
                db 65536 dup(?)

    paintstruct        PAINTSTRUCT <>

    PAC_SIZE_POINT      point <32,32>

    GHOST_SIZE_POINT    point <32,32>

    WALL_SIZE_POINT     point <40,40>

    FOOD_SIZE_POINT     point <16,16>

    PILL_SIZE_POINT     point <16,16>

    food_left   dd 234

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
    pac player <<<400,680>, <400,680>,  <0,0>>, 4, D_RIGHT, 0, 0> 

    ;instancia os fantasmas
    ghost1 ghost <<<400,400>, <440,400>,  <0,0>>, FALSE, 0, TRUE, 0, D_RIGHT, 0, D_RIGHT>
    ghost2 ghost <<<400,400>, <400,400>,  <0,0>>, FALSE, 0, TRUE, 0, D_DOWN,  1, D_DOWN>
    ghost3 ghost <<<400,400>, <440,400>,  <0,0>>, FALSE, 0, TRUE, 0, D_LEFT, 2, D_LEFT>
    ghost4 ghost <<<400,400>, <400,360>,  <0,0>>, FALSE, 0, TRUE, 0, D_TOP,  3, D_TOP>

    ;instancia as paredes
    ;[nome] wall <<x, y>, OFFSET next>
    ;parede cima
    wall0 wallTile  <<0, 0>, 0>
    wall1 wallTile  <<40, 0>, OFFSET wall0>
    wall2 wallTile  <<80, 0>, OFFSET wall1>
    wall3 wallTile  <<120, 0>, OFFSET wall2>
    wall4 wallTile  <<160, 0>, OFFSET wall3>
    wall5 wallTile  <<200,0>, OFFSET wall4>
    wall6 wallTile  <<240,0>, OFFSET wall5>
    wall7 wallTile  <<280,0>, OFFSET wall6>
    wall8 wallTile  <<320,0>, OFFSET wall7>
    wall9 wallTile  <<360,0>, OFFSET wall8>
    wall10 wallTile  <<400,0>, OFFSET wall9>
    wall11 wallTile  <<440,0>, OFFSET wall10>
    wall12 wallTile  <<480,0>, OFFSET wall11>
    wall13 wallTile  <<520,0>, OFFSET wall12>
    wall14 wallTile  <<560,0>, OFFSET wall13>
    wall15 wallTile  <<600,0>, OFFSET wall14>
    wall16 wallTile  <<640,0>, OFFSET wall15>
    wall17 wallTile  <<680,0>, OFFSET wall16>
    wall18 wallTile  <<720,0>, OFFSET wall17>
    wall19 wallTile  <<760,0>, OFFSET wall18>
    wall20 wallTile  <<800,0>, OFFSET wall19>



    ;parede baixo

    wallDown0 wallTile  <<0, 920>, OFFSET wall20>
    wallDown1 wallTile  <<40, 920>, OFFSET wallDown0>
    wallDown2 wallTile  <<80,920>, OFFSET wallDown1>
    wallDown3 wallTile  <<120,920>, OFFSET wallDown2>
    wallDown4 wallTile  <<160,920>, OFFSET wallDown3>
    wallDown5 wallTile  <<200,920>, OFFSET wallDown4>
    wallDown6 wallTile  <<240,920>, OFFSET wallDown5>
    wallDown7 wallTile  <<280,920>, OFFSET wallDown6>
    wallDown8 wallTile  <<320,920>, OFFSET wallDown7>
    wallDown9 wallTile  <<360,920>, OFFSET wallDown8>
    wallDown10 wallTile  <<400,920>, OFFSET wallDown9>
    wallDown11 wallTile  <<440,920>, OFFSET wallDown10>
    wallDown12 wallTile  <<480,920>, OFFSET wallDown11>
    wallDown13 wallTile  <<520,920>, OFFSET wallDown12>
    wallDown14 wallTile  <<560,920>, OFFSET wallDown13>
    wallDown15 wallTile  <<600,920>, OFFSET wallDown14>
    wallDown16 wallTile  <<640,920>, OFFSET wallDown15>
    wallDown17 wallTile  <<680,920>, OFFSET wallDown16>
    wallDown18 wallTile  <<720,920>, OFFSET wallDown17>
    wallDown19 wallTile  <<760,920>, OFFSET wallDown18>
    wallDown20 wallTile  <<800,920>, OFFSET wallDown19>


    ;parede esquerda


    wallLeft2 wallTile  <<0,40>, OFFSET wallDown20>
    wallLeft3 wallTile  <<0,80>, OFFSET wallLeft2>
    wallLeft4 wallTile  <<0,120>, OFFSET wallLeft3>
    wallLeft5 wallTile  <<0,160>, OFFSET wallLeft4>
    wallLeft6 wallTile  <<0,200>, OFFSET wallLeft5>
    wallLeft7 wallTile  <<0,240>, OFFSET wallLeft6>
    wallLeft8 wallTile  <<0,280>, OFFSET wallLeft7>
    ;wallLeft9 wallTile  <<0,320>, OFFSET wallLeft7>
    wallLeft10 wallTile <<0,360>, OFFSET wallLeft8>
    wallLeft11 wallTile <<0,400>, OFFSET wallLeft10>
    wallLeft12 wallTile <<0,440>, OFFSET wallLeft11>
    wallLeft13 wallTile <<0,480>, OFFSET wallLeft12>
    wallLeft14 wallTile  <<0,520>, OFFSET wallLeft13>
    wallLeft15 wallTile  <<0,560>, OFFSET wallLeft14>
    wallLeft16 wallTile  <<0,600>, OFFSET wallLeft15>
    ;wallLeft17 wallTile  <<0,640>, OFFSET wallLeft15>
    wallLeft18 wallTile  <<0,680>, OFFSET wallLeft16>
    wallLeft19 wallTile  <<0,720>, OFFSET wallLeft18>
    wallLeft20 wallTile  <<0,760>, OFFSET wallLeft19>
    wallLeft21 wallTile  <<0,800>, OFFSET wallLeft20>
    wallLeft22 wallTile  <<0,840>, OFFSET wallLeft21>
    wallLeft23 wallTile  <<0,880>, OFFSET wallLeft22>


    ;parede direita

    wallRight1 wallTile  <<800,40>, OFFSET wallLeft23>
    wallRight2 wallTile  <<800,80>, OFFSET wallRight1>
    wallRight3 wallTile  <<800,120>, OFFSET wallRight2>
    wallRight4 wallTile  <<800,160>, OFFSET wallRight3>
    wallRight5 wallTile  <<800,200>, OFFSET wallRight4>
    wallRight6 wallTile  <<800,240>, OFFSET wallRight5>
    wallRight7 wallTile  <<800,280>, OFFSET wallRight6>
    ;wallRight8 wallTile  <<800,320>, OFFSET wallRight6>
    wallRight9 wallTile  <<800,360>, OFFSET wallRight7>
    wallRight10 wallTile <<800,400>, OFFSET wallRight9>
    wallRight11 wallTile <<800,440>, OFFSET wallRight10>
    wallRight12 wallTile <<800,480>, OFFSET wallRight11>
    wallRight13 wallTile <<800,520>, OFFSET wallRight12>
    wallRight14 wallTile  <<800,560>, OFFSET wallRight13>
    wallRight15 wallTile  <<800,600>, OFFSET wallRight14>
    ;wallRight16 wallTile  <<800,640>, OFFSET wallRight15>
    wallRight17 wallTile  <<800,680>, OFFSET wallRight15>
    wallRight18 wallTile  <<800,720>, OFFSET wallRight17>
    wallRight19 wallTile  <<800,760>, OFFSET wallRight18>
    wallRight20 wallTile  <<800,800>, OFFSET wallRight19>
    wallRight21 wallTile  <<800,840>, OFFSET wallRight20>
    wallRight22 wallTile  <<800,880>, OFFSET wallRight21>
    

    ;paredes internas
    wallInside0 wallTile  <<320,40>, OFFSET wallRight22>
    wallInside1 wallTile  <<320,80>, OFFSET wallInside0>
    wallInside2 wallTile  <<480,40>, OFFSET wallInside1>
    wallInside3 wallTile  <<480,80>, OFFSET wallInside2>
    wallInside4 wallTile  <<40,560>, OFFSET wallInside3>
    wallInside5 wallTile  <<40,600>, OFFSET wallInside4>
    wallInside6 wallTile  <<760,560>, OFFSET wallInside5>
    wallInside7 wallTile  <<760,600>, OFFSET wallInside6>
    wallInside8 wallTile  <<280,480>, OFFSET wallInside7>
    wallInside9 wallTile  <<320,480>, OFFSET wallInside8>
    wallInside10 wallTile  <<360,480>, OFFSET wallInside9>
    wallInside11 wallTile  <<280,440>, OFFSET wallInside10>
    wallInside12 wallTile  <<520,480>, OFFSET wallInside11>
    wallInside13 wallTile  <<480,480>, OFFSET wallInside12>
    wallInside14 wallTile  <<440,480>, OFFSET wallInside13>
    wallInside15 wallTile  <<520,440>, OFFSET wallInside14>
    wallInside16 wallTile  <<280,320>, OFFSET wallInside15>
    wallInside17 wallTile  <<320,320>, OFFSET wallInside16>
    wallInside18 wallTile  <<360,320>, OFFSET wallInside17>
    wallInside19 wallTile  <<280,360>, OFFSET wallInside18>
    wallInside20 wallTile  <<440,320>, OFFSET wallInside19>
    wallInside21 wallTile  <<480,320>, OFFSET wallInside20>
    wallInside22 wallTile  <<520,320>, OFFSET wallInside21>
    wallInside23 wallTile  <<520,360>, OFFSET wallInside22>
    wallInside24 wallTile  <<400,80>, OFFSET wallInside23>
    wallInside25 wallTile  <<400,120>, OFFSET wallInside24>
    wallInside26 wallTile  <<400,160>, OFFSET wallInside25>
    wallInside27 wallTile  <<400,200>, OFFSET wallInside26>
    wallInside28 wallTile  <<400,240>, OFFSET wallInside27>
    wallInside29 wallTile  <<360,240>, OFFSET wallInside28>
    wallInside30 wallTile  <<320,240>, OFFSET wallInside29>
    wallInside31 wallTile  <<440,240>, OFFSET wallInside30>
    wallInside32 wallTile  <<480,240>, OFFSET wallInside31>
    wallInside33 wallTile  <<320,160>, OFFSET wallInside32>
    wallInside34 wallTile  <<280,160>, OFFSET wallInside33>
    wallInside35 wallTile  <<240,160>, OFFSET wallInside34>
    wallInside36 wallTile  <<240,120>, OFFSET wallInside35>
    wallInside37 wallTile  <<240,80>, OFFSET wallInside36>
    wallInside38 wallTile  <<480,160>, OFFSET wallInside37>
    wallInside39 wallTile  <<520,160>, OFFSET wallInside38>
    wallInside40 wallTile  <<560,160>, OFFSET wallInside39>
    wallInside41 wallTile  <<560,120>, OFFSET wallInside40>
    wallInside42 wallTile  <<560,80>, OFFSET wallInside41>
    wallInside43 wallTile  <<80,80>, OFFSET wallInside42>
    wallInside44 wallTile  <<120,80>, OFFSET wallInside43>
    wallInside45 wallTile  <<160,80>, OFFSET wallInside44>
    wallInside46 wallTile  <<640,80>, OFFSET wallInside45>
    wallInside47 wallTile  <<680,80>, OFFSET wallInside46>
    wallInside48 wallTile  <<720,80>, OFFSET wallInside47>
    wallInside49 wallTile  <<80,160>, OFFSET wallInside48>
    wallInside50 wallTile  <<120,160>, OFFSET wallInside49>
    wallInside51 wallTile  <<160,160>, OFFSET wallInside50>
    wallInside52 wallTile  <<80,200>, OFFSET wallInside51>
    wallInside53 wallTile  <<80,240>, OFFSET wallInside52>
    wallInside54 wallTile  <<80,280>, OFFSET wallInside53>
    wallInside55 wallTile  <<640,160>, OFFSET wallInside54>
    wallInside56 wallTile  <<680,160>, OFFSET wallInside55>
    wallInside57 wallTile  <<720,160>, OFFSET wallInside56>
    wallInside58 wallTile  <<720,200>, OFFSET wallInside57>
    wallInside59 wallTile  <<720,240>, OFFSET wallInside58>
    wallInside60 wallTile  <<720,280>, OFFSET wallInside59>
    wallInside61 wallTile  <<160,240>, OFFSET wallInside60>
    wallInside62 wallTile  <<200,240>, OFFSET wallInside61>
    wallInside63 wallTile  <<240,240>, OFFSET wallInside62>
    wallInside64 wallTile  <<160,280>, OFFSET wallInside63>
    wallInside65 wallTile  <<200,280>, OFFSET wallInside64>
    wallInside66 wallTile  <<560,240>, OFFSET wallInside65>
    wallInside67 wallTile  <<600,240>, OFFSET wallInside66>
    wallInside68 wallTile  <<640,240>, OFFSET wallInside67>
    wallInside69 wallTile  <<600,280>, OFFSET wallInside68>
    wallInside70 wallTile  <<640,280>, OFFSET wallInside69>
    wallInside71 wallTile  <<200,360>, OFFSET wallInside70>
    wallInside72 wallTile  <<200,400>, OFFSET wallInside71>
    wallInside73 wallTile  <<200,440>, OFFSET wallInside72>
    wallInside74 wallTile  <<200,480>, OFFSET wallInside73>
    wallInside75 wallTile  <<200,520>, OFFSET wallInside74>
    wallInside76 wallTile  <<200,560>, OFFSET wallInside75>
    wallInside77 wallTile  <<600,360>, OFFSET wallInside76>
    wallInside78 wallTile  <<600,400>, OFFSET wallInside77>
    wallInside79 wallTile  <<600,440>, OFFSET wallInside78>
    wallInside80 wallTile  <<600,480>, OFFSET wallInside79>
    wallInside81 wallTile  <<600,520>, OFFSET wallInside80>
    wallInside82 wallTile  <<600,560>, OFFSET wallInside81>
    wallInside83 wallTile  <<80,360>, OFFSET wallInside82>
    wallInside84 wallTile  <<80,400>, OFFSET wallInside83>
    wallInside85 wallTile  <<120,360>, OFFSET wallInside84>
    wallInside86 wallTile  <<120,400>, OFFSET wallInside85>
    wallInside87 wallTile  <<680,360>, OFFSET wallInside86>
    wallInside88 wallTile  <<720,360>, OFFSET wallInside87>
    wallInside89 wallTile  <<680,400>, OFFSET wallInside88>
    wallInside90 wallTile  <<720,400>, OFFSET wallInside89>
    wallInside91 wallTile  <<80,480>, OFFSET wallInside90>
    wallInside92 wallTile  <<120,480>, OFFSET wallInside91>
    wallInside93 wallTile  <<120,520>, OFFSET wallInside92>
    wallInside94 wallTile  <<120,560>, OFFSET wallInside93>
    wallInside95 wallTile  <<120,600>, OFFSET wallInside94>
    wallInside96 wallTile  <<120,640>, OFFSET wallInside95> 
    wallInside97 wallTile  <<120,680>, OFFSET wallInside96>
    wallInside98 wallTile  <<80,680>, OFFSET wallInside97>  
    wallInside99 wallTile  <<680, 480>, OFFSET wallInside98>
    wallInside100 wallTile <<720,480>, OFFSET wallInside99>
    wallInside101 wallTile <<680,520>, OFFSET wallInside100>
    wallInside102 wallTile <<680,560>, OFFSET wallInside101>
    wallInside103 wallTile <<680,600>, OFFSET wallInside102>
    wallInside104 wallTile <<680,640>, OFFSET wallInside103> 
    wallInside105 wallTile <<680,680>, OFFSET wallInside104>
    wallInside106 wallTile <<720,680>, OFFSET wallInside105>
    wallInside107 wallTile <<200,640>, OFFSET wallInside106> 
    wallInside108 wallTile <<240,640>, OFFSET wallInside107>
    wallInside109 wallTile <<280,640>, OFFSET wallInside108>
    wallInside110 wallTile <<320,640>, OFFSET wallInside109>
    wallInside111 wallTile <<200,680>, OFFSET wallInside110>   
    wallInside112 wallTile <<200,720>, OFFSET wallInside111>
    wallInside113 wallTile <<200,760>, OFFSET wallInside112>
    wallInside114 wallTile <<240,680>, OFFSET wallInside113>
    wallInside115 wallTile <<240,720>, OFFSET wallInside114>
    wallInside116 wallTile <<240,760>, OFFSET wallInside115>
    wallInside117 wallTile <<160,760>, OFFSET wallInside116>
    wallInside118 wallTile <<480,640>, OFFSET wallInside117> 
    wallInside119 wallTile <<520,640>, OFFSET wallInside118>
    wallInside120 wallTile <<560,640>, OFFSET wallInside119>
    wallInside121 wallTile <<600,640>, OFFSET wallInside120>
    wallInside122 wallTile <<560,680>, OFFSET wallInside121>   
    wallInside123 wallTile <<560,720>, OFFSET wallInside122>
    wallInside124 wallTile <<560,760>, OFFSET wallInside123>
    wallInside125 wallTile <<600,680>, OFFSET wallInside124>
    wallInside126 wallTile <<600,720>, OFFSET wallInside125>
    wallInside127 wallTile <<600,760>, OFFSET wallInside126>
    wallInside128 wallTile <<640,760>, OFFSET wallInside127>
    wallInside129 wallTile <<80,760>, OFFSET wallInside128>
    wallInside130 wallTile <<80,800>, OFFSET wallInside129> 
    wallInside131 wallTile <<80,840>, OFFSET wallInside130>
    wallInside132 wallTile <<120,840>, OFFSET wallInside131>
    wallInside133 wallTile <<160,840>, OFFSET wallInside132> 
    wallInside134 wallTile <<200,840>, OFFSET wallInside133>
    wallInside135 wallTile <<240,840>, OFFSET wallInside134>
    wallInside136 wallTile <<720,760>, OFFSET wallInside135>
    wallInside137 wallTile <<720,800>, OFFSET wallInside136> 
    wallInside138 wallTile <<720,840>, OFFSET wallInside137>
    wallInside139 wallTile <<680,840>, OFFSET wallInside138>
    wallInside140 wallTile <<640,840>, OFFSET wallInside139> 
    wallInside141 wallTile <<600,840>, OFFSET wallInside140>
    wallInside142 wallTile <<560,840>, OFFSET wallInside141>
    wallInside143 wallTile <<400,560>, OFFSET wallInside142>
    wallInside144 wallTile <<360,560>, OFFSET wallInside143> 
    wallInside145 wallTile <<320,560>, OFFSET wallInside144>
    wallInside146 wallTile <<280,560>, OFFSET wallInside145>
    wallInside147 wallTile <<440,560>, OFFSET wallInside146> 
    wallInside148 wallTile <<480,560>, OFFSET wallInside147>
    wallInside149 wallTile <<520,560>, OFFSET wallInside148>
    wallInside150 wallTile <<400,600>, OFFSET wallInside149>
    wallInside151 wallTile <<400,640>, OFFSET wallInside150> 
    wallInside152 wallTile <<400,720>, OFFSET wallInside151>
    wallInside153 wallTile <<400,760>, OFFSET wallInside152>
    wallInside154 wallTile <<320,720>, OFFSET wallInside153>
    wallInside155 wallTile <<320,760>, OFFSET wallInside154> 
    wallInside156 wallTile <<320,800>, OFFSET wallInside155>
    wallInside157 wallTile <<320,840>, OFFSET wallInside156>
    wallInside158 wallTile <<360,840>, OFFSET wallInside157> 
    wallInside159 wallTile <<400,840>, OFFSET wallInside158>
    wallInside160 wallTile <<440,840>, OFFSET wallInside159>
    wallInside161 wallTile <<480,840>, OFFSET wallInside160>
    wallInside162 wallTile <<480,800>, OFFSET wallInside161> 
    wallInside163 wallTile <<480,760>, OFFSET wallInside162>
    wallInside164 wallTile <<480,720>, OFFSET wallInside163>                                                                               
                           

    
    ;instancia as comidas
    food1 food <<<60, 60>, <60, 60>, <0,0>>, 0>
    food2 food <<<60, 100>, <60, 100>, <0,0>>, OFFSET food1>
    food3 food <<<60, 140>, <60, 140>, <0,0>>, OFFSET food2>
    food4 food <<<60, 180>, <60, 180>, <0,0>>, OFFSET food3>
    food5 food <<<60, 220>, <60, 220>, <0,0>>, OFFSET food4>
    food6 food <<<60, 260>, <60, 260>, <0,0>>, OFFSET food5>
    food7 food <<<60, 300>, <60, 300>, <0,0>>, OFFSET food6>
    food8 food <<<60, 340>, <60, 340>, <0,0>>, OFFSET food7>
    food9 food <<<60, 380>, <60, 380>, <0,0>>, OFFSET food8>
    food10 food <<<60, 420>, <60, 420>, <0,0>>, OFFSET food9>
    food11 food <<<60, 460>, <60, 460>, <0,0>>, OFFSET food10>
    food12 food <<<60, 500>, <60, 500>, <0,0>>, OFFSET food11>
    food13 food <<<60, 540>, <60, 540>, <0,0>>, OFFSET food12>
    food14 food <<<100, 540>, <100, 540>, <0,0>>, OFFSET food13>
    food15 food <<<100, 580>, <100, 580>, <0,0>>, OFFSET food14>
    food16 food <<<100, 620>, <100, 620>, <0,0>>, OFFSET food15>
    food17 food <<<100, 660>, <100, 660>, <0,0>>, OFFSET food16>
    food18 food <<<100, 60>, <100, 60>, <0,0>>, OFFSET food17>
    food19 food <<<140, 60>, <140, 60>, <0,0>>, OFFSET food18>
    food20 food <<<180, 60>, <180, 60>, <0,0>>, OFFSET food19>
    food21 food <<<220, 60>, <220, 60>, <0,0>>, OFFSET food20>
    food22 food <<<260, 60>, <260, 60>, <0,0>>, OFFSET food21>
    food23 food <<<300, 60>, <300, 60>, <0,0>>, OFFSET food22>
    food24 food <<<300, 100>, <300, 100>, <0,0>>, OFFSET food23>
    food25 food <<<300, 140>, <300, 140>, <0,0>>, OFFSET food24>
    food26 food <<<220, 100>, <220, 100>, <0,0>>, OFFSET food25>
    food27 food <<<220, 140>, <220, 140>, <0,0>>, OFFSET food26>
    food28 food <<<220, 180>, <220, 180>, <0,0>>, OFFSET food27>
    food29 food <<<220, 220>, <220, 220>, <0,0>>, OFFSET food28>
    food30 food <<<180, 140>, <180, 140>, <0,0>>, OFFSET food29>
    food31 food <<<140, 140>, <140, 140>, <0,0>>, OFFSET food30>
    food32 food <<<100, 140>, <100, 140>, <0,0>>, OFFSET food31>
    food33 food <<<180, 220>, <180, 220>, <0,0>>, OFFSET food32>
    food34 food <<<140, 220>, <140, 220>, <0,0>>, OFFSET food33>
    food35 food <<<260, 220>, <260, 220>, <0,0>>, OFFSET food34>
    food36 food <<<300, 220>, <300, 220>, <0,0>>, OFFSET food35>
    food37 food <<<340, 220>, <340, 220>, <0,0>>, OFFSET food36>
    food38 food <<<380, 220>, <380, 220>, <0,0>>, OFFSET food37>
    food39 food <<<380, 180>, <380, 180>, <0,0>>, OFFSET food38>
    food40 food <<<380, 140>, <380, 140>, <0,0>>, OFFSET food39>
    food41 food <<<380, 100>, <380, 100>, <0,0>>, OFFSET food40>
    food42 food <<<380, 60>, <380, 60>, <0,0>>, OFFSET food41>
    food43 food <<<300, 100>, <300, 100>, <0,0>>, OFFSET food42>
    food44 food <<<300, 140>, <300, 140>, <0,0>>, OFFSET food43>
    food45 food <<<340, 140>, <340, 140>, <0,0>>, OFFSET food44>
    food46 food <<<60, 660>, <60, 660>, <0,0>>, OFFSET food45>
    food47 food <<<60, 700>, <60, 700>, <0,0>>, OFFSET food46>
    food48 food <<<60, 740>, <60, 740>, <0,0>>, OFFSET food47>
    food49 food <<<60, 780>, <60, 780>, <0,0>>, OFFSET food48>
    food50 food <<<60, 820>, <60, 820>, <0,0>>, OFFSET food49>
    food51 food <<<60, 860>, <60, 860>, <0,0>>, OFFSET food50>
    food52 food <<<60, 900>, <60, 900>, <0,0>>, OFFSET food51>
    food53 food <<<100, 340>, <100, 340>, <0,0>>, OFFSET food52>
    food54 food <<<100, 460>, <100, 460>, <0,0>>, OFFSET food53>
    food55 food <<<100, 740>, <100, 740>, <0,0>>, OFFSET food54>
    food56 food <<<100, 900>, <100, 900>, <0,0>>, OFFSET food55>
    food57 food <<<140, 260>, <140, 260>, <0,0>>, OFFSET food56>
    food58 food <<<140, 300>, <140, 300>, <0,0>>, OFFSET food57>
    food59 food <<<140, 340>, <140, 340>, <0,0>>, OFFSET food58>
    food60 food <<<140, 460>, <140, 460>, <0,0>>, OFFSET food59>
    food61 food <<<140, 740>, <140, 740>, <0,0>>, OFFSET food60>
    food62 food <<<140, 780>, <140, 780>, <0,0>>, OFFSET food61>
    food63 food <<<140, 820>, <140, 820>, <0,0>>, OFFSET food62>
    food64 food <<<140, 900>, <140, 900>, <0,0>>, OFFSET food63>
    food65 food <<<180, 380>, <180, 380>, <0,0>>, OFFSET food64>
    food66 food <<<180, 420>, <180, 420>, <0,0>>, OFFSET food65>
    food67 food <<<180, 460>, <180, 460>, <0,0>>, OFFSET food66>
    food68 food <<<180, 500>, <180, 500>, <0,0>>, OFFSET food67>
    food69 food <<<180, 540>, <180, 540>, <0,0>>, OFFSET food68>
    food70 food <<<180, 580>, <180, 580>, <0,0>>, OFFSET food69>
    food71 food <<<180, 620>, <180, 620>, <0,0>>, OFFSET food70>
    food72 food <<<180, 660>, <180, 660>, <0,0>>, OFFSET food71>
    food73 food <<<180, 700>, <180, 700>, <0,0>>, OFFSET food72>
    food74 food <<<180, 740>, <180, 740>, <0,0>>, OFFSET food73>
    food75 food <<<180, 820>, <180, 820>, <0,0>>, OFFSET food74>
    food76 food <<<180, 900>, <180, 900>, <0,0>>, OFFSET food75>
    food77 food <<<180, 340>, <180, 340>, <0,0>>, OFFSET food76>
    food78 food <<<220, 340>, <220, 340>, <0,0>>, OFFSET food77>
    food79 food <<<220, 620>, <220, 620>, <0,0>>, OFFSET food78>
    food80 food <<<220, 820>, <220, 820>, <0,0>>, OFFSET food79>
    food81 food <<<220, 900>, <220, 900>, <0,0>>, OFFSET food80>
    food82 food <<<260, 300>, <260, 300>, <0,0>>, OFFSET food81>
    food83 food <<<260, 340>, <260, 340>, <0,0>>, OFFSET food82>
    food84 food <<<260, 380>, <260, 380>, <0,0>>, OFFSET food83>
    food85 food <<<260, 420>, <260, 420>, <0,0>>, OFFSET food84>
    food86 food <<<260, 460>, <260, 460>, <0,0>>, OFFSET food85>
    food87 food <<<260, 500>, <260, 500>, <0,0>>, OFFSET food86>
    food88 food <<<260, 540>, <260, 540>, <0,0>>, OFFSET food87>
    food89 food <<<260, 580>, <260, 580>, <0,0>>, OFFSET food88>
    food90 food <<<260, 620>, <260, 620>, <0,0>>, OFFSET food89>
    food91 food <<<260, 820>, <260, 820>, <0,0>>, OFFSET food90>
    food92 food <<<260, 900>, <260, 900>, <0,0>>, OFFSET food91>
    food93 food <<<300, 260>, <300, 260>, <0,0>>, OFFSET food92>
    food94 food <<<300, 300>, <300, 300>, <0,0>>, OFFSET food93>
    ;food95 food <<<300, 420>, <300, 420>, <0,0>>, OFFSET food94>
    food96 food <<<300, 540>, <300, 540>, <0,0>>, OFFSET food94>
    food97 food <<<300, 620>, <300, 620>, <0,0>>, OFFSET food96>
    food98 food <<<300, 700>, <300, 700>, <0,0>>, OFFSET food97>
    food99 food <<<300, 740>, <300, 740>, <0,0>>, OFFSET food98>
    food100 food <<<300, 780>, <300, 780>, <0,0>>, OFFSET food99>
    food101 food <<<300, 820>, <300, 820>, <0,0>>, OFFSET food100>
    food102 food <<<300, 860>, <300, 860>, <0,0>>, OFFSET food101>
    food103 food <<<300, 900>, <300, 900>, <0,0>>, OFFSET food102>
    food104 food <<<340, 300>, <340, 300>, <0,0>>, OFFSET food103>
    food105 food <<<340, 540>, <340, 540>, <0,0>>, OFFSET food104>
    food106 food <<<340, 620>, <340, 620>, <0,0>>, OFFSET food105>
    food107 food <<<340, 700>, <340, 700>, <0,0>>, OFFSET food106>
    food108 food <<<340, 900>, <340, 900>, <0,0>>, OFFSET food107>
    food109 food <<<380, 300>, <380, 300>, <0,0>>, OFFSET food108>
    food110 food <<<380, 540>, <380, 540>, <0,0>>, OFFSET food109>
    food111 food <<<380, 620>, <380, 620>, <0,0>>, OFFSET food110>
    food112 food <<<380, 660>, <380, 660>, <0,0>>, OFFSET food111>
    food113 food <<<380, 700>, <380, 700>, <0,0>>, OFFSET food112>
    food114 food <<<380, 740>, <380, 740>, <0,0>>, OFFSET food113>
    food115 food <<<380, 780>, <380, 780>, <0,0>>, OFFSET food114>
    food116 food <<<380, 820>, <380, 820>, <0,0>>, OFFSET food115>
    food117 food <<<380, 900>, <380, 900>, <0,0>>, OFFSET food116>
    food118 food <<<420, 300>, <420, 300>, <0,0>>, OFFSET food117>
    food119 food <<<420, 540>, <420, 540>, <0,0>>, OFFSET food118>
    food120 food <<<420, 820>, <420, 820>, <0,0>>, OFFSET food119>
    food121 food <<<420, 900>, <420, 900>, <0,0>>, OFFSET food120>
    food122 food <<<420, 60>, <420, 60>, <0,0>>, OFFSET food121>
    food186 food <<<460, 60>, <460, 60>, <0,0>>, OFFSET food122>
    food187 food <<<460, 100>, <460, 100>, <0,0>>, OFFSET food186>
    food188 food <<<460, 140>, <460, 140>, <0,0>>, OFFSET food187>
    food189 food <<<460, 180>, <460, 180>, <0,0>>, OFFSET food188>
    food190 food <<<460, 220>, <460, 220>, <0,0>>, OFFSET food189>
    food191 food <<<460, 300>, <460, 300>, <0,0>>, OFFSET food190>
    food192 food <<<460, 540>, <460, 540>, <0,0>>, OFFSET food191>
    food193 food <<<460, 620>, <460, 620>, <0,0>>, OFFSET food192>
    food194 food <<<460, 660>, <460, 660>, <0,0>>, OFFSET food193>
    food195 food <<<460, 700>, <460, 700>, <0,0>>, OFFSET food194>
    food196 food <<<460, 740>, <460, 740>, <0,0>>, OFFSET food195>
    food197 food <<<460, 780>, <460, 780>, <0,0>>, OFFSET food196>
    food198 food <<<460, 820>, <460, 820>, <0,0>>, OFFSET food197>
    food199 food <<<460, 900>, <460, 900>, <0,0>>, OFFSET food198>
    food200 food <<<500, 140>, <500, 140>, <0,0>>, OFFSET food199>
    food201 food <<<500, 220>, <500, 220>, <0,0>>, OFFSET food200>
    food202 food <<<500, 300>, <500, 300>, <0,0>>, OFFSET food201>
    food203 food <<<500, 540>, <500, 540>, <0,0>>, OFFSET food202>
    food204 food <<<500, 620>, <500, 620>, <0,0>>, OFFSET food203>
    food205 food <<<500, 700>, <500, 700>, <0,0>>, OFFSET food204>
    food206 food <<<500, 900>, <500, 900>, <0,0>>, OFFSET food205>
    food207 food <<<540, 60>, <540, 60>, <0,0>>, OFFSET food206>
    food208 food <<<540, 100>, <540, 100>, <0,0>>, OFFSET food207>
    food209 food <<<540, 140>, <540, 140>, <0,0>>, OFFSET food208>
    food210 food <<<540, 220>, <540, 220>, <0,0>>, OFFSET food209>
    food211 food <<<540, 260>, <540, 260>, <0,0>>, OFFSET food210>
    food212 food <<<540, 300>, <540, 300>, <0,0>>, OFFSET food211>
    food213 food <<<540, 540>, <540, 540>, <0,0>>, OFFSET food212>
    food214 food <<<540, 620>, <540, 620>, <0,0>>, OFFSET food213>
    food215 food <<<540, 700>, <540, 700>, <0,0>>, OFFSET food214>
    food216 food <<<540, 740>, <540, 740>, <0,0>>, OFFSET food215>
    food217 food <<<540, 780>, <540, 780>, <0,0>>, OFFSET food216>
    food218 food <<<540, 820>, <540, 820>, <0,0>>, OFFSET food217>
    food219 food <<<540, 860>, <540, 860>, <0,0>>, OFFSET food218>
    food220 food <<<540, 900>, <540, 900>, <0,0>>, OFFSET food219>
    food221 food <<<580, 60>, <580, 60>, <0,0>>, OFFSET food220>
    food222 food <<<580, 220>, <580, 220>, <0,0>>, OFFSET food221>
    food223 food <<<580, 300>, <580, 300>, <0,0>>, OFFSET food222>
    food224 food <<<580, 340>, <580, 340>, <0,0>>, OFFSET food223>
    food225 food <<<580, 380>, <580, 380>, <0,0>>, OFFSET food224>
    food226 food <<<580, 420>, <580, 420>, <0,0>>, OFFSET food225>
    food227 food <<<580, 460>, <580, 460>, <0,0>>, OFFSET food226>
    food228 food <<<580, 500>, <580, 500>, <0,0>>, OFFSET food227>
    food229 food <<<580, 540>, <580, 540>, <0,0>>, OFFSET food228>
    food230 food <<<580, 580>, <580, 580>, <0,0>>, OFFSET food229>
    food231 food <<<580, 620>, <580, 620>, <0,0>>, OFFSET food230>
    food232 food <<<580, 820>, <580, 820>, <0,0>>, OFFSET food231>
    food233 food <<<580, 900>, <580, 900>, <0,0>>, OFFSET food232>
    food234 food <<<620, 60>, <620, 60>, <0,0>>, OFFSET food233>
    food235 food <<<620, 100>, <620, 100>, <0,0>>, OFFSET food234>
    food236 food <<<620, 140>, <620, 140>, <0,0>>, OFFSET food235>
    food237 food <<<620, 180>, <620, 180>, <0,0>>, OFFSET food236>
    food238 food <<<620, 220>, <620, 220>, <0,0>>, OFFSET food237>
    food239 food <<<620, 340>, <620, 340>, <0,0>>, OFFSET food238>
    food240 food <<<620, 620>, <620, 620>, <0,0>>, OFFSET food239>
    food241 food <<<620, 820>, <620, 820>, <0,0>>, OFFSET food240>
    food242 food <<<620, 900>, <620, 900>, <0,0>>, OFFSET food241>
    food243 food <<<660, 60>, <660, 60>, <0,0>>, OFFSET food242>
    food244 food <<<660, 140>, <660, 140>, <0,0>>, OFFSET food243>
    food245 food <<<660, 220>, <660, 220>, <0,0>>, OFFSET food244>
    food246 food <<<660, 340>, <660, 340>, <0,0>>, OFFSET food245>
    food247 food <<<660, 380>, <660, 380>, <0,0>>, OFFSET food246>
    food248 food <<<660, 420>, <660, 420>, <0,0>>, OFFSET food247>
    food249 food <<<660, 460>, <660, 460>, <0,0>>, OFFSET food248>
    food250 food <<<660, 500>, <660, 500>, <0,0>>, OFFSET food249>
    food251 food <<<660, 540>, <660, 540>, <0,0>>, OFFSET food250>
    food252 food <<<660, 580>, <660, 580>, <0,0>>, OFFSET food251>
    food253 food <<<660, 620>, <660, 620>, <0,0>>, OFFSET food252>
    food254 food <<<660, 660>, <660, 660>, <0,0>>, OFFSET food253>
    food255 food <<<660, 700>, <660, 700>, <0,0>>, OFFSET food254>
    food256 food <<<660, 740>, <660, 740>, <0,0>>, OFFSET food255>
    food257 food <<<660, 820>, <660, 820>, <0,0>>, OFFSET food256>
    food258 food <<<660, 900>, <660, 900>, <0,0>>, OFFSET food257>
    food259 food <<<700, 60>, <700, 60>, <0,0>>, OFFSET food258>
    food260 food <<<700, 140>, <700, 140>, <0,0>>, OFFSET food259>
    food261 food <<<700, 220>, <700, 220>, <0,0>>, OFFSET food260>
    food262 food <<<700, 260>, <700, 260>, <0,0>>, OFFSET food261>
    food263 food <<<700, 300>, <700, 300>, <0,0>>, OFFSET food262>
    food264 food <<<700, 340>, <700, 340>, <0,0>>, OFFSET food263>
    food265 food <<<700, 460>, <700, 460>, <0,0>>, OFFSET food264>
    food266 food <<<700, 740>, <700, 740>, <0,0>>, OFFSET food265>
    food267 food <<<700, 780>, <700, 780>, <0,0>>, OFFSET food266>
    food268 food <<<700, 820>, <700, 820>, <0,0>>, OFFSET food267>
    food269 food <<<700, 900>, <700, 900>, <0,0>>, OFFSET food268>
    food270 food <<<740, 60>, <740, 60>, <0,0>>, OFFSET food269>
    food271 food <<<740, 140>, <740, 140>, <0,0>>, OFFSET food270>
    food272 food <<<740, 340>, <740, 340>, <0,0>>, OFFSET food271>
    food273 food <<<740, 460>, <740, 460>, <0,0>>, OFFSET food272>
    food274 food <<<740, 540>, <740, 540>, <0,0>>, OFFSET food273>
    food275 food <<<740, 580>, <740, 580>, <0,0>>, OFFSET food274>
    food276 food <<<740, 620>, <740, 620>, <0,0>>, OFFSET food275>
    food277 food <<<740, 660>, <740, 660>, <0,0>>, OFFSET food276>
    food278 food <<<740, 740>, <740, 740>, <0,0>>, OFFSET food277>
    food279 food <<<740, 900>, <740, 900>, <0,0>>, OFFSET food278>
    food280 food <<<780, 60>, <780, 60>, <0,0>>, OFFSET food279>
    food281 food <<<780, 100>, <780, 100>, <0,0>>, OFFSET food280>
    food282 food <<<780, 140>, <780, 140>, <0,0>>, OFFSET food281>
    food283 food <<<780, 180>, <780, 180>, <0,0>>, OFFSET food282>
    food284 food <<<780, 220>, <780, 220>, <0,0>>, OFFSET food283>
    food285 food <<<780, 260>, <780, 260>, <0,0>>, OFFSET food284>
    food286 food <<<780, 300>, <780, 300>, <0,0>>, OFFSET food285>
    food287 food <<<780, 340>, <780, 340>, <0,0>>, OFFSET food286>
    food288 food <<<780, 380>, <780, 380>, <0,0>>, OFFSET food287>
    food289 food <<<780, 420>, <780, 420>, <0,0>>, OFFSET food288>
    food290 food <<<780, 460>, <780, 460>, <0,0>>, OFFSET food289>
    food291 food <<<780, 500>, <780, 500>, <0,0>>, OFFSET food290>
    food292 food <<<780, 540>, <780, 540>, <0,0>>, OFFSET food291>
    food293 food <<<780, 660>, <780, 660>, <0,0>>, OFFSET food292>
    food294 food <<<780, 700>, <780, 700>, <0,0>>, OFFSET food293>
    food295 food <<<780, 740>, <780, 740>, <0,0>>, OFFSET food294>
    food296 food <<<780, 780>, <780, 780>, <0,0>>, OFFSET food295>
    food297 food <<<780, 820>, <780, 820>, <0,0>>, OFFSET food296>
    food298 food <<<780, 860>, <780, 860>, <0,0>>, OFFSET food297>
    food299 food <<<780, 900>, <780, 900>, <0,0>>, OFFSET food298>
    

    
    ;instancia as pílulas
    pill1 pill <<<136, 216>, <136, 216>, <0,0>>, 0>
    pill2 pill< <<176, 816>, <176, 816>, <0,0>>, OFFSET pill1>
    pill3 pill< <<656, 816>, <656, 816>, <0,0>>, OFFSET pill2>
    pill4 pill< <<696, 216>, <696, 216>, <0,0>>, OFFSET pill3>

    map everithing <OFFSET wallInside164, OFFSET food299, OFFSET pill4>

    tempPos     point       <0, 0>
    tempWall    wallTile    <<0, 0>, 0>
    
    RIGHTARROW            BYTE 0
    
    GAMESTATE             BYTE 0

.DATA?
    hWnd HWND ?
    thread1ID DWORD ?
    thread2ID DWORD ?

    
IS_ONLINE    dd FALSE
IS_HOST      dd FALSE
IS_GENERATED dd FALSE

;========= Grafic params =============== 
Dayly_Kof        dw     0  
CircleCount      dd     0
LightsCount      dd     0 ;[0-14] 
LightsPositions:
                 dd     ?, ?, ? ;1
                 dd     ?, ?, ? ;2
                 dd     ?, ?, ? ;3
                 dd     ?, ?, ? ;4
                 dd     ?, ?, ? ;5
                 dd     ?, ?, ? ;6
                 dd     ?, ?, ? ;7
                 dd     ?, ?, ? ;8
                 dd     ?, ?, ? ;9
                 dd     ?, ?, ? ;10
                 dd     ?, ?, ? ;11
                 dd     ?, ?, ? ;12
                 dd     ?, ?, ? ;13
                 dd     ?, ?, ? ;14  ;MAX
;=======================================

;==== Worls params ===========
WorldPower       dd      10 
WorldLength      dd      ?     
WorldWidth       dd      ?     
WorldHeight      dd      150  
SizeWorld        dd      ?
;=============================

FileNames        dd      ?
FileCount        dd      ?
ChosenFile       dd      ?


;==== Water params ===========
WaterLvl         dd      60 
;=============================

;==== Sky params =============
;Sky data
SkyLand          dd       ?
;Sky params
SkyLength        dd       ?
SkyWidth         dd       ?
SkyHieght        dd       120  
SizeSky          dd       ? 
;==============================

Inventory           dd    ?
InventorySize       dd    ?
InventoryMainOffset =     9*3*4

SmallCraft          dd    ?
BigCraft            dd    ?
SMALL_CRAFT_SIZE    =     5
BIG_CRAFT_SIZE      =     10

    ; 0     1     2     3      4
    ;       bigBag_craft_arr_example   positions:     
    ; ======= =======
    ; =  1  = =  2  =
    ; =     = =     =         =======
    ; ======= =======         =  0  =
    ; ======= =======  === >  =     =
    ; =  3  = =  4  =         =======
    ; =     = =     = 
    ; ======= =======

;=======================================
ServerIp         db       "192.168.0.101", 0
ServerPortUDP    dd       9999
ServerPortTCP    dd       10000
;=======================================

;=============================================
filename         db       "testSave.txt", 0 
filenameSky      db       "testSaveSky.txt", 0
;==============================================

;== Controller Global varibales ===============
PlayerPos        dd       50.0, 200.0, 50.0
PlayerTurn       dd       0.0, 0.0, 0.0
;Data for destroying blocks
UnderWater       dd       0

selectCubeData   dd       0.0, 0.0, 0.0
prevCubePos      dd       0, 0, 0

flag             dd       0
;==============================================

;== Animations Global Variables =============
Anim_Hand_Position dd     0.0, 0.0, 0.0
Anim_Hand_Turn     dd     0.0, 0.0, 0.0
XAxisMuliplier     dd     0.1
animate            dd     1
;============================================== 

;== Global variables for destroyed blocks =====
destrHeap             dd 0
arrayOfDroppedBlocks  dd 0
destroyedBlocksVector dd 0.0, 0.0, 0.0
;==============================================

;== Global vars for inventory=================
currentChosenCell     dd 0
chosenBlockFromInv    dd 0
currentNumOfHearts    dd 10
;=============================================  

;=========== UI data ========================
UI_MODE            dd        UI_GAME
;==============================================

;========== Other ========================
ZERO_VEC_3       dd        0.0, 0.0, 0.0
frameCount       dd        0
;=========================================

blocksTurn       dd        0.0, 0.0, 0.0

;========= Interface ======================
died_text        db        'You Died...'
died_text_len    dd        $ - died_text

Respawn_text     db        'Respawn'
IsPlayerDied     dd        0

set_radius_text  db        'Set the render radius'
set_radius_text_len dd     $ - set_radius_text
RenderRadius_input  db   0,  20   dup  (?)


ConnectionIP_input       db   0, 20   dup  (?)
ConnectionUdpPort_input  db   0, 20   dup  (?)
ConnectionTcpPort_input  db   0, 20   dup  (?)

host_error       dd   0 ;<-- adress to text  (0 - without text)
host_error_len   dd   0 ;<-- len of text 

connect_error     dd   0 ;<-- adress to text  (0 - without text)
connect_error_len dd   0 ;<-- len of text 

not_implemented_text  db 'not implemented yet..'
not_implemented_text_len  dd  $ - not_implemented_text
;===========================================

RENDER_RADIUS   dd  20


global_building_time  dd  1000

_IS_SERVER_DEBUD  dd   FALSE




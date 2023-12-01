;========= Grafic params =============== 
Dayly_Kof        dw     0  
LightsCount      db     1 ;Byte [0-15] 
LightsPositions:
                 dd     10.0, 3.0, 7.0
;=======================================

;==== Worls params ===========
WorldPower       dd      10 
WorldLength      dd      ?     
WorldWidth       dd      ?     
WorldHeight      dd      150  
SizeWorld        dd      ?
;=============================

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

;=======================================
serverIp         db       "127.0.0.1", 0
serverPortUDP    dd       9999
serverPortTCP    dd       10000
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

;========== Other ========================
ZERO_VEC_3       dd        45.0, 45.0, 0.0
;=========================================







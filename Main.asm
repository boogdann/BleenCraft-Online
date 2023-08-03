format PE GUI 4.0
stack 0x10000
entry Start

;===============Module incleude================
include "win32a.inc" 
;В первую очередь подключить модуль GraficAPI!
include "Grafic\GraficAPI\GraficAPI.asm"
include "Units\Asm_Includes\Const.asm"
include "Units\Movement\keys.code"
include "Units\Movement\move.asm"
include "Units\Movement\Vmove.asm"
;==============================================

section '.text' code readable executable     

Start:
  ;================Modules initialize=================
  stdcall gf_grafic_init
  ;===================================================
  
  ;=============Project data initialize=========================
  stdcall gf_UploadObj3D, obj_cube_name, obj_CubeHandle 

  stdcall gf_UploadTexture, tx_grassName, tx_grassHandle 
  stdcall gf_UploadTexture, tx_BOGDAN_Name, tx_BOGDANHandle 
  stdcall gf_UploadTexture, tx_Brick_Name, tx_BrickHandle
  
  stdcall Field.Initialize
  ;========================================
  
  ;===================Project circle==================
  .MainCycle:
        invoke  GetMessage, msg, 0, 0, 0
        invoke  TranslateMessage, msg
        invoke  DispatchMessage, msg
        jmp     .MainCycle
  ;====================================================
            
proc WindowProc uses ebx,\
     hWnd, uMsg, wParam, lParam

        stdcall checkMoveKeys
        stdcall OnMouseMove, сameraTurn, [sensitivity]
        
        switch  [uMsg]
        case    .Render,        WM_PAINT
        case    .Destroy,       WM_DESTROY
        case    .KeyDown,       WM_KEYDOWN
        case    .KeyChar,       WM_CHAR
        
        invoke  DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
        jmp     .Return

  .Render:
        ;Рендер
        stdcall RenderScene
        jmp     .ReturnZero
  .KeyChar:
        ;Клавиши 1
        stdcall OnCharDown, [wParam]
        jmp     .ReturnZero
  .KeyDown:
        ;Клавиши 2
        stdcall OnKeyDown, [wParam]
        jmp     .ReturnZero
  .Destroy:
        invoke ExitProcess, 1
  .ReturnZero:
        xor     eax, eax
  .Return:
        ret
endp



proc RenderScene
    ;Проиницилизировать основные данные кадра
    stdcall gf_RenderBegin, сameraPos, сameraTurn
  
    ;Проиницелизтровать источники света
    stdcall gf_CreateLightning, [LightsCount], LightsPositions
    
    ;Рендер ландшафта:
    ;Ноль на конце (isOnlyWater) - Основной рендер
    stdcall gf_RenderMineLand, Field.Blocks, [WorldLength], [WorldWidth], [WorldHeight], 0
       
    ;===========;Блок в позиции cвечки для наглядности================                      
    stdcall gf_renderObj3D, obj_CubeHandle, [tx_BrickHandle], 0,\
                            LightsPositions, cubeTurn, [cubeScale]  
                            
    ;Пример использования рендера выделенного объекта
    stdcall gf_RenderSelectObj3D, obj_CubeHandle,\ 
                            LightsPositions, cubeTurn, [cubeScale] 
    ;P.S. Для выделения объекта нужно применить специальный ререндер!!!
    ;=================================================================           
    
                            
    ;Единица на конце (isOnlyWater) - Рендер воды                       
    stdcall gf_RenderMineLand, Field.Blocks, [WorldLength], [WorldWidth], [WorldHeight], 1
    ;Рендер облаков
    stdcall gf_renderSkyObjs, SkyLand, [SkyLength], [SkyWidth], [SkyHieght]
    
    ;Окончание рендера кадра
    stdcall gf_RenderEnd
  ret
endp

  include "Units\Asm_Includes\Code.asm"

section '.data' data readable writeable
         ;Обязательно нужно выставить переменные окружения:
         ;===============Global variables===================
         ;Путь к объектам относительно исполняемого:
         GF_OBJ_PATH        db     "Assets\ObjectsPack\", 0
         ;Путь к текстурам относительно исполняемого:
         GF_TEXTURE_PATH    db     "Assets\TexturesPack\", 0
         ;Путь к юниту графики 
         GF_PATH            db     "Grafic\GraficAPI\", 0
         GF_PATH_LEN        db     $ - GF_PATH
         ;===================================================
                  
                  
         ;Пример данных:
         ;=======================Project data==========================
         ;Объекты
         obj_cube_name   db   "LCube.mobj", 0 ;(GF_OBJ_PATH)
         obj_CubeHandle  dd   ?, ? ;Да, тут именно 8 байт
         
         ;Текстуры
         tx_grassName    db   "Grass_64.mbmw", 0 
         tx_BOGDAN_Name  db   "BOGDANI_64.mbmw", 0
         tx_Brick_Name   db   "Brick_64.mbmw", 0
         ;texture Handles:
         tx_grassHandle  dd   ?
         tx_BOGDANHandle dd   ?
         tx_BrickHandle  dd   ?
         
         ;Позиция объекта:
         cubePos         dd   1.0, 5.0, 0.0
         ;Поворот объекта:  (в градусах)
         cubeTurn        dd   0.0, 0.0, 0.0
         ;Размер объекта:
         cubeScale       dd   1.0

         ;Позиция головы
         сameraPos       dd    0.0, 0.0, -4.0
         ;Поворот головы:  (в градусах)
         сameraTurn      dd    0.0, 0.0, 0.0 ;(x, y - пользуйся, z - не функциональна)
         ;P.S. z - мемная координата (как просмотр из-за стены под углом в rainbow six siege),
         ;но по итогу изза ненадобности функционал z был вырезан, так что неважно чему он равен
         
         ;=================Lightning Data==================   
         LightsCount   dd    1 ;Byte [0-255]   ;Количество свечек
         LightsPositions:
              dd   10.0, 3.0, 7.0  ;Тут стоит блок для наглядности
              
         gf_DaylyKof    db    0
         ;Пока не реализованно
         ;В планах сделать так чтобы по итогу 255 стыкавалось с 0
         ;==================================================
         ;================================================================
         
         
         ;=======================Global variables 2=======================
         ;Дискриптор кучи:
         hHeap           dd         ?
         ;Параметры окна:
         WindowRect      RECT       ?, ?, ?, ?
         ;P.S. WindowRect.right - Ширина экрана | WindowRect.bottom - Высота экрана
         
         WorldLength dd Field.LENGTH ;x
         WorldWidth  dd Field.WIDTH  ;y
         WorldHeight dd Field.HEIGHT ;z
         
         ;Богдан вынеси это себе куданибудь
         SkyLength   dd   10
         SkyWidth    dd   10
         SkyHieght   dd   100
         ;Небо
         SkyLand  db 1,0,0,0,0,0,0,0,0,0,\ 
                     0,1,1,0,1,0,0,0,1,1,\
                     0,0,0,0,0,1,0,0,1,0,\
                     0,0,0,0,0,0,0,0,0,1,\
                     0,0,0,0,0,0,0,0,0,1,\
                     0,0,0,0,1,1,1,1,0,0,\ 
                     0,0,0,1,1,1,1,1,0,0,\
                     1,1,0,0,0,0,1,1,1,0,\
                     1,1,1,0,1,1,0,0,0,0,\ 
                     1,0,1,0,1,1,1,0,0,0
         ;================================================================
         
         ;=============Data imports================
         ;Добавить импорты данных нужные GraficAPI
         include "Grafic\GraficAPI\GraficAPI.inc"
         include "Units\Movement\MConst.asm"   
         ;=========================================   

section '.idata' import data readable writeable

  ;=============Library imports==============
  library kernel32, 'KERNEL32.DLL',\
	        user32,   'USER32.DLL',\    
          opengl32, 'opengl32.DLL',\    ;1) ;Добавь нужные для GraficAPI библиотеки!
          gdi32,    'GDI32.DLL'         ;2) 
                                       
  include 'api\kernel32.inc'
  include 'api\user32.inc'
  ;===========Data imports============
  include "Units\Asm_Includes\Di.asm"
  include "Units\Asm_Includes\Du.asm"

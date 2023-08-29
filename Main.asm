format PE GUI 4.0
stack 0x10000
entry Start

;===============Module incleude================
include "win32a.inc" 
include "Grafic\GraficAPI\GraficAPI.asm"
include "CotrollerAPI\CotrollerAPI.asm"
include "Units\Asm_Includes\Const.asm"
include "Units\Asm_Includes\Code.asm"
;==============================================

section '.text' code readable executable     

Start:
    invoke  GetProcessHeap
    mov    [hHeap], eax    
  ;================Modules initialize=================
  stdcall Field.Initialize, [WorldPower] ,[WorldHeight] 
  mov     eax, [Field.Length]
  mov     [WorldLength], eax
  mov     eax, [Field.Width]
  mov     [WorldWidth], eax
      
  stdcall gf_grafic_init
  ;Флаг = 1 - показать мышку
  stdcall ct_change_mouse, 0
  ;===================================================  
  
  ;=============Project data initialize=========================
  stdcall gf_UploadObj3D, obj_cube_name, obj_CubeHandle 

  stdcall gf_UploadTexture, tx_grassName, tx_grassHandle 
  stdcall gf_UploadTexture, tx_BOGDAN_Name, tx_BOGDANHandle 
  stdcall gf_UploadTexture, tx_Brick_Name, tx_BrickHandle
  ;=============================================================
  
  ;================Params initialize=====================
  ;Позволяет автоматически изменять переменную День-Ночь
  ;1 - Вкл | 0 - Отключение
  stdcall gf_subscribeDayly, Dayly_Kof, 1
  ;======================================================
  
  ;===================Project circle==================
  .MainCycle:
        invoke  GetMessage, msg, 0, 0, 0
        invoke  TranslateMessage, msg
        invoke  DispatchMessage, msg
        jmp     .MainCycle
  ;====================================================
            
proc WindowProc uses ebx,\
     hWnd, uMsg, wParam, lParam
     
        stdcall ct_move_check, сameraPos, сameraTurn,\
                               [Field.Blocks], [WorldLength], [WorldWidth], [WorldHeight]                      
        ;Debug only:
        ;stdcall checkMoveKeys
        ;stdcall OnMouseMove, сameraTurn, [sensitivity]
        
        switch  [uMsg]
        case    .Render,        WM_PAINT
        case    .Destroy,       WM_DESTROY
        case    .Movement,      WM_KEYDOWN  
        
        invoke  DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
        jmp     .Return

  .Render:
        
        ;Рендер
        stdcall RenderScene
        
        mov [isFalling], 1
        
        jmp     .ReturnZero
        
        .Movement:
        stdcall ct_on_keyDown, [wParam] 
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
    ;Последний флаг отвечает за 0 - норма | 1 - под водой
    stdcall gf_CreateLightning, LightsCount, LightsPositions, 0
    ;P.S. Функция в начале обязательна даже с флагом ноль для
    ;регистрации твоей переменной в модуле
    
    ;Рендер ландшафта:
    ;Ноль на конце (isOnlyWater) - Основной рендер
    stdcall gf_RenderMineLand, [Field.Blocks], [WorldLength], [WorldWidth],\
                                               [WorldHeight], сameraPos, сameraTurn, 0
       
    ;===========;Блок в позиции cвечки для наглядности================  
    ;Последний параметр: 0-5 степень разрушенности                     
    stdcall gf_renderObj3D, obj_CubeHandle, [tx_BrickHandle], 0,\
                            LightsPositions, cubeTurn, [cubeScale], 3  
                            
    ;Пример использования ререндера выделенного объекта (рендер рамки)
    stdcall gf_RenderSelectObj3D, obj_CubeHandle,\ 
                            LightsPositions, cubeTurn, [cubeScale] 
    ;P.S. Для выделения объекта нужно применить специальный ререндер!!!
    ;=================================================================    
                            
    ;Единица на конце (isOnlyWater) - Рендер воды                       
    stdcall gf_RenderMineLand, [Field.Blocks], [WorldLength], [WorldWidth],\
                                               [WorldHeight], сameraPos, сameraTurn, 1
    ;Рендер облаков
    stdcall gf_renderSkyObjs, SkyLand, [SkyLength], [SkyWidth], [SkyHieght]
    
    ;Окончание рендера кадра
    stdcall gf_RenderEnd
  ret
endp

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
         ;Оптимизационное ограничение на видимлсть блоков:
         GF_BLOCKS_RADIUS   dd     400, 400, 40 ;(По x, y, z)
         ;===================================================
                  
                  
         ;=======================Project data==========================
         ;Объекты
         obj_cube_name   db   "LCube.mobj", 0 ;(GF_OBJ_PATH)
         obj_CubeHandle  dd   ?, ? ;Да, тут именно 8 байт
         
         ;Текстуры
         tx_grassName    db   "Grass_64.mbmw", 0 
         tx_BOGDAN_Name  db   "BOGDANI2_64.mbmw", 0
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
         сameraPos       dd    500.0, 110.0, 500.0
         ;Поворот головы
         сameraTurn      dd    0.0, 0.0, 0.0
         
         ;=================Lightning Data==================   
         LightsCount   db    1 ;Byte [0-15]   ;Количество свечек
         LightsPositions:
              dd   10.0, 3.0, 7.0  ;Тут стоит блок для наглядности
              
         ;Отвечает за измененя параметров сцены (день - ночь)     
         Dayly_Kof    dw    0   ;0 - 65535
         ;P.S имеется возможность установить флаг для автоматического
         ;изменения этого параметра (В начале (И он уже установлен))
         ;================================================================
         
         
         ;=======================Global variables 2=======================
         ;Дискриптор кучи:
         hHeap           dd         ?
         ;Параметры окна:
         WindowRect      RECT       ?, ?, ?, ?
         ;P.S. WindowRect.right - Ширина экрана | WindowRect.bottom - Высота экрана
         
         WorldPower  dd 10 ; размер мира задаётся степенью двойки
         
         WorldLength dd ? ;x НЕ ТРОГАТЬ
         WorldWidth  dd ? ;y
         WorldHeight dd 250  ;z
         
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
         include "CotrollerAPI\CotrollerAPI.inc"
         ;include "Units\Movement\MConst.asm"  
         ;=========================================   

section '.idata' import data readable writeable

  ;=============Library imports==============
  library kernel32, 'KERNEL32.DLL',\
	        user32,   'USER32.DLL',\    
          opengl32, 'opengl32.DLL',\   
          gdi32,    'GDI32.DLL'          
                                       
  include 'api\kernel32.inc'
  include 'api\user32.inc'
  ;===========Data imports============
  include "Units\Asm_Includes\Di.asm"
  include "Units\Asm_Includes\Du.asm"

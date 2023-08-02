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
  ;================Module initialize==================
  ;Сначала нужно проиницилизировать модуль
  ;P.S. она также иницициализирует всю оконную мишуру
  stdcall gf_grafic_init
  ;===================================================
  
  ;=============Project data initialize=========================
  ;Теперь в качестве примера загрузим куб в видеопамять
  stdcall gf_UploadObj3D, obj_cube_name, obj_CubeHandle
  ;P.S. Для загрузки объекта мы кидаем адресс(!) на Handle (dd ?, ?)

  ;Далее загрузим тексуру земли в видеопамять и получим Handle
  stdcall gf_UploadTexture, tx_grassName 
  mov [tx_grassHandle], eax
  stdcall gf_UploadTexture, tx_BOGDAN_Name 
  mov [tx_BOGDANHandle], eax
  stdcall gf_UploadTexture, tx_Brick_Name 
  mov [tx_BrickHandle], eax
  
  stdcall Field.Initialize
  
  invoke  ShowCursor, 0
  ;===============================================================
  
  
  
  ;===================Project circle==================
  ;Стандартный цикл оконной процедуры
  .MainCycle:
        invoke  GetMessage, msg, 0, 0, 0
        invoke TranslateMessage, msg
        invoke  DispatchMessage, msg
        jmp     .MainCycle
  ;====================================================
            
        
;К примеру простейшая оконная процедура
proc WindowProc uses ebx,\
     hWnd, uMsg, wParam, lParam

        stdcall checkMoveKeys
        stdcall OnMouseMove, сameraTurn, [sensitivity]
        
        ;К макросам тоже присмотрись) (Если что кину)
        switch  [uMsg]
        case    .Render,        WM_PAINT
        case    .Destroy,       WM_DESTROY
        case    .KeyDown,       WM_KEYDOWN
        case    .KeyChar,       WM_CHAR
        
        invoke  DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
        jmp     .Return

  .Render:
        ;Самое интересное это то что в функции RenderScene
        ;(Она расположена ниже)
        stdcall RenderScene
        jmp     .ReturnZero
  
  .KeyChar:
        stdcall OnCharDown, [wParam]
        jmp     .ReturnZero
        
  .KeyDown:
        ;Выход по Esc
        stdcall OnKeyDown, [wParam]
        jmp     .ReturnZero
 
  .Destroy:
        invoke ExitProcess, 1
  .ReturnZero:
        xor     eax, eax
  .Return:
        ret
endp


;(От себя рекоменлую организовать эту функцию лишь как простой вывод и
;вынести все действия над объктами наружу, не пихая всё сюда), но дело твоё
;Пример процедуры для рендера сцены
proc RenderScene
    ;Сначала нужно проиницилизировать основные данные кадра
    stdcall gf_RenderBegin, сameraPos, сameraTurn
  
    ;Также нужно проиницелизтровать источники света
    stdcall gf_CreateLightning, [LightsCount], LightsPositions
    
    ;Рендер ландшафта: (LandDataArray - 3-x мерный массив ландшафта) (X, Y, Z - размеры)
    ;Ноль на конце (isOnlyWater) - Основной рендер
    stdcall gf_RenderMineLand, Field.Blocks, [WorldLength], [WorldWidth], [WorldHeight], obj_CubeHandle, 0
    
    ;(Например рендер куба с текстурой земли)  (летает одинокий)
    stdcall gf_renderObj3D, obj_CubeHandle, [tx_grassHandle],\
                            SunPosition, cubeTurn, [cubeScale]  
                            ;Блок в позиции солца для наглядности!!!
                            
    stdcall gf_renderObj3D, obj_CubeHandle, [tx_BrickHandle],\
                            LightsPositions, cubeTurn, [cubeScale]  
                            ;Блок в позиции cвечки для наглядности!!!
    ;=======Можно вырезать========
    fld [tmp_pos]
    fadd [tmp_add]
    fstp [tmp_pos]
    fld [tmp_pos]
    fcos
    fmul [tmp_mul]
    fadd [tmp_add_2]
    fstp dword[LightsPositions]
    ;==============================                        
    
                            
    ;Единица на конце (isOnlyWater) - Рендер воды                       
    stdcall gf_RenderMineLand, Field.Blocks, [WorldLength], [WorldWidth], [WorldHeight], obj_CubeHandle, 1
    
    ;В самом конце рендера сцены нужно:
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
         obj_cube_name   db   "LCube.mobj", 0 ;(GF_OBJ_PATH) (тип .mobj!)
         ;P.S. L - в начале это файл с генерацией .mobj c uint8
         ;     B - в начале это файл с генерацией .mobj c uint16
         ;     B - cтавить не обязательно (Это по дефолту)
         obj_CubeHandle  dd   ?, ? ;Да, тут именно 8 байт, так нужно!!!
         
         ;Текстуры
         tx_grassName    db   "Grass_64.mbmw", 0 ;(GF_TEXTURE_PATH) 
         tx_BOGDAN_Name  db   "BOGDANI_64.mbmw", 0 ;(GF_TEXTURE_PATH) 
         tx_Brick_Name   db   "Brick_64.mbmw", 0 ;(GF_TEXTURE_PATH) 
         ;texture Handles:
         tx_grassHandle  dd   ?
         tx_BOGDANHandle dd   ?
         tx_BrickHandle  dd   ?
         
         ;Позиция объекта:
         cubePos         dd   1.0, 5.0, 0.0
         ;Поворот объекта:  (в градусах)
         cubeTurn        dd   0.0, 0.0, 0.0
         ;Размер объекта:
         cubeScale       dd   0.5

         ;Позиция головы
         сameraPos       dd    0.0, 0.0, -4.0
         ;Поворот головы:  (в градусах)
         сameraTurn      dd    0.0, 0.0, 0.0 ;(x, y - пользуйся, z - не функциональна)
         ;P.S. z - мемная координата (как просмотр из-за стены под углом в rainbow six siege),
         ;но по итогу изза ненадобности функционал z был вырезан, так что неважно чему он равен
         
         ;======Можно вырезать==========
         ;Для пример с поворотом объекта
         tmp_pos        dd    0.0
         tmp_add        dd    0.005
         tmp_mul        dd    3.0
         tmp_add_2      dd    10.0
         ;=============================
         
         ;=================Lightning Data==================   
         LightsCount   dd    1 ;Byte [0-255]   ;Количество свечек
         LightsPositions:
              dd   10.0, 3.0, 7.0  ;Тут стоит блок для наглядности
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

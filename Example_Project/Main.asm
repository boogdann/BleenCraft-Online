format PE GUI 4.0
entry Start

include "win32a.inc" 
;В первую очередь подключить модуль GraficAPI!
include "GraficAPI\GraficAPI.asm"

section '.text' code readable executable     

Start:
  ;Сначала нужно проиницилизировать модуль
  ;P.S. она также иницициализирует всю оконную мишуру
  stdcall gf_grafic_init
  
  ;Теперь в качестве примера загрузим куб в видеопамять
  stdcall gf_UploadObj3D, obj_cube_name, obj_CubeHandle, 1
  ;P.S. Заметь, что для загрузки объекта мы прсто кидаем адресс на Handle (dd ?, ?)
  ;P.S. Третий параметр 
  
  ;Ожидай в следующих версиях!!!
  ;Далее загрузим тексуру земли в видеопамять
  ;stdcall gf_UploadTexture, tx_grassName 
  ;mov [tx_grassHandle], eax
  ;P.S. Далее эти Handle-ы будут исользоваться
  
  ;Стандартный цикл оконной процедуры
  .MainCycle:
        invoke  GetMessage, msg, 0, 0, 0
        invoke  DispatchMessage, msg
        jmp     .MainCycle
        
        
;К примеру простейшая оконная процедура
proc WindowProc uses ebx,\
     hWnd, uMsg, wParam, lParam

        ;К макросам тоже присмотрись) (Если что кину)
        switch  [uMsg]
        case    .Render,        WM_PAINT
        case    .Destroy,       WM_DESTROY
        case    .KeyDown,       WM_KEYDOWN

        invoke  DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
        jmp     .Return

.Render:
        ;Самое интересное это то что в функции RenderScene
        ;(Она расположена ниже) 
        stdcall RenderScene
        jmp     .ReturnZero

.KeyDown:
        ;Выход по Esc
        cmp     [wParam], VK_ESCAPE
        je      .Destroy
        jmp     .ReturnZero

.Destroy:
        invoke  ExitProcess, 0

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
    
    ;Ожидай в следующих версиях!!!
    ;Также нужно проиницелизтровать источники света (Рассказать Богдану про оптимизацию!!!)
    ;stdcall gf_CrateLightning, lightningCount, LightPosArray
    
    ;Ожидай в следующих версиях!!!
    ;Рендер ландшафта: (LandDataArray - 3-х мерный массив ландшафта) (X, Y, Z - размеры)
    ;stdcall gf_RenderMineLand, LandDataArray, X, Y, Z
    
    ;Для рендера иных объектов:
    ;(Например рендер куба с текстурой земли)
    stdcall gf_renderObj3D, obj_CubeHandle, [tx_grassHandle],\
                            cubePos, cubeTurn, [cubeScale]  
                            
    ;В качестве примера действия будем вращать куб
    fld   [cubeTurn + Vector3.y]
    fadd  [tmp_turn] 
    fstp  [cubeTurn + Vector3.y]
    
    ;В самом конце рендера сцены нужно:
    stdcall gf_RenderEnd
  ret
endp


section '.data' data readable writeable
         ;Обязательно нужно выставить переменные окружения:
         ;Путь к объектам относительно исполняемого:
         GF_OBJ_PATH        db     "Assets\ObjectsPack\", 0
         ;Путь к текстурам относительно исполняемого:
         GF_TEXTURE_PATH    db     "Assets\TexturesPack\", 0
         
         ;Пример данных:
         ;Объекты
         obj_cube_name   db   "LCube.mobj", 0 ;(GF_OBJ_PATH) (тип .mobj!)
         ;P.S. L - в начале это файл с генерацией .mobj c uint8
         ;     B - в начале это файл с генерацией .mobj c uint16
         ;     B - cтавить не обязательно (Это по дефолту)
         obj_CubeHandle  dd   ?, ? ;Да, тут именно 8 байт, так нужно!!!
         
         ;Текстуры
         tx_grassName    db   "Grass.png", 0 ;(GF_TEXTURE_PATH)
         tx_grassHandle  dd   ?
         
         ;Позиция объекта:
         cubePos         dd   0.0, 0.0, 0.0
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
         
         ;Для пример с поворотом объекта
         tmp_turn        dd    0.005
         

         ;Добавить импорты данных нужные GraficAPI
         include "GraficAPI\GraficAPI.inc"            ;1)
         include "GraficAPI\gf_main\gf_api_init.inc"  ;2)  
         include "GraficAPI\gf_main\gf_render_data.inc"  ;3) 

section '.idata' import data readable writeable

  library kernel32, 'KERNEL32.DLL',\
	        user32,   'USER32.DLL',\    
          opengl32, 'opengl32.DLL',\ ;1) ;Добавь нужные для GraficAPI библиотеки!
          gdi32,    'GDI32.DLL'      ;2)
         

  include 'api\kernel32.inc'
  include 'api\user32.inc'

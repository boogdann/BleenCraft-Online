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
  ;stdcall gf_UploadObj3D, obj_cube_name
  mov [obj_CubeHandle], eax
  ;Далее загрузим тексуру земли в видеопамять
  ;stdcall gf_UploadTexture, tx_grassName 
  mov [tx_grassHandle], eax
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


;Пример процедуры для рендера сцены
proc RenderScene
    ;Сначала нужно проиницилизировать основные данные кадра
    stdcall gf_RenderBegin
    ;Для рендера объекта:
    ;(Например рендер куба с текстурой земли)
    ;stdcall gf_renderObj3D, obj_CubeHandle, tx_grassHandle, ...

    ;В самом конце рендера сцены нужно:
    stdcall gf_RenderEnd
  ret
endp


section '.data' data readable writeable
         ;Пример данных:
         ;Объекты
         obj_cube_name   db   "Cube.obj", 0
         obj_CubeHandle  dd   ?
         ;Текстуры
         tx_grassName    db   "Grass.png", 0
         tx_grassHandle  dd   ?

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

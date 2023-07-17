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
  stdcall gf_InitShaders
  
  ;Стандартный цикл
  .MainCycle:
        invoke  GetMessage, msg, 0, 0, 0
        invoke  DispatchMessage, msg
        jmp     .MainCycle
        
        
;К примеру простейшая оконная процедура 
proc WindowProc uses ebx,\
     hWnd, uMsg, wParam, lParam

        ;К макросам тоже присмотрись)
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


;Собственно говоря тут будут расположены основные возможности модуля
proc RenderScene
 
    invoke SwapBuffers, [hdc]
    invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT 
  ret
endp


section '.data' data readable writeable
         ;Добавить импорты данных нужные GraficAPI
         include "GraficAPI\GraficAPI.inc"            ;1)
         include "GraficAPI\gf_main\gf_api_init.inc"  ;2)

section '.idata' import data readable writeable

  library kernel32, 'KERNEL32.DLL',\
	        user32,   'USER32.DLL',\    
          opengl32, 'opengl32.DLL',\ ;1) ;Добавь нужные для GraficAPI библиотеки!
          gdi32,    'GDI32.DLL'      ;2)
         

  include 'api\kernel32.inc'
  include 'api\user32.inc'

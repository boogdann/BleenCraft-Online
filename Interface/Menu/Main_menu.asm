include "..\..\Grafic\GraficAPI\gf_assets\gf_macro.ASM"

proc ui_renderMenu_Main, WindowRect
  locals
    list  dd  ?
    
    x     dd  0.0
    y     dd  0.0
    x_sz  dd  0.8
    y_sz  dd  0.8
  endl 
 
  stdcall RenderScene
  stdcall gf_2D_Render_Start
  
  stdcall ui_drawButton, [WindowRect], -0.4, 0.0, 0.8, 0.15,      1, PLAY_text, 4  
  stdcall ui_drawButton, [WindowRect], -0.4, -0.2, 0.8, 0.15,     2, CONNECT_text, 7
  stdcall ui_drawButton, [WindowRect], -0.3, -0.45, 0.6, 0.15,    3, EXIT_text, 4                  
                                                                     
  stdcall gf_2D_Render_End
  

  ret
endp

proc ui_Menu_MainController, WindowRect 
  switch  [Selected_ButtonId]
  case    .Create,        1
  case    .Connect,       2
  case    .Exit,          3
  jmp     .Return
  
  .Create:
    mov [CUR_MENU], UI_CREATE_MENU
  jmp .Return  
  .Connect:
    mov [CUR_MENU], UI_CONNECT_MENU
  jmp .Return  
  .Exit:
    invoke ExitProcess, 0
  jmp .Return    
  
  .Return:
  ret
endp
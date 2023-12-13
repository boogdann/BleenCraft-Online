include "..\..\Grafic\GraficAPI\gf_assets\gf_macro.ASM"

proc ui_renderMenuConnect, WindowRect 

  locals
    curBackgroundAdd   dd   ? 
  endl

  stdcall gf_2D_Render_Start 
  
    stdcall ui_drawButton, [WindowRect], -0.3, -0.45, 0.6, 0.2,      2, CONNECT_text, 7
    stdcall ui_drawButton, [WindowRect], -0.9, -0.9, 0.4, 0.15,      3, BACK_text, 4
    
    fld [backGroundAdd]
    fcos 
    fstp [curBackgroundAdd]
    
  stdcall ui_renderBackground, [WindowRect], [curBackgroundAdd]
    

  stdcall gf_2D_Render_End
  
  invoke SwapBuffers, [hdc]
  invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT


  ret
endp


proc ui_MenuConnectController, WindowRect 
  switch  [Selected_ButtonId]
  case    .Connect,       2
  case    .Exit,          3
  jmp     .Return
  
  .Connect:
    ;Connect
  jmp .Return   
  .Exit:
    mov [CUR_MENU], UI_MAIN_MENU
  jmp .Return    
  
  .Return:
  ret
endp
include "..\..\Grafic\GraficAPI\gf_assets\gf_macro.ASM"

proc ui_renderMenu_Main, WindowRect 
  stdcall RenderScene
  stdcall gf_2D_Render_Start 
    stdcall ui_drawButton, [WindowRect], -0.4, 0.0, 0.8, 0.15,      1
    stdcall ui_drawButton, [WindowRect], -0.4, -0.2, 0.8, 0.15,     2
    stdcall ui_drawButton, [WindowRect], -0.4, -0.45, 0.38, 0.15,   3
    stdcall ui_drawButton, [WindowRect], 0.014, -0.45, 0.38, 0.15,  4
    

  stdcall gf_2D_Render_End

  ret
endp

proc ui_Menu_MainController
  switch  [Selected_ButtonId]
  case    .Create,        1
  case    .Connect,       2
  case    .Settings,      3 
  case    .Exit,          4
  jmp     .Return
  
  .Create:
    mov [CUR_MENU], UI_CREATE_MENU
  jmp .Return  
  .Connect:
    mov [CUR_MENU], UI_CONNECT_MENU
  jmp .Return  
  .Settings:
    mov [CUR_MENU], UI_SETTINGS_MENU
  jmp .Return  
  .Exit:
    invoke ExitProcess, 0
  jmp .Return    
  
  .Return:
  ret
endp
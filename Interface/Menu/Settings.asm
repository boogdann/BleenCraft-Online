include "..\..\Grafic\GraficAPI\gf_assets\gf_macro.ASM"

proc ui_renderMenuSettings, WindowRect 
    ;==============================
    locals 
      curBackgroundAdd   dd   ? 
      addPos             dd   0.01
    endl
    fld [backGroundAdd]
    fadd [addPos]
    fstp [backGroundAdd]
    ;==============================

  ;stdcall gf_2D_Render_Start 
      stdcall ui_drawButton, [WindowRect], 0.50, -0.9, 0.4, 0.15,      2
      stdcall ui_drawButton, [WindowRect], -0.9, -0.9, 0.4, 0.15,      3
  
      fld [backGroundAdd]
      fcos 
      fstp [curBackgroundAdd]
      stdcall ui_renderBackground, [WindowRect], [curBackgroundAdd]

  ;stdcall gf_2D_Render_End
  
  ;invoke SwapBuffers, [hdc]
  ;invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT


  ret
endp

proc ui_MenuSettingsController, WindowRect 
  switch  [Selected_ButtonId]
  case    .Continue,       2
  case    .Exit,           3
  jmp     .Return
  
  .Continue:
    mov [UI_MODE], UI_GAME
    stdcall ct_change_mouse, 0
  jmp .Return   
  .Exit:
    mov [UI_MODE], UI_GAME
    mov [App_Mode], MENU_MODE
    stdcall ui_InterfaceInit
  jmp .Return    
  
  .Return:
  ret
endp
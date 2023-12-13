include "..\..\Grafic\GraficAPI\gf_assets\gf_macro.ASM"

proc ui_renderMenuSettings, WindowRect 
    locals 
      curBackgroundAdd   dd   ? 
      addPos             dd   0.01
    endl
    fld [backGroundAdd]
    fadd [addPos]
    fstp [backGroundAdd]

    stdcall ui_drawButton, [WindowRect], 0.45, -0.95, 0.5, 0.15,      2, Continue_text, 8
    stdcall ui_drawButton, [WindowRect], -0.95, -0.95, 0.5, 0.15,     3, Menu_text, 4
  
    fld [backGroundAdd]
    fcos 
    fstp [curBackgroundAdd]
    stdcall ui_renderBackground, [WindowRect], [curBackgroundAdd]
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
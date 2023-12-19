UI_MAIN_MENU        equ  1 
UI_CREATE_MENU      equ  2  
UI_CONNECT_MENU     equ  3   
UI_SETTINGS_MENU    equ  4 


include "units\interfase_items.ASM"   
include "units\interfase_controller.ASM"
include "units\interfase_menu_items.ASM"  
include "units\interfase_text.ASM" 
include "Menu\Main_menu.ASM"  
include "Menu\Create.ASM"  
include "Menu\Connect.ASM"  
include "Menu\Settings.ASM"  
include "..\Grafic\GraficAPI\gf_assets\gf_macro.ASM"



proc ui_InterfaceInit
  locals
      LightAdd  dd  1.0
  endl 
  mov [CUR_MENU], UI_MAIN_MENU
  
  mov [IS_ONLINE],    FALSE   
  mov [IS_HOST],      FALSE
  mov [ChosenFile], DEFAULT_WORLD
  stdcall InitWorld  
  stdcall GameStart
  
  stdcall Set_GF_RENDER_BLOCKS_RADIUS,  30, 30, 30
  stdcall ct_change_mouse, 1
  stdcall gf_cleanLightning
  fld [PlayerPos]
  fadd [LightAdd]
  fstp [PlayerPos]
  stdcall gf_AddLightning, PlayerPos
  fld [PlayerPos]
  fsub [LightAdd]
  fstp [PlayerPos]
  
  mov [CuruiTurn], 30.0
  mov [PlayerTurn + 4], 30.0 
  mov [PlayerTurn], -10.0 
  
  mov [GLOBAL_OBJ_RADIUS_RENDER], -2.0
  ret
endp

proc ui_RenderMenu, WindowRect
  locals 
     addTurn   dd   0.04
     addPos    dd   0.001
  endl
  mov [Selected_ButtonId], 0
  fld [PlayerTurn + 4]
  fsub [addTurn]
  fstp [PlayerTurn + 4]
  fld [backGroundAdd]
  fadd [addPos]
  fstp [backGroundAdd]
  
  
  
  switch  [CUR_MENU]
  case    .UI_main,         UI_MAIN_MENU       
  case    .UI_create,       UI_CREATE_MENU 
  case    .UI_connect,      UI_CONNECT_MENU 
  case    .UI_settings,     UI_SETTINGS_MENU
  
  .UI_main:
    stdcall ui_renderMenu_Main, [WindowRect]
    jmp .Return  
  .UI_create:
    stdcall ui_renderMenuCreate, [WindowRect]
    jmp .Return
  .UI_connect:
    stdcall ui_renderMenuConnect, [WindowRect]
    jmp .Return
  .UI_settings:
    stdcall ui_renderMenuSettings, [WindowRect]
    jmp .Return
  
  .Return:
  mov [Dayly_Kof], 5000
  ret
endp

proc ui_onClick, WindowRect 

  switch  [CUR_MENU]
  case    .UI_main,         UI_MAIN_MENU       
  case    .UI_create,       UI_CREATE_MENU 
  case    .UI_connect,      UI_CONNECT_MENU 
  case    .UI_settings,     UI_SETTINGS_MENU
  
  .UI_main:
    stdcall ui_Menu_MainController, [WindowRect]
  jmp .Return  
  .UI_create:
    stdcall ui_MenuCreateController, [WindowRect]
  jmp .Return
  .UI_connect:
    stdcall ui_MenuConnectController, [WindowRect]
  jmp .Return
  .UI_settings:
    stdcall ui_renderMenuSettings, [WindowRect]
  jmp .Return
  
  .Return:
  ret
endp

proc ui_on_keyDown, wParam
  switch  [CUR_MENU]
  case    .UI_main,         UI_MAIN_MENU       
  case    .UI_create,       UI_CREATE_MENU 
  case    .UI_connect,      UI_CONNECT_MENU 
  case    .UI_settings,     UI_SETTINGS_MENU
  
  .UI_main:
    ;
  jmp .Return  
  .UI_create:
    cmp [CurFocus], 101
    jnz .Return
      stdcall AddLetterToInput, GameName_input, [wParam], 1, 1
      jmp .Return
  jmp .Return
  .UI_connect:
    stdcall ui_ConnectInputController, [wParam]
  jmp .Return
  .UI_settings:
    stdcall ui_EscMenuInputController, [wParam]
  jmp .Return
  
  .Return:
  ret
endp

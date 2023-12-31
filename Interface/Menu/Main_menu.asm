include "..\..\Grafic\GraficAPI\gf_assets\gf_macro.ASM"

proc ui_renderMenu_Main, WindowRect
  locals
    list  dd  ?
    
    x     dd  0.0
    y     dd  0.0
    x_sz  dd  0.8
    y_sz  dd  0.8
    
    MenuPlayerPos  dd   900.0, 90.0, 200.0
  endl 
  
  mov eax, [MenuPlayerPos]
  mov [PlayerPos], eax
  mov eax, [MenuPlayerPos + 4]
  mov [PlayerPos + 4], eax
  mov eax, [MenuPlayerPos + 8]
  mov [PlayerPos + 8], eax
  
  mov [IS_ONLINE],    FALSE   
  mov [IS_HOST],      FALSE
 
  stdcall RenderScene
  stdcall gf_2D_Render_Start
  
  invoke glColor3f, 1.0, 1.0, 1.0
  stdcall ui_draw_text, [WindowRect], version_text, [version_text_len], -0.98, -1.0, 0.004
  
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
    stdcall Field.GetAllWorlds, FileNames
    mov    dword[FileCount], ecx
    mov [CurOpenPage], 0
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
include "..\..\Grafic\GraficAPI\gf_assets\gf_macro.ASM"

proc ui_renderMenuCreate, WindowRect 
  locals
    curBackgroundAdd   dd   ? 
    
        
      n_TEXT             dd    25.0
      n_2                dd   2.0
      err_text_size      dd   0.005
      textWidth          dd   ?
      textHeight         dd   ?
      textX              dd   ?
  endl

  stdcall gf_2D_Render_Start 
    invoke glColor3f, 1.0, 1.0, 1.0
    stdcall ui_draw_text, [WindowRect], create_game_text, [create_game_text_len], -0.5, 0.8, 0.006
    
    stdcall ui_render_input, [WindowRect], -0.4, 0.60, 0.8, 0.15,     101, \
                             map_name_text, [map_name_text_len], GameName_input    
  
    stdcall ui_drawButton, [WindowRect], -0.3, 0.3, 0.6, 0.2,      1, Create_text, 6
    
    
    cmp [create_error], 0 
    jz .SkipErrorText   
        fld [n_2]
        fdiv [n_TEXT]
        fstp [err_text_size]
        stdcall ui_getTextSizes, [WindowRect], [create_error_len], [err_text_size]
        mov [textWidth], eax
        mov [textHeight], ecx  
    
        fld [n_2]
        fsub [textWidth]
        fdiv [n_TEXT]
        fstp [textX]
        
       invoke glColor3f, 1.0, 0.3, 0.3
       stdcall ui_draw_text, [WindowRect], [create_error], [create_error_len], [textX], 0.15, 0.005
    .SkipErrorText:
    
    ;======================================================================================
    ;stdcall ui_drawButton, [WindowRect], -0.3, -0.30, 0.6, 0.2,    2, Open_text, 4
    stdcall ui_drawButton, [WindowRect], -0.9, -0.9, 0.4, 0.15,    3, BACK_text, 4
    
    
    ;======================================================================================
    
    fld [backGroundAdd]
    fcos 
    fstp [curBackgroundAdd]
    
    stdcall ui_renderBackground, [WindowRect], [curBackgroundAdd]
    

  stdcall gf_2D_Render_End
  
  invoke SwapBuffers, [hdc]
  invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT


  ret
endp

;stdcall ui_MenuCreateController, [WindowRect]

proc ui_MenuCreateController uses esi, WindowRect 
  locals
      MenuPlayerPos  dd   900.0, 90.0, 200.0
  endl 
  switch  [Selected_ButtonId]
  case    .Create,        1
  case    .ReOpen,        2
  case    .Exit,          3
  case    .GameInput,     101
  mov [CurFocus], 0
  jmp     .Return
  
  .Create:
    ;=====================================================
    stdcall gf_2D_Render_Start 
    stdcall ui_renderBackground, [WindowRect], 0.0
    stdcall gf_2D_Render_End
    invoke SwapBuffers, [hdc]
    invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT
    mov [IS_ONLINE],    FALSE   
    mov [IS_HOST],      FALSE
    ;========================================================
    
    movzx esi, byte[GameName_input]
    mov byte[GameName_input + esi + 1], 0
    cmp esi, 4
    jl .ErrorString
    
    mov [App_Mode], GAME_MODE
    mov [ChosenFile], GameName_input + 1 
    stdcall InitWorld
    stdcall GameStart 
    
    ;====== DELETE ===========  
    mov eax, [MenuPlayerPos]
    mov [PlayerPos], eax
    mov eax, [MenuPlayerPos + 4]
    mov [PlayerPos + 4], eax
    mov eax, [MenuPlayerPos + 8]
    mov [PlayerPos + 8], eax
    ;===========================
    
    mov [create_error], 0
    mov [create_error_len], 0   
    
    .ErrorString:
    mov [create_error], name_len_err 
    mov eax, [name_len_err_len]
    mov [create_error_len], eax      
    jmp .Return
  
    
  jmp .Return  
  .ReOpen:
    ;mov [App_Mode], GAME_MODE
    ;stdcall GameStart 
  jmp .Return  
  .GameInput:
     mov [CurFocus], 101
  jmp .Return  
  .Exit:
    mov [CUR_MENU], UI_MAIN_MENU
  jmp .Return    
  
  .Return:
  ret
endp
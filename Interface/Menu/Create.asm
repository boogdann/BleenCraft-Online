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
      
      btnCurY            dd   ?
      btnStartY          dd   -0.25
      btnOffsetY         dd   -0.2
  endl

  stdcall gf_2D_Render_Start 
    invoke glColor3f, 1.0, 1.0, 1.0
    stdcall ui_draw_text, [WindowRect], create_game_text, [create_game_text_len], -0.4, 0.8, 0.006
    
    stdcall ui_render_input, [WindowRect], -0.4, 0.60, 0.8, 0.15,     101, \
                             map_name_text, [map_name_text_len], GameName_input    
  
    stdcall ui_drawButton, [WindowRect], -0.3, 0.3, 0.6, 0.2,      1, Create_text, 6
    
    stdcall ui_drawButton, [WindowRect], -0.9, -0.9, 0.4, 0.15,    3, BACK_text, 4
    
    stdcall ui_drawButton, [WindowRect], -0.55, -0.5, 0.05, 0.15,    5, Space_text, 1
    stdcall ui_drawButton, [WindowRect], 0.5, -0.5, 0.05, 0.15,    6, Space_text, 1
    
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
       stdcall ui_draw_text, [WindowRect], [create_error], [create_error_len], [textX], 0.1, 0.005
    .SkipErrorText:
    
    ;======================================================================================
    invoke glColor3f, 1.0, 1.0, 1.0
    stdcall ui_draw_text, [WindowRect], open_game_text, [open_game_text_len], -0.25, -0.05, 0.005
    
    
    
      ;==================================================      
      ;CurOpenPage  FileCount
      mov eax, [btnStartY]
      mov [btnCurY], eax
      mov ecx, 0
      .RenderOpenBtnsCircle:
          push ecx
          mov eax, [CurOpenPage]
          imul eax, 3
          add eax, ecx
          cmp eax, [FileCount]
          jge .SkipRenderBtn
          
          ;stdcall calculate_c_string
          mov esi, dword[FileNames]
          mov eax, [CurOpenPage]
          imul eax, [maps_on_page]
          add eax, ecx
          imul eax, 4
          add esi, eax
          
          push ecx
          stdcall ui_get_string_info, [esi]   ;eax - length
          
          pop ecx
          add ecx, 35
          stdcall ui_drawButton, [WindowRect], -0.4, [btnCurY], 0.8, 0.15,  ecx, [esi], eax
          jmp .SkipNewSlot
          .SkipRenderBtn:
              stdcall ui_drawButton, [WindowRect], -0.4, [btnCurY], 0.8, 0.15,  -1, new_map_slot_text, [new_map_slot_text_len]
          .SkipNewSlot:
          fld [btnCurY]
          fadd [btnOffsetY]
          fstp [btnCurY]
          pop ecx
      inc ecx
      cmp ecx, 3
      jnz .RenderOpenBtnsCircle

      
      ;==================================================
    
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

  switch  [Selected_ButtonId]
  case    .Create,        1
  case    .ReOpen,        2
  case    .Exit,          3
  case    .LBtnPage,      5
  case    .RBtnPage,      6
  case    .Btn1,          35
  case    .Btn2,          36
  case    .Btn3,          37
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
    
    stdcall copy_in_world_path, GameName_input + 1 
    
    mov [App_Mode], GAME_MODE
    mov [ChosenFile], world_path
    stdcall InitWorld
    stdcall GameStart 
    
    mov [create_error], 0
    mov [create_error_len], 0 
    
    jmp .Return  
    
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
  .LBtnPage:
      dec [CurOpenPage]
      cmp [CurOpenPage], 0
      jge @F
          mov [CurOpenPage], 0
      @@: 
  jmp .Return 
  .RBtnPage:
      inc [CurOpenPage]
      xor edx, edx
      mov eax, [FileCount]
      div [maps_on_page]
      ;dec eax
      cmp [CurOpenPage], eax
      jle @F
         dec [CurOpenPage]
      @@:
  jmp .Return
  .Btn1:
      mov eax, [CurOpenPage]
      imul eax, 3
      add eax, 0
      stdcall ui_open_map, eax
  jmp .Return
  .Btn2:
      mov eax, [CurOpenPage]
      imul eax, 3
      add eax, 1
      stdcall ui_open_map, eax
  jmp .Return
  .Btn3:
      mov eax, [CurOpenPage]
      imul eax, 3
      add eax, 2
      stdcall ui_open_map, eax
  jmp .Return
  .Return:
  ret
endp


proc ui_open_map, map_index
  locals
      MenuPlayerPos  dd   900.0, 90.0, 200.0
  endl 
 ;=====================================================
  stdcall gf_2D_Render_Start 
  stdcall ui_renderBackground, WindowRect, 0.0
  stdcall gf_2D_Render_End
  invoke SwapBuffers, [hdc]
  invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT
  mov [IS_ONLINE],    FALSE   
  mov [IS_HOST],      FALSE
  ;========================================================
    
  mov eax, [map_index]
  imul eax, 4
  add eax, dword[FileNames]
  mov esi, eax  
    
  mov [App_Mode], GAME_MODE
  mov eax, [esi]
  stdcall copy_in_world_path, eax 
  mov [ChosenFile], world_path
  stdcall InitWorld
  stdcall GameStart 
    
  ret
endp


proc copy_in_world_path uses esi edi, path
  mov esi, world_path
  add esi, [world_path_offset]
  mov edi, [path]
  
  .WriteLoop:
    mov al, byte[edi]
    mov byte[esi], al
  
    inc edi
    inc esi
  cmp byte[edi], 0
  jnz .WriteLoop

  ret
endp


proc ui_get_string_info uses esi, string
  mov eax, 0
  mov esi, [string]
  
  cmp byte[esi], 0
  jz .Return
  .len_loop:
     inc eax
     inc esi
  cmp byte[esi], 0
  jnz .len_loop
  
  .Return:
  ret
endp
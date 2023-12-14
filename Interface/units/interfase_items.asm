proc ui_renderAim uses esi, WindowRect
  locals 
    aim_size_y dd ?
    aim_size_x dd ?
  endl
  
  mov eax, [ui_aim_size]
  mov [aim_size_y], eax 
  
  mov esi, [WindowRect]
  fild dword[esi + 12]
  fild dword[esi + 8]
  fdivp
  fmul [aim_size_y]
  fstp [aim_size_x]
  
  invoke glColor3f, 0.73, 0.73, 0.73
  invoke glBegin, GL_LINES
  invoke glVertex2f, [aim_size_x], 0.0
  fld [aim_size_x]
  fchs
  fstp [aim_size_x]
  invoke glVertex2f, [aim_size_x], 0.0
  invoke glVertex2f, 0.0, [aim_size_y]
  fld [aim_size_y]
  fchs
  fstp [aim_size_y]
  invoke glVertex2f, 0.0, [aim_size_y]
  invoke glEnd
   
   ret
endp

proc ui_draw_drag uses esi edi, WindowRect
  locals 
    size_xy   dd  ?, ?
    pos_xy    dd  ?, ?
    
    n_2       dd  2.0
  endl

  cmp [ui_is_drag], 1
  jnz .Return
      invoke GetCursorPos, ui_cursor_pos
      
      mov esi, [WindowRect]
      fild [ui_cursor_pos]
      fild dword[esi + 8]
      fdivp
      fmul [n_2]
      fld1
      fsubp
      fstp [size_xy]
      fild [ui_cursor_pos + 4]
      fild dword[esi + 12]
      fdivp
      fmul [n_2]
      fld1
      fsubp
      fchs
      fstp [size_xy + 4]
      
      mov ax, word[ui_drag_item]
      cmp ax, 0
      jz .readyRender
      cmp ax, 255
      jle .cubes
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         ;other elements case
        jmp .readyRender
      .cubes:
         ;cube element case:
         xor edx, edx
         push eax
         movzx eax, word[ui_drag_item]
         dec eax
         mov ebx, 4
         imul eax, ebx 
         add eax, TextureHandles 
         push   eax
         invoke glEnable, GL_TEXTURE_2D
         pop    eax
         invoke glBindTexture, GL_TEXTURE_2D, [eax]
         pop eax
         
         stdcall ui_draw_rectangle_textured_block, [size_xy], [size_xy + 4], [big_bag_slot_size_xy], [big_bag_slot_size_xy+4]
         
         invoke glDisable, GL_TEXTURE_2D
      .readyRender: 
  
  
  .Return:
  ret
endp

proc ui_draw_slot uses esi edi ecx, x, y, s_x, s_y, elm_info
  locals 
    n_20     dd    20.0
    tmp_xy   dd    ?, ?
    add_xy   dd    ?, ?
    
    n_8      dd    6.0
    n_3      dd    3.0
  endl
  

  invoke glColor3f, 1.0, 1.0, 1.0
  movzx eax, word[elm_info + 2]
  stdcall ui_getNumText, eax
  ;eax - nums count
  ;num_text - string
  lea edi, [num_text + 4]
  sub edi, eax 
  stdcall ui_draw_text, WindowRect, edi, eax, [x], [y], 0.002
  
  mov [num_text], 0
  
  fld[s_x]
  fdiv [n_20]
  fstp [tmp_xy] 
  fld[s_y]
  fdiv [n_20]
  fstp [tmp_xy + 4] 
  
  fld [s_x]
  fsub [tmp_xy]
  fsub [tmp_xy]
  fstp[s_x]
  fld [s_y]
  fsub [tmp_xy + 4]
  fsub [tmp_xy + 4]
  fstp[s_y]
    
  fld [s_x]
  fld [tmp_xy]
  fmul [n_8]
  fsubp
  fstp[s_x]
  fld [s_y]
  fld [tmp_xy + 4]
  fmul [n_8]
  fsubp
  fstp[s_y]   
  
  fld [x]
  fld [tmp_xy]
  fmul [n_3]
  faddp
  fstp[x]
  fld [y]
  fld [tmp_xy + 4]
  fmul [n_3]
  faddp
  fstp[y]  
          
  mov ax, word[elm_info]
  cmp ax, 0
  jz .readyRender
  cmp ax, 255
  jle .cubes
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;other elements case
    jmp .readyRender
  .cubes:
     ;cube element case:
     xor edx, edx
     push eax
     movzx eax, word[elm_info]
     dec eax
     mov ebx, 4
     imul eax, ebx 
     add eax, TextureHandles 
     push   eax
     invoke glEnable, GL_TEXTURE_2D
     pop    eax
     invoke glBindTexture, GL_TEXTURE_2D, [eax]
     pop eax
     
     stdcall ui_draw_rectangle_textured_block, [x], [y], [s_x], [s_y]
     
     invoke glDisable, GL_TEXTURE_2D
  .readyRender:   

  fld [s_x]
  fld [tmp_xy]
  fmul [n_8]
  faddp
  fstp[s_x]
  fld [s_y]
  fld [tmp_xy + 4]
  fmul [n_8]
  faddp
  fstp[s_y]
  
  fld [x]
  fld [tmp_xy]
  fmul [n_3]
  fsubp
  fstp[x]
  fld [y]
  fld [tmp_xy + 4]
  fmul [n_3]
  fsubp
  fstp[y]
  invoke glColor3f, 0.55, 0.55, 0.55
  cmp [global_selected_slot_kostil], 0
  jz @F
     invoke glColor3f, 0.7, 0.7, 0.7
  @@:
  stdcall ui_draw_rectangle, [x], [y], [s_x], [s_y]

        ;global_selected_slot_kostil
  fld [s_x]
  fadd [tmp_xy]
  fstp[s_x]
  fld [s_y]
  fadd [tmp_xy + 4]
  fstp[s_y]
  invoke glColor3f, 0.22, 0.22, 0.22

  fld[x]
  fsub [tmp_xy]
  fstp [add_xy] 
  fld[y]
  fstp [add_xy + 4] 
  stdcall ui_draw_rectangle, [add_xy], [add_xy+4], [s_x], [s_y]
  
 
  fld[x]
  fsub [tmp_xy]
  fstp [add_xy] 
  fld[y]
  fsub [tmp_xy + 4]
  fstp [add_xy + 4]
  fld [s_x]
  fadd [tmp_xy]
  fstp[s_x]
  fld [s_y]
  fadd [tmp_xy + 4]
  fstp[s_y]
  invoke glColor3f, 0.9, 0.9, 0.9
  stdcall ui_draw_rectangle, [add_xy], [add_xy+4], [s_x], [s_y]

  ret
endp


proc ui_renderBigBag uses esi edi, WindowRect, tools_arr, redactor_arr
  stdcall ui_renderGameMenu, [WindowRect], [tools_arr], [redactor_arr], 0

  ret
endp


proc ui_renderWorkBench uses esi edi, WindowRect, tools_arr, redactor_arr
  stdcall ui_renderGameMenu, [WindowRect], [tools_arr], [redactor_arr], 1

  ret
endp


proc ui_renderGameMenu uses esi edi, WindowRect, tools_arr, redactor_arr, mode 
  locals 
    xy_size    dd   ?, 1.8 ;2.0 * 0.9
    xy_add     dd   ?, -0.9
    
    size_cof   dd   0.9
    n_2        dd   2.0
    n_5        dd   5.0
    n_10       dd   10.0
    tmp_sizes  dd   ?, ?
    tmp_add    dd   0.005, 0.01
    
    slot_xy    dd   ?, ?
    
    cur_slot_xy  dd   ?, 0.0
    start_slot_x dd   ?
    
    player_slot_xy  dd  ?, ?
    player_slot_xy_size  dd  ?, ?
    tmp_pl_slot  dd   2.4
    
    redactor_slot_y  dd 0.45
    
    slot_data        dd ?
    
    start_tmp_ultra_pofig  dd  -0.25
  endl
  
  mov esi, [WindowRect]
  fild dword[esi + 12]
  fild dword[esi + 8]
  fdivp
  fmul [xy_size + 4]
  fstp [xy_size]
  fld1
  fchs
  fld [n_2]
  fsub[xy_size]
  fdiv[n_2]
  faddp
  fstp[xy_add]
 
  ;========================================================================= 
  fld [xy_size + 4]
  fdiv [n_10]
  fstp [slot_xy + 4]
  mov esi, [WindowRect]
  fild dword[esi + 12]
  fild dword[esi + 8]
  fdivp
  fmul [slot_xy + 4]
  fstp [slot_xy]
  
  fld[xy_add]
  fld [slot_xy]
  fdiv [n_2]
  faddp 
  fstp [start_slot_x]
  
  mov eax, [slot_xy]
  mov [big_bag_slot_size_xy], eax
  mov eax, [slot_xy + 4]
  mov [big_bag_slot_size_xy + 4], eax
  
  mov edi, 0
  .DrawSlotsRow:
    mov eax, [start_slot_x]
    mov [cur_slot_xy], eax
    fld [cur_slot_xy + 4]
    fsub [slot_xy + 4]
    fstp [cur_slot_xy + 4] 
    mov esi, 0
    .DrawSlots:
        push esi edi
        imul edi, 36
        add edi, [tools_arr]
        mov esi, [esi * 4 + edi]
        mov [slot_data], esi
        stdcall ui_draw_slot, [cur_slot_xy], [cur_slot_xy + 4], [slot_xy], [slot_xy + 4], esi
        pop edi esi
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        push esi edi
          imul edi, 9
          add edi, esi
          imul edi, 12
          mov eax, [cur_slot_xy]
          mov [big_bag_data + edi], eax
          mov eax, [cur_slot_xy + 4]
          mov [big_bag_data + edi + 4], eax
          mov eax, [slot_data]
          mov [big_bag_data + edi + 8], eax
        pop edi esi
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        fld [cur_slot_xy]
        fadd [slot_xy]
        fstp [cur_slot_xy] 
    inc esi
    cmp esi, 9
    jnz .DrawSlots
      
  inc edi
  cmp edi, 3
  jnz @F
    fld [cur_slot_xy + 4]
    fld [slot_xy + 4]
    fdiv[n_2]
    fsubp
    fstp [cur_slot_xy + 4] 
  @@:
  cmp edi, 4
  jnz .DrawSlotsRow
  
  cmp [mode], 0
  jnz .SkipModeZero 
  ;=========================================================================
  invoke glColor3f, 0.04, 0.04, 0.04    ;player_slot_xy    ;tmp_pl_slot ;player_slot_xy_size 
  fld [start_slot_x]
  fstp [player_slot_xy]
  fldz
  fld [slot_xy]
  fdiv [n_2]
  faddp
  fstp [player_slot_xy + 4]
  fld [xy_size]
  fdiv [tmp_pl_slot]
  fstp [player_slot_xy_size]  
  
  stdcall ui_draw_rectangle, [player_slot_xy], [player_slot_xy + 4], [player_slot_xy_size], 0.8
  ;=========================================================================
  
  ;=========================================================================
  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  mov edi, 12
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  fld [start_slot_x]
  fld [slot_xy]                                      
  fmul [n_5]
  faddp
  fstp [start_slot_x]
  fld [start_slot_x]
  fstp [cur_slot_xy]
  
  mov esi, [redactor_arr]
  stdcall ui_draw_slot, [cur_slot_xy], [redactor_slot_y], [slot_xy], [slot_xy + 4], [esi + 4]
  ;=================================
  mov eax, [cur_slot_xy]
  mov [big_bag_craft_data + edi], eax
  mov eax, [redactor_slot_y]
  mov [big_bag_craft_data + edi + 4], eax
  mov eax, [esi + 4]
  mov [big_bag_craft_data + edi + 8], eax
  add edi, 3 * 4
  ;===================================
  
  fld [cur_slot_xy]
  fadd [slot_xy]
  fstp [cur_slot_xy] 
  stdcall ui_draw_slot, [cur_slot_xy], [redactor_slot_y], [slot_xy], [slot_xy + 4], [esi + 8]
  ;=================================
  mov eax, [cur_slot_xy]
  mov [big_bag_craft_data + edi], eax
  mov eax, [redactor_slot_y]
  mov [big_bag_craft_data + edi + 4], eax
  mov eax, [esi + 8]
  mov [big_bag_craft_data + edi + 8], eax
  add edi, 3 * 4
  ;===================================
  fld [start_slot_x]
  fstp [cur_slot_xy]
  fld [redactor_slot_y]
  fsub [slot_xy + 4]
  fstp [redactor_slot_y]
  stdcall ui_draw_slot, [cur_slot_xy], [redactor_slot_y], [slot_xy], [slot_xy + 4], [esi + 12]
  ;=================================
  mov eax, [cur_slot_xy]
  mov [big_bag_craft_data + edi], eax
  mov eax, [redactor_slot_y]
  mov [big_bag_craft_data + edi + 4], eax
  mov eax, [esi + 12]
  mov [big_bag_craft_data + edi + 8], eax
  add edi, 3 * 4
  ;===================================
  fld [cur_slot_xy]
  fadd [slot_xy]
  fstp [cur_slot_xy] 
  stdcall ui_draw_slot, [cur_slot_xy], [redactor_slot_y], [slot_xy], [slot_xy + 4], [esi + 16]
  ;=================================
  mov eax, [cur_slot_xy]
  mov [big_bag_craft_data + edi], eax
  mov eax, [redactor_slot_y]
  mov [big_bag_craft_data + edi + 4], eax
  mov eax, [esi + 16]
  mov [big_bag_craft_data + edi + 8], eax
  add edi, 3 * 4
  ;===================================
  
  fld [start_slot_x]
  fadd [slot_xy]
  fadd [slot_xy]
  fld [slot_xy]
  fdiv [n_2]
  faddp
  fstp [cur_slot_xy]
  fld [redactor_slot_y]
  fld [slot_xy + 4]
  fdiv [n_2]
  faddp
  fstp [redactor_slot_y]
  stdcall ui_draw_slot, [cur_slot_xy], [redactor_slot_y], [slot_xy], [slot_xy + 4], [esi]
  ;=================================
  mov eax, [cur_slot_xy]
  mov [big_bag_craft_data], eax
  mov eax, [redactor_slot_y]
  mov [big_bag_craft_data + 4], eax
  mov eax, [esi]
  mov [big_bag_craft_data + 8], eax
  jmp .SkipModeOne
  ;===================================
  ;=========================================================================
  .SkipModeZero:
  ;#############################################
  fld [redactor_slot_y]
  fld [slot_xy + 4]
  fdiv [n_2]
  fsubp
  fstp [redactor_slot_y]
  mov [cur_slot_xy], 0.15
  
  fldz
  fsub [slot_xy]
  fsub [slot_xy]
  fstp [start_tmp_ultra_pofig]
  
  fld [start_tmp_ultra_pofig]
  fadd [slot_xy]
  fadd [slot_xy]
  fadd [slot_xy]
  fld [slot_xy]
  fdiv [n_2]
  faddp
  fstp [cur_slot_xy]
  
              ;start_tmp_ultra_pofig
  mov esi, [redactor_arr]
  stdcall ui_draw_slot, [cur_slot_xy], [redactor_slot_y], [slot_xy], [slot_xy + 4], [esi]
  mov eax, [cur_slot_xy]
  mov [workbranchCraft_data], eax
  mov eax, [redactor_slot_y]
  mov [workbranchCraft_data + 4], eax
  mov eax, [esi]
  mov [workbranchCraft_data + 8], eax
  
  
  fld [redactor_slot_y]
  fadd [slot_xy + 4]
  fstp [redactor_slot_y] 
  
  mov ecx, 0
  mov edi, 0
  .Loop_A:
      mov eax, [start_tmp_ultra_pofig]
      mov [cur_slot_xy], eax
      mov edx, 0
      .Loop_B:  
          inc ecx
          push edx
          add esi, 4
          stdcall ui_draw_slot, [cur_slot_xy], [redactor_slot_y], [slot_xy], [slot_xy + 4], [esi]
              
          ;==
          push edi
          mov eax, ecx
          imul eax, 12
          mov edi, eax
          mov eax, [cur_slot_xy]
          mov [workbranchCraft_data + edi], eax
          mov eax, [redactor_slot_y]
          mov [workbranchCraft_data + edi + 4], eax
          mov eax, [esi]
          mov [workbranchCraft_data + edi + 8], eax
          pop edi
          ;==
          
          fld [cur_slot_xy]
          fadd [slot_xy]
          fstp [cur_slot_xy]
          pop edx
      inc edx
      cmp edx, 3
      jnz .Loop_B
      fld [redactor_slot_y]
      fsub [slot_xy + 4]
      fstp [redactor_slot_y] 
  inc edi
  cmp edi, 3
  jnz .Loop_A  
  
  
  
  
  
  
  ;##############################################
  .SkipModeOne:
  ;=========================================================================
  invoke glColor3f, 0.77, 0.77, 0.77
  stdcall ui_draw_rectangle, [xy_add], [xy_add + 4], [xy_size], [xy_size + 4]
  ;=========================================================================
  
 
  mov esi, [WindowRect]
  fild dword[esi + 12]
  fild dword[esi + 8]
  fdivp
  fmul [xy_add + 4]
  fstp [xy_add]
  fld [xy_add]
  fsub [tmp_add]
  fstp[xy_add]
  fld [xy_add + 4]
  fadd [tmp_add + 4]
  fstp[xy_add + 4]
  invoke glColor3f, 0.9, 0.9, 0.9
  stdcall ui_draw_rectangle, [xy_add], [xy_add + 4], [xy_size], [xy_size + 4]
  
  fld [xy_add]
  fadd [tmp_add]
  fadd [tmp_add]
  fstp[xy_add]
  fld [xy_add + 4]
  fsub [tmp_add + 4]
  fsub [tmp_add + 4]
  fstp[xy_add + 4]
  invoke glColor3f, 0.33, 0.33, 0.33
  stdcall ui_draw_rectangle, [xy_add], [xy_add + 4], [xy_size], [xy_size + 4]
  ;=========================================================================
  
  
  ;########################
  

  ret
endp


proc ui_renderBag uses esi edi, WindowRect, tools_count, tools_arr, pointer 
  locals
    bag_width    dd ?
    bag_height   dd 0.13
    cur_x        dd ?
    cur_y        dd -0.95
    
    background_xy      dd    ?, ?
    background_size    dd    ?, ?
    background_add     dd    ?, ?
    background_tmp     dd    20.0
    
    n_2          dd 2.0
  endl
  
  mov esi, [WindowRect]
  fild dword[esi + 12]
  fild dword[esi + 8]
  fdivp
  fmul [bag_height]
  fstp [bag_width]
  
  fld [n_2]
  fild [tools_count]
  fmul [bag_width]
  fsubp
  fdiv [n_2]
  fld1
  fsubp
  fstp [cur_x]

  push [cur_x]
  
  mov edi, [tools_arr]
  mov esi, 0
  .DrawLoop:
     cmp esi, [pointer]
     jnz @F
        mov [global_selected_slot_kostil], 1
     @@:
     stdcall ui_draw_slot, [cur_x], [cur_y], [bag_width], [bag_height], [edi]
     fld [cur_x]
     fadd [bag_width]
     fstp [cur_x]
     mov [global_selected_slot_kostil], 0
    add edi, 4
  inc esi
  cmp esi, [tools_count]
  jnz .DrawLoop
  
  fld  [bag_width]
  fdiv [background_tmp]
  fstp [background_add]
  fld  [bag_height]
  fdiv [background_tmp]
  fstp [background_add + 4]
  
  fld [bag_width]
  fild [tools_count]
  fmulp
  fadd [background_add]
  fadd [background_add]
  fstp [background_size]
  fld [bag_height]
  fadd [background_add + 4]
  fstp [background_size + 4]
  
  pop [cur_x]
  fld [cur_y]
  fsub [background_add + 4]
  fstp [cur_y]
  fld [cur_x]
  fsub [background_add]
  fsub [background_add]
  fstp [cur_x]
  
  invoke glColor3f, 0.77, 0.77, 0.77 
  stdcall ui_draw_rectangle, [cur_x], [cur_y], [background_size], [background_size + 4]
  
  ret
endp

proc ui_renderHealth uses esi, WindowRect, all_count, health_count 
  locals
    heart_width  dd 0.05 
    cur_x        dd ?
    cur_y        dd -0.75
    isHealth     dd 1
    
    n_2          dd 2.0
  endl
  
  fld [n_2]
  fild [all_count]
  fmul [heart_width]
  fsubp
  fdiv [n_2]
  fld1
  fsubp
  fstp [cur_x]
  

  mov esi, 0
  .DrawLoop:
    cmp esi, [health_count]
    jnz @F
      mov [isHealth], 0
    @@:
    stdcall ui_render_heart, [WindowRect], [cur_x], [cur_y], [isHealth]
    fld [cur_x]
    fadd [heart_width]
    fstp [cur_x]
    
  inc esi
  cmp esi, [all_count]
  jnz .DrawLoop
  

  ret
endp


proc ui_draw_rectangle, x, y, x_sz, y_sz
  invoke glBegin, GL_QUADS
    invoke glVertex2f, [x], [y]
    fld [x]
    fadd [x_sz]
    fstp [x]
    invoke glVertex2f, [x], [y]   
    fld [y]
    fadd [y_sz]
    fstp [y]
    invoke glVertex2f, [x], [y] 
    fld [x]
    fsub [x_sz]
    fstp [x]    
    invoke glVertex2f, [x], [y]        
  invoke glEnd;  

  ret
endp

proc ui_draw_rectangle_textured_block, x, y, x_sz, y_sz
               ;f 12 13 5 14
  invoke glEnable, GL_LIGHTING
  invoke glEnable, GL_LIGHT0
  invoke glBegin, GL_QUADS
    invoke glTexCoord2f, 0.001000, 0.500000; 
    invoke glVertex2f, [x], [y]
    fld [x]
    fadd [x_sz]
    fstp [x]
    invoke glTexCoord2f,  0.343333, 0.500000;
   
    invoke glVertex2f, [x], [y]   
    fld [y]
    fadd [y_sz]
    fstp [y]
    invoke glTexCoord2f, 0.343333, 0.750000; 
    invoke glVertex2f, [x], [y] 
    fld [x]
    fsub [x_sz]
    fstp [x]    
    invoke glTexCoord2f, 0.001000, 0.750000
    invoke glVertex2f, [x], [y]        
  invoke glEnd;  
  invoke glDisable, GL_LIGHTING
  invoke glDisable, GL_LIGHT0

  ret
endp


proc ui_draw_rectangle_textured_block_v2, x, y, x_sz, y_sz
               ;f 12 13 5 14
  invoke glEnable, GL_LIGHTING
  invoke glEnable, GL_LIGHT0
  invoke glBegin, GL_QUADS
    invoke glTexCoord2f, 0.013000, 0.500000; 
    invoke glVertex2f, [x], [y]
    fld [x]
    fadd [x_sz]
    fstp [x]
    invoke glTexCoord2f,  0.343333, 0.500000;
   
    invoke glVertex2f, [x], [y]   
    fld [y]
    fadd [y_sz]
    fstp [y]
    invoke glTexCoord2f, 0.343333, 0.740000; 
    invoke glVertex2f, [x], [y] 
    fld [x]
    fsub [x_sz]
    fstp [x]    
    invoke glTexCoord2f, 0.013000, 0.740000
    invoke glVertex2f, [x], [y]        
  invoke glEnd;  
  invoke glDisable, GL_LIGHTING
  invoke glDisable, GL_LIGHT0

  ret
endp


proc ui_render_heart uses esi, WindowRect, x, y, isHealth
  locals 
    px_size_y  dd ?
    px_size_x  dd ?
    px_size    dd 0.005 
    
    cur_x      dd ?
    cur_y      dd ?
    
    cur_width  dd ?
    cur_height dd ?
    
    n_2        dd 2.0
    n_11       dd 11.0
  endl
  
  ;calculate pixcel size
  mov eax, [px_size]
  mov [px_size_y], eax 
  
  mov esi, [WindowRect]
  fild dword[esi + 12]
  fild dword[esi + 8]
  fdivp
  fmul [px_size_y]
  fstp [px_size_x]
  
  invoke glColor3f, 1.0, 0.0, 0.16
  cmp [isHealth], 1
  jz @F
     invoke glColor3f, 0.27, 0.27, 0.27
  @@:
  
  mov eax, [x]
  mov [cur_x], eax
  mov eax, [y]
  mov [cur_y], eax
  
  fld [cur_x]
  fadd [px_size_x]
  fadd [px_size_x]
  fstp [cur_x]
  fld  [px_size_x]
  fmul [n_2]
  fstp [cur_width]
  stdcall ui_draw_rectangle, [cur_x], [cur_y], [cur_width], [px_size_y]
  fld [cur_x]
  fadd [px_size_x]
  fadd [px_size_x]
  fadd [px_size_x]
  fadd [px_size_x]
  fadd [px_size_x]
  fstp [cur_x]
  stdcall ui_draw_rectangle, [cur_x], [cur_y], [cur_width], [px_size_y]
  fld [cur_y]
  fsub [px_size_y]
  fstp [cur_y]
  fld [cur_x]
  fsub [px_size_x]
  fstp [cur_x]
  fld  [cur_width]
  fmul [n_2]
  fstp [cur_width]
  stdcall ui_draw_rectangle, [cur_x], [cur_y], [cur_width], [px_size_y]
  fld [x]
  fadd [px_size_x]
  fstp [cur_x]
  stdcall ui_draw_rectangle, [cur_x], [cur_y], [cur_width], [px_size_y]
  fld  [px_size_x]
  fmul [n_11]
  fstp [cur_width]
  fld  [px_size_y]
  fmul [n_2]
  fstp [cur_height]
  fld [cur_y]
  fsub [px_size_y]
  fsub [px_size_y]
  fstp [cur_y]
  mov eax, [x]
  mov [cur_x], eax
  stdcall ui_draw_rectangle, [cur_x], [cur_y], [cur_width], [cur_height]
  mov esi, 5
  .DrawLoop:
     fld [cur_x]
     fadd [px_size_x]
     fstp [cur_x]
     fld [cur_y]
     fsub [px_size_y]
     fstp [cur_y]
     fld  [cur_width]
     fsub [px_size_x]
     fsub [px_size_x]
     fstp [cur_width]
     stdcall ui_draw_rectangle, [cur_x], [cur_y], [cur_width], [px_size_y]
  dec esi
  cmp esi, 0
  jnz .DrawLoop
  
  ret
endp

proc ui_renderShadowEffect, kostil
    invoke glColor4f, 0.8, 0.0, 0.0, 0.4
    cmp [kostil], 1
    jz @F
      invoke glColor4f, 0.0, 0.0, 0.0, 0.4
    @@:
    stdcall ui_draw_rectangle, -1.0, -1.0, 2.0, 2.0
  ret
endp
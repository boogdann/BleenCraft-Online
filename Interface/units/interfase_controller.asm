;TODO: Проверка на совпадение элементов, проверка на колличество

proc ui_slots_controller uses esi edi, WindowRect, bigBag_arr, bigBag_craft_arr, workbench_craft_arr 
  
  invoke GetCursorPos, ui_cursor_pos
  
  cmp [App_Mode], GAME_MODE
  jnz .SkipGameController
    
    cmp [UI_MODE], UI_WORKBENCH
    jz @F
    cmp [UI_MODE], UI_MAINBAG
    jnz .ReturnGameConroller
    @@:
    ;check big bag + verstack
    stdcall ui_check_slot_section, [WindowRect], big_bag_slot_size_xy, big_bag_data, 36 
    cmp eax, 1
    jnz @F
      mov [ui_is_drag], eax
      mov [ui_drag_item], ecx
      mov eax, [bigBag_arr]
      mov [ui_drag_array_out], eax
      mov [ui_drag_index_out], ebx
      jmp .ReturnGameConroller
    @@:
    
    cmp [UI_MODE], UI_MAINBAG
    jnz .SkipBigBagCraft
      ;check big bag craft
      stdcall ui_check_slot_section, [WindowRect], big_bag_slot_size_xy, big_bag_craft_data, 5 
      cmp eax, 1
      jnz @F
        mov [ui_is_drag], eax
        mov [ui_drag_item], ecx
        mov eax, [bigBag_craft_arr]
        mov [ui_drag_array_out], eax
        mov [ui_drag_index_out], ebx
        jmp .ReturnGameConroller
      @@:
    .SkipBigBagCraft:
    
    cmp [UI_MODE], UI_WORKBENCH
    jnz .SkipWorkBranchCraft
      stdcall ui_check_slot_section, [WindowRect], big_bag_slot_size_xy, workbranchCraft_data, 10 
      cmp eax, 1
      jnz @F
        mov [ui_is_drag], eax
        mov [ui_drag_item], ecx
        mov eax, [workbench_craft_arr]
        mov [ui_drag_array_out], eax
        mov [ui_drag_index_out], ebx
        jmp .ReturnGameConroller
      @@:
    .SkipWorkBranchCraft:
   
  .ReturnGameConroller:
     ;RETURN 
  .SkipGameController:
  
  .Return:    
  ret
endp

proc ui_drag_end uses esi edi, WindowRect, bigBag_arr, bigBag_craft_arr, workbench_craft_arr
  cmp [ui_is_drag], 1
  jnz .Return
  
  invoke GetCursorPos, ui_cursor_pos
  
  
  cmp [App_Mode], GAME_MODE
  jnz .SkipGameController
    cmp [UI_MODE], UI_WORKBENCH
    jz @F
    cmp [UI_MODE], UI_MAINBAG
    jnz .ReturnGameConroller
    @@:
    stdcall ui_check_slot_section, [WindowRect], big_bag_slot_size_xy, big_bag_data, 36 
    cmp eax, 1
    jnz .SkipBigBagCheck 
       stdcall MoveElement, [bigBag_arr], ebx, 64
       ;Big bag case:
       cmp [ui_drag_index_out], 0
       jnz .SkipBigBagCheck
       mov eax, [bigBag_craft_arr]
       cmp [ui_drag_array_out], eax
       jnz .SkipBigBagDecCase
          stdcall Crafting.DecCraft, [bigBag_craft_arr], SMALL_CRAFT_SIZE
          jmp .SkipBigBagCheck 
       .SkipBigBagDecCase:
       ;WorkBench case:
       mov eax, [workbench_craft_arr]
       cmp [ui_drag_array_out], eax
       jnz .SkipWorkbenchDecCase
          stdcall Crafting.DecCraft, [workbench_craft_arr], BIG_CRAFT_SIZE
          jmp .SkipBigBagCheck 
       .SkipWorkbenchDecCase:
    .SkipBigBagCheck:
    
    cmp [UI_MODE], UI_MAINBAG
    jnz .SkipBigBagCraft
      stdcall ui_check_slot_section, [WindowRect], big_bag_slot_size_xy, big_bag_craft_data, 5 
      cmp eax, 1
      jnz @F  
        cmp ebx, 0
        jz @F
          stdcall MoveElement, [bigBag_craft_arr], ebx, 1
          stdcall Crafting.Craft, [bigBag_craft_arr], SMALL_CRAFT_SIZE
        @@:
    .SkipBigBagCraft:
    
    cmp [UI_MODE], UI_WORKBENCH
    jnz .SkipWorkBranchCraft
      stdcall ui_check_slot_section, [WindowRect], big_bag_slot_size_xy, workbranchCraft_data, 10 
      cmp eax, 1
      jnz @F  
        cmp ebx, 0
        jz @F
          stdcall MoveElement, [workbench_craft_arr], ebx, 1
          stdcall Crafting.Craft, [workbench_craft_arr], BIG_CRAFT_SIZE
        @@:
    .SkipWorkBranchCraft:
    
    .ReturnGameConroller:
     ;RETURN 
  .SkipGameController:



  .Return:
  mov [ui_is_drag], 0
  mov [ui_drag_item], 0
  mov [ui_drag_index_out], 0
  mov [ui_drag_array_out], 0
  ret
endp


proc MoveElement, arrayIn, findItemIndex, InsertCount
  locals 
    InElmAddr     dd   ?
    
    FromElm       dd   0
    InElm         dd   0
    
    FromCount     dd   0
    InCount       dd   0
    
    ResCount      dd   0
  endl
  
      mov esi, [ui_drag_array_out]
      mov edi, [ui_drag_index_out]
      shl edi, 2
      movzx eax, word[esi + edi]
      mov [FromElm], eax
      movzx eax, word[esi + edi + 2]
      mov [FromCount], eax
      
      mov ebx, [findItemIndex]
      mov esi, [arrayIn]  ;cur array
      shl ebx, 2
      add esi, ebx
      mov [InElmAddr], esi
      movzx eax, word[esi]
      mov [InElm], eax
      movzx eax, word[esi + 2]
      mov [InCount], eax
      
      mov esi, [ui_drag_array_out]
      mov edi, [ui_drag_index_out] 
      shl edi, 2
      add edi, esi
      cmp edi, [InElmAddr]
      jz .SkipCheck
      
      mov eax, [FromElm]
      cmp eax, [InElm]
      jz @F
        cmp [InElm], 0
        jnz .SkipCheck
      @@:
      
      mov ecx, 0
      mov eax, [FromCount]
      add eax, [InCount]
      cmp eax, [InsertCount]
      jle @F
        mov ecx, eax
        mov eax, [InsertCount]
        sub ecx, eax
      @@:
      mov [ResCount], eax 
      
      mov esi, [ui_drag_array_out]
      mov edi, [ui_drag_index_out]
      shl edi, 2
      cmp ecx, 0
      jz @F 
        mov word[esi + edi + 2], cx
        jmp .SkipDelete
      @@:
      mov dword[esi + edi], 0
      .SkipDelete:
      
      mov eax, [ui_drag_item]
      mov esi, [InElmAddr]
      mov dword[esi], eax
      mov eax, [ResCount]
      mov word[esi + 2], ax

  .SkipCheck:
  ret
endp


;required --> ui_cursor_pos = invoke GetCursorPos
proc ui_check_slot_section uses esi edi, WindowRect, gl_slot_size, slots_arr_data, count
  locals 
     slot_size    dd    ?
     cur_pos      dd    ?, ?
     
     n_2          dd    2.0
     
     isFind          dd    0
     findItem        dd    ?
     findItemIndex   dd    ?
  endl

  mov edi, [gl_slot_size]
  mov esi, [WindowRect]
  fld dword[edi]
  fild dword[esi + 8]
  fmulp 
  fdiv [n_2]
  fistp [slot_size]
  
  mov edi, [WindowRect]
  mov esi, 0
  .CheckSlots:
    push esi
      imul esi, 12
      add esi, [slots_arr_data]
      ;==== pos converter ====      
      fld dword[esi]
      fld1
      faddp
      fild dword[edi + 8]
      fmulp 
      fdiv [n_2]
      fistp [cur_pos] 
       
      fild dword[edi + 12]
      fld dword[esi + 4]
      fld1
      faddp
      fild dword[edi + 12]
      fmulp 
      fdiv [n_2]
      fsubp
      fistp [cur_pos + 4]
      ;========================
      ;====== pos checker =====
      mov eax, [ui_cursor_pos]
      cmp [cur_pos], eax
      jg .OutSlot
      sub eax, [slot_size]
      cmp [cur_pos], eax
      jl .OutSlot
      
      mov eax, [ui_cursor_pos + 4]
      add eax, [slot_size]
      cmp [cur_pos + 4], eax
      jg .OutSlot
      sub eax, [slot_size]
      cmp [cur_pos + 4], eax
      jl .OutSlot      
      
      .InSlot:
         mov [isFind], 1
         mov eax, dword[esi + 8] 
         mov [findItem], eax 
         sub esi, [slots_arr_data]
         mov [findItemIndex], esi
      .OutSlot:
      ;========================
    
    pop esi
  inc esi  
  cmp esi, [count]
  jnz .CheckSlots
         
  ;Return:       
  mov eax, [findItemIndex]  
  xor edx, edx 
  mov ecx, 12
  idiv ecx     
   
  mov ebx, eax      
  mov eax, [isFind]
  mov ecx, [findItem]

  ret
endp

;eax = 0 => no | eax = 1 => yea
proc ui_CheckMouseIn uses esi edi, WindowRect, x, y, s_x, s_y
      locals 
         cur_pos      dd    ?, ?
         n_2          dd    2.0
         
         size         dd    ?, ?
      endl

      invoke GetCursorPos, ui_cursor_pos
      
      mov esi, [WindowRect]
      fld [s_x]
      fild dword[esi + 8]
      fmulp 
      fdiv [n_2]
      fistp [size]
      fld [s_y]
      fild dword[esi + 12]
      fmulp 
      fdiv [n_2]
      fistp [size + 4]

      mov edi, [WindowRect]

      ;==== pos converter ====      
      fld [x]
      fld1
      faddp
      fild dword[edi + 8]
      fmulp 
      fdiv [n_2]
      fistp [cur_pos] 
       
      fild dword[edi + 12]
      fld [y]
      fld1
      faddp
      fild dword[edi + 12]
      fmulp 
      fdiv [n_2]
      fsubp
      fistp [cur_pos + 4]
      ;========================
      ;====== pos checker =====
      mov eax, [ui_cursor_pos]
      cmp [cur_pos], eax
      jg .OutSlot
      sub eax, [size]
      cmp [cur_pos], eax
      jl .OutSlot
      
      mov eax, [ui_cursor_pos + 4]
      add eax, [size + 4]
      cmp [cur_pos + 4], eax
      jg .OutSlot
      sub eax, [size + 4]
      cmp [cur_pos + 4], eax
      jl .OutSlot      
      
      .InSlot:
         mov eax, 1
         jmp .Return
      .OutSlot:
         xor eax, eax
      ;========================
  .Return:
  ret
endp
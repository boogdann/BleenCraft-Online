proc ui_slots_controller uses esi edi, WindowRect, bigBag_arr
  
  ;big_bag_data  
  invoke GetCursorPos, ui_cursor_pos
  
  ;check big bag
  stdcall ui_check_slot_section, [WindowRect], big_bag_slot_size_xy, big_bag_data 
  cmp eax, 1
  jnz @F
    mov [ui_is_drag], eax
    mov [ui_drag_item], ecx
    mov eax, [bigBag_arr]
    mov [ui_drag_array_out], eax
    mov [ui_drag_index_out], ebx
  @@:
  
  
      
  ret
endp

proc ui_drag_end uses esi edi, WindowRect, bigBag_arr
  cmp [ui_is_drag], 1
  jnz .Return
  
  invoke GetCursorPos, ui_cursor_pos
  
  stdcall ui_check_slot_section, [WindowRect], big_bag_slot_size_xy, big_bag_data 
  cmp eax, 1
  jnz @F  
    ;Insert
    mov esi, [bigBag_arr]
    mov eax, [ui_drag_item]
    shl ebx, 2
    mov dword[esi + ebx], eax
    
    ;Delete from root
    mov esi, [ui_drag_array_out]
    mov edi, [ui_drag_index_out]
    shl edi, 2
    mov dword[esi + edi], 0
  @@:



  .Return:
  mov [ui_is_drag], 0
  mov [ui_drag_item], 0
  mov [ui_drag_index_out], 0
  mov [ui_drag_array_out], 0
  ret
endp

;required --> ui_cursor_pos = invoke GetCursorPos
proc ui_check_slot_section uses esi edi, WindowRect, gl_slot_size, slots_arr_data
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
  cmp esi, 36
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
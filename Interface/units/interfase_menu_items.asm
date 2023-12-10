proc ui_drawButton uses esi edi, WindowRect, x, y, s_x, s_y, id

  locals 
    n_30     dd    30.0
    tmp_xy   dd    ?, ?
    add_xy   dd    0.005, ?
    
    isIn     dd    0
  endl
  
  stdcall ui_CheckMouseIn, [WindowRect], [x], [y], [s_x], [s_y]
  cmp eax, 0
  jz @F
     mov [isIn], 1
     mov eax, [id]
     mov [Selected_ButtonId], eax
  @@:
  
  invoke glColor3f, 0.44, 0.44, 0.44
  cmp [isIn], 1
  jnz @F
    invoke glColor3f, 0.37, 0.37, 0.37
  @@:
  stdcall ui_draw_rectangle, [x], [y], [s_x], [s_y]
  
  mov  esi, [WindowRect]
  fld  [add_xy]
  fild dword[esi + 8]
  fild dword[esi + 12]
  fdivp
  fmulp 
  fstp [add_xy + 4]
  
  fld [x]
  fsub [add_xy]
  fstp [x]
  fld [s_x]
  fadd [add_xy]
  fstp [s_x]
  fld [s_y]
  fadd [add_xy + 4]
  fstp [s_y]
  
  invoke glColor3f, 0.66, 0.66, 0.66
  
  stdcall ui_draw_rectangle, [x], [y], [s_x], [s_y] 
  
  fld [x]
  fadd [add_xy]
  fstp [x]
  fld [y]
  fsub [add_xy + 4]
  fstp [y]
  invoke glColor3f, 0.33, 0.33, 0.33
  stdcall ui_draw_rectangle, [x], [y], [s_x], [s_y] 
  
  fld [x]
  fsub [add_xy] 
  fsub [add_xy]
  fstp [x]
  fld [y]
  fsub [add_xy + 4]
  fstp [y]
  fld [s_x]
  fadd [add_xy]
  fadd [add_xy]
  fadd [add_xy]
  fstp [s_x]
  fld [s_y]
  fadd [add_xy + 4]
  fadd [add_xy + 4]
  fadd [add_xy + 4]
  fstp [s_y]
  invoke glColor3f, 0.0, 0.0, 0.0
  stdcall ui_draw_rectangle, [x], [y], [s_x], [s_y] 
 
  ret
endp
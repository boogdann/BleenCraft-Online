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
  
  invoke glColor3f, 0.73, 0.73, 0.73;
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

proc ui_renderBag uses esi, WindowRect, tools_count, tools_arr, pointer 
  locals
    bag_width    dd ?
    bag_height   dd 0.13
    cur_x        dd ?
    cur_y        dd -0.95
    n_2          dd 2.0
    
    n_15         dd 15.0
    elm_x        dd ?
    elm_y        dd ?
    x_add        dd ?
    y_add        dd ?
    tmp_xy       dd ?, ?
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
  
  fld [bag_height]
  fld [bag_height]
  fdiv [n_15]
  fst [y_add]
  fsubp
  fsub [y_add]
  fstp [elm_y]
  
  fld [bag_width]
  fld [bag_width]
  fdiv [n_15]
  fst [x_add]
  fsubp
  fsub [x_add]
  fstp [elm_x]
  
  
  
  mov esi, 0
  .DrawLoop:
    fld [cur_x]
    fadd [x_add]
    fstp [tmp_xy]
    fld [cur_y]
    fadd [y_add]
    fstp [tmp_xy + 4]
    invoke glColor3f, 0.43, 0.37, 0.29
    stdcall ui_draw_rectangle, [tmp_xy], [tmp_xy + 4], [elm_x], [elm_y]
    invoke glColor3f, 0.63, 0.57, 0.45
    stdcall ui_draw_rectangle, [cur_x], [cur_y], [bag_width], [bag_height]
    fld [cur_x]
    fadd [bag_width]
    fstp [cur_x]
  inc esi
  cmp esi, [tools_count]
  jnz .DrawLoop
  
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
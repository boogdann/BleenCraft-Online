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

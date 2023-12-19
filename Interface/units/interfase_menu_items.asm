proc ui_drawButton uses esi edi, WindowRect, x, y, s_x, s_y, id, text, textLen

  locals 
    n_30     dd    30.0
    n_TEXT   dd    25.0
    n_2      dd    ?
    n_2_2    dd    2.0
    tmp_xy   dd    ?, ?
    add_xy   dd    0.005, ?
    
    isIn     dd    0
    
    textSize    dd  ?
    textWidth   dd  ?
    textHeight  dd  ?
    textX       dd  ?
  endl
  
  fld [s_y]
  fdiv [n_TEXT]
  fstp [textSize]
  stdcall ui_getTextSizes, [WindowRect], [textLen], [textSize]
  mov [textWidth], eax
  mov [textHeight], ecx
  
  fld [x]
  fld [s_x]
  fsub [textWidth]
  fdiv [n_2_2]
  faddp
  fstp [textX]
  
  
  invoke glColor3f, 1.0, 1.0, 1.0
  stdcall ui_draw_text, [WindowRect], [text], [textLen], [textX], [y], [textSize]
  
  
  stdcall ui_CheckMouseIn, [WindowRect], [x], [y], [s_x], [s_y]
  cmp eax, 0
  jz @F
     mov [isIn], 1
     mov eax, [id]
     mov [Selected_ButtonId], eax
  @@:
  
  cmp [id], -1
  jnz @F
      invoke glColor4f, 0.4, 0.7, 0.4, 1.0 
      jmp .SkipDrawBackground
  @@:
  invoke glColor4f, 0.44, 0.44, 0.44, 1.0
  cmp [isIn], 1
  jnz @F
    invoke glColor4f, 0.37, 0.37, 0.37, 1.0
  @@:
  .SkipDrawBackground:
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
  
  cmp [id], -1
  jz .SkipDrawBackground1
  invoke glColor4f, 0.66, 0.66, 0.66, 1.0
  stdcall ui_draw_rectangle, [x], [y], [s_x], [s_y] 
  .SkipDrawBackground1:
  
  fld [x]
  fadd [add_xy]
  fstp [x]
  fld [y]
  fsub [add_xy + 4]
  fstp [y]
  invoke glColor4f, 0.33, 0.33, 0.33, 1.0
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
  invoke glColor4f, 0.0, 0.0, 0.0, 1.0
  stdcall ui_draw_rectangle, [x], [y], [s_x], [s_y] 
 
  ret
endp


proc ui_renderBackground uses esi edi, WindowRect, addiction
  locals
    CountH   dd   20
    CountW   dd   ?
    
    SizePx   dd   ?
    
    sizes    dd   ?, ?
    
    curX     dd   ?
    curY     dd   ?
    n_2      dd   2.0
    
    addict   dd   ?
  endl
  
  mov esi, [WindowRect]
  fild dword[esi + 12]
  fild [CountH]
  fdivp
  fstp [SizePx]
  
  fild dword[esi + 8]
  fdiv [SizePx]
  fistp [CountW] 
  add [CountW], 2
  
  fld  [n_2]
  fild [CountH]
  fdivp
  fstp [sizes + 4]
  
  fild dword[esi + 12]
  fild dword[esi + 8]
  fdivp
  fmul [sizes + 4]
  fstp [sizes]
  
  mov eax, [addiction]
  mov [addict], eax
  
  fld [addict]
  fild [CountW]
  fdivp
  fstp [addict]
  
  
  invoke glEnable, GL_TEXTURE_2D
  invoke glBindTexture, GL_TEXTURE_2D, [gf_block.Dirt]
  
  mov [curY], -1.0
  mov ecx, 0
  .DrawColumn:
    mov [curX], -1.0
    fld [curX]
    fsub [sizes]
    fadd [addict]
    fstp [curX]
    mov edi, 0
    .DrawRow:
        push ecx
        stdcall ui_draw_rectangle_textured_block_v2, [curX], [curY], [sizes], [sizes + 4]
        pop ecx
        fld [curX]
        fadd [sizes]
        fstp [curX]
    inc edi
    cmp edi, [CountW]
    jnz .DrawRow
    
  fld [curY]
  fadd [sizes + 4]
  fstp [curY] 
  inc ecx
  cmp ecx, [CountH]
  jnz .DrawColumn
  
  invoke glDisable, GL_TEXTURE_2D
  
  ret
endp

proc ui_render_input uses esi edi, WindowRect, x, y, s_x, s_y, id, text, textLen, outData
  locals 
    n_30     dd    30.0
    n_TEXT   dd    25.0
    n_2      dd    ?
    n_2_2    dd    2.0
    tmp_xy   dd    ?, ?
    add_xy   dd    0.005, ?
    
    isIn     dd    0
    
    textSize    dd  ?
    textWidth   dd  ?
    textHeight  dd  ?
    textX       dd  ?
  endl
  
  mov esi, [outData]
  cmp byte[esi], 0
  jnz .RenderNewtext
  
  cmp [textLen], 0
  jz .SkipText
  mov eax, [id]
  cmp [CurFocus], eax
  jz .SkipText
        fld [s_y]
        fdiv [n_TEXT]
        fstp [textSize]
        stdcall ui_getTextSizes, [WindowRect], [textLen], [textSize]
        mov [textWidth], eax
        mov [textHeight], ecx  
    
        fld [x]
        fld [s_x]
        fsub [textWidth]
        fdiv [n_TEXT]
        faddp
        fstp [textX]
    
      invoke glColor3f, 0.4, 0.4, 0.4
      stdcall ui_draw_text, [WindowRect], [text], [textLen], [textX], [y], [textSize]
  .SkipText:
  
  mov eax, [id]
  cmp [CurFocus], eax
  jnz .SkipFocusOut 
        .RenderNewtext:
        mov esi, [outData]
        movzx eax, byte[esi]
        cmp eax, 0
        jz .SkipFocusOut
        
        fld [s_y]
        fdiv [n_TEXT]
        fstp [textSize]
        stdcall ui_getTextSizes, [WindowRect], eax, [textSize]
        mov [textWidth], eax
        mov [textHeight], ecx  
    
        fld [x]
        fld [s_x]
        fsub [textWidth]
        fdiv [n_TEXT]
        faddp
        fstp [textX]
    
      invoke glColor3f, 0.7, 0.7, 0.7
      mov esi, [outData]
      movzx eax, byte[esi]
      inc esi
      stdcall ui_draw_text, [WindowRect], esi, eax, [textX], [y], [textSize]
  .SkipFocusOut:
  
  
  
  stdcall ui_CheckMouseIn, [WindowRect], [x], [y], [s_x], [s_y]
  cmp eax, 0
  jz @F
     mov [isIn], 1
     mov eax, [id]
     mov [Selected_ButtonId], eax
  @@:
  
  invoke glColor4f, 0.33, 0.33, 0.33, 1.0
  mov eax, [id]
  cmp [CurFocus], eax
  jz .inFocus
  cmp [isIn], 1
  jnz @F
    .inFocus:
    invoke glColor4f, 0.55, 0.55, 0.55, 1.0
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
  
  invoke glColor4f, 0.28, 0.28, 0.28, 1.0
  
  stdcall ui_draw_rectangle, [x], [y], [s_x], [s_y] 
  
  fld [x]
  fadd [add_xy]
  fstp [x]
  fld [y]
  fsub [add_xy + 4]
  fstp [y]
  invoke glColor4f, 0.05, 0.05, 0.05, 1.0
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
  invoke glColor4f, 0.0, 0.0, 0.0, 1.0
  stdcall ui_draw_rectangle, [x], [y], [s_x], [s_y] 
 
  ret
endp


proc AddLetterToInput uses esi edi, input, Letter, AllowLetters, AllowNums 

  mov esi, [input]
  movzx eax, byte[esi]
  inc esi
  add esi, eax
  ;esi - new letter adress
  
  cmp [Letter], VK_BACK
  jnz @F 
     mov esi, [input]
     mov dl, 0
     cmp byte[esi], dl
     jz .Return
     dec byte[esi]
     jmp .Return
  @@:
  
  push esi
  mov esi, [input]
  cmp byte[esi], 15
  pop esi
  jz .Return  
  
  mov dl, byte[MAX_LEN_INPUT]
  push esi
  mov esi, [input]
  cmp byte[esi], dl
  pop esi
  jz .Return   
  
  
  cmp [Letter], 'A'
  jl @F
  cmp [Letter], 'Z'
  jg @F
  cmp [AllowLetters], 1
  jnz @F     
     invoke GetKeyState, VK_SHIFT
     cmp eax, 0
     jnz .LowLetters
       mov al, byte[Letter]
       mov byte[esi], al
       mov esi, [input]
       inc byte[esi]
       jmp .Return  
     .LowLetters:
       mov al, byte[Letter]
       sub al, 'A'
       add al, 'a'
       mov byte[esi], al
       mov esi, [input]
       inc byte[esi]
       jmp .Return
  @@:
  
  cmp [Letter], 0xBE
  jnz @F
  cmp [AllowLetters], 1
  jnz @F
     mov byte[esi], '.'
     mov esi, [input]
     inc byte[esi]
     jmp .Return  
  @@:
  
  cmp [Letter], '0'
  jl @F
  cmp [Letter], '9'
  jg @F
  cmp [AllowNums], 1
  jnz @F
     mov al, byte[Letter]
     mov byte[esi], al
     mov esi, [input]
     inc byte[esi]
     jmp .Return  
  @@:
  
  jmp .Return
  
  .Return:
  ret
endp

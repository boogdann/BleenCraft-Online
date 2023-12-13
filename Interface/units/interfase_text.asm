proc ui_draw_text uses esi edi, WindowRect, text, len, x, y, size
  locals 
    posX  dd ?
    addX  dd ? 
    
    n_8           dd   9.0
    widthLetter   dd   6.5
  endl
  
  mov eax, [x]
  mov [posX], eax
  
  fld [size]
  fmul [widthLetter]
  fstp [addX]
  
  fld [y]
  mov esi, [WindowRect]
  mov eax, [size]
  mov [size], eax
  fild dword[esi + 8]
  fild dword[esi + 12]
  fdivp
  fmul [size]
  fmul [n_8]
  faddp
  fstp [y]

  mov edi, [text]
  mov esi, 0 
  @@:
    movzx eax, byte[edi + esi]
    sub eax, 'a'
    stdcall ui_draw_letter, [WindowRect], UI_LettersLow, eax, [size], [posX], [y]
    
    fld [posX]
    fadd [addX]
    fstp [posX]
  inc esi
  cmp esi, [len]
  jnz @B


  ret
endp


;return in eax - width
;return in ecx - height
proc ui_getTextSizes uses esi, WindowRect, len, size
  locals
    widthLetter   dd   6.5
    width         dd   ? 
    height        dd   ?
  endl
  
  mov esi, [WindowRect]
  mov eax, [size]
  mov [size], eax
  fild dword[esi + 8]
  fild dword[esi + 12]
  fdivp
  fmul [size]
  fstp [height]
  
  fld [size]
  fmul [widthLetter]
  fild [len]
  fmulp
  fstp [width]
  ;Return
  mov eax, [width]
  mov ecx, [height]

  ret
endp


proc ui_draw_letter uses esi edi, WindowRect, LetterArr, LetterIndex, Size, X, Y
  locals
    SizeXY    dd    ?, ?
    posXY     dd    ?, ?
  endl
  
  mov esi, [WindowRect]
  mov eax, [Size]
  mov [SizeXY], eax
  fild dword[esi + 8]
  fild dword[esi + 12]
  fdivp
  fmul [SizeXY]
  fstp [SizeXY + 4]
  
  mov esi, [LetterIndex]
  imul esi, 8*5
  add esi, [LetterArr]
  
  mov eax, [Y]
  mov [posXY + 4], eax
  mov ecx, 0
  .ColumnCircle:
      mov eax, [X]
      mov [posXY], eax
      mov edx, 0
      .RowCircle:
          cmp byte[esi], 0
          jz .SkipDraw
              push ecx edx
              stdcall ui_draw_rectangle, [posXY], [posXY + 4], [SizeXY], [SizeXY + 4]
              pop edx ecx
          .SkipDraw:
      
          fld  [posXY]
          fadd [SizeXY]
          fstp [posXY]
          inc esi
      inc edx
      cmp edx, 5
      jnz .RowCircle
      fld  [posXY + 4]
      fsub [SizeXY + 4]
      fstp [posXY + 4]
  inc ecx
  cmp ecx, 8
  jnz .ColumnCircle
  
  
  ret
endp
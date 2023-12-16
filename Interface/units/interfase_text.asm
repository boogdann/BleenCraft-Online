proc ui_draw_text uses esi edi, WindowRect, text, len, x, y, size
  locals 
    posX  dd ?
    addX  dd ? 
    
    n_8           dd   9.0
    widthLetter   dd   6.5
    lettersArr    dd   ?
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
    cmp byte[edi + esi], 'a'
    jl .Skip1
      sub eax, 'a'
      mov [lettersArr], UI_LettersLow
      jmp .ReadyGet
    .Skip1:
    cmp eax, 'A'
    jl .Skip2
      sub eax, 'A'
      mov [lettersArr], UI_LettersHigh
      jmp .ReadyGet
    .Skip2:
    cmp eax, '0'
    jl .Skip3
      sub eax, '0' 
      mov [lettersArr], UI_LettersNums
      jmp .ReadyGet
    .Skip3:
    cmp eax, '.'
    jnz .SkipRender
      mov eax, 10
      mov [lettersArr], UI_LettersNums
    .ReadyGet:
    stdcall ui_draw_letter, [WindowRect], [lettersArr], eax, [size], [posX], [y]
    .SkipRender:
    fld [posX]
    fadd [addX]
    fstp [posX]
  inc esi
  cmp esi, [len]
  jnz @B

  ret
endp


;eax - nums count
;num_text - string
proc ui_getNumText uses esi edi, num
    locals
      count   dd   0
    endl        
             
    mov eax, [num]
    mov ecx, 10
    mov edi, num_text + 4

convert_loop:
    xor edx, edx
    div ecx
    add dl, '0'
    dec edi
    mov [edi], dl
    inc [count]
    test eax, eax
    jnz convert_loop
            
  ;Return:
  mov eax, [count]          
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
  cmp [LetterArr], UI_LettersHigh
  jl @F
    fld  [posXY + 4]
    fadd [SizeXY + 4]
    fstp [posXY + 4]
  @@:
  
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

proc SetNumInInput uses esi edi eax, num, input
  locals
    count   dd   0
  endl        
           
  mov ecx, 10
  mov edi, [input]
  mov eax, [num]

  .len_loop:
    xor edx, edx
    div ecx
    inc [count]
    test eax, eax
    jnz .len_loop
    
  push [count]
  mov edi, [input]
  mov eax, [num]
  add edi, [count]
  inc edi
  .convert_loop:
    xor edx, edx
    div ecx
    add dl, '0'
    dec edi
    mov [edi], dl
    inc [count]
    test eax, eax
    jnz .convert_loop
    
  pop [count]
  mov eax, [count]
  mov edi, [input]
  mov byte[edi], al

  
  
  ret
endp

proc GetNumFromInput uses esi edi ecx edx, input 
  mov esi, [input]
  movzx ecx, byte[esi] 
  inc esi
  xor eax, eax 
  
  cmp ecx, 0
  jz .Return
  .convert_loop:
    movzx edx, byte[esi] 
    sub edx, '0'          
    imul eax, 10        
    add eax, edx         

    inc esi             
    dec ecx       
  jnz .convert_loop 
    
  .Return:
  ret
endp
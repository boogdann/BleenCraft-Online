proc ct_check_turns uses esi, playerTurn
  locals
      center       POINT
      tmpCamera    dd        ?
      maxDegre     dd        90
      minDegre     dd       -90
  endl
  
  mov esi, [playerTurn]

  ;Центр экрана по X
  mov eax, [WindowRect.right]
  xor edx, edx
  mov ebx, 2
  div ebx
  mov [center.x], eax
  
  ;Центр экрана по Y
  mov eax, [WindowRect.bottom]
  xor edx, edx
  mov ebx, 2
  div ebx
  mov [center.y], eax
  
  
  invoke GetCursorPos, ct_mouse
  ;Сдвиг по X
  mov eax, [center.x]
  sub [ct_mouse.x], eax
  
  ;Сдвиг по Y
  mov eax, [center.y]
  sub [ct_mouse.y], eax
     
  fld  dword[esi + 4]
  fild [ct_mouse.x]
  fmul [ct_sensitivity]
  faddp
  fstp dword[esi + 4]
  
  fld  dword[esi]
  fild [ct_mouse.y]
  fmul [ct_sensitivity]
  fsubp
  fstp dword[esi] 
  
  
  fld dword[esi]
  fistp dword[tmpCamera]
  mov eax, [tmpCamera]
  cmp [maxDegre], eax 
  jl .change
  
  cmp eax, [minDegre]
  jl .change
  jmp @F
  
  .change:
    fld  dword[esi]
    fild [ct_mouse.y]
    fmul [ct_sensitivity]
    faddp
    fstp dword[esi]
  @@:
  
  invoke SetCursorPos, [center.x], [center.y]
  
  ret
endp

proc ct_change_mouse, isShowen
  cmp [isShowen], 1
  jnz .hide
     cmp [ct_is_mouse], 1
     jz @F
     invoke  ShowCursor, 1
     mov [ct_is_mouse], 1
  jmp @F
  .hide: 
     cmp [ct_is_mouse], 0
     jz @F
     invoke  ShowCursor, 0
     mov [ct_is_mouse], 0
  @@:
  ret
endp
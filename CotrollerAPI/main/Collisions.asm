proc ct_collisionsBegin uses esi edi, playerPos
  mov esi, [playerPos]
  fld dword[esi]
  fstp [ct_lastPos]
  fld dword[esi + 4]
  fstp [ct_lastPos + 8]
  fld dword[esi + 8]
  fstp [ct_lastPos + 8]
  ret
endp


proc ct_collisionsCheck, playerPos, lastPos, Field, X, Y, Z

  locals
    Pl_pos    dd    ?, ?, ? 
  endl
  
  mov esi, [playerPos]
  fld dword[esi]
  fistp [Pl_pos]
  fld dword[esi + 4]
  fistp [Pl_pos + 8]
  fld dword[esi + 8]
  fistp [Pl_pos + 4]

  stdcall ct_isBlock, [Field], [X], [Y],\
                      [Pl_pos], [Pl_pos + 4], [Pl_pos + 8]
                      
  cmp eax, 1
  jnz @F
    invoke ExitProcess, 0
  @@:
   
  ret
endp 


proc ct_isBlock uses esi, Field, X_SIZE, Y_SIZE, X, Y, Z

  mov esi, [Field.Blocks]
  mov eax, [X_SIZE]
  imul [Y_SIZE]
  imul [Z]
  add esi, eax
  
  mov eax, [X_SIZE] 
  imul [Y]
  add esi, eax
  add esi, [X]
  
  mov eax, 0
  cmp byte[esi], 0
  jz @F
     mov eax, 1
  @@:
   
  ret
endp 


proc ct_fall_check, playerPos
  locals
    g       dd      0.00002
    curTime dd     ?
  endl
  
  invoke GetTickCount
  sub eax, [ct_last_ch_spd]
  cmp eax, 10
  jl @F
    fld  [ct_fall_speed]
    fadd [g]
    fstp [ct_fall_speed]
    mov [ct_last_ch_spd], eax
  @@:
  
  mov esi, [playerPos]
  fld  dword[esi + 4]
  fsub [ct_fall_speed]
  fstp dword[esi + 4]

  ret
endp


;Ïðûæîê
proc ct_check_Jump

  locals
      Jump_speed  dd    -0.007
  endl

  cmp [ct_isJump], 0
  jz @F
  invoke  GetAsyncKeyState, VK_SPACE
  cmp eax, 0
  jz @F
      fld [Jump_speed]
      fstp [ct_fall_speed]
  @@:

  ret
endp
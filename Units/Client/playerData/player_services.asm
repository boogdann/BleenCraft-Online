proc _client.CopyPlayerData uses esi
  ;Init last data
  ;=== position ======
  mov esi, [cl_PosAddr]
  mov eax, [esi]
  mov [cl_CurPos], eax
  mov eax, [esi + 4]
  mov [cl_CurPos + 4], eax
  mov eax, [esi + 8]
  mov [cl_CurPos + 8], eax
  
  ;====== turn =======
  mov esi, [cl_TurnAddr]
  mov eax, [esi]
  mov [cl_CurTurn], eax
  mov eax, [esi + 4]
  mov [cl_CurTurn + 4], eax
  mov eax, [esi + 8]
  mov [cl_CurTurn + 8], eax
  ;===================
  
  mov esi, [cl_HandItemAddr]
  mov eax, [esi]
  mov [cl_CurHandItem], eax
  
  mov esi, [cl_StateAddr]
  mov eax, [esi]
  mov [cl_CurState], eax

  ret
endp

proc _client.CreatePlayerData uses esi edi, buffer
  ;Init last data
  mov edi, [buffer]
  ;=== position ======  
  mov eax, [cl_CurPos]
  mov [edi], eax
  add edi, 4
  mov eax, [cl_CurPos + 4]
  mov [edi], eax
  add edi, 4
  mov eax, [cl_CurPos + 8]
  mov [edi], eax
  add edi, 4
  ;====== turn =======
  mov eax, [cl_CurTurn]
  mov [edi], eax
  add edi, 4
  mov eax, [cl_CurTurn + 4]
  mov [edi], eax
  add edi, 4
  mov eax, [cl_CurTurn + 8]
  mov [edi], eax
  add edi, 4
  ;===================
  
  mov eax, [cl_CurHandItem]
  mov [edi], eax
  add edi, 4
  
  mov eax, [cl_CurState]
  mov [edi], eax
  add edi, 4

  ret
endp

;eax = 0 => equil | eax = 1 => changed
proc _client.Vec3cmp uses esi edi, vec1, vec2
  mov esi, [vec1]
  mov edi, [vec2]
  
  mov ebx, 0
  .CmpLoop:
    mov eax, [esi + ebx]
    cmp eax, [edi + ebx]
    jne .NotEqil 
  add ebx, 4
  cmp ebx, 12
  jne .CmpLoop 
  
  xor eax, eax
  jmp .Return
  .NotEqil:
      mov eax, 1
  .Return:
  ret
endp

;eax = 0 => equil | eax = 1 => changed
proc _client.CmpPlayerData uses esi edi
  stdcall _client.Vec3cmp, [cl_PosAddr], cl_CurPos
  cmp eax, 0
  jne .NotEqil
  stdcall _client.Vec3cmp, [cl_TurnAddr], cl_CurTurn
  cmp eax, 0
  jne .NotEqil
  
  mov esi, [cl_HandItemAddr]
  mov eax, [esi]
  cmp [cl_CurHandItem], eax
  jne .NotEqil
  
  mov esi, [cl_StateAddr]
  mov eax, [esi]
  cmp [cl_CurState], eax
  jne .NotEqil
  
  xor eax, eax 
  jmp .Return
  .NotEqil:
      stdcall _client.CopyPlayerData
      mov eax, 1
  .Return:
  ret
endp


proc _cl_users_dataUpdate, userId, userData
  cmp [userId], 1
  jnz @F
    invoke ExitProcess, 0
  @@:
  
  ret
endp

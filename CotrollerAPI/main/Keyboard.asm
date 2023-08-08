proc ct_on_keyDown, wParam
  
  ;Esc
  cmp [wParam], VK_ESCAPE
  jnz @F
     cmp [ct_is_mouse], 1
     jz .hide
       stdcall ct_change_mouse, 1
       jmp .skip
     .hide:
       stdcall ct_change_mouse, 0
     .skip:
     jmp .final
  @@:
  
  ;... Другие клавиши

  .final:  
  ret
endp


proc ct_check_moves, CameraPos, CameraTurn
  locals 
    Speed   dd   ?
  endl
  
  mov eax, [сt_WalkingSpeed]
  mov [Speed], eax
  invoke  GetAsyncKeyState, VK_SHIFT
  cmp eax, 0
  jz @F
      mov eax, [сt_RunningSpeed]
      mov [Speed], eax
  @@:

  ;Хождения:
  invoke  GetAsyncKeyState, $57 
  cmp eax, 0
  jz @F
     stdcall ct_moves, [CameraPos], [CameraTurn], [Speed], 1
  @@:
  invoke  GetAsyncKeyState, $41
  cmp eax, 0
  jz @F
     stdcall ct_moves, [CameraPos], [CameraTurn], [Speed], 2
  @@:
  invoke  GetAsyncKeyState, $53
  cmp eax, 0
  jz @F
     stdcall ct_moves, [CameraPos], [CameraTurn], [Speed], 3
  @@:
  invoke  GetAsyncKeyState, $44
  cmp eax, 0
  jz @F
     stdcall ct_moves, [CameraPos], [CameraTurn], [Speed], 4
  @@:

  ret
endp


proc ct_moves, CameraPos, CameraTurn, Speed, Direction
  locals 
       a  dd  ? 
       b  dd  ? 
       PiDegree dd 180.0 
    endl   
  
    mov esi, [CameraTurn] 
    mov edi, [CameraPos] 
                                
.OnMove:  

    ;Calculate a in radian          
    mov [a], 0.0
    ;Calculate b in radian 
    fldpi
    fmul dword [esi + 4] 
    fdiv dword [PiDegree] 
    fstp dword [b] 
 
    cmp [Direction], 1 ;Forward 
    jz .MoveForward 
    cmp [Direction], 2 ;Right
    jz .MoveRight 
    cmp [Direction], 3 ;Backward 
    jz .MoveBackWard  
    cmp [Direction], 4 ;Left 
    jz .MoveLeft 
    Jmp .Skip 
  
    .MoveForward: 
      ;CameraPos[1] = CameraPos[1] - cos(a)*sin(b) * WalkingSpeed 
      fld dword [edi] 
      fld [a] 
      fcos 
      fld [b] 
      fsin 
      fmulp 
      fmul [Speed] 
      fsubp 
      fstp dword [edi] 
      ;CameraPos[3] = CameraPos[3] + cos(a) * cos(b) * WalkingSpeed 
      fld dword [edi + 8] 
      fld [a] 
      fcos 
      fld [b] 
      fcos 
      fmulp 
      fmul [Speed]  
      faddp 
      fstp dword [edi + 8] 
    Jmp .Skip 
    .MoveBackWard: 
      ;CameraPos[1] = CameraPos[1] + cos(a)*sin(b) * WalkingSpeed 
      fld dword [edi] 
      fld [a] 
      fcos 
      fld [b] 
      fsin 
      fmulp 
      fmul [Speed]  
      faddp 
      fstp dword [edi] 
      ;CameraPos[3] = CameraPos[3] + cos(a) * cos(b) * WalkingSpeed 
      fld dword [edi + 8] 
      fld [a] 
      fcos 
      fld [b] 
      fcos 
      fmulp 
      fmul [Speed] 
      fsubp 
      fstp dword [edi + 8] 
    Jmp .Skip 
    .MoveLeft: 
      ;CameraPos[1] = CameraPos[1] - cos(b) * WalkingSpeed 
      fld dword [edi] 
      fld [b] 
      fcos 
      fmul [Speed] 
      fsubp 
      fstp dword [edi] 
      ;CameraPos[3] = CameraPos[3] - sin(b) * WalkingSpeed 
      fld dword [edi + 8] 
      fld  [b] 
      fsin 
      fmul [Speed]  
      fsubp 
      fstp dword [edi + 8] 
    Jmp .Skip 
    .MoveRight: 
      ;CameraPos[1] = CameraPos[1] + cos(b) * WalkingSpeed 
      fld dword [edi] 
      fld [b] 
      fcos 
      fmul [Speed] 
      faddp 
      fstp dword [edi] 
      ;CameraPos[3] = CameraPos[3] + sin(b) * WalkingSpeed 
      fld dword [edi + 8] 
      fld [b] 
      fsin 
      fmul [Speed] 
      faddp 
      fstp dword [edi + 8] 
    Jmp .Skip 
 
    .Skip:
  ret
endp
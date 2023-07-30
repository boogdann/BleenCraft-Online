proc MoveControllerFree, CameraTurn : DWORD, CameraPos : DWORD, Direction : DWORD
;===============================================================================
;====================Третий параметр задает направление движения================
;====================             1 - W - Forward               ================
;====================             2 - D - Right                 ================  
;====================             3 - S - Backward              ================
;====================             4 - A - Left                  ================
;===============================================================================

  locals 
       a  dd  ? 
       b  dd  ? 
       Pi dd  3.14159265359 
       PiDegree dd 180.0 
       WalkingSpeed dd 0.2 
    endl   
  
    mov esi, [CameraTurn] 
    mov edi, [CameraPos] 
 
    ;Calculate a in radian 
    fld dword [Pi] 
    fmul dword [esi] 
    fdiv dword [PiDegree] 
    fstp dword [a] 
    ;Calculate b in radian 
    fld dword [Pi] 
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
      fld dword [a] 
      fcos 
      fld dword [b] 
      fsin 
      fmulp 
      fld dword [WalkingSpeed] 
      fmulp 
      fsubp 
      fstp dword [edi] 
      ;CameraPos[2] = CameraPos[2] + sin(a) * WalkingSpeed 
      fld dword [edi + 4] 
      fld dword [a] 
      fsin 
      fld dword [WalkingSpeed] 
      fmulp 
      faddp 
      fstp dword [edi + 4] 
      ;CameraPos[3] = CameraPos[3] + cos(a) * cos(b) * WalkingSpeed 
      fld dword [edi + 8] 
      fld dword [a] 
      fcos 
      fld dword [b] 
      fcos 
      fmulp 
      fld dword [WalkingSpeed] 
      fmulp 
      faddp 
      fstp dword [edi + 8] 
    Jmp .Skip 
    .MoveBackWard: 
      ;CameraPos[1] = CameraPos[1] + cos(a)*sin(b) * WalkingSpeed 
      fld dword [edi] 
      fld dword [a] 
      fcos 
      fld dword [b] 
      fsin 
      fmulp 
      fld dword [WalkingSpeed] 
      fmulp 
      faddp 
      fstp dword [edi] 
      ;CameraPos[2] = CameraPos[2] + sin(a) * WalkingSpeed 
      fld dword [edi + 4] 
      fld dword [a] 
      fsin 
      fld dword [WalkingSpeed] 
      fmulp 
      fsubp 
      fstp dword [edi + 4] 
      ;CameraPos[3] = CameraPos[3] + cos(a) * cos(b) * WalkingSpeed 
      fld dword [edi + 8] 
      fld dword [a] 
      fcos 
      fld dword [b] 
      fcos 
      fmulp 
      fld dword [WalkingSpeed] 
      fmulp 
      fsubp 
      fstp dword [edi + 8] 
    Jmp .Skip 
    .MoveLeft: 
      ;CameraPos[1] = CameraPos[1] - cos(b) * WalkingSpeed 
      fld dword [edi] 
      fld dword [b] 
      fcos 
      fld dword [WalkingSpeed] 
      fmulp 
      fsubp 
      fstp dword [edi] 
      ;CameraPos[3] = CameraPos[3] - sin(b) * WalkingSpeed 
      fld dword [edi + 8] 
      fld dword [b] 
      fsin 
      fld dword [WalkingSpeed] 
      fmulp 
      fsubp 
      fstp dword [edi + 8] 
    Jmp .Skip 
    .MoveRight: 
      ;CameraPos[1] = CameraPos[1] + cos(b) * WalkingSpeed 
      fld dword [edi] 
      fld dword [b] 
      fcos 
      fld dword [WalkingSpeed] 
      fmulp 
      faddp 
      fstp dword [edi] 
      ;CameraPos[3] = CameraPos[3] + sin(b) * WalkingSpeed 
      fld dword [edi + 8] 
      fld dword [b] 
      fsin 
      fld dword [WalkingSpeed] 
      fmulp 
      faddp 
      fstp dword [edi + 8] 
    Jmp .Skip 
 
    .Skip: 


  ret
  
endp
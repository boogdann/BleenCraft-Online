proc MoveControllerFree, CameraTurn : DWORD, CameraPos : DWORD, Direction : DWORD
;===============================================================================
;====================РўСЂРµС‚РёР№ РїР°СЂР°РјРµС‚СЂ Р·Р°РґР°РµС‚ РЅР°РїСЂР°РІР»РµРЅРёРµ РґРІРёР¶РµРЅРёСЏ================
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
  
    endl   
  
    mov esi, [CameraTurn] 
    mov edi, [CameraPos] 
 
    cmp [_isCursor], 1
    jne  .Skip
                                
    cmp [isRunning], 1
    jne @F
    
    mov eax, [RunningSpeed]
    mov [CurrentSpeed], eax
    
    jmp .OnMove 
     
@@:

    mov eax, [WalkingSpeed]
    mov [CurrentSpeed], eax

.OnMove:

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
      fld dword [CurrentSpeed] 
      fmulp 
      fsubp 
      fstp dword [edi] 
      ;CameraPos[2] = CameraPos[2] + sin(a) * WalkingSpeed 
      fld dword [edi + 4] 
      fld dword [a] 
      fsin 
      fld dword [CurrentSpeed] 
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
      fld dword [CurrentSpeed] 
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
      fld dword [CurrentSpeed] 
      fmulp 
      faddp 
      fstp dword [edi] 
      ;CameraPos[2] = CameraPos[2] + sin(a) * WalkingSpeed 
      fld dword [edi + 4] 
      fld dword [a] 
      fsin 
      fld dword [CurrentSpeed] 
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
      fld dword [CurrentSpeed] 
      fmulp 
      fsubp 
      fstp dword [edi + 8] 
    Jmp .Skip 
    .MoveLeft: 
      ;CameraPos[1] = CameraPos[1] - cos(b) * WalkingSpeed 
      fld dword [edi] 
      fld dword [b] 
      fcos 
      fld dword [CurrentSpeed] 
      fmulp 
      fsubp 
      fstp dword [edi] 
      ;CameraPos[3] = CameraPos[3] - sin(b) * WalkingSpeed 
      fld dword [edi + 8] 
      fld dword [b] 
      fsin 
      fld dword [CurrentSpeed] 
      fmulp 
      fsubp 
      fstp dword [edi + 8] 
    Jmp .Skip 
    .MoveRight: 
      ;CameraPos[1] = CameraPos[1] + cos(b) * WalkingSpeed 
      fld dword [edi] 
      fld dword [b] 
      fcos 
      fld dword [CurrentSpeed] 
      fmulp 
      faddp 
      fstp dword [edi] 
      ;CameraPos[3] = CameraPos[3] + sin(b) * WalkingSpeed 
      fld dword [edi + 8] 
      fld dword [b] 
      fsin 
      fld dword [CurrentSpeed] 
      fmulp 
      faddp 
      fstp dword [edi + 8] 
    Jmp .Skip 
 
    .Skip:

  ret
  
endp

proc OnMouseMove, cameraTurn, sensitivity : DWORD 

  locals
    
    scr.x dd ?
    scr.y dd ?
    
    delX  dd ?
    delY  dd ?
    
    st    dd 2  
  
  endl
   
  ;В scr.x будет храниться деленная на 2 ширина экрана
  mov eax, [WindowRect.right]
  mov [scr.x], eax

  fld [scr.x]
  fild [st]
   
  fdivp
  
  fstp [scr.x]

  ;В scr.x будет храниться деленная на 2 высота экрана
  mov eax, [WindowRect.bottom]
  mov [scr.y], eax
  
  fld [scr.y]
  fild [st]
   
  fdivp
  
  fstp [scr.y]
  
  invoke GetCursorPos, mouse
  
  mov eax, [mouse.x]
  mov ebx, [mouse.y]
  
  mov edi, [cameraTurn]

  sub eax, [scr.x]
  mov [delX], eax
  
  fld dword[sensitivity]
  fimul [delX]
  
  fstp [delX]
  
  fld dword[edi + 4]
  fld [delX]
  
  faddp
  fstp dword[edi + 4]

;===============================================================================
;====================          ПОВОРОТЫ ПО ОСИ OY         ======================
;===============================================================================

  sub ebx, [scr.y]
  neg ebx
  mov [delY], ebx
  
  fld dword[sensitivity]
  fimul [delY]
  
  fstp [delY]
  
  fld dword[edi]
  fld [delY]
  
  faddp
  fstp dword[edi]  

  invoke SetCursorPos, [scr.x], [scr.y] 
    
  ret
  
endp

include "CotrollerAPI\main\CollisionsConst.asm"

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
  
  cmp [isDebug], 1
  jne .finish
  
  locals
    Pl_pos    dd    ?, ?, ? 
    Pl_feets  dd    1.6
    Pl_ass  dd  0.3
    Pl_step dd  0.4
    Pl_chest  dd  -1.0
    temp    dd  ?
    
    X_Next  dd  ?
    Y_Next  dd  ?
    Z_Next  dd  ?
    
  endl
  
  mov [toSkip], 0
  mov [ct_isJump], 0
   
  mov esi, [playerPos]

  fld dword[esi]
  fistp [Pl_pos]
  fld dword[esi + 4]
  fsub dword[Pl_feets]  
  fistp [Pl_pos + 8]
  fld dword[esi + 8]
  fistp [Pl_pos + 4]
  
  stdcall ct_isBlock, [Field], [X], [Y],\
                      [Pl_pos], [Pl_pos + 4], [Pl_pos + 8]
                      
  cmp [onGround], 1
  jne @F
    mov [ct_isJump], 1
    mov [toSkip], 1
  @@:
  
  ;2
  
  fld dword[esi]
  fadd dword[Pl_ass]
  fistp [Pl_pos] 
  fld dword[esi + 8]
  fistp [Pl_pos + 4]
  
  stdcall ct_isBlock, [Field], [X], [Y],\
                      [Pl_pos], [Pl_pos + 4], [Pl_pos + 8]
  
  cmp [onGround], 1
  jne @F
    mov [ct_isJump], 1
    mov [toSkip], 1
  @@:
  
  ; 3
  
  fld dword[esi]
  fsub dword[Pl_ass]
  fsub  dword[Pl_ass]
  fistp [Pl_pos] 
  fld dword[esi + 8]
  fistp [Pl_pos + 4]
  
  stdcall ct_isBlock, [Field], [X], [Y],\
                      [Pl_pos], [Pl_pos + 4], [Pl_pos + 8]
  
  cmp [onGround], 1
  jne @F
    mov [ct_isJump], 1
    mov [toSkip], 1
  @@:
  
  ; 4
  
  fld dword[esi]
  fadd  dword[Pl_ass]
  fistp [Pl_pos] 
  fld dword[esi + 8]
  fadd  dword[Pl_ass]
  fistp [Pl_pos + 4]
  
  stdcall ct_isBlock, [Field], [X], [Y],\
                      [Pl_pos], [Pl_pos + 4], [Pl_pos + 8]
  
  cmp [onGround], 1
  jne @F
    mov [ct_isJump], 1
    mov [toSkip], 1
  @@:
  
  ;5
   
  fld dword[esi]
  fadd  dword[Pl_ass]
  fistp [Pl_pos] 
  fld dword[esi + 8]
  fsub  dword[Pl_ass]
  fsub  dword[Pl_ass]
  fistp [Pl_pos + 4]
  
  stdcall ct_isBlock, [Field], [X], [Y],\
                      [Pl_pos], [Pl_pos + 4], [Pl_pos + 8]
  
  cmp [onGround], 1
  jne @F
    mov [ct_isJump], 1
    mov [toSkip], 1                                       
  @@:

 .finish:
 
    
  ret
endp 


proc ct_isBlock uses esi edx, Field, X_SIZE, Y_SIZE, X, Y, Z
  
  mov [onGround], 0
  
  locals
  
    Check   dd  ?
    
  endl

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
  jz .finish
     
     mov [onGround], 1
     mov [toSkip], 1
            
  .finish:

         
  ret
endp 


proc ct_fall_check, playerPos
  
  cmp [isFalling], 1
  jne .Skip
  
  cmp [toSkip], 1
  je .Skip
  
  cmp [onGround], 1
  je .Skip
  
  locals
    g       dd      0.0000009
    divConst          dd  9000000.0
    mulConst          dd  3.0
    curFallSpeed      dd  ? 
    tempVector        dd  0, 0, 0
  endl
   
  invoke GetTickCount
  
  sub eax, [fallTime]
  mov edx, eax
  mov [fallTime], eax
  
  fild [fallTime]
  fdiv [divConst]
  fstp [fallTime]
               
  fld [g]
  fmul [fallTime]
  fadd [ct_fall_speed]
  fstp [ct_fall_speed]
  
  fld [fallTime]
  fmul [ct_fall_speed]
  ;fdiv [mulConst]
  fstp [curFallSpeed]
  
  mov [fallTime], edx
  
  mov esi, [playerPos]
  
  ;œ–¿¬»À‹ÕŒ ¡Àﬂ“‹
  fld  dword[esi + 4]
  fsub [curFallSpeed]
  fstp dword[esi + 4]

  
.Skip:
    
  ret
endp

;œ˚ÊÓÍ
proc ct_check_Jump, playerPos 

  locals
      Jump_speed  dd    -0.005
  endl

  cmp [ct_isJump], 0
  jz @F
  invoke  GetAsyncKeyState, VK_SPACE
  cmp eax, 0
  jz @F
      mov [onGround], 0
      mov [toSkip], 0
      fld [Jump_speed]
      fstp [ct_fall_speed]
  @@:

  ret
endp
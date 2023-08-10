
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
    temp    dd  ?
    
    X_Next  dd  ?
    Y_Next  dd  ?
    Z_Next  dd  ?
    
  endl
  
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
    mov [ct_fall_speed], 0
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
    mov [ct_fall_speed], 0
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
    mov [ct_fall_speed], 0
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
    mov [ct_fall_speed], 0
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
    mov [ct_fall_speed], 0
  @@:
  
  
  cmp [onGround], 1
  jne @F
  
    mov [ct_isJump], 1
    jmp .finish
    
  @@:
    
    mov [ct_isJump], 0
 
 .finish:
 
    
  ret
endp 


proc ct_isBlock uses esi, Field, X_SIZE, Y_SIZE, X, Y, Z
  
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
            
  .finish:
  
        
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
  
  ;œ–¿¬»À‹ÕŒ ¡Àﬂ“‹
  mov esi, [playerPos]
  fld  dword[esi + 4]
  fsub [ct_fall_speed]
  fstp dword[esi + 4]

  ret
endp


;œ˚ÊÓÍ
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
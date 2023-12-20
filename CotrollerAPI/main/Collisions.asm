proc ct_collisionsCheck, playerPos, Field, X, Y, Z
  
  cmp [isDebug], 1
  jne .finish
                   
  locals
    Pl_pos    dd    ?, ?, ? 
    Pl_feets  dd    1.7
    Pl_ass    dd  1.5
    Pl_step   dd  0.4
    Pl_chest  dd  -1.0
    temp      dd  4.0
                     
    tempHeight dd 0.3
                      
    X_Next    dd  ?
    Y_Next    dd  ?
    Z_Next    dd  ?
    
    Pl_temp_pos dd ?, ?, ?
    
  endl
  
  mov [toSkip], 0
  mov [ct_isJump], 0
   
  mov esi, [playerPos] 

  fld dword[esi + 4]
  fstp [Pl_temp_pos + 4]
  
  ;1

  fld dword[esi]
  fistp [Pl_pos]
  fld dword[esi + 4]
  fsub [Pl_feets]  
  fistp [Pl_pos + 8]
  fld dword[esi + 8]
  fistp [Pl_pos + 4]
  
  stdcall ct_isBlock, [Field], [X], [Y],\
                      [Pl_pos], [Pl_pos + 4], [Pl_pos + 8]
                      
  cmp [onGround], 1
  jne @F
    
    fld [Pl_temp_pos + 4]
    fadd [temp]
    fstp [playerPos + 4]

    fldz
    fstp [ct_jump_distancePerSecond]
    
    mov [ct_isJump], 1
    mov [toSkip], 1
  
    fld dword[esi]
    fistp [Pl_pos]
    fld dword[esi + 4]
    fsub dword[Pl_ass]  
    fistp [Pl_pos + 8]
    fld dword[esi + 8]
    fistp [Pl_pos + 4]
    
    stdcall ct_isBlock, [Field], [X], [Y],\
                      [Pl_pos], [Pl_pos + 4], [Pl_pos + 8]
    
    cmp [onGround], 1
    jne .finish
    
    mov [ct_isJump], 0
    
    fld dword[esi + 4]
    fadd [tempHeight] 
    fstp dword[esi + 4]
       
  @@:
  
 .finish:
   
    
  ret
endp 


proc ct_isBlock uses esi edx, Field, X_SIZE, Y_SIZE, X, Y, Z
  
  mov [onGround], 0
  mov [isWatter], 0
  
  locals
  
    Check   dd  ?
    
  endl

  mov esi, [Field.Blocks]
  cmp esi, 0
  jz .finish

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
     
     cmp byte[esi], 255
     jne @F
        mov [isWatter], 1
        jmp .finish 
     @@:
        
     mov [isWatter], 0
     
     stdcall getDamage
     
     fldz
     fstp [ct_damageFallSpeed]
     
     mov [onGround], 1
     mov [toSkip], 1
            
  .finish:

         
  ret
endp 


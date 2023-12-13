proc ct_watter, playerPos, Field, X, Y, Z

  locals
    
    playerHeight  dd  1.0 
    Pl_pos        dd  0, 0, 0
    
  endl

  mov esi, [playerPos]       
  
  cmp [isWatter], 1
  jne .notWater
  
  mov [ct_isJump], 1
  
  fld [ct_watter_velocity]
  fstp [ct_velocity]
  
  
  fld dword[esi]
  fistp [Pl_pos]
  fld dword[esi + 4]  
  fistp [Pl_pos + 8]
  fld dword[esi + 8]
  fistp [Pl_pos + 4]
  
  stdcall ct_isBlock, [Field], [X], [Y],\
                      [Pl_pos], [Pl_pos + 4], [Pl_pos + 8]
  
  cmp [isWatter], 1
  jne @F
    
    mov [UnderWater], 1
    jmp .skip
    
  @@:
  
    mov [UnderWater], 0
    
  .skip:
  
  fld dword [esi]
  fistp [Pl_pos]
  fld dword [esi + 4]
  fsub [playerHeight] 
  fistp [Pl_pos + 8]
  fld dword [esi + 8]
  fistp [Pl_pos + 4]
  
   
  stdcall ct_isBlock, [Field], [X], [Y],\
                       [Pl_pos], [Pl_pos + 4], [Pl_pos + 8]   
                                
   cmp [isWatter], 1
   je @F
      fld [ct_falling_velocity]
      fstp [ct_velocity]
      mov [ct_isJump], 0 
   @@:
  
  
  
.notWater:

  ret
endp

proc ct_isInWater, playerPos, Field, X, Y, Z

    locals
      Pl_pos dd 0, 0, 0
      playerFeets dd 1.6 
    endl
    
    mov esi, [playerPos] 
    
    fld dword[esi]
    fistp [Pl_pos]
    fld dword[esi + 8]
    fistp [Pl_pos + 4]

    fld dword[esi + 4]  
    fsub [playerFeets]
    fistp [Pl_pos + 8]
    
    stdcall ct_checkWater, [Field], [X], [Y],\
                           [Pl_pos], [Pl_pos + 4], [Pl_pos + 8]
                           
    ret
endp  

proc ct_checkWater uses esi edx, Field, X_SIZE, Y_SIZE, X, Y, Z
  
  mov [ct_inWater], 0

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
  cmp byte[esi], 255 
  jne .finish
    
      mov [ct_inWater], 1 
              
  .finish:

         
  ret
endp 

proc ct_isWaterAround uses esi edx, Field, X_SIZE, Y_SIZE, X, Y, Z
  
  mov [onGround], 0
  mov [isWatter], 0
  
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
  cmp byte[esi], 255 
  jne .finish
     
     mov [ct_water_around], 1
            
  .finish:

         
  ret
endp 

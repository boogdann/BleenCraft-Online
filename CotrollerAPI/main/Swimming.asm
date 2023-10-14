proc ct_watter, playerPos, Field, X, Y, Z

  locals
    
    playerHeight  dd 1.0
    Pl_pos    dd  0, 0, 0
    
  endl

  mov esi, [playerPos]
  
  mov [UnderWater], 0
  
  cmp [isWatter], 1
  jne .notWater
  
  mov [ct_isJump], 1
  
  fld [ct_watter_velocity]
  fstp [ct_velocity]
  
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
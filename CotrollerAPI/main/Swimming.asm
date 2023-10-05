proc ct_watter, playerPos, Field, X, Y, Z

  locals
    
    playerHeight  dd  0.3
    Player_pos    dd  0, 0, 0
    
  endl

  mov esi, [playerPos]
  
  cmp [isWatter], 1
  jne .finish
  
  mov [ct_isJump], 1
  
  fld [ct_watter_velocity]
  fstp [ct_velocity]
  
  fld dword [esi]
  fistp [Player_pos]
  fld dword [esi + 4]
  fadd [playerHeight]
  fistp [Player_pos + 8]
  fld dword [esi + 8]
  fistp [Player_pos + 4]
  
  stdcall ct_isBlock, [Field], [X], [Y],\
                      [Player_pos], [Player_pos + 4], [Player_pos + 8]             
  cmp [isWatter], 1
  je .finish
  
     invoke ExitProcess, 0   
     fld [ct_falling_velocity]
     fstp [ct_velocity]
     
.finish:

  ret
endp
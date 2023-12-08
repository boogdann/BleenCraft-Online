proc anim_RightHand, playerPos, playerTurn

  locals
    YVector       dd 0.11  ;0.65
    MAX_DY        dd 0.1
    
    PiDegree      dd 180.0
    
    angleX        dd 110.0
    
    a dd 0.0        
    b dd 0.0
    
    XVector       dd 0
  
    tmp           dd 0.13
    
  endl

  mov esi, [playerTurn]
  mov edi, [playerPos]
  
  fldpi
  fmul dword[esi]
  fdiv [PiDegree]
  fstp [a]
  
  fldpi
  fmul dword[esi + 4]
  fdiv [PiDegree]
  fstp [b]
  
  ;cameraPos[1]
  fld dword[edi]
  fld [a]
  fcos
  fld [b]
  fsin
  fmulp
  fmul [XAxisMuliplier]
  fsubp 
  fstp [Anim_Hand_Position]
  
  fld [a]
  fistp [XVector]
  
  cmp [XVector], 0
  jl .skip
  
  ;cameraPos[2]
  fld dword[edi + 4]
  fld [a]
  fmul [YVector]
  faddp
  fsub [MAX_DY]
  fstp [Anim_Hand_Position + 4] 
    
  jmp .next
  
  .skip:
    
    fld dword[edi + 4]
    fsub [tmp]
    fstp [Anim_Hand_Position + 4] 
    
  .next:
                                
  ;cameraPos[3]
  fld dword[edi + 8]
  fld [a]
  fcos
  fld [b]
  fcos
  fmulp
  fmul [XAxisMuliplier]
  faddp 
  fstp [Anim_Hand_Position + 8]
  
  fld dword[esi]
  fadd [angleX]
  fstp [Anim_Hand_Turn]
  fld dword[esi + 4]
  fstp [Anim_Hand_Turn + 4]
  fld dword[esi + 8]
  fstp [Anim_Hand_Turn + 8]
  
  stdcall gf_renderObj3D, obj.Player.LHand.Handle, [tx.Player.Handle], 0,\
                                Anim_Hand_Position, Anim_Hand_Turn, 0.05, 0
  ret
endp 


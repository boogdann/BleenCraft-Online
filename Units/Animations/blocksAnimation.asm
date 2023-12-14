proc anim_blockInHand, playerPos, playerTurn

  locals
    YVector       dd 0.05  ;0.65
    MAX_DY        dd 0.1
    
    PiDegree      dd 180.0
    
    angleX        dd 110.0
    
    a dd 0.0        
    b dd 0.0
    
    angleY        dd 20.0
    
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
  
  ;cameraPos[2]
  fld dword[edi + 4]
  fld [a]
  fmul [YVector]
  faddp
  fstp [Anim_Hand_Position + 4] 
                                
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
  fstp [Anim_Hand_Turn]
  fld dword[esi + 4]
  fstp [Anim_Hand_Turn + 4]
  fld dword[esi + 8]
  fadd [angleY]
  fstp [Anim_Hand_Turn + 8]
  
  mov edi, [chosenBlockFromInv]
  dec edi
  imul edi, 4
  add edi, TextureHandles
  
  stdcall gf_renderObj3D, obj.Cube.Handle, dword[edi], 0,\
                                Anim_Hand_Position, Anim_Hand_Turn, 0.05, 0
  ret
endp 


proc detectBlock, Field, cameraTurn, playerPos, X, Y

  locals
    
    tempCamera dd 0.0, 0.0, 0.0
    tempVector dd 0, 0, 0
    
    currentVector dd 1.0
    PiDegree      dd 180.0    
    temp          dd 0.5
      
    tempScale     dd 1.01
    
    a dd 0.0            
    b dd ?
    
  endl
  
  mov esi, [cameraTurn]
  mov edi, [playerPos]
  ;CameraPos[1] - cos(a) * sin(b) * currentConst 
  ;CameraPos[3] + cos(a) * cos(b) * currentConst
  ;CameraPos[2] - sin(a) * sin(b) * currentConst?
  
  fld dword[edi]
  fstp [tempCamera]
  fld dword[edi + 4]
  fstp [tempCamera + 4]
  fld dword[edi + 8]
  fstp [tempCamera + 8]
  
  fldpi
  fmul dword[esi]
  fdiv [PiDegree]
  fstp [a]
  
  fldpi
  fmul dword [esi + 4] 
  fdiv [PiDegree] 
  fstp [b]             

  mov ecx, 1

.zaloop: 

  mov [block_detected], 0
  mov [flag], 0
   
  ;Предыдущая позиция камеры
  fld [tempCamera]
  fstp [prevCubePos]
  fld [tempCamera + 4]
  fstp [prevCubePos + 4]
  fld [tempCamera + 8]
  fstp [prevCubePos + 8]
  
  ;cameraPos[1]
  fld [tempCamera]
  fld [a]
  fcos
  fld [b]
  fsin
  fmulp
  fmul [currentVector]
  fsubp
  fstp [tempCamera]
  
  ;cameraPos[2]
  fld [tempCamera + 4]
  fld [a]
  fsin 
  fmul [currentVector]
  faddp
  fstp [tempCamera + 4]
  
  ;cameraPos[3]
  fld [tempCamera + 8]
  fld [a]
  fcos
  fld [b]
  fcos
  fmulp
  fmul [currentVector]
  faddp
  fstp [tempCamera + 8]   
 
  fld [tempCamera]
  fistp [tempVector]
  fld [tempCamera + 4]
  fistp [tempVector + 8]
  fld [tempCamera + 8]
  fistp [tempVector + 4]   
  
  stdcall ct_detect_block, [Field], [X], [Y],\
                      [tempVector], [tempVector + 4], [tempVector + 8]
                      
  cmp [block_detected], 1
  jne @F
    
    mov [flag], 1
    
    mov [is_readyToBuild], 1
  
    fild [tempVector]
    fstp [selectCubeData]
    fild [tempVector + 4]
    fstp [selectCubeData + 8]
    fild [tempVector + 8]
    fstp [selectCubeData + 4]
    
    jmp .finish
    
  @@:
  
  inc ecx 
  
  fld [currentVector]
  fadd [temp]
  fstp [currentVector]
  
  cmp ecx, 3
  jl .zaloop
  
  .finish:
  
  ret
endp

proc ct_destroy_block, cubePos

  locals
    tempPos dd 0, 0, 0
  endl

  mov edi, [cubePos]
  
  fld dword[edi]
  fistp [tempPos]
  fld dword[edi + 4]
  fistp [tempPos + 4]
  fld dword[edi + 8]
  fistp [tempPos + 8]

  stdcall Field.SetBlockIndex, [tempPos], [tempPos + 8], [tempPos + 4], 0

  ret
endp

proc ct_build_block, prevCubePos

  locals
    tempPos dd 0, 0, 0
  endl

  mov edi, [prevCubePos]
  
  fld dword[edi]
  fistp [tempPos]
  fld dword[edi + 4]
  fistp [tempPos + 4]
  fld dword[edi + 8]
  fistp [tempPos + 8]

  stdcall Field.SetBlockIndex, [tempPos], [tempPos + 8], [tempPos + 4], 1

  ret
endp

proc ct_detect_block uses esi edx, Field, X_SIZE, Y_SIZE, X, Y, Z
  
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
     
     cmp byte[esi], 255
     jne @F
        jmp .finish 
     @@:
     
     mov [block_detected], 1
            
  .finish:
         
  ret
endp 
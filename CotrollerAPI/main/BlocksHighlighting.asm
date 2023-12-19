proc detectBlock, Field, cameraTurn, playerPos, X, Y

  locals
    
    tempCamera    dd 0.0, 0.0, 0.0
    tempVector    dd 0, 0, 0
    
    currentVector dd 0.1
    PiDegree      dd 180.0    
    temp          dd 0.1
      
    tempScale     dd 1.01
    
    a             dd 0.0            
    b             dd ?
    
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

.check_loop: 

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
    
    cmp [skip_destroying], 1
    jne .destroy_flag
      mov [destruction_time], 0
    .destroy_flag:
    
    cmp [build_by_click], 1
    jne .build_flag
      mov [building_time], 500
    .build_flag:
    
    mov edx, [tempVector]
    cmp edx, [prev_block_pos]
    je .firstCheck 
      mov [destruction_time], 0
    .firstCheck:
    
    mov edx, [tempVector + 4]
    cmp edx, [prev_block_pos + 8]
    je .secondCheck 
      mov [destruction_time], 0
    .secondCheck:
    
    mov edx, [tempVector + 8]
    cmp edx, [prev_block_pos + 4]
    je .thirdCheck 
      mov [destruction_time], 0
    .thirdCheck:
    
    fild [tempVector]
    fstp [selectCubeData]
    fild [tempVector + 4]
    fstp [selectCubeData + 8]
    fild [tempVector + 8]
    fstp [selectCubeData + 4]
    
    fild [tempVector]
    fistp [prev_block_pos]
    fild [tempVector + 4]
    fistp [prev_block_pos + 8]
    fild [tempVector + 8]
    fistp [prev_block_pos + 4]
    
    jmp .finish
    
  @@:
  
  inc ecx 
  
  fld [currentVector]
  fadd [temp]
  fstp [currentVector]
  
  cmp ecx, 10
  jl .check_loop
    
  .finish:
 
  ret
endp

proc ct_destroy_block, cubePos

  locals
    tempPos dd 0, 0, 0
    tempVector dd 0, 0, 0
    
    dTime dd 0
    
    Eps   dd 1.0
    
    destrTimeConst  dd 10
    
    MAX_TICKS_COUNT dd 100
    
  endl

  mov edi, [cubePos]
  
  ;Получение координат блока
  fld dword[edi]
  fistp [tempPos]
  fld dword[edi + 4]
  fistp [tempPos + 4]
  fld dword[edi + 8]
  fistp [tempPos + 8]

  cmp [UnderWater], 1
  jne @F
    jmp .WATER
  @@:
  
  fld dword[edi]
  fistp [tempVector]
  fld dword[edi + 4]
  fistp [tempVector + 4]
  fld dword[edi + 8]
  fistp [tempVector + 8]
  
  mov [ct_water_around], 0
  
  ;first check
  fld dword[edi]
  fadd [Eps]
  fistp [tempVector]
  
  stdcall ct_isWaterAround, [Field.Blocks], [WorldLength], [WorldWidth], [tempVector], [tempVector + 8], [tempVector + 4]
  
  cmp [ct_water_around], 1
  jne @F
    jmp .WATER
  @@:
  
  ;second check
  fld dword[edi]
  fsub [Eps]
  fistp [tempVector]
  
  stdcall ct_isWaterAround, [Field.Blocks], [WorldLength], [WorldWidth], [tempVector], [tempVector + 8], [tempVector + 4]
  
  cmp [ct_water_around], 1
  jne @F
    jmp .WATER
  @@:
  
  ;third check
  fld dword[edi + 8]
  fadd [Eps]
  fistp [tempVector + 8]
  
  stdcall ct_isWaterAround, [Field.Blocks], [WorldLength], [WorldWidth], [tempVector], [tempVector + 8], [tempVector + 4]
  
  cmp [ct_water_around], 1
  jne @F
    jmp .WATER
  @@:
  
  ;fourth check
  fld dword[edi + 8]
  fsub [Eps]
  fistp [tempVector + 8]
  
  stdcall ct_isWaterAround, [Field.Blocks], [WorldLength], [WorldWidth], [tempVector], [tempVector + 8], [tempVector + 4]
  
  cmp [ct_water_around], 1
  jne @F
    jmp .WATER
  @@:
  
  ;fifth check
  fld dword[edi]
  fsub [Eps]
  fistp [tempVector]
  fld dword[edi + 8]
  fsub [Eps]
  fistp [tempVector + 8]
  
  stdcall ct_isWaterAround, [Field.Blocks], [WorldLength], [WorldWidth], [tempVector], [tempVector + 8], [tempVector + 4]
  
  cmp [ct_water_around], 1
  jne @F
    jmp .WATER
  @@:
  
  ;sixth check
  fld dword[edi]
  fadd [Eps]
  fistp [tempVector]
  fld dword[edi + 8]
  fsub [Eps]
  fistp [tempVector + 8]
  
  stdcall ct_isWaterAround, [Field.Blocks], [WorldLength], [WorldWidth], [tempVector], [tempVector + 8], [tempVector + 4]
  
  cmp [ct_water_around], 1
  jne @F
    jmp .WATER
  @@:
  
  ;seventh check
  fld dword[edi]
  fsub [Eps]
  fistp [tempVector]
  fld dword[edi + 8]
  fadd [Eps]
  fistp [tempVector + 8]
  
  stdcall ct_isWaterAround, [Field.Blocks], [WorldLength], [WorldWidth], [tempVector], [tempVector + 8], [tempVector + 4]
  
  cmp [ct_water_around], 1
  jne @F
    jmp .WATER
  @@:
  
  ;eighth check
  fld dword[edi]
  fadd [Eps]
  fistp [tempVector]
  fld dword[edi + 8]
  fadd [Eps]
  fistp [tempVector + 8]
  
  stdcall ct_isWaterAround, [Field.Blocks], [WorldLength], [WorldWidth], [tempVector], [tempVector + 8], [tempVector + 4]
  
  cmp [ct_water_around], 1
  jne @F   
    jmp .WATER
  @@:
  
  .NOT_WATER:
  
  stdcall Field.SetBlockIndex, [tempPos], [tempPos + 8], [tempPos + 4], 0  
  
  jmp .getDestrBlock
  
  .WATER:
  
  stdcall Field.SetBlockIndex, [tempPos], [tempPos + 8], [tempPos + 4], 255  
  
  .getDestrBlock:
  
  mov eax, [block_isDestructible]
  
  cmp eax, Blocks.IS_DESTRUCTIBLE 
  jne @F
    
    cmp [ct_block_index], 22
    je .leaf
      stdcall addBlockToArray, selectCubeData   
    .leaf:
 
  @@:
    
.finish:

  ret
endp              

proc ct_build_block, prevCubePos

  locals
    tempPos dd 0, 0, 0
    tempVector dd 0, 0, 0
    playerCurPos dd 0, 0, 0
  endl
  
  cmp [workBench_opened], 1
  je .finish
  
  mov edi, [prevCubePos]
  
  fld dword[edi]
  fistp [tempPos]
  fld dword[edi + 4]
  fistp [tempPos + 4]
  fld dword[edi + 8]
  fistp [tempPos + 8]

  ;Check if block is inside player
  fld [PlayerPos]
  fistp [playerCurPos]
  fld [PlayerPos + 4]
  fistp [playerCurPos + 4]
  fld [PlayerPos + 8]
  fistp [playerCurPos + 8]
  
  mov ecx, 0
  
  mov eax, [playerCurPos]
  cmp [tempPos], eax
  jne @F
     inc ecx
  @@:
  
  mov eax, [playerCurPos + 4]
  cmp [tempPos + 4], eax
  jne @F
     inc ecx
  @@:

  mov eax, [playerCurPos + 8]
  cmp [tempPos + 8], eax
  jne @F
     inc ecx
  @@:
  
  cmp ecx, 3
  je .finish
  

  cmp [build_is_prohibited], 1
  je @F
  
     cmp [chosenBlockFromInv], 0
     je .finish
     
     cmp [chosenBlockFromInv], 234
     jge .finish
       
     stdcall Field.SetBlockIndex, [tempPos], [tempPos + 8], [tempPos + 4], [chosenBlockFromInv]
  
     mov eax, 27
     add eax, [currentChosenCell]
     stdcall Inventory.DecCell, eax
  
     stdcall removeBlock
  
  @@:

  .finish:

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
     
     stdcall Field.GetBlockIndex, [X], [Y], [Z]
     
     mov [ct_block_index], eax  
         
  .finish:
         
  ret
endp 
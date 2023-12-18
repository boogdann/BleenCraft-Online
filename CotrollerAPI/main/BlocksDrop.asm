proc getObj uses ebx, index

  mov edi, [index]
  inc edi  
  cmp edi, Tools.MinValueTool
  jl @F
      dec edi
      stdcall grafic.GetToolsObjHandles, edi
      mov [thrownBlockAddr], eax
      lea eax, [thrownBlockAddr]
      jmp .Render
  @@:  
  
  dec edi
  dec edi
  imul edi, 4
  add edi, TextureHandles 

  mov eax, edi

  mov ebx, obj.Cube.Handle

  .Render:
  
  mov edi, eax 
  mov edx, ebx

  ret
endp

proc addBlockToArray, blockPos

  locals
      currentIndex dd 0
  endl
  
  mov esi, [arrayOfDroppedBlocks] 
  
  mov ecx, 0
  mov ebx, 0
  
  .zaloop:
    
    cmp dword[esi + ebx + 16], 0
    jne @F
      
      mov edi, [blockPos]
          
      fld dword[edi]
      fstp dword[esi + ebx]
      fld dword[edi + 4]
      fstp dword[esi + ebx + 4]
      fld dword[edi + 8]
      fstp dword[esi + ebx + 8]
      
      mov dword[esi + ebx + 16], 1
        
      stdcall getObj, [ct_block_index]
  
      mov dword[esi + ebx + 40], edx
      mov dword[esi + ebx + 12], edi
      
      mov eax, [ct_block_index]
      mov dword[esi + ebx + 20], eax 
      
      mov dword[esi + ebx + 44], 0.2
      
      mov dword[esi + ebx + 24], 5
      
      jmp .finish 
      
    @@:
    
    add ebx, 48
    inc ecx
    
  cmp ecx, 64
  jle .zaloop
  
  .finish:
  
  ret
  
endp

proc renderDestroyedBlocks
  
    mov ecx, 0
    mov ebx, 0
    
    mov esi, [arrayOfDroppedBlocks]
    
    .zaloop:
        
          cmp dword[esi + ebx + 16], 1
          jne @F
        
          fld dword[esi + ebx]
          fstp [destroyedBlocksVector]
          fld dword[esi + ebx + 4]
          fstp [destroyedBlocksVector + 4]
          fld dword[esi + ebx + 8]
          fstp [destroyedBlocksVector + 8]
          
          push ebx 
          push esi
          push ecx edi
          
          mov edi, dword[esi + ebx + 12]
          
          stdcall gf_renderObj3D, dword[esi + ebx + 40], dword[edi], 0,\
                                destroyedBlocksVector, blocksTurn, dword[esi + ebx + 44], 0
          
          pop edi ecx
          pop esi
          pop ebx

          
        @@:
        
        add ebx, 48
        inc ecx
        
    cmp ecx, 64
    jle .zaloop
        

    ret
endp

proc pickBlock
    
    locals
      blockPos         dd 0, 0, 0
      playerCurPos     dd 0, 0, 0 
      destroyedBlocksVector dd 0, 0, 0
    endl
    
    fld [PlayerPos]
    fistp [playerCurPos]
    fld [PlayerPos + 8]
    fistp [playerCurPos + 8]
  
    mov ecx, 0
    mov ebx, 0
    
    mov esi, [arrayOfDroppedBlocks]
    
    .zaloop:
        
        mov edx, 0
        
        cmp dword[esi + ebx + 16], 1
        jne .dont_pick 
        
        fld dword[esi + ebx]
        fistp [destroyedBlocksVector]
        fld dword[esi + ebx + 8]
        fistp [destroyedBlocksVector + 8]
        
        mov eax, [playerCurPos]
        cmp [destroyedBlocksVector], eax
        jne @F
          inc edx
        @@:
  
        mov eax, [playerCurPos + 8]
        cmp [destroyedBlocksVector + 8], eax
        jne @F
          inc edx
        @@:
  
        cmp edx, 2
        jne .dont_pick
        
          mov dword[esi + ebx + 16], 0
          
          stdcall Inventory.AddElement, dword[esi + ebx + 20]
             
          jmp .finish
        
        .dont_pick:
        
        add ebx, 48
        inc ecx
        
    cmp ecx, 64
    jle .zaloop
    
    .finish:

    ret
endp

proc blockCollisions
  
  locals
      tempVector dd 0, 0, 0
      tempHeight dd 0.3
      dropVector dd 0.015
      
      MAX_ANGLE  dd 360
      
      CURRENT_ANGLE dd ?
      
  endl
  
  mov esi, [arrayOfDroppedBlocks] 
  
  fld [blocksTurn + 4]
  fld1
  faddp
  fstp [blocksTurn + 4]
  
  fld [blocksTurn + 4]
  fistp [CURRENT_ANGLE]
  
  mov ebx, [MAX_ANGLE]
  
  cmp [CURRENT_ANGLE], ebx
  jle @F
     fldz
     fstp [blocksTurn + 4]
  @@:

  mov ecx, 0
  mov ebx, 0

  .zaloop:
  
        cmp dword[esi + ebx + 16], 1
        jne .skip  
            
            fld dword[esi + ebx]
            fistp [tempVector]
            fld dword[esi + ebx + 4]
            fsub [tempHeight]
            fistp [tempVector + 4]
            fld dword[esi + ebx + 8]
            fistp [tempVector + 8]
           
            mov [blocks_skipFalling], 0
            
            stdcall detectCollision, [Field.Blocks], [WorldLength], [WorldWidth],\
                                      [tempVector], [tempVector + 8], [tempVector + 4] 
                                      
            cmp [blocks_skipFalling], 1
            je @F
                fld dword[esi + ebx + 4]
                fsub [dropVector]
                fstp dword[esi + ebx + 4]
                
                cmp dword[esi + ebx + 24], 1
                jne .skip
                  mov dword[esi + ebx + 28], 0
                
                jmp .skip
            @@:
            
            cmp dword[esi + ebx + 24], 1
            jne .skip 
              mov dword[esi + ebx + 28], 1
        
        .skip:
        
        add ebx, 48
        inc ecx
        
    cmp ecx, 64
    jle .zaloop
  

  ret
endp

proc thrownBlocksPhysics
  
  locals

    blockPos dd 0.0, 0.0, 0.0
    tempXOffset dd 0.025
    
    PiDegree dd 180.0
    
    a dd 0.0
    b dd 0.0
    
    currentTime dd 0
    
  endl
  
  mov ecx, 0
  mov ebx, 0
  
  mov esi, [arrayOfDroppedBlocks]
  
    .zaloop:
  
        cmp dword[esi + ebx + 16], 1
        jne .skip  
        
            cmp  dword[esi + ebx + 24], 1
            jne .skip
            
            cmp dword[esi + ebx + 28], 0
            jne .skip
                
                fld dword[esi + ebx]
                fld dword[esi + ebx + 32]
                fcos
                fld dword[esi + ebx + 36]
                fsin
                fmulp
                fmul [tempXOffset]
                fsubp
                fstp dword[esi + ebx]
                fld dword[esi + ebx + 8]
                fld dword[esi + ebx + 32]
                fcos
                fld dword[esi + ebx + 36]
                fcos
                fmulp
                fmul [tempXOffset]
                faddp
                fstp dword[esi + ebx + 8]
            
        .skip:
        
        add ebx, 48
        inc ecx
        
    cmp ecx, 64
    jle .zaloop
    
    .finish:

  ret  
endp

proc throwBlock

  locals
  
    blockPos dd 0.0, 0.0, 0.0
    tempHeight dd 0.4
    tempXOffset dd 1.0
    
    PiDegree dd 180.0
    
    a dd 0.0
    b dd 0.0
    
  endl
  
  fldpi
  fmul [PlayerTurn]
  fdiv [PiDegree]
  fstp [a]
  
  fldpi
  fmul [PlayerTurn + 4] 
  fdiv [PiDegree] 
  fstp [b]
  
  mov esi, [arrayOfDroppedBlocks]  
  
  cmp [chosenBlockFromInv], 0
  je .finish
  
  fld [PlayerPos]
  fld [a]
  fcos
  fld [b]
  fsin
  fmulp
  fmul [tempXOffset]
  fsubp
  fstp [blockPos]
  fld [PlayerPos + 4]
  fsub [tempHeight]
  fstp [blockPos + 4]
  fld [PlayerPos + 8]
  fld [a]
  fcos
  fld [b]
  fcos
  fmulp
  fmul [tempXOffset]
  faddp
  fstp [blockPos + 8]
  
  mov ebx, 0
  mov ecx, 0
   
  .zaloop:
  
        cmp dword[esi + ebx + 16], 0
        jne .skip  
        
            fld [blockPos]
            fstp dword[esi + ebx]
            fld [blockPos + 4]
            fstp dword[esi + ebx + 4]
            fld [blockPos + 8]
            fstp dword[esi + ebx + 8]
            
            mov dword[esi + ebx + 16], 1
            
            stdcall getObj, [chosenBlockFromInv]
            
            cmp [chosenBlockFromInv], 234
            jl @F
               mov dword[esi + ebx + 44], 0.1
               jmp .skipResize
            @@:
               mov dword[esi + ebx + 44], 0.2
            .skipResize:
            
            mov dword[esi + ebx + 12], edi
              
            mov dword[esi + ebx + 40], edx 
            
            mov eax, [chosenBlockFromInv]
            mov dword[esi + ebx + 20], eax 
            
            mov dword[esi + ebx + 24], 1  
            
            fld [a]
            fstp dword[esi + ebx + 32]
            fld [b]
            fstp dword[esi + ebx + 36]
          
            jmp .finish
        .skip:
        
        add ebx, 48
        inc ecx
        
    cmp ecx, 64
    jle .zaloop
  
    .finish:
  
  ret
endp


proc detectCollision uses esi edx, Field, X_SIZE, Y_SIZE, X, Y, Z
  
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
      
    mov [blocks_skipFalling], 1    
      
  .finish:

         
  ret
endp 

proc initializeDestrBlocksHeap

  ;Структура: x, y, z, текстура , место занято?, можно ломать?, Бросили?, Упал?

  invoke  GetProcessHeap
  mov     [destrHeap], eax    
  mov     ecx, 768         
  mov     eax, ecx
  shl     eax, 2     
  invoke  GlobalAlloc, GPTR, eax 
  mov [arrayOfDroppedBlocks], eax
  test eax, eax
  jz .error

  .error:
    
  ret
endp
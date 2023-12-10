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
      
      mov edi, [ct_block_index]
      dec edi
      imul edi, 4
      add edi, TextureHandles

  
      mov dword[esi + ebx + 12], edi
      
      jmp .finish 
      
    @@:
    
    add ebx, 20
    inc ecx
    
  cmp ecx, 20
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
          push ecx
          
          mov esi, dword[esi + ebx + 12]
          
          stdcall gf_renderObj3D, obj.Cube.Handle, dword[esi], 0,\
                                destroyedBlocksVector, ZERO_VEC_3, 0.2, 0
          
          pop ecx
          pop esi
          pop ebx

          
        @@:
        
        add ebx, 20
        inc ecx
        
    cmp ecx, 20
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
          jmp .finish
        
        .dont_pick:
        
        add ebx, 20
        inc ecx
        
    cmp ecx, 20
    jle .zaloop
    
    .finish:

    ret
endp

proc initializeDestrBlocksHeap

  invoke  GetProcessHeap
  mov     [destrHeap], eax    
  mov     ecx, 100         
  mov     eax, ecx
  shl     eax, 2     
  invoke  GlobalAlloc, GPTR, eax 
  mov [arrayOfDroppedBlocks], eax
  test eax, eax
  jz .error

  .error:
    
  ret
endp
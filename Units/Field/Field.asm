;               
;              proc Field.Initialize
proc Field.Initialize uses eax edi ecx, _hHeap, Length, Width, Height 
    mov    edi, [_hHeap]
    mov    [Field.hHeap], edi
         
    mov    edi, [Length]
    mov    [Field.Length], edi
    xchg   eax, edi 
    
    mov    edi, [Width]
    mov    [Field.Width], edi
    mul    edi
    
    mov    edi, [Height]
    mov    [Field.Height], edi
    mul    edi
    
    invoke HeapAlloc, [Field.hHeap], HEAP_ZERO_MEMORY, eax
    mov   [Field.Blocks], eax

;   alloc memory for Field.Seed    
    mov    eax, [Field.Length]
    mov    edi, [Field.Width]
    mul    edi
    
    mov    edi, 4
    mul    edi 
    
    invoke HeapAlloc, [Field.hHeap], HEAP_ZERO_MEMORY, eax
    mov    [Field.Seed], eax
    
    stdcall Field.GenerateSeed
          

    mov al, 1
    mov edi, [Field.Blocks]
    mov ecx, 1
    rep stosb
    
.Iterate_Z:

.Iterate_Y:

.Iterate_X:
    
    stdcall Field.SetBlockIndex, 12, 12, 5, Blocks.STONE
    stdcall Field.SetBlockIndex, 13, 12, 5, Blocks.STONE 
    stdcall Field.SetBlockIndex, 14, 12, 5, Blocks.STONE
    stdcall Field.SetBlockIndex, 13, 12, 6, Blocks.STONE
    stdcall Field.SetBlockIndex, 13, 12, 7, Blocks.STONE
    
    stdcall Field.SetBlockIndex, 12, 12, 12, Blocks.STONE
    stdcall Field.SetBlockIndex, 13, 12, 12, Blocks.STONE 
    stdcall Field.SetBlockIndex, 14, 12, 12, Blocks.STONE
    stdcall Field.SetBlockIndex, 13, 12, 13, Blocks.STONE
    stdcall Field.SetBlockIndex, 13, 12, 14, Blocks.STONE
    
    stdcall Field.SetBlockIndex, 10, 10, 2, Blocks.STONE
    stdcall Field.SetBlockIndex, 11, 10, 2, Blocks.STONE 
    stdcall Field.SetBlockIndex, 12, 10, 2, Blocks.STONE
    stdcall Field.SetBlockIndex, 11, 10, 3, Blocks.STONE
    stdcall Field.SetBlockIndex, 11, 10, 4, Blocks.STONE    

.Finish:
    ret
endp

proc Field.GenerateSeed uses edi ecx eax
    mov    eax, [Field.Length]
    mov    edi, [Field.Width]
    mul    edi
    xchg   eax, ecx
    
    mov    edi, [Field.Seed]
    
.Iterate:
    stdcall Random.GetFloat32
    mov     [edi], eax
    add     edi, 4
    loop   .Iterate
    
    ret
endp

;              func Field.GetBlockIndex
;    Input:  dWord X, dWord Y, dWord Z
;    Output: eax <- BlockIndex or ErrorCode
;
proc Field.GetBlockIndex uses edi, X: word, Y: word, Z: word  
     xor    eax, eax

     mov    eax, dword[Y]  
      
     mov    edi, [Field.Length]
     mul    edi
     
     mov    edi, dword[X]
     add    eax, edi
     
     xchg   eax, edi
     
     mov    esi, dword[Z]
     mov    eax, [Field.Length]
     mov    ecx, [Field.Width]
     mul    ecx
     mul    esi
     
     add    eax, edi

     add    eax, [Field.Blocks]
     
     xchg   eax, edi
     movzx  eax, byte[edi]
     jmp    .Finish

.Finish:
     ret
endp

;              func Field.SetBlockIndex
;    Input:  Word X, Word Y, Word Z, byte BlockIndex
;    Output: eax <- BlockIndex or ErrorCode
;
proc Field.SetBlockIndex uses edi eax esi ecx, X: dword, Y: dword, Z: dword, BlockIndex: byte     
     xor    eax, eax

     mov    eax, dword[Y]  
      
     mov    edi, [Field.Length]
     mul    edi
     
     mov    edi, dword[X]
     add    eax, edi
     
     xchg   eax, edi
     
     mov    esi, dword[Z]
     mov    eax, [Field.Length]
     mov    ecx, [Field.Width]
     mul    ecx
     mul    esi
     
     add    eax, edi

     add    eax, [Field.Blocks]
     
     xchg   eax, edi
     movzx  eax, byte[BlockIndex]
     mov    byte[edi], al

     jmp    .Finish
.Finish:
     ret
endp

;              func Field.TestBounds
;    Input:  Word X, Word Y, Word Z
;    Output: eax <- Zero or ErrorCode
;
proc Field.TestBounds uses ebx, X: dword, Y: dword, Z: dword
     xor    eax, eax

     cmp    word[X], Field.LENGTH
     jge    .Error

     cmp    word[Y], Field.WIDTH
     jge    .Error

     cmp    word[Z], Field.HEIGHT
     jge    .Error

     cmp    word[X], 0
     jl     .Error 
     cmp    word[Y], 0
     jl     .Error
     cmp    word[Z], 0
     jl     .Error
     jmp    .Finish

.Error:    
     mov    eax, ERROR_OUT_OF_BOUND    
.Finish:   
     ret
endp
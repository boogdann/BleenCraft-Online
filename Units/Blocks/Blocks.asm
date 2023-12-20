proc Blocks.SetStartTime, Time
     mov eax, [Time]
     mov dword[Blocks.START_DESTROY_TIME], eax
.Finish:
     ret
endp

proc Blocks.GetDestroyTime uses edi ecx ebx, IndexBlock, IndexTool
    locals
        indexDestr        dd ?
        multiplyDestr     dd ?
        multiplyPriorTool dd ?
        time              dd ?
    endl
            
    stdcall Blocks.IndexDestr, [IndexBlock], [IndexTool]
    mov     [indexDestr], eax
    
    stdcall Blocks.MultDestr, [IndexBlock]
    mov     [multiplyDestr], eax
        
    xor     edx, edx
    mov     eax, [Blocks.START_DESTROY_TIME]
    mul     dword[multiplyDestr]
    mov     [time], eax
    
    stdcall Blocks.GetIndexTool, [IndexTool]
    xchg    ebx, eax
    
    cmp     eax, 0
    jz      .SkipDiv
    
    stdcall Blocks.PriorTool, [IndexBlock]
    
    cmp     eax, ebx
    jnz     .SkipDiv
    
    stdcall Blocks.GetMaterialTool, [IndexTool]
    xchg    ebx, eax
    add     ebx, 1
    
    mov     eax, [time]
    xor     edx, edx
    div     ebx
    xor     edx, edx
    
    mov     edx, [indexDestr]
    jmp     .Finish
.SkipDiv: 
     mov     eax, [time]
     mov     edx, [indexDestr]
.Finish:
    ret
endp

proc Blocks.IndexDestr uses edi edx ecx, IndexBlock, IndexTool
     locals
         idxMaterialTool dd ?
         NUM_5           dd 5
     endl
     
    ; mov    eax, Blocks.IS_DESTRUCTIBLE
    ; mov    edi, Blocks.IndexDestruction
    ; add    edi, [IndexBlock]
    ; movzx  ebx, byte[edi] 
    ; cmp    ebx, 0
    ; jz     .Finish
          
     cmp    [IndexTool], Tools.MinValueTool
     jl     .SetZeroMaterial
     
     stdcall Blocks.PriorTool, [IndexBlock]
     xchg    eax, ebx
     
     cmp     ebx, 0
     jz      @F
     stdcall Blocks.GetIndexTool, [IndexTool]
     xchg    eax, ecx
     
     cmp     ecx, ebx
     jnz     .SetZeroMaterial
@@:
          
     stdcall Blocks.GetMaterialTool, [IndexTool]
     mov     [idxMaterialTool], eax
                                                    
.SetZeroMaterial:
     mov    [idxMaterialTool], Blocks.MaterialEmpty

.GetIdx: 
     mov    edi, Blocks.IndexDestruction
     add    edi, [IndexBlock]
     movzx  ebx, byte[edi] 
     

.Finish:
     mov    eax, Blocks.IS_NOT_DESTRUCTIBLE
     cmp    ebx, dword[idxMaterialTool]
 ;    jl     @F
     ja     @F
     mov    eax, Blocks.IS_DESTRUCTIBLE 
@@:           
     ret
endp

proc Blocks.MultDestr uses edi, IndexTool
     mov    edi, Blocks.MultiplyDestruction
     add    edi, [IndexTool]
     movzx  eax, byte[edi]
      
.Finish:
    ret
endp

; not now
proc Blocks.PriorTool uses edi, IndexBlock 
     mov    edi, Blocks.PriorirityTool
     add    edi, [IndexBlock]
     movzx  eax, byte[edi] 
     
.Finish:
     ret
endp

proc Blocks.GetIndexTool uses edi ebx, IndexTool
     xor    eax, eax
     
     mov    ebx, [IndexTool]
     cmp    ebx, Tools.MinValueTool
     jl     .Finish
     
     mov    eax, 1
     cmp    ebx, Tools.DiamondPickaxe
     jle    .Finish
     
     mov    eax, 2
     cmp    ebx, Tools.DiamondAxe
     jle    .Finish     

     mov    eax, 3
     cmp    ebx, Tools.DiamondShowel
     jle    .Finish   

.Finish:
     ret
endp

proc Blocks.GetMaterialTool uses edx, IndexTool
     locals
         idxMaterialTool dd ?
         NUM_5           dd 5
     endl
         
     xor    edx, edx
     mov    eax, [IndexTool]
     div    dword[NUM_5]
     
     cmp    edx, 0
     jnz    .Skip1
     mov    [idxMaterialTool], Blocks.MaterialWood
     jmp    .Finish
          
.Skip1:
     cmp    edx, 1
     jnz    .Skip2
     mov    [idxMaterialTool], Blocks.MaterialStone
     jmp    .Finish     
.Skip2:
     cmp    edx, 2
     jnz    .Skip3
     mov    [idxMaterialTool], Blocks.MaterialIron
     jmp    .Finish     
.Skip3:
     cmp    edx, 3
     jnz    .Skip4
     mov    [idxMaterialTool], Blocks.MaterialGold
     jmp    .Finish     
.Skip4:
     cmp    edx, 4
     jnz    .Skip5
     mov    [idxMaterialTool], Blocks.MaterialDiamond
     jmp    .Finish     
.Skip5:
.Finish:
     mov    eax, [idxMaterialTool]
     ret
endp
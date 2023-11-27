proc Blocks.SetStartTime, Time
     mov eax, [Time]
     mov dword[Blocks.START_DESTROY_TIME]
.Finish:
     ret
endp

proc Blocks.GetDestroyTime uses edi ecx, IndexBlock, IndexTool
    locals
        indexDestr        dd ?
        multiplyDestr     dd ?
        multiplyPriorTool dd ?
    endl
    
    stdcall Blocks.IndexDestr, [IndexBlock], [IndexTool]
    mov     [indexDestr], eax
    
    stdcall Blocks.MultDestr, [IndexBlock]
    mov     [multiplyDestr], eax
    
    stdcall Blocks.PriorTool, [IndexBlock]
    mov     [multiplyPriorTool], eax
    
    xor     edx, edx
    mov     eax, [Blocks.START_DESTROY_TIME]
    mul     dword[multiplyDestr]
    
    cmp     dword[multiplyPriorTool], 0
    jz      .SkipDiv
    div     dword[multiplyPriorTool]
.SkipDiv: 
    
    cmp     dword[indexDestr], 0
    jnle    .SkipSet
    mov     edx, Blocks.IS_DESTRUCTIBLE
    jmp     .SkipNotSet    
.SkipSet:
    mov     edx, Blocks.IS_NOT_DESTRUCTIBLE
.SkipNotSet:
  
.Finish:
    ret
endp

proc Blocks.IndexDestr uses edi edx, IndexBlock, IndexTool
     locals
         idxMaterialTool dd ?
         NUM_5           dd 5
     endl
     
     cmp    [IndexTool], Tools.MinValueTool
     jl     .SetZeroMaterial
     
     xor    edx, edx
     mov    eax, [IndexTool]
     div    dword[NUM_5]
     
     cmp    edx, 0
     jnz    .Skip1
     mov    [idxMaterialTool], Blocks.MaterialWood
          
.Skip1:
     cmp    edx, 1
     jnz    .Skip2
     mov    [idxMaterialTool], Blocks.MaterialStone
          
.Skip2:
     cmp    edx, 2
     jnz    .Skip3
     mov    [idxMaterialTool], Blocks.MaterialIron
          
.Skip3:
     cmp    edx, 3
     jnz    .Skip4
     mov    [idxMaterialTool], Blocks.MaterialGold
          
.Skip4:
     cmp    edx, 4
     jnz    .Skip5
     mov    [idxMaterialTool], Blocks.MaterialDiamond
          
.Skip5:
     
.SetZeroMaterial:
     mov    [idxMaterialTool], Blocks.MaterialEmpty
      
     mov    edi, Blocks.IndexDestruction
     add    edi, [IndexBlock]
     movzx  eax, byte[edi] 

.Finish:
     sub    eax, dword[idxMaterialTool]
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
proc Blocks.PriorTool uses edi, IndexTool 
     mov    edi, Blocks.PriorirityTool
     add    edi, [IndexTool]
     movzx  eax, byte[edi] 
     
.Finish:
     mov    eax, 0
     ret
endp
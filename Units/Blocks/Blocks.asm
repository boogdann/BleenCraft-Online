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
    
;    stdcall Blocks.PriorTool, [IndexBlock]
;    mov     [multiplyPriorTool], eax
    
    xor     edx, edx
    mov     eax, [Blocks.START_DESTROY_TIME]
    mul     dword[multiplyDestr]
    
;    cmp     dword[multiplyPriorTool], 0
;    jz      .SkipDiv
;    div     dword[multiplyPriorTool]
.SkipDiv: 
    
     mov     edx, [indexDestr]
.Finish:


    ret
endp

proc Blocks.IndexDestr uses edi edx ecx, IndexBlock, IndexTool
     locals
         idxMaterialTool dd ?
         NUM_5           dd 5
     endl
          
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
          
     xor    edx, edx
     mov    eax, [IndexTool]
     div    dword[NUM_5]
     
     cmp    edx, 0
     jnz    .Skip1
     mov    [idxMaterialTool], Blocks.MaterialWood
     jmp    .GetIdx
          
.Skip1:
     cmp    edx, 1
     jnz    .Skip2
     mov    [idxMaterialTool], Blocks.MaterialStone
     jmp    .GetIdx     
.Skip2:
     cmp    edx, 2
     jnz    .Skip3
     mov    [idxMaterialTool], Blocks.MaterialIron
     jmp    .GetIdx     
.Skip3:
     cmp    edx, 3
     jnz    .Skip4
     mov    [idxMaterialTool], Blocks.MaterialGold
     jmp    .GetIdx     
.Skip4:
     cmp    edx, 4
     jnz    .Skip5
     mov    [idxMaterialTool], Blocks.MaterialDiamond
     jmp    .GetIdx     
.Skip5:
                                                    
.SetZeroMaterial:
     mov    [idxMaterialTool], Blocks.MaterialEmpty

.GetIdx: 
     mov    edi, Blocks.IndexDestruction
     add    edi, [IndexBlock]
     movzx  ebx, byte[edi] 
     

.Finish:
     mov    eax, Blocks.IS_NOT_DESTRUCTIBLE
     cmp    ebx, dword[idxMaterialTool]
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
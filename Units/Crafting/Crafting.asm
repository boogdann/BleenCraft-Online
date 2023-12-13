proc Crafting.Initialize uses edi ecx ebx, pSmall, pBig
     invoke GetProcessHeap
     xchg   eax, ebx
     invoke HeapAlloc, ebx, HEAP_ZERO_MEMORY, Crafting.SMALL_SIZE * Crafting.SIZE_CELL  
     mov    edi, [pSmall]
     mov    dword[edi], eax
     
     invoke HeapAlloc, ebx, HEAP_ZERO_MEMORY, Crafting.SMALL_SIZE * Crafting.SIZE_CELL  
     mov    edi, [pBig]
     mov    dword[edi], eax     
     
.Finish:
     ret
endp

proc Crafting.Craft uses edi ecx esi ebx, pCrafting, Size
     mov    eax, [pCrafting]
     mov    dword[eax], 0
      
     mov    ecx, 0
     dec    dword[Size]
     mov    edi, Crafts
.CheckCrafts:
     xor    edx, edx
     mov    eax, Crafting.SIZE_CELL * Crafting.SIZE_CRAFT
     mul    ecx
     mov    edi, Crafts
     add    edi, eax
     mov    ebx, edi
     
     add    edi, 4
     
     push   ecx
     
     xor    edx, edx
     mov    eax, 4
     mul    dword[Size]
     mov    ecx, eax
     mov    esi, [pCrafting]
     add    esi, 4
     
     repe   cmpsb
     
     mov    eax, ecx
     pop    ecx
     
     cmp    eax, 0
     jnz    .Continue
     
     mov    ax, word[ebx]
     mov    edi, [pCrafting]
     mov    [edi], ax
     
     mov    ax, word[ebx+2]
     mov    [edi+2], ax
     
     ;stdcall Crafting.DecCraft, [pCrafting], [Size]
     
     jmp    .Finish
.Continue:
     inc    ecx
     cmp    ecx, Crafting.NUM_CRAFTS
     jl .CheckCrafts

.Finish:
     ret
endp


proc Crafting.DecCraft uses edi eax ecx, pCrafting, Size
     mov    edi, [pCrafting]
     mov    ecx, [Size]
     add    edi, ecx
.Clear:
     cmp    word[edi+2], 0
     jle    .Continue
     cmp    word[edi+2], 1
     jnz    @F
     mov    dword[edi], 0
@@:     
     dec    word[edi+2]
     
.Continue:
     sub    edi, 4
     loop   .Clear
     
.Finish:
     ret
endp
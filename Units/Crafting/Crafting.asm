proc Crafting.Initialize uses edi ecx ebx, pSmall, pBig
     invoke GetProcessHeap
     xchg   eax, ebx
     invoke HeapAlloc, ebx, HEAP_ZERO_MEMORY, Crafting.SMALL_SIZE * Crafting.SIZE_CELL  
     mov    edi, [pSmall]
     mov    dword[edi], eax
     
     invoke HeapAlloc, ebx, HEAP_ZERO_MEMORY, Crafting.BIG_SIZE * Crafting.SIZE_CELL  
     mov    edi, [pBig]
     mov    dword[edi], eax     
     
.Finish:
     ret
endp

proc Crafting.Craft uses edi ecx esi ebx, pCrafting, Size
     locals
       prevSize dd ?
     endl
     
     cmp    dword[Size], 5
     jnz    @F
     stdcall Crafting.CraftFull, [pCrafting], [Size], Crafts2x2, Crafting.SIZE_CELL * Crafting.SIZE_SMALL_CRAFT, Crafting.NUM_CRAFTS2x2
@@:
    cmp     dword[Size], 10
    jnz     @F
    stdcall Crafting.CraftFull, [pCrafting], [Size], Crafts3x3, Crafting.SIZE_CELL * Crafting.SIZE_BIG_CRAFT, Crafting.NUM_CRAFTS3x3
@@:
    mov     eax, -1
     
.Finish:
     ret
endp

proc Crafting.CraftFull uses edi ecx esi ebx, pCrafting, Size, StartCrafts, SizeLine, NumCrafts
     locals
         prevSize dd ?
     endl
     
     mov    eax, [Size]
     mov    [prevSize], eax
     
     mov    eax, [pCrafting]
     mov    dword[eax], 0
      
     mov    ecx, 0
     dec    dword[Size]
     mov    edi, [StartCrafts]
.CheckCrafts:
     xor    edx, edx
     mov    eax, [SizeLine]
     mul    ecx
     mov    edi, [StartCrafts]
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
     
     jmp    .Finish
.Continue:
     inc    ecx
     cmp    ecx, [NumCrafts]
     jl .CheckCrafts
.Finish:
     ret
endp 
                                                       
; input - pointer to craft array
; size  - size of array
;
proc Crafting.DecCraft uses edx edx eax ecx, pCrafting, Size
     mov    edi, [pCrafting]
     mov    dword[edi], 0
     
     add    edi, 4
     mov    eax, [Size]
     mov    ecx, 2
     xor    edx, edx
     mul    eax
     
     xchg   eax, ecx     
     
     mov    ax, 0
     rep    stosw
.Finish:
     ret
endp
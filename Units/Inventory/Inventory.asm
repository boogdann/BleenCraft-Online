proc Inventory.Initialize uses ecx ebx edi, pInv, pSize
     locals
       invAddr dd ?  
     endl
     
     invoke GetProcessHeap
     mov    ebx, eax
     
     mov    edi, [pSize]
     mov    eax, [Inventory.Size]
     mov    dword[edi], eax
     
     invoke HeapAlloc, ebx, HEAP_ZERO_MEMORY, [Inventory.Size]
     mov    [invAddr], eax
     
     mov    edi, [invAddr]
     mov    dword[edi], 12345
     
     mov    edi, [pInv]
     mov    eax, [invAddr]
     mov    dword[edi], eax  
     
.Finish:
     mov    eax, [pInv]
     ret
endp
;  blockIdx | numBlocks
;
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
     
     
     mov    edi, [pInv]
     mov    eax, [invAddr]
     mov    dword[edi], eax 
     mov    [Inventory.Inventory], eax 
     
.Finish:
     mov    eax, [pInv]
     ret
endp

; Input - index in inventory
; Return  eax = (-1) - error
;         eax - block index
;         edx - quantity of this block
;
proc Inventory.GetCell uses edi, idx 
     cmp    [idx], 9*4
     jnl    .Error

     xor    edx, edx
     mov    eax, 4
     mul    dword[idx]
     
     mov    edi, [Inventory.Inventory]
     add    edi, eax
     movzx  eax, word[edi]
     movzx  edx, word[edi+2]   
     jmp    .Finish
     
.Error:
     mov    eax, -1
.Finish:
     ret
endp 

; Input - index in inventory
;         block index
;         quantity of this block
; Return  (-1) - error
;
proc Inventory.SetCell uses edi, idxInv, idxBlock, num 
     cmp    [idxInv], 9*4
     jnl    .Error

     xor    edx, edx
     mov    eax, 4
     mul    dword[idxInv]
     
     mov    edi, [Inventory.Inventory]
     add    edi, eax
     mov    edx, [idxBlock]
     mov    word[edi], dx
     mov    edx, [num] 
     mov    word[edi+2], dx   
     jmp    .Finish
     
.Error:
     mov    eax, -1
.Finish:
     ret
endp     

; Input - index in inventory
; Return  (-1) - error
;
proc Inventory.IncCell uses edi, idxInv 
     cmp    [idxInv], 9*4
     jnl    .ErrorInvalidIdx

     xor    edx, edx
     mov    eax, 4
     mul    dword[idxInv]
     
     mov    edi, [Inventory.Inventory]
     add    edi, eax

     mov    dx, word[edi+2]
     cmp    dx, 64
     jae    .Error

     inc    word[edi+2]  
     jmp    .Finish
.Error:

.ErrorInvalidIdx:
     mov    eax, -1
.Finish:
     ret
endp  

; Input - index in inventory
; Return  (-1) - error
;
proc Inventory.DecCell uses edi, idxInv 
     cmp    [idxInv], 9*4
     jnl    .ErrorInvalidIdx

     xor    edx, edx
     mov    eax, 4
     mul    dword[idxInv]
     
     mov    edi, [Inventory.Inventory]
     add    edi, eax

     mov    dx, word[edi+2]
     cmp    dx, 0
     jle    .Error

     dec    word[edi+2] 
     
     cmp    word[edi+2], 0
     jnz    @F
     mov    word[edi], 0
@@: 
     jmp    .Finish
.Error:
     mov    word[edi], 0 
.ErrorInvalidIdx:
     mov    eax, -1
.Finish:
     ret
endp  

;    Input  - block index
;    Output - (-1) - error
;
proc Inventory.AddElement uses edi ecx, idxElem
     mov    edi, [Inventory.Inventory]
     add    edi, [Inventory.Size]

     mov    eax, [idxElem]
     mov    ecx, Inventory.NUM_CELL
.IterateInv:
     cmp    word[edi], ax
     jnz    .Continue
     
     cmp    word[edi+2], 64
     jae    .Continue 
     
     inc    word[edi+2]
     jmp    .Finish    
.Continue:
     sub    edi, 4
     loop   .IterateInv
     
     mov    edi, [Inventory.Inventory]
     add    edi, [Inventory.Size]     
     mov    eax, [idxElem]
     mov    ecx, Inventory.NUM_CELL
.IterateInv2:
     mov    ecx, Inventory.NUM_CELL
     cmp    word[edi], Block.Air
     jnz    .Continue2
     
     mov    word[edi], ax
     mov    word[edi+2], 1    
     
     jmp    .Finish    
.Continue2:
     sub    edi, 4
     loop   .IterateInv2
          
     mov    eax, -1
.Finish:
     ret
endp

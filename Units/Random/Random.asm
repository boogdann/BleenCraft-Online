proc Random.Initialize uses eax edx
    
     invoke GetTickCount   
     mov        [Random.wPrevNumber], eax
     
;     invoke HeapAlloc, [hHeap], HEAP_ZERO_MEMORY, eax
;     mov   [MT], eax
;    
;     mov esi, [MT]
;     mov ecx, [N]
;     mov eax, [Random.wPrevNumber]
;     mov [esi], eax
;     add esi, 4
;     dec ecx
;.LoopInit:
;     mov edx, [esi-4]
;     shr edx, 30
;     xor edx, [esi-4]
;     imul edx, 0x6c078965
;     add edx, ecx
;     and edx, 0x0ffffffff
;     mov [esi], edx
;     add esi, 4
;     dec ecx
;     jnz .LoopInit 
     
.Finish:
     ret
endp

proc Random.InitializeWith uses eax, val
     mov    eax, [val]
     mov    [Random.wPrevNumber], eax
     ret
endp

;proc Random.GetInt uses ecx edx,\
;     Min, Max
;
;     xor        eax, eax
;     mov        eax, [Random.wPrevNumber]
;     rol        eax, 7
;     adc        eax, 21
;     mov        [Random.wPrevNumber], eax
;
;     mov        ecx, [Max]
;     sub        ecx, [Min]
;     inc        ecx
;     xor        edx, edx
;     div        ecx
;     add        edx, [Min]
;     xchg       eax, edx
;     
;Finish:
;     ret                
;endp

proc Random.GetInt uses ecx edx, Min, Max 
     xor eax, eax    
     mov ecx, [Random.wPrevNumber]
     shr ecx, 11
     xor eax, ecx
     mov ecx, eax
     shl ecx, 7
     and ecx, 0x9D2C5680
     xor eax, ecx
     mov ecx, eax
     shl ecx, 15
     and ecx, 0xEFC60000
     xor eax, ecx
     mov ecx, eax
     shr ecx, 18
     xor eax, ecx
     
     mov        [Random.wPrevNumber], eax         
     mov        ecx, [Max]
     sub        ecx, [Min]
     inc        ecx
     xor        edx, edx
     div        ecx
     add        edx, [Min]
     xchg       eax, edx

.Finish:
     ret
endp

;proc Random.Twist
;    mov esi, [MT]
;    xor ebx, ebx
;.twist:
;        mov eax, [esi]
;        mov edx, [esi+4]
;        xor eax, [A]
;        add eax, edx
;        mov [esi], eax
;        add esi, 4
;        inc ebx
;        cmp ebx, [N]
;        jne .twist
;.Finish:
;     ret
;endp
;
;proc Random.Tempering 
;     mov ecx, eax
;     shr ecx, 11
;     xor eax, ecx
;     mov ecx, eax
;     shl ecx, 7
;     and ecx, 0x9D2C5680
;     xor eax, ecx
;     mov ecx, eax
;     shl ecx, 15
;     and ecx, 0xEFC60000
;     xor eax, ecx
;     mov ecx, eax
;     shr ecx, 18
;     xor eax, ecx
;.Finish:
;     ret
;endp

proc Random.GetFloat32 uses edx  
    
    stdcall Random.GetInt, 0, 100    
    mov         [Tmp], eax
    fild        dword[Tmp]
    xchg        eax, edx
    
    stdcall Random.GetInt, 0, 100
    mov         [Tmp], eax
    fild        dword[Tmp]
    
    cmp         eax, edx
    ja          .EdxDivEax
    fdivrp        
    jmp         .Finish
    
.EdxDivEax:
    fdivp       

.Finish:
    fstp        dword[Tmp]
    mov         eax, [Tmp]
    ret
endp



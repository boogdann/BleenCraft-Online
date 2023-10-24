proc Random.Initialize uses eax edx
    
     invoke GetTickCount   
     mov    [Random.wPrevNumber], eax
     mov    [Random.ToInc], 0     
.Finish:
     ret
endp

proc Random.InitializeWith uses eax, val
     mov    eax, [val]
     mov    [Random.wPrevNumber], eax
     ret
endp

proc Random.GetInt uses ecx edx, Min, Max 
     cmp [Random.wPrevNumber], 0
     jnz .Skip
     stdcall GetTickCount
     add eax, [Random.ToInc]
     mov [Random.wPrevNumber], eax
     
.Skip:
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



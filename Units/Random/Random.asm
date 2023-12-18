proc Random.Initialize uses eax edx
    
     invoke GetTickCount   
     mov    [Random.wPrevNumber], eax
     mov    [Random.ToInc], 13
     
     mov    dword[Random.NumRandom], 0
     mov    dword[Random.MaxNumRandom], 1000     
.Finish:
     ret
endp

proc Random.InitializeWith uses eax, val
     mov    eax, [val]
     mov    [Random.wPrevNumber], eax
     ret
endp

proc Random.GetInt uses ecx edx edi esi ebp esp ebx, Min, Max 
     mov ecx, [Random.NumRandom]
     cmp [Random.MaxNumRandom], ecx
     jl  .ResetNumber

     cmp [Random.wPrevNumber], 0
     jnz .Skip
     
.ResetNumber:
     invoke GetTickCount
     inc dword[Random.ToInc]
     add eax, [Random.ToInc]
     mov [Random.wPrevNumber], eax
     mov dword[Random.NumRandom], 0
     
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
     inc dword[Random.NumRandom]
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



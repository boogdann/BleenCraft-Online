proc Random.Initialize uses eax edx
    locals
      Time SYSTEMTIME ?, ?, ?, ?, ?, ?, ?, ?
    endl
    
     invoke GetTickCount
     mov        [Random.wPrevNumber], eax
     ret
endp

proc Random.GetInt uses ecx edx,\
     Min, Max

     xor        eax, eax
     mov        eax, [Random.wPrevNumber]
     rol        eax, 7
     adc        eax, 23
     mov        [Random.wPrevNumber], eax

     mov        ecx, [Max]
     sub        ecx, [Min]
     inc        ecx
     xor        edx, edx
     div        ecx
     add        edx, [Min]
     xchg       eax, edx
     
Finish:
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



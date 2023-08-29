BASE_VALUE   =  -1

proc DiamondSquare.Initialize uses eax ecx, _terrPower, _fOutsideHeight, _fRoughness, \
        _isToSecondPower, _fBaseHeight

    mov    cl, byte[_terrPower]
    mov    eax, 1
    shl    eax, cl
    mov    [max], eax
    inc    eax
    mov    [size], eax
    
    mov    eax, [_fRoughness]
    mov    [fRoughness], eax 

    mov    eax, [_isToSecondPower]
    mov    [isToSecondPower], eax 
    
    mov    eax, [_fBaseHeight]
    mov    [fBaseHeight], eax 
       
.Finish:
    ret
endp  

proc DiamondSquare.Generate uses ecx edi edx ebx, resAddr
    locals
        NewResAddr dd    ?
        x          dd    ?
        y          dd    ?
        toPushFloat dd ?
    endl
    
    xor    edx, edx
    mov    eax, [size]
    mul    dword[size]
    mov    ebx, 4
    xchg   ecx, eax
    mov    eax, BASE_VALUE
    mov    edi, [resAddr]
    rep    stosd  

;   add random to angles
    xor    edx, edx
    
    mov    ecx, [max]
    shl    ecx, 1

;   map[0, 0]
    mov    edi, [resAddr]
    stdcall Random.GetFloat32
    mov    [toPushFloat], eax
    fld    [toPushFloat]
    mov    [toPushFloat], ecx
    fild    [toPushFloat]
    fmulp
    fstp   dword[edi]    

    
;   map[0, max]
    mov    edi, [resAddr]
    mov    eax, [max]
    mov    ebx, 4
    mul    ebx
    add    edi, eax
    stdcall Random.GetFloat32
    mov    [toPushFloat], eax
    fld    [toPushFloat]
    mov    [toPushFloat], ecx
    fild   [toPushFloat]
    fmulp
    fstp   dword[edi]  
    
;   map[max, max]
    mov    edi, [resAddr]
    mov    eax, [max]
    mul    dword[size]
    add    eax, [max]
    mul    ebx
    add    edi, eax
    stdcall Random.GetFloat32
    mov    [toPushFloat], eax
    fld    [toPushFloat]
    mov    [toPushFloat], ecx
    fild   [toPushFloat]
    fmulp
    fstp   dword[edi]  

;   map[max, 0]
    mov    edi, [resAddr]
    mov    eax, [max]
    mul    dword[size]
    mul    ebx
    add    edi, eax
    stdcall Random.GetFloat32
    mov    [toPushFloat], eax
    fld    [toPushFloat]
    mov    [toPushFloat], ecx
    fild   [toPushFloat]
    fmulp
    fstp   dword[edi]  
        
    mov    dword[x], 0
.Iterate_x:
    mov    edi, [resAddr]
    mov    eax, [size]
    mul    ebx
    mul    dword[x]
    add    edi, eax
    
    mov    dword[y], 0
.Iterate_Y:
    stdcall DiamondSquare.GetHeight, [resAddr], [x], [y]
    mov    [edi], eax       
    add    edi, 4
    
    inc    dword[y]
    mov    eax, [y]
    cmp    eax, [size]
    jl     .Iterate_Y 
    
    inc    dword[x]
    mov    eax, [x]
    cmp    eax, [size]
    jl     .Iterate_x


    mov    ebx, [fRoughness]
    cmp    ebx, FALSE
    jz     .Skip
    stdcall DiamondSquare.RaiseTosecondPower, [resAddr], 0, 0, [size] 
    
.Skip:
    ; stdcall DiamondSquare.PostProcess, [NewResAddr] 
    ; mov    [NewResAddr], eax

    stdcall DiamondSquare.Normalize, [resAddr]
    stdcall DiamondSquare.Multiply, [resAddr], 100, 50
    ;mov    eax, [NewResAddr]
.Finish:
    ret
endp

proc DiamondSquare.GetHeight uses edi ecx ebx edx, resAddr, x, y
     mov    eax, [x]
     cmp    eax, 0
     jl     .FirstIf
     cmp    eax, [max]
     ja     .FirstIf
     
     mov    eax, [y]
     cmp    eax, 0
     jl     .FirstIf
     cmp    eax, [max]
     ja     .FirstIf    
     jmp    .SkipFirstIf
     
.FirstIf:    
     mov    eax, [fOutsideHeight]
     jmp    .Finish
     
.SkipFirstIf:
     xor    edx, edx
     mov    edi, [resAddr]
     mov    eax, [x]
     mul    dword[size]
     add    eax, [y]
     mov    ebx, 4
     mul    ebx
     add    edi, eax

     cmp    dword[edi], BASE_VALUE
     jne    .SecondIf
     jmp    .SkipSecondIf

.SecondIf:
     mov    eax, [edi]
     jmp    .Finish

.SkipSecondIf:
     mov    ecx, 1   ; ecx - baseSize
     
     
     mov    eax, [x]
     mov    ebx, [y]
.mWhile:
     push   eax
     and    eax, ecx
     pop    eax
     jnz    .SkipmWhile
     push   ebx
     and    ebx, ecx
     pop    ebx
     jnz    .SkipmWhile
     
     shl    ecx, 1
     jmp    .mWhile
     
.SkipmWhile:
     and    eax, ecx 
     jz     .SkipThirdIf
     and    ebx, ecx
     jnz    .ThirdIf
          
.ThirdIf: 
     mov    edi, [resAddr]
     mov    eax, [x]
     mul    dword[size]
     add    eax, [y]
     mov    ebx, 4
     mul    ebx
     add    edi, eax
     
     mov    ebx, ecx
     shl    ebx, 1
         
     stdcall DiamondSquare.CountOneSquare, [resAddr], [x], [y], ebx
     mov     [edi], eax
     jmp    .Finish 
     
.SkipThirdIf: 
     mov    edi, [resAddr]
     mov    eax, [x]
     mul    dword[size]
     add    eax, [y]
     mov    ebx, 4
     mul    ebx
     add    edi, eax
     
     mov    ebx, ecx
     shl    ebx, 1
        
     stdcall DiamondSquare.CountOneDiamond, [resAddr], [x], [y], ebx 
     mov     [edi], eax
.Finish:
     ret
endp

proc DiamondSquare.CountOneSquare uses ebx ecx edi esi ebx, resAddr, x, y, currMax
    locals
        sum           dd    ?
        toPushFloat   dd    ?
        diff          dd    ?
        rnd           dd    ?
    endl
    
    mov    eax, [currMax]
    shr    eax, 1
    mov    ecx, eax
    
    mov    eax, [x]
    sub    eax, ecx
    mov    ebx, [y]
    sub    ebx, ecx 
    stdcall DiamondSquare.GetHeight, [resAddr], eax, ebx
    mov    [sum], eax
      
         
    mov    eax, [x]
    add    eax, ecx
    mov    ebx, [y]
    sub    ebx, ecx
    stdcall DiamondSquare.GetHeight, [resAddr], eax, ebx
    mov    [toPushFloat], eax
    fld    dword[toPushFloat]
    fld    dword[sum]
    faddp
    fstp   dword[sum] 
    
    
    mov    eax, [x]
    add    eax, ecx
    mov    ebx, [y]
    add    ebx, ecx
    stdcall DiamondSquare.GetHeight, [resAddr], eax, ebx
    mov    [toPushFloat], eax
    fld    dword[toPushFloat]
    fld    dword[sum]
    faddp
    fstp   dword[sum] 
    
    mov    eax, [x]
    sub    eax, ecx
    mov    ebx, [y]
    sub    ebx, ecx
    stdcall DiamondSquare.GetHeight, [resAddr], eax, ebx
    mov    [toPushFloat], eax
    fld    [toPushFloat]
    fld    dword[sum]
    faddp
     
    mov    [toPushFloat], 4
    fild   [toPushFloat]
    
    fdivp
    fstp   dword[toPushFloat]
    mov    ebx, [toPushFloat]
    xchg   ecx, ebx
    
    mov    eax, [x]
    mul    dword[size]
    add    eax, [y]
    mov    ebx, 4
    mul    ebx
    add    eax, [resAddr]
    xchg   eax, edi
    stdcall DiamondSquare.Displace, ecx, [fRoughness], [currMax] 
    mov    [edi], eax
      
.Finish:
    ret
endp 

proc DiamondSquare.Displace, fVal, fRoughness, currMax  
    locals
;        diff          dd    ?
        toPushFloat   dd    ?
        rnd           dd    ?
    endl
;    diff = max(0.5, min(val/fBaseHeight, 1f))
;    fld    dword[fVal]
;    fld    dword[fBaseHeight]
;    fmulp
;    mov    dword[toPushFloat], 1.0
;    fld    dword[toPushFloat]
;    fcomip st0, st1
;    jna    .Smaller
;    fstp   st0
;    jmp    .Skip1
;    
;.Smaller:    
;    fstp   st1
;    
;.Skip1:
;    mov    dword[toPushFloat], 0.5
;    fld    dword[toPushFloat]
;    fcomip st0, st1
;    jna    .Smaller2
;    fstp   st1
;    jmp    .Skip2
;    
;.Smaller2:
;    fstp   st0
;
;.Skip2:
;    fstp   dword[diff]
    
    stdcall Random.GetFloat32
    mov    [toPushFloat], eax
   ; cmp    eax, 0
   ; jz     .Skip
    
    fld    dword[toPushFloat]
    mov    dword[toPushFloat], 2.0
    fld    dword[toPushFloat]
    fmulp
    
    mov    dword[toPushFloat], 1.0
    fld    dword[toPushFloat]
    fsubp  
    fstp   dword[rnd]
    
    
    fld    dword[rnd]
    fld    dword[fRoughness]
    fmulp
    fild   dword[currMax]
    fmulp
    
    fld    dword[fVal]
    faddp  
;    fldz
;    fcomip 
;    jna    .Finish
    fstp   [toPushFloat]
    mov    eax, [toPushFloat]    

.Finish:
    ret
endp   

proc DiamondSquare.CountOneDiamond uses ebx ecx edi esi ebx, resAddr, x, y, currMax
    locals
        sum           dd    ?
        toPushFloat   dd    ?
    endl

    mov    ecx, [currMax]
    shr    ecx, 1
    
    mov    eax, [x]
    mov    ebx, [y]
    sub    ebx, ecx
    stdcall DiamondSquare.GetHeight, [resAddr], eax, ebx
    mov    [sum], eax
    
    mov    eax, [x]
    add    eax, ecx
    mov    ebx, [y]
    stdcall DiamondSquare.GetHeight, [resAddr], eax, ebx
    mov    [toPushFloat], eax
    fld    dword[toPushFloat]
    fld    dword[sum]
    faddp
    fstp   dword[sum] 
    
    mov    eax, [x]
    mov    ebx, [y]
    add    ebx, ecx
    stdcall DiamondSquare.GetHeight, [resAddr], eax, ebx
    mov    [toPushFloat], eax
    fld    dword[toPushFloat]
    fld    dword[sum]
    faddp
    fstp   dword[sum] 
    
    mov    eax, [x]
    sub    eax, ecx
    mov    ebx, [y]
    stdcall DiamondSquare.GetHeight, [resAddr], eax, ebx
    mov    [toPushFloat], eax
    fld    dword[toPushFloat]
    fld    dword[sum]
    faddp
    
    mov    dword[toPushFloat], 4
    fild   dword[toPushFloat]
    
    fdivp 
    fstp   dword[toPushFloat]
    mov    ecx, [toPushFloat]
    
    mov    eax, [x]
    mul    dword[size]
    add    eax, [y]
    mov    ebx, 4
    mul    ebx
    add    eax, [resAddr]
    xchg   eax, edi
    stdcall DiamondSquare.Displace, ecx, [fRoughness], [currMax] 
    mov    [edi], eax
    
.Finish:
    ret
endp 

proc DiamondSquare.RaiseTosecondPower uses edi ebx eax ecx, resAddr, x, y, size

    mov    eax, [Field.Length]
    mul    eax
    xchg   eax, ecx
    mov    edi, [resAddr]
.Iterate:
    fld    dword[edi]
    fld    dword[edi]
    fmulp
    fstp   dword[edi]

    add    edi, 4

loop .Iterate
;    mov    dword[x], 0
;.Iterate_x:
;    mov    edi, [resAddr]
;    mov    eax, [size]
;    mul    ebx
;    mul    dword[x]
;    add    edi, eax
;    
;    mov    dword[y], 0
;.Iterate_Y:
;    fld    dword[edi]
;    fld    dword[edi]
;    fmulp
;    fstp   dword[edi]
;    add    edi, 4
;        
;    inc    dword[y]
;    mov    eax, [y]
;    cmp    eax, [size]
;    jl     .Iterate_Y 
;    
;    inc    dword[x]
;    mov    eax, [x]
;    cmp    eax, [size]
;    jl     .Iterate_x    

.Finish:
    ret
endp

proc DiamondSquare.PostProcess uses eax ebx esi edi ecx, resAddr
    locals
        NewResAddr    dd    ?
        x             dd    ?
        y             dd    ?
        h1            dd    ?
        h2            dd    ?
        h3            dd    ?
        h4            dd    ?
        h5            dd    ?
        h6            dd    ?
        h7            dd    ?
        h8            dd    ?
        sum           dd    0
        count         dd    0
        toPushFloat   dd    ?
    endl 
    
    mov    eax, [size]
    mul    dword[size]
    mov    ebx, 4
    mul    eax
    invoke HeapAlloc, [Field.hHeap], HEAP_ZERO_MEMORY, eax
    mov   [NewResAddr], eax
    
    mov    dword[x], 0
.Iterate_x:
    mov    eax, [size]
    mov    ebx, 4
    mul    ebx
    mul    dword[x]
    mov    esi, eax
    add    esi, [NewResAddr]
    
    mov    dword[y], 0
.Iterate_Y:    
    mov    eax, [x]
    dec    eax
    mov    ebx, [y]
    dec    ebx
    stdcall DiamondSquare.GetHeight, [resAddr], eax, ebx
    mov    [h1], eax
    
    mov    eax, [x]
    dec    eax
    mov    ebx, [x]
    stdcall DiamondSquare.GetHeight, [resAddr], eax, ebx
    mov    [h2], eax 
    
    mov    eax, [x]
    dec    eax
    mov    ebx, [y]
    inc    ebx
    stdcall DiamondSquare.GetHeight, [resAddr], eax, ebx
    mov     [h3], eax   
    
    mov     eax, [x]
    mov     ebx, [y]
    dec     ebx
    stdcall DiamondSquare.GetHeight, [resAddr], eax, ebx
    mov     [h4], eax
    
    mov     eax, [x]
    inc     eax
    mov     ebx, [y]
    dec     ebx
    stdcall DiamondSquare.GetHeight, [resAddr], eax, ebx
    mov     [h5], eax
    
    mov     eax, [x]
    inc     eax
    mov     ebx, [y]
    stdcall DiamondSquare.GetHeight, [resAddr], eax, ebx
    mov     [h6], eax
    
    mov     eax, [x]
    inc     eax
    mov     ebx, [y]
    inc     ebx
    stdcall DiamondSquare.GetHeight, [resAddr], eax, ebx
    mov    [h7], eax 
    
    mov     eax, [x]
    mov     ebx, [y]
    inc     ebx
    stdcall DiamondSquare.GetHeight, [resAddr], eax, ebx
    mov    [h8], eax 
        
    mov    ecx, [fOutsideHeight]
    
    mov    eax, [h1]
    cmp    eax, ecx
    jz     .Skip1
    inc    dword[count]
    mov    [toPushFloat], eax
    fld    dword[toPushFloat]
    fld    dword[sum]
    faddp
    fstp   dword[sum]
    
.Skip1: 
    mov    eax, [h2]
    cmp    eax, ecx
    jz     .Skip2
    inc    dword[count]
    mov    [toPushFloat], eax
    fld    dword[toPushFloat]
    fld    dword[sum]
    faddp
    fstp   dword[sum]

.Skip2:
    mov    eax, [h3]
    cmp    eax, ecx
    jz     .Skip3
    inc    dword[count]
    mov    [toPushFloat], eax
    fld    dword[toPushFloat]
    fld    dword[sum]
    faddp
    fstp   dword[sum]
    
.Skip3:
    mov    eax, [h4]
    cmp    eax, ecx
    jz     .Skip4
    inc    dword[count]
    mov    [toPushFloat], eax
    fld    dword[toPushFloat]
    fld    dword[sum]
    faddp
    fstp   dword[sum]

.Skip4:
    mov    eax, [h5]
    cmp    eax, ecx
    jz     .Skip5
    inc    dword[count]
    mov    [toPushFloat], eax
    fld    dword[toPushFloat]
    fld    dword[sum]
    faddp
    fstp   dword[sum]
    
.Skip5:
    mov    eax, [h6]
    cmp    eax, ecx
    jz     .Skip6
    inc    dword[count]
    mov    [toPushFloat], eax
    fld    dword[toPushFloat]
    fld    dword[sum]
    faddp
    fstp   dword[sum]
    
.Skip6:
    mov    eax, [h7]
    cmp    eax, ecx
    jz     .Skip7
    inc    dword[count]
    mov    [toPushFloat], eax
    fld    dword[toPushFloat]
    fld    dword[sum]
    faddp
    fstp   dword[sum]    
    
.Skip7:
    mov    eax, [h8]
    cmp    eax, ecx
    jz     .Skip8
    inc    dword[count]
    mov    [toPushFloat], eax
    fld    dword[toPushFloat]
    fld    dword[sum]
    faddp
    fstp   dword[sum]     
    
.Skip8:
    fld    dword[sum]
    fld    dword[count]
    fmulp 
    fstp   dword[esi]
    add    esi, 4
        
    inc    dword[y]
    mov    eax, [y]
    cmp    eax, [size]
    jl     .Iterate_Y 
    
    inc    dword[x]
    mov    eax, [x]
    cmp    eax, [size]
    jl     .Iterate_x    

.Finish:
    mov    eax, [NewResAddr]
    ret
endp

proc DiamondSquare.Normalize uses eax edi ebx ecx, resAddr
    locals
        max    dd    ?
        x      dd    ?
        y      dd    ?
    endl
    
    mov    edi, [resAddr]
    fld    dword[edi]
    
    mov    eax, [size]
    mul    eax
    xchg   eax, ecx
.Iterate_Y1:
    fld    dword[edi]
    fcomi st0, st1
    jna    .Smaller
    fstp   st1
    jmp    .Skip
    
.Smaller:
    fstp   st0
       
.Skip:
    add    edi, 4
    loop   .Iterate_Y1 
    


    fstp   dword[max]

    mov    edi, [resAddr]
    fld    dword[edi]
    
    mov    eax, [size]
    mul    eax
    xchg   eax, ecx
       
.Iterate_Y2:
    fld    dword[edi]
    fld    dword[max]
    fdivp
    fstp   dword[edi]
    
    add    edi, 4
    loop     .Iterate_Y2 
            
.Finish:
    ret
endp  

proc DiamondSquare.Multiply uses eax ebx edi ecx, resAddr, Num, NumSub
    locals
        x    dd     ?
        y    dd     ?
    endl

    xor    edx, edx
    mov    eax, [size]
    mul    eax
    xchg   ecx, eax
    mov    edi, [resAddr]
    
    mov    eax, [NumSub]
.Iterate_Y:
    fild   dword[Num]
    fld    dword[edi]
    fmulp
    fistp  dword[edi]
    add    [edi], eax
        
    add    edi, 4
loop .Iterate_Y

.Finish:
    ret
endp 

proc ProcGen.GenerateTree uses eax ecx ebx edi esi, x, y, z
    locals
        baseSize    dd    ?
        localX      dd    ?
        localY      dd    ?
        localZ      dd    ?
        height      dd    ?
    endl
    
    mov    dword[baseSize], 5
    
    stdcall Random.GetInt, 6, 8
    mov    dword[height], eax
    
    add    eax, [z]
    sub    eax, 4
    mov    [localZ], eax
    mov    ecx, 2
.Iterate_z:
    push   ecx
    mov    ecx, 2
.Iterate_layers:
    push   ecx
    mov    ecx, [baseSize]
    
    mov    eax, [baseSize]
    shr    eax, 1
    
    mov    edi, [x]
    sub    edi, eax
.Iterate_x:
    mov    esi, [y]
    sub    esi, eax
    
    push   ecx
    mov    ecx, [baseSize]
.Iterate_y:
    stdcall Field.SetBlockIndex, edi, esi, [localZ], Block.Leaves 
    inc    esi
loop .Iterate_y
    inc    edi
    pop    ecx 
loop .Iterate_x
    inc    dword[localZ]    
    pop    ecx
loop .Iterate_layers
    sub    dword[baseSize], 2
    pop    ecx
loop .Iterate_z

    mov    ecx, [height]
    mov    ebx, [z]
    mov    [localZ], ebx
.Iterate_Logs:
    stdcall Field.SetBlockIndex, [x], [y], [localZ], Block.Log
    inc    [localZ]
loop .Iterate_Logs
    stdcall Field.SetBlockIndex, [x], [y], [localZ], Block.Leaves
    
.Finish:
    ret
endp 
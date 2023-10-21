;               
;              proc Field.Initialize
proc Field.Initialize uses eax edi ecx ebx, power, Height, baseLvl
    locals
        x      dd  ?
        y      dd  ?
        z      dd  ?  
        Size   dd  ?
        Size_  dd  ?
        chancX dd  ? 
        numChanc dd ?
        startChanc dd ?
        startChancBaseMatrix dd ?
        base    dd    ?
        numTree dd  ?
        numChanc dd ?
        currChanc dd ?
        sizeChanc dd ?
        _mod      dd ?
        _div      dd ?
    endl 
    mov   eax, [baseLvl]   
    mov   dword[base], eax
    
    stdcall Random.Initialize
    
    invoke  GetProcessHeap
    mov    [Field.hHeap], eax
    
    xor    edx, edx
    mov    eax, 1
    mov    cl, byte[power]
    shl    eax, cl
    inc    eax
    mov    dword[Size_], eax
    mov    [Field.Length], eax
    mov    [Field.Width], eax
    
    mul    eax
    mov    edi, eax
             
    mov    edi, [Height]
    mov    [Field.Height], edi
    mul    edi
    
    invoke HeapAlloc, [Field.hHeap], HEAP_ZERO_MEMORY, eax
    mov   [Field.Blocks], eax
    
    xor    edx, edx
    mov    eax, [Size_]
    mul    eax
    mov    ebx, 4
    mul    ebx
;   alloc memory for Field.Matrix  
    invoke HeapAlloc, [Field.hHeap], HEAP_ZERO_MEMORY, eax
    mov    [Field.Matrix], eax
    
    stdcall DiamondSquare.Initialize, [power], 0f, 1f, FALSE, 100f 
    stdcall DiamondSquare.Generate, [Field.Matrix]
    ;mov    [Field.Matrix], eax
   
   
    xor    edx, edx
    mov    eax, [Field.Length]
    mul    dword[Field.Width]
    mov    dword[Size], eax
    
    mov    dword[x], 0        
.Iterate_X:
    xor    edx, edx
    mov    eax, [x]
    mul    dword[Field.Width]
    mov    ecx, eax
    
    mov    dword[y], 0
.Iterate_Y:
    mov    eax, ecx
    mov    edi, dword[y]
    add    eax, edi
    add    eax, [Field.Blocks]
    xchg   eax, edi
    
    xor    edx, edx
    mov    eax, dword[x]
    mul    dword[Field.Length]
    mov    ebx, dword[y]
    add    eax, ebx
    mov    ebx, 4
    xor    edx, edx
    mul    ebx
    add    eax, [Field.Matrix]
    xchg   eax, esi
    
    mov    eax, [esi]    
    
    mov    dword[z], 0
.Iterate_Z:
    mov    byte[edi], Block.Stone
    add    edi, [Size]
    
    inc    dword[z]
    mov    ebx, [z]
    cmp    ebx, eax
    jl     .Iterate_Z
    
    cmp    ebx, [base]
    jnl    .Skip

.SetDirt:
    mov    byte[edi], Block.Dirt
    add    edi, [Size]
    inc    ebx
    cmp    ebx, [base]
    jnl     .Skip
    
.SetWater:  
    mov    byte[edi], Block.Water
    add    edi, [Size]
    inc    ebx
    cmp    ebx, [base]
    jl     .SetWater
        
.Skip:
    inc   dword[y]
    mov   eax, dword[y]
    cmp   eax, dword[Field.Width]
    jl    .Iterate_Y
    
    inc   dword[x]
    mov   eax, dword[x]
    cmp   eax, dword[Field.Length]    
    jl    .Iterate_X
   
    push eax
    pop  eax
    push eax
    pop eax
;   trees
    stdcall Random.Initialize 
    mov   eax, [power]
    mul   dword[power]
    mov   dword[numChanc], eax
    
    xor   edx, edx
    mov   eax, [Field.Length]
    div   dword[power]
    mov   dword[sizeChanc], eax
    
    mov    ecx, 0
.IterateChancs:
    stdcall Random.Initialize
    push   ecx
    
    mov    [currChanc], ecx
    mov    ecx, [sizeChanc]
    shr    ecx, 2
    cmp    ecx, 2
    jnl    .Skip123
    mov    ecx, 2
.Skip123:
    stdcall Random.GetInt, 1, ecx
    mov    ecx, eax
    
.GenerateTrees:
    push   ecx
    mov    ebx, [sizeChanc]
    sub    ebx, 10
    stdcall Random.GetInt, 0, ebx
    add    eax, 6
    mov    [x], eax
  
    mov    ebx, [sizeChanc]
    sub    ebx, 7    
    stdcall Random.GetInt, 0, ebx
    add    eax, 10
    mov    [y], eax   
    
    xor    edx, edx
    mov    eax, [currChanc]
    div    dword[power]
    mov    [_div], eax
    mov    [_mod], edx
   
    xor    edx, edx
    mov    eax, [sizeChanc]
    mul    dword[_div]
    add    eax, [x]
    mov    [x], eax
    
    xor    edx, edx
    mov    eax, [sizeChanc]
    mul    dword[_mod]
    add    eax, [y]
    mov    [y], eax    
        
    xor    edx, edx
    mov    eax, [y]
    mul    dword[Field.Width]
    add    eax, [x]
    mov    ebx, 4
    mul    ebx
    add    eax, [Field.Matrix]
    
    mov    edi, [eax]
    mov    [z], edi
        
    stdcall Field.GetBlockIndex, [x], [y], [z]
    cmp    eax, Block.Air
    jnz    .Continue

    mov    eax, [x]
    sub    eax, 4
    mov    ebx, [y]
    sub    ebx, 4
    
    stdcall Field.IsEmptyArea, eax, ebx, [z], 8, 8, 9
    cmp    eax, FALSE
    jz    .Continue 

    stdcall ProcGen.GenerateTree, [x], [y], [z]
    
.Continue:
    pop    ecx
    dec    ecx
    cmp    ecx, 1
    ja    .GenerateTrees
    
    pop    ecx
    inc    ecx
    cmp    ecx, [numChanc]
    jl     .IterateChancs   
    
    mov    ecx, 10000
    
._SetSpawnPoint:
    push   ecx
    
    stdcall Random.Initialize
    mov    ebx, [Field.Length]
    dec    ebx
    stdcall Random.GetInt, 1, ebx 
    mov    dword[x], eax
    
    stdcall Random.GetInt, 1, ebx
    mov    dword[y], eax
 
    xor    edx, edx
    mov    eax, [y]
    mul    [Field.Length]
    add    eax, [x]
    mov    ebx, 4
    mul    ebx
    add    eax, [Field.Matrix]
    
    mov    edi, [eax]
    mov    [z], edi
    add    dword[z], 2
    
    stdcall Field.GetBlockIndex, [x], [y], [z]
    cmp    eax, Block.Air
    jz     ._Break  
         
    pop    ecx
    loop   ._SetSpawnPoint

._Break:
    fild   dword[x]
    fstp  dword[Field.SpawnPoint]
    
    fild   dword[z]
    fstp  dword[Field.SpawnPoint+4]
    
    fild   dword[y]
    fstp  dword[Field.SpawnPoint+8]      
   
.Finish:
    invoke HeapFree, [Field.hHeap], 0, [Field.Matrix]
    ret
endp

proc Field.GenerateSpawnPoint uses edi, resAddr
    mov    eax, [Field.SpawnPoint]
    mov    edi, [resAddr]
    mov    [edi], eax
    
    mov    eax, [Field.SpawnPoint+4]
    mov    edi, [resAddr]
    mov    [edi+4], eax
    
    mov    eax, [Field.SpawnPoint+8]
    mov    edi, [resAddr]
    mov    [edi+8], eax   
    ret
endp



proc Field.GenerateSeed uses edi ecx eax
    mov    eax, [Field.Length]
    mov    edi, [Field.Width]
    mul    edi
    xchg   eax, ecx
    
    mov    edi, [Field.Seed]
    
.Iterate:
    stdcall Random.GetFloat32
    mov     [edi], eax
    add     edi, 4
    loop   .Iterate
    
    ret
endp

proc Field.IsEmptyArea uses edx edi esi ecx, x, y, z, lenX, lenY, lenZ
    locals
        localX    dd    ?
        localY    dd    ?
        localZ    dd    ?
        i         dd    ?; x
        j         dd    ?; y
        k         dd    ?; z
    endl

    mov    eax, [z]
    mov    dword[localZ], eax
    mov    ecx, [lenZ]
.Iterate_Z:
    push   ecx
    mov    eax, [x]
    mov    dword[localX], eax
    
    mov    ecx, [lenX]
.Iterate_X:
    push   ecx
    mov    eax, [y]
    mov    dword[localY], eax
    
    mov    ecx, [lenY]
.Iterate_Y:
    push   ecx
    stdcall Field.GetBlockIndex, [localX], [localY], [localZ]
    cmp    eax, Block.Air
    jz     .Skip
    mov    eax, FALSE
    jmp    .Finish
.Skip:
    
    pop    ecx
    loop   .Iterate_Y
    pop    ecx
    loop   .Iterate_X
    pop    ecx
    loop   .Iterate_Z
    mov    eax, TRUE
.Finish:
    ret
endp

;              func Field.GetBlockIndex
;    Input:  dWord X, dWord Y, dWord Z
;    Output: eax <- BlockIndex or ErrorCode
;
proc Field.GetBlockIndex uses edi, X: word, Y: word, Z: word  
     xor    eax, eax

     mov    eax, dword[Y]  
      
     mov    edi, [Field.Length]
     mul    edi
     
     mov    edi, dword[X]
     add    eax, edi
     
     xchg   eax, edi
     
     mov    esi, dword[Z]
     mov    eax, [Field.Length]
     mov    ecx, [Field.Width]
     mul    ecx
     mul    esi
     
     add    eax, edi

     add    eax, [Field.Blocks]
     
     xchg   eax, edi
     movzx  eax, byte[edi]
     jmp    .Finish

.Finish:
     ret
endp

;              func Field.SetBlockIndex
;    Input:  Word X, Word Y, Word Z, byte BlockIndex
;    Output: eax <- BlockIndex or ErrorCode
;
proc Field.SetBlockIndex uses edi eax esi ecx ebx ecx, X: dword, Y: dword, Z: dword, BlockIndex: byte     
     xor    eax, eax

     mov    eax, dword[Y]  
      
     mov    edi, [Field.Length]
     mul    edi
     
     mov    edi, dword[X]
     add    eax, edi
     
     xchg   eax, edi
     
     mov    esi, dword[Z]
     mov    eax, [Field.Length]
     mov    ecx, [Field.Width]
     mul    ecx
     mul    esi
     
     add    eax, edi

     add    eax, [Field.Blocks]
     
     xchg   eax, edi
     movzx  eax, byte[BlockIndex]
     mov    byte[edi], al

     jmp    .Finish
.Finish:
     ret
endp

proc Field.PalinNoise2D uses esi edi ecx ebx edx, resAddr, width, height,\
                        octaves, seedAddr, fBias, Leo 
    locals
        x           dw    ?
        y           dw    ?
        o           dw    ?
        fNoise      dd    ?
        fScaleAcc   dd    ?
        fScale_     dd    ?
        pitch       dd    ?
        sampleX1    dd    ?
        sampleY1    dd    ?
        sampleX2    dd    ?
        sampleY2    dd    ?
        fBlendX     dd    ?
        fBlendY     dd    ?
        fSampleT    dd    ?
        fSampleB    dd    ?
        toPushFloat dd    ?
        Tmp         dd    ?
    endl
    
    xor    ebx, ebx
    mov    word[x], 0    ; TEST!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.Iterate_x:
    mov    word[y], 0    ; TEST!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.Iterate_y:
    mov    dword[fNoise], 0.0
    mov    dword[fScaleAcc], 0.0
    mov    dword[fScale_], 1.0
   
    mov    word[o], 0    ; TEST!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.Iterate_o:
    ; pitch = ecx = width >> o
    movzx  edi, word[width]
    mov    cx, word[o] 
    shr    edi, cl
    xchg   edi, ecx
    
    ; sampleX1 = (x / pitch) * pitch    
    mov    edx, 0
    movzx  eax, [x]
    div    ecx
    xor    edx, edx
    mul    ecx
    mov    [sampleX1], eax
    
    ; sampleY1 = (y / pitch) * pitch    
    xor    edx, edx
    movzx  eax, [y]
    div    ecx
    xor    edx, edx
    mul    ecx
    mov    [sampleY1], eax 
    
    ; sampleX2 = (sampleX1 + pitch) % width
    mov    eax, [sampleX1]
    add    eax, ecx
    xor    edx, edx
    div    [width]
    mov    [sampleX2], edx
    
    ; sampleY2 = (sampleY1 + pitch) % width
    mov    eax, [sampleY1]
    add    eax, ecx
    xor    edx, edx
    div    [width]
    mov    [sampleY2], edx
    
    ; fBlendX = float(x-sampleX1) / float(pitch)
    movzx  eax, word[x]
    sub    eax, [sampleX1]
    
    mov    [toPushFloat], eax
    fild    dword[toPushFloat]  ; (x-sampleX1) -->
       
    mov    [toPushFloat], ecx
    fild   dword[toPushFloat]  ; pitch --> (x-sampleX1)
    
    fdivp   
    fstp   dword[fBlendX]
;
    mov    eax, dword[fBlendX]
    
    ; fBlendY = float(y-sampleY1) / float(pitch)
    movzx  eax, word[y]
    sub    eax, [sampleY1]
    
    mov    [toPushFloat], eax
    fild    dword[toPushFloat]  ; (x-sampleX1) -->
    
    mov    [toPushFloat], ecx
    fild   dword[toPushFloat]  ; pitch --> (x-sampleX1)
    
    fdivp   
    fstp   dword[fBlendY] 
    
    ; sampleT = (1.0-fBlendX)*seedAddr[sampleY1*width+sampleX1]
    ;           +fBlendX*seedAddr[SampleY1*width+sampleX2]
    ;   1. sampleY1*width+sampleX1
    
    xor    edx, edx
    mov    eax, [sampleY1]
    mul    dword[width]
    mov    esi, eax     ; esi = sampleY1*width
    add    eax, [sampleX1]
    mov    edi, 4
    xor    edx, edx
    mul    edi
    mov    edi, eax
    add    edi, [seedAddr]
    
    ;   2. 1.0-fBlendX
    mov    dword[toPushFloat], 1.0
    fld    dword[toPushFloat];  1.0 -->
    fld    dword[fBlendX]    ; fBlendX --> 1.0
    
    fsubp
    mov    eax, [edi]
    mov    [toPushFloat], eax
    fld    dword[toPushFloat]
    
    fmulp
    fstp   dword[Tmp] ; Tmp = (1.0-fBlendX)*seed[sampleY1....
    
    ;   3. sampleY1*width+sampleX2
    xor   edx, edx
    mov   edi, esi
    add   edi, [sampleX2]
    mov   eax, edi
    mov   edi, 4
    mul   edi
    add   eax, [seedAddr]
    xchg  eax, edi
    
    fld   dword[fBlendX]
    
;    mov   eax, [edi]
;    mov   [toPushFloat], eax
;    fld   dword[toPushFloat]
    fld   dword[edi]
    
    fmulp 
    
    fld   dword[Tmp]
    faddp
    
    fstp dword[fSampleT]
    
        ; sampleB = (1.0-fBlendX)*seedAddr[sampleY2*width+sampleX1]
    ;           +fBlendX*seedAddr[sampleY2*width+sampleX2]
    ;   1. sampley1*width+sampleX1 
    
    xor    edx, edx
    mov    eax, [sampleY2]
    mul    dword[width]
    mov    esi, eax     ; esi = sampleY2*width
    add    eax, [sampleX1]
    mov    edi, 4
    xor    edx, edx
    mul    edi
    mov    edi, eax
    add    edi, [seedAddr]
    
    ;   2. 1.0-fBlendX
    mov    dword[toPushFloat], 1.0
    fld    dword[toPushFloat];  1.0 -->
    fld    dword[fBlendX]    ; fBlendX --> 1.0
    
    fsubp
    mov    eax, [edi]
    mov    [toPushFloat], eax
    fld    dword[toPushFloat]
    
    fmulp
    fstp   dword[Tmp] ; Tmp = (1.0-fBlendX)*seed[sampleY2....
    
    ;   3. sampleY1*width+sampleX2
    xor   edx, edx
    mov   edi, esi
    add   edi, [sampleX2]
    mov   eax, edi
    mov   edi, 4
    mul   edi
    add   eax, [seedAddr]
    xchg  eax, edi
    
    fld   dword[fBlendX]
    
    mov   eax, [edi]
    mov   [toPushFloat], eax
    fld   dword[toPushFloat]
    
    fmulp 
    
    fld   dword[Tmp]
    faddp
    
    fstp  dword[fSampleB]
    
    ;fScaleAcc = fScaleAcc + fScale_
    fld   dword[fScaleAcc] 
    fld   dword[fScale_]
    faddp
    fstp dword[fScaleAcc]
    
    ; fNoise = fNoise + (fBlendY*(fSampleB-fSampleT) + 
    ;          + fSampleT) *fScale_ 
    
    fld   dword[fSampleB]
    fld   dword[fSampleT] ; fSampleT --> fSampleB
    fsubp
    
    fld   dword[fBlendY]
    fmulp
    fld   dword[fSampleT]
    faddp
    fld   dword[fScale_]
    fmulp
    fld   dword[fNoise]
    faddp
    fstp  dword[fNoise]
    
    ; fScale_ = fScale / fBias
    fld   dword[fScale_]
    fld   dword[fBias]  ; fBias --> fScale_
    fdivp
    fstp  dword[fScale_]
    
    inc   word[o]
    movzx eax, word[o]
    cmp   eax, dword[octaves]
    
;   end cycle
    jl   .Iterate_o
    
    ; res[y*width+x] = fNoise / fScaleAcc
    inc   ebx
    xor   edx, edx
    movzx eax, word[y]
    mul   dword[width]
    movzx edi, word[x]
    add   eax, edi
    mov   edi, 4
    xor   edx, edx
    mul   edi
    ;
    ;mov   esi, eax
    ;add   esi, [seedAddr]
    ;
    
    add   eax, [resAddr]
    xchg  eax, edi
    
    fld   dword[fNoise] 
    fld   dword[fScaleAcc] ; fScaleAcc --> fNoise
    fdivp
    fild  dword[Leo]
    fmulp
    ;
    ;fstp    dword[esi]
    ;fld     dword[esi]
    ;
    fistp  dword[edi]
   ; mov    ebx, 80
   ; sub    dword[edi], ebx
    
    ; end loop_y
    inc   word[y]
    movzx eax, word[y]
    cmp   eax, dword[height]
    jl    .Iterate_y

  ; end loop_x
    inc   word[x]
    movzx eax, word[x]
    cmp   eax, dword[width]
    jl    .Iterate_x
    
.Finish:
    ret
endp 

;              func Field.TestBounds
;    Input:  Word X, Word Y, Word Z
;    Output: eax <- Zero or ErrorCode
;
proc Field.TestBounds uses ebx, X: dword, Y: dword, Z: dword
     xor    eax, eax

     cmp    word[X], Field.LENGTH
     jge    .Error

     cmp    word[Y], Field.WIDTH
     jge    .Error

     cmp    word[Z], Field.HEIGHT
     jge    .Error

     cmp    word[X], 0
     jl     .Error 
     cmp    word[Y], 0
     jl     .Error
     cmp    word[Z], 0
     jl     .Error
     jmp    .Finish

.Error:    
     mov    eax, ERROR_OUT_OF_BOUND    
.Finish:   
     ret
endp

proc Field.GenerateBigMines uses edi esi, x, y, z,  depth, size 
     locals
        newX      dd ?
        newY      dd ?
        newZ      dd ?
        toChange  dd ?
        hasBranch dd ?
     endl
     
     
     cmp    dword[depth], 0
     jz     .Finish
     cmp    dword[size], 0
     jz     .Finish

     mov    edi, [x]
     sub    edi, 1
     mov    esi, [x]
     add    esi, 1
     stdcall Random.GetInt, edi, esi
     mov    [newX], eax
     
     mov    edi, [y]
     sub    edi, 1
     mov    esi, [y]
     add    esi, 1
     stdcall Random.GetInt, edi, esi
     mov    [newY], eax
     
     mov    edi, [z]
     sub    edi, 1
     mov    esi, [z]
     add    esi, 0
     stdcall Random.GetInt, edi, esi
     mov    [newZ], eax    
     
     dec    dword[depth]
     stdcall Random.GetInt, 4, 5
     cmp    eax, 4
     jz     .Skip
     stdcall Field.GenerateBigMines, [newX], [newY], [newZ], [depth], [size]
     
.Skip:
     dec    dword[size]
     stdcall Field.GenerateBigMines, [newX], [newY], [newZ], [depth], [size]  

     stdcall Field.SetBlockIndex, [newX], [newY], [newZ], Block.Air
.Finish:
     ret
endp

proc Field.GenerateSmallMines uses edi esi, 
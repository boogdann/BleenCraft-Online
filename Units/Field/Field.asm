;               
;              proc Field.Initialize
proc Field.Initialize uses eax edi ecx ebx, _hHeap, Length, Width, Height
    locals
        x   dw    ?
        y   dw    ?
        z   dw    ?  
        Size dd   ?  
    endl 
    
    mov    edi, [_hHeap]
    mov    [Field.hHeap], edi
         
    mov    edi, [Length]
    mov    [Field.Length], edi
    xchg   eax, edi 
    
    mov    edi, [Width]
    mov    [Field.Width], edi
    mul    edi
    
    mov    edi, [Height]
    mov    [Field.Height], edi
    mul    edi
    
    invoke HeapAlloc, [Field.hHeap], HEAP_ZERO_MEMORY, eax
    mov   [Field.Blocks], eax

;   alloc memory for Field.Seed    
    mov    eax, [Field.Length]
    mov    edi, [Field.Width]
    mul    edi
    
    mov    edi, 4
    mul    edi 
    
    mov    ebx, eax
    
    invoke HeapAlloc, [Field.hHeap], HEAP_ZERO_MEMORY, eax
    mov    [Field.Seed], eax
    
    stdcall Field.GenerateSeed
    
    
    xchg  eax, ebx
;   alloc memory for Field.Matrix  
    invoke HeapAlloc, [Field.hHeap], HEAP_ZERO_MEMORY, eax
    mov    [Field.Matrix], eax
 
    stdcall Field.PalinNoise2D, [Field.Matrix],\
            [Field.Length], [Field.Width], 7, [Field.Seed], 2.0, 30
            
    
    xor    edx, edx
    mov    eax, [Field.Length]
    mul    dword[Field.Width]
    mov    dword[Size], eax
    
    mov    word[x], 0        
.Iterate_X:
    xor    edx, edx
    movzx  eax, word[x]
    mul    dword[Field.Width]
    mov    ecx, eax
    
    mov    word[y], 0
.Iterate_Y:
    mov    eax, ecx
    movzx  edi, word[y]
    add    eax, edi
    add    eax, [Field.Blocks]
    xchg   eax, edi
    
    xor    edx, edx
    movzx  eax, word[x]
    mul    dword[Field.Length]
    movzx  ebx, word[y]
    add    eax, ebx
    mov    ebx, 4
    xor    edx, edx
    mul    ebx
    add    eax, [Field.Matrix]
    xchg   eax, esi
    
    mov    eax, [esi]    
    
    mov    word[z], 0
.Iterate_Z:
    mov    byte[edi], Block.Dirt
    add    edi, [Size]
    
    inc    word[z]
    movzx  ebx, word[z]
    cmp    ebx, eax
    jl     .Iterate_Z

    inc   word[y]
    movzx eax, word[y]
    cmp   eax, dword[Field.Width]
    jl    .Iterate_Y
    
    inc   word[x]
    movzx eax, word[x]
    cmp   eax, dword[Field.Length]    
    jl    .Iterate_X
    
;    stdcall Field.SetBlockIndex, 12, 12, 5, Blocks.STONE
;    stdcall Field.SetBlockIndex, 13, 12, 5, Blocks.STONE 
;    stdcall Field.SetBlockIndex, 14, 12, 5, Blocks.STONE
;    stdcall Field.SetBlockIndex, 13, 12, 6, Blocks.STONE
;    stdcall Field.SetBlockIndex, 13, 12, 7, Blocks.STONE
;    
;    stdcall Field.SetBlockIndex, 12, 12, 12, Blocks.STONE
;    stdcall Field.SetBlockIndex, 13, 12, 12, Blocks.STONE 
;    stdcall Field.SetBlockIndex, 14, 12, 12, Blocks.STONE
;    stdcall Field.SetBlockIndex, 13, 12, 13, Blocks.STONE
;    stdcall Field.SetBlockIndex, 13, 12, 14, Blocks.STONE
;    
;    stdcall Field.SetBlockIndex, 10, 10, 2, Blocks.STONE
;    stdcall Field.SetBlockIndex, 11, 10, 2, Blocks.STONE 
;    stdcall Field.SetBlockIndex, 12, 10, 2, Blocks.STONE
;    stdcall Field.SetBlockIndex, 11, 10, 3, Blocks.STONE
;    stdcall Field.SetBlockIndex, 11, 10, 4, Blocks.STONE    

.Finish:
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
proc Field.SetBlockIndex uses edi eax esi ecx, X: dword, Y: dword, Z: dword, BlockIndex: byte     
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

proc Field.PalinNoise2D uses esi edi ecx, resAddr, width, height,\
                        octaves, seedAddr, fBias, Leo 
    locals
        x           dw    ?
        y           dw    ?
        o           db    ?
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
   
    mov    byte[o], 0    ; TEST!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.Iterate_o:
    ; pitch = ecx = width >> o
    movzx  edi, word[width]
    mov    cl, byte[o] 
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
    
    inc   byte[o]
    movzx eax, byte[o]
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
    add   eax, [resAddr]
    xchg  eax, edi
    
    fld   dword[fNoise] 
    fld   dword[fScaleAcc] ; fScaleAcc --> fNoise
    fdivp
    fild  dword[Leo]
    fmulp
    
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
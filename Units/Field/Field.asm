;              proc Field.Initialize
proc Field.Initialize uses eax edi ecx ebx, power, Height, baseLvl, filename
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
        currChanc dd ?
        sizeChanc dd ?
        _mod      dd ?
        _div      dd ?
        tmpBase   dd 0
    endl 
        
    mov   eax, [baseLvl]   
    mov   dword[base], 65
    mov   dword[tmpBase], eax
    sub   dword[tmpBase], 5
    
    mov   dword[Field.IsGenerated], 0
    
    stdcall Random.Initialize
    
    cmp     dword[IS_READ_FROM_FILE], FALSE
    jz      @F
    stdcall Field.ReadFromFiles, [filename]
    cmp     eax, -1
    jnz     .EndSetWorld
@@:

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
    
    mov    ecx, eax
    mov    edi, [Field.Blocks]
    mov    al, 0
    rep    stosb
    
;    mov    ebx, eax
;.GetMem:
;    push   ebx
;    invoke HeapAlloc, [Field.hHeap], HEAP_ZERO_MEMORY, ebx
;    pop    ebx
;    mov   [Field.Blocks], eax
;    cmp   eax, 0
;    jz    .GetMem 
        
    xor    edx, edx
    mov    eax, [Size_]
    mul    eax
    mov    ebx, 4
    mul    ebx
;   alloc memory for Field.Matrix  
;    invoke HeapAlloc, [Field.hHeap], HEAP_ZERO_MEMORY, eax
;    mov    [Field.Matrix], eax
    
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
    
;.SetDirt:
;    mov    byte[edi], Block.Dirt
;    add    edi, [Size]
;    inc    ebx
;    cmp    ebx, [base]
;    jnl    .Skip
;
;.SetGravel:
;    mov    byte[edi], Block.Gravel
;    add    edi, [Size]
;    inc    ebx
;    cmp    ebx, [base]
;    jnl    .Skip


.SetWaterGravel:
    mov    byte[edi], Block.Gravel
    add    edi, [Size]
    inc    ebx   
    cmp    ebx, [base]
    jnl    .Skip
        
.SetWaterFull:        
    mov    byte[edi], Block.Water
    add    edi, [Size]
    inc    ebx
    cmp    ebx, [base]
    jl     .SetWaterFull
    jmp    .SkipSetTurfAndDirt
            
.Skip:
    sub    edi, [Size]
    mov    byte[edi], Block.Dirt
    sub    edi, [Size]
    stdcall Random.GetInt, 2, 6
    push    ecx
    mov     ecx, eax
.SetTurf:
    mov    byte[edi], Block.Turf
    sub    edi, [Size]
    loop   .SetTurf
    pop    ecx
    
.SkipSetTurfAndDirt:
    inc   dword[y]
    mov   eax, dword[y]
    cmp   eax, dword[Field.Width]
    jl    .Iterate_Y
    
    inc   dword[x]
    mov   eax, dword[x]
    cmp   eax, dword[Field.Length]    
    jl    .Iterate_X

;   trees
    mov   eax, [power]
    mul   dword[power]
    mov   dword[numChanc], eax
    
    xor   edx, edx
    mov   eax, [Field.Length]
    div   dword[power]
    mov   dword[sizeChanc], eax
        
    mov    ecx, 0
.IterateChancs:
    push   ecx
    
    mov    [currChanc], ecx
    mov    ecx, [sizeChanc]
    shr    ecx, 1
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
    ; add    edi, 1
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
    
    mov    ecx, 100000
    
._SetSpawnPoint:
    push   ecx
    
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
    stdcall Random.Initialize
    stdcall Field.GenerateSmallMines, [x], [y], [z], 600, 3
    
    invoke HeapFree, [Field.hHeap], 0, [Field.Matrix]
    
    stdcall Field.GenerateMines, [sizeChanc], 5, [power]
    stdcall Field.GenerateOre, [sizeChanc], [numChanc], [power]
     
.EndSetWorld:
    mov     dword[Field.IsGenerated], TRUE 
    mov     dword[Field.IsSpawnPointGenerated], TRUE
     
    stdcall Field.GenerateBedrock
    ret
endp

proc Field.DestroyWorld uses ecx edx eax
     cmp     dword[Field.IsGenerated], TRUE
     jnz      .SkipDestroyWorld
     invoke  HeapFree, [Field.hHeap], 0, [Field.Blocks]
     mov     dword[Field.IsGenerated], FALSE
.SkipDestroyWorld:
     mov     dword[Field.IsSpawnPointGenerated], FALSE
     
.Finish:
     ret
endp

proc Field.DestroyClouds uses ecx edx eax 
     cmp     dword[Field.IsCloudsGenerated], TRUE
     jz      .SkipDestroyClouds
     invoke  HeapFree, [Field.hHeap], 0, [Field.Sky]
     cmp     dword[Field.IsCloudsGenerated], FALSE
.SkipDestroyClouds:
.Finish:
     ret
endp

proc Field.SetValues uses edi eax edx, pWorld, pSizeX, pSizeY, pSizeZ, pFullSize
     mov    edi, [pWorld]
     mov    eax, [Field.Blocks]
     mov    [edi], eax
     
     mov    edi, [pSizeX]
     mov    eax, [Field.Length]
     mov    [edi], eax
     
     mov    edi, [pSizeY]
     mov    eax, [Field.Width]
     mov    [edi], eax     
     
     mov    edi, [pSizeZ]
     mov    eax, [Field.Height]
     mov    [edi], eax

     xor    edx, edx
     mov    eax, [Field.Length]
     mul    dword[Field.Width]
     mul    dword[Field.Height]
     
     mov    edi, [pFullSize]
     mov    [edi], eax

.Finish:
     ret
endp

proc Field.SetCloudValues uses edi eax edx, pSky, pSizeX, pSizeY
     mov    edi, [pSky]
     mov    eax, [Field.Sky]
     mov    [edi], eax
     
     mov    edi, [pSizeX]
     mov    eax, [Field.SkyLength]
     mov    [edi], eax
     
     mov    edi, [pSizeY]
     mov    eax, [Field.SkyWidth]
     mov    [edi], eax     
     
.Finish:
     ret
endp

proc Field.GenerateBedrock uses ecx eax edx edi 
     xor     edx, edx
     mov     eax, [Field.Length]
     mul     dword[Field.Width]
     
     xchg    ecx, eax
     mov     al, Block.Bedrock  
     
     mov     edi, [Field.Blocks] 
     
     rep stosb
     
.Finish:
     ret
endp

proc Field.InitData uses eax, Length, Width, Height
     mov     eax, [Length]
     mov     [Field.Length], eax
     
     mov     eax, [Width]
     mov     [Field.Width], eax
     
     mov     eax, [Height]
     mov     [Field.Height], eax   
     
     mov     [Field.IsGenerated], TRUE  
.Finish:
     ret
endp

proc Field.GenerateSpawnPoint uses edi ecx eax ebx, resAddr
     locals
         x dd 100
         y dd 100
         z dd 100
     endl
     
     ;cmp    dword[Field.IsSpawnPointGenerated], TRUE
     ;jz     .Finish
     
     stdcall Random.Initialize
     
     mov    ecx, 10000    
._SetSpawnPoint:
     push   ecx
    
     mov    ebx, [Field.Length]
     dec    ebx
     stdcall Random.GetInt, 1, ebx 
     mov    dword[x], eax
    
     stdcall Random.GetInt, 1, ebx
     mov    dword[y], eax
    
     mov    dword[z], 40
.Iterate_Z:
     stdcall Field.GetBlockIndex, [x], [y], [z]
     cmp     eax, Block.Water
     jz      .Continue
     
     cmp    eax, Block.Air
     jz     ._Break  

.Continue:
     ;push   eax
     mov    eax, [Field.Height]
     ;sub    eax, 20
     inc    dword[z]
     cmp    [z], eax
     ;pop    eax

     jl     .Iterate_Z
         
     pop    ecx
     loop   ._SetSpawnPoint

._Break:
     fild   dword[x]
     fstp   dword[Field.SpawnPoint]
    
     fild   dword[z]
     fstp   dword[Field.SpawnPoint+4]
    
     fild   dword[y]
     fstp   dword[Field.SpawnPoint+8]   

     mov    dword[Field.IsSpawnPointGenerated], TRUE
     
.Finish:
     mov    eax, [Field.SpawnPoint]
     
     cmp   dword[_IS_SERVER_DEBUD], FALSE
     jz    @F
     mov   eax, 500.0
@@:
     mov    edi, [resAddr]
     mov    [edi], eax
    
     mov    eax, [Field.SpawnPoint+4]
     cmp   dword[_IS_SERVER_DEBUD], FALSE
     jz    @F
     mov   eax, 70.0
@@:

     mov    edi, [resAddr]
     mov    [edi+4], eax
    
     mov    eax, [Field.SpawnPoint+8]
     
     cmp   dword[_IS_SERVER_DEBUD], FALSE
     jz    @F
     mov   eax, 900.0
@@:
     
     mov    edi, [resAddr]
     mov    [edi+8], eax   
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
proc Field.GetBlockIndex uses edi esi ecx ebx ecx edx, X, Y, Z  
     xor    eax, eax

     stdcall Field.TestBounds, [X], [Y], [Z]
     cmp     eax, ERROR_OUT_OF_BOUND
     jz      .Finish

     xor    eax, eax

     mov    eax, dword[Y]  
     
     xor    edx, edx 
     mov    edi, [Field.Length]
     mul    edi
     
     mov    edi, dword[X]
     add    eax, edi
     
     xchg   eax, edi
     
     xor    edx, edx
     mov    esi, dword[Z]
     mov    eax, [Field.Length]
     mov    ecx, [Field.Width]
     mul    ecx
     mul    esi
     
     add    eax, edi

     add    eax, [Field.Blocks]
     
     xchg   eax, edi
     movzx  eax, byte[edi]
.Finish:
     ret
endp

;              func Field.SetBlockIndex
;    Input:  Word X, Word Y, Word Z, byte BlockIndex
;    Output: eax <- BlockIndex or ErrorCode
;
proc Field.SetBlockIndex uses edi eax esi ecx ebx ecx, X, Y, Z, BlockIndex
     locals
         Pos   dd   ?, ?, ?
     endl
     
     xor    eax, eax
     
     stdcall Field.TestBounds, [X], [Y], [Z]
     cmp     eax, ERROR_OUT_OF_BOUND
     jz      .Finish
     
     cmp     dword[BlockIndex], Block.Air
     jz      @F
     cmp     dword[BlockIndex], Block.Water
     jnz     .SkipDeleteTorch
@@:
     
     
     fild    dword[X]
     fstp    dword[Pos]
     
     fild    dword[Y]
     fstp    dword[Pos+8]
     
     fild    dword[Z]
     fld1
     faddp
     fstp    dword[Pos+4] 
     
     lea     esi, [Pos]
     stdcall gf_DeleteLightning, esi     
     
.SkipDeleteTorch:
     
     cmp     dword[BlockIndex], Block.Torch
     jnz     .SkipAddTorch
     
     fild    dword[X]
     fstp    dword[Pos]
     
     fild    dword[Y]
     fstp    dword[Pos+8]
     
     fild    dword[Z]
     fld1
     faddp
     fstp    dword[Pos+4] 
     
     lea     esi, [Pos]
     stdcall gf_AddLightning, esi      
.SkipAddTorch:
     
     mov    eax, dword[Y]  
     
     xor    edx, edx 
     mov    edi, [Field.Length]
     mul    edi
     
     mov    edi, dword[X]
     add    eax, edi
     
     xchg   eax, edi
     
     xor    edx, edx
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

     cmp     dword[Field.IsGenerated], 1
     jnz     @F
     stdcall Client.SendBlock, [X], [Y], [Z], [BlockIndex]
@@:

     jmp    .Finish

.Finish:
     ret
endp

;              func Field.TestBounds
;    Input:  Word X, Word Y, Word Z
;    Output: eax <- Zero or ErrorCode
;
proc Field.TestBounds uses ebx, X, Y, Z
     xor    eax, eax

     mov    eax, [Field.Length]
     cmp    [X], eax
     jnl    .Error

     mov    eax, [Field.Width]
     cmp    [Y], eax
     jnl    .Error

     mov    eax, [Field.Height]
     cmp    [Z], eax
     jnl    .Error

     cmp    [X], 0
     jl     .Error 
     cmp    [Y], 0
     jl     .Error
     cmp    [Z], 0
     jl     .Error
     jmp    .Finish

.Error:    
     mov    eax, ERROR_OUT_OF_BOUND    
.Finish:   
     ret
endp

proc Field.GenerateMines uses eax ebx edx esi edi, sizeChanc, numChanc, power
    locals
        x             dd ?
        y             dd ?
        z             dd ?
        currChanc     dd ?
        _div          dd ?
        _mod          dd ?
    endl
    
    stdcall Random.Initialize
    
    mov     ecx, 0
.IterateChancs:
    push   ecx
    mov    [currChanc], ecx
    mov    ecx, [sizeChanc]
    shr    ecx, 4
    cmp    ecx, 2
    jnl    .Skip123
    mov    ecx, 2
.Skip123:
    stdcall Random.GetInt, 1, ecx
    mov    ecx, eax
.GenerateMine:
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
    
    mov     eax, [Field.Height]
    sub     eax, 30
    stdcall Random.GetInt, 30, eax 
    mov     [z], eax 
    
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
    
    stdcall Field.GenerateSmallMines, [x], [y], [z], 600, 1  
            
.Continue:
    pop    ecx
    dec    ecx
    cmp    ecx, 1
    ja    .GenerateMine
    
    pop    ecx
    inc    ecx
        
    cmp    ecx, [numChanc]
    jl     .IterateChancs     


.Finish:
     ret
endp

proc Field.GenerateSmallMines uses edi esi ebx edx, x, y, z, size, depth
     locals
        newX       dd ?
        newY       dd ?
        newZ       dd ?
        dir        dd ?
        curr       dd ?
        len        dd ?
        NUM_100    dd ?
        sphereSize dd ?
     endl
     mov     dword[NUM_100], 100
     
     dec     dword[depth]
     cmp     dword[size], 0
     jl      .Finish
     cmp     dword[depth], 0
     jl      .Finish
          
     mov     dword[curr], 6
     mov     ecx, [size]
     
.GenerateMine: 
     stdcall Random.GetInt, 1, 400
     xor     edx, edx
     div     dword[NUM_100]
     inc     eax
     mov     [sphereSize], eax
     mov     edi, eax
     shr     edi, 1
     cmp     edi, 0
     jl      .SkipSetEbx
     mov     edi, 1

.SkipSetEbx:     
     push    ecx
     stdcall Random.GetInt, 1, 1100
     inc     eax
     
     cmp     eax, 100
     jnl     .Skip1
     stdcall Random.GetInt, 1, edi 
     sub     dword[x], edi
     jmp     .Continue

.Skip1:
     cmp     eax, 300
     jnl     .Skip2
     stdcall Random.GetInt, 1, edi 
     add     dword[x], edi
     jmp     .Continue  
     
.Skip2:
     cmp     eax, 500
     jnl     .Skip3
     stdcall Random.GetInt, 1, edi 
     sub     dword[y], edi
     jmp     .Continue 
     
.Skip3:
     cmp     eax, 700
     jnl     .Skip4
     stdcall Random.GetInt, 1, edi 
     add     dword[x], edi
     jmp     .Continue
     
.Skip4:
     cmp     eax, 900
     jnl     .Skip5
     stdcall Random.GetInt, 1, edi 
     add     dword[z], edi
     jmp     .Continue
     
.Skip5:
     stdcall Random.GetInt, 1, edi 
     sub     dword[z], edi
     jmp     .Continue

.Skip6:
.Continue:

     stdcall Random.GetInt, 0, 100
     cmp     eax, 50
     jl      .SkipBranch
     
     cmp     dword[size], 20
     jl      .SkipBranch
     
     ;stdcall Field.GenerateSmallMines, [x], [y], [z], [size], [depth]

.SkipBranch:
     
     stdcall Field.GenerateSphere, [x], [y], [z], [sphereSize]
      
     pop     ecx
     dec     ecx
     cmp     ecx, 0 
     jnz     .GenerateMine
     
.Finish:
     ret
endp

proc Field.GenerateSphere uses eax ebx edx ecx esi, x, y, z, len
     locals
        newX dd ?
        newY dd ?
        newZ dd ?
        dir  dd ?
        curr dd ?
     endl
     dec     dword[z]
     
     push    dword[x] dword[y] dword[z]
;     cmp     dword[len], 3
;     jl      .SkipSetOres
;     
;     stdcall Random.GetInt, 0, 1000
;     cmp     eax, 950
;     jl      .SkipSetOres
;     
;     stdcall Random.GetInt, 0, 6
;     add     eax, 1
;     
;     mov     ecx, [len]
;     cmp     eax, 1
;     jnz     .Skip1
;     stdcall Field.GenBlocks, [x], [y], [z]
;.Skip1:
;     
;     cmp     eax, 2
;     jnz     .Skip2
;     add     dword[x], ecx 
;     stdcall Field.GenBlocks, [x], [y], [z]
;.Skip2:
;
;     cmp     eax, 3
;     jnz     .Skip3
;     add     dword[x], ecx 
;     add     dword[y], ecx 
;     stdcall Field.GenBlocks, [x], [y], [z]
;.Skip3:
;
;     cmp     eax, 4
;     jnz     .Skip4
;     add     dword[x], ecx 
;     add     dword[y], ecx
;     add     dword[z], ecx 
;     stdcall Field.GenBlocks, [x], [y], [z]
;.Skip4:
;
;     cmp     eax, 5
;     jnz     .Skip5
;     add     dword[x], ecx 
;     add     dword[z], ecx 
;     stdcall Field.GenBlocks, [x], [y], [z]
;.Skip5:
;
;     cmp     eax, 6
;     jnz     .Skip6
;     add     dword[y], ecx 
;     add     dword[z], ecx 
;     stdcall Field.GenBlocks, [x], [y], [z]
;.Skip6:
;     cmp     eax, 7
;     jl      .SkipSetOres
;     add     dword[z], ecx
;     stdcall Field.GenBlocks, [x], [y], [z]
;
;.SkipSetOres:
    pop     dword[z] dword[y] dword[x]
     mov     ecx, dword[len]  
.SetAirX: 
     mov     eax, [x]
     add     eax, ecx
      
     push    ecx
     mov     ecx, dword[len]

.SetAirY:      
     mov     ebx, [y]
     add     ebx, ecx
     
     push    ecx
     mov     ecx, dword[len]
.SetAirZ:
     mov     edx, [z]
     add     edx, ecx
                        
     push    eax ebx edx ecx
     stdcall Field.GetBlockIndex, eax, ebx, edx
     xchg    esi, eax
     pop     ecx edx ebx eax
     
;     cmp     esi, Block.Air
;     jz     .SkipSetBlock
;     
;     cmp     esi, Block.Water
;     jz     .SkipSetBlock 
               
     stdcall Field.SetBlockIndex, eax, ebx, edx, Block.Air
     
.SkipSetBlock:
     loop    .SetAirZ
     pop     ecx
     loop    .SetAirY
     pop     ecx
     loop    .SetAirX     
          
.Finish:
    ret
endp

proc Field.GenBlocks uses eax ebx ecx edx, x, y, z
     locals
         nX   dd ?
         nY   dd ?
         nZ   dd ?
         size dd 3
     endl
         
.SetOre:
     mov     ebx, Block.CoalOre
     mov     ecx, [size]
.IterateX:
     mov     eax, [x]
     add     eax, ecx
     mov     [nX], eax
     
     push    ecx
     mov     ecx, [size]
.IterateY:
     mov     eax, [y]
     add     eax, ecx
     mov     [nY], eax
     
     push    ecx
     mov     ecx, [size]
.IterateZ:
     mov     eax, [z]
     add     eax, ecx
     mov     [nZ], eax

     stdcall Random.GetInt, 0, 100
     cmp     eax, 25
     jl      .SkipSet

     mov     eax, [nX]
     cmp     eax, [Field.Length]
     jnl     .SkipSet
     mov     eax, [nY]
     cmp     eax, [Field.Length]
     jnl     .SkipSet
     mov     eax, [nZ]
     cmp     eax, [Field.Height]
     jnl     .SkipSet 
     
;     push    eax edx ebx
;     stdcall Field.GetBlockIndex, eax, ebx, edx  
;     mov     esi, eax
;     pop     ebx edx ex  
;     cmp     eax, Block.Air
;     jz      .SkipSetBlock
;     cmp     eax, Block.Water
;     jz      .SkipSetBlock    
      
     stdcall Field.SetBlockIndex, [nX], [nY], [nZ], ebx
     
.SkipSet:
     loop    .IterateZ
     pop     ecx
     loop    .IterateY
     pop     ecx
     loop    .IterateX
           
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

proc Field.GenerateClouds uses ebx edi esi edx, power, filename
    locals
        x             dd ?
        y             dd ?
        z             dd ?
        currChanc     dd ?
        _div          dd ?
        _mod          dd ?
        resAddr       dd ?
        sizeX         dd ?
        sizeY         dd ?
        sizeChanc     dd ?
        numChanc      dd ?
    endl
          
     stdcall Random.Initialize
     
     ;stdcall Field.ReadCloudsFromFile, [filename]
     ;cmp     eax, -1
     ;jnz     .Finish
     
     invoke GetProcessHeap
     mov    [Field.hHeap], eax
     xor    edx, edx
     mov    eax, 1
     mov    cl, byte[power]
     shl    eax, cl
     inc    eax
     mov    dword[sizeX], eax
     mov    dword[sizeY], eax
     
     mov    dword[Field.SkyLength], eax
     mov    dword[Field.SkyWidth], eax
    
     xor    edx, edx
     mov    eax, [sizeX]
     mul    dword[sizeY]
     
     invoke HeapAlloc, [Field.hHeap], HEAP_ZERO_MEMORY, eax
     mov    [resAddr], eax
     mov    [Field.Sky], eax
     
     xor   edx, edx     
     mov   eax, [power]
     mul   dword[power]
     mov   dword[numChanc], eax
    
     xor   edx, edx
     mov   eax, [sizeX]
     div   dword[power]
     mov   dword[sizeChanc], eax
        
     mov     ecx, 0
.IterateChancs:
     push   ecx
     mov    [currChanc], ecx
     
     stdcall Random.GetInt, 1, 10
     mov    ecx, eax
.GenerateClouds:
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
     
     stdcall Random.GetInt, 0, 13
     add    eax, 1
          
     cmp    eax, 1
     jnz    .Skip1
     stdcall Field.SetCloud, [x], [y], [z], Field.Cloud1, [sizeChanc], [sizeChanc]
     
.Skip1:
     cmp    eax, 2
     jnz    .Skip2
     stdcall Field.SetCloud, [x], [y], [z], Field.Cloud2, [sizeChanc], [sizeChanc]
     
.Skip2:
     cmp    eax, 3
     jnz    .Skip3
     stdcall Field.SetCloud, [x], [y], [z], Field.Cloud3, [sizeChanc], [sizeChanc]
     
.Skip3:
     cmp    eax, 4
     jnz    .Skip4
     stdcall Field.SetCloud, [x], [y], [z], Field.Cloud4, [sizeChanc], [sizeChanc]
     
.Skip4:
     cmp    eax, 5
     jnz    .Skip5
     stdcall Field.SetCloud, [x], [y], [z], Field.Cloud5, [sizeChanc], [sizeChanc]
     
.Skip5:
     cmp    eax, 6
     jnz    .Skip6
     stdcall Field.SetCloud, [x], [y], [z], Field.Cloud6, [sizeChanc], [sizeChanc]
     
.Skip6:
     cmp    eax, 7
     jnz    .Skip7
     stdcall Field.SetCloud, [x], [y], [z], Field.Cloud7, [sizeChanc], [sizeChanc]

.Skip7:
     cmp    eax, 8
     jnz    .Skip8
     stdcall Field.SetCloud, [x], [y], [z], Field.Cloud8, [sizeChanc], [sizeChanc]
     
.Skip8:
     cmp    eax, 9
     jnz    .Skip9
     stdcall Field.SetCloud, [x], [y], [z], Field.Cloud9, [sizeChanc], [sizeChanc]
     
.Skip9:
     cmp    eax, 10
     jnz    .Skip10
     stdcall Field.SetCloud, [x], [y], [z], Field.Cloud10, [sizeChanc], [sizeChanc]
     
.Skip10:
     cmp    eax, 11
     jnz    .Skip11
     stdcall Field.SetCloud, [x], [y], [z], Field.Cloud11, [sizeChanc], [sizeChanc]
     
.Skip11:
     cmp    eax, 12
     jnz    .Skip12
     stdcall Field.SetCloud, [x], [y], [z], Field.Cloud12, [sizeChanc], [sizeChanc]
     
.Skip12:
     cmp    eax, 13
     jnz    .Skip13
     stdcall Field.SetCloud, [x], [y], [z], Field.Cloud6, [sizeChanc], [sizeChanc]
     
.Skip13:

.Continue:
    pop    ecx
    dec    ecx
    cmp    ecx, 1
    jnl    .GenerateClouds
    
    pop    ecx
    inc    ecx
    
    ;
    ;cmp     ecx, 64
    ;
    cmp    ecx, dword[numChanc]
    jl     .IterateChancs    

.Finish:
     mov    dword[Field.IsCloudsGenerated], TRUE
     mov    eax, [resAddr]
     ret
endp

proc Field.SetCloud uses edi esi ecx ebx, x, y, z, addres, sizeX, sizeY
     locals
         newX  dd ?
         newY  dd ?
     endl
     mov     dword[newX], 0
.IterateX:
     mov     dword[newY], 0
.IterateY:
     mov     eax, [x]
     add     eax, [newX]
     cmp     eax, [Field.SkyLength]
     jnl     .Continue

     mov     ecx, [y]
     add     ecx, [newY]
     cmp     ecx, [Field.SkyLength]
     jnl     .Continue
     
     xor     edx, edx     
     mul     dword[Field.SkyLength]
     mov     edi, eax
     add     edi, ecx
     add     edi, [Field.Sky]
     
     xor     edx, edx
     mov     eax, [newX]
     mul     dword[Field.CloudLength]
     add     eax, [newY]
     add     eax, [addres]
     
     cmp     byte[eax], 0
     jz      .Continue 
     
     mov     byte[edi], 1

.Continue:
     inc     dword[newY]
     mov     eax, [Field.CloudLength]
     cmp     dword[newY], eax
     jl      .IterateY
     
     inc     dword[newX]
     mov     eax, [Field.CloudLength]
     cmp     dword[newX], eax
     jl      .IterateX
     
.Finish:
     ret
endp


proc Field.GenerateOre uses eax ebx edx esi edi, sizeChanc, numChanc, power
    locals
        x             dd ?
        y             dd ?
        z             dd ?
        currChanc     dd ?
        _div          dd ?
        _mod          dd ?
    endl
    
    mov     ecx, 0
.IterateChancs:
    push   ecx
    mov    [currChanc], ecx
    mov    ecx, [sizeChanc]
    shl    ecx, 1
.Skip123:
    stdcall Random.GetInt, 1, ecx
    mov    ecx, eax
.GenerateOre:
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
    
    mov     eax, [Field.Height]
    shr     eax, 1
    stdcall Random.GetInt, 0, eax 
    mov     [z], eax 
    
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
    
    stdcall Random.GetInt, 0, 4
    inc     eax
    
    cmp     eax, 1
    jnz     .Skip1
    stdcall Field.Ore, [x], [y], MAX_Z_COAL, Block.CoalOre 
.Skip1:

    cmp     eax, 2
    jnz     .Skip2
    stdcall Field.Ore, [x], [y], MAX_Z_IRON, Block.IronOre 
.Skip2:    

    cmp     eax, 3
    jnz     .Skip3
    stdcall Field.Ore, [x], [y], MAX_Z_GOLD, Block.GoldOre 
.Skip3:    

    cmp     eax, 4
    jnz     .Skip4
    stdcall Field.Ore, [x], [y], MAX_Z_DIAMOND, Block.DiamondOre 
.Skip4:      
          
.Continue:
    pop    ecx
    dec    ecx
    cmp    ecx, 1
    jz     .GenerateOre
    
    pop    ecx
    inc    ecx
        
    cmp    ecx, [numChanc]
    jl     .IterateChancs  

.Finish:
     ret
endp



proc Field.Ore uses eax ebx ecx edx, x, y, maxPosZ, typeOre
     locals
         nX   dd ?
         nY   dd ?
         nZ   dd ?
         z    dd ?
         size dd 3
     endl
     
     mov     ecx, 200
.GenZ:
     stdcall Random.GetInt, 0, [maxPosZ]
     mov     dword[z], eax
     
     stdcall Field.GetBlockIndex, [x], [y], [z]
     cmp     eax, Block.Stone
     jz      .Continue
     jmp     .SetOre


.Continue:
     loop     .GenZ

.SetOre:
     stdcall Field.GetBlockIndex, [x], [y], [z]
     cmp     eax, Block.Air
     jz      .Skip1
.Skip1:
     cmp     eax, Block.Water
     jz      .Finish

     mov     ebx, [typeOre]
     mov     ecx, [size]
.IterateX:
     mov     eax, [x]
     add     eax, ecx
     mov     [nX], eax
     
     push    ecx
     mov     ecx, [size]
.IterateY:
     mov     eax, [y]
     add     eax, ecx
     mov     [nY], eax
     
     push    ecx
     mov     ecx, [size]
.IterateZ:
     mov     eax, [z]
     add     eax, ecx
     mov     [nZ], eax

     stdcall Random.GetInt, 0, 100
     cmp     eax, 25
     jl      .SkipSet

     stdcall Field.SetBlockIndex, [nX], [nY], [nZ], ebx
     
.SkipSet:
     loop    .IterateZ
     pop     ecx
     loop    .IterateY
     pop     ecx
     loop    .IterateX
           
.Finish:
     ret
endp 

proc Field.GetAllWorlds uses edx edi esi, pRes
     locals
         fileCount dd 0
         hHeap     dd ?
     endl
     
     invoke GetProcessHeap
     mov    [hHeap], eax
    
     invoke HeapAlloc, eax, HEAP_ZERO_MEMORY, 100*4
     mov    [Field.NameFiles], eax
    
     invoke FindFirstFile, Field.PathToWorldDir, Field.FindFileData
     mov    [Field.hFind], eax
     cmp    eax, INVALID_HANDLE_VALUE
     jz     .Error
     
     mov    ecx, 0
.GetFiles:    
     mov    eax, [Field.FindFileData + WIN32_FIND_DATA.dwFileAttributes]
     test   eax, FILE_ATTRIBUTE_DIRECTORY
     jnz    .NotDirectory
    
     invoke lstrlen, Field.FindFileData.cFileName
     
     invoke HeapAlloc, [hHeap], HEAP_ZERO_MEMORY, eax
    
     mov    ecx, [fileCount]
     mov    edi, [Field.NameFiles]
     mov    [edi + ecx*4], eax
     invoke lstrcpy, eax, Field.FindFileData.cFileName
     inc    dword[fileCount]
.NotDirectory:
     invoke FindNextFile, [Field.hFind], Field.FindFileData
     cmp    eax, 0
     jz     .Finish
     jmp    .GetFiles     

     jmp    .Finish
.Error:
     mov    ecx, 0
     mov    eax, -1
.Finish:
     mov    edi, [pRes]
     mov    eax, [Field.NameFiles]
     mov    [edi], eax
     invoke FindClose, [Field.hFind]
     mov    ecx, [fileCount]
     ret
endp

proc Generating.Init
    invoke GetProcessHeap
    xchg   eax, ebx
    
    invoke HeapAlloc, ebx, HEAP_ZERO_MEMORY, 1025*1025*150
    mov   [Field.Blocks], eax
    
    invoke HeapAlloc, ebx, HEAP_ZERO_MEMORY, 1025*1025*4
    mov    [Field.Matrix], eax
    
.Finish:
     ret
endp


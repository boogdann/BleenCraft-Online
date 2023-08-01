proc Blocks.GetDestroyTime uses edi edx, IndexBlock: word, IndexTool: word
    mov    eax, Blocks.START_DESTROY_TIME

;   edi    -   destroyIndex of block with IndexBlock
;   ebx    -   tool index
    movzx  edi, word[IndexBlock]
    movzx  edx, word[IndexTool]

    cmp    word[Blocks.DestoyIndex + edi], Blocks.MIN_TIME
    jz     .MinTime

    cmp    word[Blocks.DestoyIndex + edi], Blocks.INDERSTRUCTIBLE
    jz     .Indestructible

    cmp    edx, Tools.PICKAXE
    jnz    .Skip1
    cmp    word[Blocks.DestoyIndex + edi], Blocks.FASTER_PICKAXE
    jz     .Faster 

.Skip1:         
    cmp    edx, Tools.AXE
    jnz    .Skip2
    cmp    word[Blocks.DestoyIndex + edi], Blocks.FASTER_AXE
    jz     .Faster

.Skip2:
    cmp    edx, Tools.SHOVEL
    jnz    .Skip3
    cmp    word[Blocks.DestoyIndex + edi], Blocks.FASTER_SHOVEL
    jz     .Faster

.Skip3:
    jmp     .Finish

.Faster: 
    shr     eax, 1
    jmp     .Finish

.MinTime:    
    mov     eax, 0
    jmp     .Finish

.Indestructible:
    mov    eax, 429496700 
.Finish:
    ret
endp

proc Blocks.GetTextureHandle Index: word
    movzx  eax, word[Index]
    cmp    word[Index], 256
    jl     .GetTextureHandleObject 
    stdcall Blocks.GetTextureHandleBlock, eax
    jmp    .Finish

.GetTextureHandleObject:
    stdcall Blocks.GetTextureHandleObject, eax

.Finish:
    ret
endp

proc Blocks.GetTextureHandleBlock uses edi, Index: word
    movzx  edi, word[Index] 
    add    edi, Blocks.TextureAdresses 
    mov    eax, [edi]

.Finish:
    ret
endp

proc Blocks.GetTextureHandleObject uses edi, Index: word
    movzx  edi, word[Index]
    sub    edi, 256
    add    edi, Tools.TextureAdresses 
    mov    eax, [edi]

.Finish:
    ret
endp
   

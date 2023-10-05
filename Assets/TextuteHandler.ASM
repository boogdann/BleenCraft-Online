 proc gf_LoadTextures uses esi edi
        mov     esi, TextureHandles
        mov     edi, TextureNames

.Scan:
        movzx   eax, byte[edi]
        cmp     eax, 0
        je      .Return

        stdcall gf_UploadTexture, edi, esi 
        add     esi, 4

        mov     al, 0
        mov     ecx, 0xFFFFFFFF
        repne   scasb
        jmp     .Scan

.Return:
        ret
 endp
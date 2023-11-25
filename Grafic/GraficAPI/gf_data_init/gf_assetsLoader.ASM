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
 
 
  proc gf_LoadAddictionalTextures uses esi edi
        mov     esi, AddictionalTextureHandles
        mov     edi, AddictionalTextureNames

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
 
 
  proc gf_LoadObjs uses esi edi
        mov     esi, ObjectsHandles
        mov     edi, ObjectsNames

.Scan:
        movzx   eax, byte[edi]
        cmp     eax, 0
        je      .Return

        stdcall gf_UploadObj3D, edi, esi
        add     esi, 8

        mov     al, 0
        mov     ecx, 0xFFFFFFFF
        repne   scasb
        jmp     .Scan

.Return:
        ret
 endp
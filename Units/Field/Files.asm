proc Field.ReadFromFiles uses ebx edi esi ecx, filename

     ; aiaaaeou gaciagu
     stdcall Field.ReadFromFile, Field.Length, Field.Width, Field.Height, [filename]
     cmp     eax, -1
     jz      .Error
     mov     [Field.Blocks], edx
     
.Finish:
     xor     eax, eax
.Error:
     ret
endp   

proc Field.SaveInFileWorld uses ebx edi esi ecx eax edx, addres, sizeX, sizeY, sizeZ, size, filename
     locals
         hFile dd ?
         left  dd ?
     endl     
     invoke CreateFile, [filename], GENERIC_WRITE, FILE_SHARE_READ, 0,\
            CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
     mov    [hFile], eax
  
     mov     eax, [sizeX]
     mov     [Field.FileBuffer], eax
     mov     eax, [sizeY]
     mov     [Field.FileBuffer+4], eax
     mov     eax, [sizeZ]
     mov     [Field.FileBuffer+8], eax  
     invoke  WriteFile, [hFile], Field.FileBuffer, \
             12, Field.WrittenBytes, 0
  
     mov     eax, [size]
     mov     [Field.FileBuffer], eax
     invoke  WriteFile, [hFile], Field.FileBuffer, \
             4, Field.WrittenBytes, 0      
       
     mov     edi, [addres]
     mov     ecx, 0
;.IterateData:
;     cmp     ecx, [size]
;     jnl     .Finish
;
;
;     mov     [left], ecx     ; left
;     movzx   ebx, byte[edi]  ; currIdx
;     
;.FindCommonNumbers:
;     cmp     ecx, [size]
;     jnl     .EndFindCommonNumbers
;     
;     movzx   eax, byte[edi]
;     cmp     eax, ebx
;     jnz     .EndFindCommonNumbers
;     
;     inc     ecx
;     inc     edi
;     
;     cmp     ecx, [size]
;     jnl     .Finish
;     
;     jmp     .FindCommonNumbers
;     
;.EndFindCommonNumbers:
;     mov     edx, ecx
;     sub     edx, dword[left]
;     
;     mov     byte[Field.FileBuffer+4], bl
;     mov     dword[Field.FileBuffer], edx
;     

;     add     edi, edx

;     
;     push    ecx edx ebx
;     invoke  WriteFile, [hFile], Field.FileBuffer, \
;             [Field.SizeBuffer], Field.WrittenBytes, 0 
;     pop     ebx edx ecx
;     
;     cmp     ecx, [size]
;     jnl     .Finish
;
;    jmp .IterateData

     mov     edi, [addres]
     mov     ecx, [size]
.IterateData:
     mov     al, byte[edi]
     mov     ebx, ecx
     repz    scasb
     dec     edi
     inc     ecx

     sub     ebx, ecx
     mov     byte[Field.FileBuffer+4], al
     mov     dword[Field.FileBuffer], ebx        

      push    ecx edx ebx
      invoke  WriteFile, [hFile], Field.FileBuffer, \
              [Field.SizeBuffer], Field.WrittenBytes, 0 
      pop     ebx edx ecx
      cmp     ecx, 1
      ja     .IterateData
      
.Finish:
     invoke CloseHandle, [hFile]
    
     ret
endp 

proc Field.ReadFromFile uses ebx edi esi ecx, pSizeX, pSizeY, pSizeZ, filename
     locals
         hFile   dd ?
         hHeap   dd ?
         left    dd ?
         address dd ?
     endl
     invoke CreateFile, [filename], GENERIC_READ, FILE_SHARE_READ, 0,\
            OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
     mov    [hFile], eax
     
     cmp    eax, INVALID_HANDLE_VALUE   
     jz     .Error
     
     invoke GetProcessHeap
     mov    [hHeap], eax
     
     invoke ReadFile, [hFile], Field.FileBuffer, 16, 0, 0
     mov    eax, [pSizeX]
     mov    edx, [Field.FileBuffer]
     mov    [eax], edx
     mov    eax, [pSizeY]
     mov    edx, [Field.FileBuffer+4]
     mov    [eax], edx
     mov    eax, [pSizeZ]
     mov    edx, [Field.FileBuffer+8]
     mov    [eax], edx
          
     mov    eax, [Field.FileBuffer+12]
          
     invoke HeapAlloc, [hHeap], HEAP_ZERO_MEMORY, eax
     mov    [address], eax
     
     mov    ebx, 0
     mov    edi, eax
.ReadLoop:
     push   edi ecx
     invoke ReadFile, [hFile], Field.FileBuffer, [Field.SizeBuffer], Field.WrittenBytes, 0
     pop    ecx edi
     cmp    eax, 0
     jle     .Error
     
     cmp    [Field.WrittenBytes], 0
     jz     .Error 
     
     mov    ecx, [Field.FileBuffer]
     mov    al, byte[Field.FileBuffer+4]
     ;
     add    ebx, ecx
     ;
     rep    stosb
     
     jmp    .ReadLoop
     xor    eax, eax
     jmp    .Finish

.Error:
     mov    eax, -1
.Finish:
     push   eax
     invoke CloseHandle, [hFile]
     mov    edx, [address]
     pop    eax
     ret
endp 
proc Field.SaveInFileWorld uses ebx edi esi ecx eax, addres, size, filename
     locals
         hFile dd ?
         left  dd ?
     endl     
     invoke CreateFile, [filename], GENERIC_WRITE, FILE_SHARE_READ, 0,\
            CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
     mov    [hFile], eax
  
     mov     eax, [size]
     mov     [Field.FileBuffer], eax
     invoke  WriteFile, [hFile], Field.FileBuffer, \
             4, Field.WrittenBytes, 0      
        
     mov     edi, [addres]
     mov     ecx, 0
.IterateData:
     cmp     ecx, [size]
     jnl     .Finish


     mov     [left], ecx        ; left
     movzx   ebx, byte[edi]  ; currIdx
     
.FindCommonNumbers:
     cmp     ecx, [size]
     jnl     .EndFindCommonNumbers
     
     movzx   eax, byte[edi]
     cmp     eax, ebx
     jnz     .EndFindCommonNumbers
     
     inc     ecx
     inc     edi
     jmp     .FindCommonNumbers
     
.EndFindCommonNumbers:
     mov     edx, ecx
     sub     edx, dword[left]
     
     mov     dword[Field.FileBuffer], edx
     mov     dword[Field.FileBuffer+4], ebx
     
     invoke  WriteFile, [hFile], Field.FileBuffer, \
             8, Field.WrittenBytes, 0 
      
     jmp .IterateData
.Finish:
     invoke CloseHandle, [hFile]
    
     ret
endp 
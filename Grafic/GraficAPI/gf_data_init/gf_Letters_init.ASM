proc gf_UploadLetters uses esi edi, tx_Name, Handle 
    
    invoke glGenTextures, 1, gf_tx_handle
    invoke glBindTexture, GL_TEXTURE_2D, [gf_tx_handle] 
    
    stdcall gf_GetLettersData, [tx_Name]   
    mov [LettersWidth], ecx 
    mov [LettersHeight], eax                                    
                                        
    invoke glTexImage2D, GL_TEXTURE_2D, 0, GL_RGBA, ecx, eax, 0, GL_RGBA, GL_UNSIGNED_BYTE, [gf_texture_adress]
    invoke glGenerateMipmap, GL_TEXTURE_2D                                 
    
    mov eax, [gf_tx_handle]
    mov esi, [Handle]
    mov [esi], eax

    ret
endp


proc gf_GetLettersData, tx_Name

  locals 
    hFile                dd       ?
    
    height               dd       ?
    width                dd       ?
    BytesCount           dd       ?
  endl
  
    mov esi, GF_TEXTURE_PATH
    mov edi, gf_temp_path
    @@:
      mov al, byte[esi] 
      mov byte[edi], al
      inc esi
      inc edi
    cmp byte[esi], 0
    jnz @B
    mov esi, [tx_Name]
    @@:
    mov al, byte[esi] 
      mov byte[edi], al
      inc esi
      inc edi
    cmp byte[esi], 0
    jnz @B
    mov byte[edi], 0  
  
    ;Открытие файла...
    invoke  CreateFile,  gf_temp_path, GENERIC_READ, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
    mov     [hFile], eax
  
    lea     edi, [height]
    invoke  ReadFile, [hFile], edi, 4, 0, 0
    
    lea     edi, [width]
    invoke  ReadFile, [hFile], edi, 4, 0, 0 
    
    lea     edi, [BytesCount]
    invoke  ReadFile, [hFile], edi, 4, 0, 0 
    
  
    invoke  HeapAlloc, [gf_memHeap], 0, [BytesCount]
    mov [gf_texture_adress], eax
                                              
    invoke  ReadFile, [hFile], [gf_texture_adress], [BytesCount], 0, 0
    invoke CloseHandle, [hFile]
  
    ;return:
    mov ecx, [width]
    mov eax, [height]

    ret
endp
proc gf_UploadTexture uses esi edi, tx_Name, Handle 
    
    invoke glGenTextures, 1, gf_tx_handle
    invoke glBindTexture, GL_TEXTURE_2D, [gf_tx_handle] 
    
    stdcall gf_GetTextureData, [tx_Name]
    
    invoke glTexImage2D, GL_TEXTURE_2D, 0, GL_RGB, eax, ecx, 0, GL_RGB, GL_UNSIGNED_BYTE, [gf_texture_adress]
    invoke glGenerateMipmap, GL_TEXTURE_2D                                 
    
    mov eax, [gf_tx_handle]
    mov esi, [Handle]
    mov [esi], eax

    ret
endp


proc gf_GetTextureData, tx_Name

  locals 
    hFile                dd       ?
    rowBytesCount        dd       ?
    rowsCount            dd       ?
    tmpRowAdress         dd       ?
    spaceCount           dw       ?
    pixelsCount          dw       ?
    pixel                db       ?, ?, ?
    Permission           dd       10
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
  
    lea     edi, [rowBytesCount]
    invoke  ReadFile, [hFile], edi, 4, 0, 0
    
    lea     edi, [rowsCount]
    invoke  ReadFile, [hFile], edi, 4, 0, 0   


    ;Выделить память rowBytesCount * (rowsCount * Permission)
    mov eax, [Permission]
    imul eax, [rowBytesCount]
    imul eax, [rowsCount]
    invoke  HeapAlloc, [gf_memHeap], 0, eax
    mov [gf_texture_adress], eax
    
    invoke  HeapAlloc, [gf_memHeap], 0, [rowBytesCount]
    mov [tmpRowAdress], eax
    
    ;загружаем данные текструры (tx_Name) по адрессу [gf_texture_adress]
    ;Цикл считывание строк и записи x50 в [gf_texture_adress]
    mov ecx, [rowsCount]
    .RowWriteLoop:
         push ecx
         ;1. GetRowData
         ;2. Write x50 row in texture
         mov esi, [tmpRowAdress]
        
         lea     edi, [spaceCount]
         invoke  ReadFile, [hFile], edi, 2, 0, 0
         ;write space [spaceCount] * 50 (3)
         mov eax, [Permission] 
         movzx edi, [spaceCount]
         imul eax, edi
         mov edx, eax
         .WriteLoopSpace_1:
         cmp edx, 0
         jz @F
              mov byte[esi + 0], 0
              mov byte[esi + 1], 0
              mov byte[esi + 2], 0
              add esi, 3
         dec edx
         jmp .WriteLoopSpace_1
         @@:
         
         lea     edi, [pixelsCount]
         invoke  ReadFile, [hFile], edi, 2, 0, 0
         movzx ebx, [pixelsCount]
         .PixelRW:
         cmp ebx, 0
         jz @F
             lea     edi, [pixel]
             invoke  ReadFile, [hFile], edi, 3, 0, 0
             mov edx, [Permission]
             .WriteLoopPx:
                  mov al, [pixel + 0]
                  mov byte[esi + 0], al
                  mov al, [pixel + 1]
                  mov byte[esi + 1], al
                  mov al, [pixel + 2]
                  mov byte[esi + 2], al
                  add esi, 3
             dec edx
             cmp edx, 0
             jnz .WriteLoopPx
         dec ebx
         jmp .PixelRW
         @@:
         
         
         lea     edi, [spaceCount]
         invoke  ReadFile, [hFile], edi, 2, 0, 0
         ;write space [spaceCount] * 50 (3)
         mov eax, [Permission] 
         movzx edi, [spaceCount]
         imul eax, edi
         mov edx, eax
         .WriteLoopSpace_2:
         cmp edx, 0
         jz @F
              mov byte[esi + 0], 0
              mov byte[esi + 1], 0
              mov byte[esi + 2], 0
              add esi, 3
         dec edx
         jmp .WriteLoopSpace_2
         @@:   
           
         ;Row is ready
         ;Copy x50 in [gf_texture_adress] 
         pop ecx
         push ecx
         mov eax, [rowsCount]
         sub eax, ecx
         mov ecx, eax
         
         mov edi, [gf_texture_adress]  
         mov eax, [Permission]
         imul eax, ecx
         imul eax, [rowBytesCount]
         add edi, eax
         
         ;mov edi, [gf_texture_adress]  
         
         mov eax, [Permission]
         .WriteRowsLoop:
             mov esi, [tmpRowAdress]
             ;Copy row loop
             mov edx,[rowBytesCount]
             .CopyRowLoop:
                 ;movsb
                 ;mov byte[edi], $AA
                 push eax
                    mov al, byte[esi]
                    mov byte[edi], al  
                 pop eax
                 inc edi
                 inc esi
             dec edx
             cmp edx, 0
             jnz .CopyRowLoop
             
         dec eax
         cmp eax, 0
         jnz .WriteRowsLoop
         
         pop ecx 
    dec ecx
    cmp ecx, 0
    jnz .RowWriteLoop
    
  
    invoke CloseHandle, [hFile]
  
    ;return:
    mov eax, [rowBytesCount]   
    xor edx, edx     
    mov ebx, 3     
    idiv ebx   
    mov ecx, eax
    mov eax, [rowsCount]
    imul eax, [Permission]

    ret
endp
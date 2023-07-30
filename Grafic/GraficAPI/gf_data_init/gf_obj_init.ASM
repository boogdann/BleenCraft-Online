proc gf_UploadObj3D uses esi, obj_name, obj_Handle

  locals
    BytesCount   dd   ? 
  endl

  ;Получение данных
  stdcall gf_GetObj3D_data, [obj_name]
  
  invoke glGenBuffers, 3, VBOhandles
  
  mov eax, 12
  imul dword [gf_VertexCount]
  mov [BytesCount], eax
  
  invoke glBindBuffer, GL_ARRAY_BUFFER, [VBOhandles]
  invoke glBufferData, GL_ARRAY_BUFFER, [BytesCount], [gf_VertexArrayAdress], GL_STATIC_DRAW
  invoke glBindBuffer, GL_ARRAY_BUFFER, [VBOhandles + 4]
  invoke glBufferData, GL_ARRAY_BUFFER, [BytesCount], [gf_NormalArrayAdress], GL_STATIC_DRAW
  mov eax, 8
  imul dword [gf_VertexCount]
  mov [BytesCount], eax
  invoke glBindBuffer, GL_ARRAY_BUFFER, [VBOhandles + 8]
  invoke glBufferData, GL_ARRAY_BUFFER, [BytesCount], [gf_TextCordArrayAdress], GL_STATIC_DRAW 
  
  invoke glGenVertexArrays, 1, VAOhandle
  invoke glBindVertexArray, [VAOhandle]
  
  invoke glEnableVertexAttribArray, 0
  invoke glEnableVertexAttribArray, 1
  invoke glEnableVertexAttribArray, 2
  
  invoke glBindBuffer, GL_ARRAY_BUFFER, [VBOhandles]
  invoke glVertexAttribPointer, 0, 3, GL_FLOAT, 0, 0, 0
  
  invoke glBindBuffer, GL_ARRAY_BUFFER, [VBOhandles + 4]
  invoke glVertexAttribPointer, 1, 3, GL_FLOAT, 0, 0, 0
  
  invoke glBindBuffer, GL_ARRAY_BUFFER, [VBOhandles + 8]
  invoke glVertexAttribPointer, 2, 2, GL_FLOAT, 0, 0, 0
  
  ;Return:
  ;Return Handle
  mov eax, [VAOhandle]
  mov esi, [obj_Handle]
  mov dword[esi], eax
  ;Return VertexesCount
  mov eax, [gf_VertexCount]
  mov dword[esi + 4], eax
  
  ret
endp


;Мне конечно стыдно за эту процедуру (Но мне очень лень её менять)
proc gf_GetObj3D_data uses edi, obj_name 

    locals
        hFile     dd      ?  
        len       dd      ?
        byteCount dd      ?
        vertexes  dd      ?
        normals   dd      ?
        textureCoords dd  ?
        fragmentBytesCount dd ? 
        fragmentCount dd  ?
        fragments      dd ?
        frVecCount     dw ?
        texturePointer  dd ?
        vertexValue     dd  12
        BLmod           dd   1 ;1- 16bit / - 8bit
        IndVertexB      dd   6 ;/6
    endl
    
  mov esi, [obj_name]
  cmp byte[esi], 'L'
  jnz @F
    mov [BLmod], 0
    mov [IndVertexB], 3
  @@: 
  
  mov esi, GF_OBJ_PATH
  mov edi, gf_temp_path
  @@:
    mov al, byte[esi] 
    mov byte[edi], al
    inc esi
    inc edi
  cmp byte[esi], 0
  jnz @B
  mov esi, [obj_name]
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
  
  ;Read vertexCount
  lea     edi, [len]
  invoke  ReadFile, [hFile], edi, 4, 0, 0
  ;Create vertex buffer 
  mov eax, 12
  imul dword [len]
  mov [byteCount], eax
  invoke  HeapAlloc, [hHeap], 0, [byteCount]
  mov [vertexes], eax
  ;Read vertexes
  invoke  ReadFile, [hFile], [vertexes], [byteCount], 0, 0 
  
  ;Read normalCount
  lea     edi, [len]
  invoke  ReadFile, [hFile], edi, 4, 0, 0
  ;Create mormal buffer 
  mov eax, 12
  imul dword [len]
  mov [byteCount], eax
  invoke  HeapAlloc, [hHeap], 0, [byteCount]
  mov [normals], eax
  ;Read mormals
  invoke  ReadFile, [hFile], [normals], [byteCount], 0, 0 
  
  ;Read textureCordCount
  lea     edi, [len]
  invoke  ReadFile, [hFile], edi, 4, 0, 0
  ;Create textureCords buffer 
  mov eax, 8
  imul dword [len]
  mov [byteCount], eax
  invoke  HeapAlloc, [hHeap], 0, [byteCount]
  mov [textureCoords], eax
  ;Read textureCords
  invoke  ReadFile, [hFile], [textureCoords], [byteCount], 0, 0 
  
  ;Read gf_VertexCount
  lea     edi, [gf_VertexCount]
  invoke  ReadFile, [hFile], edi, 4, 0, 0
   
  ;Read fragmentBytesCount
  lea     edi, [fragmentBytesCount]
  invoke  ReadFile, [hFile], edi, 4, 0, 0

  ;Read fragmentCount
  lea     edi, [fragmentCount]
  invoke  ReadFile, [hFile], edi, 4, 0, 0
  ;Create fragments buffer 
  invoke  HeapAlloc, [hHeap], 0, [fragmentBytesCount]
  mov [fragments], eax          
  ;Read fragments
  invoke  ReadFile, [hFile], [fragments], [fragmentBytesCount], 0, 0
  ;Создание буферов
  mov eax, 12
  imul dword [gf_VertexCount] 
  mov  [len], eax  
  ;Буффер вершин
  invoke  HeapAlloc, [hHeap], 0, [len]
  mov [gf_VertexArrayAdress], eax
  ;Буффер нормалей
  invoke  HeapAlloc, [hHeap], 0, [len]
  mov [gf_NormalArrayAdress], eax
  ;Буффер текстурных координат
  mov eax, 8
  imul dword [gf_VertexCount] 
  mov  [len], eax  
  invoke  HeapAlloc, [hHeap], 0, [len]
  mov [gf_TextCordArrayAdress], eax
  
  ;Считывание индексов и преобразование под это всё
  mov ecx, 0
  mov [texturePointer], 0
  
  mov esi, [fragments]
  mov ebx, 0
  .FrLoop:
      ;Количество индексных векторов в фрагменте:
      mov ax, word[esi]
      sub ax, 2
      mov [frVecCount], ax 
      add esi, 2
      .frVecLoop:
          mov edi, esi
          push esi ebx
          
          ;;work with [edi] index !(1)
          ;Copy Vertex
          stdcall CopyVertex, [vertexes], [BLmod]
          ;Copy Normals
          stdcall CopyNormals, [normals], [BLmod]
          ;Copy TextursCoords
          stdcall CopyTextursCoords, [textureCoords], [texturePointer], [BLmod]
          add ecx, 12
          add [texturePointer], 8 
  
          mov eax, [IndVertexB]
          imul word[frVecCount]
          add edi, eax
          ;;work with [edi] index !(2)   
          ;Copy Vertex
          stdcall CopyVertex, [vertexes], [BLmod]  
          ;Copy Normals
          stdcall CopyNormals, [normals], [BLmod]
          ;Copy TextursCoords
          stdcall CopyTextursCoords, [textureCoords], [texturePointer], [BLmod]
          add ecx, 12
          add [texturePointer], 8
          
                  
          add edi, [IndVertexB]
          ;work with [edi] index !(3)
          ;Copy Vertex
          stdcall CopyVertex, [vertexes], [BLmod]  
          ;Copy Normals
          stdcall CopyNormals, [normals], [BLmod]
          ;Copy TextursCoords
          stdcall CopyTextursCoords, [textureCoords], [texturePointer], [BLmod]
          add ecx, 12
          add [texturePointer], 8 
                     
          pop ebx esi
      dec [frVecCount]
      cmp [frVecCount], 0
      jnz .frVecLoop 
      sub esi, 2
  
      movzx eax, word[esi]
      add esi, 2
      mov [len], eax
      mov eax, [IndVertexB]
      imul dword[len]
      add esi, eax 
  inc ebx
  cmp ebx, [fragmentCount]
  jnz .FrLoop
  
  ;Закрытие файла
  invoke  CloseHandle, [hFile]

  ret
endp 



proc CopyVertex, vertexes, mod 
  locals 
    vertexValue     dd  12
  endl
      movzx eax, word[edi] 
      cmp [mod], 1
      jz @F
         movzx eax, byte[edi]
      @@:
      dec eax
      imul dword[vertexValue]
      mov esi, [vertexes]
      add esi, eax   
      mov ebx, [gf_VertexArrayAdress]
      mov eax, dword[esi]
      mov dword[ebx + ecx], eax
      mov eax, dword[esi + 4]
      mov dword[ebx + ecx + 4], eax
      mov eax, dword[esi + 8]
      mov dword[ebx + ecx + 8], eax 
  ret
endp


;With out Tests
proc CopyNormals, normals, mod  
  locals 
    vertexValue     dd  12
  endl  
      movzx eax, word[edi + 4] 
      cmp [mod], 1
      jz @F
         movzx eax, byte[edi + 2]
      @@:
      dec eax
      imul dword[vertexValue]
      mov esi, [normals]
      add esi, eax  
      mov ebx, [gf_NormalArrayAdress]
      mov eax, dword[esi]
      mov dword[ebx + ecx], eax
      mov eax, dword[esi + 4]
      mov dword[ebx + ecx + 4], eax
      mov eax, dword[esi + 8]
      mov dword[ebx + ecx + 8], eax 
  ret
endp

;With out Tests
proc CopyTextursCoords, textureCoords, texturePointer, mod 
  locals 
    vertexValue  dd  8
  endl 
   movzx eax, word[edi + 2] 
   cmp [mod], 1
   jz @F
      movzx eax, byte[edi + 1] 
   @@:
   dec eax
   imul dword[vertexValue]
   mov esi, [textureCoords]
   add esi, eax  
   mov ebx, [gf_TextCordArrayAdress]
   push ecx
     mov ecx, [texturePointer]
     mov eax, dword[esi]
     mov dword[ebx + ecx], eax
     mov eax, dword[esi + 4]
     mov dword[ebx + ecx + 4], eax
   pop ecx
  ret
endp


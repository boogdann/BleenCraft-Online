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
  
  invoke glGenVertexArrays, 1, VAOhandle
  invoke glBindVertexArray, [VAOhandle]
  
  invoke glEnableVertexAttribArray, 0
  
  invoke glBindBuffer, GL_ARRAY_BUFFER, [VBOhandles]
  invoke glVertexAttribPointer, 0, 3, GL_FLOAT, 0, 0, 0
  
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



proc gf_GetObj3D_data, obj_name
  
  ;Открытие файла...
  
  
  ;Return:
  mov [gf_VertexCount], 12
  mov eax, VetexArr
  mov [gf_VertexArrayAdress], eax
  ;mov [gf_NormalArrayAdress], eax
  ;mov [gf_TextCordArrayAdress], eax

  ret
endp 


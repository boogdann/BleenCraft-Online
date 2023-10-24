proc gf_InitShaders

   mov edi, gf_temp_path
   mov esi, GF_PATH
   movzx ecx, byte[GF_PATH_LEN]
   rep movsb
   dec edi
   mov esi, vertexShader_File
   movzx ecx, byte[vertexShader_File_len]
   rep movsb
  
   
   stdcall Glext.LoadShader, gf_temp_path, GL_VERTEX_SHADER
   mov     [gf_vertexShader], eax
   
   mov edi, gf_temp_path
   mov esi, GF_PATH
   movzx ecx, byte[GF_PATH_LEN]
   rep movsb
   dec edi
   mov esi, fragmentShader_File
   movzx ecx, byte[fragmentShader_File_len]
   rep movsb

   stdcall Glext.LoadShader, gf_temp_path, GL_FRAGMENT_SHADER
   mov     [gf_fragmentShader], eax
   
   ;########################
   cmp eax, 0
   jnz @F
     invoke  ExitProcess, 0
   @@:
   ;#######################
   
   stdcall CreateShaderProgram 

  ret
endp


proc CreateShaderProgram
    invoke  glCreateProgram
    mov     [gf_shaderProgram], eax
    
    invoke  glAttachShader, [gf_shaderProgram], [gf_vertexShader]
    invoke  glAttachShader, [gf_shaderProgram], [gf_fragmentShader]
    
    invoke  glLinkProgram, [gf_shaderProgram]
    invoke  glUseProgram, [gf_shaderProgram] 
    
  ret
endp


proc Glext.LoadShader,\
     fileName, shaderType

        locals
                buffer          dd      ?
                shader          dd      ?
                compiled        dd      ?
        endl

        stdcall LoadCodeFromFile, [fileName]
        mov     [buffer], eax

        invoke  glCreateShader, [shaderType]
        mov     [shader], eax
        lea     eax, [buffer]
        invoke  glShaderSource, [shader], 1, eax, 0
        invoke  glCompileShader, [shader]

        invoke  HeapFree, [gf_memHeap], 0, [buffer]

        lea     eax, [compiled]
        invoke  glGetShaderiv, [shader], GL_COMPILE_STATUS, eax

        cmp     [compiled], 0
        je      @F

        mov     eax, [shader]
        jmp     .Return

@@:
        mov     eax, 0

.Return:
        ret
endp


proc LoadCodeFromFile uses edi,\
     fileName

        locals
                hFile   dd      ?
                length  dd      ?
                ;read    dd      ?
                pBuffer dd      ?
        endl

        invoke  CreateFile, [fileName], GENERIC_READ, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
        mov     [hFile], eax

        invoke  GetFileSize, [hFile], 0
        inc     eax
        mov     [length], eax
        invoke  HeapAlloc, [gf_memHeap], 8, [length]
        mov     [pBuffer], eax

        ;lea     edi, [read]
        invoke  ReadFile, [hFile], [pBuffer], [length], 0, 0

        invoke  CloseHandle, [hFile]

        mov     eax, [pBuffer]

        ret
endp
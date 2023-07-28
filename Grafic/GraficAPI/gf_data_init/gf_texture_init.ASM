proc gf_UploadTexture, tx_Name 
    
    invoke glGenTextures, 1, gf_tx_handle
    invoke glBindTexture, GL_TEXTURE_2D, [gf_tx_handle] 
    
    stdcall gf_GetTextureData, [tx_Name]
    
    invoke glTexImage2D, GL_TEXTURE_2D, 0, GL_RGB, 500, 500, 0, GL_BGR, GL_UNSIGNED_BYTE, [gf_texture_adress]
    invoke glGenerateMipmap, GL_TEXTURE_2D
    
    mov eax, [gf_tx_handle]

    ret
endp


proc gf_GetTextureData, tx_Name
    invoke  HeapAlloc, [hHeap], 0, 500 * 500 * 3
    mov [gf_texture_adress], eax
    
    ;Test#######################
    mov ecx, (500 * 500 * 3) - 1
    .wr_loop:
       mov byte[eax + ecx], $FF
    loop .wr_loop
    ;############################
    
    ;загружаем данные текструры (tx_Name) по адрессу [gf_texture_adress]
    
  
    
    ret
endp
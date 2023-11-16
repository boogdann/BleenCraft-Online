;Рендер ландшафта
proc gf_RenderMineLand uses esi edi ebx, LandData, X, Y, Z, PlPos, PlEye, isOnlyWater

    locals
      PlIntPos     dd    ?, ?, ?
      MAX_XYZ      dd    ?, ?, ?
      MIN_XYZ      dd    ?, ?, ?
      ADD_XYZ      dd    ?, ?, ?
      ADD_YZ_L     dd    ?, ?, ?
      tmp          dd    ?
      VertexCount  dd    ?
    endl
  
    cmp [isOnlyWater], 0
    jz @F
       invoke glUniform1f, [gf_aChanel], [gf_WaterAChanel]
       
       lea esi, [gf_MAIN_WaterHandle] ;Water
       invoke glBindVertexArray, [esi]
       
       mov eax, dword[esi + 4]
       mov [VertexCount], eax
       jmp .next
    @@:
    lea esi, [gf_MAIN_CubeHandle]
    invoke glBindVertexArray, [esi]
    mov eax, dword[esi + 4]
    mov [VertexCount], eax
    .next:
     
    ;Ограничение рендера для оптимизации:
    ;[max(posX - GF_BLOCKS_RADIUS, 0):min(posX + GF_BLOCKS_RADIUS, X)]
    ;[max(posZ - GF_BLOCKS_RADIUS, 0):min(posZ + GF_BLOCKS_RADIUS, Y)]
    ;[max(posY - GF_BLOCKS_RADIUS, 0):min(posY + GF_BLOCKS_RADIUS, Z)]
  
    ;Взятие целой позиции:
    ;======================
    mov esi, [PlPos]
    fld dword[esi]
    fistp [PlIntPos]
    fld dword[esi + 4]
    fistp [PlIntPos + 4]
    fld dword[esi + 8]
    fistp [PlIntPos + 8]
    ;=======================
    
    ;==========================
    ;Расчёт MIN_X:
    mov eax, [PlIntPos]
    sub eax, [GF_BLOCKS_RADIUS]
    cmp eax, 0
    jns @F
      mov eax, 0
    @@: 
    cmp eax, [X]
    jl @F
      mov eax, [X]
    @@:
    mov [MIN_XYZ], eax
    ;Расчёт MAX_X:
    mov eax, [PlIntPos]
    add eax, [GF_BLOCKS_RADIUS]
    cmp eax, 0
    jns @F
      mov eax, 0
    @@: 
    cmp eax, [X]
    jl @F
      mov eax, [X]
    @@:
    mov [MAX_XYZ], eax
    mov eax, [X]
    sub eax, [MAX_XYZ]
    mov [ADD_XYZ], eax
    
    ;Расчёт MIN_Y:
    mov eax, [PlIntPos + 8]
    sub eax, [GF_BLOCKS_RADIUS + 4]
    cmp eax, 0
    jns @F
      mov eax, 0
    @@: 
    cmp eax, [Y]
    jl @F
      mov eax, [Y]
    @@:
    mov [MIN_XYZ + 4], eax
    ;Расчёт MAX_Y:
    mov eax, [PlIntPos + 8]
    add eax, [GF_BLOCKS_RADIUS + 4]
    cmp eax, 0
    jns @F
      mov eax, 0
    @@: 
    cmp eax, [Y]
    jl @F
      mov eax, [Y]
    @@:
    mov [MAX_XYZ + 4], eax
    mov eax, [Y]
    sub eax, [MAX_XYZ + 4]
    imul [X]
    mov [ADD_XYZ + 4], eax
    mov eax, [MIN_XYZ + 4]
    imul [X]
    mov [ADD_YZ_L], eax 
    
    ;Расчёт MIN_Z:
    mov eax, [PlIntPos + 4]
    sub eax, [GF_BLOCKS_RADIUS + 8]
    cmp eax, 0
    jns @F
      mov eax, 0
    @@: 
    cmp eax, [Z]
    jl @F
      mov eax, [Z]
    @@:
    mov [MIN_XYZ + 8], eax
    ;Расчёт MAX_Z:
    mov eax, [PlIntPos + 4]
    add eax, [GF_BLOCKS_RADIUS + 8]
    cmp eax, 0
    jns @F
      mov eax, 0
    @@: 
    cmp eax, [Z]
    jl @F
      mov eax, [Z]
    @@:
    mov [MAX_XYZ + 8], eax
    mov eax, [Y]
    sub eax, [MAX_XYZ + 8]
    imul [X]
    imul [Y]
    mov [ADD_XYZ + 8], eax
    mov eax, [MIN_XYZ + 8]
    imul [X]
    imul [Y]
    mov [ADD_YZ_L + 4], eax 
    ;========================
    
    mov esi, [LandData]
    ;Render circle:
    ;==========Z==========
    add esi, [ADD_YZ_L + 4] 
    mov ecx, [MIN_XYZ + 8] 
    .LandRender_z:
    cmp ecx, [MAX_XYZ + 8]
    jz .skip_z
        ;==========Y===========
        add esi, [ADD_YZ_L]
        mov edx, [MIN_XYZ + 4]  
        .LandRender_y:
        cmp edx, [MAX_XYZ + 4]
        jz .skip_y    
            ;========X=========
            add esi, [MIN_XYZ]
            mov ebx, [MIN_XYZ]
            .LandRender_x:  
            cmp ebx, [MAX_XYZ]
            jz .skip_x
                  cmp byte[esi], 0
                  jz @F
                       stdcall gf_render_chank, [isOnlyWater],\
                                                [VertexCount], [X], [Y], [Z]
                  @@:
                  add esi, 1    
            inc ebx
            jmp .LandRender_x
            .skip_x:
            add esi, [ADD_XYZ] 
            ;=================
        inc edx
        jmp .LandRender_y
        .skip_y:
        add esi, [ADD_XYZ + 4]
        ;=====================
    inc ecx
    jmp .LandRender_z
    .skip_z:
    add esi, [ADD_XYZ + 8]
    ;=================
    
    invoke glUniform1f, [gf_aChanel], 1.0
  ret
endp


proc gf_render_chank, isOnlyWater, VertexCount, X, Y, Z
  locals 
    _pos       dd    ?
  endl
  
  ;Расчёт позиции блока
  mov [_pos], ebx
  fild [_pos] 
  fstp [gf_tmp_objPos + 0] 
  mov [_pos], ecx
  fild [_pos] 
  fstp [gf_tmp_objPos + 4] 
  mov [_pos], edx
  fild [_pos] 
  fstp [gf_tmp_objPos + 8] 
  
  ;Проверака на нахождение объкта в видимости:
  stdcall gf_frastrum_check, gf_tmp_objPos 
  cmp eax, 0
  jz .SkipRender 
      
  cmp [isOnlyWater], 0
  jz @F    
    stdcall gf_checkBlockVisible, [X], [Y], [Z], [isOnlyWater] 
    cmp eax, 0
    jz .SkipRender 
  @@:
  
  ;Проверка на существование блока:                    
  cmp [isOnlyWater], 0
  jnz .skip_1
    cmp byte[esi], 255  
    jz .SkipRender
  jmp .skip_2               
  .skip_1: 
  cmp byte[esi], 255 
  jnz .SkipRender
  .skip_2:
  
  ;TextureHandles
  ;Расчёт текстуры по byte[esi] в eax:
  movzx eax, byte[esi]
  dec eax
  imul eax, 4
  add eax, TextureHandles
  cmp eax, tx_EOF
  jl @F
    mov eax, TextureHandles
  @@:
  cmp byte[esi], 255
  jnz @F
    mov eax, tx_Water_Handle
  @@:
  
  push eax ebx ecx edx
  push eax
  invoke glUniform1i, [gf_discardMode], 0
  pop eax
  cmp eax, WithDiskard
  jl @F
      invoke glUniform1i, [gf_discardMode], 1
  @@:
  pop edx ecx ebx eax
  

    

  
  ;Рендер:
  stdcall gf_SimpleObj, gf_tmp_objPos, [VertexCount], [eax]
                       
  .SkipRender:
  ret
endp


proc gf_checkBlockVisible uses esi edi edx, X, Y, Z, isOnlyWater
  
  locals
    sw    dd  ?, ?, ?   
    plane dd  ?
  endl
  
  ;Check 1
  ;ebx - x [x]
  ;ecx - y [z]
  ;edx - z [y]
  ;of block
  
  push edx ebx
  mov eax, [X]
  imul [Y]
  pop ebx edx
  ;y check
  cmp ecx, [Z]
  jz @F
    add esi, eax
    cmp byte[esi], 0
    jz .SkipCheck
    cmp [isOnlyWater], 1
    jz .sk1 
      cmp byte[esi], 255  
      jz .SkipCheck
    .sk1:
    sub esi, eax
  @@:
  cmp ecx, 0
  jz @F
    sub esi, eax
    cmp byte[esi], 0
    jz .SkipCheck
    cmp [isOnlyWater], 1
    jz .sk2 
      cmp byte[esi], 255  
      jz .SkipCheck
    .sk2:
    add esi, eax
  @@:
  cmp [isOnlyWater], 1
  jz .frFalse 
  cmp ebx, [X]
  jz @F
    inc esi        
    cmp byte[esi], 0  
    jz .SkipCheck
    cmp byte[esi], 255  
    jz .SkipCheck
    dec esi
  @@:  
  cmp ebx, 0
  jz @F
    dec esi       
    cmp byte[esi], 0  
    jz .SkipCheck
    cmp byte[esi], 255  
    jz .SkipCheck
    inc esi 
  @@:
    
  cmp edx, [Y]
  jz @F
    add esi, [X]       
    cmp byte[esi], 0  
    jz .SkipCheck
    cmp byte[esi], 255  
    jz .SkipCheck
    sub esi, [X]   
  @@: 
   
  cmp edx, 0
  jz @F
    sub esi, [X]
    cmp byte[esi], 0  
    jz .SkipCheck
    cmp byte[esi], 255  
    jz .SkipCheck
    add esi, [X]
  @@:
   
  jmp .frFalse

  .SkipCheck:
  ;Return:
  mov eax, 1 ;RENDER
  jmp @F
  .frFalse:
    mov eax, 0 ;NO RENDER
  @@:
  
  ret
endp


proc gf_frastrum_check uses esi edi ecx edx, obj_pos
  locals
    distance    dd     ? 
    ObjRadius   dd     -2.0 
  endl

  ;Check frastrum
  lea esi, [gf_frastrum_planes]
  mov edi, [obj_pos]
  
  
  mov ecx, 0
  .CheckLoop:
    stdcall dupVec3, esi, edi
    mov [distance], eax
    fld [distance]
    fadd dword[esi + 12]
    fsub [ObjRadius]
    fistp [distance]
    
    cmp [distance], 0
    jle .frFalse
    add esi, 4 * 4
  inc ecx
  cmp ecx, 5
  jnz .CheckLoop
  

  ;Return:
  mov eax, 1
  jmp @F
  .frFalse:
    mov eax, 0
  @@:

  ret
endp
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
       ;mov esi, [Water]
       ;invoke glBindVertexArray, [esi]
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
                       stdcall gf_render_chank, [isOnlyWater], [VertexCount]
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


proc gf_render_chank, isOnlyWater, VertexCount
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
  
  ;Расчёт текстуры по byte[esi] в eax:
  mov eax, [tx_BOGDANHandle]
  
  ;Рендер:
  stdcall gf_SimpleObj, gf_tmp_objPos, [VertexCount], eax
                       
  .SkipRender:
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
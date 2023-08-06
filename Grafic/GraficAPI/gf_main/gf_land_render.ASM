;������ ���������
proc gf_RenderMineLand uses esi edi ebx, LandData, X, Y, Z, PlPos, PlEye, isOnlyWater

    locals
      PlIntPos   dd    ?, ?, ?
      MAX_XYZ    dd    ?, ?, ?
      MIN_XYZ    dd    ?, ?, ?
      ADD_XYZ    dd    ?, ?, ?
      ADD_YZ_L   dd    ?, ?, ?
      tmp        dd    ?
    endl
  
    cmp [isOnlyWater], 0
    jz @F
       invoke glUniform1f, [gf_aChanel], [gf_WaterAChanel]
    @@:
     
    ;����������� ������� ��� �����������:
    ;[max(posX - GF_BLOCKS_RADIUS, 0):min(posX + GF_BLOCKS_RADIUS, X)]
    ;[max(posZ - GF_BLOCKS_RADIUS, 0):min(posZ + GF_BLOCKS_RADIUS, Y)]
    ;[max(posY - GF_BLOCKS_RADIUS, 0):min(posY + GF_BLOCKS_RADIUS, Z)]
  
    ;������ ����� �������:
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
    ;������ MIN_X:
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
    ;������ MAX_X:
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
    
    ;������ MIN_Y:
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
    ;������ MAX_Y:
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
    
    ;������ MIN_Z:
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
    ;������ MAX_Z:
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
                       stdcall gf_render_chank, [isOnlyWater]
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


proc gf_render_chank, isOnlyWater
  locals 
    _pos       dd    ?
    ObjHandle  dd    ?
  endl       
  
  ;��������� �� ���������� ������ � ���������:
  ;���� �� �� jmp .SkipRender
  
  
  ;�������� �� ������������� �����:                    
  cmp [isOnlyWater], 0
  jnz .skip_1
    cmp byte[esi], 255  
    jz .SkipRender
    mov [ObjHandle], gf_MAIN_CubeHandle
  jmp .skip_2               
  .skip_1: 
  cmp byte[esi], 255 
  jnz .SkipRender
     mov [ObjHandle], 0 ;Water Handle
  .skip_2:
  
  ;������ �������� �� byte[esi] � eax:
  mov eax, [tx_BOGDANHandle]
  
  ;������ ������� �����
  mov [_pos], ebx
  fild [_pos] 
  fstp [gf_tmp_objPos + 0] 
  mov [_pos], ecx
  fild [_pos] 
  fstp [gf_tmp_objPos + 4] 
  mov [_pos], edx
  fild [_pos] 
  fstp [gf_tmp_objPos + 8] 
  
  ;������:
  stdcall gf_SimpleObj, gf_tmp_objPos, [ObjHandle], eax
                       
  .SkipRender:
  ret
endp
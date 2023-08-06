;Рендер ландшафта
proc gf_RenderMineLand uses esi edi ebx, LandData, X, Y, Z, PlPos, PlEye, isOnlyWater

    locals
      PlIntPos   dd    ?, ?, ?
      MAX_XYZ    dd    ?, ?, ?
      MIN_XYZ    dd    ?, ?, ?
    endl
  
    cmp [isOnlyWater], 0
    jz @F
       invoke glUniform1f, [gf_aChanel], [gf_WaterAChanel]
    @@:
  
    
    ;Ограничение рендера для оптимизации:
    ;GF_BLOCKS_RADIUS
    ;Взятие целой позиции:
    mov esi, [PlPos]
    fld dword[esi]
    fistp [PlIntPos]
    fld dword[esi + 4]
    fistp [PlIntPos + 4]
    fld dword[esi + 8]
    fistp [PlIntPos + 8]
    
    ;Расчёт MIN_X:
    
  

    mov esi, [LandData]
    mov ecx, 0
    .LandRender_x:
        mov edx, 0  
        .LandRender_y:
            mov ebx, 0
            .LandRender_z:  
                  cmp byte[esi], 0
                  jz @F
                       stdcall gf_render_chank, [isOnlyWater]
                  @@:
                  inc esi    
            inc ebx
            cmp ebx, [X]
            jnz .LandRender_z
        inc edx
        cmp edx, [Y] 
        jnz .LandRender_y 
    inc ecx
    cmp ecx, [Z]
    jnz .LandRender_x
    
    invoke glUniform1f, [gf_aChanel], 1.0
  ret
endp


proc gf_render_chank, isOnlyWater
  locals 
    _pos       dd    ?
    ObjHandle  dd    ?
  endl       
  
  ;Проверака на нахождение объкта в видимости:
  
  
  ;Проверка на существование блока:                    
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
  
  ;Расчёт текстуры по byte[esi] в eax:
  mov eax, [tx_BOGDANHandle]
  
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
  
  ;Рендер:
  stdcall gf_SimpleObj, gf_tmp_objPos, [ObjHandle], eax
                       
  .SkipRender:
  ret
endp
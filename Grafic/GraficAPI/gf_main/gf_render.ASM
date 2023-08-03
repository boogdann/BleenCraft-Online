proc gf_RenderBegin, CameraPos, CameraTurn 
  ;Создание матрицы камеры
  invoke  glMatrixMode, GL_MODELVIEW
  invoke  glLoadIdentity
  stdcall gf_get_camera_lookvec, [CameraPos], [CameraTurn] 
  stdcall gf_get_camera_upvec, [CameraTurn]  
  stdcall Matrix.LookAt, [CameraPos], gf_camera_lookvec, gf_uplookvec
  invoke glGetFloatv, GL_MODELVIEW_MATRIX, gf_view_matrix              
  
  ;Загрузка матрицы камеры 
  invoke glUniformMatrix4fv, [gf_view_M], 1, 0, gf_view_matrix
  
  ;Загрузка позиции камеры
  invoke glUniform3fv, [gf_CameraPos], 1, [CameraPos]
  ;Настройки
  invoke glUniform1f, [gf_aChanel], 1.0
  ;======================
  invoke glUniform1i, [gf_discardMode], 0;Отсечение пикселей (трава)
  ;======================

  ret
endp


proc gf_CreateLightning, LightsCount, LightsPositions

    ;Загрузка освещения
    invoke glUniform3fv, [gf_Ka], 1, Ka
    invoke glUniform3fv, [gf_Kd], 1, Kd
    invoke glUniform3fv, [gf_Ks], 1, Ks
    invoke glUniform1f, [gf_Shininess], [Shininess]
    invoke glUniform1f, [gf_CandleRadius], [CandleRadius]
    
    mov eax, [LightsCount]
    inc eax
    invoke glUniform1i, [gf_LightsCount], eax
    
    
    invoke glUniform4fv, [gf_SunPosition], 1, SunPosition
    invoke glUniform3fv, [gf_SunIntensity], 1, SunIntensity
    
    ;Загрузка данных источников освещения
    mov esi, [LightsPositions]
    mov ecx, 1
    inc [LightsCount]
    .WriteLightningLoop:  
    cmp ecx, [LightsCount]
    jz @F
        stdcall setLightning, esi, ecx
        add esi, 3
    inc ecx
    jmp .WriteLightningLoop
    @@:
    dec [LightsCount]
    

    ret
endp


proc setLightning uses esi ecx edi, LightsPos, LightId

  locals
    gf_CandlePosition      dd    ?
    gf_CandleIntensity     dd    ?
  endl

  mov esi, [LightsPos]
  fld  dword[esi + 0]
  fstp [tmpCandlePos + 0] 
  fld  dword[esi + 4]
  fstp [tmpCandlePos + 4] 
  fld  dword[esi + 8]
  fstp [tmpCandlePos + 8] 
  
  
  mov esi, gf_strCandleId
  .itoa:
      mov eax, [LightId]     
      xor edx, edx    
      mov ebx, 10      
      idiv ebx
      mov [LightId], eax
      add dl, '0'
      mov byte[esi], dl
      inc esi 
  cmp [LightId], 0
  jnz .itoa
  push esi  
   
  mov edi, gf_temp_path
  mov esi, gf_LeftCandleName
  movzx ecx, byte[gf_LeftCandle_len]
  rep movsb
  
  pop esi
  @@:
     dec esi
     mov al, [esi]
     mov [edi], al 
     inc edi
  cmp esi, gf_strCandleId
  jnz @B
  mov ebx, edi
   
  mov esi, gf_RightCandleName_1
  movzx ecx, byte[gf_RightCandle_len_1]
  rep movsb
  invoke  glGetUniformLocation, [gf_shaderProgram], gf_temp_path
  mov [gf_CandlePosition], eax

  mov edi, ebx
  mov esi, gf_RightCandleName_2
  movzx ecx, byte[gf_RightCandle_len_2]
  rep movsb
  invoke  glGetUniformLocation, [gf_shaderProgram], gf_temp_path
  mov [gf_CandleIntensity], eax
  
  
  cmp [gf_CandlePosition], -1
  jnz @F
    invoke ExitProcess, 0
  @@:
  
  ;Upload candle data
  invoke glUniform4fv, [gf_CandlePosition], 1, tmpCandlePos 
  invoke glUniform3fv, [gf_CandleIntensity], 1, CandleIntensity

  ret
endp



proc  gf_renderObj3D uses esi, Obj3D_Handle, tx_Handle,\
                               PosV, TurnV, Scale   

  ;Создание матрицы (ModelMatrix)
  stdcall gf_CreateModelMatrix, [PosV], [TurnV], [Scale]
  invoke glUniformMatrix4fv, [gf_model_M], 1, 0, gf_model_matrix

  ;Загрузка текстуры
  invoke glBindTexture, GL_TEXTURE_2D, [tx_Handle]
  invoke glUniform1i, [gf_Tex1], 0
  
  ;Загрузка объекта
  mov esi, [Obj3D_Handle]
  invoke glBindVertexArray, [esi]
  ;Рендер
  invoke glDrawArrays, GL_TRIANGLES, 0, [esi + 4]
  
  ret
endp


proc gf_renderCube uses esi ecx edx, cube_Pos, MainCubeHandle, TextureHandle
  stdcall gf_CreatePositionMatrix, [cube_Pos] 
  invoke glUniformMatrix4fv, [gf_model_M], 1, 0, gf_position_matrix
  
  ;Загрузка текстуры
  invoke glBindTexture, GL_TEXTURE_2D, [TextureHandle]
  invoke glUniform1i, [gf_Tex1], 0
  
  mov esi, [MainCubeHandle]
  invoke glBindVertexArray, [esi]
  
  invoke glDrawArrays, GL_TRIANGLES, 0, [esi + 4]

  ret
endp



proc gf_RenderMineLand, LandData, X, Y, Z, MainCubeHandle, isOnlyWater
  locals 
    _pos dd ?
  endl
  
  cmp [isOnlyWater], 0
  jz @F
     invoke glUniform1f, [gf_aChanel], [gf_WaterAChanel]
  @@:
    ;Loop 0 -> X
      ;Loop 0 -> Y
         ;Loop 0 -> Z
            ;Render (Pos -> X, Y, Z)
         ;End
      ;End
    ;End
    ;Loop 0 -> X
    mov esi, [LandData]
    mov ecx, 0
    .LandRender_x:
         ;Loop 0 -> Y
         mov edx, 0  
         .LandRender_y:
               ;Loop 0 -> Z
               mov ebx, 0
               .LandRender_z:
                    ;Пусто
                    cmp byte[esi], 0
                    jz @F
                       ;Для воды
                       cmp [isOnlyWater], 0
                       jnz .skip_1
                          cmp byte[esi], 255  ;Water Block
                          jz @F
                          jmp .skip_2               
                       .skip_1: 
                       cmp byte[esi], 255  ;Water Block
                       jnz @F
                       .skip_2:
                       
                       ;Pos -> X, Y, Z
                       ;Texture -> byte[esi]
                       ;Получить handle текстуры
                       ;stdcall GetTextureHandle, byte[esi]
                       mov eax, [tx_BOGDANHandle]
                    
                       mov [_pos], ebx
                       fild [_pos] 
                       fstp [gf_tmp_objPos + 0] ;ebx
                       mov [_pos], ecx
                       fild [_pos] 
                       fstp [gf_tmp_objPos + 4] ;edx
                       mov [_pos], edx
                       fild [_pos] 
                       fstp [gf_tmp_objPos + 8] ;ecx
                       stdcall gf_renderCube, gf_tmp_objPos, [MainCubeHandle], eax ;(eax - Texture Handle)
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
  ret
endp

;x - 5, y - 5, z - 2
;((1,1,1,1,1),(1,1,1,1,1),(1,1,1,1,1),(1,1,1,1,1),(1,1,1,1,1)) - z = 0
;((1,1,1,1,1),(1,1,1,1,1),(1,1,1,1,1),(1,1,1,1,1),(1,1,1,1,1)) - z = 1
;     x            x            x           x           x
                          

proc gf_RenderEnd          
  invoke SwapBuffers, [hdc]
  invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT 
  
  ret
endp
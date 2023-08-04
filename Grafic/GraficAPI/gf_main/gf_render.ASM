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

  ;=====================test=============
  invoke glUniform1i, [gf_discardMode], 0;Отсечение пикселей (трава)
  ;=====================================

  ret
endp


proc  gf_renderObj3D uses esi eax, Obj3D_Handle, tx_Handle, tx_color,\
                               PosV, TurnV, Scale, dectroyMode
                               
  cmp [tx_Handle], 0
  jnz @F
      invoke glUniform3fv, [gf_ObjColor], 1, [tx_color]
      invoke glUniform1i, [gf_ColorMode], 1
      invoke glUniform1i, [gf_SkyMode], 1
  @@:   
  
  cmp [dectroyMode], 0
  jz @F
      mov esi, tx_Destroy_Handles
      mov eax, dword[dectroyMode] 
      dec eax
      shl eax, 2
      add esi, eax
      ;invoke glActiveTexture, GL_TEXTURE1
      ;invoke glBindTexture, GL_TEXTURE_2D, dword[esi]
      ;invoke glUniform1i, [gf_Tex2], 0
  @@:
  


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
  
  cmp [tx_Handle], 0
  jnz @F
     invoke glUniform1i, [gf_ColorMode], 0
     invoke glUniform1i, [gf_SkyMode], 0
  @@:
  
  ret
endp

proc gf_RenderSelectObj3D, Obj3D_Handle,\
                               PosV, TurnV, Scale
    locals
       addScale  dd   0.002
    endl

    invoke  glPolygonMode, GL_FRONT_AND_BACK, GL_LINE
    fld  [Scale]
    fadd [addScale]
    fstp [Scale]
    stdcall gf_renderObj3D, [Obj3D_Handle], 0, gf_ConturColor,\
                            [PosV], [TurnV], [Scale], 0 
    invoke  glPolygonMode, GL_FRONT_AND_BACK, GL_FILL

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




proc gf_RenderMineLand, LandData, X, Y, Z, isOnlyWater
  locals 
    _pos       dd    ?
    ObjHandle  dd    ?
  endl
  
  mov [ObjHandle], gf_MAIN_CubeHandle
  cmp [isOnlyWater], 0
  jz @F
     mov [ObjHandle], gf_MAIN_CubeHandle ;gf_MAIN_WaterHandle
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
                       stdcall gf_renderCube, gf_tmp_objPos, [ObjHandle], eax ;(eax - Texture Handle)
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
                

proc gf_renderSkyObjs, SkyLand, X, Y, Hieght 
  locals 
    _pos dd ?
    mul  dd 4.0
  endl
  
   fild [Hieght]
   fstp [gf_tmp_objPos + 4]
   
   invoke glUniform3fv, [gf_ObjColor], 1, gf_CloudColor
   invoke glUniform1i, [gf_ColorMode], 1
   invoke glUniform1i, [gf_SkyMode], 1
  
   mov esi, [SkyLand]
   mov ecx, 0
   .LandRender_x:
         mov edx, 0  
         .LandRender_y:
             cmp byte[esi], 0
             jz @F
             
             mov [_pos], ecx
             fild [_pos] 
             fmul [mul]
             fstp [gf_tmp_objPos + 0] ;ecx
             mov [_pos], edx
             fild [_pos] 
             fmul [mul]
             fstp [gf_tmp_objPos + 8] ;edx 
             
             stdcall gf_renderCube, gf_tmp_objPos, gf_MAIN_CloudHandle, 0
             @@:
             inc esi 
         inc edx
         cmp edx, [X] 
         jnz .LandRender_y 
    inc ecx
    cmp ecx, [Y]
    jnz .LandRender_x
    
    invoke glUniform1i, [gf_ColorMode], 0
    invoke glUniform1i, [gf_SkyMode], 0
  ret
endp       


proc gf_RenderEnd   
  ;Рендер солнца
  stdcall gf_renderObj3D, gf_MAIN_CloudHandle, 0, gf_SunColor,\
                            SunPosition, gf_zeroVec, 2.0, 0

  invoke SwapBuffers, [hdc]
  invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT 
  
  ret
endp
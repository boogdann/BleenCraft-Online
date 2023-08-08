proc gf_RenderBegin, CameraPos, CameraTurn 
  ;Создание матрицы камеры
  invoke  glMatrixMode, GL_MODELVIEW
  invoke  glLoadIdentity
  stdcall gf_get_camera_lookvec, [CameraPos], [CameraTurn] 
  stdcall gf_get_camera_upvec, [CameraTurn]  
  stdcall Matrix.LookAt, [CameraPos], gf_camera_lookvec, gf_uplookvec
  invoke glGetFloatv, GL_MODELVIEW_MATRIX, gf_view_matrix 
  ;Создание gf_pr_view_matrix
  stdcall gf_MatrixMultiply, gf_view_matrix, gf_projection_matrix, gf_pr_view_matrix

  
  stdcall gf_frastrum, gf_camera_lookvec, [CameraPos], [CameraTurn]
  
  ;Загрузка позиции камеры
  invoke glUniform3fv, [gf_CameraPos], 1, [CameraPos]

  ;Устанавливаем начальные параметры
  invoke glUniform1i, [gf_discardMode], 0
  
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

  ;Загрузка текстуры
  invoke glActiveTexture, GL_TEXTURE0
  invoke glBindTexture, GL_TEXTURE_2D, [tx_Handle]
  invoke glUniform1i, [gf_Tex1], 0
  
  cmp [dectroyMode], 0
  jz @F
      mov esi, tx_Destroy_Handles
      mov eax, dword[dectroyMode] 
      dec eax
      shl eax, 2
      add esi, eax
      invoke glActiveTexture, GL_TEXTURE1
      invoke glBindTexture, GL_TEXTURE_2D, dword[esi]
      invoke glUniform1i, [gf_Tex2], 1
      invoke glUniform1i, [gf_isTex2Enable], 1
  @@:
  
  ;Создание матрицы (ModelMatrix)
  stdcall gf_CreateModelMatrix, [PosV], [TurnV], [Scale]
  invoke glUniformMatrix4fv, [gf_model_M], 1, 0, gf_model_matrix
  ;Создание матрицы MVP
  stdcall gf_MatrixMultiply, gf_model_matrix, gf_pr_view_matrix, gf_MVP_matrix
  invoke glUniformMatrix4fv, [gf_MVP], 1, 0, gf_MVP_matrix
      
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
  
  cmp [dectroyMode], 0
  jz @F
     invoke glUniform1i, [gf_isTex2Enable], 0
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


proc gf_SimpleObj uses esi ecx edx, cube_Pos, VertexCount, TextureHandle
  stdcall gf_CreatePositionMatrix, [cube_Pos] 
  invoke glUniformMatrix4fv, [gf_model_M], 1, 0, gf_position_matrix
  stdcall gf_MatrixMultiply, gf_position_matrix, gf_pr_view_matrix, gf_MVP_matrix
  invoke glUniformMatrix4fv, [gf_MVP], 1, 0, gf_MVP_matrix
  
  ;Загрузка текстуры
  invoke glBindTexture, GL_TEXTURE_2D, [TextureHandle]
  invoke glUniform1i, [gf_Tex1], 0
  
  invoke glDrawArrays, GL_TRIANGLES, 0, [VertexCount]

  ret
endp  
                

proc gf_renderSkyObjs, SkyLand, X, Y, Hieght 
  locals 
    _pos        dd     ?
    _mul        dd     4.0
    VertexCount dd     36
  endl
  
   lea esi, [gf_MAIN_CloudHandle]
   invoke glBindVertexArray, [esi]
   mov eax, dword[esi + 4]
   mov [VertexCount], eax
  
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
             fmul [_mul]
             fstp [gf_tmp_objPos + 0] 
             mov [_pos], edx
             fild [_pos] 
             fmul [_mul]
             fstp [gf_tmp_objPos + 8] 
             
             stdcall gf_SimpleObj, gf_tmp_objPos, [VertexCount], 0
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
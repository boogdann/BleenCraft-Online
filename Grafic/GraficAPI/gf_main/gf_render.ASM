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



proc gf_RenderMineLand, LandData, X, Y, Z, MainCubeHandle
  locals 
    _pos dd ?
  endl
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
                    cmp byte[esi], 0
                    jz @F
                       ;Pos -> X, Y, Z
                       ;Texture -> byte[esi]
                       ;Получить handle текстуры
                       ;stdcall GetTextureHandle, byte[esi]
                    
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
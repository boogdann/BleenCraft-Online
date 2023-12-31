proc gf_RenderBegin, CameraPos, CameraTurn 

  ;�������� ������� ������
  invoke  glMatrixMode, GL_MODELVIEW
  invoke  glLoadIdentity
  stdcall gf_get_camera_lookvec, [CameraPos], [CameraTurn] 
  stdcall gf_get_camera_upvec, [CameraTurn]  
  stdcall Matrix.LookAt, [CameraPos], gf_camera_lookvec, gf_uplookvec
  invoke glGetFloatv, GL_MODELVIEW_MATRIX, gf_view_matrix 
  ;�������� gf_pr_view_matrix
  stdcall gf_MatrixMultiply, gf_view_matrix, gf_projection_matrix, gf_pr_view_matrix

  
  stdcall gf_frastrum, gf_camera_lookvec, [CameraPos], [CameraTurn]
  
  ;�������� ������� ������
  invoke glUniform3fv, [gf_CameraPos], 1, [CameraPos]

  ;������������� ��������� ���������
  invoke glUniform1i, [gf_discardMode], 0
  
  ret
endp

proc  gf_renderObj3D uses esi eax, Obj3D_Handle, tx_Handle, tx_color,\
                               PosV, TurnV, Scale, dectroyMode  
  locals 
     n_10  dd  4.0
     turn  dd  90.0
     turn2  dd 180.0
  endl  
  mov esi, [TurnV]
  push dword[esi]  
  push dword[esi + 4] 
  push esi
                               
  cmp [Obj3D_Handle], obj.Stick.Handle
  jnz @F
    fld [Scale]
    fmul [n_10] 
    fstp [Scale]
    fld dword[esi]
    fsub [turn] 
    fstp dword[esi]
    fld dword[esi + 4]
    fsub [turn2] 
    fstp dword[esi + 4]
  @@:                                               
  cmp [tx_Handle], 0
  jnz @F
      invoke glUniform3fv, [gf_ObjColor], 1, [tx_color]
      invoke glUniform1i, [gf_ColorMode], 1
      invoke glUniform1i, [gf_SkyMode], 1
  @@:   

  ;�������� ��������
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
  
  ;�������� ������� (ModelMatrix)
  stdcall gf_CreateModelMatrix, [PosV], [TurnV], [Scale]
  invoke glUniformMatrix4fv, [gf_model_M], 1, 0, gf_model_matrix
  ;�������� ������� MVP
  stdcall gf_MatrixMultiply, gf_model_matrix, gf_pr_view_matrix, gf_MVP_matrix
  invoke glUniformMatrix4fv, [gf_MVP], 1, 0, gf_MVP_matrix
      
  ;�������� �������
  mov esi, [Obj3D_Handle]
  invoke glBindVertexArray, [esi]
  ;������
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
  
  pop esi
  pop dword[esi + 4] 
  pop dword[esi]
  
  ret
endp


proc gf_RenderSelectObj3D, PosV, Scale
    stdcall gf_renderObj3D, gf_SELECTED_CubeHandle, 0, gf_ConturColor,\
                            [PosV], gf_zeroVec, [Scale], 0

    ret
endp


proc gf_SimpleObj uses esi ecx edx, cube_Pos, VertexCount, TextureHandle
  stdcall gf_CreatePositionMatrix, [cube_Pos] 
  invoke glUniformMatrix4fv, [gf_model_M], 1, 0, gf_position_matrix
  stdcall gf_MatrixMultiply, gf_position_matrix, gf_pr_view_matrix, gf_MVP_matrix
  invoke glUniformMatrix4fv, [gf_MVP], 1, 0, gf_MVP_matrix
  
  ;�������� ��������
  invoke glBindTexture, GL_TEXTURE_2D, [TextureHandle]
  invoke glUniform1i, [gf_Tex1], 0
  
  invoke glDrawArrays, GL_TRIANGLES, 0, [VertexCount]

  ret
endp  
                

proc gf_renderSkyObjs, SkyLand, X, Y, Hieght, Word_X, Word_Y 
  locals 
    _pos        dd     ?
    _mul        dd     5.0
    _div        dd     2.0
    VertexCount dd     36
    pos_sub_x   dd     0.0
    pos_sub_y   dd     0.0
  endl
  
  fild [X]
  fmul [_mul]
  fild [Word_X]
  fsubp
  fdiv [_div]
  fstp [pos_sub_x]
  
  fild [Y]
  fmul [_mul]
  fild [Word_Y]
  fsubp
  fdiv [_div]
  fstp [pos_sub_y]
  
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
             fsub [pos_sub_x]
             fstp [gf_tmp_objPos + 0] 
             mov [_pos], edx
             fild [_pos] 
             fmul [_mul]
             fsub [pos_sub_y]
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

proc gf_2D_Render_Start 
  invoke  glMatrixMode, GL_MODELVIEW
  invoke  glLoadIdentity 
  invoke  glMatrixMode, GL_PROJECTION
  invoke  glPushMatrix
  invoke  glLoadIdentity 
   
  invoke glUseProgram, 0
  
  ret
endp 

proc gf_render_PlayerItem 
  locals
    add_turn  dd   2.0
  endl


  invoke glClear, GL_DEPTH_BUFFER_BIT
  invoke glUniform4fv, [gf_SunPosition], 1, tmp_SunPosition
  invoke  glMatrixMode, GL_MODELVIEW
  invoke  glLoadIdentity
  stdcall gf_get_camera_lookvec, ZERO_VEC_3, ZERO_VEC_3 
  stdcall gf_get_camera_upvec, ZERO_VEC_3 
  stdcall Matrix.LookAt, ZERO_VEC_3, gf_camera_lookvec, gf_uplookvec
  invoke glGetFloatv, GL_MODELVIEW_MATRIX, gf_view_matrix 
  stdcall gf_MatrixMultiply, gf_view_matrix, gf_projection_matrix, gf_pr_view_matrix
  invoke glUniform3fv, [gf_CameraPos], 1, ZERO_VEC_3
  ;=================
  stdcall gf_renderObj3D, obj.Player.Body.Handle, [tx.Player.Handle], 0, GRAFIC_TMP_VEC_3, PLAYER_ITEM_TURN, 0.004, 0
  stdcall gf_renderObj3D, obj.Player.LLeg.Handle, [tx.Player.Handle], 0, GRAFIC_TMP_VEC_3, PLAYER_ITEM_TURN, 0.004, 0
  stdcall gf_renderObj3D, obj.Player.RLeg.Handle, [tx.Player.Handle], 0, GRAFIC_TMP_VEC_3, PLAYER_ITEM_TURN, 0.004, 0
  stdcall gf_renderObj3D, obj.Player.LHand.Handle, [tx.Player.Handle], 0, GRAFIC_TMP_VEC_3, PLAYER_ITEM_TURN, 0.004, 0
  stdcall gf_renderObj3D, obj.Player.RHand.Handle, [tx.Player.Handle], 0, GRAFIC_TMP_VEC_3, PLAYER_ITEM_TURN, 0.004, 0
  ;=================
  
  fld [PLAYER_ITEM_TURN+4]
  fadd [add_turn]
  fstp [PLAYER_ITEM_TURN+4]

  ret
endp    

proc gf_render_LableItem
  locals
    add_turn  dd   0.3
    mul_tmp   dd   15.0
    
    n_90      dd   -90.0
  endl


  invoke glClear, GL_DEPTH_BUFFER_BIT
  invoke glUniform4fv, [gf_SunPosition], 1, tmp_SunPosition
  invoke  glMatrixMode, GL_MODELVIEW
  invoke  glLoadIdentity
  stdcall gf_get_camera_lookvec, ZERO_VEC_3, ZERO_VEC_3 
  stdcall gf_get_camera_upvec, ZERO_VEC_3 
  stdcall Matrix.LookAt, ZERO_VEC_3, gf_camera_lookvec, gf_uplookvec
  invoke glGetFloatv, GL_MODELVIEW_MATRIX, gf_view_matrix 
  stdcall gf_MatrixMultiply, gf_view_matrix, gf_projection_matrix, gf_pr_view_matrix
  invoke glUniform3fv, [gf_CameraPos], 1, ZERO_VEC_3
  


  ;=================
  stdcall grafic.GetToolsObjHandles, Tools.IronPickaxe 
  stdcall gf_renderObj3D, ebx, eax, 0, GRAFIC_TMP_2_VEC_3, PLAYER_ITEM_TURN, 0.007, 0
  ;=================
  
  fldz
  fstp [PLAYER_ITEM_TURN + 4]
  
  fld [LABLE_ITEM_TURN]
  fadd [add_turn]
  fstp [LABLE_ITEM_TURN]
  
  fld [LABLE_ITEM_TURN]
  fcos
  fmul [mul_tmp]
  fstp [PLAYER_ITEM_TURN + 4]
  
  
  ret
endp

proc gf_2D_Render_End
  invoke glUseProgram, [gf_shaderProgram]
  
  invoke  glMatrixMode, GL_PROJECTION
  invoke  glPopMatrix
  ret
endp 

;ebx - *(addr) to obj handle structure
;eax - [value] of texture handle
proc grafic.GetToolsObjHandles uses edx, index
  locals 
    divisor  dd  5
  endl

  mov eax, [index]
  sub eax, Tools.MinValueTool
  inc eax
  push eax
  
  
  cmp eax, 0
  jnz .SkipStick
    mov ebx, ToolsObjAddr
    jmp .ReadyObj
  .SkipStick:
    xor edx, edx
    dec eax
    div dword[divisor]
    imul eax, 8
    mov ebx, eax
    
    add ebx, ToolsObjAddr
    add ebx, 8

  .ReadyObj:
  
  pop eax
  imul eax, 4
  add eax, ToolsTxAddr
  mov eax, [eax]
  
  ret
endp

proc grafic.GetToolsTextureIndex, index
  locals 
    divisor  dd  5
  endl

  mov eax, [index]
  sub eax, Tools.MinValueTool
  inc eax

  imul eax, 4
  
  ret
endp


proc gf_RenderEnd   
  ;������ ������
  stdcall gf_renderObj3D, gf_MAIN_CloudHandle, 0, gf_SunColor,\
                            SunPosition, gf_zeroVec, 5.0, 0                        
                     
  invoke SwapBuffers, [hdc]
  invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT

  
  ret
endp
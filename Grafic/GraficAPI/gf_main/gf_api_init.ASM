 proc gf_window_init
    locals
        center          POINT
    endl
    
    invoke  RegisterClass, wndClass
    invoke  CreateWindowEx, 0, className, className, WINDOW_STYLE,\
                            0, 0, 0, 0, 0, 0, 0, 0
                            
   ;    invoke  CreateWindowEx, 0, className, className, WS_VISIBLE,\
    ;                        0, 0, 2000, 500, 0, 0, 0, 0
    mov     [hMainWindow], eax

    invoke  GetClientRect, eax, WindowRect
    
    invoke  GetDC, [hMainWindow]
    mov     [hdc], eax
    
    invoke LoadCursor, 0, IDC_ARROW 
    invoke SetCursor, eax
    
    
    ;Установка курсора в центр
    ;Центр экрана по X
    mov eax, [WindowRect.right]
    xor edx, edx
    mov ebx, 2
    div ebx
    mov [center.x], eax
  
    ;Центр экрана по Y
    mov eax, [WindowRect.bottom]
    xor edx, edx
    mov ebx, 2
    div ebx
    mov [center.y], eax
    invoke SetCursorPos, [center.x], [center.y]
    
    
   ret
 endp
 
 
 proc gf_opengl_init
    locals
        aspect          dd              ?
    endl
    
    invoke  ChoosePixelFormat, [hdc], pfd
    invoke  SetPixelFormat, [hdc], eax, pfd

    invoke  wglCreateContext, [hdc]
    invoke  wglMakeCurrent, [hdc], eax

    invoke  glViewport, 0, 0, [WindowRect.right], [WindowRect.bottom]
    
    invoke  glClearColor, 0.5, 0.66, 0.99, 1.0
    invoke  glEnable, GL_DEPTH_TEST
    invoke  glEnable, GL_LINE_SMOOTH
    invoke  glEnable, GL_BLEND
    invoke  glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA

 
    
   ret
 endp
 
 
 proc gf_LoadFunctions uses esi edi
        mov     esi, extensionAddresses
        mov     edi, extensionNames

.Scan:
        movzx   eax, byte[edi]
        cmp     eax, 0
        je      .Return

        invoke  wglGetProcAddress, edi
        mov     [esi], eax
        add     esi, 4

        mov     al, 0
        mov     ecx, 0xFFFFFFFF
        repne   scasb
        jmp     .Scan

.Return:
        ret
 endp
 
 
 proc gf_InitShadersData uses esi edi
        mov     esi, UniformLocations
        mov     edi, UniformNames

.Scan:
        movzx   eax, byte[edi]
        cmp     eax, 0
        je      .Return

        invoke  glGetUniformLocation, [gf_shaderProgram], edi
        mov     [esi], eax
        mov     edx, eax
        add     esi, 4

        mov     al, 0
        mov     ecx, 0xFFFFFFFF
        repne   scasb
        jmp     .Scan

.Return:
        ret
    ret
 endp
 
 
 proc gf_InitRenderParams 
    fld dword[WindowRect.right]
    fdiv dword[WindowRect.bottom]
    fstp dword[aspect]
 
    ;Создание матрицы проекции    
    stdcall Matrix.Projection, [fov], [aspect] , [zNear], [zFar]
    
    
    ;Загрузка стандартных объектов
    stdcall gf_UploadObj3D, gf_MAIN_cube_name, gf_MAIN_CubeHandle
    stdcall gf_UploadObj3D, gf_MAIN_cloud_name, gf_MAIN_CloudHandle
    stdcall gf_UploadObj3D, gf_MAIN_water_name, gf_MAIN_WaterHandle
    stdcall gf_UploadObj3D, gf_SELECTED_cube_name, gf_SELECTED_CubeHandle
    ;Загрузка стандартных текстур
    stdcall gf_UploadTexture, tx_Water_name, tx_Water_Handle
    stdcall gf_UploadTexture, tx_Destroy1_Name, tx_Destroy1_Handle
    stdcall gf_UploadTexture, tx_Destroy2_Name, tx_Destroy2_Handle
    stdcall gf_UploadTexture, tx_Destroy3_Name, tx_Destroy3_Handle
    stdcall gf_UploadTexture, tx_Destroy4_Name, tx_Destroy4_Handle
    stdcall gf_UploadTexture, tx_Destroy5_Name, tx_Destroy5_Handle       
    
    ;Инициализация освещения
    invoke glUniform3fv, [gf_Ka], 1, Ka
    invoke glUniform3fv, [gf_Kd], 1, Kd
    invoke glUniform3fv, [gf_Ks], 1, Ks
    invoke glUniform1f, [gf_Shininess], [Shininess]
    invoke glUniform1f, [gf_CandleRadius], [CandleRadius]  
    invoke glUniform4fv, [gf_FogColor], 1, gf_Fog_Color
    
    ret
 endp
 
proc Set_GF_RENDER_BLOCKS_RADIUS, x, y, z
  mov eax, [x]
  mov [GF_RENDER_BLOCKS_RADIUS], eax
  mov eax, [y]
  mov [GF_RENDER_BLOCKS_RADIUS + 4], eax
  mov eax, [z]
  mov [GF_RENDER_BLOCKS_RADIUS + 8], eax

  ret
endp
 proc gf_window_init
    locals
        hMainWindow     dd              ?
    endl
    
    invoke  GetProcessHeap
    mov     [hHeap], eax
    
    invoke  RegisterClass, wndClass
    invoke  CreateWindowEx, 0, className, className, WINDOW_STYLE,\
                            0, 0, 0, 0, 0, 0, 0, 0
    mov     [hMainWindow], eax

    invoke  GetClientRect, eax, WindowRect
    
    invoke  GetDC, [hMainWindow]
    mov     [hdc], eax
    
    invoke  ShowCursor, 0
    invoke  LoadCursor, 0, IDC_ARROW 
    invoke SetCursor, eax
    
    
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
    invoke glEnable, GL_LINE_SMOOTH
 
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

    invoke glUniformMatrix4fv, [gf_projection_M], 1, 0, gf_projection_matrix
    
    ;Загрузка стандартных объектов
    stdcall gf_UploadObj3D, gf_MAIN_cloud_name, gf_MAIN_CloudHandle
    stdcall gf_UploadObj3D, gf_MAIN_cube_name, gf_MAIN_CubeHandle
    ;Загрузка стандартных текстур
    stdcall gf_UploadTexture, tx_Destroy1_Name, tx_Destroy1_Handle
    stdcall gf_UploadTexture, tx_Destroy2_Name, tx_Destroy2_Handle
    stdcall gf_UploadTexture, tx_Destroy3_Name, tx_Destroy3_Handle
    stdcall gf_UploadTexture, tx_Destroy4_Name, tx_Destroy4_Handle
    stdcall gf_UploadTexture, tx_Destroy5_Name, tx_Destroy5_Handle
    
    ret
 endp
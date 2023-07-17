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

    invoke  GetClientRect, eax, clientRect
    invoke  ShowCursor, 0
    
    invoke  GetDC, [hMainWindow]
    mov     [hdc], eax
    
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

    invoke  glViewport, 0, 0, [clientRect.right], [clientRect.bottom]
    
    invoke  glClearColor, 0.1, 0.5, 0.2, 1.0
    invoke  glEnable, GL_DEPTH_TEST
 
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
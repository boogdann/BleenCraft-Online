;ƒобавить работу с матрицами в градусах 
proc Matrix.Projection uses edi,\
     fov, aspect, zNear, zFar

        locals
                sine            dd              ?
                cotangent       dd              ?
                deltaZ          dd              ?
                radians         dd              ?
        endl

        lea     edi, [gf_projection_matrix]
        mov     ecx, 4 * 4
        xor     eax, eax
        rep     stosd

        lea     edi, [gf_projection_matrix]

        fld     [fov]
        fld1
        fld1
        faddp
        fdivp
        fdiv    [radian]
        fstp    [radians]

        fld     [zFar]
        fsub    [zNear]
        fstp    [deltaZ]

        fld     [radians]
        fsin
        fstp    [sine]

        fld     [radians]
        fcos
        fdiv    [sine]
        fstp    [cotangent]

        fld     [cotangent]
        fdiv    [aspect]
        fstp    [edi + Matrix4x4.m11]

        fld     [cotangent]
        fstp    [edi + Matrix4x4.m22]

        fld     [zFar]
        fadd    [zNear]
        fdiv    [deltaZ]
        fchs
        fstp    [edi + Matrix4x4.m33]

        fld1
        fchs
        fstp    [edi + Matrix4x4.m34]

        fld1
        fld1
        faddp
        fchs
        fmul    [zNear]
        fmul    [zFar]
        fdiv    [deltaZ]
        fstp    [edi + Matrix4x4.m43]

        ret
endp

proc Matrix.LookAt uses esi edi ebx,\
     camera, target, up

        locals
                temp    dd    ?
                zAxis   dd    ?, ?, ?
                xAxis   dd    ?, ?, ?
                yAxis   dd    ?, ?, ?
        endl

        mov     edi, gf_view_matrix
        mov     ecx, 4 * 4
        xor     eax, eax
        rep     stosd

        mov     esi, [camera]
        mov     edi, [target]
        mov     ebx, [up]

        fld     [edi + Vector3.x]
        fsub    [esi + Vector3.x]
        fstp    [zAxis + Vector3.x]

        fld     [edi + Vector3.y]
        fsub    [esi + Vector3.y]
        fstp    [zAxis + Vector3.y]

        fld     [edi + Vector3.z]
        fsub    [esi + Vector3.z]
        fstp    [zAxis + + Vector3.z]

        lea     eax, [zAxis]
        stdcall Vector3.Normalize, eax

        lea     eax, [zAxis]
        lea     ecx, [xAxis]
        stdcall Vector3.Cross, eax, ebx, ecx

        lea     eax, [xAxis]
        stdcall Vector3.Normalize, eax

        lea     eax, [xAxis]
        lea     ecx, [zAxis]
        lea     ebx, [yAxis]
        stdcall Vector3.Cross, eax, ecx, ebx

        lea     esi, [xAxis]
        mov     edi, gf_view_matrix
        fld     [esi + Vector3.x]
        fstp    [edi + Matrix4x4.m11]
        fld     [esi + Vector3.y]
        fstp    [edi + Matrix4x4.m21]
        fld     [esi + Vector3.z]
        fstp    [edi + Matrix4x4.m31]

        fld     [ebx + Vector3.x]
        fstp    [edi + Matrix4x4.m12]
        fld     [ebx + Vector3.y]
        fstp    [edi + Matrix4x4.m22]
        fld     [ebx + Vector3.z]
        fstp    [edi + Matrix4x4.m32]

        lea     esi, [zAxis]
        fld     [esi + Vector3.x]
        fchs
        fstp    [edi + Matrix4x4.m13]
        fld     [esi + Vector3.y]
        fchs
        fstp    [edi + Matrix4x4.m23]
        fld     [esi + Vector3.z]
        fchs
        fstp    [edi + Matrix4x4.m33]

        fld1
        fstp    [edi + Matrix4x4.m44]

        invoke  glMultMatrixf, edi

        mov     esi, [camera]
        fld     [esi + Vector3.z]
        fchs
        fstp    [temp]
        push    [temp]
        fld     [esi + Vector3.y]
        fchs
        fstp    [temp]
        push    [temp]
        fld     [esi + Vector3.x]
        fchs
        fstp    [temp]
        push    [temp]
        
        invoke  glTranslatef

    ret
endp


proc gf_get_camera_lookvec, pos, turn
    locals
       a  dd  ?
       b  dd  ?
       c  dd  ?
       PiDegree dd 180.0
    endl
    mov esi, [turn]
    mov edi, [pos]

    ;Calculate a in radian
    fldpi
    fmul dword[esi]
    fdiv [PiDegree]
    fstp [a]
    ;Calculate b in radian
    fldpi
    fmul dword[esi + 4]
    fdiv [PiDegree]
    fstp [b]
    ;Calculate c in radian
    fldpi
    fmul dword[esi + 8]
    fdiv [PiDegree]
    fstp [c] 
    
    fld dword[edi + 0]
    fld [a]
    fcos
    fld [b] 
    fsin
    fmulp
    fsubp
    fstp [gf_camera_lookvec + 0]
    
    fld dword[edi + 4]
    fld [a]
    fsin
    faddp
    fstp [gf_camera_lookvec + 4]
    
    fld dword[edi + 8]
    fld [a]
    fcos
    fld [b] 
    fcos
    fmulp
    faddp
    fstp [gf_camera_lookvec + 8]
    
    

  ret
endp


proc gf_CreateModelMatrix uses esi edi, pos, turn, scale

    stdcall gf_CreatePositionMatrix, [pos]
    stdcall gf_CreateScaleMatrix, [scale]
    stdcall gf_CreateTurnMatrix, [turn]
    stdcall gf_MatrixMultiply4x4, gf_turn_matrix, gf_scale_matrix, gf_model_matrix
    stdcall gf_MatrixMultiply4x4, gf_model_matrix, gf_position_matrix, gf_model_matrix

    ret
endp


proc gf_CreatePositionMatrix, pos
  mov edi, gf_position_matrix
                        
  mov esi, [pos]
  fld  [esi + Vector3.x]
  fstp [edi + Matrix4x4.m41]
  
  fld  [esi + Vector3.y]
  fstp [edi + Matrix4x4.m42]
  
  fld  [esi + Vector3.z]
  fstp [edi + Matrix4x4.m43]
  

  ret
endp


proc gf_CreateTurnMatrix, turn
  ;gf_turn_matrix
  
    locals
       a  dd  ?
       b  dd  ?
       c  dd  ?
       PiDegree dd 180.0
    endl
    mov esi, [turn]

    ;Calculate a in radian
    fldpi
    fmul  dword [esi]
    fdiv  [PiDegree]
    fstp  [a]
    ;Calculate b in radian
    fldpi
    fmul  dword [esi + 4]
    fdiv  [PiDegree]
    fstp  [b]
    ;Calculate c in radian
    fldpi
    fmul dword [esi + 8]
    fdiv [PiDegree]
    fstp  [c]

    ;---Matrix[0][0]---
    fld  [b]
    fcos
    fld  [c]
    fcos
    fmulp
    fstp  dword[gf_turn_matrix + 0]
    ;------------------
    ;---Matrix[0][1]---
    fld  [c]
    fsin
    fld  [b]
    fcos
    fmulp
    fchs
    fstp  dword[gf_turn_matrix + 4]
    ;------------------
    ;---Matrix[0][2]---
    fld  [b]
    fsin
    fstp  dword[gf_turn_matrix + 8]
    ;------------------
    ;---Matrix[1][0]---
    fld  [a]
    fsin
    fld  [b]
    fsin
    fmulp
    fld  [c]
    fcos
    fmulp
    fld  [c]
    fsin
    fld  [a]
    fcos
    fmulp
    faddp
    fstp  dword[gf_turn_matrix + 16]
    ;------------------
    ;---Matrix[1][1]---
    fld  [a]
    fcos
    fld  [c]
    fcos
    fmulp
    fld  [a]
    fsin
    fld  [b]
    fsin
    fmulp
    fld  [c]
    fsin
    fmulp
    fsubp
    fstp  dword[gf_turn_matrix + 20]
    ;------------------
    ;---Matrix[1][2]---
    fld  [a]
    fsin
    fld  [b]
    fcos
    fmulp
    fchs
    fstp  dword[gf_turn_matrix + 24]
    ;------------------
    ;---Matrix[2][0]---
    fld  [a]
    fsin
    fld  [c]
    fsin
    fmulp
    fld  [b]
    fsin
    fld  [a]
    fcos
    fmulp
    fld  [c]
    fcos
    fmulp
    fsubp
    fstp  dword[gf_turn_matrix + 32]
    ;------------------
    ;---Matrix[2][1]---
    fld  [a]
    fsin
    fld  [c]
    fcos
    fmulp
    fld  [b]
    fsin
    fld  [c]
    fsin
    fmulp
    fld  [a]
    fcos
    fmulp
    faddp
    fstp dword [gf_turn_matrix + 36]
    ;------------------
    ;---Matrix[2][2]---
    fld  [a]
    fcos
    fld  [b]
    fcos
    fmulp
    fstp  dword[gf_turn_matrix + 40]
    ;------------------
    ;---Matrix[3][3]---
    fld1
    fstp dword[gf_turn_matrix + 60]
    ;------------------
  

  ret
endp


proc gf_CreateScaleMatrix, scale 
          
  mov edi, gf_scale_matrix   
          
  fld  [scale]    
  fstp [edi + Matrix4x4.m11]
  
  fld  [scale]
  fstp [edi + Matrix4x4.m22]
  
  fld  [scale]
  fstp [edi + Matrix4x4.m33]
  
  ret
endp

proc gf_MatrixMultiply4x4 uses ebx ecx edx, matrix1, matrix2, matrix_res 

   locals
     temp    dd     ?
   endl

   mov edx, [matrix_res]
   mov ecx, [matrix1]
   
   mov esi, 0
   gf_MatrixMultiply4x4.LoopA1:
   ;###########################111
       mov edi, 0
       gf_MatrixMultiply4x4.LoopA2:
       ;###########################222
           mov [temp], 0.0
           mov ebx, 0
           gf_MatrixMultiply4x4.LoopA3:
           ;###########################333
               fld dword[ecx + ebx]
               push ecx edx
               mov ecx, [matrix2]
               add ecx, edi
               fmul dword[ecx + ebx * 4]  
               pop edx ecx
               fadd dword[temp]
               fstp dword[temp]
           ;###########################333  
           add ebx, 4
           cmp ebx, 4 * 4
           jnz gf_MatrixMultiply4x4.LoopA3
           
           mov eax, [temp]
           mov [edx + edi], eax
       ;###########################222
       add edi, 4
       cmp edi, 4 * 4
       jnz gf_MatrixMultiply4x4.LoopA2
   ;###########################111
   add esi, 16
   add edx, 16
   add ecx, 16
   cmp esi, 16 * 4
   jnz gf_MatrixMultiply4x4.LoopA1

  ret
endp




;;Vector3

proc Vector3.Normalize uses edi,\
     vector

        locals
                l       dd      ?
        endl

        mov     edi, [vector]

        stdcall Vector3.Length, [vector]
        mov     [l], eax

        fld     [edi + Vector3.x]
        fdiv    [l]
        fstp    [edi + Vector3.x]

        fld     [edi + Vector3.y]
        fdiv    [l]
        fstp    [edi + Vector3.y]

        fld     [edi + Vector3.z]
        fdiv    [l]
        fstp    [edi + Vector3.z]

        ret
endp

proc Vector3.Cross uses esi edi ebx,\
     v1, v2, result

        mov     esi, [v1]
        mov     edi, [v2]
        mov     ebx, [result]

        fld     [esi + Vector3.y]
        fmul    [edi + Vector3.z]
        fld     [esi + Vector3.z]
        fmul    [edi + Vector3.y]
        fsubp
        fstp    [ebx + Vector3.x]

        fld     [esi + Vector3.z]
        fmul    [edi + Vector3.x]
        fld     [esi + Vector3.x]
        fmul    [edi + Vector3.z]
        fsubp
        fstp    [ebx + Vector3.y]

        fld     [esi + Vector3.x]
        fmul    [edi + Vector3.y]
        fld     [esi + Vector3.y]
        fmul    [edi + Vector3.x]
        fsubp
        fstp    [ebx + Vector3.z]

        ret
endp

proc Vector3.Length uses esi,\
     vector

        locals
                result  dd      ?
        endl

        mov     esi, [vector]

        fld     [esi + Vector3.x]
        fmul    [esi + Vector3.x]

        fld     [esi + Vector3.y]
        fmul    [esi + Vector3.y]

        fld     [esi + Vector3.z]
        fmul    [esi + Vector3.z]

        faddp
        faddp
        fsqrt
        fstp    [result]

        mov     eax, [result]

        ret
endp
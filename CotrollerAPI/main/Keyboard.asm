proc ct_on_keyDown, wParam, lParam
  
  ;Esc
  cmp [wParam], VK_ESCAPE
  jnz @F
     cmp [ct_is_mouse], 1
     jz .hide
       stdcall ct_change_mouse, 1
       jmp .skip
     .hide:
       stdcall ct_change_mouse, 0
     .skip:
     jmp .final
  @@:
      
  
  ;... ƒÛ„ËÂ ÍÎ‡‚Ë¯Ë
  
  cmp [wParam], VK_F2
  jnz @F
    neg [isDebug]
  @@: 

  .final:  
  ret
endp


proc ct_check_moves, CameraPos, CameraTurn
  locals 
    Speed   dd   ?
    curTime  dd  ?
    distancePerSecond  dd 130.0
    shiftConst         dd 40.0
    waterSpeed         dd 300.0
    
    
  endl
  
  invoke GetTickCount
  mov edx, eax
  sub eax, [time.deltaTime]
    
  mov [curTime], eax
  mov [time.deltaTime], edx    
    
  cmp [curTime], 0
  jle .Skip 
    
  fild dword[curTime]
  fld dword[distancePerSecond]
  cmp [ct_isJump], 0
  je .water
  cmp [isWatter], 0
  jz .notWater
    
    fadd [waterSpeed]
    jmp .water  
    
  .notWater:
  
  invoke  GetAsyncKeyState, VK_SHIFT
  cmp eax, 0
  jz @F
      fsub  [shiftConst] 
  @@:
  
  .water:
  
  fdivp
  fstp dword[Speed]

  ;À≈¬¿ﬂ  ÕŒœ ¿ Ã€ÿ»
  invoke GetAsyncKeyState, $01
  cmp eax, 0
  jz @F
     
     mov [skip_destroying], 0
     
     cmp [flag], 1
     jne .skipDestroy
        
        invoke GetTickCount
        mov edx, eax
        sub eax, [prev_destr_time]
        
        mov [prev_destr_time], edx
        
        cmp eax, 1000
        jg .time
     
          
          add [destruction_time], eax      
          
          mov eax, 0
          
          stdcall Blocks.GetDestroyTime, [ct_block_index], 1
           
     
          cmp [destruction_time], eax
          jl .time
          
            mov [flag], 0
            mov [destruction_time], 0
            stdcall ct_destroy_block, selectCubeData   
     
        .time:
     
     .skipDestroy:
     
     jmp .lmb_pressed
     
  @@:
  
  mov [skip_destroying], 1
  
  .lmb_pressed:
  
  ;œ–¿¬¿ﬂ  ÕŒœ ¿ Ã€ÿ»
  invoke GetAsyncKeyState, $02
  cmp eax, 0
  jz @F
     
     cmp [flag], 1
     jne .skipBuilding
        
        mov [build_by_click], 0
        
        invoke GetTickCount
        mov edx, eax
        sub eax, [prev_building_time]
        
        mov [prev_building_time], edx
        
        cmp eax, 1000
        jg .not_ready
     
          
          add [building_time], eax      
             
          cmp [building_time], 500
          jl .not_ready
          
            mov [flag], 0
            mov [building_time], 0
            
            stdcall ct_build_block, prevCubePos   
     
        .not_ready:
     
     .skipBuilding: 
     
     jmp .rbm_pressed
     
  @@: 
    
    mov [build_by_click], 1 
    
  .rbm_pressed:
  
  ;’ÓÊ‰ÂÌËˇ:
  invoke  GetAsyncKeyState, $57 
  cmp eax, 0
  jz @F
     stdcall ct_moves, [CameraPos], [CameraTurn], [Speed], 1
  @@:
  invoke  GetAsyncKeyState, $41
  cmp eax, 0
  jz @F
     stdcall ct_moves, [CameraPos], [CameraTurn], [Speed], 2
  @@:
  invoke  GetAsyncKeyState, $53
  cmp eax, 0
  jz @F
     stdcall ct_moves, [CameraPos], [CameraTurn], [Speed], 3
  @@:
  invoke  GetAsyncKeyState, $44
  cmp eax, 0
  jz @F
     stdcall ct_moves, [CameraPos], [CameraTurn], [Speed], 4
  @@:

  .Skip:

  ret
endp


proc ct_moves, CameraPos, CameraTurn, Speed, Direction
  locals 
       a  dd  ? 
       b  dd  ? 
       PiDegree dd 180.0
       
       Pl_step dd  0.0001
       Pl_chest  dd  1.0 
       
       tempVector dd 0, 0, 0
       tempCamera dd 0.0, 0.0, 0.0
  
    endl   
  
    mov esi, [CameraTurn] 
    mov edi, [CameraPos]  
                                
.OnMove:  
    
    cmp [ct_isMoving], 1
    jne .Skip
                       
    ;Calculate a in radian          
    mov [a], 0.0
    ;Calculate b in radian 
    fldpi
    fmul dword [esi + 4] 
    fdiv dword [PiDegree] 
    fstp dword [b] 
 
    fld dword [edi + 4]
    fsub dword [Pl_chest]
    fistp dword [tempVector + 4]
 
    fld dword [edi + 4]
    fstp dword [tempCamera + 4] 
 
    fld dword [edi]
    fstp dword [tempCamera]
      
    fld dword [edi + 8]
    fstp dword [tempCamera + 8]
  
    cmp [Direction], 1 ;Forward 
    jz .MoveForward 
    cmp [Direction], 2 ;Right
    jz .MoveRight 
    cmp [Direction], 3 ;Backward 
    jz .MoveBackWard  
    cmp [Direction], 4 ;Left 
    jz .MoveLeft 
    Jmp .Skip 
  
    .MoveForward: 
      ;CameraPos[1] = CameraPos[1] - cos(a)*sin(b) * WalkingSpeed 
      fld dword [edi] 
      fld [a] 
      fcos 
      fld [b] 
      fsin 
      fmulp 
      fmul [Speed] 
      fsubp
      ;[Field.Blocks] 
      fstp dword [edi]
      
      fld dword [edi]
      fistp dword [tempVector]    
      
      fld dword [edi + 8]
      fistp [tempVector + 8]
      
      stdcall ct_isBlock, [Field.Blocks], [WorldWidth], [WorldLength], [tempVector], [tempVector + 8], [tempVector + 4]
      
      cmp [onGround], 1
      jne @F
      
        fld dword[tempCamera]
        fstp dword [edi]
                        
      @@:                         
      
      ;CameraPos[3] = CameraPos[3] + cos(a) * cos(b) * WalkingSpeed 
      fld dword [edi + 8] 
      fld [a] 
      fcos 
      fld [b] 
      fcos 
      fmulp 
      fmul [Speed]  
      faddp 
      fstp dword [edi + 8]
      
      fld dword [edi + 8]
      fistp dword [tempVector + 8]
      
      fld [tempCamera]
      fistp [tempVector]
      
      stdcall ct_isBlock, [Field.Blocks], [WorldWidth], [WorldLength], [tempVector], [tempVector + 8], [tempVector + 4]
      
      cmp [onGround], 1
      jne @F
        
        fld dword [tempCamera + 8]
        fstp dword [edi + 8]  
                
      @@:            
      
      fild dword[tempVector + 4]
      fadd [Pl_chest]
      fistp dword[tempVector + 4]
      
      fld dword [edi]
      fistp dword [tempVector]
      
      fld [tempCamera + 8]
      fistp [tempVector + 8]
      
      stdcall ct_isBlock, [Field.Blocks], [WorldWidth], [WorldLength], [tempVector], [tempVector + 8], [tempVector + 4]
      
      cmp [onGround], 1
      jne @F
      
        fld dword[tempCamera]
        fstp dword [edi]
                        
      @@: 
      
      fld dword [edi + 8]
      fistp dword [tempVector + 8]
               
      fld [tempCamera]
      fistp [tempVector]
      
      stdcall ct_isBlock, [Field.Blocks], [WorldWidth], [WorldLength], [tempVector], [tempVector + 8], [tempVector + 4]
      
      cmp [onGround], 1
      jne @F
        
        fld dword [tempCamera + 8]
        fstp dword [edi + 8]  
                
      @@: 
      
    Jmp .Skip 
    .MoveBackWard: 
      ;CameraPos[1] = CameraPos[1] + cos(a)*sin(b) * WalkingSpeed 
      fld dword [edi] 
      fld [a] 
      fcos 
      fld [b] 
      fsin 
      fmulp 
      fmul [Speed]  
      faddp 
      fstp dword [edi]
      
      fld dword [edi]
      fistp dword [tempVector]
                    
      fld dword [edi + 8]
      fistp [tempVector + 8]
      
      stdcall ct_isBlock, [Field.Blocks], [WorldWidth], [WorldLength], [tempVector], [tempVector + 8], [tempVector + 4]
      
      cmp [onGround], 1
      jne @F
      
        fld dword[tempCamera]
        fstp dword [edi]
                        
      @@:
       
      ;CameraPos[3] = CameraPos[3] + cos(a) * cos(b) * WalkingSpeed 
      fld dword [edi + 8] 
      fld [a] 
      fcos 
      fld [b] 
      fcos 
      fmulp 
      fmul [Speed] 
      fsubp 
      fstp dword [edi + 8]
      
      fld dword [edi + 8]
      fistp dword [tempVector + 8]
               
      fld [tempCamera]
      fistp [tempVector]
      
      stdcall ct_isBlock, [Field.Blocks], [WorldWidth], [WorldLength], [tempVector], [tempVector + 8], [tempVector + 4]
      
      cmp [onGround], 1
      jne @F
        
        fld dword [tempCamera + 8]
        fstp dword [edi + 8]  
                
      @@:   
      
      fild dword[tempVector + 4]
      fadd [Pl_chest]
      fistp dword[tempVector + 4]
      
      fld dword [edi]
      fistp dword [tempVector]
      
      fld [tempCamera + 8]
      fistp [tempVector + 8]
      
      stdcall ct_isBlock, [Field.Blocks], [WorldWidth], [WorldLength], [tempVector], [tempVector + 8], [tempVector + 4]
      
      cmp [onGround], 1
      jne @F
      
        fld dword[tempCamera]
        fstp dword [edi]
                        
      @@: 
                    
      fld dword [edi + 8]
      fistp dword [tempVector + 8]
      
      fld [tempCamera]
      fistp [tempVector]
      
      stdcall ct_isBlock, [Field.Blocks], [WorldWidth], [WorldLength], [tempVector], [tempVector + 8], [tempVector + 4]
      
      cmp [onGround], 1
      jne @F
        
        fld dword [tempCamera + 8]
        fstp dword [edi + 8]  
                
      @@: 

       
    Jmp .Skip 
    .MoveLeft: 
      ;CameraPos[1] = CameraPos[1] - cos(b) * WalkingSpeed 
      fld dword [edi] 
      fld [b] 
      fcos 
      fmul [Speed] 
      fsubp 
      fstp dword [edi] 
      
      fld dword [edi]
      fistp dword [tempVector]
              
      fld dword [edi + 8]
      fistp [tempVector + 8]
      
      stdcall ct_isBlock, [Field.Blocks], [WorldWidth], [WorldLength], [tempVector], [tempVector + 8], [tempVector + 4]
      
      cmp [onGround], 1
      jne @F
      
        fld dword[tempCamera]
        fstp dword [edi]
                        
      @@:
      
      ;CameraPos[3] = CameraPos[3] - sin(b) * WalkingSpeed 
      fld dword [edi + 8] 
      fld  [b] 
      fsin 
      fmul [Speed]  
      fsubp 
      fstp dword [edi + 8]
      
      fld dword [edi + 8]
      fistp dword [tempVector + 8]
            
      fld [tempCamera]
      fistp [tempVector]
      
      stdcall ct_isBlock, [Field.Blocks], [WorldWidth], [WorldLength], [tempVector], [tempVector + 8], [tempVector + 4]
      
      cmp [onGround], 1
      jne @F
        
        fld dword [tempCamera + 8]
        fstp dword [edi + 8]  
                
      @@:    
      
      fild dword[tempVector + 4]
      fadd [Pl_chest]
      fistp dword[tempVector + 4]
      
      fld dword [edi]
      fistp dword [tempVector]
      
      fld [tempCamera + 8]
      fistp [tempVector + 8]
      
      stdcall ct_isBlock, [Field.Blocks], [WorldWidth], [WorldLength], [tempVector], [tempVector + 8], [tempVector + 4]
      
      cmp [onGround], 1
      jne @F
      
        fld dword[tempCamera]
        fstp dword [edi]
                        
      @@: 
         
      fld dword [edi + 8]
      fistp dword [tempVector + 8]
      
      fld [tempCamera]
      fistp [tempVector]
      
      stdcall ct_isBlock, [Field.Blocks], [WorldWidth], [WorldLength], [tempVector], [tempVector + 8], [tempVector + 4]
      
      cmp [onGround], 1
      jne @F
        
        fld dword [tempCamera + 8]
        fstp dword [edi + 8]  
                
      @@:
       
    Jmp .Skip 
    .MoveRight: 
      ;CameraPos[1] = CameraPos[1] + cos(b) * WalkingSpeed 
      fld dword [edi] 
      fld [b] 
      fcos 
      fmul [Speed] 
      faddp 
      fstp dword [edi]
                       
      fld dword [edi]
      fistp dword [tempVector]
      
      fld dword [edi + 8]
      fistp [tempVector + 8]
      
      stdcall ct_isBlock, [Field.Blocks], [WorldWidth], [WorldLength], [tempVector], [tempVector + 8], [tempVector + 4]
      
      cmp [onGround], 1
      jne @F
      
        fld dword[tempCamera]
        fstp dword [edi]
                        
      @@:
       
      ;CameraPos[3] = CameraPos[3] + sin(b) * WalkingSpeed 
      fld dword [edi + 8] 
      fld [b] 
      fsin 
      fmul [Speed] 
      faddp 
      fstp dword [edi + 8] 
       
      fld dword [edi + 8]
      fistp dword [tempVector + 8]
      
      fld [tempCamera]
      fistp [tempVector]
      
      stdcall ct_isBlock, [Field.Blocks], [WorldWidth], [WorldLength], [tempVector], [tempVector + 8], [tempVector + 4]
      
      cmp [onGround], 1
      jne @F
        
        fld dword [tempCamera + 8]
        fstp dword [edi + 8]  
                
      @@:  
      
      fild dword[tempVector + 4]
      fadd [Pl_chest]
      fistp dword[tempVector + 4]
         
      fld dword [edi]
      fistp dword [tempVector]
      
      fld [tempCamera + 8]
      fistp [tempVector + 8]
      
      stdcall ct_isBlock, [Field.Blocks], [WorldWidth], [WorldLength], [tempVector], [tempVector + 8], [tempVector + 4]
      
      cmp [onGround], 1
      jne @F
      
        fld dword[tempCamera]
        fstp dword [edi]
                        
      @@: 
          
      fld dword [edi + 8]
      fistp dword [tempVector + 8]
      
      fld [tempCamera]
      fistp [tempVector]
      
      stdcall ct_isBlock, [Field.Blocks], [WorldWidth], [WorldLength], [tempVector], [tempVector + 8], [tempVector + 4]
      
      cmp [onGround], 1
      jne @F
        
        fld dword [tempCamera + 8]
        fstp dword [edi + 8]  
                
      @@:
      
    Jmp .Skip 
 
    .Skip:
  ret
endp
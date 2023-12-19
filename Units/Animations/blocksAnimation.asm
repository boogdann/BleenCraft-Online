proc animate_building_block

  invoke GetTickCount
  mov edx, eax
  sub eax, [prev_build_anim_time]
  
  mov [prev_build_anim_time], edx

  cmp eax, 100
  jg .finish
      
      add [build_anim_time], eax
      
      mov [ready_to_build], 0
      
      cmp [block_builded], 0
      jne @F
          stdcall ct_build_block, prevCubePos
          mov [block_builded], 1 
      @@:
      
      cmp [build_anim_time], 300
      jl @F
         mov [block_builded], 0
         mov [build_anim_time], 0
         mov [animate_building], 0
         mov [ready_to_build], 1 
         jmp .finish   
      @@:
      
      stdcall anim_blockInHand, PlayerPos, PlayerTurn     
      
  .finish:

  ret
endp

proc anim_blockInHand uses esi edi, playerPos, playerTurn
  
  fldz
  fstp [Anim_Hand_Turn]
  fldz
  fstp [Anim_Hand_Turn + 4]
  fldz
  fstp [Anim_Hand_Turn + 8]
  
  mov [toolInHand], 0
  
  
  mov edi, [chosenBlockFromInv]
  inc edi  
  cmp edi, Tools.MinValueTool
  jl @F
      dec edi
      stdcall grafic.GetToolsObjHandles, edi
      jmp .Render
  @@:  
  dec edi
  dec edi
  imul edi, 4
  add edi, TextureHandles
  
  mov ebx, obj.Cube.Handle
  mov eax, dword[edi]
  .Render:  
  ;eax - tx | ebx - obj*
  
  cmp [chosenBlockFromInv], 235
  jl @F
    mov [toolInHand], 1
  @@:
  
  mov esi, [playerTurn]
  cmp dword[esi], 0
  jle @F
     cmp [toolInHand], 1
     je .blockUp
          stdcall anim_blockInHand_up, [playerPos], [playerTurn], ebx, eax
          jmp .Return
     .blockUp:
          stdcall anim_toolInHand_up, [playerPos], [playerTurn], ebx, eax
          jmp .Return 
  @@:
      cmp [toolInHand], 1
      je .blockDown
          stdcall anim_blockInHand_down, [playerPos], [playerTurn], ebx, eax
          jmp .Return
      .blockDown:
          stdcall anim_toolInHand_down, [playerPos], [playerTurn], ebx, eax
          jmp .Return
  .Return:
  
  ret
endp  

proc anim_blockInHand_down uses esi edi, playerPos, playerTurn, obj, tx

  locals
    a dd 0.0        
    b dd 0.0
    PiDegree    dd 180.0
    len         dd 0.11
    n_05        dd 1.3
    pos_sub      dd 0.05
    pos_sub_base dd 0.06
    
    tmp_x_turn  dd ?
    
    addTurn_A   dd 35.0 
    addTurn_A_tmp dd  22.0  ;radian  
  endl
  
  cmp [animate], 1
  jne .finish
  

  mov esi, [playerTurn]
  mov edi, [playerPos]
  
  ;fld dword[esi]
  ;fstp [Anim_Hand_Turn]
  fld dword[esi + 4]
  fstp [Anim_Hand_Turn + 4]
  
  push dword[edi + 4]
  push edi
  
  fldpi
  fmul dword[esi]
  fdiv [PiDegree] 
  fstp [a]
  
  fld dword[edi + 4]
  fld [pos_sub]
  fld [a]
  fsin
  fmulp
  faddp
  fsub [pos_sub_base]
  fstp dword[edi + 4]
  
  fld [addTurn_A]
  fld [a]   ;no
  fsin
  fld [addTurn_A_tmp]
  fmulp
  faddp    
  fstp [addTurn_A]
  
  
  fldpi
  fmul dword[esi + 4]
  fdiv [PiDegree]
  fldpi
  fmul [addTurn_A] 
  fdiv [PiDegree]
  faddp
  fstp [b]
  
  fld dword[edi + 0]
  fld [b] 
  fsin
  fmul [len]
  fsubp
  fstp [Anim_Hand_Position + 0]
    
  fld dword[edi + 4]
  fld [a]      ;no
  fsin
  fmul [len]
  faddp
  fstp [Anim_Hand_Position + 4]
  
  fld dword[edi + 8]
  fld [b] 
  fcos
  fmul [len]
  faddp
  fstp [Anim_Hand_Position + 8]
  
  fldpi
  fmul dword[esi + 4]
  fdiv [PiDegree]
  fldpi
  fmul [addTurn_A]
  fdiv [PiDegree]
  fsubp
  fstp [b]
  
  ;len_2
  fld [a]  ;no
  fsin
  fmul [len]
  fmul [n_05]
  fstp [len]
  
  fld dword[Anim_Hand_Position + 0]
  fld [b] 
  fsin
  fmul [len]
  fsubp
  fstp [result_pos + 0]
    
    
  fld dword[Anim_Hand_Position + 4]
  fld [a] ;!
  fsin
  fmul [len]
  faddp
  fstp [result_pos + 4]
  
  fld dword[Anim_Hand_Position + 8]
  fld [b] 
  fcos
  fmul [len]
  faddp
  fstp [result_pos + 8]
  
  cmp [animate_tool], 1
  jne @F
     stdcall animatetool, esi, 0.8, 0.025, 3 
  @@:
  
  mov ecx, 0
  
  cmp [animate_building], 1
  jne @F
    stdcall animatetool, esi, 0.4, 0.025, 3
  @@:

  lea esi, [result_pos]
  stdcall gf_renderObj3D, [obj], [tx], 0,\
                                esi, Anim_Hand_Turn, 0.04, 0
                                
  pop edi
  pop dword[edi + 4]
 
  .finish:
  
  
  ret
endp 


proc anim_blockInHand_up uses esi edi, playerPos, playerTurn, obj, tx
  
  locals
    a dd 0.0        
    b dd 0.0
    PiDegree    dd 180.0
    len         dd 0.11
    n_05        dd -0.005
    pos_sub      dd 0.035
    pos_sub_base dd 0.06
    
    tmp_x_turn  dd ?
    
    addTurn_A   dd 35.0 
    addTurn_A_tmp dd  22.0  ;radian  
  endl
  
  cmp [animate], 1
  jne .finish
  

  mov esi, [playerTurn]
  mov edi, [playerPos]
  
  fldz
  fstp [Anim_Hand_Turn]
  
  fld dword[esi + 4]
  fstp [Anim_Hand_Turn + 4]
  
  push dword[edi + 4]
  push edi
  
  fldpi
  fmul dword[esi]
  fdiv [PiDegree] 
  fstp [a]
  
  fld dword[edi + 4]
  fld [pos_sub]
  fld [a]
  fsin
  fmulp
  faddp
  fsub [pos_sub_base]
  fstp dword[edi + 4] 
  
  fld [addTurn_A]
  fld [a]   ;no
  fsin
  fld [addTurn_A_tmp]
  fmulp
  faddp    
  fstp [addTurn_A] 
  
  fldpi
  fmul dword[esi + 4]
  fdiv [PiDegree]
  fldpi
  fmul [addTurn_A] 
  fdiv [PiDegree]
  faddp
  fstp [b] 
  
  fld dword[edi + 0]
  fld [b] 
  fsin
  fmul [len]
  fsubp
  fstp [Anim_Hand_Position + 0]
    
  fld dword[edi + 4]
  fld [a]      ;no
  fsin
  fmul [len]
  faddp
  fstp [Anim_Hand_Position + 4]
  
  fld dword[edi + 8]
  fld [b] 
  fcos
  fmul [len]
  faddp
  fstp [Anim_Hand_Position + 8]
  
  fldpi
  fmul dword[esi + 4]
  fdiv [PiDegree]
  fldpi
  fmul [addTurn_A]
  fdiv [PiDegree]
  fsubp
  fstp [b]
  
  ;len_2
  fld [a]  ;no
  fsin
  fmul [len]
  fmul [n_05]
  fchs
  fstp [len]
  
  fld dword[Anim_Hand_Position + 0]
  fld [b] 
  fsin
  fmul [len]
  fsubp
  fstp [result_pos + 0]
    
    
  fld dword[Anim_Hand_Position + 4]
  fld [a] ;!
  fsin
  fmul [len]
  faddp
  fstp [result_pos + 4]
  
  fld dword[Anim_Hand_Position + 8]
  fld [b] 
  fcos
  fmul [len]
  faddp
  fstp [result_pos + 8]
  
  cmp [animate_tool], 1
  jne @F
     stdcall animatetool, esi, 0.6, 0.025, 3 
  @@:
  
  cmp [animate_building], 1
  jne @F
    stdcall animatetool, esi, 0.4, 0.025, 3
  @@:
  
  stdcall gf_renderObj3D, [obj], [tx], 0,\
                                result_pos, Anim_Hand_Turn, 0.04, 0
                                
  pop edi
  pop dword[edi + 4]
 
  .finish:

  ret
endp


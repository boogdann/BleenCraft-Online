proc animatetool uses esi edi, playerTurn, frequency
  
  locals
    
    testVal   dd   0.6
    
    a         dd   0.0
    b         dd   0.0
    len         dd 0.04
    PiDegree  dd   180.0
    
    tempVector  dd  0.02
    
    currentOffset dd 0
    
    multiplier    dd  100.0
    
    
    forward_mul   dd  -0.6
  endl
  
  mov esi, [playerTurn]
  
  fldpi
  fmul dword[esi]
  fdiv [PiDegree] 
  fstp [a]
  
  fldpi
  fmul dword[esi + 4]
  fdiv [PiDegree] 
  fstp [b]
  
  fld [prevToolKoeff]
  fadd [frequency]
  fstp [prevToolKoeff]
  
  fld [result_pos]
  fld [a]
  fcos
  fld[b]
  fsin
  fmulp
  fmul [animVectorOffset]
  fsubp
  fstp [result_pos]
  
  fld [result_pos + 4]
  fld [prevToolKoeff] 
  fsin
  fmul [len]
  fsubp
  fstp [result_pos + 4]
  
  fld [result_pos + 8]
  fld [prevToolKoeff] 
  fcos
  fmul [len]
  fmul [forward_mul]
  fld [b]
  fsin
  fmulp
  fsubp
  fstp [result_pos + 8]  
  
  fld [result_pos]
  fld [prevToolKoeff] 
  fcos
  fmul [len]
  fmul [forward_mul]
  fld [b]
  fcos
  fmulp
  fsubp
  fstp [result_pos] 
   
  
  fld [result_pos + 8]
  fld [a]
  fcos
  fld[b]
  fcos
  fmulp
  fmul [animVectorOffset]
  faddp
  fstp [result_pos + 8] 
  
  fld [animVectorOffset]
  fmul [multiplier]
  fistp [currentOffset]
  
  cmp [currentOffset], 4
  jg @F
     fld [animVectorOffset]
     fadd [tempVector]
     fstp [animVectorOffset]
  @@:
  
  
  ret
endp

proc anim_toolInHand_down uses esi edi, playerPos, playerTurn, obj, tx

  locals
    a dd 0.0        
    b dd 0.0
    PiDegree    dd 180.0
    len         dd 0.11
    n_05        dd 1.3
    pos_sub      dd 0.05
    pos_sub_base dd 0.06
    
    ;result_pos  dd ?, ?, ?
    
    tmp_x_turn  dd ?
    
    addTurn_A   dd 35.0 
    addTurn_A_tmp dd  22.0  ;radian 
    
    angleY        dd  70.0 
  endl
  
  cmp [animate], 1
  jne .finish
  

  mov esi, [playerTurn]
  mov edi, [playerPos]
  
  fld dword[esi + 4]
  fstp [Anim_Hand_Turn + 4]
  
  push dword[edi + 4]
  push edi
  
  fldpi
  fmul dword[esi]
  fdiv [PiDegree] 
  fstp [a]
  
  fld [Anim_Hand_Turn + 4]
  fadd [angleY]
  fstp [Anim_Hand_Turn + 4]
  
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
    stdcall animatetool, esi, 1.0
  @@:
  
  stdcall gf_renderObj3D, [obj], [tx], 0,\
                                result_pos, Anim_Hand_Turn, 0.03, 0
                                
  pop edi
  pop dword[edi + 4]
 
  .finish:
  
  
  ret
endp 



proc anim_toolInHand_up uses esi edi, playerPos, playerTurn, obj, tx
  
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
    angleY        dd  70.0
    addAngleY     dd  35.0 
  endl
  
  cmp [animate], 1
  jne .finish
  

  mov esi, [playerTurn]
  mov edi, [playerPos]
  
  fldz
  fstp [Anim_Hand_Turn]
  
  ;fld dword[esi]         ;;!!
  ;fstp [Anim_Hand_Turn]  ;;!!
  
  fld dword[esi + 4]
  fstp [Anim_Hand_Turn + 4]
  
  push dword[edi + 4]
  push edi
  
  fldpi
  fmul dword[esi]
  fdiv [PiDegree] 
  fstp [a]
  
  fld [Anim_Hand_Turn + 4]
  fadd [angleY]
  fld [a]
  fsin
  fmul [addAngleY]
  faddp
  fstp [Anim_Hand_Turn + 4]
  
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
  
;  fldpi
;  fmul dword[esi + 4]
;  fdiv [PiDegree]
;  fldpi
;  fmul [addTurn_A]
;  fdiv [PiDegree]
;  fsubp
;  fstp [b]
  
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
    stdcall animatetool, esi, 0.7
  @@:
  
  stdcall gf_renderObj3D, [obj], [tx], 0,\
                                result_pos, Anim_Hand_Turn, 0.03, 0
                                
  pop edi
  pop dword[edi + 4]
 
  .finish:

  ret
endp
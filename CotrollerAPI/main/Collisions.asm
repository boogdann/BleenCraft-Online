proc ct_collisionsBegin uses esi edi, playerPos
  mov esi, [playerPos]
  fld dword[esi]
  fstp [ct_lastPos]
  fld dword[esi + 4]
  fstp [ct_lastPos + 8]
  fld dword[esi + 8]
  fstp [ct_lastPos + 8]
  ret
endp


proc ct_collisionsCheck, playerPos, Field, X, Y, Z
    locals              
      Block           dd     0.5
      PL_HEIGHT       dd     1.85 ;;
      PL_UP_SIZE      dd     0.15
      PL_DOWN_SIZE    dd     1.7
      X_POS           dd     ?
      Y_POS           dd     ?
      Z_POS           dd     ?
      tmp             dd     2500
    endl
    
    mov esi, [playerPos]
    mov edi, [Field]
    
    ;ct_isJump = 1 если можно прыгать!!!
    
    ;Вниз:
    fld dword[esi + 4]
    fsub [PL_DOWN_SIZE]
    fistp dword [Z_POS]  
    fld dword[esi]
    fistp dword [X_POS]  
    fld dword[esi + 8]
    fistp dword [Y_POS] 
    push edi
       stdcall ct_isBlock, [Field], [X], [Y], [X_POS], [Y_POS], [Z_POS]
       cmp eax, 0
       jz @F
          jmp .Registration_Down
       @@:
       jmp .skip_Down
       .Registration_Down:
          fild [Z_POS]
          fadd [Block]
          fadd [PL_DOWN_SIZE]
          fstp dword[esi + 4]
          fldz
          fstp [ct_fall_speed]
       .skip_Down:
    pop edi

  ;1. CheckDown

  .Normal:
  ret
endp 

proc ct_isBlock uses esi, Field, XS, YS, x, y, z
     
   locals
      XY_mul      dd     ?
   endl  
   mov esi, [Field] 
   mov eax, 0
   
   
   ;mov eax, [XS]
   ;imul [YS]
   ;imul [z]
   ;add esi, eax
   
   ;mov eax, [XS]
   ;imul [y]
   ;add esi, eax
   ;add esi, [x]
   ;mov eax, 0
   ;cmp byte[esi], 0
   ;jz @F
   ;   mov eax, 1
   ;@@:

  ret
endp


proc ct_fall_check, playerPos
  locals
    g       dd      0.00002
    curTime dd     ?
  endl
  
  invoke GetTickCount
  sub eax, [ct_last_ch_spd]
  cmp eax, 10
  jl @F
    fld  [ct_fall_speed]
    fadd [g]
    fstp [ct_fall_speed]
    mov [ct_last_ch_spd], eax
  @@:
  
  mov esi, [playerPos]
  fld  dword[esi + 4]
  fsub [ct_fall_speed]
  fstp dword[esi + 4]

  ret
endp
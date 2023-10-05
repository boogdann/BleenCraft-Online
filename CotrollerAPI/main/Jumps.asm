proc ct_fall_check, playerPos, Field, X, Y
  
  locals
     fallTime      dd     ?
     curFallSpeed  dd     ?
     fallingVelocity  dd     0.0005
     tempHeight    dd     0.01
     maxSpeed      dd     0.0
             
     ;Ограничения
     MAX_TICKS_COUNT  dd  100
     MIN_TICKS_COUNT  dd  5
    
  endl
  
  cmp [isFalling], 1
  jne .Skip
  
  cmp [toSkip], 1
  je .Skip
  
  cmp [onGround], 1
  je .Skip
  
  cmp [ct_isStartOfJump], 1
  jz .startOfJump 
  
  ;Расчитываем сколько прошло тактов
  invoke GetTickCount
  mov edx, eax
  sub eax, [prevTime]
  mov [fallTime], eax
  
  ;Достаточно ли тактов?
  mov ecx, [MIN_TICKS_COUNT]
  cmp [fallTime], ecx
  jl .Skip
  ;Если да, то сетаем последний прыжок текущим временем
  mov [prevTime], edx  
  
  ;Не слишком ли много тактов?
  mov ecx, [MAX_TICKS_COUNT]
  cmp [fallTime], ecx
  jg .Skip

  ;Расчёт итоговой скорости
  fild [fallTime]
  fld [ct_jump_distancePerSecond] ;ct_jump_distancePerSecond
  fmulp               
  fstp [curFallSpeed] 
    
  ;Ускорение
  fld  [ct_jump_distancePerSecond]
  fadd [ct_velocity]
  fstp [ct_jump_distancePerSecond]
  
.changeCoord:  

  mov esi, [playerPos]

  ;Изменение координаты
  fld  dword[esi + 4]
  fsub [curFallSpeed]    
  fstp dword[esi + 4]  
  
  jmp .Skip
  
.startOfJump:

  mov esi, [playerPos]
  fld  dword[esi + 4]
  fadd [tempHeight]
  fstp dword[esi + 4]
 
  
  .Skip:
  
  
  ret
endp

proc ct_check_Jump, playerPos 

  cmp [ct_isJump], 0
  jz @F
    invoke  GetAsyncKeyState, VK_SPACE
    cmp eax, 0
    jz @F
      ;Колизии
      mov [onGround], 0
      mov [toSkip], 0
      
      mov [ct_isStartOfJump], 0
      
      fld [ct_start_jump_speed]
      fstp [ct_jump_distancePerSecond]

  @@:

  ret
endp
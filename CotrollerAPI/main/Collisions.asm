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


proc ct_collisionsCheck, playerPos, lastPos, Field, X, Y, Z

  ;Задачи функции:
  ;1. Не дать пройти сквозь препятствия
  ;2. Отследить когда человек на земле, а когда нет 
  ;  (от этого зависит можно ли прыгать) (ct_isJump)
  ;  ct_isJump = 1 - можно прыгать | 0 - нельзя
  
  ;Пометки:
  ;К этому моменту расчитано новое положение ([playerPos])
  ;и в нём человек может быть в колизии и если так, то нужно
  ;здесь это обработать с учётом что прошлое положение 
  ;(100% без колизий) хранитьcя в [ct_lastPos]
  ;Причём просто вернуться к старому положению нельзя
  ;т.к. есть вариант с "скольжением в доль стены" или
  ;просто даже ходьба по полу и т.д.
  
  ;В итоге имеется:
  ;playerPos - новая невалидированная позиция
  ;lastPos - старая валидированная позиция
  ;Field - адресс на 3-х мерный массив ладшафта
  ;X, Y, Z - размеры ладшафта
   
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


;Прыжок
proc ct_check_Jump

  locals
      Jump_speed  dd    -0.0007
  endl

  cmp [ct_isJump], 0
  jz @F
  invoke  GetAsyncKeyState, VK_SPACE
  cmp eax, 0
  jz @F
      fld [Jump_speed]
      fstp [ct_fall_speed]
  @@:

  ret
endp
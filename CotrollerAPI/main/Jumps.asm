proc ct_fall_check, playerPos
  
  locals
     fallTime      dd     ?
     curFallSpeed  dd     ?
     tempVelocity  dd     0.0005
     tempHeight    dd     0.01
     tmp dd 100.0
     
     ;Îãðàíè÷åíèÿ
     MAX_TICKS_COUNT  dd  100
     MIN_TICKS_COUNT  dd  10
  endl
  
  cmp [isFalling], 1
  jne .Skip
  
  cmp [toSkip], 1
  je .Skip
  
  cmp [onGround], 1
  je .Skip
  
  cmp [ct_isStartOfJump], 1
  jz .startOfJump
  
  ;Ðàñ÷èòûâàåì ñêîëüêî ïðîøëî òàêòîâ
  invoke GetTickCount
  mov edx, eax
  sub eax, [prevTime]
  mov [fallTime], eax
  
  ;Äîñòàòî÷íî ëè òàêòîâ?
  mov ecx, [MIN_TICKS_COUNT]
  cmp [fallTime], ecx
  jl .Skip
  ;Åñëè äà, òî ñåòàåì ïîñëåäíèé ïðûæîê òåêóùèì âðåìåíåì
  mov [prevTime], edx  
  
  ;Íå ñëèøêîì ëè ìíîãî òàêòîâ?
  mov ecx, [MAX_TICKS_COUNT]
  cmp [fallTime], ecx
  jg .Skip

  ;Ðàñ÷¸ò èòîãîâîé ñêîðîñòè
  fild [fallTime]
  fld [ct_jump_distancePerSecond] ;ct_jump_distancePerSecond
  fmulp               
  fstp [curFallSpeed]
  
  ;Óñêîðåíèå
  fld  [ct_jump_distancePerSecond]
  fadd [tempVelocity]
  fstp [ct_jump_distancePerSecond]
  
  mov esi, [playerPos]
  ;Èçìåíåíèå êîîðäèíàòû
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
      ;Êîëèçèè
      mov [onGround], 0
      mov [toSkip], 0
      
      mov [ct_isStartOfJump], 0
      
      fld [ct_start_jump_speed]
      fstp [ct_jump_distancePerSecond]
  @@:

  ret
endp
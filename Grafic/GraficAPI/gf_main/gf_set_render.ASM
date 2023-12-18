proc gf_CreateLightning, LightsCount_u, LightsPositions, isWater

    locals 
       LightsCount  dd   ?
       fog_dist     dd   ?
    endl
    
    mov eax, [LightsCount_u]
    mov [LightsCount], eax

    ;Загрузка освещения
    mov eax, [LightsCount]
    inc eax
    invoke glUniform1i, [gf_LightsCount], eax 

    cmp [gf_isAutoWhether], 0
    jz @F
       stdcall gf_changeDaylyCof
    @@:
    stdcall gf_setDaylyCof  
    stdcall gf_RecalculateWheherParams, [isWater]     
    
    fild  [GF_RENDER_BLOCKS_RADIUS]
    fstp  [fog_dist]   
    invoke glUniform1f, [gf_MaxFogDist], [fog_dist]
    
    
    ;Загрузка данных источников освещения
    mov esi, [LightsPositions]
    mov ecx, 1
    inc [LightsCount]
    .WriteLightningLoop:  
    cmp ecx, [LightsCount]
    jz @F
        stdcall setLightning, esi, ecx
        add esi, 12
    inc ecx
    jmp .WriteLightningLoop
    @@:
    dec [LightsCount]
    

    ret
endp

proc gf_RecalculateWheherParams, isWater
    locals 
      gf_kof_add    dd    0.2
      gf_kof_sub    dd    0.08
      gf_add        dd    0.1
      gf_div        dd    2.0
      cloudCof      dd    1.02
    endl
    invoke glUniform4fv, [gf_SunPosition], 1, SunPosition
    push [gf_Dayly_kof]
    
    fld [gf_Dayly_kof]
    fabs
    fstp [gf_Dayly_kof]
    
    ;Sun Intensity
    push [gf_Dayly_kof]
    fld  [gf_kof_add]
    fadd [gf_Dayly_kof]
    fstp [gf_Dayly_kof]
    fld  [Max_SunIntensity]
    fmul [gf_Dayly_kof]
    fstp [SunIntensity]
    fld  [Max_SunIntensity + 4]
    fmul [gf_Dayly_kof]
    fstp [SunIntensity + 4]
    fld  [Max_SunIntensity + 8]
    fmul [gf_Dayly_kof]
    fstp [SunIntensity + 8]
    invoke glUniform3fv, [gf_SunIntensity], 1, SunIntensity
    
    ;Background color
    pop [gf_Dayly_kof]
    cmp [isWater], 0
    jz @F
       mov [gf_Dayly_kof], 0.1
       invoke glUniform3fv, [gf_SunIntensity], 1, gf_WaterSunIntensty
    @@:
    push [gf_Dayly_kof]
    fld [gf_Dayly_kof]
    fdiv [gf_div]
    fadd [gf_add]
    fstp [gf_Dayly_kof]
    fld  [gf_kof_sub]
    fdiv [gf_Dayly_kof]
    fstp [gf_Dayly_kof]     
    fld  [gf_backgroundColorM]
    fsub [gf_Dayly_kof]
    fstp [gf_backgroundColor]
    fld  [gf_backgroundColorM + 4]
    fsub [gf_Dayly_kof]
    fstp [gf_backgroundColor + 4]
    fld  [gf_backgroundColorM + 8]
    fsub [gf_Dayly_kof]
    fstp [gf_backgroundColor + 8]
    pop [gf_Dayly_kof]
    invoke  glClearColor, [gf_backgroundColor], [gf_backgroundColor + 4],\
                                                 [gf_backgroundColor + 8], 1.0
                                                 
    ;Cloud Color
    push [gf_Dayly_kof]
    fld [gf_Dayly_kof]
    fdiv [cloudCof]
    fstp [gf_Dayly_kof]
    
    fld [gf_Dayly_kof]
    fadd [gf_CloudColorM]
    fstp [gf_CloudColor]
    fld [gf_Dayly_kof]
    fadd [gf_CloudColorM + 4]
    fstp [gf_CloudColor + 4]
    fld [gf_Dayly_kof]
    fadd [gf_CloudColorM + 8]
    fstp [gf_CloudColor + 8]
    pop [gf_Dayly_kof] 
    
    pop [gf_Dayly_kof]
    
    
    
  ret
endp


proc setLightning uses esi ecx edi, LightsPos, LightId

  locals
    gf_CandlePosition      dd    ?
    gf_CandleIntensity     dd    ?
  endl

  mov esi, [LightsPos]
  fld  dword[esi + 0]
  fstp [tmpCandlePos + 0] 
  fld  dword[esi + 4]
  fstp [tmpCandlePos + 4] 
  fld  dword[esi + 8]
  fstp [tmpCandlePos + 8] 
  
  
  mov esi, gf_strCandleId
  .itoa:
      mov eax, [LightId]     
      xor edx, edx    
      mov ebx, 10      
      idiv ebx
      mov [LightId], eax
      add dl, '0'
      mov byte[esi], dl
      inc esi 
  cmp [LightId], 0
  jnz .itoa
  push esi  
   
  mov edi, gf_temp_path
  mov esi, gf_LeftCandleName
  movzx ecx, byte[gf_LeftCandle_len]
  rep movsb
  
  pop esi
  @@:
     dec esi
     mov al, [esi]
     mov [edi], al 
     inc edi
  cmp esi, gf_strCandleId
  jnz @B
  mov ebx, edi
   
  mov esi, gf_RightCandleName_1
  movzx ecx, byte[gf_RightCandle_len_1]
  rep movsb
  invoke  glGetUniformLocation, [gf_shaderProgram], gf_temp_path
  mov [gf_CandlePosition], eax

  mov edi, ebx
  mov esi, gf_RightCandleName_2
  movzx ecx, byte[gf_RightCandle_len_2]
  rep movsb
  invoke  glGetUniformLocation, [gf_shaderProgram], gf_temp_path
  mov [gf_CandleIntensity], eax
  
  
  cmp [gf_CandlePosition], -1
  jnz @F
    invoke ExitProcess, 0
  @@:
  
  ;Upload candle data
  invoke glUniform4fv, [gf_CandlePosition], 1, tmpCandlePos 
  invoke glUniform3fv, [gf_CandleIntensity], 1, CandleIntensity

  ret
endp


;Измение внешний DaylyCof от времени
proc gf_changeDaylyCof
   locals
      currentTime     dd      ?
   endl
   
   invoke  GetTickCount
   mov     [currentTime], eax
   
   sub     eax, [gf_lastDaylyChange]
   cmp     eax, 15 
   jle     @F
     mov eax, [currentTime]
     mov [gf_lastDaylyChange], eax
     mov esi, [gf_dayly_kof_adress] 
     inc word[esi]
     mov ax, word[DAYLY_SPEED]
     add word[esi], ax   ;Debug
   @@:
  ret
endp


proc gf_cleanLightning
  mov [CircleCount], 0
  mov [LightsCount], 0
  
  ret
endp

proc gf_AddLightning uses esi edi, pos
  ;LightsCount
  ;LightsPositions
  inc [LightsCount]
  cmp [LightsCount], 14
  jl @F
    mov [LightsCount], 14
  @@: 
  
  mov eax, [CircleCount]
  imul eax, 12
  add eax, LightsPositions
  mov esi, eax
  
  mov edi, [pos]
  mov eax, dword[edi]
  mov dword[esi], eax 
  mov eax, dword[edi + 4]
  mov dword[esi + 4], eax 
  mov eax, dword[edi + 8]
  mov dword[esi + 8], eax 
  

  inc [CircleCount]
  cmp [CircleCount], 14
  jle @F
    mov [CircleCount], 0
  @@:
  ret
endp

proc gf_DeleteLightning uses esi edi ecx edx, pos
  cmp [LightsCount], 0
  jz .Ready
     
  mov esi, LightsPositions
  mov ecx, 0
  .SeachLightningCircle:
     push ecx
        stdcall _client.Vec3cmp, [pos], esi
     pop ecx
     cmp eax, 0
     jnz @F
        mov edi, esi  ;esi - cur pos
        add edi, 12   ;edi - next pos
        mov edx, [LightsCount]
        sub edx, ecx
        inc edx
        cmp ecx, edx
        jz .ReadyCircle
        mov ecx, 0
        .RewritingCircle:
            mov eax, dword[edi]
            mov dword[esi], eax 
            mov eax, dword[edi + 4]
            mov dword[esi + 4], eax 
            mov eax, dword[edi + 8]
            mov dword[esi + 8], eax 
        inc ecx
        cmp ecx, edx
        jnz .RewritingCircle
        .ReadyCircle:
        dec [LightsCount] 
        cmp [LightsCount], 0
        jg .SkipZeroCheck
            mov [LightsCount], 0
        .SkipZeroCheck:
        
        dec [CircleCount]
        cmp [CircleCount], 0
        jg .Ready
          mov [CircleCount], 0
        jmp .Ready
     @@:
     add esi, 12
  inc ecx
  cmp ecx, [LightsCount]
  jnz .SeachLightningCircle
  
  .Ready:
  ret
endp


;Установление внутреннего DaylyCof от внешнего
proc gf_setDaylyCof
  locals 
    tmp_div  dd  32768.0
    tmp_int  dd  ?
    tmp      dd  2.0
  endl 
  mov esi, [gf_dayly_kof_adress]  
  movzx eax, word[esi]
  sub eax, 65535 / 2
  mov [tmp_int], eax
  fild [tmp_int]
  fdiv [tmp_div]
  fstp [gf_Dayly_kof]                                                                    

  ret           
endp


proc gf_subscribeDayly, DaylyKofAdress, flag
    mov eax, [DaylyKofAdress]
    mov [gf_dayly_kof_adress], eax
    mov eax, [flag]
    mov [gf_isAutoWhether], al
  ret
endp
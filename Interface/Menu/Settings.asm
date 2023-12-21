include "..\..\Grafic\GraficAPI\gf_assets\gf_macro.ASM"

proc ui_renderMenuSettings, WindowRect 
    locals 
      curBackgroundAdd   dd   ? 
      addPos             dd   0.01
      
      n_TEXT             dd    25.0
      n_2                dd   2.0
      err_text_size      dd   0.005
      textWidth          dd   ?
      textHeight         dd   ?
      textX              dd   ?
    endl
    fld [backGroundAdd]
    fadd [addPos]
    fstp [backGroundAdd]
    
    invoke glColor3f, 1.0, 1.0, 1.0
    stdcall ui_draw_text, [WindowRect], start_host_text, [start_host_text_len], -0.5, 0.75, 0.006
    
    stdcall ui_render_input, [WindowRect], -0.4, 0.5, 0.8, 0.15,     10, \
                             tcp_port_text, [tcp_port_text_len], ConnectionTcpPort_input     
                                          
    stdcall ui_render_input, [WindowRect], -0.4, 0.3, 0.8, 0.15,     11, \
                             udp_port_text, [udp_port_text_len], ConnectionUdpPort_input 
                                          
    stdcall ui_render_input, [WindowRect], -0.4, 0.1, 0.8, 0.15,     12, \
                             input_ip_text, [input_ip_text_len], ConnectionIP_input
                             
    stdcall ui_drawButton, [WindowRect], -0.35, -0.15, 0.7, 0.15,     4,  HOST_text, 4
    
    
    ;=========== Error Text ==================
    cmp [host_error], 0 
    jz .SkipErrorText   
        fld [n_2]
        fdiv [n_TEXT]
        fstp [err_text_size]
        stdcall ui_getTextSizes, [WindowRect], [host_error_len], [err_text_size]
        mov [textWidth], eax
        mov [textHeight], ecx  
    
        fld [n_2]
        fsub [textWidth]
        fdiv [n_TEXT]
        fstp [textX]
        
       invoke glColor3f, 1.0, 0.3, 0.3
       mov eax, [host_error]
       cmp eax, connection_try
       jnz .Skip1
           invoke glColor3f, 1.0, 0.73, 0.0
       .Skip1:
       cmp eax, connection_success
       jnz .Skip2
           invoke glColor4f, 0.4, 0.7, 0.4, 1.0 
       .Skip2:
       
       stdcall ui_draw_text, [WindowRect], [host_error], [host_error_len], [textX], -0.3, 0.005
    .SkipErrorText:
    ;=========================================
    
    invoke glColor3f, 1.0, 1.0, 1.0
    stdcall ui_draw_text, [WindowRect], set_radius_text, [set_radius_text_len], -0.4, -0.45, 0.006
    
    stdcall ui_render_input, [WindowRect], -0.4, -0.65, 0.8, 0.15,     13, \
                             input_radius_text, [input_radius_text_len], RenderRadius_input
    
    

    stdcall ui_drawButton, [WindowRect], 0.45, -0.95, 0.5, 0.15,      2, Continue_text, 8
    stdcall ui_drawButton, [WindowRect], -0.95, -0.95, 0.5, 0.15,     3, Menu_text, 4
  
    fld [backGroundAdd]
    fcos 
    fstp [curBackgroundAdd]
    stdcall ui_renderBackground, [WindowRect], [curBackgroundAdd]
  ret
endp

proc Client.Init_event
  stdcall Client.Init, ServerIp, [ServerPortUDP], [ServerPortTCP]
  stdcall Client.SendWorld, [Field.Blocks], [WorldLength], [WorldWidth], [WorldHeight]
  ret
endp


proc ConnectEvent_host 
  locals
    threadH  dd  ?
  endl
  
    mov [host_error], connection_try
    mov eax, [connection_try_len]
    mov [host_error_len], eax

    mov [IS_ONLINE],    TRUE   
    mov [IS_HOST],      TRUE
    
    stdcall CopyConnectionData
    
    invoke CreateThread, 0, 0, Client.Init_event, 0, 0, 0
    mov [threadH], eax
    
    invoke WaitForSingleObject, [threadH], 20000
    cmp eax, WAIT_TIMEOUT
    jnz .SkipErrThered
        invoke TerminateThread, [threadH]
        jmp .Error 
    .SkipErrThered:
    jmp .Succsess
    
    .Error:
    mov [host_error], connection_error
    mov eax, [connection_error_len]
    mov [host_error_len], eax
    mov [IS_ONLINE],    FALSE   
    mov [IS_HOST],      FALSE
    stdcall client.StopServe_PlayerData 
    jmp .Result
    
    .Succsess:
    mov [host_error], connection_success
    mov eax, [connection_success_len]
    mov [host_error_len], eax
    
    .Result:
  ret
endp

proc ui_MenuSettingsController, WindowRect 
  locals 
    threadH  dd  ?
  endl
  mov [CurFocus], 0

  switch  [Selected_ButtonId]
  case    .Continue,       2
  case    .Exit,           3
  case    .Host,           4
  case    .IpFocus,       12
  case    .UdpFocus,      11
  case    .TcpFocus,      10
  case    .RadiusFocus,   13
  jmp     .Return
  
  .Continue:
    mov [UI_MODE], UI_GAME
    stdcall ct_change_mouse, 0
    mov [IS_MAP_READY], TRUE
    ;SEt last pos
  jmp .Return   
  .Exit:
    stdcall client.StopServe_PlayerData 
    mov [IS_ONLINE],    FALSE   
    mov [IS_HOST],      FALSE
    mov [IS_MAP_READY], FALSE
    
    stdcall gf_2D_Render_Start 
    stdcall ui_renderBackground, [WindowRect], 0.0
    stdcall gf_2D_Render_End
    invoke SwapBuffers, [hdc]
    invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT
    cmp [IS_CLIENT_GAME], FALSE
    jnz .SkipSave
      stdcall Field.SaveInFileWorld, [Field.Blocks], [WorldLength], [WorldWidth], [WorldHeight], [SizeWorld], [ChosenFile]
       
    .SkipSave:
    stdcall DestroyWorld
    mov [App_Mode], MENU_MODE
    stdcall ui_InterfaceInit
    stdcall ResetGameData
    mov [IS_CLIENT_GAME], FALSE
  jmp .Return 
  .Host:
      mov eax, [host_error]
      cmp eax, connection_try
      jz .Return
      cmp [IS_CLIENT_GAME], FALSE
      jnz .GetErrorClient
    ;Start Host
    invoke CreateThread, 0, 0, ConnectEvent_host, 0, 0, 0 
    jmp .Return 

    .GetErrorClient:
        mov [host_error], client_error
        mov eax, [client_error_len]
        mov [host_error_len], eax
    jmp .Return 
  .IpFocus:
     mov [CurFocus], 12
  jmp .Return 
  .UdpFocus:
     mov [CurFocus], 11
  jmp .Return  
  .TcpFocus:
     mov [CurFocus], 10
     jmp .Return 
  .RadiusFocus:
     mov [CurFocus], 13
  jmp .Return      
  
  .Return:
  ret
endp


proc ui_EscMenuInputController, wParam
  switch  [CurFocus]
  case    .IpFocus,       12
  case    .UdpFocus,      11
  case    .TcpFocus,      10
  case    .RadiusFocus,   13
  jmp     .Return
  
  .IpFocus:
     stdcall AddLetterToInput, ConnectionIP_input, [wParam], 1, 1
  jmp .Return 
  .UdpFocus:
     mov [MAX_LEN_INPUT], 5
     stdcall AddLetterToInput, ConnectionUdpPort_input, [wParam], 0, 1
     mov [MAX_LEN_INPUT], 15
  jmp .Return  
  .TcpFocus:
     mov [MAX_LEN_INPUT], 5
     stdcall AddLetterToInput, ConnectionTcpPort_input, [wParam], 0, 1
     mov [MAX_LEN_INPUT], 15
  jmp .Return 
  .RadiusFocus:    
     mov [MAX_LEN_INPUT], 2
     stdcall AddLetterToInput, RenderRadius_input, [wParam], 0, 1
     stdcall GetNumFromInput, RenderRadius_input
     cmp eax, 5
     jge @F
        mov eax, 5
     @@:
     cmp eax, 100
     jle @F
        mov eax, 100
     @@:
     mov [RENDER_RADIUS], eax
     stdcall Set_GF_RENDER_BLOCKS_RADIUS,  [RENDER_RADIUS], [RENDER_RADIUS], [RENDER_RADIUS]
     mov [MAX_LEN_INPUT], 15
  jmp .Return 
  
  .Return:
  ret
endp
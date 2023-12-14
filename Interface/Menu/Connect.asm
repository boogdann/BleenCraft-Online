include "..\..\Grafic\GraficAPI\gf_assets\gf_macro.ASM"

proc ui_renderMenuConnect, WindowRect 

  locals
    curBackgroundAdd   dd   ? 
  endl

  stdcall gf_2D_Render_Start 
  ;############################################################################
    stdcall ui_render_input, [WindowRect], -0.4, 0.2, 0.8, 0.15,     10, \
                             tcp_port_text, [tcp_port_text_len], ConnectionTcpPort_input
                                          
    stdcall ui_render_input, [WindowRect], -0.4, -0.0, 0.8, 0.15,     11, \
                             udp_port_text, [udp_port_text_len], ConnectionUdpPort_input 
                                          
    stdcall ui_render_input, [WindowRect], -0.4, -0.2, 0.8, 0.15,     12, \
                             input_ip_text, [input_ip_text_len], ConnectionIP_input
  ;############################################################################
  
    stdcall ui_drawButton, [WindowRect], -0.3, -0.45, 0.6, 0.2,      2, CONNECT_text, 7
    stdcall ui_drawButton, [WindowRect], -0.9, -0.9, 0.4, 0.15,      3, BACK_text, 4
    
    fld [backGroundAdd]
    fcos 
    fstp [curBackgroundAdd]
    
  stdcall ui_renderBackground, [WindowRect], [curBackgroundAdd]
    

  stdcall gf_2D_Render_End
  
  invoke SwapBuffers, [hdc]
  invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT


  ret
endp


proc ui_MenuConnectController, WindowRect
  mov [CurFocus], 0
 
  switch  [Selected_ButtonId]
  case    .Connect,       2
  case    .Exit,          3
  case    .IpFocus,       12
  case    .UdpFocus,      11
  case    .TcpFocus,      10
  jmp     .Return
  
  .Connect:
    ;Connect
  jmp .Return   
  .Exit:
    mov [CUR_MENU], UI_MAIN_MENU
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
  
  .Return:
  ret
endp


proc ui_ConnectInputController, wParam
  switch  [CurFocus]
  case    .IpFocus,       12
  case    .UdpFocus,      11
  case    .TcpFocus,      10
  jmp     .Return
  
  .IpFocus:
     stdcall AddLetterToInput, ConnectionIP_input, [wParam], 1, 1
  jmp .Return 
  .UdpFocus:
     stdcall AddLetterToInput, ConnectionUdpPort_input, [wParam], 0, 1
  jmp .Return  
  .TcpFocus:
     stdcall AddLetterToInput, ConnectionTcpPort_input, [wParam], 0, 1
  jmp .Return 
  
  .Return:
  ret
endp
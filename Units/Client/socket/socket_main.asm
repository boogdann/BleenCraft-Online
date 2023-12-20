proc ws_soket_init
  invoke WSAStartup, [ws_soket_version], ws_wsa
  cmp eax, 0
  jne .error
  jmp .return
  .error:
     stdcall ws_socket_error, ws_socket_init_err
     stdcall ws_close_connection
  .return:
  ret
endp

proc ws_new_socket, socket_type  ;WS_UDP/WS_TCP
  locals 
    type       dd   ?
    protocol   dd   ?
  endl

  ;udp case
  cmp [socket_type], WS_UDP
  jnz @F
    mov [type], SOCK_DGRAM
    mov [protocol], IPPROTO_UDP 
    jmp .data_ready
  @@:
  ;tcp case
  cmp [socket_type], WS_TCP
  jnz @F
    mov [type], SOCK_STREAM
    mov [protocol], IPPROTO_TCP
    jmp .data_ready
  @@:
  ;else
  jmp .error
  .data_ready:
  
  invoke socket, AF_INET, [type], [protocol]
  cmp eax, INVALID_SOCKET
  jz .error
  mov [ws_socket_handle], eax  
  
  invoke setsockopt, eax, SOL_SOCKET, SO_KEEPALIVE, ws_bOptVal, [ws_bOptLen]
  cmp eax, 0
  jnz .error
      
  jmp .return
  .error:
      stdcall ws_socket_error, ws_socket_init_err    
  .return:
  ;return socket discriptor in eax
  mov eax, [ws_socket_handle]
  ret
endp

proc ws_new_connection_structure, ip, port

  invoke GetProcessHeap
  invoke HeapAlloc, eax, 0, sizeof.sockaddr_in
  mov esi, eax
  
  mov     [esi + sockaddr_in.sin_family], AF_INET
  invoke  htons, [port]
  mov     [esi + sockaddr_in.sin_port], ax 
  invoke  inet_addr, [ip]
  mov     [esi + sockaddr_in.sin_addr], eax
  
  mov eax, esi

  ret
endp

;wrapper function for tcp connection
proc ws_tcp_connect, socket_handle, server_addr
  invoke connect, [socket_handle], [server_addr], sizeof.sockaddr
  cmp eax, SOCKET_ERROR
  jnz @F
     stdcall ws_socket_error, ws_tcp_connect_err  
  @@:
  
  ret
endp

;wrapper function for close socket
proc ws_close_connection
  invoke WSACleanup
  ret
endp

;error helper
proc ws_socket_error, err
  ;mov   eax, -1
  ;invoke MessageBoxA, 0, [err], ws_error_caption, 0
  ret
endp                     
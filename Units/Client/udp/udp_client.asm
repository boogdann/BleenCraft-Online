;example udp client chat
proc start_udp_chat, socket_handle, soket_data_addr, hStdOut, hStdIn

  .chat_loop:
    invoke WriteConsoleA, [hStdOut], write_msg_text_udp, [write_msg_text_len_udp], chrsWritten_udp, 0
    ;Reading a message
    invoke ReadConsoleA, [hStdIn], request_buf_udp, 255, chrsRead_udp, 0
    
    ;Sending a message
    stdcall ws_socket_send_msg, [socket_handle], [soket_data_addr], request_buf_udp, [chrsRead_udp], WS_UDP  
    cmp eax, SOCKET_ERROR
    jnz @F
      stdcall ws_socket_error, msg_send_err_udp
      jmp .Exit
    @@:
    
    ;Receiving a message
    stdcall ws_socket_get_msg, [socket_handle], response_buf_udp, [response_buf_len_udp]  
    cmp eax, 0
    jge @F
      stdcall ws_socket_error, msg_get_err_udp
      jmp .Exit
    @@:
    
    ;Message output
    mov word[response_buf_udp + eax], $0D0A
    add eax, 2
    invoke WriteConsoleA, [hStdOut], response_buf_udp, eax, chrsWritten_udp, 0
  jmp .chat_loop
  
  .Exit:
  ret
endp
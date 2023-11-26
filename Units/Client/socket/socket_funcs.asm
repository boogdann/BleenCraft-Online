proc ws_socket_send_msg_udp, socket, soket_info, msg, msg_len
  invoke sendto, [socket], [msg], [msg_len], 0, [soket_info], sizeof.sockaddr_in
  ret
endp

proc ws_socket_send_msg_tcp, socket, msg, msg_len
  invoke send, [socket], [msg], [msg_len], 0
  ret
endp

proc ws_socket_get_msg_udp, socket, buf, buf_len 
  invoke recvfrom, [socket], [buf], [buf_len], 0, ws_server_addr, ws_server_addr_len
  ret
endp

proc ws_socket_get_msg_tcp, socket, buf, buf_len
  invoke recv, [socket], [buf], [buf_len]
  ret
endp
  
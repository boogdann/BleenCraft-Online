ws_error_caption     db   'socket error', 0
ws_socket_init_err   db   'Socket initialize failed', 0
ws_tcp_connect_err   db   'TCP connection failed', 0

ws_wsa               WSADATA
ws_sock_addr         sockaddr_in
ws_soket_version     dd    0202h

ws_server_addr    sockaddr

ws_bOptVal           dd    1
ws_bOptLen           dd    $ - ws_bOptVal

ws_server_addr_len   dd   sizeof.sockaddr 

ws_socket_handle     dd   ? 



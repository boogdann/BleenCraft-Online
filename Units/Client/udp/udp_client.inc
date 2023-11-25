;console messages
write_msg_text_udp      db   'Enter message: ', 0
write_msg_text_len_udp  dd   $ - write_msg_text_udp 

;error_messages
msg_send_err_udp        db    'message send failed', 0
msg_get_err_udp         db    'message get failed', 0


;response data
response_buf_udp        db    1024 dup (?)
response_buf_len_udp    dd    $ - response_buf_udp
chrsRead_udp            dd    ?

;request data
request_buf_udp         db   100  dup  (?)
chrsWritten_udp         dd     ?



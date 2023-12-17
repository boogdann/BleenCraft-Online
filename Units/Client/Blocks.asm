proc Client.SendBlock uses edi ecx ebx esi, X, Y, Z, BlockIndex
     locals
       hHeap   dd ?
       toSend  dd ?
       dataMsg dd ?
     endl
     
     invoke GetProcessHeap
     mov     [hHeap], eax     

     invoke HeapAlloc, [hHeap], HEAP_ZERO_MEMORY, Client.SERVER_MSG_SIZE
     mov     [toSend], eax

     invoke HeapAlloc, [hHeap], HEAP_ZERO_MEMORY, Client.SERVER_DATA_SIZE 
     mov     [dataMsg], eax
         
     stdcall Client.SetData, [dataMsg], [X], [Y], [Z], [BlockIndex]
     
     stdcall Client.GetMessage, [Client.MSGBlockState], Client.Secret, [Client.SizeSecret], \
                                [Client.GroupID], [Client.Number], [dataMsg], Client.SERVER_DATA_SIZE, [toSend] 
                                       
     stdcall ws_socket_send_msg_tcp, [Client.hTCPQueueClient], [toSend], eax     
.Finish:
     ret
endp

proc Client.SendToServerThread, params 
  locals
      hHeap          dd ?
      recievedBytes1 dd 0
      recievedBytes2 dd 0
      msg1           dd ?
      msg2           dd ?
      sizeMsg1       dd ?
      sizeMsg2       dd ?

  endl
  
  mov    dword[sizeMsg1], Client.SERVER_MSG_SIZE
  mov    dword[sizeMsg2], Client.SERVER_MSG_SIZE
  ;  1 - from 1-st thread
  ;  2 - from go-server
  invoke GetProcessHeap
  
  push   eax
  invoke HeapAlloc, eax, HEAP_ZERO_MEMORY, Client.SERVER_MSG_SIZE + 10 
  mov    [Client.ServerMsgAddr], eax  
  mov    [msg1], eax
  pop    eax
  
  invoke HeapAlloc, eax, HEAP_ZERO_MEMORY, Client.SERVER_MSG_SIZE + 10 
  mov    [msg2], eax   
     
  stdcall ws_new_socket, WS_TCP  
  mov     dword[Client.hTCPQueueServer], eax
  cmp     eax, -1
  jz      .Error
     
  stdcall ws_new_connection_structure, Client.YourIP, [Client.YourPort]
  mov     dword[Client.sockAddrTCPQueueServer], eax  
  
  invoke bind, [Client.hTCPQueueServer], [Client.sockAddrTCPQueueServer], sizeof.sockaddr_in  
  invoke listen, [Client.hTCPQueueServer], 1
  
  invoke accept, [Client.hTCPQueueServer], 0, 0
  mov    dword[Client.hTCPQueueServer], eax
  
  ;invoke ioctlsocket, dword[Client.hTCPQueueServer], FIONBIO, one
  ;invoke ioctlsocket, dword[Client.hTCPSock], FIONBIO, one
  
.GetMsg:
  stdcall Client.GetNumberOfBytesTCP, [Client.hTCPQueueServer], [msg1], [sizeMsg1]

  stdcall ws_socket_send_msg_tcp, [Client.hTCPSock], [Client.ServerMsgAddr], Client.SERVER_MSG_SIZE
  cmp     eax, -1
  jz      .Error

;  mov     eax, [recievedBytes1]
;  mov     ebx, [sizeMsg1]
;  sub     ebx, eax
;  
;  mov     edi, [msg1]
;  add     edi, eax
;   invoke  ExitProcess, 1
;  cmp     ebx, 0
;  ja    @F
;  stdcall ws_socket_send_msg_tcp, [Client.hTCPSock], [Client.ServerMsgAddr], Client.SERVER_MSG_SIZE 
;  mov     dword[recievedBytes1], 0
; jmp     .GetMsg
;@@:    
;
;  stdcall ws_socket_get_msg_tcp, [Client.hTCPQueueClient], edi, ebx  
;  add     [recievedBytes1], eax
;  invoke  ExitProcess, 1

;  mov     eax, [recievedBytes2]
;  mov     ebx, [sizeMsg2]
;  sub     ebx, eax
;  
;  mov     edi, [msg2]
;  add     edi, eax
;  
;  cmp     ebx, 0
;  ja    @F
;  stdcall HandleMessage, [msg2], Client.SERVER_MSG_SIZE    
;  mov     dword[recievedBytes2], 0
;@@:
;
;  stdcall ws_socket_get_msg_tcp, [Client.hTCPSock], edi, ebx
;  invoke  ExitProcess, 1
;  cmp     eax, -1
;  jz      .Finish
;  
;  add     [recievedBytes2], eax
    
  jmp    .GetMsg
.Error:
     mov eax, -1  
.Finish:
     ;invoke  ExitProcess, 1
     ret
endp

proc Client.GetFromServer, params
  locals
      msg     dd ?
      sizeMsg dd Client.SERVER_MSG_SIZE 
  endl

  invoke GetProcessHeap
  
  invoke HeapAlloc, eax, HEAP_ZERO_MEMORY, Client.SERVER_MSG_SIZE + 10   
  mov    [msg], eax
  
.GetMsg:
     stdcall ws_socket_get_msg_tcp, [Client.hTCPSock], [msg], [sizeMsg]
     cmp     eax, -1
     jz      .Finish
     ; stdcall Client.GetNumberOfBytesTCP, [Client.hTCPSock], [msg], [sizeMsg]
     
;     stdcall Client.GetType, [msg], eax
;     cmp     eax, [Client.MSGHandBlock]
;     jnz     .GetMsg
     
     stdcall HandleMessage, [msg], [sizeMsg]
     ;invoke  ExitProcess, 1
     jmp     .GetMsg
       
.Finish:
     ret
endp

proc HandleMessage uses eax edi esi ebx, msg, size
     mov     edi, [msg]
     add     edi, Client.HEADER_SIZE
     stdcall Client.SetBlockIndex, dword[edi], dword[edi+4], dword[edi+8], dword[edi+12]
     ;invoke  ExitProcess, 1

.Finish:
     ret
endp

proc Client.SetBlockIndex uses edi eax esi ecx ebx ecx, X, Y, Z, BlockIndex
     xor    eax, eax
     
     stdcall Field.TestBounds, [X], [Y], [Z]
     cmp     eax, ERROR_OUT_OF_BOUND
     jz      .Finish
     
     mov    eax, dword[Y]  
     
     xor    edx, edx 
     mov    edi, [Field.Length]
     mul    edi
     
     mov    edi, dword[X]
     add    eax, edi
     
     xchg   eax, edi
     
     xor    edx, edx
     mov    esi, dword[Z]
     mov    eax, [Field.Length]
     mov    ecx, [Field.Width]
     mul    ecx
     mul    esi
     
     add    eax, edi

     add    eax, [Field.Blocks]
     
     xchg   eax, edi
     movzx  eax, byte[BlockIndex]
     mov    byte[edi], al

     jmp    .Finish
.Finish:
     ret
endp

proc Client.SetData uses edi eax, pData, X, Y, Z, BlockIndex
     mov     edi, [pData]   
     
     mov     eax, [X]
     mov     dword[edi], eax
     
     mov     eax, [Y]
     mov     dword[edi+4], eax
     
     mov     eax, [Z]
     mov     dword[edi+8], eax
          
     mov     eax, [BlockIndex]
     mov     dword[edi+12], eax
.Finish:
     ret
endp
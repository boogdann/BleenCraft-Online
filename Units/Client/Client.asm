proc Client.Init uses edx ecx ebx, serverIp, serverPortUDP, serverPortTCP
  stdcall ws_soket_init 
  
  stdcall ws_new_socket, WS_UDP
  mov     dword[Client.hUDPSock], eax
  
  stdcall ws_new_connection_structure, [serverIp], [serverPortUDP]
  mov     dword[Client.sockAddrUDP], eax
  
  stdcall ws_socket_send_msg_udp, [Client.hUDPSock], [Client.sockAddrUDP], Client.Secret, [Client.SizeSecret]  

  stdcall ws_socket_get_msg_udp, [Client.hUDPSock], Client.ReadBuffer, [Client.SizeBuffer]
    
  stdcall ws_new_socket, WS_TCP
  mov     dword[Client.hTCPSock], eax
  
  stdcall ws_new_connection_structure, [serverIp], [serverPortTCP]
  mov     dword[Client.sockAddrTCP], eax  
  
  stdcall ws_tcp_connect, [Client.hTCPSock], [Client.sockAddrTCP]
  
  stdcall ws_socket_send_msg_tcp, [Client.hTCPSock], Client.Secret, [Client.SizeSecret]  
  
  stdcall ws_socket_get_msg_tcp, [Client.hTCPSock], Client.ReadBuffer, [Client.SizeBuffer]
.Skip:
  
.Finish:
     ret
endp

proc Client.SendWorld uses edx ecx ebx edi, pWorld, SizeX, SizeY, SizeZ
     locals
        hHeap      dd ?
        buffer     dd ?
        bufferSize dd ?
        written    dd ?
        msgAddr    dd ?
        sizeMsg    dd ?
     endl
     
     mov     dword[bufferSize], 50000000
     invoke  GetProcessHeap
     mov     [hHeap], eax
     
     invoke  HeapAlloc, [hHeap], HEAP_ZERO_MEMORY, [bufferSize]
     mov     [buffer], eax

     stdcall Client.MarshalWorld, [pWorld], [SizeX], [SizeY], [SizeZ], [buffer]
     mov     dword[written], eax
     
     mov     ebx, [written]
     add     ebx, [Client.SizeSecret]
     add     ebx, 120 ; 4 - type msg
                      ; 4 - groupID
                      ; 4 - userID
     mov     [sizeMsg], ebx
                          
     invoke  HeapAlloc, [hHeap], HEAP_ZERO_MEMORY, ebx
     mov     [msgAddr], eax  
          
     stdcall Client.GetMessage, [Client.MSGStartSendWorld], Client.Secret, [Client.SizeSecret], \
                                [Client.GroupID], [Client.Number], [buffer], 0, [msgAddr] 
                                
     stdcall ws_socket_send_msg_tcp, [Client.hTCPSock], [msgAddr], eax

     mov     edi, [written]
.SendWorld: 
     cmp     edi, Client.MAX_SIZE_MSG
     jle     .SendNotFull
     mov     edx, Client.MAX_SIZE_MSG
     jmp     .GetMSG
.SendNotFull:
     mov     edx, edi     
.GetMSG:
     sub     edi, edx
     stdcall Client.GetMessage, [Client.MSGSendWorld], Client.Secret, [Client.SizeSecret], \
                                [Client.GroupID], [Client.Number], [buffer], edx, [msgAddr] 
     add     dword[buffer], edx 
     
     cmp     edx, Client.MAX_SIZE_MSG + Client.HEADER_SIZE 
     jnl     .SkipClearBuffer
.ClearBuffer:
     mov     esi, [msgAddr]
     add     esi, edx
     mov     byte[esi], 0

     inc     edx
     cmp     edx, Client.MAX_SIZE_MSG + Client.HEADER_SIZE 
     jl      .ClearBuffer

.SkipClearBuffer:

     stdcall ws_socket_send_msg_tcp, [Client.hTCPSock], [msgAddr], Client.MAX_SIZE_MSG + Client.HEADER_SIZE
     
     cmp     edi, 0
     jnle    .SendWorld
     
     stdcall Client.GetMessage, [Client.MSGEndSendWorld], Client.Secret, [Client.SizeSecret], \
                                [Client.GroupID], [Client.Number], [buffer], 0, [msgAddr] 
                                
     stdcall ws_socket_send_msg_tcp, [Client.hTCPSock], [msgAddr], eax 
     
     jmp     .Finish
.Error:
     invoke ExitProcess, 1
.Finish:
     invoke HeapFree, [hHeap], 0, [buffer]
     invoke HeapFree, [hHeap], 0, [sizeMsg] 
     ret
endp

proc Client.GetWorld, pWorld, pSizeX, pSizeY, pSizeZ
     locals
        hHeap      dd ?
        buffer     dd ?
        bufferSize dd ?
        written    dd ?
        msgAddr    dd ?
        sizeMsg    dd ?
     endl
     
          mov     dword[bufferSize], 50000000
     invoke  GetProcessHeap
     mov     [hHeap], eax
     
     invoke  HeapAlloc, [hHeap], HEAP_ZERO_MEMORY, [bufferSize]
     mov     [buffer], eax
     
     invoke  HeapAlloc, [hHeap], HEAP_ZERO_MEMORY, 
     mov     [msgAddr], eax 

     stdcall Client.GetMessage, [Client.MSGSendWorld], Client.Secret, [Client.SizeSecret], \
                                [Client.GroupID], [Client.Number], [buffer], 0, [msgAddr]      
     
     
     
     

.Finish:
     ret
endp

proc Client.GetMessage uses edx ecx edi, typeMsg, secretMsg, sizeSecretMsg, groupID, \
                       userID, msg, sizeMsg, res
     locals
       hHead   dd ?
     endl
     
     mov    edi, [res]
     
     mov    eax, [typeMsg]
     mov    dword[edi], eax
     add    edi, 4
     
     mov    ecx, [sizeSecretMsg]
     mov    esi, [secretMsg]
     repe   movsb
     
     mov   eax, [groupID]
     mov   dword[edi], eax
     add   edi, 4
     mov   eax, [userID]
     mov   dword[edi], eax
     add   edi, 4
     
     cmp   [sizeMsg], 0
     jz    @F
     mov   ecx, [sizeMsg]
     mov   esi, [msg]
     repe  movsb
@@:     
     mov   eax, 12
     add   eax, [sizeMsg]
     add   eax, [sizeSecretMsg]           
.Finish:
     ret
endp    

proc Client.MarshalWorld uses edx ecx ebx esi edi, pWorld, SizeX, SizeY, SizeZ, buf 
     locals
        size dd ?
        num  dd ?
     endl
     mov     esi, [buf]
     mov     dword[num], 0
     
     xor     edx, edx
     mov     eax, [SizeX]
     mul     dword[SizeY]
     mul     dword[SizeZ]
     
     mov     dword[size], eax
     
     mov     dword[esi], eax
     add     esi, 4
     add     dword[num], 4
     
     mov    eax, [SizeX]
     mov    dword[esi], eax 
     add    esi, 4
     add    dword[num], 4
     
     mov    eax, [SizeY]
     mov    dword[esi], eax
     add    esi, 4
     add    dword[num], 4

     mov    eax, [SizeZ]
     mov    dword[esi], eax
     add    esi, 4
     add    dword[num], 4   
     
     mov     edi, [pWorld]
     mov     ecx, [size]
.IterateData:
     mov     al, byte[edi]
     mov     ebx, ecx
     repz    scasb
     dec     edi
     inc     ecx

     sub     ebx, ecx
     mov     byte[esi+4], al
     mov     dword[esi], ebx        
     add     esi, 5
     add     dword[num], 5 
  
     cmp     ecx, 1
     ja      .IterateData
             
.Finish:
     mov     eax, dword[num]
     ret
endp

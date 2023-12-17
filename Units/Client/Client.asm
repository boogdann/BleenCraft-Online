Client.msg.SendWorld         equ  0   
Client.msg.PlayerData        equ  1   
Client.msg.BlockState        equ  2  
Client.msg.HandBlock         equ  3 
Client.msg.GetWorld          equ  4
Client.msg.UserState         equ  5 
Client.msg.Rotations         equ  6 
Client.msg.TCPInit           equ  7
Client.msg.UDPInit           equ  8 
Client.msg.StartSendWorld    equ  9 
Client.msg.EndSendWorld      equ  10 

include 'playerData/player.ASM'


proc Client.Init uses edx ecx ebx, serverIp, serverPortUDP, serverPortTCP
  stdcall ws_soket_init 
  
  stdcall ws_new_socket, WS_UDP
  cmp     eax, -1
  jz      .Error
  
  mov     dword[Client.hUDPSock], eax
  
  stdcall ws_new_connection_structure, [serverIp], [serverPortUDP]
  mov     dword[Client.sockAddrUDP], eax
  
  stdcall ws_socket_send_msg_udp, [Client.hUDPSock], [Client.sockAddrUDP], Client.Secret, [Client.SizeSecret] 
;  cmp     eax, 0
;  jz      .Error   

  stdcall ws_socket_get_msg_udp, [Client.hUDPSock], Client.ReadBuffer, [Client.SizeBuffer]
;  cmp     eax, 0
;  jz      .Error

  ;================================== Subscribe player's data =============================================
  ;Function send data only if this data changed, so you shuld to subscribe player data:
  ;1 - *player position
  ;2 - *player turn
  ;3 - *item in player hand
  ;4 - *player state                                         ;HandItem, PlayerState !!!
  stdcall client.Subscribe_PlayerData, PlayerPos, PlayerTurn, PlayerPos, PlayerTurn

  ;Then you can start serving data:
  ;last parametr (5-n) - time of ("invoke Sleep") in every loop iteration  |     [PlId],           [GrId]         (Sleep)
  stdcall client.Serve_PlayerData, [Client.hUDPSock], [Client.sockAddrUDP], [Client.GroupID], [Client.Number],     300

  ;To kill this flow you can use: (not implemented yet)
  ;stdcall client.StopServe_PlayerData
  ;========================================================================================================
  
  stdcall ws_new_socket, WS_TCP
  cmp     eax, -1
  jz      .Error
  
  mov     dword[Client.hTCPSock], eax  
  stdcall ws_new_connection_structure, [serverIp], [serverPortTCP]
  mov     dword[Client.sockAddrTCP], eax  
  
  stdcall ws_tcp_connect, [Client.hTCPSock], [Client.sockAddrTCP]
;  cmp     eax, -1
;  jz      .Error
  
  stdcall ws_socket_send_msg_tcp, [Client.hTCPSock], Client.Secret, [Client.SizeSecret]  
;  cmp     eax, 0
;  jz      .Error
  stdcall ws_socket_get_msg_tcp, [Client.hTCPSock], Client.ReadBuffer, [Client.SizeBuffer]
;  cmp     eax, 0
;  jz      .Error

;  mov    dword[one], 1
;  invoke ioctlsocket, dword[Client.hTCPSock], FIONBIO, one
;  cmp    eax, 0
;  jz     @F
;  invoke ExitProcess, 1
;@@:
      
  jmp     .Finish
.Error:
  mov     eax, -1
.Finish:
     ret
endp

proc Client.Destroy
     invoke closesocket, [Client.hTCPSock]
     invoke closesocket, [Client.hUDPSock]
     invoke closesocket, [Client.hTCPQueueClient]
     invoke closesocket, [Client.hTCPQueueServer]
.Finish:
     ret
endp

proc Client.StartTCPServer
     invoke  CreateThread, 0, 0, Client.SendToServerThread, Client.hUDPSock, 0, 0

     ;socket for work with threads     
     stdcall ws_new_socket, WS_TCP  
     mov     dword[Client.hTCPQueueClient], eax
     cmp     eax, -1
     jz      .Error
  
     stdcall ws_new_connection_structure, Client.YourIP, [Client.YourPort]
     mov     dword[Client.sockAddrTCPQueueClient], eax  
  
     stdcall ws_tcp_connect, [Client.hTCPQueueClient], [Client.sockAddrTCPQueueClient]

     invoke  CreateThread, 0, 0, Client.GetFromServer, Client.hUDPSock, 0, 0
     jmp     .Finish
.Error:
     mov     eax, -1
     invoke  ExitProcess, 1
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
                                
     stdcall ws_socket_send_msg_tcp, [Client.hTCPSock], [msgAddr], Client.HEADER_SIZE 

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
     
     mov     esi, [msgAddr]
     add     esi, eax
     
     ;cmp     eax, Client.MAX_SIZE_MSG
     cmp     eax, Client.MAX_SIZE_MSG + Client.HEADER_SIZE 
     jz      .SkipClearBuffer
.ClearBuffer:
     mov     esi, [msgAddr]
     add     esi, eax
     mov     byte[esi], 0
     inc     eax
     ;cmp     edx, Client.MAX_SIZE_MSG 
     cmp     eax, Client.MAX_SIZE_MSG + Client.HEADER_SIZE 
     jl     .ClearBuffer

.SkipClearBuffer:

     stdcall ws_socket_send_msg_tcp, [Client.hTCPSock], [msgAddr], Client.MAX_SIZE_MSG + Client.HEADER_SIZE
     
     cmp     edi, 0
     jnle    .SendWorld
     
     stdcall Client.GetMessage, [Client.MSGEndSendWorld], Client.Secret, [Client.SizeSecret], \
                                [Client.GroupID], [Client.Number], [buffer], 0, [msgAddr] 
                                
     stdcall ws_socket_send_msg_tcp, [Client.hTCPSock], [msgAddr], Client.MAX_SIZE_MSG + Client.HEADER_SIZE
     
     jmp     .Finish
.Error:
     invoke ExitProcess, 1
.Finish:
     invoke HeapFree, [hHeap], 0, [buffer]
     invoke HeapFree, [hHeap], 0, [sizeMsg] 
     ret
endp

proc Client.GetWorld uses edx edi esi, pWorld, pSizeX, pSizeY, pSizeZ
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
     
     mov     dword[sizeMsg], Client.MAX_SIZE_MSG + Client.HEADER_SIZE
     invoke  HeapAlloc, [hHeap], HEAP_ZERO_MEMORY, Client.MAX_SIZE_MSG + Client.HEADER_SIZE + 1000
     mov     [msgAddr], eax

     stdcall Client.GetMessage, [Client.MSGGetWorld], Client.Secret, [Client.SizeSecret], \
                                [Client.GroupID], [Client.Number], [buffer], 0, [msgAddr] 
     stdcall ws_socket_send_msg_tcp, [Client.hTCPSock], [msgAddr], eax
     cmp     eax, -1
     jz      .Error
     
     mov     edi, [buffer]
     mov     ebx, 0     
.GetWorld:
     stdcall Client.GetNumberOfBytesTCP, [Client.hTCPSock], [msgAddr], [sizeMsg]
     cmp     eax, -1
     jz      .Error
          
     xchg    eax, ecx
     stdcall Client.GetType, [msgAddr], eax

     cmp     eax, [Client.MSGEndSendWorld]
     jnz     @F
     mov     ebx, ebx
@@:
     
     cmp     eax, [Client.MSGEndSendWorld]
     jz      .EndSendWorld
     
     cmp     eax, [Client.MSGGetWorld]
     jnz     .Continue

     xchg    eax, ecx
     sub     eax, Client.HEADER_SIZE
     
     xchg    eax, ecx
     cmp     ecx, 0
     jle     .Continue
     
     add     ebx, ecx
     mov     esi, [msgAddr]
     add     esi, Client.HEADER_SIZE
     
     rep movsb
.Continue:
     jmp .GetWorld
     
.EndSendWorld:
     stdcall Client.UnmarshalWorld, [buffer], ebx, [pWorld], [pSizeX], [pSizeY], [pSizeZ]
     jmp     .Finish
.Error:
     mov     eax, -1 
.Finish:
     ret
endp

proc Client.GetNumberOfBytesTCP uses edx ecx edi esi ebx, hSock, msgAddr, sizeMsg
     locals
         recievedBytes  dd   0
         addres         dd   ?
     endl

     mov     ebx, [msgAddr]
     mov     [addres],  ebx
.GetMsg:
     
     mov     eax, [recievedBytes]
     mov     ebx, [sizeMsg]
     sub     ebx, eax
          
     mov     edi, [addres]
     add     edi, eax
     
     cmp     ebx, 0
     jle     .Finish
         
     stdcall ws_socket_get_msg_tcp, [hSock], edi, ebx 
     cmp     eax, -1
     jz      .Error
     
     add     [recievedBytes], eax
     jmp     .GetMsg
     
     jmp     .Finish
.Error:
     mov     eax, -1
.Finish:
     ret
endp

proc Client.GetMessage uses edx ecx edi esi, typeMsg, secretMsg, sizeSecretMsg, groupID, \
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

proc Client.GetType uses ecx edi esi, msg, msgSize
     cmp    [msgSize], Client.HEADER_SIZE
     jz     .SetInitMsg
     
     mov    edi, [msg]
     add    edi, 4
     mov    esi, Client.Secret
     mov    ecx, [Client.SizeSecret]
     
     repe   cmpsb
     
     cmp    ecx, 0
     jnz    .Error
     
     mov    eax, [msg]
     mov    eax, dword[eax]
     jmp    .Finish
     
.SetInitMsg:
     mov    eax, [Client.MSGTCPInit]
     jmp    .Finish
.Error:
     mov    eax, -1
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

proc Client.UnmarshalWorld, buffer, sizeBuffer, pWorld, pSizeX, pSizeY, pSizeZ
     locals
         fullSize dd ?
         i        dd ?
     endl
     
     mov    esi, [buffer]
     mov    eax, [esi]
     mov    [fullSize], eax
     add    esi, 4
     
     mov    edi, [pSizeX]
     mov    eax, [esi]
     mov    [edi], eax
     add    esi, 4
     
     mov    edi, [pSizeY]
     mov    eax, [esi]
     mov    [edi], eax    
     add    esi, 4

     mov    edi, [pSizeZ]
     mov    eax, [esi]
     mov    [edi], eax
     add    esi, 4
          
     invoke GetProcessHeap
     invoke HeapAlloc, eax, HEAP_ZERO_MEMORY, [fullSize]
     xchg   edi, eax
     
     mov    eax, [pWorld]
     mov    dword[eax], edi
     
     mov    ebx, 0
.Unmarshal:
     mov    ecx, [esi]
     mov    al, byte[esi+4]
     
     rep    stosb
     
     add    esi, 5
     add    ebx, 5
     cmp    ebx, [sizeBuffer]
     jl    .Unmarshal

.Finish:
     ret
endp




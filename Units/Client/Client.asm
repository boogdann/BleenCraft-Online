proc Client.Init uses edx ecx ebx, serverIp, serverPort
  stdcall ws_soket_init 
  
  stdcall ws_new_socket, WS_UDP
  mov     dword[Client.hUDPSock], eax
  
  stdcall ws_new_connection_structure, [serverIp], [serverPort]
  mov     dword[Client.sockAddrUDP], eax
  
  stdcall ws_socket_send_msg, [Client.hUDPSock], [Client.sockAddrUDP], Client.Secret, [Client.SizeSecret]  

  stdcall ws_socket_get_msg, [Client.hUDPSock], Client.ReadBuffer, [Client.SizeBuffer]
  movzx   eax, byte[Client.ReadBuffer + Client.OffsetNumber]
  mov     [Client.Number], eax
.Finish:
     ret
endp

proc Client.SendWorld uses edx ecx ebx, pWorld, SizeX, SizeY, SizeZ
     locals
        hHeap      dd ?
        buffer     dd ?
        bufferSize dd ?
        written    dd ?
     endl
     
     mov    dword[bufferSize], 3000000
     invoke GetProcessHeap
     mov    [hHeap], eax
     
     invoke HeapAlloc, [hHeap], HEAP_ZERO_MEMORY, [bufferSize]
     mov    [buffer], eax

     stdcall Client.MarshalWorld, [pWorld], [SizeX], [SizeY], [SizeZ], [buffer]
     mov     dword[written], eax
     
     stdcall ws_socket_send_msg, [Client.hUDPSock], [Client.sockAddrUDP], [buffer], [written]
    
.Finish:
      
     ret
endp

proc Client.MarshalWorld uses edx ecx ebx esi, pWorld, SizeX, SizeY, SizeZ, buf 
     locals
        size dd ?
        num  dd ?
     endl
     mov     esi, [buf]
     mov     dword[num], 0
     
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

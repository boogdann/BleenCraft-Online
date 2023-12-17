include 'player_services.asm'

proc client.Subscribe_PlayerData, posAddr, turnAddr, HandItemAddr, PlayerState

  ;Init addreses
  mov eax, [posAddr]
  mov [cl_PosAddr], eax
  mov eax, [turnAddr]
  mov [cl_TurnAddr], eax
  mov eax, [HandItemAddr]
  mov [cl_HandItemAddr], eax
  mov eax, [PlayerState]
  mov [cl_StateAddr], eax
  
  stdcall _client.CopyPlayerData
  ret
endp


proc _client.StartServe_PlayerData uses esi, args
  mov esi, [args]
  ;===================================
  ;udp_socket_handle     = [esi]
  ;udp_soket_data_addr   = [esi + 4]
  ;playerId              = [esi + 8]
  ;groopId               = [esi + 12]
  ;sleepTime             = [esi + 16]
  ;===================================
  
  .ServeCircle:
      stdcall _client.CmpPlayerData
      cmp eax, 1
      jne .SkipSend
        ;Create a message
        stdcall _client.CreatePlayerData, cl_playerData
        
        stdcall Client.GetMessage, Client.msg.PlayerData, Client.Secret, [Client.SizeSecret],\
                                   [esi + 12], [esi + 8],\      
                                   cl_playerData, [cl_playerData_len], cl_PlayerDataMsg   
        ;Sending a message
        stdcall ws_socket_send_msg_udp, dword[esi], dword[esi + 4], cl_PlayerDataMsg, eax 
        cmp eax, SOCKET_ERROR
        jnz @F
            ;invoke ExitProcess, 0
        @@:
        
      .SkipSend:
      invoke Sleep, dword[esi + 16]
      cmp [cl_isCanServingPlayerData], 0
      jz .StopServing
  jmp .ServeCircle  

  .StopServing:
  mov [cl_isCanServingPlayerData], 1
  xor eax, eax
  ret
endp

proc client.Serve_PlayerData, udp_socket_handle, udp_soket_data_addr, playerId, groopId, sleepTime
  mov [cl_isCanServingPlayerData], 1

  mov ecx, 0
  .writeArg:
     mov eax, [ebp + ecx + 8]
     mov [cl_ServeFuncARGS + ecx], eax 
  add ecx, 4
  cmp ecx, 5 * 4 
  jnz .writeArg
  
  invoke CreateThread, 0, 0, _client.StartServe_PlayerData, cl_ServeFuncARGS, 0, 0
  
  ret
endp

proc client.InitUdpPlayerConnection uses esi, msg, len
  cmp [len], 0
  jl .Error
  
  mov esi, [msg]
  add esi, [Client.SizeSecret]
  add esi, 4 + 4 ;type + groopId
  mov eax, dword[esi]
  mov [cl_curPlayerID], eax
  
  .Error:
  ret
endp

proc client.StopServe_PlayerData
  mov [cl_isCanServingPlayerData], 0
  mov [cl_curPlayerID], 0
  ret
endp
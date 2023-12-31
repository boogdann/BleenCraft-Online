cl_PosAddr                      dd     ?
cl_TurnAddr                     dd     ?
cl_HandItemAddr                 dd     ?
cl_StateAddr                    dd     ?

cl_CurPos                       dd     ?, ?, ?
cl_CurTurn                      dd     ?, ?, ?
cl_CurHandItem                  dd     ?
cl_CurState                     dd     ?

cl_ServeFuncARGS                dd     ?, ?, ?, ?, ?
cl_HandlerFuncARGS              dd     ?, ?, ?


cl_PlayerDataMsg                db     100   dup  (?)
cl_UdpMsgBuffer                 db     255   dup  (?)
cl_UdpMsgBuffer_len             dd     $ - cl_UdpMsgBuffer
;12 + 12 + 4 + 4  =      
cl_playerData                   dd     8     dup  (?)
cl_playerData_len               dd     $ - cl_playerData  

cl_isCanServingPlayerData       dd     ? 
cl_isCanHandleUdp               dd     ? 

cl_curPlayerID                  dd     ? 

cl_all_players_data_addr        dd     360 dup (0);0   
cl_player_data_len              dd     40   
;player data structure:
  ; - dd    ? - player id
  ; - dd    ?, ?, ? - position
  ; - dd    ?, ?, ? - turn
  ; - dd    ? - Hand Item
  ; - dd    ? - State
  ; - dd    ? - Other info
  ; - Result = 40 bytes
  
tmp_pos   dd   ?, ?, ?
tmp_turn  dd   ?, ?, ?
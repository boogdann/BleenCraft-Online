cl_PosAddr          dd     ?
cl_TurnAddr         dd     ?
cl_HandItemAddr     dd     ?
cl_StateAddr        dd     ?

cl_CurPos           dd     ?, ?, ?
cl_CurTurn          dd     ?, ?, ?
cl_CurHandItem      dd     ?
cl_CurState         dd     ?

cl_ServeFuncARGS    dd     ?, ?, ?, ?, ?


cl_PlayerDataMsg       db   100   dup  (?)
;12 + 12 + 4 + 4  =      
cl_playerData          dd   8     dup  (?)
cl_playerData_len      dd   $ - cl_playerData  

cl_isCanServingPlayerData dd   ?  

cl_curPlayerID         dd   ?        
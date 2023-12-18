Client.YourIP    db '127.0.0.1', 0
Client.YourPort  dd 11111

HOST   = 0
PLAYER = 1
Client.OffsetNumber = 6
Client.MAX_SIZE_MSG = 65000
Client.HEADER_SIZE  = 17

Client.MSGSendWorld         dd 0
Client.MSGPlayerPosition    dd 1
Client.MSGBlockState        dd 2
Client.MSGHandBlock         dd 3
Client.MSGGetWorld          dd 4
Client.MSGUserState         dd 5
Client.MSGRotations         dd 6
Client.MSGTCPInit           dd 7
Client.MSGUDPInit           dd 8
Client.MSGStartSendWorld    dd 9
Client.MSGEndSendWorld      dd 10

Client.SizeWorldBuffer      dd ?

testUDPLine db 'Hello', 0

Client.Secret     db 'whevf', 0
Client.SizeSecret dd 5
Client.Number     dd ?
Client.GroupID    dd ?

Client.ReadBuffer db 150 dup(0)
Client.SizeBuffer dd $ - Client.ReadBuffer

Client.IPPROTO_UDP = 17
Client.IPPROTO_TCP = 6
Client.INADDR_ANY  = 0
Client.INVALID_SOCKET     = -1

Client.WSAData   WSADATA

Client.hTCPSock  dd ?
Client.hUDPSock  dd ?

Client.hTCPQueueClient dd ?
Client.hTCPQueueServer dd ?

Client.sockAddrUDP       sockaddr_in
Client.sockAddrTCP       sockaddr_in

Client.sockAddrTCPQueueClient  sockaddr_in
Client.sockAddrTCPQueueServer  sockaddr_in

Client.maxConn  dd 5


include 'playerData/player.inc'

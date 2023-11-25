HOST   = 0
PLAYER = 1
Client.OffsetNumber = 6

testUDPLine db 'Hello', 0

Client.Secret     db 'whevf', 0
Client.SizeSecret dd 5
Client.Number     dd ?

Client.ReadBuffer db 150 dup(0)
Client.SizeBuffer dd $ - Client.ReadBuffer

Client.IPPROTO_UDP = 17
Client.IPPROTO_TCP = 6
Client.INADDR_ANY  = 0
Client.INVALID_SOCKET     = -1

Client.WSAData  WSADATA
Client.hTCPSock dd ?
Client.hUDPSock dd ?


Client.sockAddrUDP       sockaddr_in
;Client.res            
;Client.sockfd   dd ?
;Client.newfd    dd ?
Client.hints          sockaddr_in
;Client.res      addrinfo
;Client.p        addrinfo
;Client.p        addrinfo
;Client.sin_size dd       ?
;Client.their_addr dd     sockaddr_storage 

Client.maxConn  dd 5
format PE GUI 4.0
entry Start

include 'win32a.inc'  

section '.text' code readable executable

Start:


section '.data' data readable writeable



section '.idata' import data readable writeable

  library kernel32, 'KERNEL32.DLL',\
	  user32, 'USER32.DLL'

  include 'api\kernel32.inc'
  include 'api\user32.inc'
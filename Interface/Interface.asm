proc InterfaceInit
  
  stdcall GameStart
  mov [Dayly_Kof], 15000
  
  ;invoke CreateWindow, 

  ret
endp

proc RenderMainMenu

  stdcall RenderScene

  ret
endp


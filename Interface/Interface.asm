include "units\interfase_items.ASM"

proc ui_InterfaceInit
  
  stdcall GameStart
  mov [Dayly_Kof], 15000

  ret
endp

proc ui_RenderMainMenu

  stdcall RenderScene

  ret
endp


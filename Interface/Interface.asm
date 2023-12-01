include "units\interfase_items.ASM"

proc ui_InterfaceInit
  
  ;stdcall GameStart
  stdcall ct_change_mouse, 1
  mov [Dayly_Kof], 15000

  ret
endp

proc ui_RenderMainMenu
  ;stdcall RenderScene
  stdcall gf_2D_Render_Start 

  stdcall gf_2D_Render_End
  
  invoke SwapBuffers, [hdc]
  invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT

  ret
endp


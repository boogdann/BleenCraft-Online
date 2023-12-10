include "units\interfase_items.ASM"   
include "units\interfase_controller.ASM"
include "units\interfase_menu_items.ASM"

proc ui_InterfaceInit
  
  stdcall GameStart
  stdcall ct_change_mouse, 1
  mov [Dayly_Kof], 18000

  ret
endp

proc ui_RenderMenu
  stdcall ui_renderMenu_Main

  ret
endp

proc ui_renderMenu_Main 
  stdcall RenderScene
  stdcall gf_2D_Render_Start 
    ;stdcall ui_draw_slot, 0.0, 0.0, 0.2, 0.2, 1
    
    

  stdcall gf_2D_Render_End

  ret
endp


proc ui_renderMenu_settings
  ret
endp


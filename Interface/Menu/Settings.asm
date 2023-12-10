include "..\..\Grafic\GraficAPI\gf_assets\gf_macro.ASM"

proc ui_renderMenuSettings, WindowRect 

  stdcall gf_2D_Render_Start 
    

  stdcall gf_2D_Render_End
  
  invoke SwapBuffers, [hdc]
  invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT


  ret
endp
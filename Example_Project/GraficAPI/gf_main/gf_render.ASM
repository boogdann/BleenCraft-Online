proc gf_RenderBegin

  ret
endp


proc gf_RenderEnd 
  invoke SwapBuffers, [hdc]
  invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT 
  
  ret
endp
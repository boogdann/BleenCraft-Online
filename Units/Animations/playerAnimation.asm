proc renderPlayer uses esi edi ecx edx eax, pos, turn, handItem, State
  locals
    playerScale   dd   0.3
  endl
  
  
  mov esi, [turn]
  fldz
  fstp dword[esi]
  
  stdcall gf_renderObj3D, obj.Player.Body.Handle, [tx.Player.Handle], 0, [pos], [turn], [playerScale], 0
  stdcall gf_renderObj3D, obj.Player.LLeg.Handle, [tx.Player.Handle], 0, [pos], [turn], [playerScale], 0
  stdcall gf_renderObj3D, obj.Player.RLeg.Handle, [tx.Player.Handle], 0, [pos], [turn], [playerScale], 0
  stdcall gf_renderObj3D, obj.Player.LHand.Handle,[tx.Player.Handle], 0, [pos], [turn], [playerScale], 0
  stdcall gf_renderObj3D, obj.Player.RHand.Handle,[tx.Player.Handle], 0, [pos], [turn], [playerScale], 0
  
  ret
endp
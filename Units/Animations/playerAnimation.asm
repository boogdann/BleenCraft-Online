proc renderPlayer uses esi edi ecx edx eax, pos, turn, handItem, State
  locals
    playerScale   dd   0.23
    ySub         dd    0.72
  endl
  
  
  mov esi, [turn]
  fldz
  fstp dword[esi]
  
  mov esi, [pos]
  push dword[esi + 4]
  fld dword[esi + 4]
  fsub [ySub]
  fstp dword[esi + 4]
  
  stdcall gf_renderObj3D, obj.Player.Body.Handle, [tx.Player.Handle], 0, [pos], [turn], [playerScale], 0
  stdcall gf_renderObj3D, obj.Player.LLeg.Handle, [tx.Player.Handle], 0, [pos], [turn], [playerScale], 0
  stdcall gf_renderObj3D, obj.Player.RLeg.Handle, [tx.Player.Handle], 0, [pos], [turn], [playerScale], 0
  stdcall gf_renderObj3D, obj.Player.LHand.Handle,[tx.Player.Handle], 0, [pos], [turn], [playerScale], 0
  stdcall gf_renderObj3D, obj.Player.RHand.Handle,[tx.Player.Handle], 0, [pos], [turn], [playerScale], 0
  
  pop dword[esi + 4]
  
  ret
endp
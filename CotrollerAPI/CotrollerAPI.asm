include "CotrollerAPI\main\Collisions.asm"
include "CotrollerAPI\main\Keyboard.asm"
include "CotrollerAPI\main\Mouse.asm"


proc ct_move_check, playerPos, playerTurn,\
                               Field, X, Y, Z
                               
  stdcall ct_collisionsBegin, [playerPos]
  cmp [ct_is_mouse], 1
  jz @F
    stdcall ct_check_Jump
    stdcall ct_check_turns, [playerTurn]
    stdcall ct_check_moves, [playerPos], [playerTurn]
  @@:
  stdcall ct_fall_check, [playerPos]
  stdcall ct_collisionsCheck, [playerPos], ct_lastPos, [Field], [X], [Y], [Z]
  ret
endp
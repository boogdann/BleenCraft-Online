proc getCurrentBlock, currentCell

    mov edi, [currentCell]
    
    add [currentCell], 27
  
    stdcall Inventory.GetCell, [currentCell]
    
    mov [chosenBlockFromInv], eax
    
    ret
endp

proc highlightCurrentCell, wParam

    cmp [wParam], $31
    jnz @F
      mov [currentChosenCell], 0
    @@:
    
    cmp [wParam], $32
    jnz @F
      mov [currentChosenCell], 1
    @@:
  
    cmp [wParam], $33
    jnz @F
      mov [currentChosenCell], 2
    @@:
    
    cmp [wParam], $34
    jnz @F
      mov [currentChosenCell], 3
    @@:
    
    cmp [wParam], $35
    jnz @F
      mov [currentChosenCell], 4
    @@:
    
    cmp [wParam], $36
    jnz @F
      mov [currentChosenCell], 5
    @@:
    
    cmp [wParam], $37
    jnz @F
      mov [currentChosenCell], 6
    @@:
    
    cmp [wParam], $38
    jnz @F
      mov [currentChosenCell], 7
    @@:
    
    cmp [wParam], $39
    jnz @F
      mov [currentChosenCell], 8
    @@:
  
  
    ret
endp

proc getDamage

  locals
      multiplier dd 18.0
      currentSpeed dd 0
      currentDamage dd 0
      divConst      dd 2.0
      koeff         dd 1.5  
  endl
  
  fld [ct_damageFallSpeed]
  fmul [multiplier]
  fistp [currentSpeed]
        
  cmp [currentSpeed], 2
  jl @F
     cmp [currentNumOfHearts], 1
     jg .damage
         ;invoke ExitProcess, 0
         jmp .skip   
     .damage:
     
     cmp [ct_inWater], 1
     je .water
         
         cmp [UnderWater], 1
         je .water
         
             fild [currentSpeed]
             fdiv [divConst]      
             fistp [currentDamage]
          
             mov eax, [currentDamage] 
         
             sub [currentNumOfHearts], eax
             
             jmp .skip
             
     .water:
     
     fldz
     fstp [ct_damageFallSpeed] 
     
  @@:
  
  .skip:
  
  ret
endp
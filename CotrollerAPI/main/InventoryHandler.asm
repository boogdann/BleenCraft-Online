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
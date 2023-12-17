include "Units\Asm_Includes\Const.asm"
include "Units\Asm_Includes\Code.asm"
include "Units\Animations\RightHandAnimation.asm"
include "Units\Animations\blocksAnimation.asm"
include "Grafic\GraficAPI\gf_assets\gf_macro.ASM"
include "CotrollerAPI\main\BlocksDrop.asm"


;Ui rendering cases (This is necessary use Ilya) !!!
UI_GAME        equ  1   ;General ui render (in game)
UI_WORKBENCH   equ  2   ;Only Workbench ui render
UI_MAINBAG     equ  3   ;Only main (big) bag render 
UI_ESC_MENU    equ  4   ;Setting and other menu ui      
;mov [UI_MODE], CONST

proc GameStart
  mov [GLOBAL_OBJ_RADIUS_RENDER], -2.0
  
  stdcall InitWorld 
      
  stdcall initializeDestrBlocksHeap
  
  mov [UI_MODE], UI_GAME
  
  ;================ Grafic params ===========================
  ;Day/night params
  mov [Dayly_Kof], 10000   ;0 - 65535
  mov [DAYLY_SPEED], 2
  stdcall gf_subscribeDayly, Dayly_Kof, 1  ;1 - auto changing
  
  ;YOU CAN EDIT START VALUE TO "RENDER_RADIUS" in /Game.inc file
  ;Set radius of block rendering       (x,  y,  z)
  stdcall Set_GF_RENDER_BLOCKS_RADIUS,  [RENDER_RADIUS], [RENDER_RADIUS], [RENDER_RADIUS]
  ;SerRenderRadiusText!!!
  stdcall SetNumInInput, [RENDER_RADIUS], RenderRadius_input
  ;===========================================================
  
  stdcall Inventory.SetCell, 1, 235, 1
  stdcall Inventory.SetCell, 2, 1, 1
  stdcall Inventory.SetCell, 3, 1, 1
  stdcall Inventory.SetCell, 4, 1, 1
  
  ;========== Controller params ==========
  stdcall ct_change_mouse, 0
  ;=======================================
  ret
endp


proc RenderScene  
    mov [Selected_ButtonId], 0  
    stdcall gf_RenderBegin, PlayerPos, PlayerTurn
  
    ;The lighting mode is changed by the third parameter (if underwater => TRUE)
    stdcall gf_CreateLightning, LightsCount, LightsPositions, [UnderWater]
    
    ;Selection
    cmp [flag], 0
    jz @F
      stdcall gf_RenderSelectObj3D, selectCubeData, 1.0
    @@:      
    
    cmp [UI_MODE], UI_ESC_MENU
    jz .SkipRenderGameItems
      cmp [chosenBlockFromInv], 0
      jne @F
          stdcall anim_RightHand, PlayerPos, PlayerTurn
          jmp .animate  
      @@:
          stdcall anim_blockInHand, PlayerPos, PlayerTurn
    cmp [App_Mode], GAME_MODE
    jnz .SkipRenderGameItems
      
      .animate:
      ;==== Block for ilya ===============
      stdcall renderDestroyedBlocks
      
      ;===================================
    .SkipRenderGameItems:
    
    ;Landscape rendering                        
    stdcall gf_RenderMineLand, [Field.Blocks], [WorldLength], [WorldWidth],\
                               [WorldHeight], PlayerPos, PlayerTurn, 0      
    ;Water rendering (second time because of transparency)                                        
    stdcall gf_RenderMineLand, [Field.Blocks], [WorldLength], [WorldWidth],\
                               [WorldHeight], PlayerPos, PlayerTurn, 1
                                              
    stdcall gf_renderSkyObjs, [SkyLand], [SkyLength], [SkyWidth], [SkyHieght], [WorldLength], [WorldWidth]
    
    ;Block for 2D rendering:
    cmp [App_Mode], GAME_MODE
    jnz .SkipUI
    stdcall gf_2D_Render_Start
    
        ;Died screen
        cmp [currentNumOfHearts], 0
        jnz @F
          mov [IsPlayerDied], 1
        @@:
        cmp [IsPlayerDied], 1
        jnz @F  
          mov [currentNumOfHearts], 0
          stdcall ct_change_mouse, 1
          invoke glColor3f, 1.0, 1.0, 1.0
          stdcall ui_draw_text, WindowRect, died_text, [died_text_len], -0.3, 0.1, 0.01
          stdcall ui_drawButton, WindowRect, -0.3, -0.15, 0.6, 0.15, 1, Respawn_text, 7
          stdcall ui_renderShadowEffect, 1
        @@:
    
        ;mov [UI_MODE], UI_MAINBAG
        
        switch  [UI_MODE]
        case    .UI_pGame,        UI_GAME       
        case    .UI_pWorkBench,   UI_WORKBENCH 
        case    .UI_pMainBag,     UI_MAINBAG 
        case    .UI_pESCMenu,     UI_ESC_MENU  
        
        .UI_pGame:
          stdcall ui_renderHealth, WindowRect, 10, [currentNumOfHearts]
          
          mov eax, [Inventory]
          lea esi, [eax + InventoryMainOffset]
          stdcall ui_renderBag, WindowRect, 9, esi, [currentChosenCell] 
          
          stdcall ui_renderAim, WindowRect
          jmp .UI_RenderEnd
        .UI_pWorkBench:
          stdcall ui_draw_drag, WindowRect
          stdcall ui_renderWorkBench, WindowRect, [Inventory], [BigCraft]
          stdcall ui_renderShadowEffect, 0
          jmp .UI_RenderEnd
        .UI_pMainBag:
          stdcall ui_draw_drag, WindowRect
          ;36 elements in main bag required!!! 
          ;last 9 elm-s from mini bag!!!
          stdcall ui_renderBigBag, WindowRect, [Inventory], [SmallCraft]
          stdcall ui_renderShadowEffect, 0
          jmp .UI_RenderEnd
        .UI_pESCMenu:
          stdcall ui_renderMenuSettings, WindowRect
          jmp .UI_RenderEnd  
        .UI_RenderEnd:   
    stdcall gf_2D_Render_End
    .SkipUI:
    
    cmp [App_Mode], GAME_MODE
    jnz @F
    cmp [UI_MODE], UI_MAINBAG 
    jnz @F
      stdcall gf_render_PlayerItem
    @@:
    
    cmp [App_Mode], MENU_MODE
    jnz @F
    cmp [CUR_MENU], 1 
    jnz @F
      stdcall gf_render_LableItem
    @@:
    
    stdcall gf_RenderEnd
  ret
endp

;Respawn data reset
proc ResetGameData
    mov [currentNumOfHearts], 10
    mov [IsPlayerDied], 0
                  
    stdcall Field.GenerateSpawnPoint, PlayerPos
    stdcall ct_change_mouse, 0

  ret
endp

proc InitWorld
     cmp     dword[IS_GENERATED], TRUE
     jz      .EndSet
     
     cmp     dword[IS_ONLINE], TRUE
     jz      .SetOnline
     ; offline
     stdcall Field.Initialize, [WorldPower], [WorldHeight], [WaterLvl], [ChosenFile]
     stdcall Field.SetValues, Field.Blocks, WorldLength, WorldWidth, WorldHeight, SizeWorld  
    
     jmp     .Finish
.SetOnline:
     stdcall Client.Init, ServerIp, [ServerPortUDP], [ServerPortTCP]
     cmp     eax, -1
     jz      .Error
     
     cmp     dword[IS_HOST], TRUE
     jz      .SetHost
     ; not host
     stdcall Client.GetWorld, Field.Blocks, WorldLength, WorldWidth, WorldHeight
     stdcall Field.InitData, [WorldLength], [WorldWidth], [WorldHeight] 
     jmp     .StartTCPServer
     
.SetHost:
     stdcall Field.Initialize, [WorldPower], [WorldHeight], [WaterLvl], [ChosenFile]
     stdcall Field.SetValues, Field.Blocks, WorldLength, WorldWidth, WorldHeight, SizeWorld
     stdcall Client.SendWorld, [Field.Blocks], [WorldLength], [WorldWidth], [WorldHeight]

.StartTCPServer:
     stdcall Client.StartTCPServer
     cmp     eax, -1
     jz      .Error
     jmp     .Finish
     
.Error:
     mov     eax, -1   
     jmp     .EndSet
       
.Finish:
     mov     ecx, [WorldPower]
     sub     ecx, 1
     stdcall Field.GenerateClouds, ecx, filenameSky
     stdcall Field.SetCloudValues, SkyLand, SkyLength, SkyWidth 
     
     stdcall Field.GenerateSpawnPoint, PlayerPos
     
     stdcall Inventory.Initialize, Inventory, InventorySize
    
     stdcall Crafting.Initialize, SmallCraft, BigCraft
     mov     dword[IS_GENERATED], TRUE
.EndSet:
     ret    
endp

proc DestroyWorld
     cmp     dword[IS_GENERATED], FALSE
     jz      .Finish
     
     stdcall Field.DestroyWorld
     stdcall Field.DestroyClouds
     
     cmp     dword[IS_ONLINE], FALSE
     jz      .Finish
     stdcall Client.Destroy
     
.Finish:
     mov     dword[IS_GENERATED], FALSE
     ret
endp
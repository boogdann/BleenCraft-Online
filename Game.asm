include "Units\Asm_Includes\Const.asm"
include "Units\Asm_Includes\Code.asm"
include "Units\Animations\RightHandAnimation.asm"
include "Grafic\GraficAPI\gf_assets\gf_macro.ASM"


;Ui rendering cases (This is necessary use Ilya) !!!
UI_GAME        equ  1   ;General ui render (in game)
UI_WORKBENCH   equ  2   ;Only Workbench ui render
UI_MAINBAG     equ  3   ;Only main (big) bag render 
UI_ESC_MENU    equ  4   ;Setting and other menu ui      
;mov [UI_MODE], CONST
;Mouse modes switch automatically!!!

proc GameStart
  stdcall Inventory.Initialize, Inventory, InventorySize
  mov     eax, [Inventory]
  mov     eax, [InventorySize]

  ;Refactoring!!!!!!!!!!!
  ;================World initialize=================
  stdcall Field.Initialize, [WorldPower], [WorldHeight], [WaterLvl], filename 
  mov     eax, [Field.Length]
  mov     [WorldLength], eax
  mov     eax, [Field.Width]
  mov     [WorldWidth], eax
    
  xor     edx, edx
  mov     eax, [WorldLength]
  mul     dword[WorldWidth]
  mul     dword[WorldHeight]
  mov     [SizeWorld], eax
  
  mov     ecx, [WorldPower]
  sub     ecx, 1
  stdcall Field.GenerateClouds, ecx, filenameSky
  mov     dword[SkyLand], eax
  mov     eax, [Field.SkyLength]
  mov     [SkyLength], eax
  mov     eax, [Field.SkyWidth]
  mov     [SkyWidth], eax 
           
  ;=================================================
  
  ;Position initialize
  stdcall Field.GenerateSpawnPoint, PlayerPos
  
  ;================ Grafic params ===========================
  ;Day/night params
  mov [Dayly_Kof], 10000   ;0 - 65535
  mov [DAYLY_SPEED], 10
  stdcall gf_subscribeDayly, Dayly_Kof, 1  ;1 - auto changing
  
  ;Set radius of block rendering       (x,  y,  z)
  stdcall Set_GF_RENDER_BLOCKS_RADIUS,  30, 30, 20
  ;===========================================================
  
  ;========== Controller params ==========
  stdcall ct_change_mouse, 0
  ;=======================================
  
  ret
endp


proc RenderScene
    stdcall gf_RenderBegin, PlayerPos, PlayerTurn
  
    ;The lighting mode is changed by the third parameter (if underwater => TRUE)
    stdcall gf_CreateLightning, LightsCount, LightsPositions, [UnderWater]
    
    ;Selection
    cmp [flag], 0
    jz @F
      stdcall gf_RenderSelectObj3D, selectCubeData, 1.0
    @@:      
    
    stdcall anim_RightHand, PlayerPos, PlayerTurn

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
    
        ;mov [UI_MODE], UI_MAINBAG
        
        switch  [UI_MODE]
        case    .UI_pGame,        UI_GAME       
        case    .UI_pWorkBench,   UI_WORKBENCH 
        case    .UI_pMainBag,     UI_MAINBAG  
        
        .UI_pGame:
          ;stdcall ct_change_mouse, 0
          stdcall ui_renderHealth, WindowRect, 10, 6
          
          lea esi, [bigBag_arr_example + 3*9 *4]
          stdcall ui_renderBag, WindowRect, 9, esi, 2 
          
          stdcall ui_renderAim, WindowRect
          jmp .UI_RenderEnd
        .UI_pWorkBench:
          stdcall ui_draw_drag, WindowRect
          stdcall ui_renderShadowEffect
          ;stdcall ct_change_mouse, 1
          jmp .UI_RenderEnd
        .UI_pMainBag:
          stdcall ui_draw_drag, WindowRect
          ;36 elements in main bag required!!! 
          ;last 9 elm-s from mini bag!!!
          stdcall ui_renderBigBag, WindowRect, bigBag_arr_example, bigBag_craft_arr_example
          stdcall ui_renderShadowEffect
          ;stdcall ct_change_mouse, 1
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
    
    stdcall gf_RenderEnd
  ret
endp
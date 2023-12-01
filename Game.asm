include "Units\Asm_Includes\Const.asm"
include "Units\Asm_Includes\Code.asm"

include "Grafic\GraficAPI\gf_assets\gf_macro.ASM"

;Ui rendering cases (This is necessary use Ilya) !!!
UI_GAME        equ  1   ;General ui render (in game)
UI_WORKBENCH   equ  2   ;Only Workbench ui render
UI_MAINBAG     equ  3   ;Only main (big) bag render 
UI_ESC_MENU    equ  4   ;Setting and other menu ui      
;mov [UI_MODE], CONST

proc GameStart
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
    
        switch  [UI_MODE]
        case    .UI_pGame,        UI_GAME       
        case    .UI_pWorkBench,   UI_WORKBENCH 
        case    .UI_pMainBag,     UI_MAINBAG  
        
        .UI_pGame:
          stdcall ui_renderAim, WindowRect
          stdcall ui_renderHealth, WindowRect, 10, 6
          stdcall ui_renderBag, WindowRect, 9, tools_arr_example, 2
          jmp .UI_RenderEnd
       .UI_pWorkBench:
       
          jmp .UI_RenderEnd
       .UI_pMainBag:
       
          jmp .UI_RenderEnd
       .UI_RenderEnd:   
    stdcall gf_2D_Render_End
    .SkipUI:
      
    stdcall gf_RenderEnd
  ret
endp
format PE GUI 4.0
entry Start

;===============Module include================
include "win32a.inc"  
include "Game.asm"

include "Grafic\GraficAPI\GraficAPI.asm"
include "CotrollerAPI\CotrollerAPI.asm"

include "Interface\Interface.asm"

;It is expected that openGL is already connected!
include "Units\Asm_Includes\Di.asm"
include "Units\Asm_Includes\Du.asm"

;Attention! Dangerous dependencies with Grafic 
;1. Name of some files dependence (LCube.mobj, LCloud.mobj, LWater.mobj ...)
;2. Name of variables dependence (Headers variables)
;                                Example: (ObjectsNames, ObjectsHandles ...)
include "Assets\Textures.inc"
include "Assets\Blocks_textures.inc"
include "Assets\Objects.inc"
;==============================================

section '.text' code readable executable     

Start:   
  ;=============== Grafic Init ===================      
  stdcall gf_grafic_init
  
  ;Attention! Dangerous dependencies with /assets 
  stdcall gf_LoadTextures
  stdcall gf_2D_Render_Start 
  stdcall ui_renderBackground, WindowRect, 0.0
  stdcall gf_2D_Render_End
  invoke SwapBuffers, [hdc]
  invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT
  stdcall gf_LoadObjs
  stdcall gf_LoadAddictionalTextures
  
  ;================================================  
  
  ;==== Start settings ======  
  ;mov [App_Mode], GAME_MODE
  ;stdcall GameStart 
  
  
  mov [App_Mode], MENU_MODE
  stdcall ui_InterfaceInit
    
  ;========================== 
  
  ;================ Main app cycle =====================
  .AppCycle:
    .MainCycle:
          invoke  PeekMessage, msg, 0, 0, 0, PM_REMOVE
          cmp eax, 0
          jz .ExitMainCycle
          invoke  TranslateMessage, msg
          invoke  DispatchMessage, msg
          jmp     .MainCycle
     .ExitMainCycle:
     
   jmp .AppCycle
   ;====================================================
        
            
proc WindowProc uses ebx, hWnd, uMsg, wParam, lParam

        ;The physical module only works in game mode (kastil)
        cmp [App_Mode], GAME_MODE
        jnz @F
        cmp [UI_MODE], UI_ESC_MENU
        jz @F
          stdcall ct_move_check, PlayerPos, PlayerTurn,\
                                 [Field.Blocks], [WorldLength], [WorldWidth], [WorldHeight]  
        @@:   
        ;Message switch            
        switch  [uMsg]
        case    .Render,        WM_PAINT
        case    .Destroy,       WM_DESTROY
        case    .Movement,      WM_KEYDOWN 
        case    .MouseDown,     WM_LBUTTONDOWN 
        case    .MouseUp,       WM_LBUTTONUP
        case    .RMouseUp,      WM_RBUTTONUP
        case    .RMouseDown,    WM_RBUTTONDOWN
        case    .WheelScroll,   WM_MOUSEWHEEL
        
        invoke  DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
        jmp     .Return

  .Render:     
        ;Render cases
        cmp [App_Mode], GAME_MODE
        jnz @F                 
           stdcall RenderScene
           jmp     .RenderEnd
        @@:
        cmp [App_Mode], MENU_MODE
        jnz @F
           stdcall ui_RenderMenu, WindowRect
        @@:
        .RenderEnd:
        mov [isFalling], 1
        jmp     .ReturnZero
  .Movement:
        cmp [App_Mode], GAME_MODE
        jnz @F
          cmp [UI_MODE], UI_ESC_MENU
          jnz .SkipMenuEsc
            stdcall ui_EscMenuInputController, [wParam]
            cmp [wParam], VK_ESCAPE
            jnz .ReturnZero
            mov [UI_MODE], UI_GAME
            stdcall ct_change_mouse, 0
            jmp     .ReturnZero
          .SkipMenuEsc:
          stdcall ct_on_keyDown, [wParam] 
          jmp     .ReturnZero
        @@:
        stdcall ui_on_keyDown, [wParam]
        jmp     .ReturnZero
  .MouseDown:
        switch  [App_Mode]
        case    .MenuController,    MENU_MODE
        case    .GameController,    GAME_MODE
        .MenuController: 
            stdcall ui_onClick, WindowRect
            jmp .ReturnZero
        .GameController:
            cmp [IsPlayerDied], 1
            jnz .SkipDiedScreen
               cmp [Selected_ButtonId], 1
               jnz .SkipRespawn
                  stdcall ResetGameData
               .SkipRespawn:
               jmp     .ReturnZero
            .SkipDiedScreen:
            switch  [UI_MODE]
            case    .EscMenuController,    UI_ESC_MENU            
            .UIGameController:
              stdcall ui_slots_controller, WindowRect, [Inventory],\   ;9x4
                                                       [SmallCraft],\  ;2x2 + 1
                                                       [BigCraft]      ;3x3 + 1
            jmp     .ReturnZero
            .EscMenuController:
              stdcall ui_MenuSettingsController, WindowRect                                        
            jmp     .ReturnZero
  .MouseUp:        
        ;govnokod no uje pohui
        ;All parameters are array to slots hz v kakom poryadke
        stdcall ui_drag_end, WindowRect, [Inventory],\      ;9x4
                                         [SmallCraft],\     ;2x2 + 1
                                         [BigCraft]         ;3x3 + 1
                                         
        ;
        stdcall Crafting.Craft, [SmallCraft], 5
        ;
        jmp     .ReturnZero
 
  .RMouseUp:
        cmp [App_Mode], GAME_MODE
        jnz .SkipRMouseUp
        cmp [UI_MODE], UI_GAME
        jnz .SkipRMouseUp
        stdcall OpenWorckBranch
        ;stdcall ct_build_block, prevCubePos
  
        .SkipRMouseUp:
        jmp     .ReturnZero
        
  .RMouseDown:
        cmp [App_Mode], GAME_MODE
        jnz .SkipRMouseDown
        cmp [UI_MODE], UI_GAME
        jnz .SkipRMouseDown
        cmp [flag], 1
        jne .SkipRMouseDown
        mov [global_building_time], 1000
        stdcall ct_build_block, prevCubePos
        
        .SkipRMouseDown:
        jmp     .ReturnZero
  .WheelScroll:
        
        stdcall mouseScroll, [wParam]
        
        jmp     .ReturnZero
  
  .Destroy:
        stdcall Field.SaveInFileWorld, [Field.Blocks], [WorldLength], [WorldWidth], [WorldHeight], [SizeWorld], DEFAULT_WORLD       
        invoke ExitProcess, 1
  .ReturnZero:                                                
        xor     eax, eax
  .Return:
        ret
endp

section '.data' data readable writeable
         ;===============Global variables===================
         GF_OBJ_PATH        db     "Assets\ObjectsPack\", 0
         GF_TEXTURE_PATH    db     "Assets\TexturesPack\", 0
         GF_PATH            db     "Grafic\GraficAPI\", 0
         GF_PATH_LEN        db     $ - GF_PATH
         
         ;Main window descriptor
         hMainWindow        dd          ?
         ;Main window params
         WindowRect         RECT  ;left ;top ;right ;bottom
         ;=================================================== 
         
         ;Menu/Game mode
         MENU_MODE           =    1
         GAME_MODE           =    2
         App_Mode            dd   ?
         
         MAX_PLAYERS_COUNT   dd   9
         
         ;obj.Cube.Handle - CUBE
         
         ;===========Data imports============
         include "Game.inc"
         include "Grafic\GraficAPI\GraficAPI.inc"
         include "CotrollerAPI\CotrollerAPI.inc"
         include "Interface\Interface.inc"

section '.idata' import data readable writeable

  ;=============Library imports==============
  library kernel32, 'KERNEL32.DLL',\
	        user32,   'USER32.DLL',\    
          opengl32, 'opengl32.DLL',\   
          gdi32,    'GDI32.DLL', \
          wsock32,  'WSOCK32.DLL'
                                    
  include 'api\kernel32.inc'
  include 'api\user32.inc'
  include 'api\wsock32.inc'
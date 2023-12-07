format PE GUI 4.0
stack 0x10000
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
  stdcall gf_LoadObjs
  stdcall gf_LoadTextures
  stdcall gf_LoadAddictionalTextures
  ;================================================  
  
  ;==== Start settings ======  
  mov [App_Mode], GAME_MODE
  stdcall GameStart 
  
  
  ;mov [App_Mode], MENU_MODE
  ;stdcall ui_InterfaceInit
  
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
          stdcall ct_move_check, PlayerPos, PlayerTurn,\
                                 [Field.Blocks], [WorldLength], [WorldWidth], [WorldHeight]  
        @@:   
        ;Message switch            
        switch  [uMsg]
        case    .Render,        WM_PAINT
        case    .Destroy,       WM_DESTROY
        case    .Movement,      WM_KEYDOWN 
        case    .MouseDown,     WM_LBUTTONDOWN 
        case    .MouseUp,     WM_LBUTTONUP
        
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
           stdcall ui_RenderMainMenu
        @@:
        .RenderEnd:
        mov [isFalling], 1
        jmp     .ReturnZero
  .Movement:
        stdcall ct_on_keyDown, [wParam] 
        jmp     .ReturnZero
  .MouseDown:
        stdcall ui_slots_controller, WindowRect, bigBag_arr_example
        jmp     .ReturnZero
  .MouseUp:
        ;govnokod no uje pohui
        ;All parameters are array to slots hz v kakom poryadke
        stdcall ui_drag_end, WindowRect, bigBag_arr_example
        jmp     .ReturnZero
  .Destroy:
        ;stdcall Field.SaveInFileWorld, [Field.Blocks], [WorldLength], [WorldWidth], [WorldHeight], [SizeWorld], filename       
        ;stdcall Field.SaveInFileWorld, [SkyLand],[SkyLength] ,[SkyWidth], 1 ,[SizeSky], filenameSky
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
         MENU_MODE       =     1
         GAME_MODE       =     2
         App_Mode        dd    ?
         
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
          gdi32,    'GDI32.DLL'
                                    
  include 'api\kernel32.inc'
  include 'api\user32.inc'

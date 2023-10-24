format PE GUI 4.0
stack 0x10000
entry Start

;===============Module incleude================
include "win32a.inc" 
include "Grafic\GraficAPI\GraficAPI.asm"
include "CotrollerAPI\CotrollerAPI.asm"
include "Interface\Interface.asm"
include "GameInit.asm"
;==============================================


section '.text' code readable executable     

Start:      
  stdcall gf_grafic_init  
  
  ;stdcall ct_change_mouse, 1
  ;mov [App_Mode], MENU_MODE
  ;stdcall InterfaceInit
  
  stdcall ct_change_mouse, 0
  mov [App_Mode], GAME_MODE
  stdcall GameStart 
  
  .MainCycle:
        invoke  GetMessage, msg, 0, 0, 0
        invoke  TranslateMessage, msg
        invoke  DispatchMessage, msg
        jmp     .MainCycle
        
            
proc WindowProc uses ebx,\
     hWnd, uMsg, wParam, lParam
     
        cmp [App_Mode], GAME_MODE
        jnz @F
          stdcall ct_move_check, cameraPos, cameraTurn,\
                                 [Field.Blocks], [WorldLength], [WorldWidth], [WorldHeight]  
        @@:
                            
        switch  [uMsg]
        case    .Render,        WM_PAINT
        case    .Destroy,       WM_DESTROY
        case    .Movement,      WM_KEYDOWN  
        
        invoke  DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
        jmp     .Return

  .Render:
        cmp [App_Mode], GAME_MODE
        jnz @F
           stdcall RenderScene
        @@:
        cmp [App_Mode], MENU_MODE
        jnz @F
           stdcall RenderMainMenu
        @@:
        
        mov [isFalling], 1
        jmp     .ReturnZero
        
  .Movement:
        stdcall ct_on_keyDown, [wParam] 
        jmp     .ReturnZero
  .Destroy:
        invoke ExitProcess, 1
  .ReturnZero:
        xor     eax, eax
  .Return:
        ret
endp

section '.data' data readable writeable
         ;??????????? ????? ????????? ?????????? ?????????:
         ;===============Global variables===================
         ;???? ? ???????? ???????????? ????????????:
         GF_OBJ_PATH        db     "Assets\ObjectsPack\", 0
         ;???? ? ????????? ???????????? ????????????:
         GF_TEXTURE_PATH    db     "Assets\TexturesPack\", 0
         ;???? ? ????? ??????? 
         GF_PATH            db     "Grafic\GraficAPI\", 0
         GF_PATH_LEN        db     $ - GF_PATH
         ;??????????????? ??????????? ?? ????????? ??????:
         GF_BLOCKS_RADIUS   dd     30, 30, 30 ;(?? x, y, z)
         
         hMainWindow        dd          ?
         ;=================================================== 
         
         App_Mode           dd     0
         MENU_MODE = 1
         GAME_MODE = 2

section '.idata' import data readable writeable

  ;=============Library imports==============
  library kernel32, 'KERNEL32.DLL',\
	        user32,   'USER32.DLL',\    
          opengl32, 'opengl32.DLL',\   
          gdi32,    'GDI32.DLL'          
                                       
  include 'api\kernel32.inc'
  include 'api\user32.inc'
  ;===========Data imports============
  include "GameInitData.inc"

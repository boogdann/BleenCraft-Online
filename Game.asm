include "Units\Asm_Includes\Const.asm"
include "Units\Asm_Includes\Code.asm"

proc GameStart
  ;Refactoring!!!!!!!!!!!
  ;================World initialize=================
  stdcall Field.Initialize, [WorldPower], [WorldHeight], [WaterLvl], filename 
  mov     eax, [Field.Length]
  mov     [WorldLength], eax
  mov     eax, [Field.Width]
  mov     [WorldWidth], eax
  
  mov     edi, [Field.Blocks]
  add     edi, 10
  mov     byte[edi], 1
  
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
  
  xor     edx, edx
  mov     eax, [SkyLength]
  mul     dword[SkyWidth]
  mov     [SizeSky], eax          
  ;=================================================
  
  ;Position initialize
  stdcall Field.GenerateSpawnPoint, PlayerPos
  
  ;================ Grafic params ===========================
  ;Day/night params
  mov [Dayly_Kof], 0   ;0 - 65535
  stdcall gf_subscribeDayly, Dayly_Kof, 0  ;0 - auto changing
  
  ;Set radius of block rendering       (x,  y,  z)
  stdcall Set_GF_RENDER_BLOCKS_RADIUS,  20, 20, 30
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
    
    ;TODO: Fix Selection
    cmp [flag], 0
    jz @F
    stdcall gf_RenderSelectObj3D, obj.Cube.Handle,\ 
                            selectCubeData, ZERO_VEC_3, 1.0
    @@:      
                     
    stdcall gf_RenderSelectObj3D, obj.Cube.Handle,\ 
                            LightsPositions, ZERO_VEC_3, 1.0 
    ;================================================================= 
                            
    ;Landscape rendering                        
    stdcall gf_RenderMineLand, [Field.Blocks], [WorldLength], [WorldWidth],\
                               [WorldHeight], PlayerPos, PlayerTurn, 0      
    ;Water rendering (second time because of transparency)                                        
    stdcall gf_RenderMineLand, [Field.Blocks], [WorldLength], [WorldWidth],\
                               [WorldHeight], PlayerPos, PlayerTurn, 1
       
    ;TODO: Position fix                                        
    stdcall gf_renderSkyObjs, [SkyLand], [SkyLength], [SkyWidth], [SkyHieght]
    
    stdcall gf_RenderEnd
  ret
endp
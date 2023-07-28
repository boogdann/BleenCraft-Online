;Imports
;\gf_main
include "gf_main\gf_api_init.ASM"
include "gf_main\gf_math.ASM"
include "gf_main\gf_init_render_data.ASM"
include "gf_main\gf_render.ASM"
;\gf_data_init
include "gf_data_init\gf_obj_init.ASM"
include "gf_data_init\gf_texture_init.ASM"
;\gf_assets
include "gf_assets\gf_macro.ASM"
include "gf_assets\gf_struct.ASM"
;\gf_shaders
include "gf_shaders\gf_shader_init.ASM"
;library headers
include "api\opengl.inc"
include "api\gdi32.inc"


proc gf_grafic_init uses esi edi  
    stdcall gf_window_init         
    stdcall gf_opengl_init
    stdcall gf_LoadFunctions
    stdcall gf_InitShaders
    stdcall gf_InitShadersData
    stdcall gf_InitRenderParams
  ret
endp







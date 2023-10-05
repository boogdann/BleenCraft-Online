UniformLocations:
        gf_MVP                dd      ?
        gf_model_M            dd      ?
        gf_Tex1               dd      ?
        gf_Tex2               dd      ?
        gf_Ka                 dd      ?
        gf_Kd                 dd      ?
        gf_Ks                 dd      ?
        gf_Shininess          dd      ?
        gf_LightsCount        dd      ?
        gf_SunPosition        dd      ?
        gf_SunIntensity       dd      ?
        gf_CandleRadius       dd      ?
        gf_CameraPos          dd      ?
        gf_aChanel            dd      ?
        gf_discardMode        dd      ?
        gf_ObjColor           dd      ?
        gf_ColorMode          dd      ?
        gf_SkyMode            dd      ?  
        gf_isTex2Enable       dd      ?
        gf_MaxFogDist         dd      ?
        gf_FogColor           dd      ?
        
UniformNames:  
        db      "MVP", 0
        db      "model", 0
        db      "Tex1", 0
        db      "Tex2", 0
        db      "Ka", 0
        db      "Kd", 0
        db      "Ks", 0
        db      "Shininess", 0
        db      "LightsCount", 0
        db      "lights[0].Position", 0
        db      "lights[0].Intensity", 0
        db      "CandleRadius", 0
        db      "CameraPos", 0
        db      "aChanel", 0
        db      "discardMode", 0
        db      "ObjColor", 0
        db      "ColorMode", 0
        db      "SkyMode", 0
        db      "isTex2Enable", 0
        db      "MaxFogDist", 0
        db      "FogColor", 0
        db      0
        
        
;Siple Objs Names:
gf_MAIN_cloud_name   db  "LCloud.mobj", 0 
gf_MAIN_cube_name    db  "LCube.mobj", 0
;Siple Objs Handles:
gf_MAIN_CubeHandle   dd   ?, ? 
gf_MAIN_CloudHandle  dd   ?, ?

;Textures
tx_test_name         db  "test_64.mbmw", 0
tx_test_Handle       dd  ?

tx_Destroy1_Name     db  "Destroy1_64.mbmw", 0
tx_Destroy2_Name     db  "Destroy2_64.mbmw", 0
tx_Destroy3_Name     db  "Destroy3_64.mbmw", 0
tx_Destroy4_Name     db  "Destroy4_64.mbmw", 0
tx_Destroy5_Name     db  "Destroy5_64.mbmw", 0
tx_Destroy_Handles:
  tx_Destroy1_Handle   dd   ?
  tx_Destroy2_Handle   dd   ?
  tx_Destroy3_Handle   dd   ?
  tx_Destroy4_Handle   dd   ?
  tx_Destroy5_Handle   dd   ?
  
gf_LeftCandleName     db    "lights["
gf_LeftCandle_len     db    $ - gf_LeftCandleName
gf_RightCandleName_1  db    "].Position", 0
gf_RightCandle_len_1  db    $ - gf_RightCandleName_1
gf_RightCandleName_2  db    "].Intensity", 0
gf_RightCandle_len_2  db    $ - gf_RightCandleName_2
gf_strCandleId        db    4 dup (?)
        
VAOhandle               dd        0        
VBOhandles              dd        ?, ?, ?       
PosHandle               dd        ?
NormalHandel            dd        ?
TextureHandle           dd        ? 

gf_tx_handle            dd        ?
gf_texture_adress       dd        ?

gf_VertexCount          dd        ?
gf_VertexArrayAdress    dd        ?
gf_NormalArrayAdress    dd        ?
gf_TextCordArrayAdress  dd        ?

;==================Matrix=================
gf_MVP_matrix         Matrix4x4  ;gf_pr_view_matrix * model
gf_pr_view_matrix     Matrix4x4  ;gf_projection_matrix * gf_view_matrix
gf_view_matrix        Matrix4x4
gf_model_matrix       Matrix4x4
gf_projection_matrix  Matrix4x4
gf_position_matrix    Matrix4x4     1.0,0.0,0.0,0.0,\
                                    0.0,1.0,0.0,0.0,\
                                    0.0,0.0,1.0,0.0,\
                                    0.0,0.0,0.0,1.0
gf_scale_matrix       Matrix4x4     1.0,0.0,0.0,0.0,\
                                    0.0,1.0,0.0,0.0,\
                                    0.0,0.0,1.0,0.0,\
                                    0.0,0.0,0.0,1.0
gf_turn_matrix        Matrix4x4
gf_frastrum_planes    dd            6 * 4 dup (?)     
;==========================================
gf_camera_lookvec     dd     ?, ?, ?
gf_uplookvec          dd     0.0, 0.0, 0.0
gf_zeroVec            dd     0.0, 0.0, 0.0
;==========================================

;================Lightning===================
;Candles
CandleIntensity       dd    0.40, 0.2, 0.2
CandleRadius          dd    15.0
tmpCandlePos          dd    ?, ?, ?, 0.0

;Sun                    
gf_Dayly_kof          dd    -1.0 ;[-1.0:1.0]
Max_SunIntensity      dd    0.5, 0.5, 0.5, 1.0
SunIntensity          dd    ?,   ?,   ?,   1.0 
SunPosition           dd    20.0, 120.0, 20.0, 1.0
;Object
Ka            dd       0.3, 0.3, 0.3
Kd            dd       0.4, 0.4, 0.4    
Ks            dd       0.15, 0.15, 0.15
Shininess     dd       1.5   

gf_dayly_kof_adress     dd     ?
;Флаг автоуправления день-ночь
gf_isAutoWhether        db     ?
gf_lastDaylyChange      dd     ?                    
;===========================================


;===============Colors======================
gf_SunColor         dd      0.97, 0.96, 0.86
gf_ConturColor      dd      0.0, 0.0, 0.0
gf_WaterAChanel     dd      0.3
gf_WaterSunIntensty dd      0.44, 0.48, 0.97, 1.0
gf_CloudColorM      dd      0.1, 0.1, 0.1  
gf_CloudColor       dd      ?, ?, ?  
gf_backgroundColorM dd      0.5, 0.66, 0.99     
gf_backgroundColor  dd      ?,  ?,  ?
gf_Fog_Color        dd      0.2, 0.2, 0.2, 1.0
;===========================================


;===============Camera================
fov             GLfloat         60.0
zNear           GLfloat         0.1
zFar            GLfloat         1000.0
aspect          GLfloat         ?
radian          GLfloat         57.32
;=====================================


gf_tmp_objPos   dd    ?,   ?,   ?
gf_ViewVec3     dd    ?,   ?,   ?
gf_temp_path    db    30   dup   (?)



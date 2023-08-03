UniformLocations:
        gf_view_M             dd      ?
        gf_model_M            dd      ?
        gf_projection_M       dd      ?
        gf_Tex1               dd      ?
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
        
UniformNames:  
        db      "view", 0
        db      "model", 0
        db      "projection", 0
        db      "Tex1", 0
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
        db      0
        
 
VAOhandle         dd     0        
VBOhandles        dd     ?, ?, ?       
PosHandle         dd     ?
NormalHandel      dd     ?
TextureHandle     dd     ? 

gf_tx_handle      dd     ?
gf_texture_adress dd     ?

gf_VertexCount             dd        ?
gf_VertexArrayAdress       dd        ?
gf_NormalArrayAdress       dd        ?
gf_TextCordArrayAdress     dd        ?

;#####################Matrix#########################
gf_view_matrix        Matrix4x4
gf_model_matrix       Matrix4x4
gf_projection_matrix  Matrix4x4
;####################################################
gf_position_matrix    Matrix4x4     1.0,0.0,0.0,0.0,\
                                    0.0,1.0,0.0,0.0,\
                                    0.0,0.0,1.0,0.0,\
                                    0.0,0.0,0.0,1.0
;####################################################
gf_scale_matrix       Matrix4x4     1.0,0.0,0.0,0.0,\
                                    0.0,1.0,0.0,0.0,\
                                    0.0,0.0,1.0,0.0,\
                                    0.0,0.0,0.0,1.0
;####################################################
gf_turn_matrix        Matrix4x4
;####################################################
gf_camera_lookvec     dd     ?, ?, ?

;############################################
gf_uplookvec          dd     0.0, 0.0, 0.0
;############################################
gf_zeroVec            dd     0.0, 0.0, 0.0

;Candles
CandleIntensity       dd    0.40, 0.2, 0.2
CandleRadius          dd    15.0
tmpCandlePos          dd    ?, ?, ?, 0.0


gf_LeftCandleName     db    "lights["
gf_LeftCandle_len     db    $ - gf_LeftCandleName
gf_RightCandleName_1  db    "].Position", 0
gf_RightCandle_len_1  db    $ - gf_RightCandleName_1
gf_RightCandleName_2  db    "].Intensity", 0
gf_RightCandle_len_2  db    $ - gf_RightCandleName_2
gf_strCandleId        db    4 dup (?)

;Sun
SunIntensity          dd    0.55, 0.5, 0.5, 1.0
SunPosition           dd    20.0, 120.0, 20.0, 1.0
gf_SunColor           dd    0.97, 0.96, 0.86
gf_ConturColor        dd    0.0, 0.0, 0.0

;Objects
Ka            dd       0.2, 0.2, 0.2 ;Общий свет (им можно сделать день\ночь)
Kd            dd       0.4, 0.4, 0.4
Ks            dd       0.15, 0.15, 0.15
Shininess     dd       1.5   ;Float


gf_WaterAChanel  dd  0.3
gf_CloudColor    dd  1.0, 1.0, 1.0


fov             GLfloat         60.0
zNear           GLfloat         0.001
zFar            GLfloat         1000.0
aspect          GLfloat         ?

radian          GLfloat         57.32

gf_tmp_objPos   dd    ?,   ?,   ?
gf_temp_path    db    50   dup   (?)


;Siple Objs Names:
gf_MAIN_cloud_name   db  "LCloud.mobj", 0 
gf_MAIN_cube_name    db  "LCube.mobj", 0
;Siple Objs Handles:
gf_MAIN_CubeHandle   dd   ?, ? 
gf_MAIN_CloudHandle  dd   ?, ?


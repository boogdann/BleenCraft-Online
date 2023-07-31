UniformLocations:
        gf_view_M             dd      ?
        gf_model_M            dd      ?
        gf_projection_M       dd      ?
        gf_Tex1               dd      ?
        

UniformNames:  
        db      "view", 0
        db      "model", 0
        db      "projection", 0
        db      "Tex1", 0
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
gf_uplookvec          dd     0.0, 1.0, 0.0


fov             GLfloat         60.0
zNear           GLfloat         0.001
zFar            GLfloat         1000.0
aspect          GLfloat         ?

radian          GLfloat         57.32

gf_tmp_objPos   dd    ?,   ?,   ?
gf_temp_path    db    50   dup   (?)




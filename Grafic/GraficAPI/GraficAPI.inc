include "gf_main\gf_api_init.inc"   
include "gf_main\gf_render_data.inc"   

GF_RENDER_BLOCKS_RADIUS         dd     20, 20, 30 

  
LettersCount                    dd     62
LettersWidth                    dd     ?
LettersHeight                   dd     ?


true            =               1
false           =               0

COLOR_DEPTH     =               24
PFD_FLAGS       =               PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER or PFD_DRAW_TO_WINDOW
WINDOW_STYLE    =               WS_VISIBLE or WS_MAXIMIZE or WS_POPUP

wndClass        WNDCLASS                0, WindowProc, 0, 0, 0, 0, 0, 0, 0, className
pfd             PIXELFORMATDESCRIPTOR   sizeof.PIXELFORMATDESCRIPTOR, 1, PFD_FLAGS, PFD_TYPE_RGBA, COLOR_DEPTH,\
                                                                         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,\
                                                            COLOR_DEPTH, 0, 0, PFD_MAIN_PLANE, 0, PFD_MAIN_PLANE
                              
                                                                       
className       db              "GraficAPI"
hdcBack         dd              ?
startTime       dd              ?
lastTime        dd              ?
currentTime     dd              ?
programTime     dd              ?
hdc             dd              ?
msg             MSG










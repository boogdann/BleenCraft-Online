ct_mouse           POINT  
ct_fall_speed      dd    0.0
ct_last_ch_spd     dd    0
          
ct_sensitivity     dd    0.07
сt_WalkingSpeed    dd    0.03
сt_RunningSpeed    dd    0.06
ct_isMoving        dd    1
prevTime           dd    0

ct_is_mouse        dd    1

isDebug            dd    1
time.deltaTime     dd    0.0

;Колизии прыжка
onGround      dd      0
toSkip        dd      0
isBlock       dd      0
isFalling     dd      0
ct_isJump     dd      1

ct_start_jump_speed        dd     -0.006
ct_jump_distancePerSecond  dd     0.005

ct_isStartOfJump           dd     0
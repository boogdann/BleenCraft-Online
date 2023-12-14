ct_mouse           POINT  
ct_fall_speed      dd    0.0
ct_last_ch_spd     dd    0
          
ct_sensitivity     dd    0.07
сt_WalkingSpeed    dd    0.03
сt_RunningSpeed    dd    0.035
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

ct_start_jump_speed        dd     -0.004
ct_water_jump_speed        dd     -0.001
ct_jump_distancePerSecond  dd     0.005
ct_isStartOfJump           dd     0    
ct_damageFallSpeed         dd     0.0

ct_velocity                dd     0.0005
ct_watter_velocity         dd     0.00005
ct_falling_velocity        dd     0.0005
ct_water_around            dd     0


isWatter                   dd     0

block_isDestructible       dd     0
block_detected             dd     0
is_readyToBuild            dd     0
ct_block_index             dd     0
prev_destr_time            dd     0
destruction_time           dd     0
prev_block_pos             dd     0, 0, 0

prev_building_time         dd     0
building_time              dd     0
build_by_click             dd     0

build_is_prohibited        dd     0

skip_destroying            dd     0

openMainBag                dd     -1

blocks_skipFalling         dd     0

ct_inWater                 dd     0

prev_regen_time            dd     0
current_regen_time         dd     0

isDamaged                  dd     0

tmpw                       dd     0 ;прокрутка колёсика мышки
WHEEL_DELTA                dd     120.0
curWheelDelta              dd     0
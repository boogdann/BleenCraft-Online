Crafting.SMALL_SIZE = 5
Crafting.BIG_SIZE   = 10
Crafting.SIZE_CELL  = 4

Crafting.NUM_CRAFTS2x2     = 4
Crafting.SIZE_SMALL_CRAFT  = 5
Crafting.NUM_CRAFTS3x3     = 6
Crafting.SIZE_BIG_CRAFT    = 10

Crafts2x2    dw\
       2, 4,  1, 1,  0,0,   0, 0,   0,0,\ ;log -> 4 planks 
       10,1,  20,1,  0,0,   23,1,   0,0,\ ;torch
       4, 1,  2, 1,  2,1,   2, 1,   2,1,\ ;crafting table
       23,2,  2, 1,  0,0,   2, 1,   0,0,\ ;sticks  
       0,0,   0 ,0,  0,0,   0, 0,   0,0

Crafts3x3    dw\
       2, 4,  1, 1,  0,0,   0,0,   0,0,   0, 0,   0,0,   0,0,   0,0,   0,0,\ ;log -> 4 planks 
       10,1,  20,1,  0,0,   0,0,   0,0,    23,1,  0,0,   0,0,   0,0,   0,0,\ ;torch
       23,2,  2, 1,  0,0,   0,0,   0,0,   2, 1,   0,0,   0,0,   0,0,   0,0,\ ;sticks  
       4, 1,  2, 1,  2,1,   0,0,   0,0,   2, 1,   2,1,   0,0,   0,0,   0,0,\ ;crafting table
       14,1,  13,1,  13,1,  13,1,  13,1,  0, 0,   13,1,  13,1,  13,1,  13,1,\;furnace
       3,1,   1 ,1,  1 ,1,  1 ,1,  1 ,1,  0, 0,   1 ,1,  1 ,1,  1 ,1,  1 ,1,\;chest
       0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0     
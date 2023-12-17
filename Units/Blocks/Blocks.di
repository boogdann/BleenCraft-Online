Blocks.MaterialEmpty           = 0
Blocks.MaterialWood            = 1
Blocks.MaterialStone           = 2
Blocks.MaterialIron            = 3
Blocks.MaterialGold            = 4
Blocks.MaterialDiamond         = 5

Blocks.START_DESTROY_TIME     dd   1000

;                               0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F  
Blocks.IndexDestruction db      9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0,\ ; 0
                                0, 9, 2, 3, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,\ ; 1 
                                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,\ ; 2 
                                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,\ ; 3 
                                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0\ ; 4   

;                               0    1    2  3  4  5  6  7  8  9  A  B  C  D  E  F  
Blocks.MultiplyDestruction db   255, 3,   2, 3, 3, 2, 2, 1, 1, 1, 1, 1, 4, 4, 4, 1,\ ; 0
                                1,   255, 5, 5, 4, 6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\ ; 1  
                                1,   1,   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\ ; 2 
                                1,   1,   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\ ; 3 
                                0,   0,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0\ ; 4 


Tools.PriorityAll            = 0
Tools.PrioriryPickaxe        = 1
Tools.PrioriryAxe            = 2
Tools.PrioriryShowel         = 3

;                               0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F  
Blocks.PriorirityTool      db   0, 2, 2, 2, 2, 3, 3, 3, 3, 3, 0, 3, 1, 1, 1, 0,\ ; 0
                                0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,\ ; 1  
                                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,\ ; 2 
                                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,\ ; 3 
                                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0\ ; 4 

 

AddictionalTextureNames:                          
              db      "Player_1.mbmw", 0
              ;Attention!!! Add your textures names in this field
              ;=====================================
              ;Your textures names:
              ;db     "texture.mbmw", 0
              ;...
              ;=====================================
              
              ;========== SLOT TEXTURES ==================
              db      "LowQuality\Stick_Slot_2.mbmw", 0   ;!!!!!
              
              db      "LowQuality\Pickaxe\PicsageWood_slot_2.mbmw", 0      
              db      "LowQuality\Pickaxe\PicsageStone_slot_2.mbmw", 0     
              db      "LowQuality\Pickaxe\PicsageIron_slot_2.mbmw", 0      
              db      "LowQuality\Pickaxe\PicsageGold_slot_2.mbmw", 0      
              db      "LowQuality\Pickaxe\PicsageDiamond_slot_2.mbmw", 0   
              
              db      "LowQuality\Axe\AxeWood_Slot_2.mbmw", 0     
              db      "LowQuality\Axe\AxeStone_Slot_2.mbmw", 0
              db      "LowQuality\Axe\AxeIron_Slot_2.mbmw", 0
              db      "LowQuality\Axe\AxeGold_Slot_2.mbmw", 0
              db      "LowQuality\Axe\AxeDiamond_Slot_2.mbmw", 0
              
              db      "LowQuality\Showel\ShovelWood_Slot_2.mbmw", 0    
              db      "LowQuality\Showel\ShovelStone_Slot_2.mbmw", 0    
              db      "LowQuality\Showel\ShovelIron_Slot_2.mbmw", 0    
              db      "LowQuality\Showel\ShovelGold_Slot_2.mbmw", 0     
              db      "LowQuality\Showel\ShovelDiamond_Slot_2.mbmw", 0 
              
              db      "HighQuality\Sword\SwordWood_slot_2.mbmw",0
              db      "HighQuality\Sword\SwordStone_slot_2.mbmw",0
              db      "HighQuality\Sword\SwordIron_slot_2.mbmw",0
              db      "HighQuality\Sword\SwordGold_slot_2.mbmw",0
              db      "HighQuality\Sword\SwordDiamond_slot_2.mbmw",0
              ;===============================================
              
              
              
              db      "LowQuality\stick_1.mbmw", 0
              
              db      "LowQuality\Pickaxe\Wood_32.mbmw", 0
              db      "LowQuality\Pickaxe\Stone_32.mbmw", 0
              db      "LowQuality\Pickaxe\Iron_32.mbmw", 0
              db      "LowQuality\Pickaxe\Gold_32.mbmw", 0
              db      "LowQuality\Pickaxe\Diamond_32.mbmw", 0
              
              db      "LowQuality\Axe\AxeWood.mbmw", 0     
              db      "LowQuality\Axe\AxeStone.mbmw", 0
              db      "LowQuality\Axe\AxeIron.mbmw", 0
              db      "LowQuality\Axe\AxeGold.mbmw", 0
              db      "LowQuality\Axe\Axe_Diamond.mbmw", 0
              
              db      "LowQuality\Pickaxe\Wood_32.mbmw", 0    ;SHOWEL!!!!
              db      "LowQuality\Pickaxe\Stone_32.mbmw", 0    ;SHOWEL!!!!
              db      "LowQuality\Pickaxe\Iron_32.mbmw", 0     ;SHOWEL!!!!
              db      "LowQuality\Pickaxe\Gold_32.mbmw", 0     ;SHOWEL!!!!
              db      "LowQuality\Pickaxe\Diamond_32.mbmw", 0   ;SHOWEL!!!!
              
              db      "HighQuality\Sword\SwordWood.mbmw",0
              db      "HighQuality\Sword\SwordStone.mbmw",0
              db      "HighQuality\Sword\SwordIron.mbmw",0
              db      "HighQuality\Sword\SwordGold.mbmw",0
              db      "HighQuality\Sword\Sword_Diamond.mbmw",0
              db      0
        
AddictionalTextureHandles:    

              tx.Player.Handle   dd   ?
              ;Attention!!! Add your objs in this field
              ;=====================================
              ;Your textures:
              ;tx.YouTexture.Handle       dd     ?
              ;...
              ;=====================================
              
              ;========== SLOT TEXTURES ==================
ToolsSlotAddr:tx.Slot.Stick.Handle             dd     ?

              tx.Slot.Pickaxe.Wood.Handle      dd     ?
              tx.Slot.Pickaxe.Stone.Handle     dd     ? 
              tx.Slot.Pickaxe.Iron.Handle      dd     ? 
              tx.Slot.Pickaxe.Gold.Handle      dd     ? 
              tx.Slot.Pickaxe.Diamond.Handle   dd     ?
                
              tx.Slot.Axe.Wood.Handle          dd     ?
              tx.Slot.Axe.Stone.Handle         dd     ? 
              tx.Slot.Axe.Iron.Handle          dd     ? 
              tx.Slot.Axe.Gold.Handle          dd     ? 
              tx.Slot.Axe.Diamond.Handle       dd     ?  
              
              tx.Slot.Showel.Wood.Handle       dd     ?
              tx.Slot.Showel.Stone.Handle      dd     ? 
              tx.Slot.Showel.Iron.Handle       dd     ? 
              tx.Slot.Showel.Gold.Handle       dd     ? 
              tx.Slot.Showel.Diamond.Handle    dd     ? 
              
              tx.Slot.Sword.Wood.Handle        dd     ?
              tx.Slot.Sword.Stone.Handle       dd     ? 
              tx.Slot.Sword.Iron.Handle        dd     ? 
              tx.Slot.Sword.Gold.Handle        dd     ? 
              tx.Slot.Sword.Diamond.Handle     dd     ? 
              ;===========================================

   
ToolsTxAddr:  tx.Stick.Handle             dd     ?

              tx.Pickaxe.Wood.Handle      dd     ?
              tx.Pickaxe.Stone.Handle     dd     ? 
              tx.Pickaxe.Iron.Handle      dd     ? 
              tx.Pickaxe.Gold.Handle      dd     ? 
              tx.Pickaxe.Diamond.Handle   dd     ?
                
              tx.Axe.Wood.Handle          dd     ?
              tx.Axe.Stone.Handle         dd     ? 
              tx.Axe.Iron.Handle          dd     ? 
              tx.Axe.Gold.Handle          dd     ? 
              tx.Axe.Diamond.Handle       dd     ?  
              
              tx.Showel.Wood.Handle       dd     ?
              tx.Showel.Stone.Handle      dd     ? 
              tx.Showel.Iron.Handle       dd     ? 
              tx.Showel.Gold.Handle       dd     ? 
              tx.Showel.Diamond.Handle    dd     ? 
              
              tx.Sword.Wood.Handle        dd     ?
              tx.Sword.Stone.Handle       dd     ? 
              tx.Sword.Iron.Handle        dd     ? 
              tx.Sword.Gold.Handle        dd     ? 
              tx.Sword.Diamond.Handle     dd     ? 









ObjectsNames:     
            obj.Player.Hand.Name      db      "Player\RHandpl.mobj", 0
            obj.Cube.Name             db      "LCube.mobj", 0                     
            obj.Player.Body.Name      db      "Player\Body.mobj", 0
            obj.Player.LLeg.Name      db      "Player\LLeg.mobj", 0
            obj.Player.RLeg.Name      db      "Player\RLeg.mobj", 0
            obj.Player.LHand.Name     db      "Player\LHand.mobj", 0
            obj.Player.RHand.Name     db      "Player\RHand.mobj", 0
            ;Attention!!! Add your objs names in this field
            ;=====================================
            ;Your objs names:
            ;                         db     "texture.mbmw", 0
            ;...
            ;=====================================
            obj.Stick.Name            db      "Stick.mobj", 0
            obj.Pickaxe.Name          db      "Pickaxe.mobj", 0
            obj.Axe.Name              db      "Axe.mobj", 0
            obj.Showel.Name           db      "Pickaxe.mobj", 0 ;SHOWEL!!!!
            obj.Sword.Name            db      "Sword.mobj", 0
            db      0
        
ObjectsHandles:
                  obj.Player.Hand.Handle     dd     ?, ?
                  obj.Cube.Handle            dd     ?, ?
                  obj.Player.Body.Handle     dd     ?, ?
                  obj.Player.LLeg.Handle     dd     ?, ?
                  obj.Player.RLeg.Handle     dd     ?, ?
                  obj.Player.LHand.Handle    dd     ?, ?
                  obj.Player.RHand.Handle    dd     ?, ?
                  ;Attention!!! Add your objs in this field
                  ;=====================================
                  ;Your objs:
                  ;obj.YouObj.Handle         dd     ?, ?
                  ;...
                  ;=====================================
ToolsObjAddr:     obj.Stick.Handle           dd     ?, ?
                  obj.Pickaxe.Handle         dd     ?, ?
                  obj.Axe.Handle             dd     ?, ?
                  obj.Showel.Handle          dd     ?, ?
                  obj.Sword.Handle           dd     ?, ?
                  obj_EOF:






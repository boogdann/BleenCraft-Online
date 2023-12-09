ui_aim_size  dd  0.015
bag_size     dd  10

big_bag_slot_size_xy  dd   ?, ?
big_bag_data          dd   36  dup (0, 0, 0)

big_bag_craft_data      dd   5  dup (0, 0, 0)
workbranchCraft_data    dd  10  dup (0, 0, 0)

ui_cursor_pos         dd   ?, ?

ui_is_drag            dd   0
ui_drag_item          dd   0
ui_drag_index_out     dd   0
ui_drag_array_out     dd   0


MAX_SLOT_ELM_COUNT    dd   64 

global_selected_slot_kostil  dd  0                               
;64 - max count of elements in slot







extends TileMap
var spikes = preload("res://Scenes/Spikes.tscn")


func _ready():
	for tile_pos in get_used_cells():
		var tile_id = get_cell(tile_pos.x, tile_pos.y)
		if get_cellv(tile_pos) != INVALID_CELL:
			set_cellv(tile_pos, -1)
			update_bitmask_region()
			var obj = spikes.instance()
			var obj_pos = map_to_world(tile_pos)*scale.x + Vector2(48,48)
			get_node("../YSort").add_child(obj)
			obj.global_position = obj_pos
			obj.activate = bool(tile_id)

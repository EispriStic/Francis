extends TileMap

onready var level = $"../Ground"
onready var obstacles = $"../../TileMap"

func _ready():
	var level_cells = level.get_used_cells_by_id(0) #if tile id 0 
	var obstacles_cells = obstacles.get_used_cells()
	for i in obstacles_cells:
		level_cells.erase(i)
		set_cellv(i, 1)
	for i in level_cells:
		set_cellv(i,0)

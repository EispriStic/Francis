extends Area2D

export var lvl:String
export var spawnpoint:int


func _ready():
	pass # Replace with function body.


func _on_Warp_body_entered(body):
	if body.get_name() == "Player":
		Globals.position = spawnpoint
		get_tree().change_scene("res://Levels/Level_"+lvl+".tscn")

extends Area2D

export(String, FILE, "*.tscn") var scene

func _ready():
	pass # Replace with function body.


func _on_Warp_body_entered(body):
	if body.get_name() == "Player":
		get_tree().change_scene(scene)

extends Area2D

export var dialog:String

export var one_time = false

enum DIRECTION { Null,Up,Down,Left,Right }
export(DIRECTION) var push_player

var dialogscene = preload("res://Scenes/DialogNode.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Trigger_body_entered(body):
	if body.get_name() == "Player":
		var instance = dialogscene.instance() #Lance le dialogue
		instance.init(dialog)
		add_child(instance)
		match push_player:
			1: #Up
				Globals.player.global_position.y = global_position.y - $CollisionShape2D.shape.extents.y*$CollisionShape2D.scale.y - 24
			2: #Down
				Globals.player.global_position.y = global_position.y + $CollisionShape2D.shape.extents.y + 2
			3: #Left
				Globals.player.global_position.x = global_position.x - 2
			4: #Right
				Globals.player.global_position.x = global_position.x + $CollisionShape2D.shape.extents.x + 2

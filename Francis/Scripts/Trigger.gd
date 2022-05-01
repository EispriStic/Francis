extends Area2D

export var dialog:String

export var delete_with_flag = false

enum DIRECTION { Null,Up,Down,Left,Right }
export(DIRECTION) var push_player
export var flag = "ALWAYS_TRUE"

var dialogscene = preload("res://Scenes/DialogNode.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.connect("stop_dialoging", self, "del_if_one_time") # Replace with function body.


func _on_Trigger_body_entered(body):
	if body.get_name() == "Player":
		var instance = dialogscene.instance() #Lance le dialogue
		instance.init(dialog)
		add_child(instance)
		match push_player:
			1: #Up
				Globals.player.global_position.y = global_position.y - $CollisionShape2D.shape.extents.y*$CollisionShape2D.scale.y - 24
			2: #Down
				Globals.player.global_position.y = global_position.y + $CollisionShape2D.shape.extents.y*$CollisionShape2D.scale.y + 24
			3: #Left
				Globals.player.global_position.x = global_position.x - $CollisionShape2D.shape.extents.x*$CollisionShape2D.scale.x - 24
			4: #Right
				Globals.player.global_position.x = global_position.x + $CollisionShape2D.shape.extents.x*$CollisionShape2D.scale.x + 24

func del_if_one_time(from_npc, target):
	if target == self and delete_with_flag:
		if Globals.FLAGS[flag]:
			queue_free()

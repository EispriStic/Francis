extends PathFollow2D

var speed = 200

onready var zombie = $RemoteTransform2D.get_node($RemoteTransform2D.remote_path)


func _ready():
	pass # Replace with function body.

func _process(delta):
	
	if zombie.state == "patrolling":
		offset = offset + speed*delta

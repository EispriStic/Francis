extends PathFollow2D

var speed = 200

func _ready():
	pass # Replace with function body.

func _process(delta):
	if $Zombie.state == "patrolling":
		offset = offset + speed*delta
	print($Zombie.state)

extends KinematicBody2D

var speed = 2.5


func _ready():
	pass

func _process(delta):
	var direction = Vector2(0,0)
	if Input.is_action_pressed("down"):
		direction.y += 1
	elif Input.is_action_pressed("up"):
		direction.y -= 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	elif Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("sprint"):
		speed = 5
	else:
		speed = 2.5
	direction = direction * delta
	direction = direction.normalized() * speed
	move_and_collide(direction)

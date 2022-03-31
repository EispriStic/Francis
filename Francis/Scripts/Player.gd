extends KinematicBody2D

func _ready():
	pass

func _process(delta):
	var speed = 150
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
		speed *= 1.5
	direction = direction.normalized() * speed
	var velo = move_and_slide(direction)

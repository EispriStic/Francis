extends KinematicBody2D

var state = "Idle"
var orientation = "Right"

func _ready():
	$AnimationPlayer.play("Idle_Right")

func _process(delta):
	var speed = 300
	var direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	if Input.is_action_pressed("sprint"):
		speed *= 1.5
	if direction.x > 0:
		orientation = "Right"
	elif direction.x < 0:
		orientation = "Left"
	if direction == Vector2.ZERO:
		state = "Idle"
	else:
		state = "Walk"
	var animation_name = state+"_"+orientation
	if $AnimationPlayer.current_animation != animation_name:
		$AnimationPlayer.play(animation_name)
		$AnimationPlayer.play(animation_name)
	
	direction = direction.normalized() * speed
	var velo = move_and_slide(direction)

extends KinematicBody2D

var state = "patrolling"
var target = null
var speed = 175
var last_point = null

func _ready():
	pass # Replace with function body.

func _process(delta):
	if state == "chasing":
		var velocity = Vector2(target.position.x-global_position.x,target.position.y-global_position.y)
		velocity = velocity.normalized()
		velocity*=speed
		move_and_slide(velocity)
	if state == "returning":
		var distance = pow( pow(last_point.x-global_position.x,2) + pow(last_point.y-global_position.y,2),0.5)
		if distance > 1:
			var velocity = Vector2(last_point.x-global_position.x,last_point.y-global_position.y)
			velocity = velocity.normalized()
			velocity*=speed
			move_and_slide(velocity)
		else:
			global_position = last_point
			state = "patrolling"

func _on_Area2D_body_entered(body):
	if body.get_name() == "Player":
		if state == "patrolling":
			last_point = global_position
		state = "chasing"
		target = body


func _on_Area2D_body_exited(body):
	if body.get_name() == "Player":
		state = "returning"
		target = null

extends KinematicBody2D

var state = "patrolling"
var target = null
var speed = 50
var last_point = null

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if state == "chasing":
		var velocity = global_position.direction_to(target.global_position).normalized() * speed
		move_and_slide(velocity)
	if state == "returning":
		var distance = global_position.distance_to(last_point)
		if distance > 3:
			var velocity = global_position.direction_to(last_point).normalized() * speed
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

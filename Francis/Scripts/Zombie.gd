extends KinematicBody2D

export var detection_rad: int
export var base_speed:int = 300
export var acceleration:int = 5
signal player_got_hit

var state = "patrolling"
var target = null
var speed = base_speed
var last_point = null
var orientation = "right"
var velocity = Vector2.ZERO

func _ready():
	add_to_group("ennemies")
	$Area2D/CollisionShape2D.shape.radius = detection_rad


func _process(delta):
	if $AnimationPlayer.current_animation == "attack":
		return
	
	if state == "chasing":
		speed+=(acceleration*delta)
	else:
		speed = base_speed
	
	if state == "chasing":
		velocity = global_position.direction_to(target.global_position).normalized() * speed
		move_and_slide(velocity)
		var slide_count = get_slide_count()
		for idx in range(slide_count):
			var collision = get_slide_collision(idx)
			var collider = collision.collider
			if collider.name == "Player":
				$AnimationPlayer.play("attack")
				velocity = Vector2.ZERO
				speed = int((base_speed + speed)/2)
				emit_signal("player_got_hit", 1)
				return

	if state == "returning":
		#speed *= acceleration
		var distance = global_position.distance_to(last_point)
		if distance > 3:
			velocity = global_position.direction_to(last_point).normalized() * speed
			move_and_slide(velocity)
		else:
			velocity = Vector2.ZERO
			speed = base_speed
			global_position = last_point
			state = "patrolling"
	
	if velocity == Vector2.ZERO and $AnimationPlayer.current_animation != "idle":
		$AnimationPlayer.play("idle")
	elif $AnimationPlayer.current_animation != "run":
		$AnimationPlayer.play("run")
	
	if velocity.x < 0 and orientation == "right":
		orientation = "left"
		$AnimatedSprite.flip_h = true
	elif velocity.x > 0 and orientation == "left":
		orientation = "right"
		$AnimatedSprite.flip_h = false

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

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "attack":
		$AnimationPlayer.play("idle")

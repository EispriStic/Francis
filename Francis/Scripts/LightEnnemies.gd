extends KinematicBody2D

onready var light = $AnimatedSprite/Light2D
var playerInLight = null
export var speed = 300
var chasing = false
export var case_max = 5
onready var max_distance = case_max * 96
onready var distance = max_distance
export var timing = 1.5
const orange = Color("#ff7e01")
const red = Color("#ff0000")

signal player_got_hit

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.one_shot = true
	$Timer.wait_time = timing
	$AnimationPlayer.play("Run")
	pass # Replace with function body.

func turn(value=null):
	if value == null or value != $AnimatedSprite.flip_h:
		$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
		$AnimatedSprite.offset.x = - $AnimatedSprite.offset.x
		light.rotation_degrees+=180
		if $AnimatedSprite.flip_h:
			light.offset.y = 2
		else:
			light.offset.y = -5

func checkInLight():
	if playerInLight:
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(position, playerInLight.position, [self])
		if result && result.collider.name == "Player":
			light.color = red
			chasing = true
			speed *= 1.5
			$Timer.stop()
	return chasing

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not chasing:	checkInLight()
	if not $Timer.is_stopped(): return
	if $AnimationPlayer.current_animation == "Attack": return
	if not chasing:
		light.color = orange
		var direction = Vector2(speed,0)
		if $AnimatedSprite.flip_h:
			direction*=-1
		move_and_slide(direction)
		distance -= speed*delta
		if distance <= 0:
			turn()
			$Timer.start()
			$AnimationPlayer.play("Idle")
			yield($Timer, "timeout")
			$AnimationPlayer.play("Run")
			distance = max_distance
	else:
		$AnimationPlayer.play("Run")
		var dir = global_position.direction_to(Vector2(Globals.player.global_position.x, Globals.player.global_position.y-1)).normalized()
		var distance = global_position.distance_to(Vector2(Globals.player.global_position.x, Globals.player.global_position.y-1))
		if distance < 3: return
		print(distance)
		var velocity = dir*speed
		if dir.x != 0: turn(dir.x < 0)	
		move_and_slide(velocity)
		
		var slide_count = get_slide_count()
		for idx in range(slide_count):
			var collision = get_slide_collision(idx)
			var collider = collision.collider
			#Si on trouve le joueur dans les collisions
			if collider.name == "Player":
				$AnimationPlayer.play("Attack")
				emit_signal("player_got_hit", 2)
				return

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		playerInLight = body


func _on_Area2D_body_exited(body):
	if body.name == "Player":
		playerInLight = null

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Attack":
		$AnimationPlayer.play("Idle")

extends KinematicBody2D

onready var light = $AnimatedSprite/Light2D
var playerInLight = null
export var speed = 300
var chasing = false
export var case_horizontal = 5
export var case_vertical = 0
export var light_degrees = 0
export var turning = false
export var clockwise = true
onready var max_horizontal = case_horizontal * 96
onready var max_vertical = case_vertical * 96
export var timing = 1.5
const orange = Color("#ff7e01")
const red = Color("#ff0000")
var direction = Vector2.ZERO
signal player_got_hit
onready var next_point 

func _ready():
	$Timer.one_shot = true
	$Timer.wait_time = timing
	$AnimationPlayer.play("Run")
	rotate_light(light_degrees)
	next_point = get_next_point()

func get_next_point():
	return position + direction.normalized() * Vector2(max_horizontal, max_vertical).length()

func rotate_light(degrees):
	#Oui, moi aussi j'ai envie de chialer en voyant ça
	degrees = int(degrees)%360
	light.rotation_degrees = degrees
	turn(degrees > 90 and degrees < 270)
	match degrees:
		0:
			light.offset = Vector2(84,-5.5)
			direction = Vector2(1,0)
		45:
			light.offset = Vector2(80,-5.5)
			direction = Vector2(1,1).normalized()
		90:
			light.offset = Vector2(78,-5.5)
			direction = Vector2(0,1)
		135:
			light.offset = Vector2(80,3)
			direction = Vector2(-1,1).normalized()
		180:
			light.offset = Vector2(84, 2)
			direction = Vector2(-1,0)
		225:
			light.offset = Vector2(84,0)
			direction = Vector2(-1,-1).normalized()
		270:
			light.offset = Vector2(84,1)
			direction = Vector2(0,-1)
		315:
			light.offset = Vector2(84,-2)
			direction = Vector2(1,-1).normalized()

func nearest_vect(vect):
	var tab = [Vector2(1,0), Vector2(1,1).normalized(), Vector2(0,1), Vector2(-1,1).normalized(), Vector2(-1,0), Vector2(-1,-1).normalized(), Vector2(0,-1), Vector2(1,-1).normalized()]
	var temp = tab[0] - vect
	var mini = temp.length()
	var mini_index = 0
	for index in range(1, len(tab)):
		temp = tab[index] - vect
		if mini > temp.length():
			mini = temp.length()
			mini_index = index
	return mini_index*45

func turn(value=null):
	if value == null or value != $AnimatedSprite.flip_h:
		$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
		$AnimatedSprite.offset.x = - $AnimatedSprite.offset.x

func flip():
	if turning:
		if clockwise:
			rotate_light(light.rotation_degrees+90)
		else:
			rotate_light(light.rotation_degrees+270)
	else:
		rotate_light(light.rotation_degrees+180)

func player_detected():
	light.color = red
	chasing = true
	speed *= 1.3
	$Timer.stop()

func checkInLight():
	if playerInLight:
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(position, playerInLight.position, [self])
		if result && result.collider.name == "Player":
			player_detected()
	return chasing

func change_direction():
	$Timer.start()
	$AnimationPlayer.play("Idle")
	flip()
	next_point = get_next_point()
	yield($Timer, "timeout")
	$AnimationPlayer.play("Run")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not chasing:	checkInLight()
	if not $Timer.is_stopped(): return
	if $AnimationPlayer.current_animation == "Attack": return
	if not chasing:
		light.color = orange
		var velocity = position.direction_to(next_point).normalized() * speed
		move_and_slide(velocity)
		var slide_count = get_slide_count()
		for idx in range(slide_count):
			var collision = get_slide_collision(idx)
			var collider = collision.collider
			if collider.name == "Player":
				player_detected()
				return
		if position.distance_to(next_point) < 10:
			position = next_point
			change_direction()
	else:
		$AnimationPlayer.play("Run")
		var dir = global_position.direction_to(Vector2(Globals.player.global_position.x, Globals.player.global_position.y-1)).normalized()
		rotate_light(nearest_vect(dir))
		var distance = global_position.distance_to(Vector2(Globals.player.global_position.x, Globals.player.global_position.y-1))
		if distance < 3: return
		var velocity = dir*speed
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

extends KinematicBody2D

var state = "Idle"
var orientation = "Right"
export var health:int = 5
export var base_speed:int = 380
var invincibility = 0
export var max_energy:int = 5
export var max_energy_cd:int = 3
export var invincibily_seconds:int = 2
var energy_cd = max_energy_cd
var energy = max_energy

func _ready():
	yield(get_parent(), "ready")
	var ennemies = get_tree().get_nodes_in_group("ennemies")
	$AnimationPlayer.play("Idle_Right")
	for ennemy in ennemies:
		ennemy.connect("player_got_hit", self, "on_hit")

func _process(delta):
	if invincibility > 0:
		invincibility -= delta
	if $AnimationPlayer.current_animation.begins_with("Hit"):
		return
	var direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	var speed = base_speed
	if Input.is_action_pressed("sprint") and energy > 0 and direction != Vector2.ZERO:
		speed *= 1.2
		energy -= delta
		energy_cd = max_energy_cd
		$AnimationPlayer.playback_speed = 2
	else:
		energy_cd -= delta
		if energy != max_energy and energy_cd < 0:
			energy += delta
			if energy > max_energy:
				energy = max_energy
		if $AnimationPlayer.playback_speed != 1:
			$AnimationPlayer.playback_speed = 1
	print(energy)
	if direction.x > 0:
		orientation = "Right"
	elif direction.x < 0:
		orientation = "Left"
	if direction == Vector2.ZERO:
		state = "Idle"
	else:
		state = "Walk"
	if not $AnimationPlayer.current_animation.begins_with(state) or not $AnimationPlayer.current_animation.ends_with(orientation):
		play_animation(state)
	direction = direction.normalized() * speed
	move_and_slide(direction)

func on_hit(damage):
	if invincibility <= 0:
		play_animation("Hit")
		health -= damage
		invincibility = invincibily_seconds
		if health <= 0:
			get_parent().remove_child(self)

func play_animation(name, speed=1):
	$AnimationPlayer.play(name+"_"+orientation)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name.begins_with("Hit"):
		play_animation("Idle")
		

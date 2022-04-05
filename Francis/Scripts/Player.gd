extends KinematicBody2D

var state = "Idle"
var orientation = "Right"
export var health:int = 5
export var base_speed:int = 380
var invincibility = 0

func _ready():
	yield(get_parent(), "ready")
	var ennemies = get_tree().get_nodes_in_group("ennemies")
	$AnimationPlayer.play("Idle_Right")
	for ennemy in ennemies:
		ennemy.connect("player_got_hit", self, "on_hit")

func _process(delta):
	print(health)
	if invincibility > 0:
		invincibility -= delta
	if $AnimationPlayer.current_animation.begins_with("Hit"):
		return
	var direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	var speed = base_speed
	if Input.is_action_pressed("sprint"):
		speed *= 1.2
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
	move_and_slide(direction)

func on_hit(damage):
	if invincibility <= 0:
		$AnimationPlayer.play("Hit_"+orientation)
		health -= damage
		invincibility = 2
		if health <= 0:
			get_parent().remove_child(self)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name.begins_with("Hit"):
		$AnimationPlayer.play("Idle_"+orientation)
		

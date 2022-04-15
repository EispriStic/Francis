extends KinematicBody2D

var state = "Idle"
var orientation = "Right"
export var base_speed:int = 380

var invincibility = Globals.invincibility
var max_energy = Globals.max_energy
var max_energy_cd = Globals.max_energy_cd
var invincibily_seconds = Globals.invincibily_seconds
var energy_cd = Globals.energy_cd
var energy = Globals.energy
var npcs = null
var target = self
var cursor = null
var interactions = []

signal player_death
signal health_changed
signal interaction

func _ready():
	yield(get_parent(), "ready")
	Globals.player = self
	var ennemies = get_tree().get_nodes_in_group("ennemies")
	var spawnpoints = get_tree().get_nodes_in_group("spawnpoints")
	npcs = get_tree().get_nodes_in_group("NPCs")
	for spawnpoint in spawnpoints:
		if spawnpoint.name.ends_with(Globals.position):
			position = spawnpoint.position
			break
	$AnimationPlayer.play("Idle_Right")
	for ennemy in ennemies:
		ennemy.connect("player_got_hit", self, "on_hit")

func _process(delta):
	if Globals.dialoging:
		if not $AnimationPlayer.current_animation.begins_with("Idle"):
			$AnimationPlayer.play("Idle_"+orientation)
			$Indicator.visible = false
			$AnimationPlayer.playback_speed = 1
		return
	
	var offset = -(target.get_node("AnimatedSprite").frames.get_frame("idle", 0).get_size()[1]*target.scale.y)/2
	$Indicator.global_position = Vector2(target.global_position.x, target.global_position.y+offset)
	
	
	if Globals.invincibility > 0:
		Globals.invincibility -= delta
	if $AnimationPlayer.current_animation.begins_with("Hit"):
		return
	if Input.is_action_just_pressed("ui_accept") and $Indicator.visible:
		emit_signal("interaction", target)
		return
	var direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	var speed = base_speed
	if Input.is_action_pressed("sprint") and energy > 0 and direction != Vector2.ZERO:
		speed *= 1.2
		Globals.energy -= delta
		Globals.energy_cd = Globals.max_energy_cd
		$AnimationPlayer.playback_speed = 2
	else:
		Globals.energy_cd -= delta
		if Globals.energy != Globals.max_energy and Globals.energy_cd < 0:
			Globals.energy += delta
			if Globals.energy > Globals.max_energy:
				Globals.energy = Globals.max_energy
		if $AnimationPlayer.playback_speed != 1:
			$AnimationPlayer.playback_speed = 1
	direction = direction.normalized() * speed
	direction = move_and_slide(direction)
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

func on_hit(damage):
	if Globals.invincibility <= 0:
		play_animation("Hit")
		Globals.health -= damage
		emit_signal("health_changed", Globals.health)
		Globals.invincibility = Globals.invincibily_seconds
		if Globals.health <= 0:
			emit_signal("player_death")
			get_parent().remove_child(self)

func play_animation(name):
	$AnimationPlayer.play(name+"_"+orientation)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name.begins_with("Hit"):
		play_animation("Idle")
		


func _on_InteractionArea_body_entered(body):
	if body in npcs:
		interactions.append(body)
		var dist = self.position.distance_to(interactions[0].position)
		target = interactions[0]
		for body in interactions:
			var dist2 = self.position.distance_to(body.position)
			if dist2 < dist:
				target = body
		$Indicator.visible=true

func _on_InteractionArea_body_exited(body):
	if body in npcs:
		var index = interactions.find(body, 0)
		if index != -1:
			interactions.remove(index)
	if interactions.size() == 0:
		$Indicator.visible = false

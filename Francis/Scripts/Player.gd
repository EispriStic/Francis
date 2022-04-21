extends KinematicBody2D

var state = "Idle"
var orientation = "Right"
export var base_speed:int = 380

#Ca sera utile plus tard de stocker ça dans global
#Pour garder les stats modifiées
var npcs = null
var target = self
var cursor = null
var interactions = []

signal player_death
signal health_changed #askip Regis en a besoin mais bon il a jamais bossé MDR
signal interaction

func _ready():
	yield(get_parent(), "ready")
	Globals.player = self
	var ennemies = get_tree().get_nodes_in_group("ennemies")
	var spawnpoints = get_tree().get_nodes_in_group("spawnpoints")
	npcs = get_tree().get_nodes_in_group("NPCs")
	
	#Trouver où spawn
	#Globals.position = 2 => Spawn au noeud "SpawnPoint2"
	for spawnpoint in spawnpoints:
		if spawnpoint.name.ends_with(Globals.position):
			position = spawnpoint.position
			break
	$AnimationPlayer.play("Idle_Right")
	
	#Connection des signals
	Globals.connect("start_dialoging", self, "dialog_init")
	Globals.connect("stop_dialoging", self, "dialog_exit")
	for ennemy in ennemies:
		ennemy.connect("player_got_hit", self, "on_hit")

func dialog_init():
	#Appelé au début d'un dialogue
	#Stop l'animation du joueur et le fait regarder son interlocuteur (= Globals.dialoging)
	if global_position.direction_to(Globals.dialoging.global_position).x > 0:
		orientation = "Right"
	else:
		orientation = "Left"
	$AnimationPlayer.play("Idle_"+orientation)
	$Indicator.visible = false
	$AnimationPlayer.playback_speed = 1
	
func dialog_exit():
	#Appelé à la fin d'un dialogue
	$Indicator.visible = true

func _process(delta):
	if Globals.dialoging:
		return

	#C'est moche comme ça mais oklm
	#L'indicateur va se positionnier au dessus du NPC / item avec lequel il pourra interagir
	var offset = -(target.get_node("AnimatedSprite").frames.get_frame("idle", 0).get_size()[1]*target.scale.y)/2
	#Un truc hyper compliqué juste pour trouver le milieu haut du sprite de l'interlocuteur
	#Faudra le changer plus tard si on veut interagir avec des items parce que ça force à avoir AnimatedSprite là
	$Indicator.global_position = Vector2(target.global_position.x, target.global_position.y+offset)
	
	#Après un coup, le joueur est invincible pendant "Globals.invincibility" secondes.
	if Globals.invincibility > 0:
		Globals.invincibility -= delta
	#Si le joueur se fait taper, on l'empêche de bouger ou interagir
	if $AnimationPlayer.current_animation.begins_with("Hit"):
		return
		
	#Interaction
	if Input.is_action_just_pressed("ui_accept") and $Indicator.visible:
		emit_signal("interaction", target)
		return
		
	#Mouvements
	var direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	var speed = base_speed
	if Input.is_action_pressed("sprint") and Globals.energy > 0 and direction != Vector2.ZERO:
		speed *= 1.2
		Globals.energy -= delta
		Globals.energy_cd = Globals.max_energy_cd
		$AnimationPlayer.playback_speed = 2 #L'animation de course accélère lorsque le joueur sprint
	else:
		#Régénération de l'énergie si le joueur ne cours pas après energy_cd secondes
		Globals.energy_cd -= delta
		if Globals.energy != Globals.max_energy and Globals.energy_cd < 0:
			Globals.energy += delta
			if Globals.energy > Globals.max_energy:
				Globals.energy = Globals.max_energy
		if $AnimationPlayer.playback_speed != 1:
			$AnimationPlayer.playback_speed = 1 #On remet la vitesse d'animation normal si besoin

	#Déplacement
	direction = direction.normalized() * speed
	direction = move_and_slide(direction)
	# Orientation => Pour le sprite, j'ai pas trouvé mieux, il est pas centré :'(
	if direction.x > 0:
		orientation = "Right"
	elif direction.x < 0:
		orientation = "Left"
	if direction == Vector2.ZERO:
		state = "Idle"
	else:
		state = "Walk"
	if not $AnimationPlayer.current_animation.begins_with(state) or not $AnimationPlayer.current_animation.ends_with(orientation):
		play_animation(state) #Si changement d'animation il y a besoin, changement d'animation se fait

func on_hit(damage):
	if Globals.invincibility <= 0:
		play_animation("Hit")
		Globals.health -= damage
		emit_signal("health_changed", Globals.health)
		Globals.invincibility = Globals.invincibility_cd
		if Globals.health <= 0:
			emit_signal("player_death")
			get_parent().remove_child(self)

func play_animation(name):
	$AnimationPlayer.play(name+"_"+orientation)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name.begins_with("Hit"):
		play_animation("Idle")


func _on_InteractionArea_body_entered(body):
	#On liste toutes les interactions possible
	#On trouve la plus proche de nous => On la définie comme cible.
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
	#On retire l'interaction manquante de la liste et si la liste est vide on fait disparaitre l'indicateur.
	if body in npcs:
		var index = interactions.find(body, 0)
		if index != -1:
			interactions.remove(index)
	if interactions.size() == 0:
		$Indicator.visible = false

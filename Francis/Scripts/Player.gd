extends KinematicBody2D

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

func turn(value=null):
	if value == null or value != $AnimatedSprite.flip_h:
		$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
		$AnimatedSprite.offset.x = - $AnimatedSprite.offset.x

func _ready():
	$AnimatedSprite.position = Vector2.ZERO
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
	$AnimationPlayer.play("Idle")
	
	#Connection des signals
	Globals.connect("start_dialoging", self, "dialog_init")
	Globals.connect("stop_dialoging", self, "dialog_exit")
	for ennemy in ennemies:
		ennemy.connect("player_got_hit", self, "on_hit")
	for npc in npcs:
		self.connect("interaction", npc, "_on_Player_interaction")

func dialog_init():
	#Appelé au début d'un dialogue
	#Stop l'animation du joueur et le fait regarder son interlocuteur (= Globals.dialoging)
	turn(global_position.direction_to(Globals.dialoging.global_position).x < 0)
	$AnimationPlayer.play("Idle")
	$Indicator.visible = false
	$AnimationPlayer.playback_speed = 1
	
func dialog_exit():
	#Appelé à la fin d'un dialogue
	$Indicator.visible = true

func _process(delta):
	if Globals.dialoging:
		return

	if $Indicator.visible:
		choose_focus()
		#C'est moche comme ça mais oklm
		#L'indicateur va se positionnier au dessus du NPC / item avec lequel il pourra interagir
		#var hitbox_target = target.get_node("CollisionShape2D")
		#var offset = -(hitbox_target.shape.extents.y*hitbox_target.scale.y)
		print(target.get_node("AnimatedSprite").position.y)
		print()
		var offset = -(target.get_node("AnimatedSprite").frames.get_frame("idle", 0).get_size()[1])*2
		#Un truc hyper compliqué juste pour trouver le milieu haut du sprite de l'interlocuteur
		#Faudra le changer plus tard si on veut interagir avec des items parce que ça force à avoir AnimatedSprite là
		$Indicator.global_position = Vector2(target.position.x, target.position.y+offset)
	
	#Après un coup, le joueur est invincible pendant "Globals.invincibility" secondes.
	if Globals.invincibility > 0:
		Globals.invincibility -= delta
	#Si le joueur se fait taper, on l'empêche de bouger ou interagir
	if $AnimationPlayer.current_animation == "Hit":
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
	if direction != Vector2.ZERO:
		if direction.x != 0: turn(direction.x < 0)
		$AnimationPlayer.play("Walk")
	else:
		$AnimationPlayer.play("Idle")

func on_hit(damage):
	if Globals.invincibility <= 0:
		$AnimationPlayer.play("Hit")
		Globals.health -= damage
		emit_signal("health_changed", Globals.health)
		Globals.invincibility = Globals.invincibility_cd
		if Globals.health <= 0:
			emit_signal("player_death")
			get_parent().remove_child(self)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Hit":
		$AnimationPlayer.play("Idle")

func choose_focus():
	var dist = self.position.distance_to(interactions[0].position)
	target = interactions[0]
	for body in interactions:
		var dist2 = self.position.distance_to(body.position)
		if dist2 < dist:
			target = body

func _on_InteractionArea_body_entered(body):
	#On liste toutes les interactions possible
	#On trouve la plus proche de nous => On la définie comme cible.
	if body in npcs:
		interactions.append(body)
		$Indicator.visible=true

func _on_InteractionArea_body_exited(body):
	#On retire l'interaction manquante de la liste et si la liste est vide on fait disparaitre l'indicateur.
	if body in npcs:
		var index = interactions.find(body, 0)
		if index != -1:
			interactions.remove(index)
		else:
			print("index not found")
	if interactions.size() == 0:
		$Indicator.visible = false

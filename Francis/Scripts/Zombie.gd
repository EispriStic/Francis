extends KinematicBody2D

export var detection_rad: int
export var base_speed:int = 300
export var acceleration:int = 5
signal player_got_hit

var state = "patrolling"
var target = null
var speed = base_speed
var last_point = null
var velocity = Vector2.ZERO

func _ready():
	$Area2D/CollisionShape2D.shape.radius = detection_rad

func _process(delta):
	if $AnimationPlayer.current_animation == "attack":
		return
	
	if state == "chasing": #Il accélère indéfiniement s'il pourchasse le joueur jusqu'à le toucher
		speed+=(acceleration*delta)
	else:
		speed = base_speed
	
	if state == "chasing":
		#J'ai pas réussi à faire marcher le pathfinding donc il va juste foncer sur lui sans vérifier les murs
		#Typical Zombie Move
		velocity = global_position.direction_to(target.global_position).normalized() * speed
		move_and_slide(velocity)
		
		#On récupère les collisions suite au mouvement
		var slide_count = get_slide_count()
		for idx in range(slide_count):
			var collision = get_slide_collision(idx)
			var collider = collision.collider
			#Si on trouve le joueur dans les collisions
			if collider.name == "Player":
				$AnimationPlayer.play("attack")
				velocity = Vector2.ZERO
				#On divise par deux notre accélération
				speed = int((base_speed + speed)/2)
				emit_signal("player_got_hit", 1)
				return

	if state == "returning":
		#Retour au point pour continuer le patterne
		var distance = global_position.distance_to(last_point)
		if distance > 3:
			velocity = global_position.direction_to(last_point).normalized() * speed
			move_and_slide(velocity)
		else:
			#Y avait un soucis, il tournait autour du point et glitchait sans jamais être PILE dessus
			#J'ai mis un gros pansement au lieu de régler le soucis
			velocity = Vector2.ZERO
			speed = base_speed
			global_position = last_point
			state = "patrolling"
	
	#Gestion de l'animation
	if velocity == Vector2.ZERO and $AnimationPlayer.current_animation != "idle":
		$AnimationPlayer.play("idle")
	elif $AnimationPlayer.current_animation != "run":
		$AnimationPlayer.play("run")
	
	if velocity.x < 0 and (not $AnimatedSprite.flip_h):
		$AnimatedSprite.flip_h = true
	elif velocity.x > 0 and $AnimatedSprite.flip_h:
		$AnimatedSprite.flip_h = false

func _on_Area2D_body_entered(body): #On détecte le joueur, on sauvegarde le point et on le pourchasse
	if body.get_name() == "Player":
		if state == "patrolling":
			last_point = global_position
		state = "chasing"
		target = body


func _on_Area2D_body_exited(body):
	#Le joueur sort de la zone de détection, on retourne au point pour continuer le patterne
	if body.get_name() == "Player":
		state = "returning"
		target = null

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "attack":
		$AnimationPlayer.play("idle")

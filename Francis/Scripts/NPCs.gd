extends KinematicBody2D

enum BEHAVIORS { Idle,Running_Around }
export(BEHAVIORS) var behavior

export (Array, String) var dialogs
export var speed:int = 500
export var min_timer = 1.5
export var max_timer = 3.5
export var max_collision = 3
var current_collision = 0
var timer
export var max_range_from_player = 3000
var rng = RandomNumberGenerator.new()
var destination = Vector2.ZERO
var dialogscene = preload("res://Scenes/DialogNode.tscn")

func _ready():
	rng.randomize()
	$AnimationPlayer.play("Idle")
	set_timer()
	assert(dialogs.size() != 0, "No dialog set for NPC " + name+ " !")

func set_timer():
	timer = rng.randf_range(min_timer, max_timer)

func generate_coord():
	var x = rng.randi_range(Globals.player.global_position.x - max_range_from_player/2,
	 Globals.player.global_position.x + max_range_from_player/2)
	var y = rng.randi_range(Globals.player.global_position.y - max_range_from_player/2,
	 Globals.player.global_position.y + max_range_from_player/2)
	return Vector2(x,y)

func turn(value=null):
	if value == null or value != $AnimatedSprite.flip_h:
		$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
		$AnimatedSprite.offset.x = - $AnimatedSprite.offset.x

func _process(delta):
	if Globals.dialoging == self:
		return
	timer-=delta
	match behavior:
		0: #Idle
			$AnimationPlayer.play("Idle")
			if timer <= 0:
				turn()
				set_timer()
		1: #Running Around
			var state = $AnimationPlayer.current_animation
			if state == "Idle":
				#il reste dans cet état "timer" secondes.
				if timer <= 0:
					$AnimationPlayer.play("Run")
					destination = generate_coord()
					set_timer()
			elif state == "Run":
				#Se déplace vers le point
				var dir = global_position.direction_to(destination)
				turn(dir.x < 0)
				var velocity = dir * speed
				move_and_slide(velocity)
				if timer <= 0 or global_position.distance_to(destination) < 10 or get_slide_count() != 0:
					#Une fois le temps écoulé ou le point atteint, rechange d'état.
					$AnimationPlayer.play("Idle")
					if get_slide_count() == 0:
						set_timer()
					else:
						current_collision += 1
						if current_collision == max_collision:
							set_timer()
							current_collision = 0
						else:
							timer = 0

func _on_Player_interaction(target):
	if target == self:
		#Sauvegarde les valeurs courantes pour les réattribuer après le dialogue
		$AnimationPlayer.play("Idle")
		turn(not global_position.direction_to(Globals.player.global_position).x >= 0) #Se tourne vers le joueur
		var instance = dialogscene.instance() #Lance le dialogue
		instance.init(dialogs[randi()%dialogs.size()])
		add_child(instance)

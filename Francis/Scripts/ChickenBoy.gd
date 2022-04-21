extends KinematicBody2D

export var speed:int = 500
export var max_timer = 3
var timer = max_timer
var max_range_point = 740
var range_point = max_range_point
var rng = RandomNumberGenerator.new()
var direction = Vector2(0,0)
var state = "Idle"

var save_value = []

var dialogscene = preload("res://Scenes/DialogNode.tscn")

func _ready():
	rng.randomize()
	$AnimationPlayer.play("Idle")
	Globals.connect("stop_dialoging", self, "dialog_exit")

func dialog_exit():
	#Récupère son état avant l'interaction (course ou marche)
	$AnimationPlayer.play(save_value[0])
	$AnimatedSprite.flip_h = save_value[1]
	save_value = []

func _process(delta):
	if Globals.dialoging:
		return
	if state == "Idle":
		#il reste dans cet état "timer" secondes.
		timer-=delta
		if timer <= 0:
			#Puis prend une direction aléatoire et vas s'y diriger
			direction = Vector2(rng.randf()-0.5, rng.randf()-0.5).normalized()
			state = "Run"
			$AnimationPlayer.play("Run")
			$AnimatedSprite.flip_h = direction.x <= 0
	elif state == "Run":
		#Se déplace vers la direction aléatoire choisie
		var velocity = direction*speed
		var dir = move_and_slide(velocity)
		range_point-=(velocity*delta).length()
		if range_point < 0:
			#Une fois le point atteint, il rechange d'état.
			$AnimationPlayer.play("Idle")
			timer = max_timer
			state = "Idle"
			range_point=rng.randi_range(max_range_point/3, max_range_point)


func _on_Player_interaction(target):
	if target == self:
		print(get_children())
		#Sauvegarde les valeurs courantes pour les réattribuer après le dialogue
		save_value.append($AnimationPlayer.current_animation)
		save_value.append($AnimatedSprite.flip_h)
		$AnimationPlayer.play("Idle")
		if global_position.direction_to(Globals.player.global_position).x > 0: #Se tourne vers le joueur
			$AnimatedSprite.flip_h = false
		else:
			$AnimatedSprite.flip_h = true
		var instance = dialogscene.instance() #Lance le dialogue
		instance.init("0")
		add_child(instance)

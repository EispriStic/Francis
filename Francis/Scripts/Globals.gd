extends Node

var player
var health = 5
var base_speed = 380
var invincibility = 0
var max_energy = 5
var max_energy_cd = 3
var invincibility_cd = 2
var energy_cd = max_energy_cd
var energy = max_energy
var position = 1
var dialoging = null
var last_dialog_state = null
var paused = false

signal start_dialoging
signal stop_dialoging

func _ready():
	VisualServer.set_default_clear_color(Color(0,0,0,0)) #Met le fond en noir
	pause_mode = Node.PAUSE_MODE_PROCESS

func _process(delta):
	if dialoging != last_dialog_state: #Si changement de la valeur de dialog
		last_dialog_state = dialoging
		if dialoging:
			emit_signal("start_dialoging")
		else:
			emit_signal("stop_dialoging")
		
		
	if Input.is_action_just_pressed("pause"):
		return #Plus tard...

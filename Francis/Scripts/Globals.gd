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
var dialoging = null
var last_dialog_state = null
var paused = false

#Save Variable
#Default values = New Game
var position = 1
var map = 1
var pseudo = "Francis"
var known_npcs = {"0":{"name":pseudo, "dialogs":{}}}
var merchant_multiply = 1.25
var inventory = []


signal start_dialoging
signal stop_dialoging

func _ready():
	VisualServer.set_default_clear_color(Color(0,0,0,0)) #Met le fond en noir
	pause_mode = Node.PAUSE_MODE_PROCESS

func _process(delta):
	if dialoging != last_dialog_state: #Si changement de la valeur de dialog
		if not last_dialog_state:
			emit_signal("start_dialoging")
		else:
			emit_signal("stop_dialoging", last_dialog_state is KinematicBody2D)
		last_dialog_state = dialoging
		
		
	if Input.is_action_just_pressed("pause"):
		return #Plus tard...

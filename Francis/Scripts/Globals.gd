extends Node

var player
var max_health
var health
var base_speed
var invincibility
var max_energy
var max_energy_cd
var invincibility_cd
var energy_cd
var energy
var dialoging = null
var last_dialog_state = null

#Save Variable
#Default values = New Game
var position = 1
var map = 1
var pseudo = "Francis"
var merchant_multiply = 1.25
var inventory = []
var FLAGS = {
	"ALWAYS_TRUE":true,
	"LVL2_SPEAK":false,
	"PARENT_QUEST_STARTED":false
}
var dialog_data = {}
var npc_known = [{"name":"PLAYER", "origin_name":"player"}]

func reset_player():
	max_health = 5.0
	health = 5.0
	base_speed = 380.0
	invincibility = 0
	max_energy = 5.0
	max_energy_cd = 3.0
	invincibility_cd = 2.0
	energy_cd = max_energy_cd
	energy = max_energy

func find_npc_by_name(name):
	for i in npc_known:
		if i.origin_name == name:
			return i
	return null

signal start_dialoging
signal stop_dialoging

func _ready():
	reset_player()
	VisualServer.set_default_clear_color(Color(0,0,0,0)) #Met le fond en noir
	pause_mode = Node.PAUSE_MODE_PROCESS

func _process(delta):
	if dialoging != last_dialog_state: #Si changement de la valeur de dialog
		if not last_dialog_state:
			emit_signal("start_dialoging", dialoging is KinematicBody2D, dialoging)
		else:
			emit_signal("stop_dialoging", last_dialog_state is KinematicBody2D, last_dialog_state)
		last_dialog_state = dialoging
		
		
	if Input.is_action_just_pressed("pause"):
		return #Plus tard...

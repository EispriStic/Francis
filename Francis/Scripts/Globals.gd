extends Node

var health = 5
var base_speed = 380
var invincibility = 0
var max_energy = 5
var max_energy_cd = 3
var invincibily_seconds = 2
var energy_cd = max_energy_cd
var energy = max_energy
var position = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	VisualServer.set_default_clear_color(Color(0,0,0,0))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

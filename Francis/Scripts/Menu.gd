extends Control

export var save_path = ""

onready var cont = $VBoxContainer/Continue
onready var start = $VBoxContainer/Start


func _ready():
	var f = File.new()
	# Désactive le bouton continuer s'il n'y a pas de sauvegarde.
	if not f.file_exists(save_path):
		cont.disabled = true
		start.grab_focus()
	else:
		cont.grab_focus()


func _on_Quit_pressed():
	get_tree().quit()


func _on_Continue_pressed():
	Globals.reset_player()
	load_save()

func load_save():
	#Charge la sauvegarde : fichier json ayant des valeurs qui seront set dans le script Globals
	#Valeur "level" qui permettra de choisir la scène à charger.
	var f = File.new()
	assert(f.file_exists(save_path), "Sauvegarde introuvable.")
	f.open(save_path, File.READ)
	var json = f.get_as_text()
	var output = parse_json(json)
	Globals.position = output.position
	var map = str(output.level)
	get_tree().change_scene("res://Levels/Level_"+map+".tscn")


func _on_Start_pressed():
	Globals.reset_player()
	get_tree().change_scene("res://Levels/Level_1.tscn")

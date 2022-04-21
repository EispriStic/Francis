extends Control

export var save_path = ""


func _ready():
	var f = File.new()
	#Affiche ou non le bouton Continuer s'il y a une sauvegarde
	#Update les voisins selon la présence ou non du bouton continuer
	if not f.file_exists(save_path):
		$VBoxContainer/Continue.queue_free()
		$VBoxContainer/Start.grab_focus()
		$VBoxContainer/Start.focus_neighbour_top = $VBoxContainer/Quit.get_path()
		$VBoxContainer/Quit.focus_neighbour_bottom = $VBoxContainer/Start.get_path()
	else:
		$VBoxContainer/Continue.grab_focus()
		$VBoxContainer/Continue.focus_neighbour_top = $VBoxContainer/Quit.get_path()
		$VBoxContainer/Quit.focus_neighbour_bottom = $VBoxContainer/Continue.get_path()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Quit_pressed():
	get_tree().quit()


func _on_Continue_pressed():
	load_save()

func load_save():
	#Charge la sauvegarde : fichier json ayant des valeurs qui seront set dans le script Globals
	#Valeur "level" qui permettra de choisir la scène à charger.
	var f = File.new()
	assert(f.file_exists(save_path), "Sauvegarde introuvable.")
	f.open(save_path, File.READ)
	var json = f.get_as_text()
	var output = parse_json(json)
	
	output.position = Globals.position
	var level = str(output.level)
	if len(level) == 1:
		level = "0" + level
	get_tree().change_scene("res://Scenes/Level"+level+".tscn")


func _on_Start_pressed():
	get_tree().change_scene("res://Scenes/Level01.tscn")

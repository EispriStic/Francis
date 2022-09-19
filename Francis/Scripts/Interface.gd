extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$HpBar.value = (Globals.health/Globals.max_health)*100
	$StaminaBar.value = (Globals.energy/Globals.max_energy)*100

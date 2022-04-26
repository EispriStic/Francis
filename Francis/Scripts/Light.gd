extends Light2D

enum BEHAVIORS { On,Off,Graduate,Flash }
export(BEHAVIORS) var behavior

export var min_energy = 0.0
export var max_energy = 1.5
export var timer = 3.0
export var flashes = 5
export var anim_time = 0.2
var multiply = 1
var nb_flashes = 0
onready var diff = max_energy - min_energy

func _ready():
	$Timer.wait_time = timer
	$Timer.one_shot = true
	$Timer.start()
	energy = max_energy

func _process(delta):
	if $Timer.is_stopped():
		match behavior:
			0: #On
				enabled = true
			1: #Off
				enabled = false
			2: #Graduate
				enabled = true
				energy += (diff/anim_time)*delta * multiply
				print(energy)
				print(delta)
				if energy <= min_energy:
					multiply = -multiply
					energy = min_energy
					$Timer.start()
				elif energy >= max_energy:
					multiply = -multiply
					energy = max_energy
					$Timer.start()
			3: #Flash
				enabled = true
				if nb_flashes == flashes*2:
					nb_flashes = 0
					$Timer.wait_time = timer
				else:
					if nb_flashes%2 == 0:
						energy = min_energy
					else:
						energy = max_energy
					$Timer.wait_time = anim_time
					nb_flashes += 1
				$Timer.start()

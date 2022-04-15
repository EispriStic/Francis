extends KinematicBody2D

export var speed:int = 500
export var max_timer = 3
var timer = max_timer
var max_range_point = 740
var range_point = max_range_point
var rng = RandomNumberGenerator.new()
var direction = Vector2(0,0)
var state = "Idle"

var dialogscene = preload("res://Scenes/DialogNode.tscn")

func _ready():
	rng.randomize()
	$AnimationPlayer.play("Idle")

func _process(delta):
	if Globals.dialoging:
		return
	if state == "Idle":
		timer-=delta
		if timer <= 0:
			direction = Vector2(rng.randf()-0.5, rng.randf()-0.5).normalized()
			print(direction)
			state = "Run"
			$AnimationPlayer.play("Run")
			$AnimatedSprite.flip_h = direction.x <= 0
	elif state == "Run":
		var velocity = direction*speed
		var dir = move_and_slide(velocity)
		range_point-=(velocity*delta).length()
		if range_point < 0:
			$AnimationPlayer.play("Idle")
			timer = max_timer
			state = "Idle"
			range_point=rng.randi_range(max_range_point/3, max_range_point)


func _on_Player_interaction(target):
	if target == self and not get_node_or_null("DialogNode"):
		$AnimationPlayer.play("Idle")
		var instance = dialogscene.instance()
		add_child(instance)

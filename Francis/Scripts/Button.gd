extends KinematicBody2D

var activated = false
export var id = 0

signal active

var remotes

func _ready():
	remotes = get_tree().get_nodes_in_group("remote")
	for i in remotes:
		self.connect("active", i, "_on_Button_active")

func switch():
	activated = not activated
	if activated:
		$AnimatedSprite.frame = 1
		emit_signal("active", id)
	else:
		$AnimatedSprite.frame = 0
		emit_signal("active", id)

func _on_Player_interaction(target):
	if target == self:
		switch()

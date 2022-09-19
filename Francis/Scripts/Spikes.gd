extends KinematicBody2D

export var id = [0]
export var activate = true
export var damage = 1
signal player_got_hit

func _ready():
	if not activate: _on_Button_active(id[0])


func _on_Player_collide(body, player):
	if body == self:
		emit_signal("player_got_hit", damage)
		var pos = player.position

func _on_Button_active(id_sign):
	if not (id_sign in id): return
	$CollisionShape2D.disabled = not $CollisionShape2D.disabled
	$LightOccluder2D.visible = not $LightOccluder2D.visible
	if $AnimatedSprite.frame == 10: $AnimatedSprite.frame = 0
	else: $AnimatedSprite.frame = 10

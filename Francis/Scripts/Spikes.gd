extends KinematicBody2D

export var id = 0
export var damage = 1
signal player_got_hit

func _ready():
	pass


func _on_Player_collide(body, player):
	if body == self:
		emit_signal("player_got_hit", damage)
		var pos = player.position

func _on_Button_active(id_sign, value):
	if id_sign != id: return
	if value:
		$CollisionShape2D.disabled = true
		$AnimatedSprite.frame = 0
	else:
		$CollisionShape2D.disabled = false
		$AnimatedSprite.frame = 10

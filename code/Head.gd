extends RigidBody2D
class_name Head

func hit(dmg: float):
	var color = modulate
	modulate = Color(1, color.g - dmg, color.b - dmg, 1)
	if color.g <= 0:
		get_parent().queue_free()


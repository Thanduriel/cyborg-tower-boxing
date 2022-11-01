extends RigidBody2D
class_name Head

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func hit(dmg: float):
	var color = modulate
	modulate = Color(1, color.g - dmg, color.b - dmg, 1)
	if color.g <= 0:
		get_parent().queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

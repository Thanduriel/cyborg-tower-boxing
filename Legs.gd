extends RigidBody2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

export var speed: float = 500


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	for x in get_colliding_bodies():
		if x.get_name() == "GroundCollider":
			if Input.is_action_pressed("move_left"):
				apply_central_impulse(Vector2.LEFT * speed * delta * weight)
			elif Input.is_action_pressed("move_right"):
				apply_central_impulse(Vector2.RIGHT * speed * delta * weight)


extends RigidBody2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

export var speed = 500

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("move_left"):
		linear_velocity.x = -speed
		# move_and_slide(Vector2.LEFT * speed, Vector2.UP)
	if Input.is_action_pressed("move_right"):
		linear_velocity.x = speed
		#move_and_slide(Vector2.RIGHT * speed, Vector2.UP)


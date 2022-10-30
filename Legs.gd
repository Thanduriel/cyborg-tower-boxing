extends RigidBody2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

export var speed: float = 500
export var jumpForce = 8
var partScene = preload("res://Part.tscn")
export var dont_move: bool = false
var head = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("spawn"):
		var part = partScene.instance()
		part.global_position = head.global_position + Vector2.UP.rotated(head.global_rotation) * 70
		part.global_rotation = head.global_rotation
		part.stack(head.get_path())
		get_tree().root.add_child(part)
		head = part.get_node("Body")

func below(pos) -> Vector2:
	pos.y = 490
	return pos

func _physics_process(delta: float) -> void:
	$"Skeleton2D/center/hip".rotation = -global_rotation 
	$"IK-Left".reach_toward(below($"Skeleton2D/center/hip/leg_left".global_position))
	$"IK-Right".reach_toward(below($"Skeleton2D/center/hip/leg_right".global_position))
	if not dont_move:
		for x in get_colliding_bodies():
			if x.get_name() == "GroundCollider":
				if Input.is_action_pressed("move_left"):
					apply_central_impulse(Vector2.LEFT * speed * delta * weight)
				elif Input.is_action_pressed("move_right"):
					apply_central_impulse(Vector2.RIGHT * speed * delta * weight)
				if Input.is_key_pressed(KEY_UP):
					apply_central_impulse(Vector2.UP * jumpForce * weight)


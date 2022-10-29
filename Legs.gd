extends RigidBody2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

export var speed: float = 500
export var jumpForce = 8
export var can_move = true
var partScene = preload("res://Part.tscn")

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

func _physics_process(delta: float) -> void:
	if not can_move: return
	for x in get_colliding_bodies():
		if x.get_name() == "GroundCollider":
			if Input.is_action_pressed("move_left"):
				apply_central_impulse(Vector2.LEFT * speed * delta * weight)
			elif Input.is_action_pressed("move_right"):
				apply_central_impulse(Vector2.RIGHT * speed * delta * weight)
			if Input.is_key_pressed(KEY_UP):
				apply_central_impulse(Vector2.UP * jumpForce * weight)


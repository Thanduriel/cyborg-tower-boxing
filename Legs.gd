extends RigidBody2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

export var speed: float = 500
export var jumpForce = 8
var partScene = preload("res://Part.tscn")
export var dont_move: bool = false
var head = self

onready var hip = $"Visual/Skeleton2D/center/hip"

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
	var space_state = get_world_2d().get_direct_space_state()
	hip.rotation = -global_rotation

	var pos = hip.get_node("leg_left").global_position
	var result = space_state.intersect_ray(pos,pos + Vector2.DOWN * 200, [self])
	if result.size():
		$"IK-Left".reach_toward(result.position)
		hip.get_node("leg_left/culf_left/lower_left").global_rotation = Vector2.UP.angle_to_point(result.normal)
	pos = hip.get_node("leg_right").global_position
	result = space_state.intersect_ray(pos,pos + Vector2.DOWN * 200, [self])
	if result.size():
		$"IK-Right".reach_toward(result.position)
		hip.get_node("leg_right/culf_right/lower_rigth").global_rotation = Vector2.UP.angle_to_point(result.normal)


	if not dont_move:
		for x in get_colliding_bodies():
			if x.get_name() == "GroundCollider":
				if Input.is_action_pressed("move_left"):
					apply_central_impulse(Vector2.LEFT * speed * delta * weight)
				elif Input.is_action_pressed("move_right"):
					apply_central_impulse(Vector2.RIGHT * speed * delta * weight)
				if Input.is_key_pressed(KEY_UP):
					apply_central_impulse(Vector2.UP * jumpForce * weight)


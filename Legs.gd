extends RigidBody2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


export var speed: float = 500
export var jumpForce = 8
export var dont_move: bool = false

var partScene = preload("res://Part.tscn")

onready var parts = [self, $Head]


onready var hip = $"Visual/Skeleton2D/center/hip"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Head/Joiner.stack(get_path(), $Head.get_path())

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("spawn"):

		var head = parts.pop_back() as RigidBody2D
		var prev = parts.back() as RigidBody2D
		var up = Vector2.UP.rotated(prev.global_rotation)

		var part = partScene.instance()
		part.global_position = prev.global_position + up * 70
		part.global_rotation = prev.global_rotation
		var bodyPart = part.get_node("Body")
		get_tree().root.add_child(part)
		part.get_node("Joiner").stack(prev.get_path(), bodyPart.get_path())
		parts.push_back(bodyPart)

		head.global_position = part.global_position + up * 80
		head.global_rotation = part.global_rotation
		head.get_node("Joiner").stack(bodyPart.get_path(), head.get_path())
		parts.push_back(head)


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


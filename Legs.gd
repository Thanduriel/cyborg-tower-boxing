extends RigidBody2D

export var speed: float = 500
export var jumpForce = 8
var partScene = preload("res://Part.tscn")
var stand_left = true
var fixed_foot_pos = Vector2.ZERO
var walking_ani_fact = 0.03
var in_air_foot_dist = 80
var forward_dir = 1.0
export var isPlayerB = false

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
		part.isPlayerB = isPlayerB
		var bodyPart = part.get_node("Body")
		get_tree().root.add_child(part)
		part.get_node("Joiner").stack(prev.get_path(), bodyPart.get_path())
		parts.push_back(bodyPart)

		head.global_position = part.global_position + up * 100
		head.global_rotation = part.global_rotation
		head.get_node("Joiner").stack(bodyPart.get_path(), head.get_path())
		parts.push_back(head)

func reach_smoothly(ik, target_bone, target_pos, delta):
	var current_pos = target_bone.global_position
	var diff = target_pos - current_pos
	var l = diff.length()
	
	if l > 0.1:
		ik.reach_toward(current_pos + diff * min(1.0, delta * 256 / l))
		
	target_bone.global_rotation = Vector2.RIGHT.angle()

func _physics_process(delta: float) -> void:
	var is_touching_ground = false
	for x in get_colliding_bodies():
		if x.get_name() == "GroundCollider":
			is_touching_ground = true
			break

	if is_touching_ground:
		var pre = "b_" if isPlayerB else "a_"
		if Input.is_action_pressed(pre + "move_left"):
			apply_central_impulse(Vector2.LEFT * speed * delta * weight)
		elif Input.is_action_pressed(pre + "move_right"):
			apply_central_impulse(Vector2.RIGHT * speed * delta * weight)
		if Input.is_key_pressed(KEY_UP):
			apply_central_impulse(Vector2.UP * jumpForce * weight)

	var space_state = get_world_2d().get_direct_space_state()
	$"Visual/Skeleton2D/center/hip".rotation = -global_rotation

	# walking
	if is_touching_ground:
		var moving_foot = $"Visual/Skeleton2D/center/hip/leg_left/culf_left/lower_left"
		var moving_ik = $"IK-Left"
		var moving_leg = $"Visual/Skeleton2D/center/hip/leg_left"
		var fixed_foot = $"Visual/Skeleton2D/center/hip/leg_right/culf_right/lower_rigth"
		var fixed_ik = $"IK-Right"
		var fixed_leg = $"Visual/Skeleton2D/center/hip/leg_right"
		if stand_left:
			moving_foot = $"Visual/Skeleton2D/center/hip/leg_right/culf_right/lower_rigth"
			moving_ik = $"IK-Right"
			moving_leg = $"Visual/Skeleton2D/center/hip/leg_right"
			fixed_foot = $"Visual/Skeleton2D/center/hip/leg_left/culf_left/lower_left"
			fixed_ik = $"IK-Left"
			fixed_leg = $"Visual/Skeleton2D/center/hip/leg_left"

		var pos = moving_leg.global_position
		var v = linear_velocity.x
		pos.x = moving_foot.global_position.x + walking_ani_fact * v
		var result = space_state.intersect_ray(pos,pos + Vector2.DOWN * 200, [self])
		if result.size():
			moving_ik.reach_toward(result.position)
			moving_foot.global_rotation = Vector2.UP.angle_to_point(result.normal)

		pos = fixed_leg.global_position
		pos.x = fixed_foot_pos.x
		result = space_state.intersect_ray(pos,pos + Vector2.DOWN * 200, [self])
		if result.size():
			fixed_foot.global_rotation = Vector2.UP.angle_to_point(result.normal)
		fixed_ik.reach_toward(fixed_foot_pos)

		# switch legs if the fixed pos is streched to far
		var d = fixed_foot.global_position.distance_to(fixed_foot_pos)
		#var d = $"Skeleton2D/center/hip".global_position.distance_to(fixed_foot_pos)
		var threshold = 1 if v * forward_dir >= 0 else 10
		if d > threshold:
			stand_left = not stand_left
			fixed_foot_pos = moving_foot.global_position
	else:
		var target_pos = $"Visual/Skeleton2D/center/hip/leg_left".global_position
		target_pos.y += in_air_foot_dist
		var left_foot = $"Visual/Skeleton2D/center/hip/leg_left/culf_left/lower_left"
		reach_smoothly($"IK-Left", left_foot, target_pos, delta)
		
		target_pos = $"Visual/Skeleton2D/center/hip/leg_right".global_position
		target_pos.y += in_air_foot_dist
		var right_foot = $"Visual/Skeleton2D/center/hip/leg_right/culf_right/lower_rigth"
		reach_smoothly($"IK-Right", right_foot, target_pos, delta)
		
		fixed_foot_pos = left_foot.global_position if stand_left else right_foot.global_position
	#	for i in range(0,$Visual/Skeleton2D.get_bone_count()):
	#		$Visual/Skeleton2D.get_bone(i).apply_rest()

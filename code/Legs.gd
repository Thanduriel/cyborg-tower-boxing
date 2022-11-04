extends RigidBody2D
class_name Legs

export var speed: float = 500
export var jumpForce = 8
export var isPlayerB = false

var partScene = preload("res://scenes/Part.tscn")
var standLeft = true
var fixedFootPos = Vector2.ZERO
var fixedFootNormal = Vector2.UP
var wasTouchingGround = false

onready var parts = [self, $Head]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if isPlayerB:
		$Polygons.scale *= Vector2(-1, 1)
		$Skeleton2D.scale *= Vector2(-1, 1)
		$LeftIk.is_reversed = true
		$RightIk.is_reversed = true
		$Head/Chest.flip_h = true
		$Head/Head.flip_h = true
		$Head/CollisionShape2D.position.x *= -1

	$Head/Joiner.stack(get_path(), $Head.get_path())

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("spawn"):
		var old = parts
		parts = []
		for part in old:
			if part and is_instance_valid(part):
				parts.append(part)

		var head = parts.pop_back() as RigidBody2D
		var prev = parts.back() as RigidBody2D
		var up = Vector2.UP.rotated(prev.global_rotation)

		var part = partScene.instance()
		part.global_position = prev.global_position + up * 65
		part.global_rotation = prev.global_rotation + deg2rad(-3 if isPlayerB else 3)
		part.isPlayerB = isPlayerB
		part.top = head
		part.index = parts.size()
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

	if abs(target_bone.rotation) > 0.01:
		target_bone.rotation -= sign(target_bone.rotation) * min(abs(target_bone.rotation), delta * 4)#Vector2.LEFT.angle() if isPlayerB  else Vector2.RIGHT.angle()

func _physics_process(delta: float) -> void:
	var onGround = isTouchingGround()
	var standCast: RayCast2D = $LeftCast if standLeft else $RightCast
	var moveCast: RayCast2D = $RightCast if standLeft else $LeftCast

	$RightCast.rotation = linear_velocity.x * -.001 - deg2rad(8)
	$LeftCast.rotation = linear_velocity.x * -.001 + deg2rad(8)

	if onGround:
		var pre = "b_" if isPlayerB else "a_"
		if Input.is_action_pressed(pre + "move_left"):
			apply_central_impulse(Vector2.LEFT * speed * delta * weight)
		elif Input.is_action_pressed(pre + "move_right"):
			apply_central_impulse(Vector2.RIGHT * speed * delta * weight)

		apply_central_impulse(-pow(linear_velocity.x,2) * (linear_velocity.normalized()*Vector2.RIGHT) * .001)

		if Input.is_action_just_pressed(pre + "jump"):
			apply_central_impulse(Vector2.UP * jumpForce * weight)

		# stand
		var standIk: InverseKinematic = $LeftIk if standLeft else $RightIk
		#standIk.reach_toward(fixedFootPos)
		var standFoot = standIk.get_node(standIk.terminus_node) as Node2D
		standFoot.global_rotation = Vector2.UP.angle_to(fixedFootNormal)
		standIk.reach_toward(standFoot.global_position.move_toward(fixedFootPos, delta * 800))

		# move
		var cycle = standCast.global_position.distance_to(fixedFootPos) / standCast.cast_to.length()

		var velocityMod = clamp(1 - abs(linear_velocity.x)/200, 0, 1)
		var cycleMode = 1 - (1-cycle) * 1.2
		var velocityCycle = clamp(cycleMode + velocityMod, 0, 1)
		var target = (moveCast.get_collision_point() - moveCast.global_position) * velocityCycle + moveCast.global_position

		var moveIk: InverseKinematic = $RightIk if standLeft else $LeftIk
		var moveFoot = standIk.get_node(moveIk.terminus_node) as Node2D
		moveFoot.global_rotation = Vector2.UP.angle_to(moveCast.get_collision_normal()) - 1.5*(1-velocityCycle) * (-1 if isPlayerB else 1)
		moveIk.reach_toward(moveFoot.global_position.move_toward(target, delta * 500))

		if cycle > 1:
			standLeft = not standLeft
			standCast = moveCast
			wasTouchingGround = false

	if onGround and not wasTouchingGround:
		fixedFootPos = standCast.get_collision_point()
		fixedFootNormal = standCast.get_collision_normal()

	wasTouchingGround = onGround

func isTouchingGround():
	for x in get_colliding_bodies():
		if x.is_in_group("Ground"):
			return true
	if $LeftCast.is_colliding():
		return true
	if $RightCast.is_colliding():
		return true
	return false

extends Node2D
class_name Part

export var cooldown = 1.5
export var reach = 50
export var isPlayerB = false
export var index = 0 # lowest part has 0
export var stop_time: float = 0.07 # time after punsh, arm keeps extendet

var projectileScene = preload("res://scenes/Projectile.tscn")
onready var progress = get_node("Body/TextureProgress")
onready var damage = get_node("Body/Damage")
var proj: KinematicBody2D = null
var move_back: bool = true
var top = null
onready var projOrigin = get_node("Body/Woble_Body/Projectile_Origin")
var reachTowards: Vector2 = Vector2(0,0)
onready var fist = $"Body/Visuals/Skeleton2D/Upper_Arm/Lower_Arm/Fist"

var distance: float = 0
var proj_valid: bool = false
func hit(dmg: float) -> void:
	print("realy hit")
	var color = $Body.modulate
	$Body.modulate = Color(1, color.g - dmg, color.b - dmg, 1)
	if color.g <= 0:
		var bottom = get_node($Joiner/PinJoint2D.node_a)
		print("OO ", top.get_name(), bottom.get_name())
		var joiner_top = top.get_child(0)
		for child in joiner_top.get_children():
			child.node_a = bottom.get_path();
		var up = Vector2.UP.rotated(bottom.global_rotation)
		# top.global_position.x = bottom.global_position * up * 70
		queue_free()


func _ready() -> void:
	if isPlayerB:
		$Body/Visuals.scale.x *= -1
		$InverseKinematic.is_reversed = true
		$Body/Woble_Body.position.x *= -1
		$Body/Woble_Body/PinJoint2D.disable_collision = !$Body/Woble_Body/PinJoint2D.disable_collision
		$Body/Woble_Body/PinJoint2D.disable_collision = !$Body/Woble_Body/PinJoint2D.disable_collision
	reachTowards = projOrigin.get_global_position()

func _process(delta: float) -> void:
	if progress.value > 0:
		progress.value -= delta * 100 / cooldown
	else:
		var pre = "b_" if isPlayerB else "a_"
		var post = ""
		match index:
			1: post= "_0"
			2: post="_1"
			3: post="_2"
			4: post="_3"
		if Input.is_action_just_pressed(pre+"shoot"+post):
			shoot()

	$InverseKinematic.reach_toward(reachTowards)

	if is_instance_valid(proj):
		move_back = false
		reachTowards = proj.global_position
		# fist is extended
		if projOrigin.global_position.distance_to(proj.global_position) > reach:
			proj.queue_free()
			proj = null
			var attack_timer = get_tree().create_timer(stop_time)
			yield(attack_timer, "timeout")
			move_back = true
	elif proj and not is_instance_valid(proj):
		proj = null
		var attack_timer = get_tree().create_timer(stop_time)
		yield(attack_timer, "timeout")
		move_back = true
	elif move_back:
		reachTowards = reachTowards.move_toward(projOrigin.global_position, delta * 500)




func shoot() -> void:
	progress.value = 100
	proj = projectileScene.instance()
	proj.global_position =  projOrigin.global_position
	proj.speed = 500
	proj.origin = $Body
	proj.impluse = 1000
	proj.impulse_on_hit = 300
	proj.direction = (Vector2.LEFT if isPlayerB else Vector2.RIGHT).rotated(projOrigin.global_rotation)
	proj.parent = projOrigin
	proj.isPlayerB = isPlayerB
	get_tree().root.add_child(proj)

	# reset fist for distance calc
	$InverseKinematic.reach_toward(proj.global_position)

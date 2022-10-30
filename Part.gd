extends Node2D
class_name Part

export var cooldown = 1.5
export var reach = 50
export var isPlayerB = false
export var index = 0 # lowest part has 0
export var stop_time: float = 0.07 # time after punsh, arm keeps extendet

var projectileScene = preload("res://Projectile.tscn")
onready var progress = get_node("Body/TextureProgress")
var proj: KinematicBody2D = null
var move_back: bool = true

onready var projOrigin = get_node("Body/Woble_Body/Projectile_Origin")
onready var reachTowards = projOrigin.global_position
onready var fist = $"Body/Skeleton2D/Upper_Arm/Lower_Arm/Fist"

var distance: float = 0
var proj_valid: bool = false

func _process(delta: float) -> void:
	if progress.value > 0:
		progress.value -= delta * 100 / cooldown
	else:
		var pre = "b_" if isPlayerB else "a_"
		var post = ""
		match index:
			0: post= "_0"
			1: post="_1"
			2: post="_2"
			3: post="_3"
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
	proj.direction = Vector2.RIGHT.rotated(projOrigin.rotation)
	get_tree().root.add_child(proj)

	# reset fist for distance calc
	$InverseKinematic.reach_toward(proj.global_position)

extends Node2D
class_name Part

export var cooldown = 1.5

var projectileScene = preload("res://Projectile.tscn")
onready var progress = get_node("Body/TextureProgress")
var proj: KinematicBody2D = null

onready var projOrigin = get_node("Body/Woble_Body/Projectile_Origin")
onready var reachTowards = projOrigin.global_position
onready var fist = $"Body/Skeleton2D/Upper_Arm/Lower_Arm/Fist"

func _ready() -> void:
	shoot()

var distance: float = 0
var proj_valid: bool = false

func _process(delta: float) -> void:
	if progress.value > 0:
		progress.value -= delta * 100 / cooldown
	else:
		if Input.is_action_just_pressed("hit"):
			shoot()

	if is_instance_valid(proj) and not proj.is_queued_for_deletion():
		reachTowards = proj.global_position
		# fist is extended
		if fist.global_position.distance_squared_to(proj.global_position) > 200:
			proj.queue_free()
			proj = null
	else:
		reachTowards = reachTowards.move_toward(projOrigin.global_position, delta * 400)

	$InverseKinematic.reach_toward(reachTowards)

func shoot() -> void:
	progress.value = 100
	proj = projectileScene.instance()
	proj.global_position =  projOrigin.global_position
	proj.speed = 800
	proj.origin = $Body
	proj.direction = Vector2.RIGHT.rotated(projOrigin.rotation)
	get_tree().root.add_child(proj)

	# reset fist for distance calc
	$InverseKinematic.reach_toward(proj.global_position)
	#fist.global_position = proj.global_position

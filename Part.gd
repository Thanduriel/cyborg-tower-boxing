extends Node2D
class_name Part

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var projectileScene = preload("res://Projectile.tscn")

# Called when the node enters the scene tree for the first time.
var proj = null
var ready: bool = true
var offset: Vector2 = Vector2.RIGHT * 120
func shoot() -> void:
	ready = false
	proj = projectileScene.instance()
	proj.global_position =  $"Body".global_position + offset.rotated($"Body".global_rotation)
	proj.speed = 500
	proj.parent = $"Body"
	proj.direction = offset.normalized()
	get_tree().root.add_child(proj)
	
func _ready() -> void:
	shoot()
	
	# var tracker = RemoteTransform2D.new()
	# proj.add_child(tracker)
	# tracker.update_position = true
	# tracker.remote_path = $"Body/Skeleton2D/Bone2D/Bone2D/Bone2D".get_path()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
var distance: float = 0
var proj_valid: bool = false

func _process(_delta: float) -> void:
	if ready and Input.is_action_just_pressed("hit"):
		shoot()
	if proj and is_instance_valid(proj) and not proj.is_queued_for_deletion(): 
		proj_valid = true
		$"Body/InverseKinematic".reach_toward(proj.global_position)
		if (proj.global_position - $"Body/Skeleton2D/Bone2D/Bone2D/Bone2D".global_position).length_squared() > 20:
			proj.queue_free()
	if proj and is_instance_valid(proj) and (proj.is_queued_for_deletion() or proj_valid):
		proj_valid = false
		$"Tween".remove_all()
		distance = ($"Body/Skeleton2D/Bone2D/Bone2D/Bone2D".global_position - $"Body".global_position).length()
		$"Tween".interpolate_property(self, "distance", distance, 100, 0.5)
		$"Tween".start()

func stack(base: NodePath) -> void:
	$"Spring left".node_a = base
	$"Spring right".node_a = base
	$"PinJoint2D".node_a = base
	
func _on_Tween_completed(object, key):
	pass # Replace with function body.



func _on_Tween_tween_step(object, key, elapsed, value):
	$"Body/InverseKinematic".reach_toward($"Body".global_position + offset.normalized().rotated($"Body".global_rotation) * value)


func _on_Tween_tween_completed(object, key):
	ready = true

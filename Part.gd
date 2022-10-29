extends Node2D
class_name Part

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var projectileScene = preload("res://Projectile.tscn")

# Called when the node enters the scene tree for the first time.
var proj = null
func _ready() -> void:
	proj = projectileScene.instance()
	proj.global_position = global_position + Vector2.RIGHT * 64
	proj.speed = 70
	get_tree().root.add_child(proj)
	# var tracker = RemoteTransform2D.new()
	# proj.add_child(tracker)
	# tracker.update_position = true
	# tracker.remote_path = $"Body/Skeleton2D/Bone2D/Bone2D/Bone2D".get_path()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
func _process(_delta: float) -> void:
	if proj and is_instance_valid(proj) and not proj.is_queued_for_deletion(): 
		$"Body/InverseKinematic".reach_toward(proj.global_position)
		# print(proj.global_position, $Body/Skeleton2D/Bone2D/Bone2D/Position2D.global_position)

func stack(base: NodePath) -> void:
	$"Spring left".node_a = base
	$"Spring right".node_a = base
	$"PinJoint2D".node_a = base

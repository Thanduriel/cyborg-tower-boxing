extends Node2D
class_name Joiner

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func unlink() -> void:
	print(get_node($"Spring left".node_a ).get_child(0).get_name())
func stack(node_a: NodePath, node_b: NodePath) -> void:
	$"Spring left".node_a = node_a
	$"Spring right".node_a = node_a
	$"PinJoint2D".node_a = node_a

	$"Spring left".node_b = node_b
	$"Spring right".node_b = node_b
	$"PinJoint2D".node_b = node_b

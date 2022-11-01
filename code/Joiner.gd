extends Node
class_name Joiner

func stack(node_a: NodePath, node_b: NodePath) -> void:
	for child in get_children():
		child = child as Joint2D
		if child:
			child.node_a = node_a
			child.node_b = node_b

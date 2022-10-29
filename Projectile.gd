extends KinematicBody2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

export var speed = 10
var direction = Vector2.RIGHT
export var impluse = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _physics_process(delta: float) -> void:
	move_and_collide(direction * speed * delta)


func _on_Area2D_body_entered(body: Node) -> void:
	if body is RigidBody2D:
		body.apply_central_impulse(direction * impluse)
		queue_free()

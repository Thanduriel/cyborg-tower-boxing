extends KinematicBody2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

export var speed = 10
var direction = Vector2.RIGHT
export var impluse = 100
var origin: RigidBody2D = null
export var impulse_on_hit: float = 100
var bound: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#global_rotation = origin.global_rotation

	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _physics_process(delta: float) -> void:
	var _c = move_and_collide(direction * speed * delta)
	speed += 10000 * delta


func _on_Area2D_body_entered(body: Node) -> void:
	if body is RigidBody2D:
		body.apply_central_impulse(direction * impluse)
		origin.apply_central_impulse(-direction * impulse_on_hit)
		queue_free()
	elif body is CollisionObject2D:
		if body != self:
			origin.apply_central_impulse(-direction * impulse_on_hit)
			queue_free()

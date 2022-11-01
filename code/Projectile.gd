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
export var accel: float = 10000
var parent: Node2D = null
var isPlayerB: bool = false
var dmg: float = 0.25

func _physics_process(delta: float) -> void:
	var _c = move_and_collide(direction * speed * delta)
	speed += accel * delta

var isPart = RegEx.new()
var isLegs = RegEx.new()
func _on_Area2D_body_entered(body: Node) -> void:
	isPart.compile("@Part@[0-9]")
	isLegs.compile("Legs .")
	if body is RigidBody2D:
		var n = body.get_parent().get_name()
		print(name)
		if body.get_name() == "Head":
			body.hit(dmg)
			print("hit Head")
		elif isLegs.search(n):
			print("hit Legs")
		elif isPart.search(n):
			body.get_parent().hit(dmg)
			print("hit part")
		body.apply_central_impulse(direction * impluse)
		origin.apply_central_impulse(-direction * impulse_on_hit)
		queue_free()
	elif body is CollisionObject2D:
		if body != self:
			origin.apply_central_impulse(-direction * impulse_on_hit)
			queue_free()

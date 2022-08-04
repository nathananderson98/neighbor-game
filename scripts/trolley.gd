extends KinematicBody2D

class_name Trolley

export var TIME = 60
onready var trolley_closed_shape = $TrolleyClosedShape
export var MAX_VELOCITY = .3

var velocity := Vector2.ZERO
var has_roger := false

func _ready() -> void:
	trolley_closed_shape.set_deferred("disabled", true)
	
func _physics_process(delta: float) -> void:
	velocity.x = move_toward(velocity.x, MAX_VELOCITY, delta if not has_roger else delta * 10)
	var collision := move_and_collide(velocity)
	if collision:
		var collider = collision.get_collider()
		if collider.get_class() == "KinematicBody2D":
			if has_roger:
				MAX_VELOCITY = 10
			collider.move_and_collide(velocity * 3)

				


func _on_TrolleySeatArea_body_entered(body: Node) -> void:
	if body is Player:
		has_roger = true
		print('closing trolley')
		trolley_closed_shape.set_deferred("disabled", false)


extends KinematicBody2D

class_name Trolley

signal rogers_left_trolley()
signal rogers_entered_trolley()
signal left_wih_rogers(has_rogers)

onready var trolley_closed_shape = $TrolleyClosedShape
export var MAX_VELOCITY = 8

var velocity := Vector2.ZERO
var state = State.STOPPED
var has_roger := false
var destination := Vector2.ZERO
var house_position : Vector2
var arrival_time: int
var en_route_length: float

enum State {
	MOVE_TO_START,
	STOPPED,
	EN_ROUTE,
	LEAVING
}

func set_trolley_open(trolley_open: bool) -> void:
	trolley_closed_shape.set_deferred("disabled", trolley_open)

func move_to_start(start_pos: Vector2) -> void:
	state = State.MOVE_TO_START
	destination = start_pos
	velocity = Vector2(MAX_VELOCITY, 0)
	set_trolley_open(false)

func move_to_end(end_pos: Vector2, seconds_to_exit) -> void:
	state = State.EN_ROUTE
	destination = end_pos
	velocity = Vector2.ZERO
	arrival_time = seconds_to_exit
	set_trolley_open(false)
	en_route_length = destination.x - global_position.x

func move_to_leave() -> void:
	if state != State.LEAVING:
		set_trolley_open(false)
		emit_signal("left_wih_rogers", has_roger)
		state = State.LEAVING
	
func _physics_process(delta: float) -> void:
	match state:
		State.MOVE_TO_START:
			_decelerate_to_start(delta)
		State.STOPPED:
			_stop(delta)
		State.EN_ROUTE:
			_en_route(delta)
		State.LEAVING:
			_leaving(delta)
	# For the player indicator to show where the trolley is, update 'house_position' to current position
	house_position = global_position

func _decelerate_to_start(delta: float) -> void:
	var length_to_start := destination.x - global_position.x - 100
	velocity.x = min(move_toward(velocity.x, length_to_start, delta * 10), MAX_VELOCITY)
	var collision := move_and_collide(velocity)
	if collision:
		var collider = collision.get_collider()
		if collider.get_class() == "KinematicBody2D":
			collider.move_and_collide(velocity * 2)
	if global_position.x >= destination.x:
		set_trolley_open(true)
		state = State.STOPPED

	
func _stop(delta: float) -> void:
	pass
	
func _en_route(delta: float) -> void:
	velocity.x = en_route_length / arrival_time * delta
	var collision := move_and_collide(velocity)
	if collision:
		var collider = collision.get_collider()
		if collider.get_class() == "KinematicBody2D":
			if has_roger:
				return
			collider.move_and_collide(velocity * 3)
	if global_position.x >= destination.x:
		set_trolley_open(false)
		state = State.LEAVING


func _leaving(delta: float) -> void:
	velocity.x = min(move_toward(velocity.x, (destination.x + 200), delta * 10), MAX_VELOCITY)
	var collision := move_and_collide(velocity)
	if collision:
		var collider = collision.get_collider()
		if collider.get_class() == "KinematicBody2D":
			collider.move_and_collide(velocity * 3)
#	if global_position.x >= destination.x:
#		set_trolley_open(true)
#		state = State.STOPPED


func _on_TrolleySeatArea_body_entered(body: Node) -> void:
	if body is Player and state != State.STOPPED and state != State.MOVE_TO_START:
		has_roger = true
		trolley_closed_shape.set_deferred("disabled", false)
		emit_signal("rogers_entered_trolley")


func _on_TrolleySurroundingArea_body_exited(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body is Player:
		has_roger = false
		emit_signal("rogers_left_trolley")


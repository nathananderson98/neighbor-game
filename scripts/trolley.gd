extends KinematicBody2D

class_name Trolley

signal rogers_left_trolley()
signal rogers_entered_trolley()
signal left_wih_rogers(has_rogers)

onready var trolley_closed_shape = $TrolleyClosedShape
onready var timer := $Timer
onready var player := $AudioStreamPlayer2D
onready var smoke := $SmokeParticles

export var MAX_VELOCITY = 8
export var MAX_PITCH_SOUND := 1.25

var velocity := Vector2.ZERO
var state = State.STOPPED
var has_roger := false
var destination := Vector2.ZERO
var house_position : Vector2
var arrival_time: int
var en_route_length: float
var roger: Player
var audio_enabled := false

enum State {
	MOVE_TO_START,
	STOPPED,
	EN_ROUTE,
	LEAVING
}

func set_trolley_open(trolley_open: bool) -> void:
	trolley_closed_shape.set_deferred("disabled", trolley_open)

func move_to_start(start_pos: Vector2) -> void:
#	smoke.set_param(CPUParticles2D.PARAM_INITIAL_LINEAR_VELOCITY, 160.0)
	state = State.MOVE_TO_START
	destination = start_pos
	velocity = Vector2(MAX_VELOCITY, 0)
	set_trolley_open(false)

func move_to_end(end_pos: Vector2, seconds_to_exit) -> void:
	smoke.set_param(CPUParticles2D.PARAM_INITIAL_LINEAR_VELOCITY, 100.0)
	state = State.EN_ROUTE
	destination = end_pos
	velocity = Vector2.ZERO
	arrival_time = seconds_to_exit
	set_trolley_open(false)
	en_route_length = destination.x - global_position.x

func move_to_leave() -> void:
	if state != State.LEAVING:
		smoke.set_param(CPUParticles2D.PARAM_INITIAL_LINEAR_VELOCITY, 160.0)
		set_trolley_open(false)
		state = State.LEAVING
		timer.start(2)

#func set_roger_body(body: Player) -> void:
#	roger = body

func _physics_process(delta: float) -> void:
	if not player.playing and audio_enabled:
		player.play()
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
	if smoke.get_param(CPUParticles2D.PARAM_INITIAL_LINEAR_VELOCITY) > 25:
		smoke.set_param(CPUParticles2D.PARAM_INITIAL_LINEAR_VELOCITY, 25.0)
	
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
		set_trolley_open(true)
		state = State.STOPPED


func _leaving(delta: float) -> void:
	var new_speed = move_toward(player.get_pitch_scale(), MAX_PITCH_SOUND, delta / 2)
	player.set_pitch_scale(new_speed)
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

func _on_Timer_timeout() -> void:
	timer.stop()
	emit_signal("left_wih_rogers", has_roger)

func _set_audio(enabled: bool) -> void:
	audio_enabled = enabled

func _set_paused(paused: bool) -> void:
	set_physics_process(!paused)
	set_process(!paused)
	smoke.set_speed_scale(0 if paused else 1)
	timer.paused = paused

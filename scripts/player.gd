extends KinematicBody2D

class_name Player

export var MAX_SPEED := 300
export var ACCELERATION := 1000
export var FRICTION := 2000

var player_velocity = Vector2.ZERO
var state = State.IDLE
var follower : KinematicBody2D
var leader := self

onready var sprite := $AnimatedSprite
onready var chevron_sprite := $ChevronSprite
onready var camera := $Camera2D
onready var gui := $GUI

enum State {
	MOVE,
	IDLE,
}

func set_camera_bounds(up: int, down: int, left: int, right: int):
	camera.set_limit(MARGIN_TOP, up)
	camera.set_limit(MARGIN_BOTTOM, down)
	camera.set_limit(MARGIN_LEFT, left)
	camera.set_limit(MARGIN_RIGHT, right)

func _process(delta: float) -> void:
	gui.global_position = camera.get_camera_screen_center() - Vector2(get_viewport().get_visible_rect().size.x / 2, get_viewport().get_visible_rect().size.y / 2) # Get Height)
	
func _physics_process(delta: float) -> void:
	match state:
		State.MOVE:
			_move_state(delta)
		State.IDLE:
			_idle_state(delta)
	chevron_sprite.visible = follower != null
	if follower != null:
		if follower.name == "Trolley":
			chevron_sprite.set_modulate(Color(0,0.9,0))
		chevron_sprite.rotation_degrees = rad2deg((follower.house_position - global_position).angle()) - 90

func _move_state(delta: float) -> void:
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector.normalized()
	
	if input_vector.x < 0 and not sprite.flip_h:
		sprite.flip_h = true
	elif input_vector.x > 0 and sprite.flip_h:
		sprite.flip_h = false
		
	
	if input_vector != Vector2.ZERO:
		player_velocity = player_velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		player_velocity = player_velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	player_velocity = move_and_slide(player_velocity, Vector2( 0, 0 ), false, 4, 0.785398, false)
	for i in get_slide_count():
		var collision := get_slide_collision(i)
		if "Trolley" in collision.collider.name or "Car" in collision.collider.name:
			state = State.IDLE
	if player_velocity == Vector2.ZERO:
		state = State.IDLE

func _idle_state(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		sprite.set_animation("run")
		state = State.MOVE
	else:
		sprite.set_animation("idle")

func _set_paused(paused: bool) -> void:
	set_physics_process(!paused)
	set_process(!paused)

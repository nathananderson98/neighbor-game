extends KinematicBody2D

class_name Player

export var MAX_SPEED := 300
export var ACCELERATION := 1000
export var FRICTION := 2000

var player_velocity = Vector2.ZERO
var state = State.IDLE
var follower : KinematicBody2D

onready var sprite := $AnimatedSprite

enum State {
	MOVE,
	IDLE
}


func _physics_process(delta: float) -> void:
	match state:
		State.MOVE:
			move_state(delta)
		State.IDLE:
			idle_state(delta)
	
func move_state(delta: float) -> void:
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
	
	player_velocity = move_and_slide(player_velocity)
	
	if player_velocity == Vector2.ZERO:
		state = State.IDLE

func idle_state(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		sprite.set_animation("run")
		state = State.MOVE
	else:
		sprite.set_animation("idle")
#	if Input.is_action_pressed("ui_up"):
#		speed.y -= ACCELERATION
#	elif Input.is_action_pressed("ui_right"):
#		print("right")
#	elif Input.is_action_pressed("ui_left"):
#		print("left")
#	elif Input.is_action_pressed("ui_down"):
#		print("down")

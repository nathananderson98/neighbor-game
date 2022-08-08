extends KinematicBody2D

class_name Car

enum CarState {
	READY,
	MOVING,
	DONE
}

onready var car_sprite := $CarSprite

var state : int
var car_speed: int
var start_point: Vector2
var destination: Vector2
var velocity := Vector2.ZERO
var is_moving_to_left : bool
var rng := RandomNumberGenerator.new()
var collision_speed : Vector2

func start_engine(start: Vector2, end: Vector2, speed: int) -> void:
	rng.randomize()
	var rnd_num = rng.randi_range(1, 3)
	start_point = start
	destination = end
	car_speed = speed
	is_moving_to_left = destination.x < start_point.x
	global_position = start_point
	state = CarState.MOVING
	car_sprite.texture = load("res://assets/car%s.png" % rnd_num)
	collision_speed = Vector2(car_speed * 3, -10)
	if not is_moving_to_left:
		car_sprite.flip_h = true

func _ready() -> void:
	state = CarState.READY

func _physics_process(delta: float) -> void:
	match state:
		CarState.READY:
			_wait(delta)
		CarState.MOVING:
			_move(delta)
		CarState.DONE:
			_clean_up(delta)

func _wait(delta: float) -> void:
	pass
	
func _move(delta: float) -> void:
	velocity.x = car_speed if not is_moving_to_left else -car_speed
	var collision := move_and_collide(velocity)
	if collision:
		var collider = collision.get_collider()
		if collider.get_class() == "KinematicBody2D":
			collider.move_and_collide(collision_speed)
	if is_moving_to_left and global_position.x < destination.x or not is_moving_to_left and global_position.x > destination.x:
		state = CarState.DONE


func _clean_up(delta: float) -> void:
	print('Deleting my car self')
	queue_free()

func _set_paused(paused: bool) -> void:
	set_physics_process(!paused)
	set_process(!paused)

extends Node2D

onready var spawn_timer := $SpawnTimer
onready var car_end_point := $CarEndPoint

export var SPAWN_FREQUENCY := 10
export var SPAWN_VARIANCE := 5
export var CAR_SPEED := 12
export var CAR_SPEED_VARIANCE := 6

var car_scene = preload("res://scenes/car.tscn")
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	var spawn_time := rng.randf_range((SPAWN_FREQUENCY - SPAWN_VARIANCE / 2), (SPAWN_FREQUENCY + SPAWN_VARIANCE / 2))
	print('Waiting %s for car' % stepify(spawn_time, 0.1))
	spawn_timer.start(spawn_time)

func _on_SpawnTimer_timeout() -> void:
	var new_car_instance = car_scene.instance() as Car
	get_parent().add_child(new_car_instance)
	var rng_speed := rng.randf_range((CAR_SPEED - CAR_SPEED_VARIANCE / 2), (CAR_SPEED + CAR_SPEED_VARIANCE / 2))
	print('Starting engine at %s' % stepify(rng_speed, 0.1))
	new_car_instance.start_engine(global_position, car_end_point.global_position, rng_speed)
	var spawn_time := rng.randf_range((SPAWN_FREQUENCY - SPAWN_VARIANCE / 2), (SPAWN_FREQUENCY + SPAWN_VARIANCE / 2))
	print('Waiting %s for car' % stepify(spawn_time, 0.1))
	spawn_timer.start(spawn_time)

func _set_paused(paused: bool) -> void:
	set_physics_process(!paused)
	set_process(!paused)
	spawn_timer.paused = paused

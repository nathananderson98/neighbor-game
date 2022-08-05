extends KinematicBody2D

class_name Neighbor

signal found_home(id)

onready var roger_area := $RogerArea2D
onready var sprite := $AnimatedSprite
onready var wander_timer := $WanderTimer
onready var chevron_sprite := $ChevronSprite

export var MAX_SPEED := 225
export var ACCELERATION := 1000
export var FRICTION := 2000

var state = State.IDLE
var neighbor_velocity := Vector2.ZERO
var leader: KinematicBody2D
var follower: KinematicBody2D
var rng := RandomNumberGenerator.new()
var wander_direction := Vector2.ZERO
var matching_house_node : Node2D
var house_position := Vector2.ZERO
var house_direction := Vector2.ZERO
var id : int

var pop_effect_scene = preload("res://scenes/pop.tscn")

enum State {
	MOVE,
	WANDER,
	IDLE,
	GO_HOME,
	FOUND_HOME
}

func reset_leads() -> void:
	if follower != null:
		follower.reset_leads()
	leader = null
	follower = null

func _ready() -> void:
	id = int(self.name[-1])
	rng.set_seed(id)
	matching_house_node = get_parent().get_node("House%s" % id)
	matching_house_node.connect("come_home", self, "_on_house_come_home")

func _physics_process(delta: float) -> void:
	house_position = matching_house_node.global_position
	house_direction = (house_position - global_position).normalized()
	match state:
		State.MOVE:
			_move_state(delta)
		State.WANDER:
			_wander_state(delta)
		State.IDLE:
			_idle_state(delta)
		State.GO_HOME:
			_go_home_state(delta)

func _move_state(delta: float) -> void:
	if leader == null:
		state = State.IDLE
		return
	var result_vector := leader.global_position - global_position
	if result_vector.length() > 100:
		_move_neighbor(result_vector)
	else:
		state = State.IDLE
	if result_vector.length() > 250:
		leader.follower = null
		leader = null
		if follower != null:
			follower.reset_leads()
			follower = null
		state = State.IDLE

func _wander_state(delta: float) -> void:
	if leader != null:
		state = State.MOVE
		return
	_move_neighbor(wander_direction, true)

func _idle_state(delta: float) -> void:
	if wander_timer.is_stopped():
		wander_timer.start(rng.randf_range(1.8, 6.5))
	sprite.play("idle")
	for body in roger_area.get_overlapping_bodies():
		if body.is_class("KinematicBody2D") and not body is Trolley and leader == null and body.follower == null and body.leader != null:
			leader = body
			leader.follower = self
	if leader != null:
		state = State.MOVE

func _go_home_state(delta: float) -> void:
	_move_neighbor(house_direction, true)
	if ((house_position - global_position).length() < 30):
		emit_signal("found_home", id)
		queue_free()

func _move_neighbor(direction_vector: Vector2, is_walk: bool = false) -> void:
		sprite.play("run") if not is_walk else sprite.play("walk")
		var move_vector := Vector2(direction_vector).normalized()
		if move_vector.x < 0 and not sprite.flip_h:
			sprite.flip_h = true
		elif move_vector.x > 0 and sprite.flip_h:
			sprite.flip_h = false
		if move_vector != Vector2.ZERO:
			var velocity := move_vector * MAX_SPEED if not is_walk else move_vector * MAX_SPEED / 3
			neighbor_velocity = neighbor_velocity.move_toward(velocity, ACCELERATION * get_physics_process_delta_time())
		else:
			neighbor_velocity = neighbor_velocity.move_toward(Vector2.ZERO, FRICTION * get_physics_process_delta_time())
		
		neighbor_velocity = move_and_slide(neighbor_velocity)

func _on_RogerArea2D_body_entered(body: Node) -> void:
	if body != self and leader == null:
		if body is Player and body.follower == null:
			body.follower = self
			leader = body
		elif body.is_class("KinematicBody2D") and not body is Trolley and body.follower == null:
			if body.leader != null:
				leader = body
				leader.follower = self

func _on_WanderTimer_timeout() -> void:
	if state == State.IDLE:
		var rand_x = rng.randf_range(-1.0, 1.0)
		var rand_y = rng.randf_range(-1.0, 1.0)
		var wander_time = rng.randf_range(0.3, 1.2)
		state = State.WANDER
		wander_direction = Vector2(rand_x, rand_y)
		wander_timer.start(wander_time)
	elif state == State.WANDER:
		var wait_time = rng.randf_range(1.8, 6.5)
		state = State.IDLE
		wander_timer.start(wait_time)
	elif state == State.FOUND_HOME:
		state = State.GO_HOME
		

func _on_house_come_home() -> void:
	sprite.play("idle")
	wander_timer.start(0.5)
	var instance = pop_effect_scene.instance()
	get_parent().add_child(instance)
	instance.global_position = Vector2(global_position.x, global_position.y - 50)
	if follower == null:
		leader.follower = null
	else:
		leader.follower = follower
		follower.leader = leader
	state = State.FOUND_HOME

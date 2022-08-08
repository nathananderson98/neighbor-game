extends KinematicBody2D

class_name Neighbor

signal found_home(id)

var NeighborSprite = {
	0:"aberlin",
	1:"chad",
	2:"gary",
	3:"maggie",
	4:"sarah",
	5:"steve",
	6:"tim",
	7:"tyler"
}

onready var roger_area := $RogerArea2D
onready var sprite := $AnimatedSprite
onready var wander_timer := $WanderTimer
onready var chevron_sprite := $ChevronSprite
onready var line_path := $LinePath
onready var path_dist_label := $PathDistanceLabel
onready var circle_sprite := $CircleSprite

export var MAX_SPEED := 225
export var ACCELERATION := 1000
export var FRICTION := 2000
export var MAX_FOLLOW_DISTANCE := 250
export var MIN_FOLLOW_DISTANCE := 80
export var DIST_PERCENT_AWAY_SHOW_CUTOFF := 0.65

var neighbor_sprite : int
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
var path: Array = []
var path_length: float
var calc_path := true
var level_navigation: Navigation2D setget set_level_navigation

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
	
func set_level_navigation(node: Navigation2D) -> void:
	level_navigation = node

func _ready() -> void:
	path_dist_label.text = ''
	id = int(self.name[-1])
	rng.set_seed(id)
	matching_house_node = get_parent().get_node("House%s" % id)
	matching_house_node.connect("come_home", self, "_on_house_come_home")
	circle_sprite.scale = Vector2((MAX_FOLLOW_DISTANCE / 16), (MAX_FOLLOW_DISTANCE / 16))
	circle_sprite.set_modulate(Color(0,0,0,0))
	_setup_animated_sprite()

func _physics_process(delta: float) -> void:
#	if OS.is_debug_build():
#		line_path.global_position = Vector2.ZERO
#		chevron_sprite.visible = leader != null
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
	else:
		if (leader.global_position - global_position).length() <= 40.0:
#			if OS.is_debug_build():
#				chevron_sprite.rotation_degrees = rad2deg((global_position - leader.global_position).angle()) - 90
			_move_neighbor(global_position - leader.global_position)
			return
	if calc_path:
		path = level_navigation.get_simple_path(global_position, leader.global_position)
		calc_path = false
		path_length = _calc_points_length(path)
#		if OS.is_debug_build():
#			line_path.points = path
#			path_dist_label.text = "%s" % path_length
	else:
		calc_path = true
	var result_vector = path[1] - path[0] if len(path) >= 2 else leader.global_position - global_position
#	if OS.is_debug_build():
#		chevron_sprite.rotation_degrees = rad2deg((result_vector).angle()) - 90
	if path_length > MIN_FOLLOW_DISTANCE:
		_move_neighbor(result_vector)
	else:
		state = State.IDLE
	_set_circle_indicator(result_vector.length())
	if result_vector.length() > MAX_FOLLOW_DISTANCE or path_length > MAX_FOLLOW_DISTANCE * 1.75:
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
	if leader == null and len(line_path.points) != 0:
		line_path.points = []
	circle_sprite.set_modulate(Color(0,0,0,0))
	if wander_timer.is_stopped() and leader == null:
		wander_timer.start(rng.randf_range(1.8, 6.5))
	sprite.play("idle")
	# Connect to roger or neighbor following roger
	for body in roger_area.get_overlapping_bodies():
		if body.is_class("KinematicBody2D") and not body is Trolley and not body is Car and leader == null and body.follower == null and body.leader != null:
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
		
		neighbor_velocity = move_and_slide(neighbor_velocity, Vector2( 0, 0 ), false, 4, 0.785398, false)
		for i in get_slide_count():
			var collision := get_slide_collision(i)
			if "Trolley" in collision.collider.name or "Car" in collision.collider.name:
				state = State.IDLE

func _on_RogerArea2D_body_entered(body: Node) -> void:
	if body != self and leader == null:
		if body is Player and body.follower == null:
			body.follower = self
			leader = body
		elif body.is_class("KinematicBody2D") and not body is Trolley and not body is Car and body.follower == null:
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

func _set_circle_indicator(length: float) -> void:
	# begin to show circle when neighbor is approaching max
	if length / MAX_FOLLOW_DISTANCE >= DIST_PERCENT_AWAY_SHOW_CUTOFF:
		# returns a value between 0 and 1 based on the cutoff value
		var percent_visible = ((length / MAX_FOLLOW_DISTANCE) - DIST_PERCENT_AWAY_SHOW_CUTOFF) / (1 - DIST_PERCENT_AWAY_SHOW_CUTOFF)
		circle_sprite.set_modulate(Color(percent_visible, percent_visible / 2, percent_visible / 2, percent_visible))
	else:
		circle_sprite.set_modulate(Color(0,0,0,0))

func _setup_animated_sprite() -> void:
	var name = NeighborSprite[id % 8]
	var sprite_frames := SpriteFrames.new()
	# add animations
	sprite_frames.add_animation("idle")
	sprite_frames.add_animation("run")
	sprite_frames.add_animation("walk")
	# idle
	sprite_frames.add_frame("idle", load("res://assets/%s.png" % name))
	# walk
	sprite_frames.add_frame("walk", load("res://assets/runningSprites/%s/%s1.png" % [name, name.capitalize()]))
	sprite_frames.add_frame("walk", load("res://assets/runningSprites/%s/%s2.png" % [name, name.capitalize()]))
	sprite_frames.add_frame("walk", load("res://assets/%s.png" % name))
	# run
	for i in range(8):
		sprite_frames.add_frame("run", load("res://assets/runningSprites/%s/%s%s.png" % [name, name.capitalize(), i]))
	sprite_frames.set_animation_speed("run", 8.0)
	sprite.frames = sprite_frames
	
func _calc_points_length(points: PoolVector2Array) -> float:
	var sum_vector := Vector2.ZERO
	if len(points) == 0:
		return (MAX_FOLLOW_DISTANCE + 1) as float
	var current_point = points[0]
	points.remove(0)
	for point in points:
		sum_vector += point - current_point
	return sum_vector.length()
		
func _set_paused(paused: bool) -> void:
	set_physics_process(!paused)
	set_process(!paused)
	wander_timer.paused = paused

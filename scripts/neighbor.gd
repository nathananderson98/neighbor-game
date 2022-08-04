extends KinematicBody2D

class_name Neighbor

signal neighbor_following_roger

onready var roger_area := $RogerArea2D
onready var sprite := $AnimatedSprite
onready var wander_timer := $WanderTimer

export var MAX_SPEED := 225
export var ACCELERATION := 1000
export var FRICTION := 2000

var state = State.IDLE
var neighbor_velocity := Vector2.ZERO
var leader: KinematicBody2D
var follower: KinematicBody2D
var rng := RandomNumberGenerator.new()
var is_wandering := false
var wander_direction := Vector2.ZERO

enum State {
	MOVE,
	WANDER,
	IDLE
}

func reset_leads() -> void:
	if follower != null:
		follower.reset_leads()
	leader = null
	follower = null

func _ready() -> void:
	sprite.set_modulate(Color(.5,0,0))

func _physics_process(delta: float) -> void:
	match state:
		State.MOVE:
			move_state(delta)
		State.WANDER:
			wander_state(delta)
		State.IDLE:
			idle_state(delta)

func move_state(delta: float) -> void:
#	var player := get_parent().get_node("Player") as Player
#	leader.follower = self
	if leader == null:
		state = State.IDLE
		return
	var result_vector := leader.global_position - global_position
	if result_vector.length() > 100:
		move_neighbor(result_vector)
	else:
		state = State.IDLE
	if result_vector.length() > 250:
		leader.follower = null
		leader = null
		if follower != null:
			follower.reset_leads()
			follower = null
		state = State.IDLE

func wander_state(delta: float) -> void:
	if leader != null:
		state = State.MOVE
		return
	move_neighbor(wander_direction, true)
	

func move_neighbor(direction_vector: Vector2, is_wander: bool = false) -> void:
		sprite.play("run") if not is_wander else sprite.play("walk")
		var move_vector := Vector2(direction_vector).normalized()
		if move_vector.x < 0 and not sprite.flip_h:
			sprite.flip_h = true
		elif move_vector.x > 0 and sprite.flip_h:
			sprite.flip_h = false
		if move_vector != Vector2.ZERO:
			var velocity := move_vector * MAX_SPEED if not is_wander else move_vector * MAX_SPEED / 3
			neighbor_velocity = neighbor_velocity.move_toward(velocity, ACCELERATION * get_physics_process_delta_time())
		else:
			neighbor_velocity = neighbor_velocity.move_toward(Vector2.ZERO, FRICTION * get_physics_process_delta_time())
		
		neighbor_velocity = move_and_slide(neighbor_velocity)


func idle_state(delta: float) -> void:
	if wander_timer.is_stopped():
		wander_timer.start(rng.randf_range(0, 1.5))
	sprite.play("idle")
	for body in roger_area.get_overlapping_bodies():
		if body.is_class("KinematicBody2D") and not body is Trolley and leader == null and body.follower == null and body.leader != null:
			leader = body
			leader.follower = self
	if leader != null:
		state = State.MOVE

func _on_RogerArea2D_body_entered(body: Node) -> void:
	if body != self and leader == null:
		if body is Player and body.follower == null:
			body.follower = self
			leader = body
		elif body.is_class("KinematicBody2D") and not body is Trolley and body.follower == null:
			print('Got neighbor body')
			if body.leader != null:
				print('Following the leader')
				leader = body
				leader.follower = self


func _on_WanderTimer_timeout() -> void:
	if state == State.IDLE:
		print('wander timer done')
		var rand_x = rng.randf_range(-1.0, 1.0)
		var rand_y = rng.randf_range(-1.0, 1.0)
		var wander_time = rng.randf_range(1.0, 1.5)
		state = State.WANDER
		wander_direction = Vector2(rand_x, rand_y)
		wander_timer.start(wander_time)
	elif state == State.WANDER:
		print('Done wandering')
		var wait_time = rng.randf_range(1.0, 5.5)
		state = State.IDLE
		wander_timer.start(wait_time)
		

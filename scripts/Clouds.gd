extends Node2D

onready var topBorder = $TopBorder
onready var bottomBorder = $BottomBorder
onready var leftBorder = $LeftBorder
onready var rightBorder = $RightBorder

export var NUM_CLOUDS = 12

var clouds = []
var speeds = []
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	for num in range(NUM_CLOUDS):
		var cloud_image_path = "res://assets/cloud%s.png" % (num % 4 + 1)
		var new_cloud_sprite = Sprite.new()
		new_cloud_sprite.texture = load(cloud_image_path)
		add_child(new_cloud_sprite)
		clouds.append(new_cloud_sprite)
		var rand_speed = rng.randf_range(0.5,2)
		speeds.append(rand_speed)
	rng.randomize()
	_start_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var index := 0
	for cloud in clouds:
		if cloud.global_position.x + speeds[index] < rightBorder.global_position.x:
			cloud.global_position.x = cloud.global_position.x + speeds[index]
		else:
			cloud.global_position.x = leftBorder.global_position.x
			cloud.global_position.y = rng.randi_range(topBorder.global_position.y, bottomBorder.global_position.y)
		index += 1

func _start_position():
	rng.randomize()
	for cloud in clouds:
		var y = rng.randi_range(topBorder.global_position.y, bottomBorder.global_position.y)
		var x = rng.randi_range(leftBorder.global_position.x, rightBorder.global_position.x)
		cloud.global_position = Vector2(x, y)

	
	

	

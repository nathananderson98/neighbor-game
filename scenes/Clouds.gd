extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var cloud1 = $Sprite
onready var cloud2 = $Sprite2
onready var cloud3 = $Sprite3
onready var cloud4 = $Sprite4
onready var topBorder = $TopBorder
onready var bottomBorder = $BottomBorder
onready var leftBorder = $LeftBorder
onready var rightBorder = $RightBorder

var clouds = []

var rng = RandomNumberGenerator.new()
var xSpeed = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	xSpeed = rng.randf_range(0.5,2)
	clouds = [cloud1, cloud2, cloud3, cloud4]
	_start_position()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(xSpeed)
	for cloud in clouds:
		if cloud.global_position.x + xSpeed < rightBorder.global_position.x:
			cloud.global_position.x = cloud.global_position.x + xSpeed
		else:
			cloud.global_position.x = leftBorder.global_position.x

func _start_position():
	rng.randomize()
	for cloud in clouds:
		var y = rng.randi_range(topBorder.global_position.y, bottomBorder.global_position.y)
		var x = rng.randi_range(leftBorder.global_position.x, rightBorder.global_position.x)
		cloud.global_position = Vector2(x, y)

	
	

	

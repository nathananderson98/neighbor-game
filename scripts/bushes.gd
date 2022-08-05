extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var bush1 = $Bush1/Sprite
onready var bush2 = $Bush4/Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	bush1.set_modulate(Color(0.75, 0.75, 0.75))
	bush2.set_modulate(Color(0.75, 0.75, 0.75))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

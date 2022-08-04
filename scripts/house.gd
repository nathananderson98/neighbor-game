extends Node2D

onready var sprite = $Sprite

func _ready() -> void:
	sprite.set_modulate(Color(1.0, 0.0, 0.0))

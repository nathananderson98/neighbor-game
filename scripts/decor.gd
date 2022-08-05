extends Node2D

onready var sprite := $Sprite


const SpriteAsset = {bush1 = "bush1", bush2 = "bush2", tree = "tree", lamppost = "lamppost"}
export var SPRITE_ASSET := SpriteAsset.bush1

func _ready() -> void:
	if SPRITE_ASSET in SpriteAsset:
		sprite.texture = load("res://roger-roger/%s.png" % SPRITE_ASSET)
	else:
		print("ERROR - Provided Sprite asset is either not defined or misspelled: %s FIXME %s" % [SPRITE_ASSET, self.name])
		sprite.texture = load("res://roger-roger/%s.png" % SpriteAsset.bush1)
	

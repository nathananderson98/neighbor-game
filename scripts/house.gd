extends Node2D

onready var sprite = $Sprite
onready var door_area = $DoorArea2D

signal come_home

var id : int
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

func _ready() -> void:
	id = int(self.name[-1])
	sprite.texture = load("res://assets/%sHouse.png" % NeighborSprite[id % 8])


func _on_DoorArea2D_body_entered(body: Node) -> void:
	if body is Neighbor:
		if body.id == id:
			emit_signal("come_home")

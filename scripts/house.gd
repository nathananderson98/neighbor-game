extends Node2D

onready var sprite = $Sprite
onready var door_area = $DoorArea2D

signal come_home

var id : int

func _ready() -> void:
	id = int(self.name[-1])



func _on_DoorArea2D_body_entered(body: Node) -> void:
	if body is Neighbor:
		if body.id == id:
			emit_signal("come_home")

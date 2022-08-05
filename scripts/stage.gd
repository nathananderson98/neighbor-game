extends Node2D

var helped_neighbors := []
var total_neighbors := 0

onready var trolley = $YSort/Trolley as Trolley

func _ready() -> void:
	trolley.connect("rogers_left_trolley", self, "_on_rogers_left_trolley")
	for node in get_node("YSort").get_children():
		if 'Neighbor' in node.name:
			var err = node.connect("found_home", self, "_on_neighbor_found_home")
			total_neighbors += 1
			

func _on_rogers_left_trolley() -> void:
	pass

func _on_neighbor_found_home(id: int) -> void:
	print('You helped a neighbor')
	helped_neighbors.append(id)
	if len(helped_neighbors) == total_neighbors:
		trolley.set_trolley_open(true)



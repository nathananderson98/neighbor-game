extends Node2D


var level_path := "res://scenes/level{num}.tscn"
var level1 = preload("res://scenes/level1.tscn")
var current_level_num = 1
var current_level : Node
var max_levels = 3
var level_win := false

onready var end_timer := $EndTimer

func _ready() -> void:
	current_level = level1.instance()
	add_child(current_level)
	var err = current_level.get_child(0).connect("game_complete", self, "_on_level_complete")

func _on_level_complete(is_win: bool) -> void:
	print('Level complete')
	level_win = is_win
	end_timer.start(2)


func _on_EndTimer_timeout() -> void:
	if level_win and current_level_num < max_levels:
		current_level_num += 1
		var new_level_path = level_path.format({"num": current_level_num})
		var next_level = load(new_level_path).instance()
		add_child(next_level)
		current_level.queue_free()
		current_level = next_level
		var current_base_level = current_level.get_node("BaseLevel") as BaseLevel
		current_base_level.display_start(current_level_num)
		var err = current_base_level.connect("game_complete", self, "_on_level_complete")



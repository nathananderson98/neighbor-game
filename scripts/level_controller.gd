extends Node2D

var level_path := "res://scenes/level{num}.tscn"
var level1 = preload("res://scenes/level1.tscn")
var current_level_num = 1
var current_level : Node
var max_levels := 3
var level_win := false

onready var game_timer := $GameTimer
onready var game_screen_text := $GameScreenText

func setup_next_level():
	if current_level_num == 1:
		current_level = level1.instance()
		add_child(current_level)
	else:
		var new_level_path = level_path.format({"num": current_level_num})
		var next_level = load(new_level_path).instance()
		add_child(next_level)
		if current_level != null:
			current_level.queue_free()
		current_level = next_level
	var current_base_level = current_level.get_node("BaseLevel") as BaseLevel
	current_base_level.display_start(current_level_num, current_level_num == max_levels)
	var err = current_base_level.connect("game_complete", self, "_on_level_complete")
	print(err)

func _on_level_complete(is_win: bool) -> void:
	print('Level complete')
	level_win = is_win
	if current_level_num == max_levels:
		game_timer.start(3.5)
	else:
		game_timer.start(2)
	current_level_num += 1

func _on_GameTimer_timeout() -> void:
	print('Timer done')
	if level_win and current_level_num <= max_levels:
		setup_next_level()
	elif not level_win:
		var header := game_screen_text.get_node("ColorRect/VBoxContainer/HeaderText")
		var body := game_screen_text.get_node("ColorRect/VBoxContainer/BodyText")
		header.text = "Seems you got lost in the world of make believe"
		body.text = "I don't blame you, its a beautiful place"
		if current_level != null:
			current_level.queue_free()
	else:
		var header := game_screen_text.get_node("ColorRect/VBoxContainer/HeaderText")
		var body := game_screen_text.get_node("ColorRect/VBoxContainer/BodyText")
		header.text = "Now go out and meet some real neighbors"
		body.text = "'In a way, you’ve already won in this world because you’re the only one who can be you.'\n-Mister Rogers"
		if current_level != null:
			current_level.queue_free()


func _on_GameScreenText_done_reading() -> void:
	setup_next_level()

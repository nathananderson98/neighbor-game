extends Node2D

class_name GUI

signal toggle_music(music_off)
signal toggle_pause(paused)

onready var time_label := $MarginContainer/HBoxContainer/TimeLabel
onready var neighbor_label := $MarginContainer/HBoxContainer/NeighborLabel
onready var game_timer := $GameTimer
onready var music_button := $MarginContainer/HBoxContainer/GridContainer/MusicButton
onready var pause_button := $MarginContainer/HBoxContainer/GridContainer/PauseButton

var arrow = preload("res://assets/ui/pointer.png")
var hand = preload("res://assets/ui/pointer_hand.png")
#var music_enabled_texture = preload("res://assets/ui/music-enabled.png")
#var music_disabled_texture = preload("res://assets/ui/music-disabled.png")
#var pause_texture = preload("res://assets/ui/pause.png")
#var play_texture = preload("res://assets/ui/play.png")

func start_timer(seconds: int) -> void:
	game_timer.start(seconds)

func set_neighbor_count(neighbors_left: int) -> void:
	neighbor_label.text = "Neighbors left: %s" % neighbors_left

func set_game_label(content: String) -> void:
	neighbor_label.text = content

func _ready() -> void:
	Input.set_custom_mouse_cursor(arrow)
#	Input.set_custom_mouse_cursor(beam, Input.CURSOR_IBEAM)
#	start_timer(60)
	
func _process(delta: float) -> void:
	var time = int(game_timer.get_time_left())
	time_label.text = "Time: %s" % time

func _on_PauseButton_toggled(button_pressed: bool) -> void:
	game_timer.set_paused(button_pressed)
	emit_signal("toggle_pause", button_pressed)
	
func _on_MusicButton_toggled(button_pressed: bool) -> void:
	get_tree().call_group("plays_audio", "_set_audio", button_pressed)
	emit_signal("toggle_music", button_pressed)

func _on_mouse_entered() -> void:
	Input.set_custom_mouse_cursor(hand)
	
func _on_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(arrow)


func _on_GameTimer_timeout() -> void:
	pass # Replace with function body.

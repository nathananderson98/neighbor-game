extends Node2D

onready var time_label := $MarginContainer/HBoxContainer/TimeLabel
onready var game_timer := $GameTimer

func start_timer(seconds: int) -> void:
	game_timer.start(seconds)

func _ready() -> void:
	start_timer(60)
	
func _process(delta: float) -> void:
	var time = int(game_timer.get_time_left())
	time_label.text = "Time %s" % time


func _on_ToolButton_toggled(button_pressed: bool) -> void:
	print(button_pressed)

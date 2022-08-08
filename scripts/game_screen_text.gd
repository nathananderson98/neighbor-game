extends Control

export var HEADER_TIME := 3.0
export var BODY_TIME := 8.0

signal done_reading()

onready var header_text := $ColorRect/VBoxContainer/HeaderText
onready var body_text := $ColorRect/VBoxContainer/BodyText
onready var text_timer := $TextTimer

var text_to_readout := 0

func _ready() -> void:
	# This throws an error in the base level idk why
#	if OS.is_debug_build():
#		emit_signal("done_reading")
#	else:
	header_text.percent_visible = 0.0
	body_text.percent_visible = 0.0
	text_timer.start(1)
	
	
func _process(delta: float) -> void:
	match text_to_readout:
		1:
			header_text.percent_visible = (HEADER_TIME - text_timer.time_left) / HEADER_TIME + 0.05
		3:
			body_text.percent_visible = (BODY_TIME - text_timer.time_left) / BODY_TIME + 0.05



func _on_TextTimer_timeout() -> void:
	match text_to_readout:
		0:
			text_timer.start(HEADER_TIME)
		1:
			text_timer.start(1)
		2:
			text_timer.start(BODY_TIME)
		3:
			text_timer.start(1)
		4:
			emit_signal("done_reading")
	text_to_readout += 1 

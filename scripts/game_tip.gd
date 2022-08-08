extends Node2D

onready var text_timer := $TextTimer
onready var label := $MarginContainer/TipLabel

export var TIME_TO_READ := 3.0
export var LABEL_TEXT := ""

func _ready() -> void:
	label.percent_visible = 0.0
	label.bbcode_text = "[center][wave amp=10 freq=4]%s[/wave][/center]" % LABEL_TEXT
	set_process(false)

func _process(delta: float) -> void:
	if not text_timer.is_stopped():
		var percent = TIME_TO_READ - text_timer.get_time_left()
		label.percent_visible = percent

func _on_Area2D_body_entered(body: Node) -> void:
	if body is Player:
		text_timer.start(TIME_TO_READ)
		set_process(true)

func _on_TextTimer_timeout() -> void:
	set_process(false)

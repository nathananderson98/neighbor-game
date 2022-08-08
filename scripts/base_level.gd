extends Node2D

class_name BaseLevel

var helped_neighbors := []
var total_neighbors := 0
var playback_position: float
var level_num := 1
var last_level := false

export var SECONDS_TO_COMPLETE := 10

signal game_complete(is_win)

onready var trolley = $YSort/Trolley as Trolley
onready var player = $YSort/Player as Player
onready var bounds = $CameraBounds
onready var audio_player = $AudioStreamPlayer
onready var gui = $YSort/Player/GUI as GUI
onready var trolley_locations = $TrolleyLocations
onready var end_game_panel = $Panel
onready var end_game_label_title = $Panel/VBoxContainer/EndGameTitle
onready var end_game_label_body = $Panel/VBoxContainer/EndGameBody
onready var display_timer = $DisplayTimer
onready var level_navigation := $LevelNavigation

func display_start(this_level_num: int, is_last_level: bool) -> void:
	last_level = is_last_level
	level_num = this_level_num
	end_game_label_title.text = 'Land of make believe'
	end_game_label_body.text = '1 - %s' % level_num
	end_game_panel.visible = true
	display_timer.start(2.0)

func _process(delta: float) -> void:
	if end_game_panel.visible:
			end_game_panel.rect_global_position = player.camera.get_camera_screen_center() - Vector2(get_viewport().get_visible_rect().size.x / 2, get_viewport().get_visible_rect().size.y / 2)

func _on_neighbor_found_home(id: int) -> void:
	helped_neighbors.append(id)
	gui.set_neighbor_count(total_neighbors - len(helped_neighbors))
	if len(helped_neighbors) == total_neighbors:
		trolley.set_trolley_open(true)
		gui.set_game_label("Get to the Trolley!")
		player.follower = trolley

func _set_audio(enabled: bool) -> void:
	if not enabled:
		playback_position = audio_player.get_playback_position()
		audio_player.stop()
	else:
		audio_player.play(playback_position)

func _on_toggle_music(playing: bool) -> void:
	print('Calling _set_audio %s' % playing)
	get_tree().call_group("plays_audio", "_set_audio", playing)

func _on_toggle_pause(paused: bool) -> void:
	print('Calling _set_paused %s' % paused)
	get_tree().call_group("pausable", "_set_paused", paused)

func _on_Trolley_rogers_entered_trolley() -> void:
	player.follower = null
	trolley.move_to_leave()

func _on_Trolley_rogers_left_trolley() -> void:
	gui.start_timer(SECONDS_TO_COMPLETE)
	trolley.move_to_end(trolley_locations.get_node("TrolleyEnd").global_position, SECONDS_TO_COMPLETE)
	
func _on_GameTimer_timeout() -> void:
	trolley.move_to_leave()


func _on_Trolley_left_wih_rogers(has_rogers) -> void:
	if has_rogers:
		if last_level:
			end_game_label_title.text = 'You are so neighborly'
			end_game_label_body.text = 'You saved all the neighbors in the land of make believe!'
			emit_signal("game_complete", true)
		else:
			end_game_label_title.text = 'You win'
			end_game_label_body.text = 'Proceeding to level %s' % (level_num + 1)
			emit_signal("game_complete", true)
		end_game_panel.visible = true
	else:
		emit_signal("game_complete", false)


# Sets up the level start
func _on_DisplayTimer_timeout() -> void:
	end_game_panel.visible = false
	if trolley != null:
		trolley.global_position = Vector2(bounds.get_node("Left").global_position.x - 20, trolley_locations.get_node("TrolleyStart").global_position.y)
	if player != null:
		player.global_position = trolley.get_node("TrolleySeatArea/SeatAreaShape").global_position
	for node in get_node("YSort").get_children():
		if 'Neighbor' in node.name:
			var neighbor = node as Neighbor
			neighbor.set_level_navigation(level_navigation)
			var err = neighbor.connect("found_home", self, "_on_neighbor_found_home")
			total_neighbors += 1
	print('Level loaded with %s neighbors' % total_neighbors)
	gui.set_neighbor_count(total_neighbors)
	player.set_camera_bounds(bounds.get_node("Top").global_position.y, bounds.get_node("Bottom").global_position.y, bounds.get_node("Left").global_position.x, bounds.get_node("Right").global_position.x)
	var err = gui.connect("toggle_music", self, "_on_toggle_music")
	print('toggle music error %s' % err) if err != 0 else print('')
	err = gui.connect("toggle_pause", self, "_on_toggle_pause")
	print('toggle music error %s' % err) if err != 0 else print('')
	err = gui.get_node("GameTimer").connect("timeout", self, "_on_GameTimer_timeout")
	print('toggle music error %s' % err) if err != 0 else print('')
	#	trolley.set_roger_body(player)
	trolley.move_to_start(get_node("TrolleyLocations/TrolleyStart").global_position)

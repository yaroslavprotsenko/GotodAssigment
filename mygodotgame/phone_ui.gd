extends CanvasLayer

@export var play_icon: Texture2D
@export var pause_icon: Texture2D

@export var song_screens: Array[Control]
@export var song_tracks: Array[AudioStream]

@export var active_on_start := false
@export var play_music_when_enabled := true
@export var open_phone_when_enabled := true

@export var hide_move_down := 550.0
@export var animation_time := 0.35

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var phone_root: Control = $PhoneRoot

var phone_enabled := false
var phone_open := false

var current_song := 0
var updating_slider := false

var open_position := Vector2.ZERO
var hidden_position := Vector2.ZERO
var phone_tween: Tween


func _ready() -> void:
	phone_enabled = active_on_start

	open_position = phone_root.position
	hidden_position = open_position + Vector2(0, hide_move_down)

	phone_root.position = hidden_position
	phone_root.visible = false

	for screen in song_screens:
		screen.visible = false

	connect_buttons()

	if song_screens.size() > 0:
		song_screens[current_song].visible = true

	music_player.finished.connect(_on_music_finished)

	setup_slider()
	update_play_button_icon()

	if phone_enabled:
		if play_music_when_enabled:
			play_current_song_from_start()

		if open_phone_when_enabled:
			open_phone()


func _process(_delta: float) -> void:
	update_music_ui()


func _input(event: InputEvent) -> void:
	if phone_enabled == false:
		return

	if event is InputEventKey:
		if event.pressed and event.echo == false and event.keycode == KEY_Q:
			toggle_phone()


func connect_buttons() -> void:
	for screen in song_screens:
		screen.get_node("PreviousButton").pressed.connect(previous_song)
		screen.get_node("NextButton").pressed.connect(next_song)
		screen.get_node("PlayButton").pressed.connect(play_or_pause_music)
		screen.get_node("SeekSlider").value_changed.connect(seek_music)


func enable_phone() -> void:
	phone_enabled = true

	if play_music_when_enabled:
		play_current_song_from_start()

	if open_phone_when_enabled:
		open_phone()


func toggle_phone() -> void:
	if phone_open:
		close_phone()
	else:
		open_phone()


func open_phone() -> void:
	phone_open = true
	phone_root.visible = true

	if phone_tween != null:
		phone_tween.kill()

	phone_tween = create_tween()
	phone_tween.tween_property(phone_root, "position", open_position, animation_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func close_phone() -> void:
	phone_open = false

	if phone_tween != null:
		phone_tween.kill()

	phone_tween = create_tween()
	phone_tween.tween_property(phone_root, "position", hidden_position, animation_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	phone_tween.finished.connect(hide_phone_after_close)


func hide_phone_after_close() -> void:
	if phone_open == false:
		phone_root.visible = false


func play_current_song_from_start() -> void:
	if song_tracks.size() == 0:
		return

	if current_song < 0 or current_song >= song_tracks.size():
		return

	if song_tracks[current_song] == null:
		return

	music_player.stop()
	music_player.stream = song_tracks[current_song]
	music_player.stream_paused = false
	music_player.play(0.0)

	setup_slider()
	update_play_button_icon()


func play_or_pause_music() -> void:
	if music_player.stream == null:
		return

	if music_player.playing == false:
		music_player.play(music_player.get_playback_position())
		music_player.stream_paused = false
	elif music_player.stream_paused:
		music_player.stream_paused = false
	else:
		music_player.stream_paused = true

	update_play_button_icon()


func next_song() -> void:
	show_song(current_song + 1)


func previous_song() -> void:
	show_song(current_song - 1)


func show_song(song_number: int) -> void:
	if song_screens.size() == 0:
		return

	if song_number < 0:
		song_number = song_screens.size() - 1

	if song_number >= song_screens.size():
		song_number = 0

	song_screens[current_song].visible = false

	current_song = song_number

	song_screens[current_song].visible = true

	play_current_song_from_start()


func seek_music(value: float) -> void:
	if updating_slider:
		return

	if music_player.stream == null:
		return

	music_player.seek(value)

	var screen := song_screens[current_song]
	var current_time_label := screen.get_node("CurrentTimeLabel") as Label
	current_time_label.text = format_time(value)


func _on_music_finished() -> void:
	next_song()


func setup_slider() -> void:
	if song_screens.size() == 0:
		return

	var screen := song_screens[current_song]
	var seek_slider := screen.get_node("SeekSlider") as HSlider
	var current_time_label := screen.get_node("CurrentTimeLabel") as Label
	var total_time_label := screen.get_node("TotalTimeLabel") as Label

	if music_player.stream == null:
		seek_slider.min_value = 0
		seek_slider.max_value = 100
		seek_slider.value = 0

		current_time_label.text = "0:00"
		total_time_label.text = "0:00"
		return

	var total_time := music_player.stream.get_length()

	seek_slider.min_value = 0
	seek_slider.max_value = total_time
	seek_slider.step = 0.01
	seek_slider.value = 0

	current_time_label.text = "0:00"
	total_time_label.text = format_time(total_time)


func update_music_ui() -> void:
	if song_screens.size() == 0:
		return

	if music_player.stream == null:
		return

	var screen := song_screens[current_song]
	var seek_slider := screen.get_node("SeekSlider") as HSlider
	var current_time_label := screen.get_node("CurrentTimeLabel") as Label

	var current_time := music_player.get_playback_position()

	current_time_label.text = format_time(current_time)

	updating_slider = true
	seek_slider.value = current_time
	updating_slider = false


func update_play_button_icon() -> void:
	if song_screens.size() == 0:
		return

	var screen := song_screens[current_song]
	var play_button := screen.get_node("PlayButton") as TextureButton

	if music_player.playing and music_player.stream_paused == false:
		play_button.texture_normal = pause_icon
	else:
		play_button.texture_normal = play_icon


func format_time(seconds: float) -> String:
	var total_seconds := int(seconds)
	var minutes := int(total_seconds / 60)
	var secs := total_seconds % 60

	if secs < 10:
		return str(minutes) + ":0" + str(secs)

	return str(minutes) + ":" + str(secs)

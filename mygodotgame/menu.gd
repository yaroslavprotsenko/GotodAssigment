extends Control

func _ready():
	$A.hide()
	$B.hide()
	$C.hide()
	$D.hide()
	$E.hide()

func start_to_a():
	play_click_sound()
	$Start.hide()
	$A.show()

func start_to_b():
	play_click_sound()
	$Start.hide()
	$B.show()

func b_to_a():
	play_click_sound()
	$B.hide()
	$A.show()

func a_to_c():
	play_click_sound()
	$A.hide()
	$C.show()

func c_to_d():
	play_click_sound()
	$C.hide()
	$D.show()

func d_to_e():
	play_click_sound()
	$D.hide()
	$E.show()

func start_game():
	play_click_sound()
	$E.hide()

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($Backround, "modulate:a", 0.0, 2.0)
	tween.tween_property($MenuMusic, "volume_db", -40.0, 2.0)

	await tween.finished

	var kitchen_music = get_parent().get_node("Node3D/KitchenMusic")
	kitchen_music.volume_db = -20.0
	kitchen_music.play()

	var music_tween = create_tween()
	music_tween.tween_property(kitchen_music, "volume_db", -3.0, 1.5)

	queue_free()

func play_click_sound():
	$ButtonClickSound.stop()
	$ButtonClickSound.play()

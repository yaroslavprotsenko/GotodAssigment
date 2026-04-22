extends Control

func _ready():
	$A.hide()
	$B.hide()
	$C.hide()
	$D.hide()
	$E.hide()

func start_to_a():
	$Start.hide()
	$A.show()

func start_to_b():
	$Start.hide()
	$B.show()

func b_to_a():
	$B.hide()
	$A.show()

func a_to_c():
	$A.hide()
	$C.show()

func c_to_d():
	$C.hide()
	$D.show()

func d_to_e():
	$D.hide()
	$E.show()

func start_game():
	$E.hide()

	var tween = create_tween()
	tween.tween_property($Backround, "modulate:a", 0.0, 1.0)

	await tween.finished

	queue_free()

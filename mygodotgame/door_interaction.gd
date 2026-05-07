extends StaticBody3D

@export var right_mouse_image: Control

@export var before_tea_text_object: Control

@export var black_screen: Control
@export var ending_label: Label

@export var text_show_time := 3.5

@export var ending_text := "I finally left for university. Unfortunately, on the way there, I was hit by a car. The end."

var mouse_inside := false
var text_is_showing := false
var tea_finished := false
var ending_started := false

var hide_timer: Timer


func _ready() -> void:
	input_ray_pickable = true

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	hide_timer = Timer.new()
	hide_timer.one_shot = true
	add_child(hide_timer)
	hide_timer.timeout.connect(_hide_before_tea_text)

	if right_mouse_image != null:
		right_mouse_image.visible = false

	if before_tea_text_object != null:
		before_tea_text_object.visible = false

	if black_screen != null:
		black_screen.visible = false

	if ending_label != null:
		ending_label.visible = false


func _input(event: InputEvent) -> void:
	if mouse_inside == false:
		return

	if text_is_showing:
		return

	if ending_started:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			interact_with_door()


func interact_with_door() -> void:
	if right_mouse_image != null:
		right_mouse_image.visible = false

	if tea_finished == false:
		show_before_tea_text()
	else:
		start_ending()


func unlock_after_tea() -> void:
	tea_finished = true

	if before_tea_text_object != null:
		before_tea_text_object.visible = false

	if right_mouse_image != null:
		right_mouse_image.visible = false


func show_before_tea_text() -> void:
	if before_tea_text_object == null:
		return

	text_is_showing = true
	before_tea_text_object.visible = true

	hide_timer.stop()
	hide_timer.wait_time = text_show_time
	hide_timer.start()


func _hide_before_tea_text() -> void:
	text_is_showing = false

	if before_tea_text_object != null:
		before_tea_text_object.visible = false

	if mouse_inside and right_mouse_image != null and ending_started == false:
		right_mouse_image.visible = true


func start_ending() -> void:
	ending_started = true

	if right_mouse_image != null:
		right_mouse_image.visible = false

	if before_tea_text_object != null:
		before_tea_text_object.visible = false

	if black_screen != null:
		black_screen.visible = true

	if ending_label != null:
		ending_label.text = ending_text
		ending_label.visible = true


func _on_mouse_entered() -> void:
	mouse_inside = true

	if text_is_showing:
		return

	if ending_started:
		return

	if right_mouse_image != null:
		right_mouse_image.visible = true


func _on_mouse_exited() -> void:
	mouse_inside = false

	if right_mouse_image != null:
		right_mouse_image.visible = false

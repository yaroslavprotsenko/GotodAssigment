extends StaticBody3D

@export var right_mouse_image: Control
@export var bottom_text_object: Control
@export var show_time := 3.5

var mouse_inside := false
var text_is_showing := false
var hide_timer: Timer


func _ready() -> void:
	input_ray_pickable = true

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	hide_timer = Timer.new()
	hide_timer.one_shot = true
	add_child(hide_timer)
	hide_timer.timeout.connect(_hide_bottom_text)

	if right_mouse_image != null:
		right_mouse_image.visible = false

	if bottom_text_object != null:
		bottom_text_object.visible = false


func _input(event: InputEvent) -> void:
	if mouse_inside == false:
		return

	if text_is_showing:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			show_bottom_text()


func show_bottom_text() -> void:
	text_is_showing = true

	if right_mouse_image != null:
		right_mouse_image.visible = false

	if bottom_text_object != null:
		bottom_text_object.visible = true

	hide_timer.stop()
	hide_timer.wait_time = show_time
	hide_timer.start()


func _hide_bottom_text() -> void:
	text_is_showing = false

	if bottom_text_object != null:
		bottom_text_object.visible = false

	if mouse_inside and right_mouse_image != null:
		right_mouse_image.visible = true


func _on_mouse_entered() -> void:
	mouse_inside = true

	if text_is_showing == false and right_mouse_image != null:
		right_mouse_image.visible = true


func _on_mouse_exited() -> void:
	mouse_inside = false

	if right_mouse_image != null:
		right_mouse_image.visible = false

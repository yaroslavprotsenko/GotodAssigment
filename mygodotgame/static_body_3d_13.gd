extends StaticBody3D

@export var right_mouse_image: Control
@export var mini_game_scene: PackedScene
@export var door_object: Node

var mouse_inside := false
var mini_game_open := false
var already_used := false


func _ready() -> void:
	input_ray_pickable = true

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	if right_mouse_image != null:
		right_mouse_image.visible = false


func _input(event: InputEvent) -> void:
	if already_used:
		return

	if mouse_inside == false:
		return

	if mini_game_open:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			start_mini_game()


func start_mini_game() -> void:
	if mini_game_scene == null:
		print("Mini game scene is not assigned.")
		return

	already_used = true
	mini_game_open = true
	input_ray_pickable = false

	if right_mouse_image != null:
		right_mouse_image.visible = false

	var mini_game = mini_game_scene.instantiate()
	get_tree().current_scene.add_child(mini_game)

	await mini_game.tree_exited

	mini_game_open = false

	if right_mouse_image != null:
		right_mouse_image.visible = false

	if door_object != null:
		if door_object.has_method("unlock_after_tea"):
			door_object.unlock_after_tea()


func _on_mouse_entered() -> void:
	mouse_inside = true

	if already_used:
		return

	if mini_game_open:
		return

	if right_mouse_image != null:
		right_mouse_image.visible = true


func _on_mouse_exited() -> void:
	mouse_inside = false

	if right_mouse_image != null:
		right_mouse_image.visible = false

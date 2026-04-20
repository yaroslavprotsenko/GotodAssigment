extends CharacterBody3D

var step_size = 2.0
var step_time = 0.08
var turn_time = 0.08
var check_distance = 1.0

var busy = false


func _unhandled_input(event):
	if busy:
		return

	if event.is_action_pressed("turn_left"):
		turn_player(90)

	elif event.is_action_pressed("turn_right"):
		turn_player(-90)

	elif event.is_action_pressed("move_forward"):
		try_move(-transform.basis.z)

	elif event.is_action_pressed("move_backward"):
		try_move(transform.basis.z)


func turn_player(angle_degrees):
	busy = true

	var start_rotation = rotation
	var end_rotation = rotation
	end_rotation.y += deg_to_rad(angle_degrees)

	var tween = create_tween()
	tween.tween_property(self, "rotation", end_rotation, turn_time)
	tween.finished.connect(_finish_action)


func try_move(direction):
	var flat_direction = direction
	flat_direction.y = 0
	flat_direction = flat_direction.normalized()

	if can_move(flat_direction):
		move_player(flat_direction)


func move_player(direction):
	busy = true

	var target_position = global_position + direction * step_size

	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, step_time)
	tween.finished.connect(_finish_action)


func can_move(direction):
	var space_state = get_world_3d().direct_space_state

	var start = global_position + Vector3(0, 0.5, 0)
	var end = start + direction * check_distance

	var query = PhysicsRayQueryParameters3D.create(start, end)
	query.exclude = [self]

	var result = space_state.intersect_ray(query)

	if result.is_empty():
		return true

	return false


func _finish_action():
	busy = false

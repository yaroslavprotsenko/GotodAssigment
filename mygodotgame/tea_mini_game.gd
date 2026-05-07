extends Node2D

@export var left_x := 370.0
@export var right_x := 1525.0

@export var normal_speed := 350.0
@export var pouring_speed := 120.0

@export var pour_tilt_degrees := 35.0

@export var kettle_start_water := 150.0
@export var cup_full_water := 80.0
@export var needed_cup_percent := 80.0
@export var perfect_cup_percent := 100.0

@export var pour_local_offset := Vector2(-355, -95)

@export var drop_size := Vector2(14, 14)
@export var drop_speed := 700.0
@export var drop_spawn_time := 0.035

@export var cup_size := Vector2(130, 90)

@export var intro_fade_time := 0.6
@export var result_fade_time := 0.5
@export var result_show_time := 3.0

@export var win_text := "This tea was perfect. I am ready for a great day."
@export var lose_text := "The day starts on a bad note. As always, it will probably be terrible."

@onready var kettle: Sprite2D = $KettleImage
@onready var cup: Sprite2D = $CupImage
@onready var water_parent: Node2D = $WaterParent

@onready var kettle_percent_label: Label = $KettlePercentLabel
@onready var cup_percent_label: Label = $CupPercentLabel

@onready var black_screen: ColorRect = $UI/BlackScreen
@onready var result_label: Label = $UI/ResultLabel

var direction := 1.0
var spawn_timer := 0.0

var game_started := false
var is_finished := false

var kettle_water := 0.0
var cup_water := 0.0

var drops := []


func _ready() -> void:
	kettle_water = kettle_start_water
	cup_water = 0.0

	result_label.visible = false

	black_screen.visible = true
	black_screen.modulate.a = 1.0

	update_ui()
	start_intro()


func start_intro() -> void:
	var tween = create_tween()
	tween.tween_property(black_screen, "modulate:a", 0.0, intro_fade_time)

	await tween.finished

	black_screen.visible = false
	game_started = true


func _process(delta: float) -> void:
	if game_started == false:
		return

	if is_finished:
		update_drops(delta)
		return

	var pouring := Input.is_key_pressed(KEY_SPACE) and kettle_water > 0

	move_kettle(delta, pouring)
	rotate_kettle(delta, pouring)

	if pouring:
		spawn_timer -= delta

		if spawn_timer <= 0:
			spawn_water_drop()
			spawn_timer = drop_spawn_time

	update_drops(delta)
	update_ui()

	if get_cup_percent() >= perfect_cup_percent:
		finish_game(true)
		return

	if kettle_water <= 0:
		finish_game(get_cup_percent() >= needed_cup_percent)


func move_kettle(delta: float, pouring: bool) -> void:
	var speed := normal_speed

	if pouring:
		speed = pouring_speed

	kettle.position.x += direction * speed * delta

	if kettle.position.x >= right_x:
		kettle.position.x = right_x
		direction = -1

	if kettle.position.x <= left_x:
		kettle.position.x = left_x
		direction = 1


func rotate_kettle(delta: float, pouring: bool) -> void:
	var target_rotation := 0.0

	if pouring:
		target_rotation = pour_tilt_degrees

	kettle.rotation_degrees = lerp(kettle.rotation_degrees, target_rotation, 8.0 * delta)


func spawn_water_drop() -> void:
	if kettle_water <= 0:
		return

	kettle_water -= 1.0

	var drop := ColorRect.new()
	drop.size = drop_size
	drop.color = Color(0.45, 0.8, 1.0, 0.95)

	water_parent.add_child(drop)
	drop.global_position = kettle.to_global(pour_local_offset)

	var random_x := randf_range(-35.0, 35.0)
	var velocity := Vector2(random_x, drop_speed)

	drops.append({
		"node": drop,
		"velocity": velocity
	})


func update_drops(delta: float) -> void:
	for i in range(drops.size() - 1, -1, -1):
		var drop = drops[i]
		var node: ColorRect = drop["node"]
		var velocity: Vector2 = drop["velocity"]

		node.global_position += velocity * delta

		if is_drop_inside_cup(node):
			add_water_to_cup()
			node.queue_free()
			drops.remove_at(i)
			continue

		if node.global_position.y > 900:
			node.queue_free()
			drops.remove_at(i)


func add_water_to_cup() -> void:
	cup_water += 1.0

	if cup_water > cup_full_water:
		cup_water = cup_full_water


func is_drop_inside_cup(drop: ColorRect) -> bool:
	var cup_rect := Rect2(cup.global_position - cup_size / 2.0, cup_size)
	return cup_rect.has_point(drop.global_position)


func get_kettle_percent() -> float:
	if kettle_start_water <= 0:
		return 0.0

	return kettle_water / kettle_start_water * 100.0


func get_cup_percent() -> float:
	if cup_full_water <= 0:
		return 0.0

	return cup_water / cup_full_water * 100.0


func update_ui() -> void:
	kettle_percent_label.text = "Kettle: " + str(int(get_kettle_percent())) + "%"
	cup_percent_label.text = "Cup: " + str(int(get_cup_percent())) + "%"


func finish_game(success: bool) -> void:
	if is_finished:
		return

	is_finished = true

	if success:
		result_label.text = win_text
	else:
		result_label.text = lose_text

	black_screen.visible = true
	black_screen.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(black_screen, "modulate:a", 1.0, result_fade_time)

	await tween.finished

	result_label.visible = true

	await get_tree().create_timer(result_show_time).timeout

	queue_free()

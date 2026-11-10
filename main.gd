extends Node3D

const RoomView := preload("res://room/room_view.gd")


func _ready() -> void:
	_setup_world()
	_setup_camera()
	_setup_lighting()
	_add_room()


func _setup_world() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.53, 0.70, 0.84)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.60, 0.62, 0.68)
	env.ambient_light_energy = 0.6

	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)


func _setup_camera() -> void:
	var camera := Camera3D.new()
	camera.position = Vector3(5.0, 8.0, 8.0)
	add_child(camera)
	camera.look_at(Vector3(0.0, 1.0, 0.0))


func _setup_lighting() -> void:
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50.0, -90.0, -35.0)
	sun.light_color = Color(1.0, 0.95, 0.85)
	sun.light_energy = 1.5
	sun.shadow_enabled = true
	add_child(sun)


func _add_room() -> void:
	var room := RoomView.new()
	add_child(room)

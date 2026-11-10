extends Node3D

const RoomView        := preload("res://room/room_view.gd")
const Creature        := preload("res://creature/creature.gd")
const CreatureView    := preload("res://creature/creature_view.gd")
const Needs           := preload("res://sim/needs.gd")
const Brain           := preload("res://sim/brain.gd")
const SmartObject     := preload("res://objects/smart_object.gd")
const ObjectDefinition := preload("res://objects/object_definition.gd")
const DebugOverlay    := preload("res://ui/debug_overlay.gd")


func _ready() -> void:
	_setup_world()
	_setup_camera()
	_setup_lighting()
	_add_room()
	_add_objects()
	var creature: Creature = _add_creature()
	_add_brain(creature)


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


func _add_objects() -> void:
	# Bed — recovers energy
	var bed_def := ObjectDefinition.new()
	bed_def.label          = "Bed"
	bed_def.interact_offset = Vector3(0.0, 0.0, 0.9)
	bed_def.use_duration   = 1800.0
	bed_def.gains          = {"energy": 0.055}
	bed_def.color          = Color(0.55, 0.38, 0.22)
	bed_def.mesh_size      = Vector3(1.4, 0.3, 1.0)
	_spawn_object(bed_def, Vector3(1.5, 0.0, -2.0))

	# Food bowl — recovers hunger
	var food_def := ObjectDefinition.new()
	food_def.label          = "Food bowl"
	food_def.interact_offset = Vector3(0.0, 0.0, 0.5)
	food_def.use_duration   = 120.0
	food_def.gains          = {"hunger": 0.5}
	food_def.color          = Color(0.85, 0.80, 0.25)
	food_def.mesh_size      = Vector3(0.4, 0.2, 0.4)
	_spawn_object(food_def, Vector3(-1.5, 0.0, -2.0))

	# Toy — recovers fun
	var toy_def := ObjectDefinition.new()
	toy_def.label          = "Toy"
	toy_def.interact_offset = Vector3(0.0, 0.0, 0.4)
	toy_def.use_duration   = 300.0
	toy_def.gains          = {"fun": 0.2}
	toy_def.color          = Color(0.90, 0.28, 0.28)
	toy_def.mesh_size      = Vector3(0.4, 0.4, 0.4)
	_spawn_object(toy_def, Vector3(1.5, 0.0, 1.0))

	# Window — recovers fun and social
	var win_def := ObjectDefinition.new()
	win_def.label          = "Window"
	win_def.interact_offset = Vector3(0.6, 0.0, 0.0)
	win_def.use_duration   = 180.0
	win_def.gains          = {"fun": 0.1, "social": 0.2}
	win_def.color          = Color(0.60, 0.85, 0.95)
	win_def.mesh_size      = Vector3(0.05, 1.5, 1.6)
	_spawn_object(win_def, Vector3(-3.0, 0.0, 0.0))


func _spawn_object(definition: ObjectDefinition, pos: Vector3) -> void:
	var obj := SmartObject.new()
	obj.definition = definition
	obj.position   = pos
	add_child(obj)


func _add_creature() -> Creature:
	var creature := Creature.new()
	var view     := CreatureView.new()
	creature.add_child(view)
	add_child(creature)
	return creature


func _add_brain(creature: Creature) -> void:
	var needs   := Needs.new()
	var brain   := Brain.new()
	var overlay := DebugOverlay.new()

	add_child(needs)
	add_child(brain)
	add_child(overlay)

	brain.setup(creature, needs)
	overlay.setup(needs, brain)

extends Node3D

const RoomView         := preload("res://room/room_view.gd")
const Creature         := preload("res://creature/creature.gd")
const CreatureView     := preload("res://creature/creature_view.gd")
const Needs            := preload("res://sim/needs.gd")
const Brain            := preload("res://sim/brain.gd")
const SmartObject      := preload("res://objects/smart_object.gd")
const ObjectDefinition := preload("res://objects/object_definition.gd")
const DebugOverlay     := preload("res://ui/debug_overlay.gd")
const TimeOfDay        := preload("res://core/time_of_day.gd")
const PresenceDetector   := preload("res://core/presence_detector.gd")
const CameraController   := preload("res://ui/camera_controller.gd")

var _sun: DirectionalLight3D
var _lamp: OmniLight3D
var _env: Environment
var _time_of_day: TimeOfDay


func _ready() -> void:
	_setup_world()
	_setup_camera()
	_setup_lighting()
	_add_room()
	_add_objects()
	var creature: Creature         = _add_creature()
	var view: CreatureView         = creature.get_child(0) as CreatureView
	_add_systems(creature, view)


func _process(_delta: float) -> void:
	if _time_of_day == null:
		return
	_sun.light_energy   = _time_of_day.get_sun_energy()
	_sun.light_color    = _time_of_day.get_sun_color()
	_lamp.light_energy  = _time_of_day.get_lamp_energy()
	_env.ambient_light_energy = _time_of_day.get_ambient_energy()
	_env.ambient_light_color  = _time_of_day.get_ambient_color()


func _setup_world() -> void:
	_env = Environment.new()
	_env.background_mode = Environment.BG_COLOR
	_env.background_color = Color(0.53, 0.70, 0.84)
	_env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_env.ambient_light_color = Color(0.60, 0.62, 0.68)
	_env.ambient_light_energy = 0.6

	var world_env := WorldEnvironment.new()
	world_env.environment = _env
	add_child(world_env)


func _setup_camera() -> void:
	var camera := CameraController.new()
	add_child(camera)


func _setup_lighting() -> void:
	_sun = DirectionalLight3D.new()
	_sun.rotation_degrees = Vector3(-50.0, -90.0, -35.0)
	_sun.light_color   = Color(1.0, 0.95, 0.85)
	_sun.light_energy  = 1.5
	_sun.shadow_enabled = true
	add_child(_sun)

	_lamp = OmniLight3D.new()
	_lamp.position     = Vector3(0.0, 3.2, 0.0)
	_lamp.light_color  = Color(1.0, 0.90, 0.70)
	_lamp.light_energy = 0.0
	_lamp.omni_range   = 6.0
	add_child(_lamp)


func _add_room() -> void:
	var room := RoomView.new()
	add_child(room)


func _add_objects() -> void:
	var bed_def := ObjectDefinition.new()
	bed_def.label           = "Bed"
	bed_def.interact_offset = Vector3(0.0, 0.0, 0.9)
	bed_def.use_duration    = 1800.0
	bed_def.gains           = {"energy": 0.055}
	bed_def.color           = Color(0.55, 0.38, 0.22)
	bed_def.mesh_size       = Vector3(1.4, 0.3, 1.0)
	_spawn_object(bed_def, Vector3(1.5, 0.0, -2.0))

	var food_def := ObjectDefinition.new()
	food_def.label           = "Food bowl"
	food_def.interact_offset = Vector3(0.0, 0.0, 0.5)
	food_def.use_duration    = 120.0
	food_def.gains           = {"hunger": 0.5}
	food_def.color           = Color(0.85, 0.80, 0.25)
	food_def.mesh_size       = Vector3(0.4, 0.2, 0.4)
	_spawn_object(food_def, Vector3(-1.5, 0.0, -2.0))

	var toy_def := ObjectDefinition.new()
	toy_def.label           = "Toy"
	toy_def.interact_offset = Vector3(0.0, 0.0, 0.4)
	toy_def.use_duration    = 300.0
	toy_def.gains           = {"fun": 0.2}
	toy_def.color           = Color(0.90, 0.28, 0.28)
	toy_def.mesh_size       = Vector3(0.4, 0.4, 0.4)
	_spawn_object(toy_def, Vector3(1.5, 0.0, 1.0))

	var win_def := ObjectDefinition.new()
	win_def.label           = "Window"
	win_def.interact_offset = Vector3(0.6, 0.0, 0.0)
	win_def.use_duration    = 180.0
	win_def.gains           = {"fun": 0.1, "social": 0.2}
	win_def.color           = Color(0.60, 0.85, 0.95)
	win_def.mesh_size       = Vector3(0.05, 1.5, 1.6)
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


func _add_systems(creature: Creature, view: CreatureView) -> void:
	var time_of_day := TimeOfDay.new()
	var needs       := Needs.new()
	var brain       := Brain.new()
	var presence    := PresenceDetector.new()
	var overlay     := DebugOverlay.new()

	add_child(time_of_day)
	add_child(needs)
	add_child(brain)
	add_child(presence)
	add_child(overlay)

	_time_of_day = time_of_day

	brain.setup(creature, needs, time_of_day)
	overlay.setup(needs, brain)

	presence.went_afk.connect(brain.on_went_afk)
	presence.returned.connect(brain.on_returned)
	presence.returned.connect(view.play_happy_reaction)

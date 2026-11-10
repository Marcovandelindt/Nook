class_name CameraController
extends Camera3D

# Point the camera orbits around.
@export var target: Vector3    = Vector3(0.0, 1.0, 0.0)

# Initial spherical coordinates that match the phase-0 camera position (5,8,8).
@export var distance: float    = 11.75
@export var azimuth: float     = 32.0   # horizontal angle, degrees
@export var elevation: float   = 37.0   # vertical angle, degrees

@export var orbit_sensitivity: float = 0.25
@export var zoom_step: float         = 1.0
@export var min_distance: float      = 4.0
@export var max_distance: float      = 20.0
@export var min_elevation: float     = 10.0
@export var max_elevation: float     = 75.0

var _lmb: bool = false
var _rmb: bool = false


func _ready() -> void:
	_apply()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		match mb.button_index:
			MOUSE_BUTTON_LEFT:
				_lmb = mb.pressed
			MOUSE_BUTTON_RIGHT:
				_rmb = mb.pressed
			MOUSE_BUTTON_WHEEL_UP:
				distance = clampf(distance - zoom_step, min_distance, max_distance)
				_apply()
			MOUSE_BUTTON_WHEEL_DOWN:
				distance = clampf(distance + zoom_step, min_distance, max_distance)
				_apply()

	elif event is InputEventMouseMotion and _lmb and _rmb:
		var m := event as InputEventMouseMotion
		azimuth   -= m.relative.x * orbit_sensitivity
		elevation  = clampf(elevation - m.relative.y * orbit_sensitivity,
				min_elevation, max_elevation)
		_apply()


func _apply() -> void:
	var az: float = deg_to_rad(azimuth)
	var el: float = deg_to_rad(elevation)
	position = target + Vector3(
		distance * cos(el) * sin(az),
		distance * sin(el),
		distance * cos(el) * cos(az)
	)
	look_at(target)

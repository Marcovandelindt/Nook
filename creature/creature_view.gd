class_name CreatureView
extends Node3D

# Body: capsule with radius BODY_R and cylindrical section BODY_H.
# BODY_BASE_Y keeps the bottom of the capsule flush with y = 0 (the floor).
const BODY_R: float      = 0.28
const BODY_H: float      = 0.50
const BODY_BASE_Y: float = BODY_H * 0.5 + BODY_R

# Eyes sit near the top of the capsule, slightly forward (+z = facing direction)
const EYE_R: float = 0.08
const EYE_X: float = 0.11
const EYE_Y: float = 0.88
const EYE_Z: float = 0.24

@export var body_color: Color = Color(0.35, 0.60, 0.80)
@export var eye_color: Color  = Color(0.95, 0.95, 0.95)

var _body:  MeshInstance3D
var _eye_l: MeshInstance3D
var _eye_r: MeshInstance3D
var _blink_timer: float = 0.0
var _blink_tween: Tween


func _ready() -> void:
	_build()
	_start_breathing()
	_schedule_blink()


func _process(delta: float) -> void:
	_blink_timer -= delta
	if _blink_timer <= 0.0:
		_do_blink()
		_schedule_blink()


func _build() -> void:
	_body = _capsule(BODY_R, BODY_H, body_color)
	_body.position.y = BODY_BASE_Y
	add_child(_body)

	_eye_l = _sphere(EYE_R, eye_color)
	_eye_l.position = Vector3(-EYE_X, EYE_Y, EYE_Z)
	add_child(_eye_l)

	_eye_r = _sphere(EYE_R, eye_color)
	_eye_r.position = Vector3(EYE_X, EYE_Y, EYE_Z)
	add_child(_eye_r)


func _start_breathing() -> void:
	var t: Tween = create_tween().set_loops()
	t.tween_property(_body, "scale:y", 1.04, 1.8) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(_body, "scale:y", 1.00, 1.8) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


func _schedule_blink() -> void:
	_blink_timer = randf_range(2.5, 7.0)


func _do_blink() -> void:
	if _blink_tween != null and _blink_tween.is_running():
		return
	_blink_tween = create_tween()
	_blink_tween.tween_property(_eye_l, "scale:y", 0.1, 0.06)
	_blink_tween.parallel().tween_property(_eye_r, "scale:y", 0.1, 0.06)
	_blink_tween.tween_property(_eye_l, "scale:y", 1.0, 0.10)
	_blink_tween.parallel().tween_property(_eye_r, "scale:y", 1.0, 0.10)


func _capsule(radius: float, height: float, color: Color) -> MeshInstance3D:
	var mi   := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height + radius * 2.0
	mi.mesh = mesh
	mi.material_override = _mat(color)
	return mi


func _sphere(radius: float, color: Color) -> MeshInstance3D:
	var mi   := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mi.mesh = mesh
	mi.material_override = _mat(color)
	return mi


func _mat(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	return mat

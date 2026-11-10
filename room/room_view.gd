class_name RoomView
extends Node3D

# Interior dimensions
const ROOM_W: float = 6.0
const ROOM_D: float = 6.0
const ROOM_H: float = 4.0
const WALL_T: float = 0.2

# Window in the left wall (x = -ROOM_W/2)
const WIN_Y_BOT: float = 1.2   # bottom of opening
const WIN_H: float    = 2.0    # opening height
const WIN_HALF_Z: float = 1.0  # half-width of opening in z

# @export makes these tunable from the Godot editor inspector without changing code
@export var floor_color: Color = Color(0.76, 0.60, 0.42)
@export var wall_color: Color  = Color(0.95, 0.93, 0.88)


func _ready() -> void:
	_build()


func _build() -> void:
	_add_floor()
	_add_back_wall()
	_add_right_wall()
	_add_left_wall()


func _add_floor() -> void:
	add_child(_box(
		Vector3(ROOM_W + WALL_T * 2.0, WALL_T, ROOM_D + WALL_T * 2.0),
		Vector3(0.0, -WALL_T * 0.5, 0.0),
		floor_color
	))


func _add_back_wall() -> void:
	add_child(_box(
		Vector3(ROOM_W + WALL_T * 2.0, ROOM_H, WALL_T),
		Vector3(0.0, ROOM_H * 0.5, -(ROOM_D * 0.5 + WALL_T * 0.5)),
		wall_color
	))


func _add_right_wall() -> void:
	add_child(_box(
		Vector3(WALL_T, ROOM_H, ROOM_D),
		Vector3(ROOM_W * 0.5 + WALL_T * 0.5, ROOM_H * 0.5, 0.0),
		wall_color
	))


func _add_left_wall() -> void:
	var x: float = -(ROOM_W * 0.5 + WALL_T * 0.5)
	var side_d: float = ROOM_D * 0.5 - WIN_HALF_Z

	# Strip below window
	add_child(_box(
		Vector3(WALL_T, WIN_Y_BOT, ROOM_D),
		Vector3(x, WIN_Y_BOT * 0.5, 0.0),
		wall_color
	))

	# Strip above window
	var top_h: float = ROOM_H - (WIN_Y_BOT + WIN_H)
	add_child(_box(
		Vector3(WALL_T, top_h, ROOM_D),
		Vector3(x, WIN_Y_BOT + WIN_H + top_h * 0.5, 0.0),
		wall_color
	))

	# Side panel: towards camera (z > WIN_HALF_Z)
	add_child(_box(
		Vector3(WALL_T, WIN_H, side_d),
		Vector3(x, WIN_Y_BOT + WIN_H * 0.5, WIN_HALF_Z + side_d * 0.5),
		wall_color
	))

	# Side panel: away from camera (z < -WIN_HALF_Z)
	add_child(_box(
		Vector3(WALL_T, WIN_H, side_d),
		Vector3(x, WIN_Y_BOT + WIN_H * 0.5, -(WIN_HALF_Z + side_d * 0.5)),
		wall_color
	))


func _box(size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mi.material_override = mat
	mi.position = pos
	return mi

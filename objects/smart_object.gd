class_name SmartObject
extends Node3D

const ObjectDefinition := preload("res://objects/object_definition.gd")

@export var definition: ObjectDefinition


func _ready() -> void:
	add_to_group("smart_objects")
	if definition != null:
		_build_visual()


func get_interact_position() -> Vector3:
	if definition == null:
		return global_position
	return global_position + definition.interact_offset


func _build_visual() -> void:
	var mi   := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = definition.mesh_size
	mi.mesh = mesh
	mi.position.y = definition.mesh_size.y * 0.5
	var mat := StandardMaterial3D.new()
	mat.albedo_color = definition.color
	mi.material_override = mat
	add_child(mi)

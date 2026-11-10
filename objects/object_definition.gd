class_name ObjectDefinition
extends Resource

@export var label: String = ""

# Where the creature stands relative to the object's origin.
@export var interact_offset: Vector3 = Vector3.ZERO

# How long one use-session lasts in simulated seconds.
@export var use_duration: float = 120.0

# Gains applied to needs per simulated second while in use.
# Keys are StringNames matching Needs properties: "energy", "hunger", "fun", "social".
@export var gains: Dictionary = {}

# Visual placeholder for phase 2.
@export var color: Color      = Color.WHITE
@export var mesh_size: Vector3 = Vector3(0.5, 0.5, 0.5)

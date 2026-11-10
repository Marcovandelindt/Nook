class_name PresenceDetector
extends Node

signal went_afk
signal returned

# Real seconds without mouse movement before the user is considered AFK.
@export var afk_timeout: float = 180.0

var is_present: bool = true

var _last_pos: Vector2 = Vector2.ZERO
var _afk_timer: float  = 0.0


func _ready() -> void:
	_last_pos = DisplayServer.mouse_get_position()


func _process(delta: float) -> void:
	var pos: Vector2 = DisplayServer.mouse_get_position()

	if pos != _last_pos:
		_last_pos  = pos
		_afk_timer = 0.0
		if not is_present:
			is_present = true
			returned.emit()
		return

	if is_present:
		_afk_timer += delta
		if _afk_timer >= afk_timeout:
			is_present = false
			went_afk.emit()

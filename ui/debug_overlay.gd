class_name DebugOverlay
extends CanvasLayer

const ClockScript := preload("res://core/sim_clock.gd")
const Needs       := preload("res://sim/needs.gd")
const Brain       := preload("res://sim/brain.gd")

var _label:  Label
var _needs:  Needs
var _brain:  Brain
var _clock:  ClockScript


func setup(needs: Needs, brain: Brain) -> void:
	_needs = needs
	_brain = brain


func _ready() -> void:
	_clock = get_node("/root/Clock")

	_label = Label.new()
	_label.position = Vector2(10.0, 10.0)
	_label.add_theme_font_size_override("font_size", 14)
	_label.modulate = Color(1.0, 1.0, 0.5)
	add_child(_label)
	visible = false


func _process(_delta: float) -> void:
	if visible and _needs != null:
		_label.text = _build_text()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key: InputEventKey = event as InputEventKey
	if not key.pressed or key.echo:
		return
	match key.keycode:
		KEY_F1:
			visible = not visible
		KEY_1:
			_clock.time_scale = 1.0
		KEY_2:
			_clock.time_scale = 10.0
		KEY_3:
			_clock.time_scale = 60.0


func _build_text() -> String:
	var ts: float = _clock.time_scale
	var lines: PackedStringArray
	lines.append("=== NOOK DEBUG  [F1 hide] ===")
	lines.append("Time scale: %.0fx    [1] 1x  [2] 10x  [3] 60x" % ts)
	lines.append("")
	lines.append("NEEDS")
	lines.append("  energy  %s" % _bar(_needs.energy))
	lines.append("  hunger  %s" % _bar(_needs.hunger))
	lines.append("  fun     %s" % _bar(_needs.fun))
	lines.append("  social  %s" % _bar(_needs.social))
	lines.append("  mood    %s" % _bar(_needs.get_mood()))
	lines.append("")
	lines.append("ACTION: %s" % _brain.get_status())
	if not _brain.last_scores.is_empty():
		lines.append("")
		lines.append("LAST SCORES")
		for entry: Dictionary in _brain.last_scores:
			lines.append("  %-12s  %.2f" % [entry["label"], entry["score"]])
	return "\n".join(lines)


func _bar(value: float) -> String:
	var filled: int = clampi(roundi(value / 10.0), 0, 10)
	var bar: String = ""
	for i: int in range(10):
		bar += "█" if i < filled else "░"
	return "[%s] %5.1f" % [bar, value]

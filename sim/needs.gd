class_name Needs
extends Node

signal changed(need: StringName, value: float)

# Decay rates in units per simulated second.
# Full drain from 100 → 0 takes: 100 / rate seconds of sim-time.
@export var energy_decay: float = 100.0 / (16.0 * 3600.0)  # empties in 16 sim-hours
@export var hunger_decay: float = 100.0 / ( 8.0 * 3600.0)  # empties in  8 sim-hours
@export var fun_decay:    float = 100.0 / ( 4.0 * 3600.0)  # empties in  4 sim-hours
@export var social_decay: float = 100.0 / ( 6.0 * 3600.0)  # empties in  6 sim-hours

var energy: float = 80.0
var hunger: float = 70.0
var fun:    float = 60.0
var social: float = 65.0


func _ready() -> void:
	SimClock.ticked.connect(_on_tick)


func _on_tick(sim_delta: float) -> void:
	_decay(&"energy", energy_decay, sim_delta)
	_decay(&"hunger", hunger_decay, sim_delta)
	_decay(&"fun",    fun_decay,    sim_delta)
	_decay(&"social", social_decay, sim_delta)


func get_value(need: StringName) -> float:
	return get(need)


func apply_gain(need: StringName, amount: float) -> void:
	var new_val: float = clampf(get_value(need) + amount, 0.0, 100.0)
	set(need, new_val)
	changed.emit(need, new_val)


# Non-linear urgency: a need at 0% is much more urgent than one at 50%.
# Returns 0 when the need is full, 1 when completely empty.
func urgency(need: StringName) -> float:
	var v: float = get_value(need) / 100.0
	return (1.0 - v) * (1.0 - v)


func get_mood() -> float:
	return (energy + hunger + fun + social) / 4.0


func _decay(need: StringName, rate: float, sim_delta: float) -> void:
	var old: float    = get_value(need)
	var new_val: float = clampf(old - rate * sim_delta, 0.0, 100.0)
	set(need, new_val)
	if old != new_val:
		changed.emit(need, new_val)

class_name Brain
extends Node

const Creature    := preload("res://creature/creature.gd")
const Needs       := preload("res://sim/needs.gd")
const SmartObject := preload("res://objects/smart_object.gd")

# Base score for the "just wander" option.
# Objects need to beat this to be chosen.
const IDLE_SCORE: float    = 10.0
const EVAL_INTERVAL: float = 30.0  # simulated seconds between re-evaluations

var last_scores: Array[Dictionary] = []

var _needs: Needs
var _creature: Creature
var _current_object: SmartObject = null
var _using: bool      = false
var _use_elapsed: float = 0.0
var _eval_timer: float  = 0.0


func setup(creature: Creature, needs: Needs) -> void:
	_creature = creature
	_needs    = needs
	_creature.arrived.connect(_on_arrived)


func _ready() -> void:
	SimClock.ticked.connect(_on_tick)


func get_status() -> String:
	if _using and _current_object != null:
		return "Using %s (%.0f / %.0f s)" % [
			_current_object.definition.label,
			_use_elapsed,
			_current_object.definition.use_duration,
		]
	if _current_object != null:
		return "Walking to %s" % _current_object.definition.label
	return "Wandering"


func _on_tick(sim_delta: float) -> void:
	if _using:
		_tick_use(sim_delta)
	elif _current_object == null:
		_eval_timer += sim_delta
		if _eval_timer >= EVAL_INTERVAL:
			_eval_timer = 0.0
			_evaluate()


func _tick_use(sim_delta: float) -> void:
	for need_name: String in _current_object.definition.gains:
		var gain: float = _current_object.definition.gains[need_name]
		_needs.apply_gain(need_name, gain * sim_delta)

	_use_elapsed += sim_delta
	if _use_elapsed >= _current_object.definition.use_duration:
		_end_use()


func _end_use() -> void:
	_using        = false
	_use_elapsed  = 0.0
	_current_object = null
	_creature.command_wander()
	_eval_timer = EVAL_INTERVAL  # re-evaluate on next tick


func _evaluate() -> void:
	var objects: Array[Node] = get_tree().get_nodes_in_group("smart_objects")
	var best_score: float    = IDLE_SCORE
	var best_object: SmartObject = null
	last_scores = []

	for node: Node in objects:
		var obj: SmartObject = node as SmartObject
		if obj == null or obj.definition == null:
			continue
		var score: float = _score(obj)
		last_scores.append({"label": obj.definition.label, "score": score})
		if score > best_score:
			best_score  = score
			best_object = obj

	last_scores.append({"label": "Wander", "score": IDLE_SCORE})
	last_scores.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a["score"] > b["score"]
	)

	if best_object != null:
		_current_object = best_object
		_creature.command_walk_to(best_object.get_interact_position())


# score = Σ (urgency × gain_per_sec × duration) × distance_factor × noise
func _score(obj: SmartObject) -> float:
	var need_score: float = 0.0
	for need_name: String in obj.definition.gains:
		var urgency: float   = _needs.urgency(need_name)
		var gain: float      = obj.definition.gains[need_name]
		need_score += urgency * gain * obj.definition.use_duration

	var dist: float          = _creature.global_position.distance_to(obj.get_interact_position())
	var dist_factor: float   = 1.0 / (1.0 + dist)
	var noise: float         = randf_range(0.9, 1.1)
	return need_score * dist_factor * noise


func _on_arrived() -> void:
	if _current_object != null:
		_using       = true
		_use_elapsed = 0.0

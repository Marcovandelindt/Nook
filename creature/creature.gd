class_name Creature
extends Node3D

signal state_changed(new_state: int)
signal arrived  # fired when a brain-commanded walk_to target is reached

enum State { IDLE, WALKING }

const WALK_SPEED: float  = 1.5
const ACCEL: float       = 5.0
const ARRIVE_DIST: float = 0.15
const TURN_SPEED: float  = 8.0
const IDLE_MIN: float    = 2.0
const IDLE_MAX: float    = 5.0
const WANDER_X: float    = 2.5
const WANDER_Z: float    = 2.5

var state: State  = State.IDLE
var speed: float  = 0.0

var _target: Vector3     = Vector3.ZERO
var _idle_timer: float   = 0.0
var _facing: float       = 0.0
var _brain_walk: bool    = false  # true when walking to a brain-commanded position
var _paused: bool        = false  # true when user is AFK; suppresses random wandering


func _ready() -> void:
	_pick_idle()


func _process(delta: float) -> void:
	match state:
		State.IDLE:    _tick_idle(delta)
		State.WALKING: _tick_walk(delta)


# --- Brain commands ---

func command_walk_to(target: Vector3) -> void:
	_target     = target
	_brain_walk = true
	_set_state(State.WALKING)


# Release brain control; creature resumes random wandering.
func command_wander() -> void:
	_brain_walk = false
	_pick_idle()
	if state != State.WALKING:
		_set_state(State.IDLE)


# Stop all wandering until command_resume() is called (used when user is AFK).
func command_pause() -> void:
	_paused = true
	if state == State.WALKING and not _brain_walk:
		speed = 0.0
		_set_state(State.IDLE)
		_idle_timer = INF


func command_resume() -> void:
	_paused = false
	if not _brain_walk:
		_pick_idle()


# --- Internal ---

func _tick_idle(delta: float) -> void:
	speed = move_toward(speed, 0.0, ACCEL * delta)
	if _paused:
		return
	_idle_timer -= delta
	if _idle_timer <= 0.0:
		_start_wander()


func _tick_walk(delta: float) -> void:
	var diff: Vector3 = _target - position
	diff.y = 0.0
	var dist: float = diff.length()

	if dist < ARRIVE_DIST:
		speed = 0.0
		if _brain_walk:
			_brain_walk    = false
			_idle_timer    = INF  # stay put until Brain calls command_wander()
			_set_state(State.IDLE)
			arrived.emit()
		else:
			_set_state(State.IDLE)
			_pick_idle()
		return

	# Decelerate in the last 0.5 m so it doesn't overshoot
	var desired: float = WALK_SPEED if dist > 0.5 else WALK_SPEED * (dist / 0.5)
	speed = move_toward(speed, desired, ACCEL * delta)

	var dir: Vector3        = diff.normalized()
	var target_angle: float = atan2(dir.x, dir.z)
	_facing = lerp_angle(_facing, target_angle, TURN_SPEED * delta)

	position  += Vector3(sin(_facing), 0.0, cos(_facing)) * speed * delta
	rotation.y = _facing


func _start_wander() -> void:
	_target = Vector3(
		randf_range(-WANDER_X, WANDER_X),
		0.0,
		randf_range(-WANDER_Z, WANDER_Z)
	)
	_set_state(State.WALKING)


func _pick_idle() -> void:
	_idle_timer = randf_range(IDLE_MIN, IDLE_MAX)


func _set_state(new_state: State) -> void:
	if state == new_state:
		return
	state = new_state
	state_changed.emit(new_state)

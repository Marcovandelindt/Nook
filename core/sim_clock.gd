extends Node

signal ticked(sim_delta: float)

# Simulated seconds that pass per real second.
# 1 = real-time, 60 = one sim-minute per real second.
@export var time_scale: float = 1.0

const TICK_RATE: float     = 10.0
const TICK_INTERVAL: float = 1.0 / TICK_RATE

var sim_time: float = 0.0
var _acc: float     = 0.0


func _process(delta: float) -> void:
	_acc += delta
	while _acc >= TICK_INTERVAL:
		_acc     -= TICK_INTERVAL
		var sim_delta: float = TICK_INTERVAL * time_scale
		sim_time += sim_delta
		ticked.emit(sim_delta)

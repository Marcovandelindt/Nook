class_name TimeOfDay
extends Node

# Current hour as a float (0.0 = midnight, 12.0 = noon, 23.99 = end of day).
var hour: float = 12.0


func _process(_delta: float) -> void:
	var t: Dictionary = Time.get_time_dict_from_system()
	hour = t["hour"] + t["minute"] / 60.0 + t["second"] / 3600.0


# --- Sleepiness ---

# Returns 1.0 during the day; rises toward 4.0 at night so the Brain
# scores the bed much higher when it is time to sleep.
func get_sleepiness_factor() -> float:
	if hour >= 22.0 or hour < 6.0:
		return 4.0
	if hour >= 20.0:
		return lerpf(1.0, 4.0, (hour - 20.0) / 2.0)
	if hour < 8.0:
		return lerpf(4.0, 1.0, (hour - 6.0) / 2.0)
	return 1.0


# --- Sun (DirectionalLight3D through the window) ---

func get_sun_energy() -> float:
	if hour < 5.0 or hour > 21.0:
		return 0.0
	var t: float
	if hour <= 12.0:
		t = (hour - 5.0) / 7.0
	else:
		t = (21.0 - hour) / 9.0
	return t * 1.5


func get_sun_color() -> Color:
	var dawn_dusk := Color(1.0, 0.55, 0.20)
	var noon      := Color(1.0, 0.95, 0.85)
	if hour < 5.0 or hour > 21.0:
		return dawn_dusk
	var t: float
	if hour <= 12.0:
		t = clampf((hour - 5.0) / 4.0, 0.0, 1.0)
	else:
		t = clampf((21.0 - hour) / 4.0, 0.0, 1.0)
	return dawn_dusk.lerp(noon, t)


# --- Indoor lamp (OmniLight3D) ---

func get_lamp_energy() -> float:
	if hour >= 20.0 or hour < 6.0:
		return 1.2
	if hour >= 18.0:
		return lerpf(0.0, 1.2, (hour - 18.0) / 2.0)
	if hour < 8.0:
		return lerpf(1.2, 0.0, (hour - 6.0) / 2.0)
	return 0.0


# --- Ambient (WorldEnvironment) ---

func get_ambient_energy() -> float:
	if hour < 5.0 or hour > 22.0:
		return 0.1
	if hour <= 7.0:
		return lerpf(0.1, 0.6, (hour - 5.0) / 2.0)
	if hour >= 20.0:
		return lerpf(0.6, 0.1, (hour - 20.0) / 2.0)
	return 0.6


func get_ambient_color() -> Color:
	var night := Color(0.10, 0.12, 0.25)
	var day   := Color(0.60, 0.62, 0.68)
	if hour < 5.0 or hour > 22.0:
		return night
	if hour <= 7.0:
		return night.lerp(day, (hour - 5.0) / 2.0)
	if hour >= 20.0:
		return day.lerp(night, (hour - 20.0) / 2.0)
	return day

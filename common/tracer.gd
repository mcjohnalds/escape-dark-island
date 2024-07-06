class_name Tracer
extends Node3D

var min_length := 2.0
var max_length := 10.0
var min_lifetime := 0.05
var speed := 250.0
var start: Vector3
var end: Vector3
var _created_at := 0.0
var _trail_start_distance := 0.0
var _trail_end_distance := 0.0


func _enter_tree() -> void:
	_trail_end_distance = minf(min_length, start.distance_to(end))
	_created_at = Util.get_ticks_sec()
	_update()


func _process(delta: float) -> void:
	var stage := (
		"freeing" if _trail_start_distance >= start.distance_to(end)
		else "shrinking" if _trail_end_distance >= start.distance_to(end)
		else "growing" if _trail_end_distance - _trail_start_distance < max_length
		else "travelling"
	)
	match stage:
		"growing":
			_trail_start_distance = 0.0
			_trail_end_distance += speed * delta
		"travelling":
			_trail_start_distance += speed * delta
			_trail_end_distance += speed * delta
		"shrinking":
			if Util.get_ticks_sec() - _created_at > min_lifetime:
				_trail_start_distance += speed * delta
				_trail_end_distance = start.distance_to(end)
		"freeing":
			queue_free()
	_update()


func _update() -> void:
	global_position = start + _trail_start_distance * start.direction_to(end)
	Util.safe_look_at(self, end, true)
	scale.z = _trail_end_distance - _trail_start_distance

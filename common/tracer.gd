class_name Tracer
extends Node3D

var max_length := 10.0
var speed := 250.0
var start: Vector3
var end: Vector3
var _trail_start_distance := 0.0
var _trail_end_distance := 0.0

func _init() -> void:
	# We hide initially to prevent the tracer from rendering at position 0,0,0
	# for the first frame
	visible = false


func _process(delta: float) -> void:
	visible = true
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
			_trail_start_distance += speed * delta
			_trail_end_distance = start.distance_to(end)
		"freeing":
			queue_free()
	global_position = start + _trail_start_distance * start.direction_to(end)
	Util.safe_look_at(self, end, true)
	scale.z = _trail_end_distance - _trail_start_distance

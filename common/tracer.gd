class_name Tracer
extends Node3D

var start: Vector3
var end: Vector3
var _has_rendered := false


func _process(delta: float) -> void:
	if _has_rendered:
		var dir1 := start.direction_to(end)
		var speed := 200.0
		start += start.direction_to(end) * speed * delta
		var dir2 := start.direction_to(end)
		if dir1.dot(dir2) < 0.0:
			queue_free()
	_has_rendered = true
	global_position = start
	Util.safe_look_at(self, end, true)
	self.scale.z = start.distance_to(end)

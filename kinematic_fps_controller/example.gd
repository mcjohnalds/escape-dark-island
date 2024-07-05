extends Node3D


func _ready() -> void:
	if process_mode == PROCESS_MODE_DISABLED:
		return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

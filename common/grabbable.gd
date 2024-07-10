extends Node3D
class_name Grabbable

enum Type { AMMO, GRENADE, BANDAGES }

@export var _type := Type.AMMO
@onready var _initial_transform := transform


func get_type() -> Type:
	return _type


func reset() -> void:
	transform = _initial_transform
	process_mode = PROCESS_MODE_INHERIT
	visible = true


func disable() -> void:
	process_mode = PROCESS_MODE_DISABLED
	visible = false

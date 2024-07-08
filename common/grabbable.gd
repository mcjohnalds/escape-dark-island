extends Node3D
class_name Grabbable

enum Type { AMMO, GRENADE, BANDAGES }

@export var _type := Type.AMMO


func get_type() -> Type:
	return _type

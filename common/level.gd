extends Node3D
class_name Level

@onready var directional_light: DirectionalLight3D = %DirectionalLight
@onready var world_environment: WorldEnvironment  = %WorldEnvironment
@onready var fuel_indicator_3d := %FuelIndicator3D
@onready var _omni_lights := %OmniLights


func get_omni_lights() -> Array[OmniLight3D]:
	var arr: Array[OmniLight3D] = []
	for light: OmniLight3D in _omni_lights.get_children():
		arr.append(light)
	return arr

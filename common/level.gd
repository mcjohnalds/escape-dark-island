extends Node3D
class_name Level

@onready var directional_light: DirectionalLight3D = %DirectionalLight
@onready var world_environment: WorldEnvironment  = %WorldEnvironment
@onready var fuel_indicator_3d := %FuelIndicator3D
@onready var _omni_lights := %OmniLights
@onready var _mesh: Node3D = %Mesh
var _light_mesh_material: StandardMaterial3D


func _ready() -> void:
	for child in Util.get_children_recursive(_mesh):
		if not child is MeshInstance3D:
			continue
		var child_mesh: MeshInstance3D = child
		for i in child_mesh.mesh.get_surface_count():
			if (
				not child_mesh.mesh.surface_get_material(i)
				is StandardMaterial3D
			):
				continue
			var material: StandardMaterial3D = (
				child_mesh.mesh.surface_get_material(i)
			)
			if material.emission_enabled:
				_light_mesh_material = material


func get_omni_lights() -> Array[OmniLight3D]:
	var arr: Array[OmniLight3D] = []
	for light: OmniLight3D in _omni_lights.get_children():
		arr.append(light)
	return arr


func set_light_mesh_emission_energy(emission_energy: float) -> void:
	_light_mesh_material.emission_energy_multiplier = emission_energy

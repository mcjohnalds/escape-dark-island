extends Node3D
class_name Level

@onready var _directional_light: DirectionalLight3D = %DirectionalLight
@onready var _omni_lights := %OmniLights
@onready var _mesh: Node3D = %Mesh
@onready var _player_home: Building = %PlayerHome
@onready var _enemy_buildings: Array[Building] = [
	%EnemyBuilding1, %EnemyBuilding2
]
@onready var _fuel_indicator_3d: FuelIndicator3D = %FuelIndicator3D
var _light_mesh_material: StandardMaterial3D


func _ready() -> void:
	for child in Util.get_children_recursive(_mesh):
		if not child is MeshInstance3D:
			continue
		var child_mesh: MeshInstance3D = child
		for i in child_mesh.mesh.get_surface_count():
			var material := child_mesh.mesh.surface_get_material(i)
			if not material is StandardMaterial3D:
				continue
			var standard: StandardMaterial3D = (
				child_mesh.mesh.surface_get_material(i)
			)
			if standard.emission_enabled:
				_light_mesh_material = standard


func get_omni_lights() -> Array[OmniLight3D]:
	var arr: Array[OmniLight3D] = []
	for light: OmniLight3D in _omni_lights.get_children():
		arr.append(light)
	return arr


func get_light_mesh_material() -> StandardMaterial3D:
	return _light_mesh_material


func get_directional_light() -> DirectionalLight3D:
	return _directional_light


func get_fuel_indicator_3d() -> FuelIndicator3D:
	return _fuel_indicator_3d


func get_player_home() -> Building:
	return _player_home


func get_enemy_buildings() -> Array[Building]:
	return _enemy_buildings

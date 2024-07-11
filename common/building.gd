extends Node
class_name Building

@onready var _retreat_locations_node: Node = $RetreatLocations
@onready var _grabbables_node: Node = $Grabbables
@onready var _enemies_node: Node = $Enemies


func get_retreat_locations() -> Array[Node3D]:
	var arr: Array[Node3D] = []
	for node: Node3D in _retreat_locations_node.get_children():
		arr.append(node)
	return arr


func respawn_grabbables() -> void:
	_respawn_grabbable_type(Grabbable.Type.AMMO, 3.0, 1.0)
	_respawn_grabbable_type(Grabbable.Type.GRENADE, 2.0, 1.0)
	_respawn_grabbable_type(Grabbable.Type.BANDAGES, 2.0, 1.0)


func respawn_enemy() -> void:
	for enemy: Enemy in _enemies_node.get_children():
		enemy.queue_free()
	var enemy: Enemy = global.get_enemy_scene().instantiate()
	enemy.retreat_locations = get_retreat_locations()
	enemy.position = get_retreat_locations().pick_random().global_position
	_enemies_node.add_child(enemy)


func _respawn_grabbable_type(
	grabbable_type: Grabbable.Type, mean: float, deviation: float
) -> void:
	var grabbables: Array[Grabbable] = []
	for grabbable: Grabbable in _grabbables_node.get_children():
		if grabbable.get_type() == grabbable_type:
			grabbables.append(grabbable)
	var random_count := clampi(
		roundi(randfn(mean, deviation)), 1, grabbables.size()
	)
	for i in mini(random_count, grabbables.size()):
		var j := randi_range(0, grabbables.size() - 1)
		grabbables[j].reset()
		grabbables.remove_at(j)
	for grabbable in grabbables:
		grabbable.disable()

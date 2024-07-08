extends RigidBody3D
class_name ThrownGrenade

@export var explosion_scene: PackedScene
@export var explosion_range := 14.0
@export var explosion_max_damage := 110.0


func _ready() -> void:
	get_tree().create_timer(2.0).timeout.connect(_explode)


func _explode() -> void:
	var explosion: CustomParticlesCluster = explosion_scene.instantiate()
	explosion.position = position
	explosion.one_shot = true
	explosion.emitting = true
	global.get_level().add_child(explosion)

	var targets := get_tree().get_nodes_in_group("enemies")
	targets.append(get_tree().get_first_node_in_group("player"))
	for target: Node3D in targets:
		var query := PhysicsRayQueryParameters3D.new()
		query.collision_mask = Global.PhysicsLayer.DEFAULT
		query.from = global_position + center_of_mass
		query.to = target.global_position
		query.exclude = [self.get_rid()]
		var collision := get_world_3d().direct_space_state.intersect_ray(query)
		if collision:
			var d := query.from.distance_to(collision.position)
			if collision.collider == target and d < explosion_range:
				# Grenade damage varies between explosion_max_damage and
				# explosion_max_damage/8.0
				target.damage(
					minf(explosion_range / d, 8.0) / 8.0 * explosion_max_damage
				)

	queue_free()

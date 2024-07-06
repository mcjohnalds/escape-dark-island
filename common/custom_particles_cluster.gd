class_name CustomParticlesCluster
extends Node3D

@export var free_after_lifetime := false


@export var one_shot := false:
	set(value):
		one_shot = value
		if not is_node_ready():
			await ready
		for particles in _get_particles():
			particles.one_shot = value


@export var emitting := false:
	set(value):
		emitting = value
		if not is_node_ready():
			await ready
		for particles in _get_particles():
			particles.emitting = value


func _ready() -> void:
	if free_after_lifetime:
		await get_tree().create_timer(get_max_lifetime()).timeout
		queue_free()


func get_max_lifetime() -> float:
	var max_lifetime := 0.0
	for particles in _get_particles():
		max_lifetime = maxf(max_lifetime, particles.lifetime)
	return max_lifetime


func _get_particles() -> Array[GPUParticles3D]:
	var particles: Array[GPUParticles3D] = []
	for child in get_children():
		if child is GPUParticles3D:
			particles.append(child)
	return particles


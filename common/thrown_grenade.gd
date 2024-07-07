extends RigidBody3D
class_name ThrownGrenade

@export var explosion_scene: PackedScene


func _ready() -> void:
	get_tree().create_timer(2.0).timeout.connect(func() -> void:
		var explosion: CustomParticlesCluster = explosion_scene.instantiate()
		explosion.position = position
		explosion.one_shot = true
		explosion.emitting = true
		global.get_level().add_child(explosion)
		queue_free()
	)

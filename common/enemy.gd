extends CharacterBody3D
class_name Enemy

enum State { IDLE, ATTACK, RETREAT }

@export var black_goo_explosion_scene: PackedScene
@export var eye_explosion_scene: PackedScene
var min_retreat_duration := 5.0
var movement_speed := 8.0
var retreat_damage_threshold := 10.0
var acceleration_speed := 4.0
var max_health := 100.0
var _state := State.IDLE
var _damage_taken_since_last_state_transition := 0.0
var _last_state_transition_at := -1000.0
var _animation_time := 0.0
var _alive := true
var _shrinking := false
var _last_attack_at := -1000.0
@onready var _health := max_health
@onready var _navigation_agent: NavigationAgent3D = %NavigationAgent3D
@onready var _eye: Node3D = %Eye
@onready var _eye_cover: Node3D = %EyeCover
@onready var _body: MeshInstance3D = %Body
@onready var _initial_eye_position := _eye.position
@onready var _initial_body_position := _body.position

func _ready() -> void:
	# Wait for the NavigationServer to sync
	await get_tree().physics_frame
	while true:
		if _state == State.ATTACK:
			_navigation_agent.set_target_position(
				global.get_player().global_position
			)
		await get_tree().create_timer(0.5).timeout


func _physics_process(delta: float) -> void:
	_animation_time += remap(_health, 0.0, max_health, 8.0, 0.5) * delta
	_update_navigation(delta)
	_update_rotation(delta)
	_update_eye()
	_update_eye_cover()
	_update_body(delta)
	_health += 2.0 * delta
	_health = minf(_health, max_health)
	_update_attack(delta)


func damage(amount: float) -> void:
	_health -= amount
	_damage_taken_since_last_state_transition += amount
	if _health < 0.0:
		_health = 0.0
		if _alive:
			_alive = false
			_eye.visible = false
			var eye_explosion: CustomParticlesCluster = eye_explosion_scene.instantiate()
			eye_explosion.position = _eye.global_position
			eye_explosion.one_shot = true
			eye_explosion.emitting = true
			get_parent().add_child(eye_explosion)
			await get_tree().create_timer(0.7).timeout
			_shrinking = true
			await get_tree().create_timer(0.7).timeout
			_body.visible = false
			var body_explosion: CustomParticlesCluster = black_goo_explosion_scene.instantiate()
			body_explosion.position = _eye.global_position
			body_explosion.one_shot = true
			body_explosion.emitting = true
			get_parent().add_child(body_explosion)
			await get_tree().create_timer(body_explosion.get_max_lifetime()).timeout
	if _alive and _damage_taken_since_last_state_transition > retreat_damage_threshold:
		if _state == State.ATTACK:
			if _get_best_retreat_location():
				_transition_to_retreat_state()
			else:
				_transition_to_attack_state()
		if _state == State.RETREAT:
			var d := global_position.distance_to(
				global.get_player().global_position
			)
			var close := d < _navigation_agent.target_desired_distance
			if close:
				_transition_to_attack_state()


func _update_navigation(delta: float) -> void:
	if not _alive:
		return

	var query := PhysicsRayQueryParameters3D.new()
	query.from = _eye.global_position
	query.to = global.get_player().global_position
	query.exclude = [get_rid()]
	var collision := get_world_3d().direct_space_state.intersect_ray(query)
	var can_see_player := (
		collision and collision.collider is KinematicFpsController
	)

	if _state == State.IDLE and can_see_player:
		_transition_to_attack_state()
	if (
		_state == State.RETREAT
		and can_see_player
		and Util.get_ticks_sec() - _last_state_transition_at
			> min_retreat_duration
	):
		_transition_to_attack_state()
	if (
		_state == State.RETREAT
		and not can_see_player
		and Util.get_ticks_sec() - _last_state_transition_at
			> min_retreat_duration
	):
		_transition_to_idle_state()
	if (
		_state == State.RETREAT and _navigation_agent.is_navigation_finished()
	):
		_transition_to_idle_state()
	if (
		_state == State.RETREAT
		and _navigation_agent.is_navigation_finished()
		and can_see_player
	):
		if _get_best_retreat_location():
			_navigation_agent.set_target_position(
				_get_best_retreat_location().global_position
			)
		else:
			_transition_to_attack_state()
	if not _navigation_agent.is_navigation_finished() and (not can_see_player or global_position.distance_to(global.get_player().global_position) > 2.0):
		var dir := global_position.direction_to(
			_navigation_agent.get_next_path_position()
		)
		velocity = lerp(
			velocity, dir * movement_speed, delta * acceleration_speed
		)
		scale = Vector3.ONE
		move_and_slide()
	for i in get_slide_collision_count():
		if (
			get_slide_collision(i).get_collider() is KinematicFpsController
			and _state != State.ATTACK
		):
			_transition_to_attack_state()
	get_tree().get_first_node_in_group("debug_sphere").global_position = (
		_navigation_agent.target_position
	)


func _update_rotation(delta: float) -> void:
	var v: Vector3 = global.get_player().global_position - global_position
	rotation.y = lerp_angle(
		rotation.y, atan2(v.x, v.z), delta * acceleration_speed
	)


func _update_eye() -> void:
	var dir := _eye.global_position.direction_to(
		get_viewport().get_camera_3d().global_position
	)
	_eye.basis = Basis.looking_at(
		global_basis.transposed() * dir, Vector3.UP, true
	)
	_eye.position.x = _initial_eye_position.x - 0.02 * sin(4.0 * _animation_time)
	_eye.position.y = _initial_eye_position.y - 0.06 * sin(5.0 * _animation_time + 1.0)
	_eye.position.z = _initial_eye_position.z - 0.02 * sin(6.0 * _animation_time + 2.0)


func _update_eye_cover() -> void:
	_eye_cover.position.x = 0.05 * sin(4.0 * _animation_time)
	_eye_cover.position.y = 0.05 * sin(5.0 * _animation_time + 1.0)
	_eye_cover.position.z = 0.05 * sin(6.0 * _animation_time + 2.0)
	_eye_cover.rotation.x = TAU / 4.0 + 0.1 * TAU * sin(2.0 * _animation_time)
	_eye_cover.rotation.y = 0.1 * TAU * sin(3.0 * _animation_time + 1.0)


func _update_body(delta: float) -> void:
	var mesh: QuadMesh = _body.mesh
	var material: ShaderMaterial = mesh.material
	material.set_shader_parameter("health", _health / max_health)
	material.set_shader_parameter("time", _animation_time)
	if _shrinking:
		mesh.size -= 2.0 * mesh.size * delta
		if mesh.size.x < 0.0 or mesh.size.y < 0.0:
			mesh.size = Vector2.ZERO


func _update_attack(delta: float) -> void:
	if not _alive:
		return
	# TODO: change to shapecast
	var query := PhysicsRayQueryParameters3D.new()
	query.from = global_position + Vector3.UP
	var max_attack_range := 2.0
	query.to = global.get_player().global_position
	query.exclude = [get_rid()]
	var collision := get_world_3d().direct_space_state.intersect_ray(query)
	var attack_cooldown := 0.5
	var can_attack := (
		collision
		and collision.collider is KinematicFpsController
		and query.from.distance_to(collision.position) <= max_attack_range
		and Util.get_ticks_sec() - _last_attack_at > attack_cooldown
	)
	if can_attack:
		_last_attack_at = Util.get_ticks_sec()
		var target := (
			_initial_body_position
			+ (
				_body.global_transform.inverse()
				* get_viewport().get_camera_3d().global_position
				/ 2.0
			)
		)
		get_tree().create_timer(attack_cooldown * 0.1).timeout.connect(func():
			global.get_player().damage(5.0)
		)
		var tween = create_tween()
		(tween
			.tween_property(
				_body,
				"position",
				target, attack_cooldown * 0.25
			)
			.set_trans(Tween.TRANS_ELASTIC)
		)
		(tween
			.tween_property(
				_body,
				"position",
				_initial_body_position, attack_cooldown * 0.75
			)
			.set_trans(Tween.TRANS_SPRING)
			.set_ease(Tween.EASE_OUT)
		)


func _get_best_retreat_location() -> Node3D:
	var target: Node3D = null
	for node: Node3D in get_tree().get_nodes_in_group("retreat_locations"):
		if not target:
			if _get_retreat_position_score(node.global_position) > 0.0:
				target = node
		elif (
			_get_retreat_position_score(node.global_position)
			> _get_retreat_position_score(target.global_position)
		):
			target = node
	return target


func _get_retreat_position_score(point: Vector3) -> float:
	var query := PhysicsRayQueryParameters3D.new()
	query.from = point + Vector3.UP * 1.0
	query.to = global.get_player().global_position
	query.exclude = [get_rid()]
	var collision := get_world_3d().direct_space_state.intersect_ray(query)
	var can_see_player := (
		collision and collision.collider is KinematicFpsController
	)
	if can_see_player:
		return 0.0
	var alignment := (
		global_position
			.direction_to(global.get_player().global_position)
			.dot(global_position.direction_to(point))
	)
	return 1.0 - alignment


func _transition_to_attack_state() -> void:
	_state = State.ATTACK
	_last_state_transition_at = Util.get_ticks_sec()
	_damage_taken_since_last_state_transition = 0.0
	_navigation_agent.set_target_position(global.get_player().global_position)


func _transition_to_idle_state() -> void:
	_state = State.IDLE
	_last_state_transition_at = Util.get_ticks_sec()
	_damage_taken_since_last_state_transition = 0.0


func _transition_to_retreat_state() -> void:
	_state = State.RETREAT
	_last_state_transition_at = Util.get_ticks_sec()
	_damage_taken_since_last_state_transition = 0.0
	_navigation_agent.set_target_position(
		_get_best_retreat_location().global_position
	)

extends CharacterBody3D
class_name Enemy

enum State { IDLE, ATTACK, RETREAT }

var min_retreat_duration := 5.0
var movement_speed := 3.0
var retreat_damage_threshold := 10.0
var acceleration_speed := 4.0
var max_health := 100.0
var _state := State.IDLE
var _damage_taken_since_last_state_transition := 0.0
var _last_state_transition_at := -1000.0
@onready var _health := max_health
@onready var _navigation_agent: NavigationAgent3D = %NavigationAgent3D
@onready var _eye: Node3D = %Eye
@onready var _iris: Node3D = %Iris


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
	if not _navigation_agent.is_navigation_finished():
		var dir := global_position.direction_to(
			_navigation_agent.get_next_path_position()
		)
		velocity = lerp(
			velocity, dir * movement_speed, delta * acceleration_speed
		)
		move_and_slide()
	for i in get_slide_collision_count():
		if (
			get_slide_collision(i).get_collider() is KinematicFpsController
			and _state != State.ATTACK
		):
			_transition_to_attack_state()
	var v: Vector3 = global.get_player().global_position - global_position
	rotation.y = lerp_angle(
		rotation.y, atan2(v.x, v.z), delta * acceleration_speed
	)
	_update_eye()

	get_tree().get_first_node_in_group("debug_sphere").global_position = (
		_navigation_agent.target_position
	)


func damage(amount: float) -> void:
	_health -= amount
	_damage_taken_since_last_state_transition += amount
	if _health < 0.0:
		_health = 0.0
	if _damage_taken_since_last_state_transition > retreat_damage_threshold:
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


func _update_eye() -> void:
	var dir := _eye.global_position.direction_to(
		get_viewport().get_camera_3d().global_position
	)
	_eye.basis = Basis.looking_at(
		global_basis.transposed() * dir, Vector3.UP, true
	)
	_iris.scale.x = _health / max_health
	_iris.scale.y = _health / max_health


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

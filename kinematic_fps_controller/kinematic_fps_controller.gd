extends CharacterBody3D
class_name KinematicFpsController

enum WeaponType { GUN, GRENADE, BANDAGES }

@export var melee_duration := 0.4
@export var melee_range := 2.0
@export var thrown_grenade_scene: PackedScene
@export var fire_rate := 11.0
@export var max_bullet_range := 1000.0
@export var max_grab_range := 3.0
@export var goo_bullet_impact_scene: PackedScene
@export var default_bullet_impact_scene: PackedScene
@export var tracer_scene: PackedScene
@export var bullet_start_margin := 0.0
@export var muzzle_flash_alpha_curve: Curve
@export var muzzle_flash_lifetime := 0.05
@export var smoke_lifetime := 0.3
@export var back_speed := 0.6
@export var max_health := 100.0
@export var weapon_linear_pid_kp := 1.0
@export var weapon_linear_pid_kd := 1.0
@export var weapon_angular_pid_kp := 1.0
@export var weapon_angular_pid_kd := 1.0
@export var camera_linear_pid_kp := 1.0
@export var camera_linear_pid_kd := 1.0
@export var camera_angular_pid_kp := 1.0
@export var camera_angular_pid_kd := 1.0
@export var sprint_seconds := 3.0
@export var sprint_regen_time := 6.0
var sprint_energy := 1.0
var _switching_weapon := false
var _last_sprint_cooldown_at := -1000.0
var _camera_linear_velocity := Vector3.ZERO
var _camera_angular_velocity := Vector3.ZERO
var _weapon_linear_velocity := Vector3.ZERO
var _weapon_angular_velocity := Vector3.ZERO
var _last_camera_position := Vector3.ZERO
var _last_camera_rotation := Vector3.ZERO
var _weapon_type: WeaponType = WeaponType.GUN
var _grenade_throw_cooldown_remaining := 0.0
var _bandages_cooldown_remaining := 0.0
var _grenade_count := 0
var _gun_ammo_in_magazine := 31
var _gun_ammo_in_inventory := 0
var _bandages_in_inventory := 0
var _reloading_gun := false
var _aiming_at_grabbable: Grabbable = null
var _grabbing: Grabbable = null
var _last_melee_at := -1000.0
var _has_melee_applied_damage := false
@onready var _health := max_health
@onready var _weapon: Node3D = %Weapon
@onready var _gun: Node3D = %Gun
@onready var _grenade: Node3D = %Grenade
@onready var _bandages: Node3D = %Bandages
@onready var _center: Node3D = %Center
@onready var _target_weapon_position: Vector3 = _weapon.position
@onready var _target_weapon_rotation: Vector3 = _weapon.rotation
@onready var _initial_weapon_position: Vector3 = _weapon.position
@onready var _initial_weapon_rotation: Vector3 = _weapon.rotation
@onready var _weapon_last_position := _target_weapon_position
@onready var _weapon_last_rotation := _target_weapon_rotation

@export_group("Audio")

@export var material_audios: Array[MaterialAudio]

@export var water_material_audio: MaterialAudio

@export var crouch_audios: Array[AudioStream] = []

@export var uncrouch_audios: Array[AudioStream] = []

@export_group("FOV")

## Speed at which the FOV changes
@export var fov_change_speed := 20.0

## FOV to be multiplied when active the crouch
@export var crouch_fov_multiplier := 0.99

## FOV multiplier applied at max speed
@export var max_speed_fov_multiplier := 1.01

@export_group("Mouse")

## Mouse Sensitivity
@export var mouse_sensitivity := 8.0

## Maximum vertical angle the head can aim
@export var vertical_angle_limit := TAU * 0.24

@export_group("Head Bob")

## Enables bob for made steps
@export var step_bob_enabled := true

## Difference of step bob movement between vertical and horizontal angle
@export var vertical_horizontal_ratio = 2.0

@export var head_bob_x_curve : Curve

@export var head_bob_y_curve : Curve

@export var head_bob_curve_multiplier := Vector2(2,2)

## Maximum range value of headbob
@export var head_bob_range := Vector2(0.07, 0.07)

@export_group("Quake Camera Tilt")

## Enables camera angle for the direction the character controller moves
@export var quake_camera_tilt_enabled := true

## Speed at which the camera angle moves
@export var quake_camera_tilt_speed := 0.1

## Rotation angle limit per move
@export var quake_camera_tilt_angle_limit := 0.007

@export_group("Movement")

## Controller Gravity Multiplier
## The higher the number, the faster the controller will fall to the ground and 
## your jump will be shorter.
@export var gravity_multiplier := 3.0

## Controller base speed
## Note: this speed is used as a basis for abilities to multiply their 
## respective values, changing it will have consequences on [b]all
## abilities[/b] that use velocity.
@export var base_speed := 10.0

@export_group("Walk")

## Time for the character to reach full speed
@export var walk_acceleration := 8.0

## Time for the character to stop walking
@export var walk_deceleration := 10.0

## Sets control in the air
@export var air_control := 0.3

@export_group("Sprint")

## Speed to be multiplied when active the ability
@export var sprint_speed_multiplier := 1.6

@export_group("Footsteps")

## Maximum counter value to be computed one step
@export var step_lengthen := 0.7

## Value to be added to compute a step, each frame that the character is
## walking this value is added to a counter
@export var step_interval := 6.0

@export_group("Crouch")

## Collider height when crouch actived
@export var height_in_crouch := 1.0

## Speed multiplier when crouch is actived
@export var crouch_speed_multiplier := 0.7

@export_group("Jump")

## Jump/Impulse height
@export var jump_height := 10.0

@export_group("Fly")

## Speed multiplier when fly mode is actived
@export var fly_mode_speed_modifier := 2.0

@export_group("Swim")

## Minimum height for [CharacterController3D] to be completely submerged in
## water.
@export var submerged_height := 0.36

## Minimum height for [CharacterController3D] to be float in water.
@export var floating_height := 0.75

## Speed multiplier when floating water
@export var on_water_speed_multiplier := 0.75

## Speed multiplier when submerged water
@export var submerged_speed_multiplier := 0.5

@export var underwater_env: Environment

var _gun_last_fired_at := -1000.0
var _step_cycle := 0.0
var _is_flying := false
var _last_is_on_water := false
var _last_is_floating := false
var _last_is_submerged := false
var _last_is_on_floor := false
var _head_bob_cycle_position := Vector2.ZERO
var _quake_camera_tilt_ratio := 0.0

@onready var _head: Node3D = $Head
@onready var _camera: Camera3D =  $Head/Camera3D
@onready var _collision: CollisionShape3D = $CollisionShape3D
@onready var _capsule: CapsuleShape3D = _collision.shape
@onready var _head_ray_cast: RayCast3D = $HeadRayCast
@onready var _step_audio_stream_player: AudioStreamPlayer3D = (
	$StepAudioStreamPlayer
)
@onready var _land_audio_stream_player: AudioStreamPlayer3D = (
	$LandAudioStreamPlayer
)
@onready var _jump_audio_stream_player: AudioStreamPlayer3D = (
	$JumpAudioStreamPlayer
)
@onready var _crouch_audio_stream_player: AudioStreamPlayer3D = (
	$CrouchAudioStreamPlayer
)
@onready var _uncrouch_audio_stream_player: AudioStreamPlayer3D = (
	$UncrouchAudioStreamPlayer
)
@onready var _ground_ray_cast: RayCast3D = $GroundRayCast
@onready var _swim_ray_cast: RayCast3D = $SwimRayCast
@onready var _initial_fov := _camera.fov
@onready var _initial_capsule_height = _capsule.height
@onready var _bullet_start: Node3D = %BulletStart
@onready var _smoke: GPUParticles3D = %Smoke
@onready var _muzzle_flashes: Array[MeshInstance3D] = [
	%MuzzleFlash1, %MuzzleFlash2, %MuzzleFlash3,
]


func _ready() -> void:
	_smoke.emitting = false
	_update_muzzle_flash()


func _physics_process(delta: float) -> void:
	_update_movement(delta)
	_update_gun_shooting(delta)
	_update_grenade(delta)
	_update_bandages(delta)
	_update_weapon_linear_velocity(delta)
	_update_weapon_angular_velocity(delta)
	# _camera.position = _get_step_bob_camera_offset() + _camera_kick_offset
	var camera_linear_velocity := (
		_last_camera_position - _camera.position
	) / delta
	_weapon_linear_velocity += Vector3(
		0.1 * camera_linear_velocity.x,
		0.1 * camera_linear_velocity.y,
		0.0 * camera_linear_velocity.length(),
	)
	_weapon_angular_velocity += Vector3(
		0.3 * camera_linear_velocity.y,
		0.9 * camera_linear_velocity.x,
		0.0
	)
	global.get_blood_overlay().strength = lerp(
		global.get_blood_overlay().strength,
		1.0 - _health / max_health,
		delta * 2.0
	)
	_update_camera_linear_velocity(delta)
	_update_camera_angular_velocity(delta)
	_update_grabbing(delta)
	_update_melee()


func _input(event: InputEvent) -> void:
	if not Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventKey and OS.is_debug_build():
		var e: InputEventKey = event
		if e.keycode == KEY_L and e.pressed:
			damage(1.0)
	if event is InputEventMouseMotion:
		var e: InputEventMouseMotion = event
		var s: float = mouse_sensitivity / 1000.0 * global.mouse_sensitivity
		var i := -1.0 if global.invert_mouse else 1.0
		var a := 1.0 if _health > 0.0 else 0.1
		var last_x := _head.rotation.x
		var last_y := rotation.y
		rotation.y -= e.relative.x * s * a
		_head.rotation.x = clamp(
			_head.rotation.x - e.relative.y * s * i * a,
			-vertical_angle_limit,
			vertical_angle_limit
		)
		var dx := angle_difference(_head.rotation.x, last_x)
		var dy := angle_difference(rotation.y, last_y)
		_weapon_linear_velocity += Vector3(-dy, dx, 0.0)
		_weapon_angular_velocity += Vector3(dx, dy, 0.0)

	if event.is_action_pressed("move_crouch"):
		_crouch_audio_stream_player.stream = crouch_audios.pick_random()
		_crouch_audio_stream_player.play()
	if event.is_action_released("move_crouch"):
		_uncrouch_audio_stream_player.stream = uncrouch_audios.pick_random()
		_uncrouch_audio_stream_player.play()
	if (
		event.is_action_pressed("select_weapon_1")
		and not _is_reloading()
		and not _switching_weapon
		and _weapon_type != WeaponType.GUN
		and not _grabbing
	):
		_switching_weapon = true
		await _bring_weapon_down()
		if _health == 0.0:
			return
		_weapon_type = WeaponType.GUN
		_gun.visible = true
		_grenade.visible = false
		_bandages.visible = false
		await _bring_weapon_up()
		if _health == 0.0:
			return
		_switching_weapon = false
	if (
		event.is_action_pressed("select_weapon_2")
		and not _is_reloading()
		and not _switching_weapon
		and _weapon_type != WeaponType.GRENADE
		and _grenade_count > 0
		and not _grabbing
	):
		_switching_weapon = true
		await _bring_weapon_down()
		if _health == 0.0:
			return
		_weapon_type = WeaponType.GRENADE
		_gun.visible = false
		_grenade.visible = true
		_bandages.visible = false
		await _bring_weapon_up()
		if _health == 0.0:
			return
		_switching_weapon = false
	if (
		event.is_action_pressed("select_weapon_3")
		and not _is_reloading()
		and not _switching_weapon
		and _weapon_type != WeaponType.BANDAGES
		and _bandages_in_inventory > 0
		and not _grabbing
	):
		_switching_weapon = true
		await _bring_weapon_down()
		if _health == 0.0:
			return
		_weapon_type = WeaponType.BANDAGES
		_gun.visible = false
		_grenade.visible = false
		_bandages.visible = true
		await _bring_weapon_up()
		if _health == 0.0:
			return
		_switching_weapon = false
	if (
		event.is_action_pressed("reload")
		and not _is_reloading()
		and _weapon_type == WeaponType.GUN
		and _gun_ammo_in_magazine < 31
		and _gun_ammo_in_inventory > 0
		and not _switching_weapon
		and not _grabbing
		and not _reloading_gun
		and not is_meleeing()
	):
		_reloading_gun = true
		await _bring_weapon_down()
		await get_tree().create_timer(1.7).timeout
		if _health == 0.0:
			return
		var target := 30 if _gun_ammo_in_magazine == 0 else 31
		var b := mini(target - _gun_ammo_in_magazine, _gun_ammo_in_inventory)
		_gun_ammo_in_magazine += b
		_gun_ammo_in_inventory -= b
		await _bring_weapon_up()
		if _health == 0.0:
			return
		_reloading_gun = false
	if Input.is_action_pressed("use") and can_grab():
		_grabbing = _aiming_at_grabbable
	if Input.is_action_pressed("melee") and can_melee():
		_last_melee_at = Util.get_ticks_sec()


func _bring_weapon_down() -> void:
		_target_weapon_position = _initial_weapon_position + Vector3.DOWN * 0.5
		_target_weapon_rotation = (
			_initial_weapon_rotation + Vector3(-TAU * 0.05, 0.0, 0.0)
		)
		await get_tree().create_timer(0.3).timeout


func _bring_weapon_up() -> void:
		_target_weapon_position = _initial_weapon_position
		_target_weapon_rotation = _initial_weapon_rotation
		await get_tree().create_timer(0.3).timeout


func _update_movement(delta: float) -> void:
	var input_horizontal := Vector2.ZERO
	var input_vertical := 0.0
	var input_jump := false
	var input_crouch := false
	var input_sprint := false
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and _health > 0.0:
		if Input.is_action_just_pressed("move_fly_mode"):
			_is_flying = not _is_flying
		input_horizontal = Input.get_vector(
			"move_left", "move_right", "move_backward", "move_forward"
		)
		input_vertical = Input.get_axis("move_crouch", "move_jump")
		input_jump = Input.is_action_just_pressed("move_jump")
		input_crouch = Input.is_action_pressed("move_crouch")
		input_sprint = Input.is_action_pressed("move_sprint")

	var is_on_water := _swim_ray_cast.is_colliding()

	var depth_on_water := 2.1
	if is_on_water:
		var point := _swim_ray_cast.get_collision_point()
		depth_on_water = -_swim_ray_cast.to_local(point).y

	var is_jumping := (
		input_jump and is_on_floor() and not _head_ray_cast.is_colliding()
	)

	var is_submerged := (
		depth_on_water < submerged_height and is_on_water and !_is_flying
	)

	var is_floating := (
		depth_on_water < floating_height and is_on_water and !_is_flying
	)

	var is_landed_on_floor_this_frame := (
		not is_floating and is_on_floor() and not _last_is_on_floor
	)

	if is_floating and !_last_is_floating:
		# TODO: play started floating sound
		pass
	elif !is_floating and _last_is_floating:
		# TODO: play stopped floating sound
		pass

	if is_submerged and not _last_is_submerged:
		_camera.environment = underwater_env
	if not is_submerged and _last_is_submerged:
		_camera.environment = null

	var is_walking := not _is_flying and not is_floating

	var is_crouching := (
		input_crouch
		and is_on_floor()
		and not is_floating
		and not is_submerged
		and not _is_flying
	)

	var is_sprinting := (
		input_sprint
		and is_on_floor()
		and  input_horizontal.y >= 0.5
		and !is_crouching
		and not _is_flying
		and not is_floating
		and not is_submerged
		and sprint_energy > 0.0
	)

	var is_entered_water := is_on_water and not _last_is_on_water
	var is_exited_water := not is_on_water and _last_is_on_water

	var speed_multiplier := 1.0
	if is_crouching:
		speed_multiplier *= crouch_speed_multiplier
	if is_sprinting:
		speed_multiplier *= sprint_speed_multiplier
	if _is_flying:
		speed_multiplier *= fly_mode_speed_modifier
	if is_submerged:
		speed_multiplier *= submerged_speed_multiplier
	elif is_floating:
		speed_multiplier *= on_water_speed_multiplier

	var move_speed := base_speed * speed_multiplier

	var input_direction := _get_input_direction(
		input_horizontal, input_vertical, is_floating
	)

	var new_velocity := _get_next_velocity(
		is_jumping,
		is_submerged,
		is_floating,
		is_walking,
		move_speed,
		input_direction,
		depth_on_water,
		delta
	)

	var horizontal_velocity := Vector3(new_velocity.x, 0.0, new_velocity.z)

	var is_shuffling_feet := absf(horizontal_velocity.length()) < 0.1
	var is_stepping := (
		not _is_flying
		and not is_floating
		and not is_submerged
		and not is_shuffling_feet
	)

	var next_step_cycle := _step_cycle
	var is_step_completed := false
	if is_stepping:
		next_step_cycle += (
			(horizontal_velocity.length() + step_lengthen) * delta
		)
		is_step_completed = next_step_cycle > step_interval
		if is_step_completed:
			next_step_cycle -= step_interval
		if is_landed_on_floor_this_frame:
			next_step_cycle = 0.0

	var is_sprint_regen_cooldown := (
		Util.get_ticks_sec() - _last_sprint_cooldown_at < 0.1
	)

	# Calculations happen above, side-effects happen below

	if quake_camera_tilt_enabled and false:
		var target := input_horizontal.x
		var direction := signf(target - _quake_camera_tilt_ratio)
		var new_ratio := (
			_quake_camera_tilt_ratio + quake_camera_tilt_speed * direction
		)
		var new_direction := signf(target - new_ratio)
		if new_direction != direction:
			_quake_camera_tilt_ratio = target
		else:
			_quake_camera_tilt_ratio += quake_camera_tilt_speed * direction
		_camera.rotation.z = lerp(
			-quake_camera_tilt_angle_limit,
			quake_camera_tilt_angle_limit,
			smoothstep(-1.0, 1.0, -_quake_camera_tilt_ratio)
		)

	if is_on_floor():
		var dv := (
			_get_head_bob_curve_tangent()
				* delta
				* horizontal_velocity.length()
				* Vector3(10.0, 5.0, 0.0)
		)
		_camera_linear_velocity += dv * 1.5
		_weapon_angular_velocity += Vector3(dv.y, dv.x, 0.0) * 2.0

	if is_jumping:
		_play_jump_audio(is_on_water, is_landed_on_floor_this_frame)
	if is_landed_on_floor_this_frame or is_entered_water:
		_play_land_audio(is_on_water, is_landed_on_floor_this_frame)
	elif is_exited_water:
		# TODO: this doesn't play
		_play_jump_audio(is_on_water, is_landed_on_floor_this_frame)
	if is_step_completed:
		_play_step_audio(is_on_water, is_landed_on_floor_this_frame)

	_step_cycle = next_step_cycle
	var previous_capsule_height := _capsule.height
	_capsule.height = _get_next_capsule_height(is_crouching, delta)
	_camera.fov = _get_next_camera_fov(new_velocity, is_crouching, delta)
	_head_bob_cycle_position = _get_next_head_bob_cycle_position(
		horizontal_velocity, is_jumping, delta
	)

	if is_crouching:
		var dh := (_capsule.height - previous_capsule_height) * delta
		_weapon_linear_velocity += Vector3(0.0, dh * 100.0, 0.0)
		_weapon_angular_velocity += Vector3(dh * delta * 500.0, 0.0, 0.0)

	if is_sprinting:
		sprint_energy -= delta / sprint_seconds
	elif not is_sprint_regen_cooldown:
		sprint_energy += delta / sprint_regen_time
	if sprint_energy <= 0.0 and input_sprint:
		_last_sprint_cooldown_at = Util.get_ticks_sec()
	sprint_energy = clampf(sprint_energy, 0.0, 1.0)

	velocity = new_velocity
	_last_is_on_water = is_on_water
	_last_is_floating = is_floating
	_last_is_submerged = is_submerged
	_last_is_on_floor = is_on_floor()
	# No idea why but self sometimes gets scaled a little bit sometimes and we
	# have to reset it or else move_and_slide will error
	scale = Vector3.ONE
	move_and_slide()


func _get_next_capsule_height(is_crouching: bool, delta: float) -> float:
	var h := _capsule.height
	if is_crouching:
		h -= delta * 8.0
	elif not _head_ray_cast.is_colliding():
		h += delta * 8.0
	return clampf(h, height_in_crouch, _initial_capsule_height)


func _get_head_bob_curve_tangent() -> Vector3:
	if step_bob_enabled:
		var x_pos := (
			Util.sample_curve_tangent(
				head_bob_x_curve, _head_bob_cycle_position.x
			)
			* head_bob_curve_multiplier.x
			* head_bob_range.x
		)
		var y_pos := (
			Util.sample_curve_tangent(
				head_bob_y_curve, _head_bob_cycle_position.y
			)
			* head_bob_curve_multiplier.y
			* head_bob_range.y
		)
		if is_on_floor():
			return Vector3(x_pos, y_pos, 0.0)
	return Vector3.ZERO


func _get_next_head_bob_cycle_position(
	horizontal_velocity: Vector3, is_jumping: bool, delta: float
) -> Vector2:
	if is_jumping:
		return Vector2.ZERO

	var new_pos := _head_bob_cycle_position

	var head_bob_interval := 2.0 * step_interval
	var tick_speed = (horizontal_velocity.length() * delta) / head_bob_interval
	new_pos.x += tick_speed
	new_pos.y += tick_speed * vertical_horizontal_ratio

	if new_pos.x > 1.0:
		new_pos.x -= 1.0
	if new_pos.y > 1.0:
		new_pos.y -= 1.0
	return new_pos


func _get_input_direction(
	input_horizontal: Vector2, input_vertical: float, is_floating: bool
) -> Vector3:
	var allow_vertical := _is_flying or is_floating
	var aim := _head if allow_vertical else self
	var input_direction := Vector3.ZERO
	if input_horizontal.y >= 0.5:
		input_direction -= aim.global_basis.z
	if input_horizontal.y <= -0.5:
		input_direction += aim.global_basis.z
	if input_horizontal.x <= -0.5:
		input_direction -= aim.global_basis.x
	if input_horizontal.x >= 0.5:
		input_direction += aim.global_basis.x
	if allow_vertical:
		input_direction.y += input_vertical
	return input_direction.normalized()


func _get_material_audio_for_object(object: Object) -> MaterialAudio:
	if object.get("physics_material_override") is PhysicsMaterial:
		var material: PhysicsMaterial = object.physics_material_override
		for m in material_audios:
			if m.physics_material == material:
				return m
	return null


func _get_current_material_audio(
	is_on_water: bool,
	is_landed_on_floor_this_frame: bool
) -> MaterialAudio:
	if is_on_water:
		return water_material_audio
	if is_landed_on_floor_this_frame:
		var k_col = get_last_slide_collision()
		return _get_material_audio_for_object(k_col.get_collider(0))
	if _ground_ray_cast.get_collider():
		return _get_material_audio_for_object(_ground_ray_cast.get_collider())
	return null


func _play_jump_audio(
	is_on_water: bool,
	is_landed_on_floor_this_frame: bool
) -> void:
	var material_audio: MaterialAudio = _get_current_material_audio(
		is_on_water, is_landed_on_floor_this_frame
	)
	if not material_audio:
		return
	_jump_audio_stream_player.stream = material_audio.jump_audio_stream
	_jump_audio_stream_player.play()


func _play_land_audio(
	is_on_water: bool,
	is_landed_on_floor_this_frame: bool
) -> void:
	var material_audio: MaterialAudio = _get_current_material_audio(
		is_on_water, is_landed_on_floor_this_frame
	)
	if not material_audio:
		return
	_land_audio_stream_player.stream = material_audio.landed_audio_stream
	_land_audio_stream_player.play()


func _play_step_audio(
	is_on_water: bool,
	is_landed_on_floor_this_frame: bool
) -> void:
	var material_audio: MaterialAudio = _get_current_material_audio(
		is_on_water, is_landed_on_floor_this_frame
	)
	if not material_audio:
		return
	_step_audio_stream_player.stream = (
		material_audio.step_audio_streams.pick_random()
	)
	_step_audio_stream_player.play()


func _get_next_camera_fov(
	vel: Vector3, is_crouching: bool, delta: float
) -> float:
	var max_locomotion_speed := (
		base_speed * maxf(sprint_speed_multiplier, fly_mode_speed_modifier)
	)
	var a := vel.length() / max_locomotion_speed
	var b := max_speed_fov_multiplier - 1.0
	var target_fov := _initial_fov * (1.0 + a * b)
	if is_crouching:
		target_fov *= crouch_fov_multiplier
	return lerp(_camera.fov, target_fov, delta * fov_change_speed)


func _get_next_velocity(
	is_jumping: bool,
	is_submerged: bool,
	is_floating: bool,
	is_walking: bool,
	move_speed: float,
	input_direction: Vector3,
	depth_on_water: float,
	delta: float
) -> Vector3:
	var vel := velocity

	var is_gravity_applied := (
		not is_jumping
		and not _is_flying
		and not is_submerged
		and not is_floating
	)
	if is_gravity_applied:
		vel.y -= Util.get_default_gravity() * gravity_multiplier * delta

	if is_walking:
		var horizontal_velocity := vel
		horizontal_velocity.y = 0.0

		var is_accelerating := input_direction.dot(horizontal_velocity) > 0.0
		var is_backward := input_direction.dot(global_basis.z) > 0.1
		var back_penalty := (
			back_speed if is_accelerating and  is_backward else 1.0
		)

		var a := walk_acceleration if is_accelerating else walk_deceleration
		if not is_on_floor():
			a *= air_control
		a *= back_penalty

		var target := input_direction * move_speed * back_penalty
		var w := horizontal_velocity.lerp(target, a * delta)

		vel.x = w.x
		vel.z = w.z

	if is_floating:
		var depth := floating_height - depth_on_water
		vel = input_direction * move_speed
#	if depth < 0.1: && !_is_flying:
		if depth < 0.1:
			# Prevent free sea movement from exceeding the water surface
			vel.y = min(vel.y,0)

	if _is_flying:
		vel = input_direction * move_speed

	if is_jumping:
		vel.y = jump_height
	_weapon_angular_velocity += Vector3(
		-vel.y * delta * 10.0,
		0.0,
		0.0,
	)
	return vel


func _update_gun_shooting(delta: float) -> void:
	var fire_bullet := (
		_health > 0.0
		and not _is_reloading()
		and _weapon_type == WeaponType.GUN
		and _gun_ammo_in_magazine > 0
		and not _switching_weapon
		and Input.is_action_pressed("shoot")
		and Util.get_ticks_sec() - _gun_last_fired_at > 1.0 / fire_rate
		and not is_meleeing()
	)
	if fire_bullet:
		_gun_ammo_in_magazine -= 1
		_gun_last_fired_at = Util.get_ticks_sec()
		var query := PhysicsRayQueryParameters3D.new()
		query.collision_mask = (
			Global.PhysicsLayer.DEFAULT | Global.PhysicsLayer.INTERIOR
		)
		query.from = _camera.global_position
		var dir := -_weapon.global_basis.z
		query.to = _camera.global_position + dir * max_bullet_range
		query.exclude = [get_rid()]
		var collision := get_world_3d().direct_space_state.intersect_ray(query)

		var bullet_end: Vector3
		if collision:
			bullet_end = collision.position
		else:
			bullet_end = query.to

		var tracer: Tracer = tracer_scene.instantiate()
		tracer.start = (
			_bullet_start.global_position
			+ velocity * delta
			- _camera.global_basis.z * bullet_start_margin
		)
		tracer.end = bullet_end
		get_parent().add_child(tracer)
		var dlv := Vector3(
			randf_range(-0.1, 0.1),
			randf_range(0.5, 0.6),
			randf_range(0.8, 0.9)
		)
		var dav := Vector3(
			randf_range(-0.1, 3.0),
			randf_range(-3.0, 3.0),
			randf_range(-0.9, 0.9)
		)
		_weapon_linear_velocity += dlv * 0.5
		_weapon_angular_velocity += dav * 0.5
		_camera_linear_velocity += dlv * 1.0 * Vector3(1.0, 1.0, 1.2)
		_camera_angular_velocity += dav * 0.05

		if collision:
			var scene := (
				goo_bullet_impact_scene if collision.collider is Enemy
				else default_bullet_impact_scene
			)
			var impact: GPUParticles3D = scene.instantiate()
			impact.position = collision.position
			impact.one_shot = true
			impact.emitting = true
			get_parent().add_child(impact)

			if collision.collider is Enemy:
				var enemy: Enemy = collision.collider
				enemy.damage(3.0)
	_smoke.emitting = (
		Util.get_ticks_sec() - _gun_last_fired_at < smoke_lifetime
	)
	_update_muzzle_flash()


func _update_grenade(delta: float) -> void:
	if (
		_health == 0.0
		or _weapon_type != WeaponType.GRENADE
		or _switching_weapon
		or is_meleeing()
	):
		return
	if can_throw_grenade() and Input.is_action_pressed("shoot"):
		_grenade_count -= 1
		_grenade_throw_cooldown_remaining = 1.0
		var tg: ThrownGrenade = thrown_grenade_scene.instantiate()
		tg.position = _grenade.global_position - _camera.global_basis.x * 0.1
		tg.linear_velocity += -_camera.global_basis.z * 15.0
		tg.linear_velocity += _camera.global_basis.y * 3.0
		tg.linear_velocity += velocity
		global.get_level().add_child(tg)
		_grenade.visible = false
		_bring_weapon_down()
	if _grenade_throw_cooldown_remaining > 0.0:
		_grenade_throw_cooldown_remaining -= delta
		if _grenade_throw_cooldown_remaining <= 0.0:
			_grenade_throw_cooldown_remaining = 0.0
			if can_throw_grenade():
				_grenade.visible = true
				_bring_weapon_up()


func _update_bandages(delta: float) -> void:
	if (
		_health == 0.0
		or _weapon_type != WeaponType.BANDAGES
		or _switching_weapon
		or is_meleeing()
	):
		return
	if (
		can_use_bandages()
		and Input.is_action_pressed("shoot")
		and _health < max_health
	):
		_bandages_in_inventory -= 1
		_bandages_cooldown_remaining = 1.0
		_bring_weapon_down()
	if _bandages_cooldown_remaining > 0.0:
		_bandages_cooldown_remaining -= delta
		if _bandages_cooldown_remaining <= 0.0:
			_bandages_cooldown_remaining = 0.0
			_health += 50.0
			if _health > max_health:
				_health = max_health
			if can_use_bandages():
				_bandages.visible = true
				_bring_weapon_up()


func _update_weapon_linear_velocity(delta: float) -> void:
	var error := _target_weapon_position - _weapon.position
	var error_delta := (_weapon_last_position - _weapon.position) / delta
	var accel := (
		weapon_linear_pid_kp * error + weapon_linear_pid_kd * error_delta
	)
	_weapon_linear_velocity += accel * delta
	_weapon_linear_velocity = _weapon_linear_velocity.limit_length(7.0)
	_weapon_last_position = _weapon.position
	_weapon.position += _weapon_linear_velocity * delta


func _update_weapon_angular_velocity(delta: float) -> void:
	var error := _target_weapon_rotation - _weapon.rotation
	var error_delta := (_weapon_last_rotation - _weapon.rotation) / delta
	var accel := (
		weapon_angular_pid_kp * error + weapon_angular_pid_kd * error_delta
	)
	_weapon_angular_velocity += accel * delta
	_weapon_angular_velocity = _weapon_angular_velocity
	_weapon_last_rotation = _weapon.rotation
	_weapon.rotation += _weapon_angular_velocity * delta


func _update_camera_linear_velocity(delta: float) -> void:
	var error := -_camera.position
	var error_delta := (_last_camera_position - _camera.position) / delta
	var accel := (
		camera_linear_pid_kp * error + camera_linear_pid_kd * error_delta
	)
	_camera_linear_velocity += accel * delta
	_last_camera_position = _camera.position
	_camera.position += _camera_linear_velocity * delta


func _update_camera_angular_velocity(delta: float) -> void:
	var error := -_camera.rotation
	var error_delta := (_last_camera_rotation - _camera.rotation) / delta
	var accel := (
		camera_angular_pid_kp * error + camera_angular_pid_kd * error_delta
	)
	_camera_angular_velocity += accel * delta
	_last_camera_rotation = _camera.rotation
	_camera.rotation += _camera_angular_velocity * delta


func _update_grabbing(delta: float) -> void:
	var query := PhysicsRayQueryParameters3D.new()
	query.collision_mask = Global.PhysicsLayer.GRABBABLE
	query.from = _camera.global_position
	var dir := -_camera.global_basis.z
	query.to = _camera.global_position + max_grab_range * dir
	query.exclude = [get_rid()]
	var collision := get_world_3d().direct_space_state.intersect_ray(query)
	if collision and collision.collider is Grabbable:
		_aiming_at_grabbable = collision.collider
	else:
		_aiming_at_grabbable = null

	if _grabbing:
		_grabbing.global_position = lerp(
			_grabbing.global_position, global_position, delta * 20.0,
		)
		if _grabbing.global_position.distance_to(global_position) < 0.1:
			if _grabbing.get_type() == Grabbable.Type.AMMO:
				_gun_ammo_in_inventory += 30
			elif _grabbing.get_type() == Grabbable.Type.GRENADE:
				if _weapon_type == WeaponType.GRENADE and _grenade_count == 0:
					_grenade.visible = true
					_bring_weapon_up()
				_grenade_count += 1
			elif _grabbing.get_type() == Grabbable.Type.BANDAGES:
				if (
					_weapon_type == WeaponType.BANDAGES
					and _bandages_in_inventory == 0
				):
					_bandages.visible = true
					_bring_weapon_up()
				_bandages_in_inventory += 1
			else:
				push_error("Impossible state")
			_grabbing.queue_free()
			_grabbing = null


func _update_melee() -> void:
	if _health == 0.0:
		return
	var d := Util.get_ticks_sec() - _last_melee_at
	if d < melee_duration:
		# TODO: a state machine would work better
		_target_weapon_position = _initial_weapon_position
		_target_weapon_position.z += 10.0
		if d > 0.07 and d <= 0.2:
			_target_weapon_position = _initial_weapon_position
			_target_weapon_position.x -= 1.5
			_target_weapon_position.y += 1.4
			_target_weapon_position.z -= 10.0
			_target_weapon_rotation = Vector3(
				0.01 * TAU, 0.05 * TAU, 0.1 * TAU
			)
			if not _has_melee_applied_damage:
				_do_melee_damage()
				_has_melee_applied_damage = true
		if d > 0.2:
			_target_weapon_position = _initial_weapon_position
			_target_weapon_rotation = _initial_weapon_rotation
			_has_melee_applied_damage = false


func _do_melee_damage() -> void:
	var query := PhysicsRayQueryParameters3D.new()
	query.collision_mask = Global.PhysicsLayer.DEFAULT
	query.from = _camera.global_position
	var dir := -_weapon.global_basis.z
	query.to = _camera.global_position + dir * melee_range
	query.exclude = [get_rid()]
	var collision := get_world_3d().direct_space_state.intersect_ray(query)
	if collision and collision.collider is Enemy:
		var enemy: Enemy = collision.collider
		enemy.damage(5.0)
		var scene := (
			goo_bullet_impact_scene if collision.collider is Enemy
			else default_bullet_impact_scene
		)
		var impact: GPUParticles3D = scene.instantiate()
		impact.position = collision.position
		impact.one_shot = true
		impact.emitting = true
		get_parent().add_child(impact)


func _update_muzzle_flash() -> void:
	for muzzle_flash in _muzzle_flashes:
		var material: StandardMaterial3D = muzzle_flash.material_override
		var t := Util.get_ticks_sec()
		var d := t - _gun_last_fired_at
		material.albedo_color.a = (
			muzzle_flash_alpha_curve.sample_baked(d / muzzle_flash_lifetime)
		)


func get_health() -> float:
	return _health


func damage(amount: float) -> void:
	_health -= amount
	_camera_linear_velocity += Vector3(
		randf_range(-5.0, 5.0), randf_range(5.0, 10.0), 0.0
	)
	_camera_angular_velocity += Vector3(
		randf_range(1.0, 2.0), 0.0, 0.0
	)
	if _health <= 0.0:
		_health = 0.0
		_target_weapon_position = _initial_weapon_position + Vector3.DOWN * 0.1
		_target_weapon_rotation = Vector3(-TAU * 0.05, 0.0, 0.0)
		_fade_in_death_overlay()


func _fade_in_death_overlay() -> void:
	var tween := create_tween()
	(
		tween.tween_property(
			global.get_death_overlay(), "modulate:a", 1.0, 10.0
		)
			.set_trans(Tween.TRANS_EXPO)
			.set_ease(Tween.EASE_OUT)
	)


func get_gun_ammo_in_magazine() -> int:
	return _gun_ammo_in_magazine


func get_gun_ammo_in_inventory() -> int:
	return _gun_ammo_in_inventory


func can_throw_grenade() -> bool:
	return (
		_weapon_type == WeaponType.GRENADE
		and not _switching_weapon
		and _grenade_throw_cooldown_remaining == 0.0
		and _grenade_count > 0
	)


func can_use_bandages() -> bool:
	return (
		_weapon_type == WeaponType.BANDAGES
		and not _switching_weapon
		and _bandages_cooldown_remaining == 0.0
		and _bandages_in_inventory > 0
	)


func get_bandages_count() -> int:
	return _bandages_in_inventory


func get_grenade_count() ->	int:
	return _grenade_count


func get_weapon_type() -> WeaponType:
	return _weapon_type


func _is_reloading() -> bool:
	return _reloading_gun or _grenade_throw_cooldown_remaining > 0.0


func can_grab() -> bool:
	return (
		_health > 0.0
		and _aiming_at_grabbable
		and not _switching_weapon
		and not _grabbing
		and not is_meleeing()
	)


func is_switching_weapon() -> bool:
	return _switching_weapon


func can_melee() -> bool:
	return (
		Util.get_ticks_sec() - _last_melee_at > melee_duration
		and _health > 0.0
		and not _switching_weapon
		and not _grabbing 
	)


func is_meleeing() -> bool:
	return Util.get_ticks_sec() - _last_melee_at <= melee_duration


func get_center() -> Vector3:
	return _center.position

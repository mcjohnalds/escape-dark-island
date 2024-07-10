extends Node
class_name Game

signal restarted
signal started_sleeping
signal finished_sleeping

@export var enemy_scene: PackedScene
var _paused := false
var _desired_mouse_mode := Input.MOUSE_MODE_VISIBLE
var _mouse_mode_mismatch_count := 0
var _fuel := 300
@onready var _container: Node3D = $Container
@onready var _main_menu: MainMenu = %MainMenu
@onready var _menu_container = %MenuContainer
@onready var _health_label: Label = %HealthLabel
@onready var _sprint_bar: ColorRect = %SprintBar
@onready var _sprint_bar_initial_size: Vector2 = _sprint_bar.size
@onready var _ammo_label: Label = %AmmoLabel
@onready var _shoot_crosshair: Control = %ShootCrosshair
@onready var _grab_crosshair: Control = %GrabCrosshair
@onready var _gun_icon: ItemIcon = %GunIcon
@onready var _grenade_icon: ItemIcon = %GrenadeIcon
@onready var _bandages_icon: ItemIcon = %BandagesIcon
@onready var _night_vision_shader: Control = %NightVisionShader
@onready var _level: Level = %Level


func _ready() -> void:
	_main_menu.resumed.connect(_unpause)
	_main_menu.restarted.connect(restarted.emit)
	set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	global.get_player().started_sleeping.connect(_on_started_sleeping)
	global.get_player().finished_sleeping.connect(finished_sleeping.emit)
	randomize_level()


func _process(delta: float) -> void:
	# Deal with the bullshit that can happen when the browser takes away the
	# game's pointer lock
	if (
		_desired_mouse_mode == Input.MOUSE_MODE_CAPTURED
		and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED
	):
		_mouse_mode_mismatch_count += 1
	else:
		_mouse_mode_mismatch_count = 0
	if _mouse_mode_mismatch_count > 10:
		_pause()
	_health_label.text = "Health %s%%" % ceil(global.get_player().get_health())
	_update_sprint_bar(delta)
	_update_ammo_label()
	_update_crosshair()
	_update_item_icons()
	var nv: bool = global.get_player().night_vision
	_night_vision_shader.visible = nv
	_level.directional_light.visible = nv
	for light in _level.get_omni_lights():
		light.light_energy = 5.0 if nv else 0.1
	_level.world_environment.environment.fog_enabled = nv
	_level.world_environment.environment.ambient_light_energy = 16.0 if nv else 0.5
	_level.world_environment.environment.background_energy_multiplier = 1.0 if nv else 0.0
	# _level.world_environment.environment.fog_depth_begin = 0 if nv else 10
	# _level.world_environment.environment.fog_depth_curve = 0.07 if nv else 1.0
	# _level.world_environment.environment.background_energy_multiplier = 1.0 if nv else 10000.0
	_level.fuel_indicator_3d.litres = _fuel


func _update_sprint_bar(delta: float) -> void:
	var target := (
		global.get_player().sprint_energy * _sprint_bar_initial_size.x
	)
	if global.get_player().sprint_energy > 0.0:
		_sprint_bar.size.x = lerpf(_sprint_bar.size.x, target, delta * 3.0)
	else:
		_sprint_bar.size.x -= 20.0 * delta
		_sprint_bar.size.x = maxf(_sprint_bar.size.x, 0.0)


func _update_ammo_label() -> void:
	var p := global.get_player()
	match p.get_weapon_type():
		KinematicFpsController.WeaponType.GUN:
			_ammo_label.text = "%s/31 - 5.56 mm" % p.get_gun_ammo_in_magazine()
		KinematicFpsController.WeaponType.GRENADE:
			_ammo_label.text = (
				"%s/1 - Mk 2" % (1 if p.can_throw_grenade() else 0)
			)
		KinematicFpsController.WeaponType.BANDAGES:
			_ammo_label.text = (
				"%s/1 - Bandages" % (1 if p.can_use_bandages() else 0)
			)


func _update_crosshair() -> void:
	var p := global.get_player()
	_shoot_crosshair.visible = (
		not p.is_switching_weapon()
		and not p.is_meleeing()
		and not p.can_use()
	)
	_grab_crosshair.visible = (
		not p.is_switching_weapon()
		and not p.is_meleeing()
		and p.can_use()
	)


func _update_item_icons() -> void:
	var p := global.get_player()
	var gun_ammo := (
		p.get_gun_ammo_in_magazine() + p.get_gun_ammo_in_inventory()
	)
	_gun_icon.text = "%s" % gun_ammo
	_grenade_icon.text = "%s" % p.get_grenade_count()
	_bandages_icon.text = "%s" % p.get_bandages_count()
	var t := p.get_weapon_type()
	_gun_icon.hover = t == KinematicFpsController.WeaponType.GUN
	_grenade_icon.hover = t == KinematicFpsController.WeaponType.GRENADE
	_bandages_icon.hover = t == KinematicFpsController.WeaponType.BANDAGES
	_grenade_icon.disabled = p.get_grenade_count() == 0
	_bandages_icon.disabled = p.get_bandages_count() == 0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _paused:
			# In a browser, we can only capture the mouse on a mouse click
			# event, so we only let the user unpause by clicking the resume
			# buttom
			if OS.get_name() != "Web":
				_unpause()
		else:
			_pause()


func _pause() -> void:
	_paused = true
	_container.process_mode = Node.PROCESS_MODE_DISABLED
	_menu_container.visible = true
	set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _unpause() -> void:
	_paused = false
	_container.process_mode = Node.PROCESS_MODE_INHERIT
	_menu_container.visible = false
	_main_menu.settings_open = false
	set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func set_mouse_mode(mode: Input.MouseMode) -> void:
	_desired_mouse_mode = mode
	Input.mouse_mode = mode


func _spawn_enemy() -> void:
	for enemy: Enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
	var enemy_spawn: Node3D = (
		get_tree().get_nodes_in_group("retreat_locations").pick_random()
	)
	var enemy: Enemy = enemy_scene.instantiate()
	enemy.position = enemy_spawn.global_position
	add_child(enemy)


func _randomize_grabbable_group(
	group_name: String, mean: float, deviation: float
) -> void:
	var grabbables := get_tree().get_nodes_in_group(group_name)
	var random_count := clampi(
		roundi(randfn(mean, deviation)), 1, grabbables.size()
	)
	for i in random_count:
		var j := randi_range(0, grabbables.size() - 1)
		grabbables[j].reset()
		grabbables.remove_at(j)
	for grabbable in grabbables:
		grabbable.disable()


func randomize_level() -> void:
	_spawn_enemy()
	_randomize_grabbable_group("grabbable_ammo", 3.0, 1.0)
	_randomize_grabbable_group("grabbable_grenades", 2.0, 1.0)
	_randomize_grabbable_group("grabbable_bandages", 2.0, 1.0)


func _on_started_sleeping() -> void:
	started_sleeping.emit()
	_fuel -= 20

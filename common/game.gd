extends Node
class_name Game

signal restarted
signal started_sleeping
signal finished_sleeping

@export var fuel_loss_per_second := 0.01
var _paused := false
var _desired_mouse_mode := Input.MOUSE_MODE_VISIBLE
var _mouse_mode_mismatch_count := 0
# var _fuel := 200.0
# var _fuel := 10.0
var _fuel := 0.1
var _player_home_light_energy_level := 1.0
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
@onready var _screen_message: CustomLabel = %ScreenMessage


func _ready() -> void:
	_main_menu.resumed.connect(_unpause)
	_main_menu.restarted.connect(restarted.emit)
	set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	global.get_player().sleep_attemped.connect(_on_sleep_attempted)
	global.get_player().died.connect(_on_died)
	respawn_contents()


func _process(delta: float) -> void:
	_fuel -= delta * fuel_loss_per_second
	if _fuel < 0.0:
		_fuel = 0.0
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
	_level.get_directional_light().visible = nv
	for light in _level.get_omni_lights():
		if _fuel == 0.0:
			_player_home_light_energy_level = lerpf(
				_player_home_light_energy_level, 0.0, delta * 5.0
			)
		light.light_energy = (
			(5.0 if nv else 0.1) * _player_home_light_energy_level
		)
		_level.get_light_mesh_material().emission_energy_multiplier = (
			_player_home_light_energy_level
		)
	var env := get_viewport().world_3d.environment
	env.fog_enabled = nv
	env.ambient_light_energy = 16.0 if nv else 0.5
	env.background_energy_multiplier = 1.0 if nv else 0.0
	_level.get_fuel_indicator_3d().litres = _fuel


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
		p.get_health() > 0.0
		and not _screen_message.visible
		and not p.is_switching_weapon()
		and not p.is_meleeing()
		and not p.can_use()
	)
	_grab_crosshair.visible = (
		p.get_health() > 0.0
		and not _screen_message.visible
		and not p.is_switching_weapon()
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
	_level.process_mode = Node.PROCESS_MODE_DISABLED
	_menu_container.visible = true
	set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _unpause() -> void:
	_paused = false
	_level.process_mode = Node.PROCESS_MODE_INHERIT
	_menu_container.visible = false
	_main_menu.settings_open = false
	set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func set_mouse_mode(mode: Input.MouseMode) -> void:
	_desired_mouse_mode = mode
	Input.mouse_mode = mode


func _on_sleep_attempted() -> void:
	global.get_player().start_sleeping()
	started_sleeping.emit()
	_fuel -= 20.0
	if _fuel < 0.0:
		_fuel = 0.0
	respawn_contents()
	await get_tree().create_timer(1.0).timeout
	global.get_player().night_vision = _fuel == 0.0
	global.get_player().stop_sleeping()
	finished_sleeping.emit()


func _on_died() -> void:
	global.get_player().start_sleeping()
	started_sleeping.emit()
	_fuel -= 20.0
	if _fuel < 0.0:
		_fuel = 0.0
	respawn_contents()
	global.get_player().respawn()
	await get_tree().create_timer(1.0).timeout
	global.get_player().night_vision = _fuel == 0.0
	global.get_player().stop_sleeping()
	finished_sleeping.emit()


func _display_screen_message(text: String) -> void:
	_screen_message.text = text
	_screen_message.visible = true
	await get_tree().create_timer(3.0).timeout
	_screen_message.visible = false


func respawn_contents() -> void:
	_level.get_enemy_building().respawn_enemy()
	_level.get_enemy_building().respawn_grabbables()
	if _fuel == 0.0:
		_level.get_player_home().respawn_enemy()

extends Node
class_name Game

signal restarted

var _paused := false
var _desired_mouse_mode := Input.MOUSE_MODE_VISIBLE
var _mouse_mode_mismatch_count := 0
@onready var _container: Node3D = $Container
@onready var _main_menu: MainMenu = %MainMenu
@onready var _menu_container = %MenuContainer
@onready var _health_label: Label = %HealthLabel
@onready var _sprint_bar: ColorRect = %SprintBar
@onready var _sprint_bar_initial_size: Vector2 = _sprint_bar.size
@onready var _ammo_label: Label = %AmmoLabel
@onready var _shoot_crosshair: Control = %ShootCrosshair
@onready var _grab_crosshair: Control = %GrabCrosshair


func _ready() -> void:
	_main_menu.resumed.connect(_unpause)
	_main_menu.restarted.connect(restarted.emit)
	set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


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
	_shoot_crosshair.visible = not global.get_player().can_grab()
	_grab_crosshair.visible = global.get_player().can_grab()


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
			_ammo_label.text = (
				"%s/%s - 5.56 mm"
				% [
					p.get_gun_ammo_in_magazine(),
					p.get_gun_ammo_in_inventory()
				]
			)
		KinematicFpsController.WeaponType.GRENADE:
			var a := 1 if p.can_throw_grenade() else 0
			_ammo_label.text = (
				"%s/%s - Mk 2"
				% [
					a,
					maxf(p.get_grenade_count() - a, 0)
				]
			)
		KinematicFpsController.WeaponType.BANDAGES:
			var a := 1 if p.can_use_bandages() else 0
			_ammo_label.text = (
				"%s/%s - Bandages"
				% [
					a,
					maxf(p.get_bandages_count() - a, 0)
				]
			)


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

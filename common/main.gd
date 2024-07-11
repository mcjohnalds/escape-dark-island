extends Node
class_name Main

const _FADE_DURATION = 0.15
@export var loader_scene: PackedScene
@export var start_scene: PackedScene
@export var game_scene: PackedScene
var _game: Game
@onready var _container: Node = %Container
@onready var _fps_counter: Label = %FpsCounter
@onready var _transition: ColorRect = %Transition


func _ready() -> void:
	if not OS.is_debug_build():
		var loader: Loader = loader_scene.instantiate()
		_container.add_child(loader)
		await loader.compile_shaders()
		await _fade_out()
		loader.queue_free()
		await loader.tree_exited
	var start: Start = start_scene.instantiate()
	_container.add_child(start)
	await _fade_in()
	if not OS.is_debug_build():
		await start.main_menu.started
		await _fade_out()
	start.queue_free()
	await start.tree_exited
	_restart()


func _process(_delta: float) -> void:
	_fps_counter.text = "%s FPS " % Engine.get_frames_per_second()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fps_counter"):
		_fps_counter.visible = not _fps_counter.visible


func _restart() -> void:
	if _game:
		await _fade_out()
		_game.queue_free()
		await _game.tree_exited
	_game = game_scene.instantiate()
	_container.add_child(_game)
	_game.restarted.connect(_restart)
	_game.started_sleeping.connect(_on_started_sleeping)
	_game.finished_sleeping.connect(_fade_in)
	await _fade_in()


func _fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(_transition, "color:a", 1.0, _FADE_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await tween.finished


func _fade_in() -> void:
	_transition.color.a = 1.0
	var tween := create_tween()
	tween.tween_property(_transition, "color:a", 0.0, _FADE_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await tween.finished


func _on_started_sleeping() -> void:
	await _fade_out()
	_game.respawn_contents()

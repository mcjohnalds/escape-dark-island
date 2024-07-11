extends Control
class_name FuelIndicator2D


@export var litres := 300.01:
	set(value):
		litres = value
		if not is_node_ready():
			await ready
		_number.text = "%.2f" % litres


@onready var _number: Label = %Number


func _ready() -> void:
	while true:
		if litres == 0.0:
			_number.visible = not _number.visible
		else:
			_number.visible = true
		await get_tree().create_timer(1.0).timeout

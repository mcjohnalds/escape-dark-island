extends Control
class_name FuelIndicator2D


@export var litres := 300.01:
	set(value):
		litres = value
		if not is_node_ready():
			await ready
		_number.text = "%.2f" % litres


@onready var _number: Label = %Number

extends Node3D
class_name FuelIndicator3D


@export var litres := 300.0:
	set(value):
		litres = value
		if not is_node_ready():
			await ready
		_2d.litres = litres


@onready var _2d: FuelIndicator2D = %FuelIndicator2D

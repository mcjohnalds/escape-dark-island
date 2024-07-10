extends Control
class_name FuelIndicator2D


@export var litres := 300:
	set(value):
		litres = value
		if not is_node_ready():
			await ready
		_body.text = "%s LITRES" % litres


@onready var _body: Label = %Body

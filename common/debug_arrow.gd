@tool
class_name DebugArrow
extends Node3D


@export var material: Material:
	set(value):
		material = value
		if not is_node_ready():
			await ready
		_line.material_override = material
		_tip.material_override = material


@export var color: Color = Color("ffffff"):
	set(value):
		color = value
		if not is_node_ready():
			await ready
		if material:
			material.albedo_color = color


@export var vector: Vector3:
	set(value):
		vector = value
		if not is_node_ready():
			await ready
		Util.safe_look_at(self, global_position + value, true)
		scale.z = value.length()


@onready var _line: MeshInstance3D = %Line
@onready var _tip: MeshInstance3D = %Tip


func _ready() -> void:
	color = color
	vector = vector

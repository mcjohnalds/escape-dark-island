@tool
extends TextureRect
class_name BloodOverlay


@export_range(0.0, 1.0) var strength := 0.0:
	set(value):
		strength = value
		if not is_node_ready():
			await ready
		size = get_parent().size * remap(strength, 0.0, 1.0, 1.5, 1.0)
		position = get_parent().size / 2.0 - size / 2.0
		modulate.a = strength

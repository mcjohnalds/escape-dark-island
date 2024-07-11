@tool
extends Label
class_name CustomLabel

enum Type { BODY_MEDIUM, HEADER_SMALL, HEADER_MEDIUM, HEADER_LARGE, TITLE }


@export var type := Type.BODY_MEDIUM:
	set(value):
		type = value
		if not is_node_ready():
			await ready
		var font: Font
		var font_size: int
		match type:
			Type.BODY_MEDIUM:
				font = default_font
				font_size = 16
			Type.HEADER_SMALL:
				font = header_font
				font_size = 20
			Type.HEADER_MEDIUM:
				font = header_font
				font_size = 24
			Type.HEADER_LARGE:
				font = header_font
				font_size = 28
			Type.TITLE:
				font = title_font
				font_size = 32
		add_theme_font_override("font", font)
		add_theme_font_size_override("font_size", font_size)


@export var outline := false:
	set(value):
		outline = value
		if not is_node_ready():
			await ready
		_outline.visible = outline


@export var default_font: Font
@export var header_font: Font
@export var title_font: Font
@onready var _outline: Label = $Outline


func _ready() -> void:
	_outline.text = text
	type = type

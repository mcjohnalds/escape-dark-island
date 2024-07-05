class_name CustomParticles
extends GPUParticles3D

@export var free_after_lifetime := false


func _init() -> void:
	global.graphics_preset_changed.connect(_update)
	_update()


func _ready() -> void:
	if free_after_lifetime:
		await get_tree().create_timer(lifetime).timeout
		queue_free()


func _update() -> void:
	if global.get_graphics_preset() == Global.GraphicsPreset.LOW:
		amount = maxi(amount / 2, 1)
	if global.get_graphics_preset() >= Global.GraphicsPreset.HIGH:
		if draw_pass_1 is QuadMesh:
			var mesh: QuadMesh = draw_pass_1
			if mesh.material is StandardMaterial3D:
				var mat: StandardMaterial3D = mesh.material
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if global.get_graphics_preset() == Global.GraphicsPreset.INSANE:
		amount = amount * 2

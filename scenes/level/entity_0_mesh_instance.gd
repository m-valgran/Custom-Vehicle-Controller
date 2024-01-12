@tool
extends MeshInstance3D

func _ready() -> void:
	for index in mesh.get_surface_count():
		var material := mesh.surface_get_material(index)
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		material.metallic_specular = 0

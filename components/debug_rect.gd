extends ColorRect

func _ready() -> void:
	add_to_group("DebugRects")
	update_visibility()

func update_visibility() -> void:
	visible = Global.DEBUG_MODE

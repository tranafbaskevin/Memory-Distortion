extends CanvasLayer

@onready var label = get_node_or_null("Control/Label")

func _ready() -> void:
	add_to_group("DebugRects")
	update_visibility()

func _process(_delta: float) -> void:
	if not visible or not label:
		return
		
	label.text = "=== DEBUG INTERFACE (F3) ===\n" \
		+ "Fear Level: " + str(Global.fear_level) + " / 5\n" \
		+ "Acceptance: " + str(Global.truth_acceptance_level) + " / 5\n" \
		+ "Denial Level: " + str(Global.denial_level) + " / 5\n" \
		+ "Loop Depth: " + str(Global.loop_depth)

func update_visibility() -> void:
	visible = Global.DEBUG_MODE

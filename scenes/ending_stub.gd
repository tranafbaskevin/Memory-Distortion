## ending_stub.tscn — Scene tạm thời khi Player dùng chìa khoá thoát nhà
## Phase sau sẽ thay bằng ending thật với cutscene
extends Node2D

func _ready() -> void:
	Vignette.show_vignette(0.0, 0.0)
	Narrative.show_message("...", 2.0)
	await get_tree().create_timer(2.5).timeout
	Narrative.show_message("Cánh cửa mở ra.", 2.5)
	await get_tree().create_timer(3.0).timeout
	Narrative.show_message("Phía ngoài... tối tăm hơn tớ tưởng.", 3.5)
	await get_tree().create_timer(4.0).timeout
	Narrative.show_message("[ Hết demo — Phase 5 ]", 5.0)

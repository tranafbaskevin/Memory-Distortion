## Hệ thống bếp nhiều trạng thái — Environmental Storytelling
## Cải tiến theo pacing của DistortionController (Tier 0 -> Tier 1 -> Tier 2+)
extends Node2D

@onready var chair = $Chair
@onready var light_node = $KitchenLight
@onready var player = $Player

const SCENE_ID = "kitchen"

func _ready() -> void:
	var title_label = get_node_or_null("RoomTitleOverlay/TitleLabel")
	if title_label:
		title_label.text = "PHÒNG BẾP"

	# Ghi nhận lượt vào phòng
	if not Global.room_visits.has(SCENE_ID):
		Global.room_visits[SCENE_ID] = 0
	Global.room_visits[SCENE_ID] += 1
	
	var visit = Global.room_visits[SCENE_ID]
	var tier = DistortionController.current_tier
	print("[Kitchen] Visit #", visit, " | Tier: ", tier)
	
	# Phát ambient dựa trên scene path và level distortion
	AudioManager.play_ambient_for_scene(scene_file_path, tier >= 3)
	
	_apply_state(tier)

func _apply_state(tier: int) -> void:
	if tier == 0:
		# Tier 0: bình thường hoàn toàn
		Narrative.show_message("Căn bếp vắng lặng. Mùi cơm nguội vẫn còn lảng vảng đâu đây.", 4.0)
	elif tier == 1:
		# Tier 1: cái ghế lệch sang một chút
		if chair:
			chair.position += Vector2(25, 15)
			chair.rotation_degrees = 8.0
		Narrative.show_message("Cái ghế... hình như đã bị ai đó đẩy ra.", 3.5)
	else:
		# Tier 2+: ghế lệch nhiều, đèn mờ nhấp nháy, camera drift
		if chair:
			chair.position += Vector2(65, 30)
			chair.rotation_degrees = 22.0
		if light_node:
			# Giảm năng lượng đèn tạo cảm giác tối hơn
			light_node.energy = 0.3
			light_node.color = Color(0.65, 0.5, 0.45)
			if light_node.has_method("flicker_burst"):
				light_node.flicker_burst(2.0, 0.5)
		
		# Request event Tier 2 từ DistortionController
		var event = DistortionController.request_event(2, 2)
		
		Narrative.show_message("Đèn bếp cứ nhấp nháy như thế... Tớ không dám nhìn lâu.", 4.0)
		
		# Camera drift nhẹ tạo cảm giác không gian "lệch"
		await get_tree().create_timer(1.5).timeout
		var camera = player.find_child("Camera2D", true, false)
		if camera:
			camera.drift(Vector2(15, -8), 5.0)


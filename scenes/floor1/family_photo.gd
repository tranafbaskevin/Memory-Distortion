extends "res://components/anchor_object.gd"

@onready var sprite = get_node_or_null("Sprite2D")

func _ready() -> void:
	super._ready()
	anchor_id = "family_photo"
	prompt_message = "Nhấn E để xem ảnh gia đình"

func _interact(player: Node2D) -> void:
	_observed_count += 1
	Global.anchor_observations[anchor_id] = _observed_count
	
	# Tính toán mức độ méo mó dựa trên Fear Level hiện tại
	var fear = Global.fear_level
	var message = ""
	
	match fear:
		0:
			message = "Bức ảnh gia đình chụp năm tớ 10 tuổi. Mọi người đều cười rất tươi."
		1, 2:
			message = "Bức ảnh gia đình... Hình như khuôn mặt của tớ bị nhoè mờ đi một cách khó hiểu."
			if sprite:
				sprite.modulate = Color(0.8, 0.7, 0.7, 1.0)
		3, 4:
			message = "Bức ảnh gia đình... Khuôn mặt của tất cả mọi người đều bị cào xước nhem nhuốc. Thật đáng sợ."
			if sprite:
				sprite.modulate = Color(0.5, 0.2, 0.2, 1.0)
				# Rung camera nhẹ
				var camera = player.find_child("Camera2D", true, false)
				if camera and camera.has_method("shake"):
					camera.shake(1.5, 0.3, 20.0)
		5:
			message = "Chỉ còn tớ đứng một mình trong bức ảnh đen kịt. Phía sau có dòng chữ nguệch ngoạc: 'MÀY ĐÃ QUÊN'."
			if sprite:
				sprite.modulate = Color(0.1, 0.0, 0.0, 1.0)
				
	Narrative.show_message(message, 4.0)
	
	# Thông báo cho DistortionController
	DistortionController.notify_anchor_observed(anchor_id, _observed_count)
	
	# Nếu là lần 2+ hoặc fear level cao, cho hiệu ứng pulse phản hồi xác nhận
	if _observed_count >= 2 or fear >= 1:
		_pulse_feedback()
		
	# Gợi ý/Hook đầu game (Early Game Hook)
	# Nếu player xem ảnh lần đầu tiên trong vòng 2 phút đầu, kích hoạt thay đổi môi trường nhẹ
	if _observed_count == 1 and DistortionController.get_elapsed_minutes() < 2.0:
		# Tăng Fear level lên 1 ngay để kích thích progression
		Global.fear_level = clampi(Global.fear_level + 1, 0, 5)
		# Cho đèn phòng khách nháy nhẹ
		var light = get_node_or_null("../LivingRoomLight")
		if light and light.has_method("flicker_burst"):
			light.flicker_burst(1.0, 0.6)
		# Tiếng thở khẽ hoặc tiếng kẽo kẹt
		AudioManager.play_sfx_placeholder("early_hook_creak")
		print("[EarlyHook] Early game photo interaction triggered at: ", DistortionController.get_elapsed_minutes(), "m")

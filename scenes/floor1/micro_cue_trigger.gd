extends BaseTrigger

func _custom_ready() -> void:
	require_interaction = false

func _on_trigger_fired(player: Node2D) -> void:
	if not is_instance_valid(player):
		return
		
	# Chỉ kích hoạt nếu đã qua 60 giây (player có thời gian học không gian)
	# Và Controller đang ở Tier 0→1 (chưa có distortion chính thức)
	if DistortionController.get_elapsed_minutes() < 1.0:
		has_triggered = false # Cho phép thử lại lần sau nếu chưa đủ thời gian
		return
		
	_trigger_micro_cue()

func _trigger_micro_cue() -> void:
	# Tìm đèn toilet gần nhất
	var toilet_light = get_node_or_null("../ToiletDoorLight")
	
	# Nhấp nháy 1 lần duy nhất — không lặp lại
	if toilet_light:
		toilet_light.energy = 0.0
		await get_tree().create_timer(0.08).timeout
		toilet_light.energy = 1.0
		await get_tree().create_timer(0.06).timeout
		toilet_light.energy = 0.2
		await get_tree().create_timer(0.12).timeout
		toilet_light.energy = 1.0
	
	# Âm thanh mờ — rất nhẹ, không rõ nguồn gốc
	AudioManager.play_sfx_placeholder("light_buzz_brief")
	
	# KHÔNG có lời thoại. Không có giải thích.
	print("[MicroCueTrigger] Micro-cue fired at ", "%.1f" % DistortionController.get_elapsed_minutes(), " min")

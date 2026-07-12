extends EventTrigger

func _on_trigger(player: Node2D) -> void:
	# Chỉ kích hoạt nếu DistortionController chấp nhận sự kiện Tier 2
	var event = DistortionController.request_event(2, 2)
	if event == "":
		return
		
	var camera = player.find_child("Camera2D", true, false)

	if camera:
		print("[HORROR EVENT] Twitching camera zoom!")
		
		# Giật cận cảnh nhanh chóng (0.15s)
		camera.smooth_zoom(Vector2(1.25, 1.25), 0.15)
		
		# Chờ 0.25 giây
		await get_tree().create_timer(0.25).timeout
		
		# Trả lại góc nhìn bình thường
		camera.smooth_zoom(Vector2(1.0, 1.0), 0.3)

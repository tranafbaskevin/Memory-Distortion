## Hiệu ứng "hành lang dài hơn tớ nhớ" — Loop Illusion
## Khi player di chuyển qua điểm giữa hành lang, camera drift sang phải
## rồi tự trở về. Tạo cảm giác như hành lang tự kéo dài ra.
## Xác suất: 60% để không phải lúc nào cũng xảy ra
extends AdvancedEventTrigger

func _on_trigger(player: Node2D) -> void:
	var camera = player.find_child("Camera2D", true, false)
	if not camera:
		return
	
	# Drift sang phải nhẹ — hành lang "kéo dài"
	AudioManager.play_sfx_placeholder("low_hum_loop")
	camera.drift(Vector2(30, 0), 7.0)
	
	# Sau drift, lời thoại xuất hiện
	await get_tree().create_timer(3.5).timeout
	Narrative.show_message("Tớ đã đi được bao lâu rồi? Sao hành lang lại dài thế này?", 4.5)

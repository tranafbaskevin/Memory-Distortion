## Sự kiện đa bước ở hành lang tầng 2
## Bước 1: Player đi qua khu vực → KHÔNG có gì ngay lập tức
## Bước 2: Sau 3 giây → Camera rung nhẹ
## Bước 3: Sau 1.5 giây nữa → Tiếng thì thầm (placeholder) + lời thoại hoang mang
extends AdvancedEventTrigger

func _on_trigger(player: Node2D) -> void:
	var camera = player.find_child("Camera2D", true, false)
	
	# Vignette nhẹ khi sự kiện bắt đầu
	Vignette.show_vignette(0.25, 2.0)
	
	# Bước 1: Âm thanh mơ hồ (placeholder) — player nghe thấy gì đó lạ
	AudioManager.play_sfx_placeholder("hallway_creak")
	
	# Bước 2: Sau 3s camera rung nhẹ như thể ai đó đang đứng sau
	await get_tree().create_timer(3.0).timeout
	if camera:
		camera.shake(3.0, 0.4, 15.0)
	AudioManager.play_sfx_placeholder("whisper_01")
	
	# Bước 3: Sau thêm 1.5s lời thoại xuất hiện
	await get_tree().create_timer(1.5).timeout
	Narrative.show_message("Ai đó... vừa gọi tên tớ?", 4.0)
	
	# Bước 4: Camera drift rất nhẹ — hành lang "dài ra" một chút
	if camera:
		camera.drift(Vector2(25, 0), 6.0)
	
	# Kết thúc: Vignette nhạt dần về bình thường sau 5 giây
	await get_tree().create_timer(5.0).timeout
	Vignette.hide_vignette(3.0)

extends Node2D

func _ready() -> void:
	# Dừng nhạc nền cũ, chuyển sang ambient yên bình giải thoát
	AudioManager.stop_ambient()
	AudioManager.play_ambient_placeholder("true_ending_peaceful_chimes")
	
	# Hiển thị lời tự thoại kết thúc thật sự
	Narrative.show_message("Tớ chấp nhận. Bố không khóa cửa... chính tớ đã tự khóa chặt mình trong căn phòng tối tăm này vì nỗi sợ hãi và mặc cảm tội lỗi. Nhưng giờ đây, tớ sẽ mở nó ra.", 8.5)
	
	await get_tree().create_timer(9.0).timeout
	Narrative.show_message("Ký ức tan rã. Căn nhà biến mất. Tớ tự do.\n\n[KẾT THÚC THẬT SỰ — BẠN ĐÃ CHẤP NHẬN SỰ THẬT VÀ GIẢI THOÁT TÂM LÝ]", 15.0)

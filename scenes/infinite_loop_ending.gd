extends Node2D

func _ready() -> void:
	# Phát âm thanh rè điện ghê rợn
	AudioManager.stop_ambient()
	AudioManager.play_ambient_placeholder("infinite_loop_dread")
	
	# Hiển thị lời tự thoại về việc phủ nhận mãi mãi
	Narrative.show_message("Tớ đã chạy... và tớ sẽ tiếp tục chạy mãi mãi. Trong thế giới của riêng tớ, nơi bố luôn là người chịu mọi tội lỗi.", 8.5)
	
	await get_tree().create_timer(9.0).timeout
	Narrative.show_message("Không có lối thoát cho kẻ từ chối sự thật.\n\n[KẾT THÚC VÒNG LẶP PHỦ NHẬN — BẠN BỊ KẸT VĨNH VIỄN TRONG SỰ DỐI TRÁ CỦA KÝ ỨC]", 15.0)

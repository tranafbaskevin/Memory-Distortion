extends Node2D

func _ready() -> void:
	AudioManager.stop_ambient()
	AudioManager.play_ambient_placeholder("broken_ending_static")
	
	Narrative.show_message("Ký ức của tớ nửa thực nửa hư. Tớ chấp nhận một phần tội lỗi, nhưng tớ vẫn cố bấu víu vào những lời nói dối để tự bảo vệ. Tớ không còn biết mình thực sự là ai nữa.", 9.0)
	
	await get_tree().create_timer(9.5).timeout
	Narrative.show_message("Tâm trí tớ vỡ vụn thành từng mảnh. Căn nhà vẫn ở đó, bệnh viện vẫn ở đó, nhưng tớ mãi mãi điên loạn trong sự hỗn loạn của trí nhớ.\n\n[KẾT THÚC VỤN VỠ — BẠN KHÔNG THỂ HÒA GIẢI ĐƯỢC TÂM TRÍ CHÍNH MÌNH]", 15.0)

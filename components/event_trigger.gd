class_name EventTrigger
extends BaseTrigger

# Dòng thoại hiển thị khi chạm bẫy
@export var dialogue_text: String = ""

# Phát tín hiệu khi bẫy sự kiện được kích hoạt
signal triggered(player: Node2D)

func _custom_ready() -> void:
	# EventTrigger thường kích hoạt tự động khi giẫm vào
	require_interaction = false

func _on_trigger_fired(player: Node2D) -> void:
	print("[EVENT TRIGGER] Activated: ", name)
	
	# Phát tín hiệu ra ngoài
	triggered.emit(player)
	
	# Chạy hàm ảo xử lý sự kiện phụ
	_on_trigger(player)
	
	# Hiển thị lời thoại nếu có
	if dialogue_text != "":
		Narrative.show_message(dialogue_text)

# Hàm ảo để override tùy chỉnh sự kiện (ví dụ: rung camera, nháy đèn...)
func _on_trigger(_player: Node2D) -> void:
	pass

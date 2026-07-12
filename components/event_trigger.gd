class_name EventTrigger
extends Area2D

# Phát tín hiệu khi bẫy sự kiện được kích hoạt
signal triggered(player: Node2D)

# Sự kiện có thể kích hoạt nhiều lần không (nếu false chỉ kích hoạt 1 lần duy nhất)
@export var repeatable: bool = false
# Dòng thoại hiển thị khi chạm bẫy
@export var dialogue_text: String = ""

var has_triggered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if not repeatable and has_triggered:
			return
		
		has_triggered = true
		print("[EVENT TRIGGER] Activated: ", name)
		
		# Phát tín hiệu ra ngoài
		triggered.emit(body)
		
		# Chạy hàm ảo xử lý sự kiện phụ
		_on_trigger(body)
		
		# Hiển thị lời thoại nếu có
		if dialogue_text != "":
			Narrative.show_message(dialogue_text)

# Hàm ảo để override tùy chỉnh sự kiện (ví dụ: rung camera, nháy đèn...)
func _on_trigger(_player: Node2D) -> void:
	pass

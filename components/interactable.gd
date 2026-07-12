class_name Interactable
extends Area2D

# Phát tín hiệu khi đối tượng được tương tác
signal interacted(player: Node2D)

# Dòng chữ nhắc nhở người chơi tương tác (ví dụ: "Nhấn E để đọc nhật ký")
@export var prompt_message: String = "Nhấn E để tương tác"
# Dòng lời thoại/suy nghĩ hiển thị lên màn hình sau khi tương tác
@export var dialogue_text: String = ""
# Kích hoạt hoặc vô hiệu hóa tương tác
@export var is_active: bool = true

func _ready() -> void:
	# Thêm vào nhóm để Player dễ dàng quét và nhận diện Area2D này
	add_to_group("Interactable")

# Hàm chính xử lý khi người chơi ấn phím tương tác (E / Enter)
func interact(player: Node2D) -> void:
	if not is_active:
		return
	
	# Phát tín hiệu ra ngoài
	interacted.emit(player)
	
	# Gọi hàm ảo xử lý riêng của từng đối tượng
	_interact(player)
	
	# Hiển thị hội thoại thông qua Autoload Narrative
	if dialogue_text != "":
		Narrative.show_message(dialogue_text)

# Hàm ảo có thể được override bởi các script kế thừa (như Cửa)
func _interact(_player: Node2D) -> void:
	pass

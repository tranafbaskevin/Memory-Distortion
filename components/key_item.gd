## KeyItem — Vật phẩm chìa khoá có thể nhặt
## Kế thừa Interactable, một lần duy nhất
## Khi nhặt: Global.player_has_key = true, tự ẩn
class_name KeyItem
extends Interactable

func _ready() -> void:
	super._ready()
	prompt_message = "Nhấn E để nhặt chìa khoá"
	dialogue_text = "Một chiếc chìa khoá cũ kỹ. Nó dẫn đến đâu nhỉ?"
	
	# Nếu đã nhặt rồi thì tự ẩn ngay khi load scene
	if Global.player_has_key:
		hide()
		is_active = false

func _interact(_player: Node2D) -> void:
	if Global.player_has_key:
		return
	
	# Nhặt khoá
	Global.player_has_key = true
	AudioManager.play_key_pickup()
	
	# Vô hiệu hoá và ẩn đi
	is_active = false
	hide()
	
	print("[KeyItem] Key picked up!")

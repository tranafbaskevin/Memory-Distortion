## LockedDoor — Cửa bị khoá, chỉ mở được khi Player có chìa khoá
## Kế thừa door.gd (vốn kế thừa Interactable)
extends "res://environment/door.gd"

func _ready() -> void:
	super._ready()
	_update_prompt()

func _update_prompt() -> void:
	if Global.player_has_key:
		prompt_message = "Nhấn E để mở cửa"
	else:
		prompt_message = "Cửa bị khoá..."

func _interact(player: Node2D) -> void:
	if Global.player_has_key:
		# Mở cửa bình thường
		AudioManager.play_door_open()
		super._interact(player)
	else:
		# Cửa bị khoá — phát SFX và lời thoại
		AudioManager.play_door_locked()
		Narrative.show_message("Cửa bị khoá. Tớ cần tìm thứ gì đó để mở nó.", 3.0)
		
		# Rung camera nhẹ như thể player giật tay nắm cửa
		var camera = player.find_child("Camera2D", true, false)
		if camera:
			camera.shake(2.5, 0.2, 25.0)
		
		print("[LockedDoor] Door is locked. Player needs key.")

## Study Room — Phòng làm việc có chìa khoá ẩn
## Đây là phòng quan trọng nhất trong gameplay loop:
## Player phải tìm ra chìa khoá ở đây để thoát nhà
extends Node2D

@onready var key = $Key
@onready var player = $Player

func _ready() -> void:
	AudioManager.play_ambient_for_scene(scene_file_path, Global.bedroom_distorted)
	
	# Nếu đã nhặt khoá → khoá tự ẩn (xử lý bởi key_item.gd)
	if Global.player_has_key:
		if key:
			key.hide()
			key.is_active = false
	
	# Lời dẫn nhập nhẹ khi vào phòng lần đầu
	if not Global.room_visits.has("study_room"):
		await get_tree().create_timer(0.8).timeout
		Narrative.show_message("Phòng làm việc của bố. Giấy tờ vương vãi khắp nơi...", 3.5)
	
	if not Global.room_visits.has("study_room"):
		Global.room_visits["study_room"] = 0
	Global.room_visits["study_room"] += 1

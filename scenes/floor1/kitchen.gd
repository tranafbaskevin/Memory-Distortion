## Hệ thống bếp nhiều trạng thái — Environmental Storytelling
## Lần 1 vào: bình thường
## Lần 2 vào: cái ghế bị đẩy lệch nhẹ
## Lần 3+ vào: ánh sáng mờ dần, âm thanh rì rầm
extends Node2D

@onready var chair = $Chair
@onready var light_node = $KitchenLight
@onready var note_interactable = $NoteOnTable
@onready var player = $Player

const SCENE_ID = "kitchen"

func _ready() -> void:
	# Ghi nhận lượt vào phòng
	if not Global.room_visits.has(SCENE_ID):
		Global.room_visits[SCENE_ID] = 0
	Global.room_visits[SCENE_ID] += 1
	
	var visit = Global.room_visits[SCENE_ID]
	print("[Kitchen] Visit #", visit)
	
	_apply_state(visit)
	
	# Thông báo audio khi vào bếp
	AudioManager.play_ambient_placeholder("kitchen_ambient_hum")

func _apply_state(visit: int) -> void:
	match visit:
		1:
			# Lần đầu: bình thường hoàn toàn
			Narrative.show_message("Căn bếp vắng lặng. Mùi cơm nguội vẫn còn lảng vảng đâu đây.", 4.0)
		2:
			# Lần 2: cái ghế lệch sang một chút
			if chair:
				chair.position += Vector2(35, 20)
				chair.rotation_degrees = 12.0
			Narrative.show_message("Cái ghế... hình như đã bị ai đó đẩy ra.", 3.5)
		_:
			# Lần 3+: ánh sáng mờ + âm thanh bất thường
			if chair:
				chair.position += Vector2(80, 40)
				chair.rotation_degrees = 28.0
			if light_node:
				# Giảm năng lượng đèn tạo cảm giác tối hơn
				light_node.energy = 0.3
				light_node.color = Color(0.6, 0.5, 0.4)
			Narrative.show_message("Đèn bếp cứ nhấp nháy như thế... Tớ không dám nhìn lâu.", 4.0)
			AudioManager.play_sfx_placeholder("flicker_sound")
			
			# Camera drift nhẹ tạo cảm giác không gian "lệch"
			await get_tree().create_timer(1.5).timeout
			var camera = player.find_child("Camera2D", true, false)
			if camera:
				camera.drift(Vector2(15, -8), 5.0)

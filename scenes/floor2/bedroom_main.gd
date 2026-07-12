## Cập nhật bedroom_main — Thêm mảnh giấy nhàu nát, ambient khi vào,
## và tăng áp lực tâm lý khi distorted.
extends Node2D

@onready var diary = $Diary
@onready var desk = $Desk
@onready var red_shadow = $RedShadow
@onready var player = $Player
@onready var door = $DoorToHallway
@onready var crumpled_note = $CrumpledNote

const SCENE_ID = "bedroom_main"

func _ready() -> void:
	if not Global.room_visits.has(SCENE_ID):
		Global.room_visits[SCENE_ID] = 0
	Global.room_visits[SCENE_ID] += 1
	
	AudioManager.play_ambient_placeholder("bedroom_silence_hum")
	
	if Global.bedroom_distorted:
		_apply_distorted_state()
	else:
		_apply_normal_state()

func _apply_normal_state() -> void:
	if red_shadow:
		red_shadow.hide()
	if crumpled_note:
		crumpled_note.show()
	if diary:
		diary.is_active = true
		diary.interacted.connect(_on_diary_interacted)

func _apply_distorted_state() -> void:
	var tier = DistortionController.current_tier
	# 1. Cái bàn bị dịch chuyển tinh tế (lệch hướng khác mỗi lần)
	if desk:

		var offset_x = [-90, 120, -50][Global.room_visits[SCENE_ID] % 3]
		var offset_y = [40, -70, 30][Global.room_visits[SCENE_ID] % 3]
		desk.position += Vector2(offset_x, offset_y)
	
	# 2. Nhật ký biến mất
	if diary:
		diary.hide()
		diary.is_active = false
	
	# 3. Mảnh giấy nhàu vẫn còn nhưng dịch chuyển sang góc khác
	if crumpled_note:
		crumpled_note.position += Vector2(200, 100)
	
	# 4. Bóng đỏ xuất hiện ở góc — vị trí ngẫu nhiên giữa các lần vào
	if red_shadow:
		red_shadow.show()
		var corners = [Vector2(950, 100), Vector2(100, 500), Vector2(900, 520), Vector2(150, 100)]
		red_shadow.position = corners[Global.room_visits[SCENE_ID] % 4]
	
	# 5. Cửa dẫn đến nơi bất ngờ (luân phiên giữa các lần)
	if door:
		var visit = Global.room_visits[SCENE_ID]
		if visit % 2 == 0:
			door.target_scene = "res://scenes/floor2/study_room.tscn"
			door.prompt_message = "Nhấn E để mở cửa"
		else:
			door.target_scene = "res://scenes/floor2/bedroom_sibling.tscn"
			door.prompt_message = "Nhấn E để mở cửa"
	
	# 6. Camera ngột ngạt hơn theo level tier
	# 7. Vignette tối cạnh — áp lực tâm lý
	Vignette.show_vignette(0.2 + tier * 0.1, 2.0)
	
	# Request event Tier 3 từ DistortionController (spatial distortion)
	DistortionController.request_event(3, 3)
	
	await get_tree().create_timer(0.3).timeout
	var camera = player.find_child("Camera2D", true, false)
	if camera:
		var zoom_intensity = min(1.0 + tier * 0.15, 1.6)
		camera.smooth_zoom(Vector2(zoom_intensity, zoom_intensity), 2.0)
	
	# 7. Lời thoại thay đổi theo số lần vào
	var messages = [
		"Ủa... sao bàn học lại lệch đi thế kia? Cả căn phòng trông ngột ngạt quá...",
		"Lại rồi... lần này cái bàn ở chỗ khác nữa. Hay là do tớ nhớ nhầm?",
		"Tớ không muốn ở đây nữa. Có gì đó không ổn với căn phòng này."
	]
	var msg_idx = min(Global.room_visits[SCENE_ID] - 2, messages.size() - 1)
	Narrative.show_message(messages[msg_idx], 4.5)


func _on_diary_interacted(_player: Node2D) -> void:
	if not Global.bedroom_distorted:
		Global.bedroom_distorted = true
		Narrative.show_message("Nhật ký: 'Hôm nay tớ cảm giác như ai đó đã sắp xếp lại các căn phòng... Tốt nhất không nên ra ngoài...'", 5.5)
		AudioManager.play_sfx_placeholder("page_turn_eerie")
		
		# Thông báo cho DistortionController để tăng tier / unlock phòng
		DistortionController.notify_major_interaction("diary_read")


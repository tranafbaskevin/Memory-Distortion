extends Node2D

@onready var diary = $Diary
@onready var desk = $Desk
@onready var red_shadow = $RedShadow
@onready var player = $Player
@onready var door = $DoorToHallway

func _ready() -> void:
	# Kết nối tín hiệu tương tác từ Nhật ký
	if diary:
		diary.interacted.connect(_on_diary_interacted)
		
	# Nếu phòng đang ở trạng thái nhiễu ký ức (Memory Distortion)
	if Global.bedroom_distorted:
		# 1. Bất thường tinh tế: Dịch chuyển nhẹ vị trí cái bàn (Desk)
		if desk:
			desk.position += Vector2(120, -60)
			
		# 2. Cuốn nhật ký biến mất
		if diary:
			diary.hide()
			diary.is_active = false
			
		# 3. Hiện bóng đỏ mơ hồ ở góc phòng
		if red_shadow:
			red_shadow.show()
			
		# 4. Hiện thoại suy nghĩ hoang mang của nhân vật
		Narrative.show_message("Ủa... sao bàn học lại lệch đi thế kia? Cả căn phòng trông ngột ngạt quá...", 4.0)
		
		# 5. Rung / Zoom Camera cận cảnh hẹp hơn (tạo cảm giác bức bối)
		if player:
			var camera = player.find_child("Camera2D", true, false)
			if camera:
				camera.call_deferred("smooth_zoom", Vector2(1.5, 1.5), 1.5)
				
		# 6. KHÔNG GIAN BẤT THƯỜNG: Cửa ra thay vì dẫn ra hành lang thì dẫn thẳng tới Phòng làm việc (Study Room)
		if door:
			door.target_scene = "res://scenes/floor2/study_room.tscn"
			door.target_spawn_name = "SpawnPoint" # Spawn giữa phòng làm việc
			door.prompt_message = "Nhấn E để mở cửa"
	else:
		# Lần đầu vào phòng thì ẩn bóng đỏ
		if red_shadow:
			red_shadow.hide()

func _on_diary_interacted(_player: Node2D) -> void:
	if not Global.bedroom_distorted:
		# Kích hoạt cờ nhiễu ký ức cho lần vào sau
		Global.bedroom_distorted = true
		Narrative.show_message("Nhật ký: 'Hôm nay tớ cảm giác như ai đó đã sắp xếp lại các căn phòng... Tốt nhất không nên ra ngoài...'", 5.5)

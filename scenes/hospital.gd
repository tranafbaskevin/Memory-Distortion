extends Node2D

@onready var door = get_node("DoorToHallway")
@onready var player = get_node("Player")

var _is_showing_choices: bool = false
var _puzzle_solved: bool = false

func _ready() -> void:
	var title_label = get_node_or_null("RoomTitleOverlay/TitleLabel")
	if title_label:
		title_label.text = "PHÒNG BỆNH VIỆN"

	AudioManager.play_ambient_for_scene(scene_file_path)
	
	# Đăng ký signal của monitor
	var monitor = get_node_or_null("MonitorInteractable")
	if monitor:
		monitor.interacted.connect(_on_monitor_interacted)
		
	# Nếu đã giải từ trước (trong trường hợp load game)
	_puzzle_solved = Global.unlocked_rooms.get("hospital_puzzle_solved", false)
	if _puzzle_solved:
		if door:
			door.door_state = "unlocked"
			door.locked_hint = ""

func _on_monitor_interacted(_player: Node2D) -> void:
	if _puzzle_solved:
		var msg = "Màn hình Monitor hiển thị nhịp tim bình thường. Mọi thứ đã yên tĩnh."
		if Global.denial_level > 0:
			msg = "Màn hình hiển thị: 'Kevin - Bệnh án: Tai nạn'. Một ký ức sai lệch nhưng dễ chịu."
		else:
			msg = "Màn hình hiển thị: 'Kevin - Bệnh án: Tự chấn thương'. Sự thật đau đớn."
		Narrative.show_message(msg, 4.0)
		return
		
	_is_showing_choices = true
	if player and "speed_multiplier" in player:
		player.speed_multiplier = 0.0
		
	AudioManager.play_sfx_placeholder("monitor_alert")
	Narrative.show_message("Máy Monitor nhấp nháy báo động bệnh án của tớ:\n[1] CHẤP NHẬN: 'Tự hủy hoại bản thân'\n[2] PHỦ NHẬN: 'Tai nạn giao thông'", 8.0)

func _unhandled_input(event: InputEvent) -> void:
	if not _is_showing_choices:
		return
		
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			_resolve_puzzle(true)
		elif event.keycode == KEY_2:
			_resolve_puzzle(false)

func _resolve_puzzle(accept_truth: bool) -> void:
	_is_showing_choices = false
	_puzzle_solved = true
	Global.unlocked_rooms["hospital_puzzle_solved"] = true
	
	if player and "speed_multiplier" in player:
		player.speed_multiplier = 1.0
		
	if accept_truth:
		# Chấp nhận sự thật
		Global.truth_acceptance_level = clampi(Global.truth_acceptance_level + 1, 0, 5)
		SaveSystem.save_game()
		
		# Nháy màn hình monitor xanh lá xác nhận
		var monitor_sprite = get_node_or_null("MonitorInteractable/Sprite2D")
		if monitor_sprite:
			monitor_sprite.modulate = Color(0.2, 0.9, 0.2, 1.0)
			
		AudioManager.play_sfx_placeholder("monitor_chime_ok")
		Narrative.show_message("Tớ chấp nhận. Vết sẹo đó... là do tớ tự gây ra trong cơn khủng hoảng. Đèn báo xanh, cửa phòng bệnh mở khóa.", 5.0)
		
		if door:
			door.door_state = "unlocked"
			door.locked_hint = ""
	else:
		# Phủ nhận sự thật (chọn quen nhưng sai) -> denial_level +1, tạo loop giam lại giường bệnh
		Global.denial_level = clampi(Global.denial_level + 1, 0, 5)
		Global.loop_depth += 1
		SaveSystem.save_game()
		
		var monitor_sprite = get_node_or_null("MonitorInteractable/Sprite2D")
		if monitor_sprite:
			monitor_sprite.modulate = Color(0.9, 0.2, 0.2, 1.0) # Đỏ báo động phủ nhận
			
		AudioManager.play_sfx_placeholder("monitor_error")
		Narrative.show_message("Không! Đó chỉ là một tai nạn giao thông bất ngờ thôi! Căn phòng bắt đầu xoay chuyển...", 4.5)
		
		await get_tree().create_timer(3.5).timeout
		# Loop reset người chơi trở lại giường bệnh (vị trí SpawnPoint)
		Transition.change_scene("res://scenes/hospital.tscn", "SpawnPoint")

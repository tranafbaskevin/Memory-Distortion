extends "res://environment/door.gd"

var _is_showing_choices: bool = false
var _cached_player: Node2D = null

func _ready() -> void:
	super._ready()
	door_state = "locked" # Ban đầu là locked bằng chìa khóa vật lý
	locked_hint = "Cánh cửa thoát hiểm. Nó đã bị khóa chặt. Tớ cần tìm chìa khóa."

func _interact(player: Node2D) -> void:
	# Nếu chưa có chìa khoá, hành xử giống Door V2 locked bình thường
	if not Global.player_has_key:
		_handle_locked(player, locked_hint)
		return
		
	# Nếu có chìa khoá, kích hoạt puzzle Denial Wall (Bức Tường Phủ Nhận)
	_is_showing_choices = true
	_cached_player = player
	
	# Khóa di chuyển của player
	if "speed_multiplier" in player:
		player.speed_multiplier = 0.0
		
	AudioManager.play_sfx_placeholder("denial_wall_active")
	
	Narrative.show_message("Bức Tường Phủ Nhận chặn trước cửa. Tớ phải đối mặt:\n[1] CHẤP NHẬN SỰ THẬT (Tự khóa bản thân)\n[2] PHỦ NHẬN (Bố là người có lỗi)", 8.0)

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
	
	# Trả lại tốc độ di chuyển
	if is_instance_valid(_cached_player) and "speed_multiplier" in _cached_player:
		_cached_player.speed_multiplier = 1.0
		
	if accept_truth:
		# Người chơi chọn chấp nhận sự thật
		Global.truth_acceptance_level = clampi(Global.truth_acceptance_level + 2, 0, 5)
		SaveSystem.save_game()
		
		# Đọc trạng thái giải đố từ cả Mirror puzzle và Blind Spot puzzle
		var has_mirror_clue = Global.unlocked_rooms.get("mirror_puzzle_solved", false)
		var has_blind_spot_clue = Global.unlocked_rooms.get("blind_spot_solved", false)
		
		# Cần giải cả 2 puzzle và Acceptance Level >= 3 để đạt True Ending
		if Global.truth_acceptance_level >= 3 and has_mirror_clue and has_blind_spot_clue:
			Narrative.show_message("Tớ chấp nhận mọi thứ. Ký ức này là của tớ, tội lỗi này là của tớ. Cửa mở ra...", 4.5)
			AudioManager.play_door_open()
			await get_tree().create_timer(3.0).timeout
			Transition.change_scene("res://scenes/true_ending.tscn")
		else:
			# Chưa đủ bằng chứng để tự thuyết phục bản thân
			Narrative.show_message("Tớ cố chấp nhận... nhưng sâu trong lòng tớ vẫn hoài nghi và sợ hãi. (Tớ cần tìm thêm bằng chứng ở chiếc gương và chiếc tủ gỗ phòng ngủ...)", 5.5)
	else:
		# Người chơi phủ nhận sự thật -> Tăng loop_depth và denial_level
		Global.loop_depth += 1
		Global.denial_level = clampi(Global.denial_level + 1, 0, 5)
		Global.bedroom_distorted = false # Reset để chơi lại
		SaveSystem.save_game()
		
		# Nếu bị lặp lại quá sâu (từ 3 lần trở lên), giam cầm vĩnh viễn
		if Global.loop_depth >= 3:
			Narrative.show_message("Không! Không phải tớ! Tất cả là do bố! Tớ phải chạy thoát khỏi đây!", 4.0)
			AudioManager.play_sfx_placeholder("loop_reset_scary")
			await get_tree().create_timer(3.5).timeout
			Transition.change_scene("res://scenes/infinite_loop_ending.tscn")
		else:
			# Vòng lặp tiếp diễn, đưa về đầu Hallway F1
			Narrative.show_message("Không phải tớ! Tất cả là do bố! Tớ phải chạy thoát khỏi đây!", 4.0)
			AudioManager.play_sfx_placeholder("loop_reset_scary")
			
			# Tăng Fear Level khi bị loop lại
			Global.fear_level = clampi(Global.fear_level + 1, 0, 5)
			
			await get_tree().create_timer(3.5).timeout
			Transition.change_scene("res://scenes/floor1/hallway_f1.tscn", "SpawnStart")

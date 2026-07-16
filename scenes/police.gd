extends Node2D

@onready var door = get_node("DoorToHallway")
@onready var player = get_node("Player")

var _is_showing_choices: bool = false
var _puzzle_solved: bool = false

func _ready() -> void:
	AudioManager.play_ambient_for_scene(scene_file_path)
	
	var file_node = get_node_or_null("CaseFileInteractable")
	if file_node:
		file_node.interacted.connect(_on_file_interacted)
		
	# SYSTEM 4: Door anomalies on loop (Cửa bị xê dịch vị trí dị thường khi bị loop)
	var loops = Global.distortion_events_count
	if loops > 0:
		print("[Police] Applying door anomaly for loop depth: ", loops)
		if door:
			# Dịch cửa ra mép bên trái thay vì ở giữa
			door.position.x = 220.0 + (loops * 40.0)
			door.locked_hint = "Cửa dịch chuyển sai vị trí... Tớ cần phải hoàn tất hồ sơ vụ án."
			
	_puzzle_solved = Global.unlocked_rooms.get("police_puzzle_solved", false)
	if _puzzle_solved:
		if door:
			door.door_state = "unlocked"
			door.locked_hint = ""

func _on_file_interacted(_player: Node2D) -> void:
	if _puzzle_solved:
		Narrative.show_message("Hồ sơ vụ án kết luận bi kịch gia đình xảy ra do bạo hành và tự vệ... Dòng chữ đen lạnh lùng.", 4.5)
		return
		
	_is_showing_choices = true
	if player and "speed_multiplier" in player:
		player.speed_multiplier = 0.0
		
	AudioManager.play_sfx_placeholder("file_puzzle_active")
	Narrative.show_message("Đọc hồ sơ vụ án mạng nhà Kevin:\n[1] HỢP LÝ: Kẻ cướp đột nhập sát hại bố mẹ\n[2] KHÓ CHẤP NHẬN: Mâu thuẫn bạo lực, tự vệ dẫn đến bi kịch", 8.5)

func _unhandled_input(event: InputEvent) -> void:
	if not _is_showing_choices:
		return
		
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			_resolve_puzzle(false)
		elif event.keycode == KEY_2:
			_resolve_puzzle(true)

func _resolve_puzzle(accept_truth: bool) -> void:
	_is_showing_choices = false
	_puzzle_solved = true
	
	if player and "speed_multiplier" in player:
		player.speed_multiplier = 1.0
		
	if accept_truth:
		# Chấp nhận sự thật -> acceptance + 1
		Global.truth_acceptance_level = clampi(Global.truth_acceptance_level + 1, 0, 5)
		Global.unlocked_rooms["police_puzzle_solved"] = true
		SaveSystem.save_game()
		
		var file_sprite = get_node_or_null("CaseFileInteractable/Sprite2D")
		if file_sprite:
			file_sprite.modulate = Color(0.1, 0.65, 0.1, 1.0)
			
		AudioManager.play_sfx_placeholder("police_buzzer_ok")
		Narrative.show_message("Tớ thừa nhận sự thật đau đớn đó... Không có tên trộm nào. Đó là mâu thuẫn gia đình đỉnh điểm. Cửa đồn cảnh sát mở.", 5.5)
		
		if door:
			door.door_state = "unlocked"
			door.locked_hint = ""
	else:
		# Chọn Denial (phủ nhận) -> loop, tăng loop depth
		Global.denial_level = clampi(Global.denial_level + 1, 0, 5)
		Global.loop_depth += 1
		SaveSystem.save_game()
		
		AudioManager.play_sfx_placeholder("loop_reset_scary")
		Narrative.show_message("Không! Đó phải là một tên trộm! Bố mẹ rất yêu thương tớ, bố không làm thế! Tiếng còi đồn cảnh sát hú inh ỏi...", 4.5)
		
		await get_tree().create_timer(3.5).timeout
		# Loop reset
		Transition.change_scene("res://scenes/police.tscn", "SpawnPoint")
